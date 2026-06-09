<script setup lang="ts">
import GSparkline from './Sparkline.vue'

interface Props {
  label: string
  value: string | number
  hint?: string
  trend?: 'up' | 'down' | 'flat'
  trendValue?: string
  icon?: string
  spark?: number[]
  sparkColor?: string
}

withDefaults(defineProps<Props>(), { trend: 'flat' })
</script>

<template>
  <div class="bg-white rounded-lg border border-neutral-200 shadow-card p-5">
    <div class="flex items-start justify-between gap-3">
      <div class="min-w-0">
        <div class="flex items-center gap-2">
          <span v-if="icon" class="text-base text-neutral-400">{{ icon }}</span>
          <p class="text-sm text-neutral-500 truncate">{{ label }}</p>
        </div>
        <p class="text-2xl font-semibold text-neutral-900 mt-2 tabular-nums">{{ value }}</p>
      </div>
      <div v-if="spark && spark.length" class="flex-shrink-0 pt-1">
        <GSparkline :values="spark" :color="sparkColor" />
      </div>
    </div>
    <div v-if="hint || trendValue" class="flex items-center gap-2 mt-2">
      <span
        v-if="trendValue"
        :class="[
          'text-xs font-medium',
          trend === 'up' && 'text-success',
          trend === 'down' && 'text-danger',
          trend === 'flat' && 'text-neutral-500',
        ]"
      >
        <span v-if="trend === 'up'">▲</span>
        <span v-else-if="trend === 'down'">▼</span>
        <span v-else>—</span>
        {{ trendValue }}
      </span>
      <span v-if="hint" class="text-xs text-neutral-500">{{ hint }}</span>
    </div>
  </div>
</template>
