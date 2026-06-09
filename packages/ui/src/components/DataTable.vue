<script setup lang="ts" generic="T extends Record<string, any>">
import { computed, ref, watch } from 'vue'

interface Column<R> {
  key: string
  label: string
  align?: 'left' | 'right' | 'center'
  width?: string
  render?: (row: R) => any
  sortable?: boolean
}

interface Props {
  columns: Column<T>[]
  rows: T[]
  rowKey?: keyof T | ((row: T) => string)
  emptyTitle?: string
  emptyDescription?: string
  loading?: boolean
  sortable?: boolean
  pageSize?: number
  selectable?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  rowKey: 'id' as any,
  emptyTitle: 'Tidak ada data',
  sortable: false,
  pageSize: 10,
  selectable: false,
})

const emit = defineEmits<{ rowClick: [row: T]; 'update:selected': [keys: string[]] }>()

function keyFor(row: T, index: number): string {
  if (typeof props.rowKey === 'function') return props.rowKey(row)
  const k = row[props.rowKey as keyof T]
  return k != null ? String(k) : String(index)
}

// ---- Sorting ----
const sortKey = ref<string | null>(null)
const sortDir = ref<'asc' | 'desc'>('asc')
function toggleSort(col: Column<T>) {
  if (!props.sortable || col.sortable === false) return
  if (sortKey.value === col.key) {
    sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = col.key
    sortDir.value = 'asc'
  }
}

const sortedRows = computed(() => {
  if (!props.sortable || !sortKey.value) return props.rows
  const k = sortKey.value
  const dir = sortDir.value === 'asc' ? 1 : -1
  return [...props.rows].sort((a, b) => {
    const av = a[k]; const bv = b[k]
    if (av == null) return 1
    if (bv == null) return -1
    if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * dir
    return String(av).localeCompare(String(bv)) * dir
  })
})

// ---- Pagination ----
const page = ref(1)
const usePaging = computed(() => props.pageSize > 0 && sortedRows.value.length > props.pageSize)
const totalPages = computed(() => Math.max(1, Math.ceil(sortedRows.value.length / props.pageSize)))
const pagedRows = computed(() => {
  if (!usePaging.value) return sortedRows.value
  const start = (page.value - 1) * props.pageSize
  return sortedRows.value.slice(start, start + props.pageSize)
})
watch([() => props.rows, totalPages], () => { if (page.value > totalPages.value) page.value = 1 })
const rangeStart = computed(() => (sortedRows.value.length === 0 ? 0 : (page.value - 1) * props.pageSize + 1))
const rangeEnd = computed(() => Math.min(page.value * props.pageSize, sortedRows.value.length))

// ---- Selection ----
const selected = ref<Set<string>>(new Set())
const allKeys = computed(() => sortedRows.value.map((r, i) => keyFor(r, i)))
const allSelected = computed(() => allKeys.value.length > 0 && allKeys.value.every((k) => selected.value.has(k)))
const someSelected = computed(() => allKeys.value.some((k) => selected.value.has(k)) && !allSelected.value)
function toggleAll() {
  if (allSelected.value) selected.value = new Set()
  else selected.value = new Set(allKeys.value)
  emit('update:selected', [...selected.value])
}
function toggleRow(k: string) {
  const s = new Set(selected.value)
  if (s.has(k)) s.delete(k); else s.add(k)
  selected.value = s
  emit('update:selected', [...s])
}
function clearSelection() { selected.value = new Set(); emit('update:selected', []) }
defineExpose({ clearSelection })

const colSpan = computed(() => props.columns.length + (props.selectable ? 1 : 0))
</script>

<template>
  <div class="space-y-3">
    <!-- Bulk action bar -->
    <div v-if="selectable && selected.size > 0" class="flex items-center justify-between gap-3 bg-brand-50 border border-brand-200 rounded-lg px-4 py-2.5">
      <span class="text-sm font-medium text-brand-800">{{ selected.size }} dipilih</span>
      <div class="flex items-center gap-2">
        <slot name="bulk-actions" :selected="[...selected]" :clear="clearSelection" />
        <button class="text-sm text-neutral-500 hover:text-neutral-700" @click="clearSelection">Batal</button>
      </div>
    </div>

    <div class="bg-white rounded-lg border border-neutral-200 shadow-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-neutral-50 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider">
            <tr>
              <th v-if="selectable" class="px-5 py-3 w-10">
                <input type="checkbox" :checked="allSelected" :indeterminate.prop="someSelected" class="rounded border-neutral-300 text-brand-600 focus:ring-brand-500" @change="toggleAll" />
              </th>
              <th
                v-for="col in columns"
                :key="col.key"
                :style="col.width ? { width: col.width } : undefined"
                :class="[
                  'px-5 py-3 select-none',
                  col.align === 'right' && 'text-right',
                  col.align === 'center' && 'text-center',
                  sortable && col.sortable !== false ? 'cursor-pointer hover:text-neutral-700' : '',
                ]"
                @click="toggleSort(col)"
              >
                <span class="inline-flex items-center gap-1" :class="col.align === 'right' && 'flex-row-reverse'">
                  {{ col.label }}
                  <span v-if="sortable && col.sortable !== false" class="text-neutral-300">
                    <template v-if="sortKey === col.key">{{ sortDir === 'asc' ? '▲' : '▼' }}</template>
                    <template v-else>↕</template>
                  </span>
                </span>
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-neutral-100">
            <template v-if="loading">
              <tr v-for="i in 5" :key="`sk-${i}`">
                <td v-if="selectable" class="px-5 py-3.5"><div class="h-3 w-3 bg-neutral-100 rounded animate-pulse" /></td>
                <td v-for="col in columns" :key="col.key" class="px-5 py-3.5"><div class="h-3 bg-neutral-100 rounded animate-pulse" /></td>
              </tr>
            </template>
            <template v-else-if="sortedRows.length === 0">
              <tr><td :colspan="colSpan" class="px-5 py-12 text-center">
                <p class="text-sm font-medium text-neutral-700">{{ emptyTitle }}</p>
                <p v-if="emptyDescription" class="text-sm text-neutral-500 mt-1">{{ emptyDescription }}</p>
              </td></tr>
            </template>
            <template v-else>
              <tr
                v-for="(row, i) in pagedRows"
                :key="keyFor(row, i)"
                class="hover:bg-neutral-50 transition-colors"
                :class="selected.has(keyFor(row, i)) ? 'bg-brand-50/40' : ''"
              >
                <td v-if="selectable" class="px-5 py-3.5" @click.stop>
                  <input type="checkbox" :checked="selected.has(keyFor(row, i))" class="rounded border-neutral-300 text-brand-600 focus:ring-brand-500" @change="toggleRow(keyFor(row, i))" />
                </td>
                <td
                  v-for="col in columns"
                  :key="col.key"
                  :class="['px-5 py-3.5 text-neutral-800', col.align === 'right' && 'text-right', col.align === 'center' && 'text-center', $attrs.onRowClick ? 'cursor-pointer' : '']"
                  @click="emit('rowClick', row)"
                >
                  <slot :name="`cell-${col.key}`" :row="row" :value="row[col.key]">
                    <template v-if="col.render">{{ col.render(row) }}</template>
                    <template v-else>{{ row[col.key] }}</template>
                  </slot>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="usePaging && !loading" class="flex items-center justify-between px-5 py-3 border-t border-neutral-200 bg-neutral-50">
        <p class="text-xs text-neutral-500">Menampilkan {{ rangeStart }}–{{ rangeEnd }} dari {{ sortedRows.length }}</p>
        <div class="flex items-center gap-1">
          <button class="px-2.5 py-1 text-sm rounded border border-neutral-300 bg-white disabled:opacity-40 hover:bg-neutral-100" :disabled="page === 1" @click="page--">‹</button>
          <span class="px-3 text-sm text-neutral-600">{{ page }} / {{ totalPages }}</span>
          <button class="px-2.5 py-1 text-sm rounded border border-neutral-300 bg-white disabled:opacity-40 hover:bg-neutral-100" :disabled="page === totalPages" @click="page++">›</button>
        </div>
      </div>
    </div>
  </div>
</template>
