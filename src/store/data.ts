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

// Anything that decides whether an id in an address is real reads this.  A language
// id is still real - /cpp is a link people may have - but it is only ever a way in.
export function knownItem(id: string | null | undefined): boolean {
    return isLanguage(id) || isSample(id);
}

// What the showcase opens on when the address names nothing at all: the first host
// language's first pairing, which is the first sample the generator listed.
export function defaultSampleId(): string | null {
    const language = languages()[0];
    return firstSampleIdForLanguage(language?.id ?? null) ?? samples()[0]?.id ?? null;
}

// The pairings one host language offers, in the order the generator sorted them:
// guest alphabetically.  This is what the header's switcher lists.
export function languageSamples(languageId: string | null): Sample[] {
    const language = languageById(languageId);
    if (!language) {
        return [];
    }
    return language.sampleIds
        .map((id) => sampleById(id))
        .filter((entry): entry is Sample => !!entry);
}

// The pairing a language id stands for: the first one it hosts, which is the guest
// that sorts first.  Nothing in the dashboard is ever "the language on its own" - the
// address always names a pairing - so this is how `/cpp` becomes `/cpp-assembly-32bit`.
export function firstSampleIdForLanguage(languageId: string | null): string | null {
    return languageSamples(languageId)[0]?.id ?? null;
}

// An id from an address resolved to the pairing it means: a sample id is itself, and a
// language id is that host's first pairing.  Anything else is not a destination.
export function resolveSampleId(id: string | null | undefined): string | null {
    if (isSample(id)) {
        return id ?? null;
    }
    return firstSampleIdForLanguage(id ?? null);
}

// The pairings this sample's host offers, so a page can move between them - the two
// code columns, the Docs tab and the Expected Output tab all follow.
export function pairingsForSample(sample: Sample | undefined): Sample[] {
    if (!sample) {
        return [];
    }
    const pairings = languageSamples(sample.host.id);
    return pairings.length ? pairings : [sample];
}

// Whether a sample can show a tab: every sample has its source, and the Docs and
// Expected Output tabs need its README and its expected-output block.
export function tabAvailable(sample: Sample | undefined, tab: string): boolean {
    if (tab === "code") {
        return true;
    }
    if (tab === "docs") {
        return !!sample?.readme;
    }
    if (tab === "output") {
        return !!sample?.output;
    }
    return false;
}

// The folder the sample lives in, used for its GitHub link.
export function repoFolder(sampleId: string | null): string {
    return sampleById(sampleId)?.folder ?? "";
}

// `<repository>/tree/<branch>/<folder>`, from the repository and branch the generator
// recorded (the git remote, else GITHUB_REPOSITORY, else its default), so a clone or a
// fork links to the right project.  The folder is percent-encoded, so a name with a
// space, a `+` or a `#` in it opens the folder rather than a fragment of the URL.
export function repoUrlFor(itemId: string | null): string {
    return repoTreeUrl(repoFolder(itemId));
}

// The repository root itself, behind the sidebar's GitHub mark.
export function repoHomeUrl(): string {
    return DATA?.meta?.repository || DEFAULT_REPOSITORY;
}

export function branch(): string {
    return DATA?.meta?.branch || "main";
}

// GitHub's own URLs for this repository percent-encode the characters a path cannot
// carry: a space is ``%20``, ``C++`` is ``C%2B%2B`` and - the one that silently
// breaks a link rather than merely looking untidy - ``F#`` is ``F%23``, because a
// bare ``#`` turns everything after it into a fragment.  Brackets are left as they
// are, exactly as the README's own sample index writes them.  Each segment is encoded
// on its own, so the slashes that separate them survive.
const SAFE_SEGMENT_CHARACTERS = /[A-Za-z0-9\-._~()]/;

export function encodeRepoPath(path: string): string {
    return path
        .split("/")
        .map((segment) =>
            [...segment]
                .map((character) =>
                    SAFE_SEGMENT_CHARACTERS.test(character)
                        ? character
                        : encodeURIComponent(character),
                )
                .join(""),
        )
        .join("/");
}

export function repoTreeUrl(folder: string): string {
    const repository = DATA?.meta?.repository;
    if (!repository || !folder) {
        return "";
    }
    return repository + "/tree/" + branch() + "/" + encodeRepoPath(folder);
}

export function repoBlobUrl(path: string): string {
    const repository = DATA?.meta?.repository;
    if (!repository || !path) {
        return "";
    }
    return repository + "/blob/" + branch() + "/" + encodeRepoPath(path);
}

// A README may write its links percent-encoded (`C%2B%2B%20with%20Lua`), so each
// segment is decoded before it is re-encoded; a stray `%` that is not an escape is
// kept as written rather than thrown away.
function decodePathSegment(segment: string): string {
    try {
        return decodeURIComponent(segment);
    } catch {
        return segment;
    }
}

// A relative link inside a sample's README, pointed at the file it names on GitHub.
//
// The READMEs link to each other - ``../Bash/Bash with Pascal/README.md`` - and those
// links mean nothing on the site: the Docs tab renders the README at the page's own
// address, so a relative href would resolve against that and 404.  Resolving it
// against the sample's folder in the repository is what the link meant in the first
// place, and GitHub then shows the target with its history and its own relative links
// intact.  "" leaves the link as the README wrote it (an absolute URL, or a fragment
// pointing inside the same document).
export function githubUrlForRelative(folder: string, href: string): string {
    const repository = DATA?.meta?.repository;
    if (!repository || !folder) {
        return "";
    }
    const [path, fragment] = href.split("#", 2);
    if (!path) {
        return "";   // "#section": a jump inside the rendered README
    }
    const segments = folder.split("/");
    for (const part of path.split("/")) {
        if (part === "" || part === ".") {
            continue;
        }
        if (part === "..") {
            segments.pop();
            continue;
        }
        segments.push(decodePathSegment(part));
    }
    const target = segments.join("/");
    // A file is shown with `blob`, a directory with `tree` - the READMEs link to both.
    const kind = /\.[a-z0-9]+$/i.test(target) ? "blob" : "tree";
    return (
        repository + "/" + kind + "/" + branch() + "/" + encodeRepoPath(target) +
        (fragment ? "#" + fragment : "")
    );
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
