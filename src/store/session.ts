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
// Every address names a pairing: /c-elixir for the sample it joins - `<host>-<guest>` -
// plus a tolerated trailing tab (/c-elixir/docs).  A language id is only a way in
// (/cpp), and resolves to the first pairing that host offers.  A nested /cpp/cpp-lua
// reads the same as the flat form, which is what the dashboard links.  The dashboard is
// a static bundle, so the path is resolved client-side with the History API.  A document
// with a null origin (file://) refuses path writes, so the query-string shape
// (?item=c-elixir) is used there instead - and that query shape is also what the deployed
// site's 404.html shim forwards, so `?item=` and `?tab=` stay readable in both forms.
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

// A subdomain names a pairing too: c-elixir.interop.pattygcoding.com is that sample, and
// c.interop.pattygcoding.com is resolved to the first pairing C hosts - a language is
// never a destination of its own.  The leftmost label is only read when it is an id the
// data knows, which keeps the apex domain, `www`, and any other service label out of it
// - and that is also what makes the rule work under `c-elixir.localhost` on a
// development machine.
function subdomainItem(): string | null {
    const labels = window.location.hostname.toLowerCase().split(".");
    if (labels.length < 2) {
        return null;
    }
    return data.knownItem(labels[0]) ? labels[0] : null;
}

interface LocationState {
    /** The pairing the address names - a language id resolves to its first one. */
    sampleId: string | null;
    tab: TabId;
    /** Whether the address wrote a language (``/cpp``) rather than a pairing. */
    namedLanguage: boolean;
    explicitTab: boolean;
}

// What the current address asks for, in either shape.
function locationState(): LocationState {
    const tail = window.location.pathname.slice(APP_DIR.length).replace(/\/+$/, "");
    const parts = tail ? tail.split("/").filter(Boolean) : [];
    const params = new URLSearchParams(window.location.search || "");
    // A trailing tab segment is tolerated on the path (/c-elixir/docs); the pairing is
    // the segment in front of it.
    const pathTab = parts.length > 1 && isTab(parts[parts.length - 1]) ? (parts.pop() as TabId) : "";
    // A nested address names the language first and the sample after it; the sample is
    // the destination in either form.
    const pathId =
        parts.length >= 2 && data.knownItem(parts[1])
            ? parts[1]
            : parts.length >= 1 && data.knownItem(parts[0])
              ? parts[0]
              : "";
    const queryId = params.get("item") || params.get("lang") || "";
    const named = data.knownItem(pathId) ? pathId : data.knownItem(queryId) ? queryId : subdomainItem();
    const rawTab = pathTab || params.get("tab") || "";
    return {
        // Nothing is ever "the language on its own": /cpp is the host's first pairing,
        // and the address is rewritten to name it (see `initSession`).
        sampleId: data.resolveSampleId(named),
        tab: isTab(rawTab) ? rawTab : "code",
        namedLanguage: data.isLanguage(named),
        explicitTab: !!(pathTab || params.get("tab")),
    };
}

// The address for what is on screen, in whichever shape the browser accepts.  Used for
// the sidebar's real links too, so a copied or middle-clicked link carries the current
// tab along with the pairing.  There is deliberately no "selected sample" parameter: a
// pairing is always named in the path, so two visitors who see the same panel see the
// same address.
export function stateUrl(sampleId: string, tab: TabId): string {
    const params = new URLSearchParams();
    if (!canWritePath) {
        params.set("item", sampleId);
    }
    // Addresses stay clean: name a tab only when the sample can show it.
    if (!data.tabAvailable(data.sampleById(sampleId), tab)) {
        tab = "code";
    }
    if (tab !== "code") {
        params.set("tab", tab);
    }
    const search = params.toString();
    const path = canWritePath ? APP_DIR + sampleId : window.location.pathname;
    return path + (search ? "?" + search : "");
}

function syncUrl(mode: "push" | "replace"): void {
    if (applyingHistory || !state.sampleId) {
        return;
    }
    const url = stateUrl(state.sampleId, state.tab);
    try {
        window.history[mode === "push" ? "pushState" : "replaceState"](null, "", url);
    } catch {
        // Belt and braces: keep the query shape such a document allows.
        canWritePath = false;
        syncUrl(mode);
    }
}

// Back/forward: rebuild the view from the address without writing it again.  An entry
// that names a language brings its list back with it.
function applyLocation(): void {
    const target = locationState();
    applyingHistory = true;
    if (target.sampleId && target.sampleId !== state.sampleId) {
        state.sampleId = target.sampleId;
    }
    state.mode = target.namedLanguage ? "languages" : "samples";
    switchTab(target.explicitTab ? target.tab : "code");
    applyingHistory = false;
}

// ---- Selection ------------------------------------------------------------------
export const state = reactive({
    /** The pairing on screen.  It is always a sample id - never a bare language. */
    sampleId: null as string | null,
    tab: "code" as TabId,
    query: "",
    host: "All",
    bridge: "All",
    guest: "All",
    /** Which list the sidebar is showing: every pairing, or one row per host language. */
    mode: "samples" as ModeId,
    /** The mobile drawer: a slide-in sidebar below `lg`. */
    sidebarOpen: false,
    /** The one filter dropdown allowed open at a time. */
    openMenu: null as MenuId | null,
});

export const activeSample = computed<Sample | undefined>(() => data.sampleById(state.sampleId));

export const currentName = computed<string>(() => activeSample.value?.name ?? "");

// The pairings this host offers - what the header's switcher lists and what the list
// marks as current.
export const pairings = computed<Sample[]>(() => data.pairingsForSample(activeSample.value));

export const pairingOptions = computed<FacetOption[]>(() =>
    pairings.value.map((pairing) => ({ value: pairing.id, label: pairing.name })),
);

// The switcher only appears where there is something to switch: a host with more than
// one pairing.
export const showSampleSwitcher = computed<boolean>(() => pairings.value.length > 1);

// The two sides the panel draws: the host program(s) on the left, the guest on the
// right.
export const hostFiles = computed<FileEntry[]>(() =>
    activeSample.value ? data.hostSideFiles(activeSample.value) : [],
);

export const guestFiles = computed<FileEntry[]>(() =>
    activeSample.value ? data.guestSideFiles(activeSample.value) : [],
);

// The extra facets (Host, Bridge) only describe a sample, so in the Languages list
// they are ignored and their rows hidden; Guest applies to both: it answers "which
// languages run a Rust helper" as readily as it filters the pairing list.
export const facetsApply = computed<boolean>(() => state.mode === "samples");

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
export const repoUrl = computed<string>(() => data.repoUrlFor(state.sampleId));

export const repoFolderName = computed<string>(() => data.repoFolder(state.sampleId));

// The tags the header shows beside the title: the two languages of the pairing, host
// first.  A guest that has a directory of its own still appears here as a name and an
// extension rather than as a link, because a click on the row it sits on belongs to
// the pairing being shown.
export const headerTags = computed<Named[]>(() =>
    activeSample.value ? data.pairingTags(activeSample.value) : [],
);

export const showDocsTab = computed<boolean>(() => data.tabAvailable(activeSample.value, "docs"));

export const showOutputTab = computed<boolean>(() => data.tabAvailable(activeSample.value, "output"));

export const docsText = computed<string>(() => activeSample.value?.readme ?? "");

export const outputText = computed<string>(() => activeSample.value?.output ?? "");

// The README the Docs tab is rendering, linked on GitHub - the same repository and
// folder the header's link uses, with the file named and the path encoded.
export const docsUrl = computed<string>(() => {
    const sample = activeSample.value;
    return sample ? data.repoBlobUrl(sample.folder + "/README.md") : "";
});

// Relative links inside a rendered README - "the Ruby sample is over there" - resolved
// against the sample's own folder in the repository, because on this page they would
// otherwise resolve against the address bar and 404.
export const resolveDocLink = computed<(href: string) => string>(() => {
    const folder = activeSample.value?.folder ?? "";
    return (href: string) => data.githubUrlForRelative(folder, href);
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

// Move to a pairing.  A tab the new one cannot show would leave an empty panel, so it
// falls back to the code before the address below is written - and the address always
// names the pairing, never a language.
function applySelection(sampleId: string): void {
    if (!sampleId) {
        return;
    }
    state.sampleId = sampleId;
    if (!data.tabAvailable(data.sampleById(sampleId), state.tab)) {
        state.tab = "code";
    }
    syncUrl("push");
}

// A tap on a row in the Languages list: the row stands for the host, and the panel
// opens the first pairing it offers - the guest that sorts first.  The list stays the
// languages one, so the host the visitor picked is still in front of them.
export function selectLanguage(languageId: string): void {
    const first = data.firstSampleIdForLanguage(languageId);
    if (!first) {
        return;
    }
    state.mode = "languages";
    applySelection(first);
    state.sidebarOpen = false;   // a tap on a list row ends that interaction
}

// A tap on a row in the Samples list: that pairing, with the samples list kept.
export function selectPairing(sampleId: string): void {
    state.mode = "samples";
    applySelection(sampleId);
    state.sidebarOpen = false;
}

// The header's switcher: another pairing of the same host.  The two code columns, the
// Docs tab and the Expected Output tab all describe one pairing, so switching it
// switches all of them - and the list the visitor was browsing stays as it was.
export function selectSample(sampleId: string): void {
    applySelection(sampleId);
}

// The pill only chooses which list the sidebar shows; the pairing on screen is the
// address, and switching lists never moves it.
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
}

export function switchTab(tab: TabId): void {
    if (!data.tabAvailable(activeSample.value, tab)) {
        tab = "code";
    }
    const changed = state.tab !== tab;
    state.tab = tab;
    if (changed) {
        syncUrl("push");
    }
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
// taken from the URL must not add a history entry).  An address that named a language
// - /cpp, ?item=cpp, or the cpp subdomain - is rewritten to the pairing it stands for,
// so what the visitor is looking at is what the address says.
export function initSession(): void {
    if (!data.hasData) {
        return;
    }
    const target = locationState();
    state.sampleId = target.sampleId ?? data.defaultSampleId();
    state.mode = target.namedLanguage ? "languages" : "samples";
    applyingHistory = true;
    switchTab(target.explicitTab ? target.tab : "code");
    applyingHistory = false;
    syncUrl("replace");

    window.addEventListener("popstate", applyLocation);
}
