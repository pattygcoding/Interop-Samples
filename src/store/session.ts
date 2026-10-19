import { computed, reactive } from "vue";
import type { FileEntry, Language, ModeId, Named, Sample, TabId } from "../types";
import * as data from "./data";

export type MenuId = "host" | "bridge" | "guest" | "sample";

export interface FacetOption {
    value: string;
    label: string;
}

const TABS: TabId[] = ["code", "docs", "output"];

function isTab(value: string): value is TabId {
    return (TABS as string[]).includes(value);
}

// ---- The address ----------------------------------------------------------------
// Every language and every sample is addressable on its own path: /c for the
// language, /c-elixir for the sample it hosts - `<host>-<guest>` - plus a tolerated
// trailing tab (/c/docs).  A nested /c/c-elixir reads the same as the flat form,
// which is what the dashboard links.  The dashboard is a static bundle, so the path
// is resolved client-side with the History API.  A document with a null origin
// (file://) refuses path writes, so the query-string shape (?item=c-elixir) is used
// there instead - and that query shape is also what the deployed site's 404.html shim
// forwards, so `?item=`, `?tab=` and `?sample=` stay readable in both forms.
//
// The directory the site itself is served from is whatever is left above the route:
// the tab and up to two ids the data knows are stripped, which is what makes one
// build work both at the custom domain's root (nothing left to strip) and under a
// `<user>.github.io/<repo>/` path - where "Interop-Samples" is not an id, so the
// strip stops above it.  Every link and every history write is built from this.
const APP_DIR = (function deploymentDir(): string {
    const parts = window.location.pathname.split("/").filter(Boolean);
    // The document itself: a deep link lands on `index.html?...` (that is what the
    // 404 shim forwards to), and the file is never part of the route.
    if (parts.length && /\.html?$/i.test(parts[parts.length - 1])) {
        parts.pop();
    }
    if (parts.length && isTab(parts[parts.length - 1])) {
        parts.pop();
    }
    let dropped = 0;
    while (parts.length && dropped < 2 && data.knownItem(parts[parts.length - 1])) {
        parts.pop();
        dropped += 1;
    }
    return parts.length ? "/" + parts.join("/") + "/" : "/";
})();

let applyingHistory = false;

// Can this document write a path?  Probing once here, rather than discovering it
// when the first write fails, keeps the sidebar's hrefs in the right shape from the
// very first render; the temporary URL is restored in the same tick, before
// anything can observe it.
let canWritePath = (function probePathWrites(): boolean {
    const original = window.location.href;
    try {
        window.history.replaceState(window.history.state, "", APP_DIR + "__path-probe__");
    } catch {
        return false;
    }
    try {
        window.history.replaceState(window.history.state, "", original);
    } catch {
        // keep going: the probe already told us path writes are allowed
    }
    return true;
})();

// A subdomain names an item too: ada.interop.pattygcoding.com is the Ada language
// page and c-elixir.interop.pattygcoding.com is that sample, so a pairing can be
// shared as a short host as well as a path.  The leftmost label is only read when it
// is an id the data knows, which keeps the apex domain, `www`, and any other service
// label out of it - and that is also what makes the rule work under `ada.localhost`
// on a development machine.
function subdomainItem(): string | null {
    const labels = window.location.hostname.toLowerCase().split(".");
    if (labels.length < 2) {
        return null;
    }
    return data.knownItem(labels[0]) ? labels[0] : null;
}

interface LocationState {
    itemId: string | null;
    tab: TabId;
    /** Which of a language's samples is on screen; null means its first. */
    sampleId: string | null;
    explicitTab: boolean;
}

// What the current address asks for, in either shape.
function locationState(): LocationState {
    const tail = window.location.pathname.slice(APP_DIR.length).replace(/\/+$/, "");
    const parts = tail ? tail.split("/").filter(Boolean) : [];
    const params = new URLSearchParams(window.location.search || "");
    // A trailing tab segment is tolerated on the path (/ada/docs); the item is the
    // segment in front of it.
    const pathTab = parts.length > 1 && isTab(parts[parts.length - 1]) ? (parts.pop() as TabId) : "";
    // A nested address names the language first and the sample after it; the sample
    // is the item in either form.
    const pathId =
        parts.length >= 2 && data.knownItem(parts[1])
            ? parts[1]
            : parts.length >= 1 && data.knownItem(parts[0])
              ? parts[0]
              : "";
    const queryId = params.get("item") || params.get("lang") || "";
    const itemId = data.knownItem(pathId)
        ? pathId
        : data.knownItem(queryId)
          ? queryId
          : subdomainItem();
    const rawTab = pathTab || params.get("tab") || "";
    return {
        itemId,
        tab: isTab(rawTab) ? rawTab : "code",
        // A sample's own page names it in the path and needs nothing here; this is how
        // a language page says which of its pairings is open.
        sampleId: params.get("sample"),
        explicitTab: !!(pathTab || params.get("tab")),
    };
}

// The address for what is on screen, in whichever shape the browser accepts.  Used
// for the sidebar's real links too, so a copied or middle-clicked link carries the
// current tab (and sample) along with the item.
export function stateUrl(itemId: string, tab: TabId, sampleId: string | null): string {
    const params = new URLSearchParams();
    if (!canWritePath) {
        params.set("item", itemId);
    }
    // Addresses stay clean: name a tab only when the sample can show it, and name a
    // sample only when it is not the one the item opens on anyway.
    if (!data.tabAvailable(itemId, tab, sampleId)) {
        tab = "code";
    }
    if (tab !== "code") {
        params.set("tab", tab);
    }
    if (sampleId && sampleId !== data.defaultSampleId(itemId)) {
        params.set("sample", sampleId);
    }
    const search = params.toString();
    const path = canWritePath ? APP_DIR + itemId : window.location.pathname;
    return path + (search ? "?" + search : "");
}

function syncUrl(mode: "push" | "replace"): void {
    if (applyingHistory || !state.itemId) {
        return;
    }
    const url = stateUrl(state.itemId, state.tab, state.sampleId);
    try {
        window.history[mode === "push" ? "pushState" : "replaceState"](null, "", url);
    } catch {
        // Belt and braces: keep the query shape such a document allows.
        canWritePath = false;
        syncUrl(mode);
    }
}

// Back/forward: rebuild the view from the address without writing it again.
function applyLocation(): void {
    const target = locationState();
    applyingHistory = true;
    if (target.itemId && target.itemId !== state.itemId) {
        state.itemId = target.itemId;
        state.sampleId = data.defaultSampleId(target.itemId);
        syncMode();
    }
    const wanted = data.sampleForItem(state.itemId, target.sampleId);
    if (wanted) {
        state.sampleId = wanted.id;
    }
    switchTab(target.explicitTab ? target.tab : "code");
    applyingHistory = false;
}

// ---- Selection ------------------------------------------------------------------
export const state = reactive({
    itemId: null as string | null,
    tab: "code" as TabId,
    /** The sample on screen: a language page's pairing is chosen here. */
    sampleId: null as string | null,
    query: "",
    host: "All",
    bridge: "All",
    guest: "All",
    mode: "languages" as ModeId,
    /** The mobile drawer: a slide-in sidebar below `lg`. */
    sidebarOpen: false,
    /** The one filter dropdown allowed open at a time. */
    openMenu: null as MenuId | null,
});

export const sampleSelected = computed<boolean>(() => data.isSample(state.itemId));

export const currentName = computed<string>(() => data.itemName(state.itemId));

export const currentKind = computed<string>(() => (sampleSelected.value ? "Interop sample" : "Host language"));

// The extra facets (Host, Bridge) only describe a sample, so in Languages mode they
// are ignored and their rows hidden; Guest applies to both: it answers "which
// languages run a Rust helper" as readily as it filters the sample list.
export const facetsApply = computed<boolean>(() => sampleSelected.value);

// The samples this item can show: one for a sample page, and every pairing a
// language hosts - guest-alphabetical - for a language page.
export const samples = computed<Sample[]>(() => data.samplesForItem(state.itemId));

export const activeSample = computed<Sample | undefined>(() =>
    data.sampleForItem(state.itemId, state.sampleId),
);

// The two sides the panel draws: the host program(s) on the left, the guest on the
// right.
export const hostFiles = computed<FileEntry[]>(() =>
    activeSample.value ? data.hostSideFiles(activeSample.value) : [],
);

export const guestFiles = computed<FileEntry[]>(() =>
    activeSample.value ? data.guestSideFiles(activeSample.value) : [],
);

// The switcher only appears where there is something to switch: a language page with
// more than one pairing.  A sample page *is* the pairing.
export const showSampleSwitcher = computed<boolean>(() => !sampleSelected.value && samples.value.length > 1);

export const sampleOptions = computed<FacetOption[]>(() =>
    samples.value.map((sample) => ({ value: sample.id, label: sample.name })),
);

export const modeItems = computed(() => (facetsApply.value ? data.samples() : data.languages()));

function matchesQuery(haystack: string): boolean {
    const query = state.query.trim().toLowerCase();
    return query === "" || haystack.toLowerCase().includes(query);
}

export const visibleSamples = computed<Sample[]>(() => {
    if (!facetsApply.value) {
        return [];
    }
    const host = state.host;
    const bridge = state.bridge;
    const guest = state.guest;
    return data.samples().filter((sample) => {
        const matchesHost = host === "All" || sample.host.name === host || sample.host.id === host;
        const matchesBridge = bridge === "All" || sample.bridgeFamily.id === bridge;
        const matchesGuest = guest === "All" || sample.guest.name === guest;
        const haystack = [
            sample.name,
            sample.id,
            sample.host.name,
            sample.guestLabel,
            sample.guest.name,
            sample.bridge,
            sample.bridgeFamily.name,
            sample.platform,
            sample.folder,
        ].join(" ");
        return matchesHost && matchesBridge && matchesGuest && matchesQuery(haystack);
    });
});

export const visibleLanguages = computed<Language[]>(() => {
    if (facetsApply.value) {
        return [];
    }
    const guest = state.guest;
    return data.languages().filter((language) => {
        const matchesGuest = guest === "All" || language.guests.some((item) => item.name === guest);
        const haystack = [language.name, language.id, language.extension]
            .concat(language.guests.map((item) => item.name))
            .join(" ");
        return matchesGuest && matchesQuery(haystack);
    });
});

export const visibleCount = computed<number>(
    () => visibleSamples.value.length + visibleLanguages.value.length,
);

export const listMessage = computed<string>(() => {
    if (modeItems.value.length === 0) {
        return facetsApply.value ? "No samples yet." : "No languages yet.";
    }
    return "No " + state.mode + " match your search.";
});

export const searchPlaceholder = computed<string>(() =>
    facetsApply.value ? "Search samples..." : "Search languages...",
);

export const metaLine = computed<string>(() => {
    const meta = data.DATA?.meta;
    const languages = meta?.languageCount || data.languages().length;
    const samples = meta?.sampleCount || data.samples().length;
    return (
        languages + " languages \u00b7 " + samples + " samples\nupdated " + (meta?.updated || "n/a")
    );
});

// The repository root itself, behind the sidebar's GitHub mark: a real link rather
// than a per-folder one, so the whole project is one click away from every screen.
export const repoHomeUrl = computed<string>(() => data.repoHomeUrl());

// ---- The detail panel -----------------------------------------------------------
export const repoUrl = computed<string>(() => data.repoUrlFor(state.itemId));

export const repoFolderName = computed<string>(() => data.repoFolder(state.itemId));

// The tags the header shows beside the title: a sample's host and guest, or every
// guest a language hosts.  A guest that has a directory of its own still appears
// here as a name and an extension rather than as a link, because a click on the row
// it sits on belongs to the item being shown.
export const headerTags = computed<Named[]>(() => {
    const sample = data.sampleById(state.itemId);
    if (sample) {
        return data.pairingTags(sample);
    }
    return data.languageById(state.itemId)?.guests ?? [];
});

export const showDocsTab = computed<boolean>(() =>
    data.tabAvailable(state.itemId, "docs", activeSample.value?.id ?? null),
);

export const showOutputTab = computed<boolean>(() =>
    data.tabAvailable(state.itemId, "output", activeSample.value?.id ?? null),
);

export const docsText = computed<string>(() => activeSample.value?.readme ?? "");

export const outputText = computed<string>(() => activeSample.value?.output ?? "");

// The README the Docs tab is rendering, linked on GitHub - the same repository the
// folder link uses, with the file named this time.
export const docsUrl = computed<string>(() => {
    const repository = data.DATA?.meta?.repository;
    const sample = activeSample.value;
    if (!repository || !sample) {
        return "";
    }
    return repository + "/blob/" + (data.DATA?.meta?.branch || "main") + "/" + sample.folder + "/README.md";
});

// ---- Facets ---------------------------------------------------------------------
function countsBy(values: string[]): { value: string; count: number }[] {
    const counted = new Map<string, number>();
    for (const value of values) {
        counted.set(value, (counted.get(value) ?? 0) + 1);
    }
    return [...counted.entries()]
        .map(([value, count]) => ({ value, count }))
        .sort((a, b) => b.count - a.count || a.value.localeCompare(b.value));
}

export const hostOptions = computed<FacetOption[]>(() =>
    [{ value: "All", label: "All host languages" }].concat(
        countsBy(data.samples().map((sample) => sample.host.name)).map((entry) => ({
            value: entry.value,
            label: entry.value + " (" + entry.count + ")",
        })),
    ),
);

export const bridgeOptions = computed<FacetOption[]>(() =>
    [{ value: "All", label: "All bridge styles" }].concat(
        countsBy(data.samples().map((sample) => sample.bridgeFamily.id)).map((entry) => {
            const family = data.samples().find((sample) => sample.bridgeFamily.id === entry.value)?.bridgeFamily;
            return { value: entry.value, label: (family?.name ?? entry.value) + " (" + entry.count + ")" };
        }),
    ),
);

export const guestOptions = computed<FacetOption[]>(() =>
    [{ value: "All", label: "All guest languages" }].concat(
        countsBy(data.samples().map((sample) => sample.guest.name)).map((entry) => ({
            value: entry.value,
            label: entry.value + " (" + entry.count + ")",
        })),
    ),
);

// ---- Actions --------------------------------------------------------------------
export function setQuery(value: string): void {
    state.query = value;
}

export function setFacet(facet: MenuId, value: string): void {
    if (facet === "sample") {
        selectSample(value);
        return;
    }
    state[facet] = value;
}

// Keep the browse mode in step with the selection: opening /c-elixir (or navigating
// back to it) must reveal the Samples list it belongs to.
function syncMode(): void {
    const mode: ModeId = data.isSample(state.itemId) ? "samples" : "languages";
    if (mode === state.mode) {
        return;
    }
    state.mode = mode;
    state.host = "All";
    state.bridge = "All";
    state.guest = "All";
}

// Move the selection.  A tab the new item cannot show would leave an empty panel, and
// a sample that belongs to the previous item would show the wrong pairing, so both
// fall back to that item's own before the address below is written.
function applySelection(id: string): void {
    if (!id) {
        return;
    }
    state.itemId = id;
    state.sampleId = data.defaultSampleId(id);
    if (!data.tabAvailable(id, state.tab, state.sampleId)) {
        state.tab = "code";
    }
    syncUrl("push");
}

export function selectItem(id: string): void {
    applySelection(id);
    // A tap on a list row ends that interaction, so the mobile drawer goes away.
    // `setMode` moves the selection through `applySelection` instead, because there
    // the sidebar has to stay open and show the list that was just asked for.
    state.sidebarOpen = false;
}

export function setMode(mode: ModeId): void {
    if (mode === state.mode) {
        return;
    }
    state.mode = mode;
    // Switching lists resets the search and every facet, to keep the two lists
    // independent; the search box empties with `state.query`.
    state.query = "";
    state.host = "All";
    state.bridge = "All";
    state.guest = "All";
    const items = mode === "samples" ? data.samples() : data.languages();
    if (items.some((item) => item.id === state.itemId)) {
        syncUrl("push");
        return;
    }
    // Carry the context across instead of dropping to the top of the list: a sample
    // belongs to a host language, and a language's first sample is where its own
    // list starts.
    const carried =
        mode === "languages"
            ? activeSample.value?.host.id ?? ""
            : data.languageById(state.itemId)?.sampleIds[0] ?? "";
    applySelection(data.knownItem(carried) ? carried : items[0]?.id ?? "");
}

export function switchTab(tab: TabId): void {
    if (!data.tabAvailable(state.itemId, tab, state.sampleId)) {
        tab = "code";
    }
    const changed = state.tab !== tab;
    state.tab = tab;
    if (changed) {
        syncUrl("push");
    }
}

// The sample switcher on a language page.  The two code columns, the Docs tab and the
// Expected Output tab all describe one pairing, so switching it switches all of them.
export function selectSample(id: string): void {
    if (!id || id === state.sampleId) {
        return;
    }
    state.sampleId = id;
    syncUrl("push");
}

export function toggleSidebar(): void {
    state.sidebarOpen = !state.sidebarOpen;
}

export function closeSidebar(): void {
    state.sidebarOpen = false;
}

export function toggleMenu(id: MenuId): void {
    state.openMenu = state.openMenu === id ? null : id;
}

export function closeMenus(): void {
    state.openMenu = null;
}

// Mirror the address into the view; the address is only written at the end (a tab
// taken from the URL must not add a history entry).
export function initSession(): void {
    if (!data.hasData) {
        return;
    }
    const target = locationState();
    state.itemId = target.itemId ?? data.defaultItemId();
    state.sampleId = data.sampleForItem(state.itemId, target.sampleId)?.id ?? data.defaultSampleId(state.itemId);
    syncMode();
    applyingHistory = true;
    switchTab(target.explicitTab ? target.tab : "code");
    applyingHistory = false;
    syncUrl("replace");   // canonical address for what is on screen

    window.addEventListener("popstate", applyLocation);
}
