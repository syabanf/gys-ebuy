<script setup lang="ts">
import { computed } from 'vue'
import { chartColors } from '../charts'

interface Point {
  label: string
  value: number
}

interface Props {
  data: Point[]
  height?: number
  color?: string
  formatValue?: (n: number) => string
  area?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  height: 200,
  color: chartColors.brand,
  area: true,
})

const stats = computed(() => {
  const vals = props.data.map((d) => d.value)
  const max = Math.max(...vals, 0)
  const min = Math.min(...vals, 0)
  // Headroom so the peak isn't flush with the top.
  const top = max === min ? max + 1 : max + (max - min) * 0.15
  const bottom = Math.min(min, 0)
  return { top, bottom, range: top - bottom || 1 }
})

const geometry = computed(() => {
  const n = props.data.length
  const pts = props.data.map((d, i) => {
    const x = n === 1 ? 50 : (i / (n - 1)) * 100
    const y = 100 - ((d.value - stats.value.bottom) / stats.value.range) * 100
    return [x, y] as const
  })
  const line = pts.map((p) => `${p[0].toFixed(2)},${p[1].toFixed(2)}`).join(' ')
  const area = `0,100 ${line} 100,100`
  return { line, area, pts }
})

function fmt(n: number) {
  return props.formatValue ? props.formatValue(n) : String(n)
}
</script>

<template>
  <div>
    <div class="relative w-full" :style="{ height: height + 'px' }">
      <!-- y-axis max label -->
      <span class="absolute top-0 left-0 text-[11px] text-neutral-400 tabular-nums">{{ fmt(stats.top) }}</span>
      <svg class="w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
        <!-- gridlines -->
        <line x1="0" y1="0" x2="100" y2="0" :stroke="chartColors.grid" stroke-width="1" vector-effect="non-scaling-stroke" stroke-dasharray="3 3" />
        <line x1="0" y1="50" x2="100" y2="50" :stroke="chartColors.grid" stroke-width="1" vector-effect="non-scaling-stroke" stroke-dasharray="3 3" />
        <line x1="0" y1="100" x2="100" y2="100" :stroke="chartColors.grid" stroke-width="1" vector-effect="non-scaling-stroke" />
        <polygon v-if="area" :points="geometry.area" :fill="color" opacity="0.10" />
        <polyline :points="geometry.line" fill="none" :stroke="color" stroke-width="2" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" />
        <circle
          v-for="(p, i) in geometry.pts"
          :key="i"
          :cx="p[0]"
          :cy="p[1]"
          r="2.5"
          :fill="color"
          vector-effect="non-scaling-stroke"
        />
      </svg>
    </div>
    <div class="flex mt-2 border-t border-neutral-100 pt-2">
      <div v-for="(p, i) in data" :key="i" class="flex-1 text-center min-w-0">
        <span class="text-[11px] text-neutral-500 truncate block">{{ p.label }}</span>
      </div>
    </div>
  </div>
</template>
