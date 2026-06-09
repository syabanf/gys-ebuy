<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'

interface Item { label: string; sublabel?: string; to: string; group?: string }

const props = defineProps<{ open: boolean; items: Item[] }>()
const emit = defineEmits<{ close: []; select: [to: string] }>()

const query = ref('')
const activeIndex = ref(0)
const inputEl = ref<HTMLInputElement | null>(null)

const results = computed(() => {
  const q = query.value.trim().toLowerCase()
  const base = q
    ? props.items.filter((i) => i.label.toLowerCase().includes(q) || (i.sublabel ?? '').toLowerCase().includes(q))
    : props.items
  return base.slice(0, 12)
})

watch(() => props.open, (o) => {
  if (o) {
    query.value = ''
    activeIndex.value = 0
    nextTick(() => inputEl.value?.focus())
  }
})
watch(results, () => { activeIndex.value = 0 })

function move(delta: number) {
  if (!results.value.length) return
  activeIndex.value = (activeIndex.value + delta + results.value.length) % results.value.length
}
function choose() {
  const item = results.value[activeIndex.value]
  if (item) emit('select', item.to)
}
</script>

<template>
  <Teleport to="body">
    <Transition name="cp">
      <div v-if="open" class="fixed inset-0 z-[70] flex items-start justify-center pt-[12vh] px-4" @keydown.down.prevent="move(1)" @keydown.up.prevent="move(-1)" @keydown.enter.prevent="choose" @keydown.esc="emit('close')">
        <div class="absolute inset-0 bg-neutral-900/50 backdrop-blur-sm" @click="emit('close')" />
        <div class="relative w-full max-w-xl bg-white rounded-xl shadow-elevated overflow-hidden">
          <div class="flex items-center gap-3 px-4 border-b border-neutral-100">
            <span class="text-neutral-400 text-lg">⌕</span>
            <input
              ref="inputEl"
              v-model="query"
              type="text"
              placeholder="Cari halaman, pesanan, produk…"
              class="flex-1 h-14 bg-transparent text-base outline-none placeholder:text-neutral-400"
            />
            <kbd class="text-[11px] text-neutral-400 border border-neutral-200 rounded px-1.5 py-0.5">ESC</kbd>
          </div>
          <ul v-if="results.length" class="max-h-80 overflow-y-auto py-2">
            <li
              v-for="(r, i) in results"
              :key="r.to + i"
              :class="['mx-2 px-3 py-2.5 rounded-lg flex items-center justify-between gap-3 cursor-pointer', i === activeIndex ? 'bg-brand-50' : 'hover:bg-neutral-50']"
              @mouseenter="activeIndex = i"
              @mousedown.prevent="emit('select', r.to)"
            >
              <div class="min-w-0">
                <p class="text-sm font-medium text-neutral-900 truncate">{{ r.label }}</p>
                <p v-if="r.sublabel" class="text-xs text-neutral-500 truncate">{{ r.sublabel }}</p>
              </div>
              <span v-if="r.group" :class="['text-[10px] px-2 py-0.5 rounded-full flex-shrink-0', i === activeIndex ? 'bg-brand-100 text-brand-700' : 'bg-neutral-100 text-neutral-500']">{{ r.group }}</span>
            </li>
          </ul>
          <div v-else class="px-6 py-10 text-center text-sm text-neutral-500">
            {{ query ? `Tidak ada hasil untuk "${query}"` : 'Mulai mengetik untuk mencari…' }}
          </div>
          <div class="px-4 py-2 border-t border-neutral-100 flex items-center gap-3 text-[11px] text-neutral-400">
            <span><kbd class="border border-neutral-200 rounded px-1">↑</kbd> <kbd class="border border-neutral-200 rounded px-1">↓</kbd> navigasi</span>
            <span><kbd class="border border-neutral-200 rounded px-1">↵</kbd> buka</span>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.cp-enter-active, .cp-leave-active { transition: opacity 0.15s ease; }
.cp-enter-from, .cp-leave-to { opacity: 0; }
</style>
