<script setup lang="ts">
defineProps<{ title: string; description?: string }>()
</script>

<template>
  <div class="text-center py-14 px-6">
    <div class="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-neutral-100 to-neutral-200 flex items-center justify-center text-neutral-400 text-3xl shadow-inner">
      <slot name="icon">∅</slot>
    </div>
    <h3 class="mt-4 text-base font-semibold text-neutral-900">{{ title }}</h3>
    <p v-if="description" class="mt-1 text-sm text-neutral-500 max-w-sm mx-auto">{{ description }}</p>
    <div v-if="$slots.action" class="mt-5">
      <slot name="action" />
    </div>
  </div>
</template>
