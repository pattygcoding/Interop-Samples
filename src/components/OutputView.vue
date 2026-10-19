<script setup lang="ts">
import { activeSample, outputText } from "../store/session";
</script>

<template>
    <section class="flex-1 flex flex-col min-h-0">
        <div class="flex items-center justify-between gap-3 mb-2">
            <span class="micro text-fg-dim truncate">Expected output &mdash; {{ activeSample?.name ?? "" }}</span>
            <span class="micro text-accent/70 shrink-0">As the sample's README records it</span>
        </div>
        <!-- The fenced block from the README's "Expected output" section, shown
             verbatim: prompts, blank lines and all, with no highlighting, so what the
             README promises is what the panel prints. -->
        <pre class="bg-console text-accent font-mono p-5 rounded-lg flex-1 min-h-0 overflow-auto text-sm border border-line/5 leading-relaxed"><code class="language-none">{{ outputText }}</code></pre>
    </section>
</template>
