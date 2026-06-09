<script setup lang="ts">
import { GBadge, GButton, GDataTable, GInput, GLabel, GModal, GSummaryCard, formatIDR } from '@gys/ui'
import { useCatalogStore, type Product } from '~/composables/useCatalogStore'
import { useToast } from '~/composables/useToast'

const store = useCatalogStore()
const router = useRouter()
const toast = useToast()
const search = ref('')
const categoryFilter = ref('all')
const statusFilter = ref('all')
const loading = ref(true)
const selected = ref<string[]>([])

onMounted(async () => { await store.load(); loading.value = false })

const summary = computed(() => {
  const list = store.products
  const avg = list.length ? Math.round(list.reduce((s, p) => s + p.centralPrice, 0) / list.length) : 0
  return { total: list.length, active: store.activeCount, categories: store.categories.length, avg }
})

const filtered = computed(() => {
  let list = store.products
  if (categoryFilter.value !== 'all') list = list.filter((p) => p.categoryId === categoryFilter.value)
  if (statusFilter.value !== 'all') list = list.filter((p) => p.status === statusFilter.value)
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter((p) => p.name.toLowerCase().includes(q) || p.sku.toLowerCase().includes(q))
  }
  return list
})

function resetFilters() { search.value = ''; categoryFilter.value = 'all'; statusFilter.value = 'all' }

// CRUD
const showForm = ref(false)
const editingId = ref<string | null>(null)
const deleteTarget = ref<Product | null>(null)
const errors = ref<Record<string, string>>({})
const uoms = ['batang', 'lembar', 'kg', 'm', 'pcs', 'roll']
const blank = () => ({ name: '', sku: '', categoryId: store.categories[0]?.id ?? '', uom: 'batang', centralPrice: 0, weightKg: 0, status: 'active' })
const form = ref(blank())

function openCreate() { editingId.value = null; errors.value = {}; form.value = blank(); showForm.value = true }
function openEdit(p: Product) {
  editingId.value = p.id; errors.value = {}
  form.value = { name: p.name, sku: p.sku, categoryId: p.categoryId, uom: p.uom, centralPrice: p.centralPrice, weightKg: p.weightKg, status: p.status }
  showForm.value = true
}
function validate() {
  const e: Record<string, string> = {}
  if (!form.value.name.trim()) e.name = 'Nama wajib diisi'
  if (!form.value.sku.trim()) e.sku = 'SKU wajib diisi'
  if (!form.value.centralPrice || form.value.centralPrice <= 0) e.centralPrice = 'Harga harus > 0'
  errors.value = e; return Object.keys(e).length === 0
}
function save() {
  if (!validate()) return
  const payload = { name: form.value.name.trim(), sku: form.value.sku.trim().toUpperCase(), categoryId: form.value.categoryId, uom: form.value.uom, centralPrice: Number(form.value.centralPrice), weightKg: Number(form.value.weightKg) || 0, status: form.value.status }
  if (editingId.value) { store.update(editingId.value, payload); toast.success('Produk diperbarui') }
  else { store.create(payload); toast.success('Produk ditambahkan') }
  showForm.value = false
}
function confirmDelete() {
  if (deleteTarget.value) { store.remove(deleteTarget.value.id); toast.success('Produk dihapus') }
  deleteTarget.value = null
}

// CSV
const csvHeaders = [
  { key: 'sku', label: 'SKU' }, { key: 'name', label: 'Nama' }, { key: 'uom', label: 'UoM' },
  { key: 'centralPrice', label: 'Harga' }, { key: 'status', label: 'Status' },
]
function exportCsv(rows: Product[]) {
  downloadCsv(`katalog-distributor-${rows.length}.csv`, rows, csvHeaders)
  toast.success(`${rows.length} produk diekspor ke CSV`)
}
function bulkDelete(ids: string[], clear: () => void) {
  store.removeMany(ids); toast.success(`${ids.length} produk dihapus`); clear()
}
function bulkExport(ids: string[]) {
  const set = new Set(ids)
  exportCsv(store.products.filter((p) => set.has(p.id)))
}

const columns = [
  { key: 'sku', label: 'SKU', width: '140px', sortable: true },
  { key: 'name', label: 'Nama Produk', sortable: true },
  { key: 'category', label: 'Kategori', width: '160px', sortable: false },
  { key: 'uom', label: 'UoM', width: '80px' },
  { key: 'centralPrice', label: 'Harga Pusat', align: 'right' as const, width: '150px', sortable: true },
  { key: 'status', label: 'Status', width: '100px', sortable: true },
  { key: 'actions', label: '', width: '120px', align: 'right' as const, sortable: false },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Katalog Produk</h1>
        <p class="text-sm text-neutral-500 mt-1">{{ store.products.length }} produk · {{ summary.active }} aktif</p>
      </div>
      <div class="flex gap-2">
        <GButton variant="secondary" @click="toast.info('Fitur impor CSV tersedia di MVP1')">Impor CSV</GButton>
        <GButton variant="secondary" @click="exportCsv(filtered)">Ekspor CSV</GButton>
        <GButton @click="openCreate">+ Tambah Produk</GButton>
      </div>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Produk" :value="loading ? '…' : summary.total" icon="◷" tone="brand" />
      <GSummaryCard label="Produk Aktif" :value="loading ? '…' : summary.active" icon="✓" tone="success" />
      <GSummaryCard label="Kategori" :value="loading ? '…' : summary.categories" icon="☰" tone="info" />
      <GSummaryCard label="Harga Rata-rata" :value="loading ? '…' : formatIDR(summary.avg)" icon="◉" tone="warning" />
    </div>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari nama produk atau SKU…" /></div>
      <select v-model="categoryFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Kategori</option>
        <option v-for="c in store.categories" :key="c.id" :value="c.id">{{ c.name }}</option>
      </select>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Status</option>
        <option value="active">Aktif</option>
        <option value="inactive">Nonaktif</option>
      </select>
      <button v-if="search || categoryFilter !== 'all' || statusFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ filtered.length }} produk ditampilkan</p>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" sortable selectable empty-title="Tidak ada produk" empty-description="Coba ubah filter atau tambah produk." @update:selected="selected = $event" @row-click="(row) => router.push(`/catalog/${row.id}`)">
      <template #bulk-actions="{ selected: sel, clear }">
        <GButton size="sm" variant="secondary" @click="bulkExport(sel)">Ekspor</GButton>
        <GButton size="sm" variant="danger" @click="bulkDelete(sel, clear)">Hapus</GButton>
      </template>
      <template #cell-sku="{ row }"><span class="font-mono text-xs text-neutral-600">{{ row.sku }}</span></template>
      <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.name }}</span></template>
      <template #cell-category="{ row }"><span class="text-neutral-600">{{ store.categoryName(row.categoryId) }}</span></template>
      <template #cell-centralPrice="{ row }"><span class="font-semibold">{{ formatIDR(row.centralPrice) }}</span></template>
      <template #cell-status="{ row }"><GBadge :tone="row.status === 'active' ? 'success' : 'neutral'">{{ row.status === 'active' ? 'Aktif' : 'Nonaktif' }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-danger hover:text-red-700 font-medium px-2 py-1" @click.stop="deleteTarget = row">Hapus</button>
        </div>
      </template>
    </GDataTable>

    <GModal :open="showForm" :title="editingId ? 'Ubah Produk' : 'Tambah Produk'" size="lg" @close="showForm = false">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="sm:col-span-2"><GLabel for="name" required>Nama Produk</GLabel><GInput id="name" v-model="form.name" :error="errors.name" /></div>
        <div><GLabel for="sku" required>SKU</GLabel><GInput id="sku" v-model="form.sku" :error="errors.sku" /></div>
        <div>
          <GLabel for="cat">Kategori</GLabel>
          <select id="cat" v-model="form.categoryId" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option v-for="c in store.categories" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </div>
        <div>
          <GLabel for="uom">Satuan</GLabel>
          <select id="uom" v-model="form.uom" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option v-for="u in uoms" :key="u" :value="u">{{ u }}</option>
          </select>
        </div>
        <div>
          <GLabel for="status">Status</GLabel>
          <select id="status" v-model="form.status" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="active">Aktif</option>
            <option value="inactive">Nonaktif</option>
          </select>
        </div>
        <div><GLabel for="price" required>Harga (IDR)</GLabel><GInput id="price" v-model="form.centralPrice" type="number" :error="errors.centralPrice" /></div>
        <div><GLabel for="weight">Berat (kg)</GLabel><GInput id="weight" v-model="form.weightKg" type="number" /></div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">{{ editingId ? 'Simpan' : 'Tambah' }}</GButton>
      </template>
    </GModal>

    <GModal :open="!!deleteTarget" title="Hapus produk?" @close="deleteTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ deleteTarget?.name }}</strong> ({{ deleteTarget?.sku }})?</p>
      <template #footer>
        <GButton variant="secondary" @click="deleteTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmDelete">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
