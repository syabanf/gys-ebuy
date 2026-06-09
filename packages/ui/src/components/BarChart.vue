<script setup lang="ts">
import { computed } from 'vue'
import { chartColors } from '../charts'

interface Bar {
  label: string
  value: number
  color?: string
  caption?: string
}

interface Props {
  data: Bar[]
  height?: number
  color?: string
  formatValue?: (n: number) => string
}

const props = withDefaults(defineProps<Props>(), {
  height: 180,
  color: chartColors.brand,
})

const max = computed(() => Math.max(1, ...props.data.map((d) => d.value)))
function fmt(n: number) {
  return props.formatValue ? props.formatValue(n) : String(n)
}
</script>

<template>
  <div>
    <div class="flex items-end gap-3" :style="{ height: height + 'px' }">
      <div v-for="(bar, i) in data" :key="i" class="flex-1 flex flex-col items-center justify-end h-full min-w-0">
        <span class="text-xs font-semibold text-neutral-700 mb-1 tabular-nums whitespace-nowrap">{{ fmt(bar.value) }}</span>
        <div
          class="w-full rounded-t-md transition-all duration-300"
          :style="{
            height: `${(bar.value / max) * 100}%`,
            minHeight: bar.value > 0 ? '4px' : '0',
            background: bar.color ?? color,
          }"
          :title="`${bar.label}: ${fmt(bar.value)}`"
        />
      </div>
    </div>
    <div class="flex gap-3 mt-2 border-t border-neutral-100 pt-2">
      <div v-for="(bar, i) in data" :key="i" class="flex-1 text-center min-w-0">
        <p class="text-xs text-neutral-600 truncate" :title="bar.label">{{ bar.label }}</p>
        <p v-if="bar.caption" class="text-[10px] text-neutral-400 truncate">{{ bar.caption }}</p>
      </div>
    </div>
  </div>
</template>
