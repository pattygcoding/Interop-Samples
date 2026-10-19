<script setup lang="ts">
import { activeSample, docsText, docsUrl, resolveDocLink } from "../store/session";
import MarkdownView from "./MarkdownView.vue";
</script>

<template>
    <section class="flex-1 flex flex-col min-h-0">
        <div class="flex items-center justify-between gap-3 mb-2">
            <span class="micro text-fg-dim truncate">{{ (activeSample?.folder ?? "") + "/README.md" }}</span>
            <a v-if="docsUrl" :href="docsUrl" target="_blank" rel="noopener"
               class="micro text-accent/70 hover:text-accent transition shrink-0">On GitHub</a>
        </div>
        <!-- The sample's own README, rendered: prerequisites, the exact build
             commands, the expected output and how the bridge works.  Its own relative
             links are resolved to the files they name on GitHub. -->
        <div class="flex-1 min-h-0 overflow-auto rounded-lg bg-ink-850 border border-line/5 px-4 py-4 sm:px-6 sm:py-5">
            <MarkdownView :text="docsText" :resolve-link="resolveDocLink" />
        </div>
    </section>
</template>
