<script setup lang="ts">
import { languageTag } from "../store/data";
import type { FileEntry, Named } from "../types";
import FilePanel from "./FilePanel.vue";

// One half of a pairing: the language, its extension tag, and the program(s) it
// contributes.  SourceView puts the host in the left half and the guest in the right.
defineProps<{
    role: "host" | "guest";
    language: Named;
    files: FileEntry[];
}>();
</script>

<template>
    <section class="flex flex-col min-h-0 min-w-0">
        <div class="flex items-center justify-between gap-2 mb-2">
            <div class="flex items-center gap-2 min-w-0">
                <span class="micro shrink-0" :class="role === 'host' ? 'text-accent/80' : 'text-guest-300/80'">
                    {{ role === "host" ? "Host" : "Guest" }}
                </span>
                <span class="text-sm font-semibold tracking-tight truncate text-fg-strong">{{ language.name }}</span>
                <span class="lang-tag shrink-0" :title="language.name">{{ languageTag(language.name) }}</span>
            </div>
            <span class="micro text-fg-dim shrink-0">{{ files.length }} file{{ files.length === 1 ? "" : "s" }}</span>
        </div>
        <div class="flex-1 min-h-0 overflow-auto space-y-2 pr-0.5">
            <FilePanel v-for="file in files" :key="file.path" :file="file" />
            <p v-if="files.length === 0" class="text-xs text-fg-dim italic">No code recorded for this side.</p>
        </div>
    </section>
</template>
