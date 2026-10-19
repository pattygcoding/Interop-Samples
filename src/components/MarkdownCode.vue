<script setup lang="ts">
import { ref, watch } from "vue";
import { highlightCode } from "../prism";

// One fenced block from a sample README, highlighted like the Source tab - the code
// inside a README is often the only place the interesting detail is written down.
const props = defineProps<{
    code: string;
    prism: string;
}>();

const highlighted = ref("");
let highlightRun = 0;

watch(
    () => [props.code, props.prism],
    async () => {
        highlightRun += 1;
        const run = highlightRun;
        const html = await highlightCode(props.code, props.prism);
        if (run === highlightRun) {
            highlighted.value = html;
        }
    },
    { immediate: true },
);
</script>

<template>
    <pre class="io-docs-code overflow-auto rounded-md border border-line/10 text-[12.5px]"><code v-html="highlighted" :class="[prism, 'whitespace-pre']"></code></pre>
</template>
