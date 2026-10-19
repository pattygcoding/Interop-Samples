#!/usr/bin/env python3
"""Generate the static showcase dashboard for the interop samples.

This script reads the *real* repository contents and writes
``public/interop-data.js`` - the file the dashboard loads with a ``<script>``
tag, so ``npm run build`` copies it into the published site untouched:

  * every host language directory under ``langs/`` (``langs/Ada``, ``langs/C++``,
    ``langs/VB.NET`` ...) becomes a sidebar entry in the dashboard's "Languages"
    browse mode,
  * every ``langs/<Language>/<Host> with <Guest>/`` folder becomes an entry in the
    "Samples" browse mode: its host/guest/bridge come from the sample's own
    README, its files are the ones that README lists, and the fenced block
    under "## Expected output" becomes the "Expected Output" tab, and
  * the project URL (the git remote, else ``GITHUB_REPOSITORY``, else a
    default) and branch are recorded so the dashboard can link every folder to
    its page on GitHub.

The README's own "Sample index" table is read too, but only as a supplement:
it is the one place a sample's *platform* is written down, and it fills in any
value a sample README is missing.

Because the data is emitted as a plain JavaScript object it can be loaded with a
``<script>`` tag, so the dashboard works both on a static host and straight from
``file://`` (no fetch/CORS problems).

Usage::

    python tools/generate_dashboard.py
"""

from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
INDEX_FILE = ROOT / "README.md"
# Every host language lives in ``langs/<Language>/`` and every sample it hosts in a
# folder beside it, so the whole showcase is one directory: the repository root stays
# for the project's own files (this README, the tooling, the built site).
LANGS_DIR = ROOT / "langs"
# The site the addresses belong to.  Every link the dashboard serves is the same
# ``/<pairing-id>`` on this origin, which is what ``docs/links.md`` lists.
SITE = "https://interop.pattygcoding.com"
# The list of every address, written from the same data as the dashboard reads.  Unlike
# ``public/interop-data.js`` this one is tracked: it is documentation, and GitHub is
# where it is read.
LINKS_FILE = ROOT / "docs" / "links.md"
# The Vue app loads this with a classic <script> tag, so it has to sit beside the
# built ``index.html``.  Vite copies ``public/`` verbatim into ``dist/``, which is
# also what the dev server serves at the site root - hence ``public/`` and not the
# repository root.  It is generated, never hand-edited, and not tracked in git.
OUTPUT_FILE = ROOT / "public" / "interop-data.js"

# Fallbacks for the project link the dashboard shows above each sample.
DEFAULT_REPOSITORY = "https://github.com/pattygcoding/Interop-Samples"
DEFAULT_BRANCH = "main"

# Directories that never hold sample source: build output, caches, tool metadata.
# A sample builds with its own toolchain, so these appear all over the tree and
# have to be skipped both when a language directory is discovered and when a
# file named in a README is looked up.
SKIP_DIR_NAMES = {
    ".git",
    ".github",
    ".venv",
    "venv",
    "__pycache__",
    "node_modules",
    "bin",
    "obj",
    "target",
    "build",
    "dist",
    "dist-newstyle",
    "elm-stuff",
    "nimcache",
    ".dart_tool",
    ".metals",
    ".scala-build",
    ".bsp",
    ".bloop",
    "out",
    "classes",
    ".gradle",
    ".kotlin",
    ".vscode",
    ".idea",
    "public",
    "src",
    "tools",
}

# ---------------------------------------------------------------------------
# Display metadata per language: id -> (display name, Prism class, extension
# tag).  An id is the slug of the directory a language lives in (``C++`` ->
# ``cpp``, ``VB.NET`` -> ``vbnet``), so a language that only ever appears as a
# guest - Assembly, SQL, Common Lisp, Prolog, SCSS, C#, D, COBOL - has no
# directory of its own and is listed here anyway.  Add new languages here;
# anything missing falls back to the directory name and a generic grammar.
# ---------------------------------------------------------------------------
LANGUAGES = {
    "ada": ("Ada", "language-ada", ".adb"),
    "assembly": ("Assembly", "language-nasm", ".asm"),
    "bash": ("Bash", "language-bash", ".sh"),
    "c": ("C", "language-c", ".c"),
    "clojure": ("Clojure", "language-clojure", ".clj"),
    "cobol": ("COBOL", "language-cobol", ".cob"),
    "cpp": ("C++", "language-cpp", ".cpp"),
    "csharp": ("C#", "language-csharp", ".cs"),
    "d": ("D", "language-d", ".d"),
    "dart": ("Dart", "language-dart", ".dart"),
    "elixir": ("Elixir", "language-elixir", ".exs"),
    "elm": ("Elm", "language-elm", ".elm"),
    "erlang": ("Erlang", "language-erlang", ".escript"),
    "fortran": ("Fortran", "language-fortran", ".f90"),
    "fsharp": ("F#", "language-fsharp", ".fsx"),
    "go": ("Go", "language-go", ".go"),
    "groovy": ("Groovy", "language-groovy", ".groovy"),
    "haskell": ("Haskell", "language-haskell", ".hs"),
    "haxe": ("Haxe", "language-haxe", ".hx"),
    "java": ("Java", "language-java", ".java"),
    "javascript": ("JavaScript", "language-javascript", ".js"),
    "julia": ("Julia", "language-julia", ".jl"),
    "kotlin": ("Kotlin", "language-kotlin", ".kt"),
    "lisp": ("Common Lisp", "language-lisp", ".lisp"),
    "lua": ("Lua", "language-lua", ".lua"),
    "nim": ("Nim", "language-nim", ".nim"),
    "objectivec": ("Objective-C", "language-objectivec", ".m"),
    "ocaml": ("OCaml", "language-ocaml", ".ml"),
    "pascal": ("Free Pascal", "language-pascal", ".pas"),
    "perl": ("Perl", "language-perl", ".pl"),
    "php": ("PHP", "language-php", ".php"),
    "powershell": ("PowerShell", "language-powershell", ".ps1"),
    "prolog": ("Prolog", "language-prolog", ".pro"),
    "python": ("Python", "language-python", ".py"),
    "r": ("R", "language-r", ".R"),
    "ruby": ("Ruby", "language-ruby", ".rb"),
    "rust": ("Rust", "language-rust", ".rs"),
    "scala": ("Scala", "language-scala", ".scala"),
    "scss": ("SCSS", "language-scss", ".scss"),
    "shell": ("Shell", "language-bash", ".sh"),
    "sql": ("SQL", "language-sql", ".sql"),
    "swift": ("Swift", "language-swift", ".swift"),
    "typescript": ("TypeScript", "language-typescript", ".ts"),
    "v": ("V", "language-v", ".v"),
    "vbnet": ("VB.NET", "language-vbnet", ".vb"),
}

# How the languages name themselves in a sample README ("Free Pascal", "Python
# 3", "Common Lisp (SBCL)", "Shell (POSIX `sh`)") -> the id above.  Matching
# happens after a name is normalised (lower-cased, backticks and bracketed
# asides dropped, trailing version numbers stripped), and a name that is not
# here is slugified and looked up in LANGUAGES instead.
NAME_IDS = {
    "ada": "ada",
    "assembly": "assembly",
    "x86-32 assembly": "assembly",
    "x86-64 assembly": "assembly",
    "bash": "bash",
    "shell": "shell",
    "posix shell": "shell",
    "sh": "shell",
    "c": "c",
    "c++": "cpp",
    "clojure": "clojure",
    "cobol": "cobol",
    "gnucobol": "cobol",
    "c#": "csharp",
    "d": "d",
    "dart": "dart",
    "elixir": "elixir",
    "elm": "elm",
    "erlang": "erlang",
    "fortran": "fortran",
    "free pascal": "pascal",
    "pascal": "pascal",
    "f#": "fsharp",
    "go": "go",
    "groovy": "groovy",
    "haskell": "haskell",
    "haxe": "haxe",
    "neko": "haxe",
    "java": "java",
    "javascript": "javascript",
    "node.js": "javascript",
    "julia": "julia",
    "kotlin": "kotlin",
    "common lisp": "lisp",
    "sbcl": "lisp",
    "lisp": "lisp",
    "lua": "lua",
    "nim": "nim",
    "objective-c": "objectivec",
    "ocaml": "ocaml",
    "perl": "perl",
    "php": "php",
    "powershell": "powershell",
    "prolog": "prolog",
    "swi-prolog": "prolog",
    "python": "python",
    "r": "r",
    "ruby": "ruby",
    "rust": "rust",
    "scala": "scala",
    "scss": "scss",
    "dart sass": "scss",
    "sql": "sql",
    "sqlite": "sql",
    "swift": "swift",
    "typescript": "typescript",
    "v": "v",
    "vb.net": "vbnet",
    "vb": "vbnet",
}

# A file extension -> every language id it can be written in.  A sample holds
# one host program and one guest program, so the language a file belongs to is
# usually decided by its extension alone; the two entries with more than one
# candidate (``.pl`` is Perl *or* Prolog, ``.sh`` is Bash *or* POSIX shell)
# resolve against the sample's own host and guest names.
EXTENSIONS = {
    ".adb": ["ada"],
    ".ads": ["ada"],
    ".asm": ["assembly"],
    ".s": ["assembly"],
    ".bash": ["bash", "shell"],
    ".sh": ["bash", "shell"],
    ".c": ["c"],
    ".h": ["c"],
    ".cc": ["cpp"],
    ".cpp": ["cpp"],
    ".hpp": ["cpp"],
    ".clj": ["clojure"],
    ".cljs": ["clojure"],
    ".cob": ["cobol"],
    ".cpy": ["cobol"],
    ".cs": ["csharp"],
    ".d": ["d"],
    ".dart": ["dart"],
    ".ex": ["elixir"],
    ".exs": ["elixir"],
    ".elm": ["elm"],
    ".erl": ["erlang"],
    ".escript": ["erlang"],
    ".f": ["fortran"],
    ".f90": ["fortran"],
    ".f95": ["fortran"],
    ".fs": ["fsharp"],
    ".fsx": ["fsharp"],
    ".go": ["go"],
    ".groovy": ["groovy"],
    ".gvy": ["groovy"],
    ".hs": ["haskell"],
    ".hx": ["haxe"],
    ".java": ["java"],
    ".js": ["javascript"],
    ".mjs": ["javascript"],
    ".jl": ["julia"],
    ".kt": ["kotlin"],
    ".kts": ["kotlin"],
    ".lisp": ["lisp"],
    ".lsp": ["lisp"],
    ".lua": ["lua"],
    ".m": ["objectivec"],
    ".ml": ["ocaml"],
    ".mli": ["ocaml"],
    ".nim": ["nim"],
    ".pas": ["pascal"],
    ".pp": ["pascal"],
    ".pl": ["perl", "prolog"],
    ".pro": ["prolog"],
    ".prolog": ["prolog"],
    ".php": ["php"],
    ".ps1": ["powershell"],
    ".psm1": ["powershell"],
    ".py": ["python"],
    ".r": ["r"],
    ".rb": ["ruby"],
    ".rs": ["rust"],
    ".sc": ["scala"],
    ".scala": ["scala"],
    ".sass": ["scss"],
    ".scss": ["scss"],
    ".sql": ["sql"],
    ".swift": ["swift"],
    ".ts": ["typescript"],
    ".tsx": ["typescript"],
    ".v": ["v"],
    ".vsh": ["v"],
    ".vb": ["vbnet"],
}

# Build glue a sample's README lists beside its two programs (``elm.json``,
# ``tsconfig.json``, ``AverageCalculator.csproj`` ...).  The dashboard is about
# the interop code, so these are read but not shown.
CONFIG_EXTENSIONS = {
    ".json",
    ".edn",
    ".csproj",
    ".vbproj",
    ".sln",
    ".props",
    ".targets",
    ".toml",
    ".ini",
    ".cfg",
    ".yml",
    ".yaml",
    ".lock",
    ".txt",
}

# The bridge a sample uses, grouped into the families the sidebar can filter on.
# The first keyword found in a sample's own bridge sentence wins, in this order,
# because several sentences mention more than one idea ("In-process embedding
# via PySwip" is an embedding, "Ports + Node host, child process" is the port
# mechanism).
BRIDGE_FAMILIES = (
    ("native linking", "native-linking", "Native linking", "NL"),
    ("embedding", "embedding", "Embedding", "EMB"),
    ("in-process", "in-process", "In-process API", "IP"),
    ("bytecode", "jvm-bytecode", "Shared JVM bytecode", "BC"),
    ("ahead-of-time", "jvm-bytecode", "Shared JVM bytecode", "BC"),
    ("port", "ports", "Ports and pipes", "PORT"),
    ("child process", "child-process", "Child process", "CP"),
)

UNKNOWN_FAMILY = ("other", "Other", "OTH")

# Platforms that are worth a badge in the list: anything portable is the norm,
# so only a sample tied to one operating system is called out.
PORTABLE_PLATFORMS = {"any", "any (jvm)", "cross-platform"}

TABLE_ROW = re.compile(r"^\|\s*\*\*(Host language|Guest language|Bridge|Files)\*\*\s*\|\s*(.*?)\s*\|\s*$")
INDEX_ROW = re.compile(r"^\|\s*\[(.*?)\]\((.*?)\)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*$")
EXPECTED_HEADING = re.compile(r"^##\s+expected output\s*$", re.IGNORECASE)
SECTION_HEADING = re.compile(r"^#{2,}\s")
FENCE_START = re.compile(r"^```")

# id -> the directory name a language lives in ("cpp" -> "C++").  Filled in by
# ``discover`` before anything asks for a display name, so a guest language that
# has a directory of its own shows that directory's spelling.
FOLDER_NAMES: dict[str, str] = {}

# Collected while the payload is built and printed at the end, so a sample whose
# README stops matching the layout is visible in the build log.
WARNINGS: list[str] = []


def read_text(path: Path) -> str:
    """Read a text file and normalise its line endings to ``\\n``."""
    return path.read_text(encoding="utf-8").replace("\r\n", "\n").replace("\r", "\n")


def is_source_text(path: Path) -> bool:
    """True when ``path`` decodes as UTF-8 text.

    A sample directory can hold compile artefacts beside its source, and those
    sort before the source; only text is read, so binaries are skipped here.
    """
    try:
        path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return False
    return True


def slugify(text: str) -> str:
    """``C++`` -> ``cpp``, ``VB.NET`` -> ``vbnet``, ``C with Assembly (32bit)`` -> ``c-with-assembly-32bit``.

    The slug is both the item's id in the payload and the address the dashboard
    serves it on, so it is kept to letters, digits and single dashes: ``+`` and
    ``#`` are spelled out, a dot and a dash disappear (which is what makes
    ``Objective-C`` one word), and any other run of separators becomes one dash.
    """
    spelled = re.sub(r"\++", "pp", re.sub(r"#+", "sharp", text.lower()))
    out = []
    for character in spelled:
        if character.isalnum():
            out.append(character)
        elif character in ".-":
            continue
        else:
            out.append("-")
    return re.sub(r"-+", "-", "".join(out)).strip("-")


def normalise_name(text: str) -> str:
    """The comparable form of a README language name: lower-case, no backticks,
    no bracketed aside, no trailing version number."""
    cleaned = text.replace("`", "").replace("*", "").strip().lower()
    cleaned = re.sub(r"\([^)]*\)", " ", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return re.sub(r"v?\d+(\.\d+)*$", "", cleaned).strip()


def canonical_id(name: str) -> str:
    """The language id a README name refers to, or "" when it is not known."""
    normalised = normalise_name(name)
    if not normalised:
        return ""
    if normalised in NAME_IDS:
        return NAME_IDS[normalised]
    slug = slugify(normalised)
    if slug in LANGUAGES:
        return slug
    # "Haxe (Neko target)" and friends: an aside can be the only distinguishing
    # word, so one more pass keeps just the first word before giving up.
    first = normalised.split(" ")[0]
    return NAME_IDS.get(first, slug if first in LANGUAGES else "")


def display_name(language_id: str) -> str:
    """What to call a language on screen: its directory's spelling when it has
    one, else the name from LANGUAGES."""
    if language_id in FOLDER_NAMES:
        return FOLDER_NAMES[language_id]
    return LANGUAGES.get(language_id, (language_id, "", ""))[0]


def prism_for_id(language_id: str) -> str:
    return LANGUAGES.get(language_id, ("", "language-none", ""))[1]


def clean_bridge(text: str) -> str:
    """A README's bridge sentence without markdown emphasis."""
    return re.sub(r"\s+", " ", text.replace("`", "").replace("*", "")).strip()


def bridge_family(bridge: str) -> dict:
    """Group a bridge sentence into the family the sidebar filters on."""
    lowered = bridge.lower()
    for keyword, family_id, name, tag in BRIDGE_FAMILIES:
        if keyword in lowered:
            return {"id": family_id, "name": name, "tag": tag}
    family_id, name, tag = UNKNOWN_FAMILY
    return {"id": family_id, "name": name, "tag": tag}


def git_output(*args: str) -> str:
    """Run a read-only git command in the repository; "" when git is unavailable."""
    try:
        result = subprocess.run(
            ["git", "-C", str(ROOT), *args],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def repository_url() -> str:
    """The GitHub project the dashboard links to.

    The clone's remote is the truth, then ``GITHUB_REPOSITORY`` (set inside
    Actions), then the committed default.  ``git@``/``ssh://`` remotes are
    normalised to https and a trailing ``.git`` is dropped, so
    ``git@github.com:owner/repo.git`` becomes ``https://github.com/owner/repo``.
    """
    remote = git_output("config", "--get", "remote.origin.url") or os.environ.get(
        "GITHUB_REPOSITORY", ""
    )
    if not remote:
        return DEFAULT_REPOSITORY
    if remote.startswith("git@"):
        host, _, path = remote[len("git@"):].partition(":")
        remote = "https://%s/%s" % (host, path)
    elif remote.startswith("ssh://"):
        remote = "https://" + remote[len("ssh://"):].replace("git@", "", 1)
    if not remote.startswith("http"):
        remote = "https://github.com/" + remote
    if remote.endswith(".git"):
        remote = remote[: -len(".git")]
    return remote.rstrip("/") or DEFAULT_REPOSITORY


def repository_branch() -> str:
    """The branch the dashboard links into: HEAD's name, else Actions', else main.

    A detached HEAD (a CI checkout) reports ``HEAD``, which is not a usable ref,
    so ``GITHUB_REF_NAME`` takes over there.
    """
    branch = git_output("rev-parse", "--abbrev-ref", "HEAD")
    if not branch or branch == "HEAD":
        branch = os.environ.get("GITHUB_REF_NAME", "") or DEFAULT_BRANCH
    return branch


def read_index_rows() -> dict[str, dict]:
    """The README's "Sample index" table, keyed by the sample's folder.

    The table repeats host/guest/bridge for every sample - this script prefers
    the sample's own README, because it is the file that travels with the code -
    and adds the one thing a sample README does not carry: its platform.
    """
    rows: dict[str, dict] = {}
    if not INDEX_FILE.is_file():
        return rows

    for line in read_text(INDEX_FILE).split("\n"):
        match = INDEX_ROW.match(line)
        if not match:
            continue
        link, target, host, guest, bridge, platform = (group.strip() for group in match.groups())
        folder = unquote(target).rsplit("/README.md", 1)[0]
        rows[folder] = {
            "link": link,
            "host": host,
            "guest": guest,
            "bridge": clean_bridge(bridge),
            "platform": platform,
        }
    return rows


def parse_sample_readme(text: str) -> dict:
    """The facts a sample README states about itself.

    Every sample opens with an H1 title, a one-line summary and a two-column
    table (Host language / Guest language / Bridge / Files), so the table is the
    authority on what the sample is made of.
    """
    info = {"title": "", "host": "", "guest": "", "bridge": "", "files": []}
    for line in text.split("\n"):
        if not info["title"] and line.startswith("# "):
            info["title"] = line[2:].strip()
        match = TABLE_ROW.match(line)
        if match:
            key = match.group(1).split(" ")[0].lower()
            value = match.group(2).strip()
            if key == "files":
                info["files"] = [name.strip() for name in re.findall(r"`([^`]+)`", value)]
            else:
                info[key] = value
    return info


def expected_output(text: str) -> str:
    """The fenced block under the README's "Expected output" heading, verbatim.

    The block is shown as-is in the dashboard's "Expected Output" tab - prompts,
    blank lines and all - so what the README promises is what the panel prints.
    """
    lines = text.split("\n")
    start = None
    for index, line in enumerate(lines):
        if EXPECTED_HEADING.match(line):
            start = index + 1
            break
    if start is None:
        return ""
    block: list[str] = []
    inside = False
    for line in lines[start:]:
        if FENCE_START.match(line):
            if inside:
                break
            inside = True
            continue
        if not inside:
            if SECTION_HEADING.match(line):
                break   # the section ended before a block was found
            continue
        block.append(line)
    return "\n".join(block).strip("\n")


def walk_sample_files(directory: Path) -> list[Path]:
    """Every text file inside a sample directory, skipping build output."""
    found: list[Path] = []
    for path in sorted(directory.rglob("*")):
        if not path.is_file():
            continue
        if any(part in SKIP_DIR_NAMES or part.startswith(".") for part in path.relative_to(directory).parts[:-1]):
            continue
        if path.name == "README.md":
            continue
        found.append(path)
    return found


def listed_files(sample_dir: Path, names: list[str]) -> list[Path]:
    """The files a README's Files row names, in that order.

    A name may be a path (``src/Main.elm``) or a bare file name
    (``AverageCalculator.java``), and the row is what decides host from guest, so
    order is preserved and a name that cannot be found is reported.
    """
    available = {path.name.lower(): path for path in walk_sample_files(sample_dir)}
    found: list[Path] = []
    for name in names:
        if "/" in name:
            candidate = sample_dir / name
            if candidate.is_file():
                found.append(candidate)
            else:
                WARNINGS.append("%s: file %s not found" % (sample_dir.name, name))
            continue
        path = available.get(name.lower())
        if path is None:
            WARNINGS.append("%s: file %s not found" % (sample_dir.name, name))
            continue
        found.append(path)
    return found


def role_for(path: Path, host_id: str, guest_id: str) -> str:
    """Whether a file is the host program, the guest program or glue.

    The extension decides it: ``main.adb`` can only be Ada.  The two extensions
    written by more than one language are resolved against the sample's own host
    and guest names, which is what separates Perl's ``main.pl`` from Prolog's
    ``average_calculator.pl``.
    """
    candidates = EXTENSIONS.get(path.suffix.lower(), [])
    if host_id and host_id in candidates:
        return "host"
    if guest_id and guest_id in candidates:
        return "guest"
    return "support"


def prism_for_file(path: Path, role: str, host_id: str, guest_id: str) -> str:
    """The Prism grammar class for a file, from the language it belongs to."""
    language_id = host_id if role == "host" else guest_id if role == "guest" else ""
    if not language_id:
        candidates = EXTENSIONS.get(path.suffix.lower(), [])
        language_id = candidates[0] if candidates else ""
    return prism_for_id(language_id)


def build_sample(language_dir: Path, sample_dir: Path, index_rows: dict[str, dict]) -> dict:
    """One ``<Host> with <Guest>`` folder, ready for the dashboard."""
    folder = sample_dir.relative_to(ROOT).as_posix()
    readme = read_text(sample_dir / "README.md")
    info = parse_sample_readme(readme)
    row = index_rows.get(folder, {})

    host_id = slugify(language_dir.name)
    guest_name = info["guest"] or row.get("guest", "")
    guest_id = canonical_id(guest_name)
    if not guest_id:
        WARNINGS.append("%s: guest language %r not recognised" % (folder, guest_name))

    candidates = listed_files(sample_dir, info["files"])
    if not candidates:
        candidates = walk_sample_files(sample_dir)

    files = []
    for path in candidates:
        if path.suffix.lower() in CONFIG_EXTENSIONS or not is_source_text(path):
            continue
        role = role_for(path, host_id, guest_id)
        files.append(
            {
                "path": path.relative_to(ROOT).as_posix(),
                "label": path.name,
                "role": role,
                "prism": prism_for_file(path, role, host_id, guest_id),
                "code": read_text(path),
            }
        )
    if not any(entry["role"] == "host" for entry in files):
        WARNINGS.append("%s: no host file identified" % folder)

    bridge = clean_bridge(info["bridge"] or row.get("bridge", ""))
    return {
        # The address is assigned in `assign_ids` once every sample is known, because
        # it is built from the two languages and has to stay unique across the repo.
        "id": "",
        "name": info["title"] or sample_dir.name,
        "host": {"id": host_id, "name": display_name(host_id)},
        "guest": {"id": guest_id, "name": display_name(guest_id) if guest_id else guest_name},
        "guestLabel": guest_name,
        "bridge": bridge,
        "bridgeFamily": bridge_family(bridge),
        "platform": row.get("platform", ""),
        "folder": folder,
        "files": files,
        "readme": readme,
        "output": expected_output(readme),
    }


def sample_sort_key(sample: dict) -> tuple:
    """Host first, then guest, both alphabetically - the order the lists read in.

    A sample is named `<Host> with <Guest>`, so ordering by guest inside a host is the
    same as ordering the samples themselves, and it is what makes the first entry of a
    language the sample whose guest sorts first (the one the dashboard opens on).
    """
    return (
        sample["host"]["name"].casefold(),
        sample["guest"]["name"].casefold(),
        sample["name"].casefold(),
        sample["folder"].casefold(),
    )


def variant_slug(sample: dict) -> str:
    """The qualifier that tells two samples with the same pair apart.

    ``C with Assembly (32bit)`` and ``C with Assembly (64bit)`` are the same host and
    the same guest, so the bracket the folder name carries becomes part of the
    address: ``/c-assembly-32bit`` and ``/c-assembly-64bit``.
    """
    folder_name = Path(sample["folder"]).name
    qualifiers = re.findall(r"\(([^)]+)\)", folder_name)
    return slugify(" ".join(qualifiers))


def assign_ids(samples: list[dict]) -> None:
    """Give every sample the ``<host>-<guest>`` address the dashboard serves it on.

    The address names the two languages rather than the folder, because that is what
    the page is about: ``/c-elixir`` is C driving Elixir.  A pair that appears twice
    keeps a qualifier from its folder name (the assembly samples differ only by word
    size), and anything still shared falls back to a counter, so no address is ever
    served by two samples.
    """
    base_ids = [
        "%s-%s" % (sample["host"]["id"], sample["guest"]["id"] or "guest") for sample in samples
    ]
    shared = Counter(base_ids)
    for sample, base in zip(samples, base_ids):
        qualifier = variant_slug(sample) if shared[base] > 1 else ""
        sample["id"] = base + ("-" + qualifier if qualifier else "")

    seen: Counter = Counter()
    for sample in samples:
        seen[sample["id"]] += 1
        if seen[sample["id"]] > 1:
            WARNINGS.append(
                "sample address %s is shared: falling back to %s-%d"
                % (sample["id"], sample["id"], seen[sample["id"]])
            )
            sample["id"] = "%s-%d" % (sample["id"], seen[sample["id"]])


def build_language(language_dir: Path, samples: list[dict]) -> dict:
    """One host language directory, described by the samples it holds."""
    language_id = slugify(language_dir.name)
    guests: list[dict] = []
    for sample in samples:
        guest = sample["guest"]
        if guest["id"] and all(guest["id"] != seen["id"] for seen in guests):
            guests.append(guest)
    suffixes = Counter(
        Path(entry["path"]).suffix
        for sample in samples
        for entry in sample["files"]
        if entry["role"] == "host"
    )
    fallback = LANGUAGES.get(language_id, ("", "", ""))[2]
    return {
        "id": language_id,
        "name": language_dir.name,
        # The folder the language lives in (``langs/PHP``), which is what its GitHub
        # link points at - recorded rather than rebuilt, so moving the tree does not
        # mean touching the dashboard.
        "folder": language_dir.relative_to(ROOT).as_posix(),
        "prism": prism_for_id(language_id),
        "extension": suffixes.most_common(1)[0][0] if suffixes else fallback,
        "sampleCount": len(samples),
        "guests": guests,
        "sampleIds": [sample["id"] for sample in samples],
    }


def extension_tags(languages: list[dict], samples: list[dict]) -> dict[str, str]:
    """Display name -> the file-extension tag the dashboard shows beside it.

    A host language's tag is the extension of the code it contributes; a guest's
    is the extension of the helper it contributes, which is how ``Prolog`` ends
    up tagged ``.pl`` (or ``.pro``) rather than being confused with Perl.
    """
    tags: dict[str, str] = {}
    guest_suffixes: dict[str, Counter] = {}
    for sample in samples:
        for entry in sample["files"]:
            if entry["role"] == "guest" and sample["guest"]["id"]:
                counted = guest_suffixes.setdefault(sample["guest"]["id"], Counter())
                counted[Path(entry["path"]).suffix] += 1
    for language in languages:
        tags.setdefault(language["name"], language["extension"])
    for guest_id, counted in guest_suffixes.items():
        if counted:
            tags.setdefault(display_name(guest_id), counted.most_common(1)[0][0])
    return tags


def discover() -> tuple[list[dict], list[dict]]:
    """Find every host language and every ``<Host> with <Guest>`` sample."""
    languages: list[dict] = []
    samples: list[dict] = []
    if not LANGS_DIR.is_dir():
        return languages, samples

    directories = [
        directory
        for directory in sorted(LANGS_DIR.iterdir())
        if directory.is_dir()
        and not directory.name.startswith(".")
        and directory.name not in SKIP_DIR_NAMES
    ]
    # The directory spelling is the display name, so a guest language that has a
    # directory of its own ("Pascal", "Shell", "VB.NET") reads the same way
    # whether it is opened as a host or named in another sample's README.
    for directory in directories:
        FOLDER_NAMES.setdefault(slugify(directory.name), directory.name)

    index_rows = read_index_rows()
    grouped: list[tuple[Path, list[dict]]] = []
    for directory in directories:
        sample_dirs = [
            child
            for child in sorted(directory.iterdir())
            if child.is_dir()
            and not child.name.startswith(".")
            and child.name not in SKIP_DIR_NAMES
            and (child / "README.md").is_file()
        ]
        if not sample_dirs:
            continue   # not a language: no sample folders beside it
        grouped.append(
            (directory, [build_sample(directory, sample_dir, index_rows) for sample_dir in sample_dirs])
        )

    # Every address is assigned from the sorted list, so two samples that pair the
    # same two languages are told apart the same way on every machine.
    samples = [sample for _directory, entries in grouped for sample in entries]
    samples.sort(key=sample_sort_key)
    assign_ids(samples)

    languages: list[dict] = []
    for directory, entries in grouped:
        entries.sort(key=sample_sort_key)
        languages.append(build_language(directory, entries))
    return languages, samples


def links_markdown(languages: list[dict], samples: list[dict]) -> str:
    """The documentation list of every address the dashboard serves.

    One line per pairing, grouped by host language, plus the host's own address - which
    resolves to the first pairing beneath it.  A tab can be named on any of them
    (``/docs``, ``/output``) or as a query (``?tab=docs``), which is why only the
    pairing itself is listed: everything else is a suffix of these.
    """
    lines = [
        "# Showcase links",
        "",
        "Every address on <%s/> names one **pairing** - a host language and the guest it" % SITE,
        "drives - and each is a real link that can be bookmarked or shared. This file is",
        "generated by `tools/generate_dashboard.py` in the same run that writes",
        "`public/interop-data.js`, so it always matches the repository: **%d host languages**"
        % len(languages),
        "and **%d pairings**." % len(samples),
        "",
        "- A pairing's address is `<host>-<guest>`, e.g. <%s/c-elixir>." % SITE,
        "- A host language's address resolves to the first pairing it offers - the guest",
        "  that sorts first - so <%s/cpp> opens <%s/cpp-assembly-32bit>." % (SITE, SITE),
        "- Any pairing can show its README or its expected output by adding a tab:",
        "  <%s/c-elixir/docs>, <%s/c-elixir/output>, or `?tab=docs`." % (SITE, SITE),
        "- The same pairings answer on a subdomain (`c-elixir.interop.pattygcoding.com`,",
        "  `cpp.interop.pattygcoding.com`), which needs a wildcard `CNAME`.",
        "",
    ]

    # A jump index, because the list is one section per host language.
    index = ["[%s](#lang-%s)" % (language["name"], language["id"]) for language in languages]
    for start in range(0, len(index), 8):
        lines.append(" \u00b7 ".join(index[start : start + 8]))
    lines.append("")

    by_language: dict[str, list[dict]] = {}
    for sample in samples:
        by_language.setdefault(sample["host"]["id"], []).append(sample)

    for language in languages:
        owned = by_language.get(language["id"], [])
        lines.append('<a id="lang-%s"></a>' % language["id"])
        lines.append("")
        lines.append("## %s" % language["name"])
        lines.append("")
        if owned:
            lines.append(
                "- <%s/%s> - the host entry, opens the first pairing below"
                % (SITE, language["id"])
            )
        else:
            lines.append("- <%s/%s>" % (SITE, language["id"]))
        for sample in owned:
            # The bracket is only worth writing when the pairing's name does not already
            # say the guest: "Ada with Lisp" is paired with Common Lisp (SBCL), for
            # instance, and "Pascal" is Free Pascal.
            guest = sample["guest"]["name"]
            note = "" if guest.casefold() in sample["name"].casefold() else " (%s)" % guest
            lines.append("- <%s/%s> - %s%s" % (SITE, sample["id"], sample["name"], note))
        lines.append("")

    lines.append("The same list travels with the dashboard: the counts and the data behind")
    lines.append("every one of these pages are in `public/interop-data.js`.")
    return "\n".join(lines).rstrip() + "\n"


def write_links(languages: list[dict], samples: list[dict]) -> None:
    """Write ``docs/links.md``, creating the directory if the checkout lacks it."""
    LINKS_FILE.parent.mkdir(parents=True, exist_ok=True)
    LINKS_FILE.write_text(links_markdown(languages, samples), encoding="utf-8")


def build_payload() -> dict:
    languages, samples = discover()
    return {
        "meta": {
            "updated": datetime.datetime.now(datetime.timezone.utc).strftime(
                "%Y-%m-%d %H:%M UTC"
            ),
            "languageCount": len(languages),
            "sampleCount": len(samples),
            "outputCount": sum(1 for sample in samples if sample["output"]),
            "guestCount": len({sample["guest"]["id"] for sample in samples if sample["guest"]["id"]}),
            "bridgeCount": len({sample["bridgeFamily"]["id"] for sample in samples}),
            # The dashboard shows "<repository>/tree/<branch>/<folder>" above each
            # sample, so the project it lives in travels with the data.
            "repository": repository_url(),
            "branch": repository_branch(),
        },
        "languages": languages,
        "samples": samples,
        "extensions": extension_tags(languages, samples),
    }


def main() -> int:
    payload = build_payload()
    body = json.dumps(payload, indent=2, ensure_ascii=False)
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text("window.INTEROP_DATA = " + body + ";\n", encoding="utf-8")
    # The same data, as the documentation list of addresses.
    write_links(payload["languages"], payload["samples"])
    meta = payload["meta"]
    print(
        "Wrote %s and %s (%d language(s), %d sample(s), %d guest language(s), %d bridge(s))"
        % (
            OUTPUT_FILE.name,
            LINKS_FILE.relative_to(ROOT).as_posix(),
            meta["languageCount"],
            meta["sampleCount"],
            meta["guestCount"],
            meta["bridgeCount"],
        )
    )
    for warning in WARNINGS:
        print("warning: %s" % warning, file=sys.stderr)
    if meta["languageCount"] == 0 or meta["sampleCount"] == 0:
        print(
            "error: no samples found - run this from a checkout of the repository",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
