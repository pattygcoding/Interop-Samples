<script setup lang="ts">
import { activeSample, guestFiles, hostFiles } from "../store/session";
import ProgramColumn from "./ProgramColumn.vue";
</script>

<template>
    <section class="flex-1 flex flex-col min-h-0">
        <div class="flex items-center justify-between gap-3 mb-2">
            <span class="micro text-fg-dim truncate">{{ activeSample?.name ?? "Source code" }}</span>
            <span class="micro text-accent/70 truncate shrink-0">{{ activeSample?.bridge ?? "" }}</span>
        </div>
        <!-- The pairing, side by side: the host language's program(s) in the left half
             and the guest's in the right - 50/50 on a wide screen, stacked on a
             narrow one, because two columns of code need the room. -->
        <div v-if="activeSample" class="flex-1 min-h-0 grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-5">
            <ProgramColumn role="host" :language="activeSample.host" :files="hostFiles" />
            <ProgramColumn role="guest" :language="activeSample.guest" :files="guestFiles" />
        </div>
    </section>
</template>
