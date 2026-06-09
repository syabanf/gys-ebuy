<script setup lang="ts">
import { GBadge, GButton, GDataTable, GInput, GLabel, GModal, GSummaryCard, formatIDR } from '@gys/ui'
import { useInventoryStore } from '~/composables/useInventoryStore'
import { useSessionStore } from '~/composables/useSession'

const session = useSessionStore()
const store = useInventoryStore()
const distId = computed(() => session.distributorId ?? 'dist-001')
const loading = ref(true)
const search = ref('')
const statusFilter = ref<'all' | 'safe' | 'low' | 'out'>('all')

onMounted(async () => {
  await store.load()
  loading.value = false
})

const allRows = computed(() => store.rowsFor(distId.value))

function available(r: any) { return r.onHand - r.reserved }
function rowStatusKey(r: any): 'safe' | 'low' | 'out' {
  const a = available(r)
  if (a <= 0) return 'out'
  if (a <= r.safetyStock) return 'low'
  return 'safe'
}
function rowStatus(r: any) {
  return { out: { label: 'Habis', tone: 'danger' as const }, low: { label: 'Stok Rendah', tone: 'warning' as const }, safe: { label: 'Aman', tone: 'success' as const } }[rowStatusKey(r)]
}

const summary = computed(() => {
  const rows = allRows.value
  return {
    total: rows.length,
    low: rows.filter((r) => rowStatusKey(r) === 'low').length,
    out: rows.filter((r) => rowStatusKey(r) === 'out').length,
    value: rows.reduce((s, r) => s + r.onHand * (r.product?.centralPrice ?? 0), 0),
  }
})

const rows = computed(() => {
  let list = allRows.value
  if (statusFilter.value !== 'all') list = list.filter((r) => rowStatusKey(r) === statusFilter.value)
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter((r) => (r.product?.name ?? '').toLowerCase().includes(q) || (r.product?.sku ?? '').toLowerCase().includes(q))
  }
  return list
})

function resetFilters() { search.value = ''; statusFilter.value = 'all' }

// ---- Edit stock ----
const showEdit = ref(false)
const editProductId = ref<string | null>(null)
const editForm = ref({ onHand: 0, safetyStock: 0, leadTimeDays: 0 })
function openEdit(r: any) {
  editProductId.value = r.productId
  editForm.value = { onHand: r.onHand, safetyStock: r.safetyStock, leadTimeDays: r.leadTimeDays }
  showEdit.value = true
}
function saveEdit() {
  if (editProductId.value) {
    store.updateStock(distId.value, editProductId.value, {
      onHand: Number(editForm.value.onHand) || 0,
      safetyStock: Number(editForm.value.safetyStock) || 0,
      leadTimeDays: Number(editForm.value.leadTimeDays) || 0,
    })
  }
  showEdit.value = false
}

// ---- Add product ----
const showAdd = ref(false)
const addForm = ref({ productId: '', onHand: 0, safetyStock: 10, leadTimeDays: 3 })
const addable = computed(() => store.availableProducts(distId.value))
function openAdd() {
  addForm.value = { productId: addable.value[0]?.id ?? '', onHand: 0, safetyStock: 10, leadTimeDays: 3 }
  showAdd.value = true
}
function saveAdd() {
  if (!addForm.value.productId) return
  store.addRow(distId.value, addForm.value.productId, {
    onHand: Number(addForm.value.onHand) || 0,
    safetyStock: Number(addForm.value.safetyStock) || 0,
    leadTimeDays: Number(addForm.value.leadTimeDays) || 0,
  })
  showAdd.value = false
}

// ---- Remove ----
const removeTarget = ref<any | null>(null)
function confirmRemove() {
  if (removeTarget.value) store.removeRow(distId.value, removeTarget.value.productId)
  removeTarget.value = null
}

const columns = [
  { key: 'sku', label: 'SKU', width: '130px' },
  { key: 'name', label: 'Produk' },
  { key: 'onHand', label: 'Stok Fisik', align: 'right' as const, width: '110px' },
  { key: 'reserved', label: 'Direservasi', align: 'right' as const, width: '110px' },
  { key: 'available', label: 'Tersedia', align: 'right' as const, width: '100px' },
  { key: 'safetyStock', label: 'Safety', align: 'right' as const, width: '90px' },
  { key: 'status', label: 'Status', width: '110px' },
  { key: 'actions', label: '', width: '120px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Stok Gudang</h1>
        <p class="text-sm text-neutral-500 mt-1">Atur level stok, safety stock, dan lead time.</p>
      </div>
      <GButton @click="openAdd">+ Tambah Produk ke Stok</GButton>
    </div>

    <!-- Summary cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total SKU" :value="loading ? '…' : summary.total" icon="◰" tone="brand" />
      <GSummaryCard label="Stok Rendah" :value="loading ? '…' : summary.low" icon="▼" tone="warning" />
      <GSummaryCard label="Habis" :value="loading ? '…' : summary.out" icon="✕" tone="danger" />
      <GSummaryCard label="Nilai Stok" :value="loading ? '…' : formatIDR(summary.value)" icon="◉" tone="success" />
    </div>

    <!-- Filters -->
    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari produk atau SKU…" /></div>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Status</option>
        <option value="safe">Aman</option>
        <option value="low">Stok Rendah</option>
        <option value="out">Habis</option>
      </select>
      <button v-if="search || statusFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ rows.length }} produk ditampilkan</p>

    <GDataTable :columns="columns" :rows="rows" :loading="loading" row-key="productId" empty-title="Tidak ada produk" empty-description="Coba ubah filter atau tambahkan produk ke stok.">
      <template #cell-sku="{ row }"><span class="font-mono text-xs text-neutral-600">{{ row.product?.sku }}</span></template>
      <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.product?.name }}</span></template>
      <template #cell-available="{ row }">
        <span :class="['font-semibold', available(row) <= row.safetyStock ? 'text-danger' : 'text-neutral-900']">{{ available(row) }}</span>
      </template>
      <template #cell-status="{ row }"><GBadge :tone="rowStatus(row).tone">{{ rowStatus(row).label }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-danger hover:text-red-700 font-medium px-2 py-1" @click.stop="removeTarget = row">Hapus</button>
        </div>
      </template>
    </GDataTable>

    <!-- Edit stock -->
    <GModal :open="showEdit" title="Ubah Stok" @close="showEdit = false">
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div><GLabel for="oh">Stok Fisik</GLabel><GInput id="oh" v-model="editForm.onHand" type="number" /></div>
        <div><GLabel for="ss">Safety Stock</GLabel><GInput id="ss" v-model="editForm.safetyStock" type="number" /></div>
        <div><GLabel for="lt">Lead Time (hari)</GLabel><GInput id="lt" v-model="editForm.leadTimeDays" type="number" /></div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showEdit = false">Batal</GButton>
        <GButton @click="saveEdit">Simpan</GButton>
      </template>
    </GModal>

    <!-- Add product -->
    <GModal :open="showAdd" title="Tambah Produk ke Stok" @close="showAdd = false">
      <div v-if="addable.length === 0" class="text-sm text-neutral-600">Semua produk katalog sudah ada di stok Anda.</div>
      <div v-else class="space-y-4">
        <div>
          <GLabel for="prod" required>Produk</GLabel>
          <select id="prod" v-model="addForm.productId" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option v-for="p in addable" :key="p.id" :value="p.id">{{ p.name }} ({{ p.sku }})</option>
          </select>
        </div>
        <div class="grid grid-cols-3 gap-4">
          <div><GLabel for="aoh">Stok Awal</GLabel><GInput id="aoh" v-model="addForm.onHand" type="number" /></div>
          <div><GLabel for="ass">Safety Stock</GLabel><GInput id="ass" v-model="addForm.safetyStock" type="number" /></div>
          <div><GLabel for="alt">Lead Time</GLabel><GInput id="alt" v-model="addForm.leadTimeDays" type="number" /></div>
        </div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showAdd = false">Batal</GButton>
        <GButton :disabled="addable.length === 0" @click="saveAdd">Tambah</GButton>
      </template>
    </GModal>

    <!-- Remove confirm -->
    <GModal :open="!!removeTarget" title="Hapus dari stok?" @close="removeTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ removeTarget?.product?.name }}</strong> dari daftar stok Anda?</p>
      <template #footer>
        <GButton variant="secondary" @click="removeTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmRemove">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
