<script setup lang="ts">
import { computed } from "vue";
import { bridgeOptions, guestOptions, hostOptions, metaLine, repoHomeUrl, searchPlaceholder, setFacet, setMode, setQuery, state } from "../store/session";
import FacetDropdown from "./FacetDropdown.vue";
import ItemList from "./ItemList.vue";

// The two browse modes the pill switches between: the languages that host a sample,
// and the pairings of two programs themselves.
const MODES = ["languages", "samples"] as const;

// The sidebar is a slide-in drawer below `lg` (toggled by the header's menu button)
// and a plain static column above it.  The `-translate-x-full` class is the closed
// state; `lg:translate-x-0` keeps it on screen there.
const drawerClass = computed<string>(() =>
    state.sidebarOpen ? "translate-x-0" : "-translate-x-full",
);

// Host and Bridge only describe a sample, so their rows appear only in Samples mode.
const showSampleFacets = computed<boolean>(() => state.mode === "samples");
</script>

<template>
    <aside id="sidebar"
           :class="['fixed inset-y-0 left-0 z-50 w-80 max-w-[85vw] bg-ink-900 border-r border-line/5 flex flex-col shrink-0 transition-transform duration-200 ease-out lg:static lg:z-auto lg:translate-x-0 lg:bg-ink-900/70',
                    drawerClass]">
        <div class="p-5 border-b border-line/5">
            <div class="flex items-center gap-2.5">
                <a href="https://pattygcoding.com" target="_blank" rel="noopener" title="pattygcoding.com"
                   aria-label="Back to pattygcoding.com"
                   class="flex items-center justify-center w-8 h-8 rounded-md bg-ink-950 border border-line/10 text-fg-muted hover:text-accent hover:border-accent/40 transition">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" /></svg>
                </a>
                <!-- The GitHub mark sits beside the home mark: this repository is the
                     other destination a visitor wants from any screen.  Its target is
                     the generated `meta.repository`, the same source the per-folder
                     links use. -->
                <a :href="repoHomeUrl" :title="repoHomeUrl" target="_blank" rel="noopener"
                   aria-label="Open the repository on GitHub"
                   class="flex items-center justify-center w-8 h-8 rounded-md bg-ink-950 border border-line/10 text-fg-muted hover:text-accent hover:border-accent/40 transition">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" /><path d="M9 18c-4.51 2-5-2-7-2" /></svg>
                </a>
                <p class="micro text-fg-dim">IO / Interop Samples</p>
            </div>
            <h1 class="mt-3 text-2xl font-semibold tracking-tight text-fg-strong">Interop <span class="text-accent">Samples</span></h1>
            <p class="mt-1 text-xs text-fg-muted">Two languages, one program</p>
            <p class="micro mt-3 text-accent/80 whitespace-pre-line">{{ metaLine }}</p>
            <!-- Browse mode: the languages that host a sample, and the pairings of two
                 programs themselves.  The list swaps between the two without touching
                 the address, which only ever names one item. -->
            <div role="tablist" aria-label="Browse languages or samples"
                 class="flex gap-1 mt-4 p-1 rounded-full bg-ink-950 border border-line/10">
                <button v-for="mode in MODES" :key="mode" type="button" role="tab"
                        :aria-selected="state.mode === mode" @click="setMode(mode)"
                        :class="['flex-1 micro px-3 py-1.5 rounded-full transition',
                                 state.mode === mode ? 'bg-mint-400 text-on-accent' : 'text-fg-muted hover:text-fg']">
                    {{ mode === "languages" ? "Languages" : "Samples" }}
                </button>
            </div>
        </div>
        <div class="p-3 border-b border-line/5 space-y-2">
            <input type="search" :placeholder="searchPlaceholder" :value="state.query"
                   @input="setQuery(($event.target as HTMLInputElement).value)"
                   class="w-full bg-ink-950 border border-line/10 rounded-md px-3 py-2 text-sm text-fg
                          placeholder-hint focus:outline-none focus:border-accent/60 focus:ring-1 focus:ring-accent/20 transition" />
            <div v-if="showSampleFacets" class="flex items-center gap-2">
                <p class="micro text-fg-dim shrink-0 w-[4.75rem]">Host</p>
                <FacetDropdown id="host" :options="hostOptions" @pick="setFacet('host', $event)" />
            </div>
            <div v-if="showSampleFacets" class="flex items-center gap-2">
                <p class="micro text-fg-dim shrink-0 w-[4.75rem]">Bridge</p>
                <FacetDropdown id="bridge" :options="bridgeOptions" @pick="setFacet('bridge', $event)" />
            </div>
            <!-- Guest applies in both modes: in Samples it narrows the list to the
                 samples whose helper is written in that language, and in Languages it
                 narrows the list to the languages that host one. -->
            <div class="flex items-center gap-2">
                <p class="micro text-fg-dim shrink-0 w-[4.75rem]">Guest</p>
                <FacetDropdown id="guest" :options="guestOptions" @pick="setFacet('guest', $event)" />
            </div>
        </div>
        <ItemList />
    </aside>
</template>
