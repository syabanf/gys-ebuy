<script setup lang="ts">
interface Props {
  title?: string
  description?: string
  padded?: boolean
}

withDefaults(defineProps<Props>(), { padded: true })
</script>

<template>
  <section class="bg-white rounded-lg border border-neutral-200 shadow-card overflow-hidden">
    <header v-if="title || $slots.header" class="px-5 py-4 border-b border-neutral-200 flex items-center justify-between">
      <div>
        <h2 v-if="title" class="text-base font-semibold text-neutral-900">{{ title }}</h2>
        <p v-if="description" class="text-sm text-neutral-500 mt-0.5">{{ description }}</p>
      </div>
      <slot name="header" />
    </header>
    <div :class="padded ? 'p-5' : ''">
      <slot />
    </div>
    <footer v-if="$slots.footer" class="px-5 py-4 border-t border-neutral-200 bg-neutral-50">
      <slot name="footer" />
    </footer>
  </section>
</template>
