<script setup lang="ts">
import { computed } from 'vue'
import { colorAt } from '../charts'

interface Segment {
  label: string
  value: number
  color?: string
}

interface Props {
  data: Segment[]
  size?: number
  thickness?: number
  centerLabel?: string
  centerValue?: string
  legend?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 180,
  thickness: 22,
  legend: true,
})

const total = computed(() => props.data.reduce((s, d) => s + d.value, 0))

const segments = computed(() => {
  const r = (props.size - props.thickness) / 2
  const c = 2 * Math.PI * r
  let offset = 0
  return props.data.map((d, i) => {
    const frac = total.value > 0 ? d.value / total.value : 0
    const len = frac * c
    const seg = {
      color: d.color ?? colorAt(i),
      label: d.label,
      value: d.value,
      pct: Math.round(frac * 100),
      dash: `${len} ${c - len}`,
      offset: -offset,
      r,
    }
    offset += len
    return seg
  })
})

const center = computed(() => props.size / 2)
</script>

<template>
  <div class="flex items-center gap-5" :class="legend ? 'flex-row' : 'flex-col'">
    <svg :width="size" :height="size" :viewBox="`0 0 ${size} ${size}`" class="flex-shrink-0 -rotate-90">
      <circle :cx="center" :cy="center" :r="(size - thickness) / 2" fill="none" stroke="#F4F4F5" :stroke-width="thickness" />
      <circle
        v-for="(s, i) in segments"
        :key="i"
        :cx="center"
        :cy="center"
        :r="s.r"
        fill="none"
        :stroke="s.color"
        :stroke-width="thickness"
        :stroke-dasharray="s.dash"
        :stroke-dashoffset="s.offset"
        stroke-linecap="butt"
      />
    </svg>
    <div v-if="centerLabel || centerValue" class="absolute pointer-events-none" :style="{ width: size + 'px', height: size + 'px' }" />
    <ul v-if="legend" class="space-y-2 text-sm min-w-0">
      <li v-for="(s, i) in segments" :key="i" class="flex items-center gap-2">
        <span class="h-2.5 w-2.5 rounded-sm flex-shrink-0" :style="{ background: s.color }" />
        <span class="text-neutral-600 truncate flex-1">{{ s.label }}</span>
        <span class="font-semibold text-neutral-900 tabular-nums">{{ s.value }}</span>
        <span class="text-neutral-400 text-xs tabular-nums w-9 text-right">{{ s.pct }}%</span>
      </li>
    </ul>
  </div>
</template>
