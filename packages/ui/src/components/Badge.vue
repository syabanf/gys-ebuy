<script setup lang="ts">
import type { BadgeTone } from '../types'

interface Props {
  tone?: BadgeTone
  size?: 'sm' | 'md'
}

withDefaults(defineProps<Props>(), { tone: 'neutral', size: 'sm' })

const toneClasses: Record<BadgeTone, string> = {
  neutral: 'bg-neutral-100 text-neutral-700 ring-neutral-200',
  brand: 'bg-brand-50 text-brand-700 ring-brand-200',
  success: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
  warning: 'bg-amber-50 text-amber-800 ring-amber-200',
  danger: 'bg-red-50 text-red-700 ring-red-200',
  info: 'bg-blue-50 text-blue-700 ring-blue-200',
}
</script>

<template>
  <span
    :class="[
      'inline-flex items-center gap-1 rounded-full font-medium ring-1 ring-inset',
      size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-1 text-sm',
      toneClasses[tone],
    ]"
  >
    <slot />
  </span>
</template>
