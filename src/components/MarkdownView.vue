<script setup lang="ts">
import { computed } from "vue";
import { parseMarkdown } from "../markdown";
import type { Block, LinkResolver } from "../markdown";
import MarkdownCode from "./MarkdownCode.vue";

// A sample's README, rendered from the blocks src/markdown.ts parses: headings,
// prose, lists, quotes, tables and highlighted code.  `resolveLink` is how a relative
// link in the README ("the Ruby sample is over there") reaches GitHub instead of the
// address bar it would otherwise resolve against.
const props = defineProps<{
    text: string;
    resolveLink?: LinkResolver;
}>();

const blocks = computed<Block[]>(() => parseMarkdown(props.text, props.resolveLink));

function headingClass(level: number): string {
    if (level === 1) {
        return "text-base font-semibold tracking-tight text-fg-strong";
    }
    if (level === 2) {
        return "mt-6 pt-3 border-t border-line/5 text-sm font-semibold text-accent";
    }
    return "mt-4 text-sm font-semibold text-fg-strong";
}
</script>

<template>
    <div class="io-docs space-y-3 text-sm leading-relaxed text-fg-soft">
        <template v-for="(block, index) in blocks" :key="index">
            <h2 v-if="block.kind === 'heading'" :class="headingClass(block.level)" v-html="block.html"></h2>
            <p v-else-if="block.kind === 'paragraph'" v-html="block.html"></p>
            <blockquote v-else-if="block.kind === 'quote'"
                        class="border-l-2 border-accent/40 pl-3 text-fg-muted" v-html="block.html"></blockquote>
            <ul v-else-if="block.kind === 'list'" :class="block.ordered ? 'list-decimal' : 'list-disc'"
                class="pl-5 space-y-1 marker:text-fg-dim">
                <li v-for="(item, position) in block.items" :key="position" v-html="item"></li>
            </ul>
            <MarkdownCode v-else-if="block.kind === 'code'" :code="block.code" :prism="block.prism" />
            <div v-else-if="block.kind === 'table'" class="overflow-auto rounded-md border border-line/10">
                <table class="w-full text-xs">
                    <thead>
                        <tr class="bg-ink-900/60">
                            <th v-for="(cell, position) in block.head" :key="position"
                                class="text-left px-3 py-2 border-b border-line/10 micro text-fg-dim" v-html="cell"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(row, rowIndex) in block.rows" :key="rowIndex">
                            <td v-for="(cell, position) in row" :key="position"
                                class="px-3 py-2 border-b border-line/5 align-top text-fg-soft" v-html="cell"></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <hr v-else-if="block.kind === 'rule'" class="border-line/10" />
        </template>
    </div>
</template>
