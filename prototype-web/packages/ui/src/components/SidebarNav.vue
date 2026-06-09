<script setup lang="ts">
import { reactive } from 'vue'

interface NavItem {
  label: string
  to: string
  icon?: string
  badge?: string | number
}
interface NavGroup {
  label?: string
  icon?: string
  collapsible?: boolean
  items: NavItem[]
}

const props = defineProps<{ nav: NavGroup[]; currentPath: string }>()
defineEmits<{ navigate: [to: string] }>()

const manualOpen = reactive<Record<number, boolean>>({})

function isActive(itemPath: string): boolean {
  if (itemPath === '/') return props.currentPath === '/'
  return props.currentPath.startsWith(itemPath)
}
function groupActive(g: NavGroup): boolean {
  return g.items.some((i) => isActive(i.to))
}
function isOpen(g: NavGroup, i: number): boolean {
  if (!g.collapsible) return true
  return manualOpen[i] ?? groupActive(g)
}
function toggle(g: NavGroup, i: number) {
  if (!g.collapsible) return
  manualOpen[i] = !isOpen(g, i)
}
</script>

<template>
  <nav class="flex-1 px-2 py-3 space-y-1 overflow-y-auto">
    <div v-for="(group, gi) in nav" :key="gi" class="space-y-0.5">
      <button
        v-if="group.collapsible"
        type="button"
        class="w-full flex items-center gap-2.5 px-3 py-2 rounded-md text-sm font-medium transition-colors text-neutral-700 hover:bg-neutral-100"
        @click="toggle(group, gi)"
      >
        <span v-if="group.icon" class="text-base w-5 text-center text-neutral-400">{{ group.icon }}</span>
        <span class="flex-1 text-left">{{ group.label }}</span>
        <span class="text-neutral-400 text-xs transition-transform duration-200" :class="isOpen(group, gi) ? 'rotate-90' : ''">›</span>
      </button>
      <p v-else-if="group.label" class="px-3 pt-3 pb-1 text-[11px] font-semibold uppercase tracking-wider text-neutral-400">{{ group.label }}</p>

      <div v-show="isOpen(group, gi)" :class="group.collapsible ? 'pl-3' : ''" class="space-y-0.5">
        <a
          v-for="item in group.items"
          :key="item.to"
          :href="item.to"
          :class="[
            'flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
            isActive(item.to) ? 'bg-brand-50 text-brand-700' : 'text-neutral-700 hover:bg-neutral-100',
          ]"
          @click.prevent="$emit('navigate', item.to)"
        >
          <span class="text-base w-5 text-center">{{ item.icon ?? '•' }}</span>
          <span class="flex-1">{{ item.label }}</span>
          <span v-if="item.badge" class="bg-brand-100 text-brand-700 text-xs font-semibold px-2 py-0.5 rounded-full">{{ item.badge }}</span>
        </a>
      </div>
    </div>
  </nav>
</template>
