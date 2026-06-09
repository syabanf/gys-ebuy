<script setup lang="ts">
interface Props {
  modelValue?: string | number
  type?: string
  placeholder?: string
  disabled?: boolean
  error?: string
  id?: string
  autocomplete?: string
}

defineProps<Props>()
defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

<template>
  <div class="w-full">
    <input
      :id="id"
      :type="type ?? 'text'"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :autocomplete="autocomplete"
      :class="[
        'w-full h-10 px-3 rounded-md border bg-white text-sm placeholder:text-neutral-400 transition-colors',
        'disabled:bg-neutral-100 disabled:text-neutral-500 disabled:cursor-not-allowed',
        error
          ? 'border-danger focus:ring-2 focus:ring-danger/20 focus:border-danger'
          : 'border-neutral-300 focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500',
      ]"
      @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
    <p v-if="error" class="text-xs text-danger mt-1">{{ error }}</p>
  </div>
</template>
