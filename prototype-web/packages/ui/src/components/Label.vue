<script setup lang="ts">
defineProps<{ for?: string; required?: boolean }>()
</script>

<template>
  <label :for="$props.for" class="block text-sm font-medium text-neutral-700 mb-1.5">
    <slot />
    <span v-if="required" class="text-danger ml-0.5">*</span>
  </label>
</template>
