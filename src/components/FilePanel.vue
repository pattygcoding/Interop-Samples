<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { PLAIN, highlightCode } from "../prism";
import { lineNumbersFor } from "../store/data";
import type { FileEntry } from "../types";

// One program in a column: its path, a copy button, the line-number gutter and the
// highlighted source.  A column can hold more than one file (Elm's program is
// src/Main.elm *and* the Node host that starts it), so this is the file, and
// ProgramColumn stacks them.
const props = defineProps<{
    file: FileEntry;
}>();

const highlighted = ref("");
const copied = ref(false);
let copyTimer: number | undefined;

// Prism loads a grammar on demand, so highlighting is async: a fast selection change
// must not let an older highlight land on the newer file.
let highlightRun = 0;

watch(
    () => props.file,
    async (file) => {
        highlightRun += 1;
        const run = highlightRun;
        const html = await highlightCode(file.code, file.prism || PLAIN);
        if (run === highlightRun) {
            highlighted.value = html;
        }
    },
    { immediate: true },
);

// The gutter must line up with Prism's output, so it is derived from the same code
// the panel is showing.
const lineNumbers = computed<string>(() => lineNumbersFor(props.file.code));

async function copyCode(): Promise<void> {
    if (!navigator.clipboard?.writeText) {
        return;
    }
    try {
        await navigator.clipboard.writeText(props.file.code);
    } catch {
        return;   // refused (insecure context or permissions): leave the icon alone
    }
    copied.value = true;
    window.clearTimeout(copyTimer);
    copyTimer = window.setTimeout(() => { copied.value = false; }, 1200);
}
</script>

<template>
    <div class="relative rounded-lg bg-ink-850 border border-line/5">
        <div class="flex items-center justify-between gap-2 px-4 pt-2.5 pb-1">
            <span class="micro text-fg-dim truncate" :title="file.path">{{ file.path }}</span>
            <button type="button" @click="copyCode()" title="Copy this file" aria-label="Copy this file"
                    :class="['shrink-0 flex items-center justify-center w-7 h-7 rounded-md bg-ink-900/80 border border-line/10 transition',
                             copied ? 'text-accent' : 'text-fg-muted hover:text-accent hover:border-accent/40']">
                <svg v-if="copied" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5" /></svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="14" height="14" x="8" y="8" rx="2" ry="2" /><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2" /></svg>
            </button>
        </div>
        <div class="overflow-auto font-mono text-[12.5px] leading-relaxed">
            <div class="flex min-w-full">
                <pre class="m-0 pb-4 pt-1 pl-3 pr-2.5 text-right text-[12.5px] leading-relaxed text-gutter select-none whitespace-pre shrink-0 sticky left-0 bg-ink-850 border-r border-line/5">{{ lineNumbers }}</pre>
                <pre class="io-code m-0 flex-1 text-[12.5px] leading-relaxed outline-none"><code v-html="highlighted" :class="[file.prism || 'language-none', 'whitespace-pre']"></code></pre>
            </div>
        </div>
    </div>
</template>
