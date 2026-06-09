<script setup lang="ts">
type Tone = 'brand' | 'info' | 'warning' | 'danger' | 'success' | 'neutral'

interface Props {
  label: string
  value: string | number
  icon?: string
  tone?: Tone
  hint?: string
}

withDefaults(defineProps<Props>(), { tone: 'brand' })

const chipClasses: Record<Tone, string> = {
  brand: 'bg-gradient-to-br from-brand-400 to-brand-600 text-white',
  info: 'bg-gradient-to-br from-blue-400 to-blue-600 text-white',
  warning: 'bg-gradient-to-br from-amber-400 to-amber-600 text-white',
  danger: 'bg-gradient-to-br from-red-400 to-red-600 text-white',
  success: 'bg-gradient-to-br from-emerald-400 to-emerald-600 text-white',
  neutral: 'bg-gradient-to-br from-neutral-400 to-neutral-600 text-white',
}
</script>

<template>
  <div class="group bg-white rounded-xl border border-neutral-200 shadow-card p-4 flex items-center gap-3.5 transition-all duration-200 hover:shadow-elevated hover:border-neutral-300 hover:-translate-y-0.5">
    <div v-if="icon" class="h-11 w-11 rounded-lg flex items-center justify-center text-lg flex-shrink-0 shadow-sm transition-transform duration-200 group-hover:scale-105" :class="chipClasses[tone]">
      {{ icon }}
    </div>
    <div class="min-w-0">
      <p class="text-xl font-semibold text-neutral-900 tabular-nums leading-tight truncate">{{ value }}</p>
      <p class="text-xs text-neutral-500 truncate">{{ label }}</p>
      <p v-if="hint" class="text-[11px] text-neutral-400 truncate">{{ hint }}</p>
    </div>
  </div>
</template>
