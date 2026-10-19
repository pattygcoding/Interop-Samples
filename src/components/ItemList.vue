<script setup lang="ts">
import { firstSampleIdForLanguage, isPortable } from "../store/data";
import { activeSample, listMessage, selectLanguage, selectPairing, state, stateUrl, visibleCount, visibleLanguages, visibleSamples } from "../store/session";

// The list is real links, so every row can be copied, bookmarked or opened in a new
// tab; a plain left click stays in the page.  A language row links to the first pairing
// that host offers, because no address in the dashboard ever names a language on its
// own - the row is a way into the pairings, not a page of its own.
function onSelectLanguage(event: MouseEvent, id: string): void {
    if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
        return;
    }
    event.preventDefault();
    selectLanguage(id);
}

function onSelectPairing(event: MouseEvent, id: string): void {
    if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
        return;
    }
    event.preventDefault();
    selectPairing(id);
}

// The two row styles share a class string; the badges differ, because a language
// counts its pairings while a pairing names its bridge and its guest.
function rowClass(selected: boolean): string {
    return "w-full text-left px-3 py-2.5 rounded-md text-sm font-medium transition flex items-center justify-between gap-2 " +
        (selected
            ? "bg-accent/10 text-accent border border-accent/30"
            : "text-fg-soft hover:bg-line/5 border border-transparent");
}
</script>

<template>
    <nav class="overflow-y-auto flex-1 p-2 space-y-1">
        <p v-if="!visibleCount" class="micro text-fg-dim px-3 py-2">{{ listMessage }}</p>
        <template v-else>
            <!-- Languages: one row per host, showing how many pairings it holds and the
                 extension its own code uses.  The row links to that host's first
                 pairing, and stays highlighted while the switcher moves between them. -->
            <a v-for="item in visibleLanguages" :key="item.id"
               :href="stateUrl(firstSampleIdForLanguage(item.id) ?? item.id, state.tab)"
               :aria-current="item.id === activeSample?.host.id ? 'page' : undefined"
               :class="rowClass(item.id === activeSample?.host.id)" @click="onSelectLanguage($event, item.id)">
                <span class="truncate">{{ item.name }}</span>
                <span class="flex items-center gap-1 shrink-0">
                    <span class="micro px-1.5 py-0.5 rounded border border-line/10 text-fg-dim"
                          :title="item.sampleCount + ' interop sample(s)'">{{ item.sampleCount }} samples</span>
                    <span class="lang-tag" :title="item.name + ' source'">{{ item.extension }}</span>
                </span>
            </a>
            <!-- Pairings: the host language in the left half and the guest in the right,
                 so the two halves line up down the list and the pairing reads as
                 <host> + <guest> at a glance. -->
            <a v-for="item in visibleSamples" :key="item.id"
               :href="stateUrl(item.id, state.tab)"
               :aria-current="item.id === state.sampleId ? 'page' : undefined"
               :class="rowClass(item.id === state.sampleId)" @click="onSelectPairing($event, item.id)">
                <span class="w-1/2 shrink-0 truncate" :title="item.host.name">{{ item.host.name }}</span>
                <span class="w-1/2 min-w-0 flex items-center gap-2">
                    <span class="flex-1 min-w-0 truncate" :title="item.guestLabel || item.guest.name">{{ item.guest.name }}</span>
                    <!-- The tag is an abbreviation, so it drops the wide tracking the
                         .micro labels use - which is exactly the room the longest guest
                         name ("Common Lisp") needs to fit its half. -->
                    <span class="micro tracking-normal px-1 py-0.5 rounded border shrink-0"
                          :class="isPortable(item.platform)
                              ? 'border-line/15 text-fg-dim'
                              : 'border-accent/40 text-accent/90'"
                          :title="item.bridgeFamily.name + (item.platform ? ' \u00b7 ' + item.platform : '')">
                        {{ item.bridgeFamily.tag }}
                    </span>
                </span>
            </a>
        </template>
    </nav>
</template>
