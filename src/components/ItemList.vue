<script setup lang="ts">
import { isPortable } from "../store/data";
import { listMessage, selectItem, state, stateUrl, visibleCount, visibleLanguages, visibleSamples } from "../store/session";

// The list is real links, so every language and every sample can be copied,
// bookmarked or opened in a new tab; a plain left click stays in the page.
function onSelect(event: MouseEvent, id: string): void {
    if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
        return;
    }
    event.preventDefault();
    selectItem(id);
}

// The two row styles share a class string; the badges differ, because a language
// counts samples while a sample names its bridge, its platform and its guest.
function rowClass(id: string): string {
    return "w-full text-left px-3 py-2.5 rounded-md text-sm font-medium transition flex items-center justify-between gap-2 " +
        (id === state.itemId
            ? "bg-accent/10 text-accent border border-accent/30"
            : "text-fg-soft hover:bg-line/5 border border-transparent");
}
</script>

<template>
    <nav class="overflow-y-auto flex-1 p-2 space-y-1">
        <p v-if="!visibleCount" class="micro text-fg-dim px-3 py-2">{{ listMessage }}</p>
        <template v-else>
            <!-- Languages: how many samples it hosts, and the extension its own code uses. -->
            <a v-for="item in visibleLanguages" :key="item.id"
               :href="stateUrl(item.id, state.tab, null)"
               :aria-current="item.id === state.itemId ? 'page' : undefined"
               :class="rowClass(item.id)" @click="onSelect($event, item.id)">
                <span class="truncate">{{ item.name }}</span>
                <span class="flex items-center gap-1 shrink-0">
                    <span class="micro px-1.5 py-0.5 rounded border border-line/10 text-fg-dim"
                          :title="item.sampleCount + ' interop sample(s)'">{{ item.sampleCount }} samples</span>
                    <span class="lang-tag" :title="item.name + ' source'">{{ item.extension }}</span>
                </span>
            </a>
            <!-- Samples: the host language in the left half and the guest in the right,
                 so the two halves line up down the list and the pairing reads as
                 <host> + <guest> at a glance.  The guest's name is what the extension
                 tag used to imply, so the only badge left is the bridge: mint when the
                 sample is tied to one platform, dim when it runs anywhere, with the
                 platform named in its tooltip (and in full in the header). -->
            <a v-for="item in visibleSamples" :key="item.id"
               :href="stateUrl(item.id, state.tab, null)"
               :aria-current="item.id === state.itemId ? 'page' : undefined"
               :class="rowClass(item.id)" @click="onSelect($event, item.id)">
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
