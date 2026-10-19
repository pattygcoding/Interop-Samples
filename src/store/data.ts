import type { FileEntry, InteropData, Language, Named, Sample } from "../types";

// Everything the dashboard displays, read straight from the generated payload.
// These helpers are pure lookups over `DATA` - the reactive selection on top of
// them lives in `session.ts`.
export const DATA: InteropData | undefined = window.INTEROP_DATA;

// A checkout that has not run the generator yet still boots and shows the empty
// state (which says how to generate the data) instead of throwing.
export const hasData: boolean = !!DATA && Array.isArray(DATA.languages) && DATA.languages.length > 0;

// The last-resort repository, for the one place a link cannot read `meta`: a
// checkout that has not generated the showcase data yet.  The generator writes the
// real one (git remote, else GITHUB_REPOSITORY, else this same default).
const DEFAULT_REPOSITORY = "https://github.com/pattygcoding/Interop-Samples";

// A sample is two programs, and the panel shows both at once: the host on the left,
// the guest on the right.  `support` files - the Node host Elm needs, a driver the
// build produces - belong to the host side, which is the side that runs them.
export function hostSideFiles(sample: Sample): FileEntry[] {
    return sample.files.filter((file) => file.role !== "guest");
}

export function guestSideFiles(sample: Sample): FileEntry[] {
    return sample.files.filter((file) => file.role === "guest");
}

export function languages(): Language[] {
    return DATA?.languages ?? [];
}

export function samples(): Sample[] {
    return DATA?.samples ?? [];
}

export function languageById(id: string | null | undefined): Language | undefined {
    if (!id) {
        return undefined;
    }
    return languages().find((item) => item.id === id);
}

export function sampleById(id: string | null | undefined): Sample | undefined {
    if (!id) {
        return undefined;
    }
    return samples().find((item) => item.id === id);
}

export function isLanguage(id: string | null | undefined): boolean {
    return !!languageById(id);
}

export function isSample(id: string | null | undefined): boolean {
    return !!sampleById(id);
}

// Anything that decides whether an id in an address is real reads this.
export function knownItem(id: string | null | undefined): boolean {
    return isLanguage(id) || isSample(id);
}

// What the showcase opens on when the address names nothing: the first host
// language in the list (Ada), whose first sample fills the detail panel.
export function defaultItemId(): string | null {
    return languages()[0]?.id ?? samples()[0]?.id ?? null;
}

export function itemName(id: string | null): string {
    return languageById(id)?.name ?? sampleById(id)?.name ?? "";
}

// The samples an item can show.  A sample item is one sample; a language item is
// every sample it hosts, in the order the generator sorted them - host, then guest
// alphabetically - which is what makes the first entry the guest that sorts first.
export function samplesForItem(itemId: string | null): Sample[] {
    const sample = sampleById(itemId);
    if (sample) {
        return [sample];
    }
    const language = languageById(itemId);
    if (!language) {
        return [];
    }
    return language.sampleIds
        .map((id) => sampleById(id))
        .filter((entry): entry is Sample => !!entry);
}

// The sample the panel opens on: the first one the generator listed, which is the
// alphabetically-first guest language of that host.
export function defaultSampleId(itemId: string | null): string | null {
    return samplesForItem(itemId)[0]?.id ?? null;
}

export function sampleForItem(itemId: string | null, sampleId: string | null): Sample | undefined {
    const choices = samplesForItem(itemId);
    if (sampleId) {
        const match = choices.find((entry) => entry.id === sampleId);
        if (match) {
            return match;
        }
    }
    return choices[0];
}

// Whether a sample can show a tab: every sample has its source, and the Docs and
// Expected Output tabs need the sample's README and its expected-output block.
export function tabAvailable(itemId: string | null, tab: string, sampleId: string | null): boolean {
    if (tab === "code") {
        return true;
    }
    const sample = sampleForItem(itemId, sampleId);
    if (tab === "docs") {
        return !!sample?.readme;
    }
    if (tab === "output") {
        return !!sample?.output;
    }
    return false;
}

// The folder an item lives in, used for its GitHub link.
export function repoFolder(itemId: string | null): string {
    const sample = sampleById(itemId);
    if (sample) {
        return sample.folder;
    }
    return languageById(itemId)?.name ?? "";
}

// `<repository>/tree/<branch>/<folder>`, from the repository and branch the
// generator recorded (the git remote, else GITHUB_REPOSITORY, else its default),
// so a clone or a fork links to the right project.
export function repoUrlFor(itemId: string | null): string {
    const repository = DATA?.meta?.repository;
    const folder = repoFolder(itemId);
    if (!repository || !folder) {
        return "";
    }
    return repository + "/tree/" + (DATA?.meta?.branch || "main") + "/" + folder;
}

// The repository root itself, behind the sidebar's GitHub mark.
export function repoHomeUrl(): string {
    return DATA?.meta?.repository || DEFAULT_REPOSITORY;
}

// A language's short file-extension tag (".adb", ".py") - how the tags in the
// sidebar and the header identify it.
export function languageTag(name: string): string {
    return DATA?.extensions?.[name] ?? name;
}

// Whether a platform reads as "runs everywhere": a sample tied to one operating
// system gets a badge instead of the sentence the header shows.
export function isPortable(platform: string): boolean {
    const normalised = platform.trim().toLowerCase();
    return normalised === "" || normalised === "any" || normalised === "any (jvm)";
}

// The languages a sample pairs up, host first - the two tags in the header.
export function pairingTags(sample: Sample): Named[] {
    return [sample.host, sample.guest];
}

// The line-number column beside the code: one number per line, trimmed of the
// trailing blank lines a file ends with.
export function lineNumbersFor(text: string): string {
    const normalized = text.replace(/\n+$/, "");
    const count = normalized.length ? normalized.split("\n").length : 1;
    const numbers: number[] = [];
    for (let line = 1; line <= count; line += 1) {
        numbers.push(line);
    }
    return numbers.join("\n");
}
