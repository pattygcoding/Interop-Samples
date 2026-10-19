// The Docs tab renders each sample's own README, and those READMEs are a small,
// regular subset of GitHub markdown: a title, a summary, a two-column table, then
// sections of prose, lists, quotes and fenced code.  This module turns exactly that
// subset into blocks the view can render, so a static showcase needs no markdown
// dependency; fenced blocks keep their info string as a Prism class, which is what
// makes the code inside a README highlight like the Source tab does.

import { PLAIN, escapeHtml } from "./prism";

export interface HeadingBlock { kind: "heading"; level: number; html: string }
export interface ParagraphBlock { kind: "paragraph"; html: string }
export interface ListBlock { kind: "list"; ordered: boolean; items: string[] }
export interface CodeBlock { kind: "code"; code: string; prism: string }
export interface TableBlock { kind: "table"; head: string[]; rows: string[][] }
export interface QuoteBlock { kind: "quote"; html: string }
export interface RuleBlock { kind: "rule" }

export type Block =
    | HeadingBlock
    | ParagraphBlock
    | ListBlock
    | CodeBlock
    | TableBlock
    | QuoteBlock
    | RuleBlock;

const FENCE = /^```(.*)$/;
const HEADING = /^(#{1,6})\s+(.*)$/;
const RULE = /^\s*(-{3,}|\*{3,}|_{3,})\s*$/;
const BULLET = /^[-*+]\s+(.*)$/;
const ORDERED = /^\d+[.)]\s+(.*)$/;
const QUOTE = /^>\s?(.*)$/;
const TABLE_ROW = /^\|(.*)\|$/;
const TABLE_SEPARATOR = /^\|[\s:|-]+\|$/;

export function parseMarkdown(text: string): Block[] {
    const lines = text.replace(/\r\n?/g, "\n").split("\n");
    const blocks: Block[] = [];
    let index = 0;

    while (index < lines.length) {
        const line = lines[index];
        if (!line.trim()) {
            index += 1;
            continue;
        }

        const fence = FENCE.exec(line.trim());
        if (fence) {
            const prism = fencePrism(fence[1].trim());
            const code: string[] = [];
            index += 1;
            while (index < lines.length && !FENCE.test(lines[index].trim())) {
                code.push(lines[index]);
                index += 1;
            }
            index += 1;   // past the closing fence, or the end of the file
            blocks.push({ kind: "code", code: code.join("\n"), prism });
            continue;
        }

        const heading = HEADING.exec(line);
        if (heading) {
            blocks.push({ kind: "heading", level: heading[1].length, html: inlineHtml(heading[2]) });
            index += 1;
            continue;
        }

        if (RULE.test(line)) {
            blocks.push({ kind: "rule" });
            index += 1;
            continue;
        }

        // A table is a row of cells followed by its separator line.
        if (TABLE_ROW.test(line.trim()) && index + 1 < lines.length && TABLE_SEPARATOR.test(lines[index + 1].trim())) {
            const head = splitRow(line);
            index += 2;
            const rows: string[][] = [];
            while (index < lines.length && TABLE_ROW.test(lines[index].trim())) {
                rows.push(splitRow(lines[index]));
                index += 1;
            }
            blocks.push({ kind: "table", head, rows });
            continue;
        }

        const quote = QUOTE.exec(line);
        if (quote) {
            const parts: string[] = [];
            while (index < lines.length) {
                const match = QUOTE.exec(lines[index]);
                if (!match) {
                    break;
                }
                parts.push(match[1]);
                index += 1;
            }
            blocks.push({ kind: "quote", html: inlineHtml(parts.join(" ")) });
            continue;
        }

        const bullet = BULLET.exec(line);
        const ordered = ORDERED.exec(line);
        if (bullet || ordered) {
            const isOrdered = !bullet;
            const pattern = isOrdered ? ORDERED : BULLET;
            const items: string[] = [];
            while (index < lines.length) {
                const match = pattern.exec(lines[index]);
                if (match) {
                    items.push(match[1].trim());
                    index += 1;
                    continue;
                }
                // An indented line under an item is the rest of that item's text.
                if (items.length && lines[index].trim() && /^\s+\S/.test(lines[index])) {
                    items[items.length - 1] += " " + lines[index].trim();
                    index += 1;
                    continue;
                }
                break;
            }
            blocks.push({ kind: "list", ordered: isOrdered, items: items.map(inlineHtml) });
            continue;
        }

        const paragraph: string[] = [];
        while (index < lines.length && lines[index].trim() && !startsBlock(lines[index])) {
            paragraph.push(lines[index].trim());
            index += 1;
        }
        if (paragraph.length) {
            blocks.push({ kind: "paragraph", html: inlineHtml(paragraph.join(" ")) });
        } else {
            index += 1;   // a line this parser does not know: never stall on it
        }
    }
    return blocks;
}

function startsBlock(line: string): boolean {
    const trimmed = line.trim();
    return (
        FENCE.test(trimmed) ||
        HEADING.test(line) ||
        RULE.test(line) ||
        QUOTE.test(line) ||
        BULLET.test(line) ||
        ORDERED.test(line) ||
        TABLE_ROW.test(trimmed)
    );
}

function splitRow(line: string): string[] {
    return line
        .trim()
        .replace(/^\||\|$/g, "")
        .split("|")
        .map((cell) => inlineHtml(cell.trim()));
}

// Inline markdown, on text that has already been escaped.  Code spans are handled
// first and kept literal, so the `*` and `_` inside them cannot be read as emphasis.
export function inlineHtml(text: string): string {
    return text
        .split("`")
        .map((part, index) => (index % 2 === 1 ? "<code>" + escapeHtml(part) + "</code>" : emphasise(escapeHtml(part))))
        .join("");
}

function emphasise(escaped: string): string {
    return escaped
        .replace(/\[([^\]]+)\]\(([^)<>]+)\)/g, (_match, label: string, href: string) => link(label, href))
        .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
        .replace(/(^|[\s(])\*([^*\s][^*]*)\*/g, "$1<em>$2</em>");
}

// Only the link shapes these READMEs use become anchors, and a target that could
// break out of the attribute is left as plain text.
function link(label: string, href: string): string {
    const target = href.trim();
    if (/["']/.test(target) || !/^(https?:\/\/|mailto:|\/|\.|#)/i.test(target)) {
        return label;
    }
    const external = /^https?:/i.test(target);
    return (
        '<a href="' + target + '"' + (external ? ' target="_blank" rel="noopener"' : "") +
        ' class="text-accent hover:underline">' + label + "</a>"
    );
}

// The info string a fenced block carries (`ada`, `bash`, `text`) -> the Prism class
// for it.  Anything absent here is plain text, exactly like the console captures.
const FENCE_PRISM: Record<string, string> = {
    ada: "language-ada",
    asm: "language-nasm",
    assembly: "language-nasm",
    bash: "language-bash",
    c: "language-c",
    clojure: "language-clojure",
    cobol: "language-cobol",
    cpp: "language-cpp",
    cs: "language-csharp",
    csharp: "language-csharp",
    d: "language-d",
    dart: "language-dart",
    elixir: "language-elixir",
    elm: "language-elm",
    erlang: "language-erlang",
    f90: "language-fortran",
    fortran: "language-fortran",
    fs: "language-fsharp",
    fsx: "language-fsharp",
    go: "language-go",
    groovy: "language-groovy",
    haskell: "language-haskell",
    hs: "language-haskell",
    hx: "language-haxe",
    java: "language-java",
    javascript: "language-javascript",
    jl: "language-julia",
    js: "language-javascript",
    json: "language-json",
    kotlin: "language-kotlin",
    kt: "language-kotlin",
    lisp: "language-lisp",
    lua: "language-lua",
    ml: "language-ocaml",
    nim: "language-nim",
    "objective-c": "language-objectivec",
    objc: "language-objectivec",
    pas: "language-pascal",
    pascal: "language-pascal",
    perl: "language-perl",
    php: "language-php",
    pl: "language-perl",
    powershell: "language-powershell",
    prolog: "language-prolog",
    ps1: "language-powershell",
    py: "language-python",
    python: "language-python",
    r: "language-r",
    rb: "language-ruby",
    ruby: "language-ruby",
    rs: "language-rust",
    rust: "language-rust",
    scala: "language-scala",
    scss: "language-scss",
    sh: "language-bash",
    shell: "language-bash",
    sql: "language-sql",
    swift: "language-swift",
    ts: "language-typescript",
    typescript: "language-typescript",
    v: "language-v",
    vb: "language-vbnet",
    vbnet: "language-vbnet",
};

export function fencePrism(info: string): string {
    return FENCE_PRISM[info.toLowerCase()] ?? PLAIN;
}
