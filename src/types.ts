// The shape of `public/interop-data.js`, which tools/generate_dashboard.py writes
// from the real repository.  A language and a sample are described by different
// fields - a language is a directory holding samples, a sample is one pairing of
// two programs - but both are addressed by the same kind of id, so the router and
// the sidebar can treat them alike.

export type TabId = "code" | "docs" | "output";

export type ModeId = "languages" | "samples";

/** Which side of the pairing a file belongs to: the program that starts the
 *  other one, the helper it starts, or the glue a toolchain needs. */
export type FileRole = "host" | "guest" | "support";

export interface Named {
    id: string;
    name: string;
}

export interface FileEntry {
    /** Repository-relative path: the file's identity, and what the panel headers show. */
    path: string;
    /** The file name, shown in the switcher and above the code. */
    label: string;
    role: FileRole;
    /** The Prism grammar class, e.g. `language-ada`. */
    prism: string;
    code: string;
}

export interface BridgeFamily {
    id: string;
    name: string;
    /** The two- or three-letter badge the sidebar rows use. */
    tag: string;
}

export interface Sample {
    id: string;
    name: string;
    host: Named;
    guest: Named;
    /** The guest's spelling in the README, e.g. "Common Lisp (SBCL)". */
    guestLabel: string;
    /** The README's own bridge sentence. */
    bridge: string;
    bridgeFamily: BridgeFamily;
    /** "Any", "Linux, Windows", ...; empty when the index records nothing. */
    platform: string;
    /** The folder the sample lives in, which is what GitHub is linked to. */
    folder: string;
    files: FileEntry[];
    readme: string;
    /** The fenced block under the README's "Expected output" heading. */
    output: string;
}

export interface Language {
    id: string;
    name: string;
    /** The folder the language's samples live in, which is what GitHub is linked to. */
    folder: string;
    prism: string;
    /** The file extension its own code uses, e.g. `.adb`. */
    extension: string;
    sampleCount: number;
    guests: Named[];
    sampleIds: string[];
}

export interface DataMeta {
    updated: string;
    languageCount: number;
    sampleCount: number;
    outputCount: number;
    guestCount: number;
    bridgeCount: number;
    repository: string;
    branch: string;
}

export interface InteropData {
    meta: DataMeta;
    languages: Language[];
    samples: Sample[];
    /** A language's display name -> its file-extension tag (".ada", ".py", ...). */
    extensions: Record<string, string>;
}

declare global {
    interface Window {
        /** Installed by public/interop-data.js, before the app module runs. */
        INTEROP_DATA?: InteropData;
    }
}
