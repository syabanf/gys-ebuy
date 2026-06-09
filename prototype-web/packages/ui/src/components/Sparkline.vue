<script setup lang="ts">
import { computed } from 'vue'
import { chartColors } from '../charts'

interface Props {
  values: number[]
  color?: string
  width?: number
  height?: number
  fill?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  color: chartColors.brand,
  width: 96,
  height: 28,
  fill: true,
})

const geometry = computed(() => {
  const vals = props.values.length ? props.values : [0, 0]
  const min = Math.min(...vals)
  const max = Math.max(...vals)
  const range = max - min || 1
  const n = vals.length
  const pad = 2
  const w = props.width
  const h = props.height
  const pts = vals.map((v, i) => {
    const x = n === 1 ? w / 2 : pad + (i / (n - 1)) * (w - pad * 2)
    const y = h - pad - ((v - min) / range) * (h - pad * 2)
    return [x, y] as const
  })
  const line = pts.map((p) => `${p[0].toFixed(1)},${p[1].toFixed(1)}`).join(' ')
  const area = `M ${pts[0][0].toFixed(1)},${h} L ${line.replace(/ /g, ' L ')} L ${pts[n - 1][0].toFixed(1)},${h} Z`
  return { line, area }
})
</script>

<template>
  <svg :width="width" :height="height" :viewBox="`0 0 ${width} ${height}`" preserveAspectRatio="none" class="overflow-visible">
    <path v-if="fill" :d="geometry.area" :fill="color" opacity="0.12" />
    <polyline :points="geometry.line" fill="none" :stroke="color" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" />
  </svg>
</template>
