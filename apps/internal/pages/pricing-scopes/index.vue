<script setup lang="ts">
import { GBadge, GButton, GCard, GDataTable, GInput, GLabel, GModal, GSummaryCard } from '@gys/ui'
import { usePricingStore, type Scope } from '~/composables/usePricingStore'
import { useToast } from '~/composables/useToast'
import { useMockApi } from '~/composables/useMockApi'

const store = usePricingStore()
const toast = useToast()
const api = useMockApi()
const loading = ref(true)
const typeFilter = ref('all')
const search = ref('')
const distributors = ref<any[]>([])

onMounted(async () => {
  await store.load()
  distributors.value = await api.listDistributors()
  loading.value = false
})

const summary = computed(() => ({
  total: store.scopes.length,
  central: store.scopes.filter((s) => s.type === 'central').length,
  distributor: store.scopes.filter((s) => s.type === 'distributor').length,
  active: store.scopes.filter((s) => s.active).length,
}))

const filtered = computed(() => {
  let list = store.scopes
  if (typeFilter.value !== 'all') list = list.filter((s) => s.type === typeFilter.value)
  if (search.value.trim()) { const q = search.value.toLowerCase(); list = list.filter((s) => s.label.toLowerCase().includes(q)) }
  return list
})
function resetFilters() { typeFilter.value = 'all'; search.value = '' }

// CRUD
const showForm = ref(false)
const editingId = ref<string | null>(null)
const deleteTarget = ref<Scope | null>(null)
const errors = ref<Record<string, string>>({})
const blank = () => ({ type: 'central' as 'central' | 'distributor', label: '', distributorId: '' as string, active: true, notes: '' })
const form = ref(blank())

function openCreate() { editingId.value = null; errors.value = {}; form.value = blank(); showForm.value = true }
function openEdit(s: Scope) {
  editingId.value = s.id; errors.value = {}
  form.value = { type: s.type, label: s.label, distributorId: s.distributorId ?? '', active: s.active, notes: s.notes ?? '' }
  showForm.value = true
}
function save() {
  const e: Record<string, string> = {}
  if (!form.value.label.trim()) e.label = 'Nama scope wajib diisi'
  if (form.value.type === 'distributor' && !form.value.distributorId) e.distributorId = 'Pilih distributor'
  errors.value = e
  if (Object.keys(e).length) return
  const payload = {
    type: form.value.type,
    label: form.value.label.trim(),
    distributorId: form.value.type === 'distributor' ? form.value.distributorId : null,
    active: form.value.active,
    notes: form.value.notes.trim(),
  }
  if (editingId.value) { store.update(editingId.value, payload); toast.success('Scope diperbarui') }
  else { store.create(payload); toast.success('Scope dibuat') }
  showForm.value = false
}
function confirmDelete() {
  if (deleteTarget.value) { store.remove(deleteTarget.value.id); toast.success('Scope dihapus') }
  deleteTarget.value = null
}

const columns = [
  { key: 'label', label: 'Scope', sortable: true },
  { key: 'type', label: 'Tipe', width: '140px', sortable: true },
  { key: 'notes', label: 'Catatan' },
  { key: 'active', label: 'Status', width: '110px', sortable: true },
  { key: 'actions', label: '', width: '120px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Pricing Scope</h1>
        <p class="text-sm text-neutral-500 mt-1">Atur strategi harga: pusat (GYS) vs per-distributor.</p>
      </div>
      <GButton @click="openCreate">+ Buat Scope</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Scope" :value="loading ? '…' : summary.total" icon="◉" tone="brand" />
      <GSummaryCard label="Pusat" :value="loading ? '…' : summary.central" icon="★" tone="info" />
      <GSummaryCard label="Distributor" :value="loading ? '…' : summary.distributor" icon="◰" tone="warning" />
      <GSummaryCard label="Aktif" :value="loading ? '…' : summary.active" icon="✓" tone="success" />
    </div>

    <GCard title="Aturan Prioritas" description="Bagaimana harga efektif ditentukan saat pembeli menambahkan produk ke keranjang">
      <ol class="space-y-3 text-sm text-neutral-700 list-decimal list-inside">
        <li>Jika pembeli memesan via distributor yang punya <strong>distributor scope</strong> untuk produk → gunakan harga distributor.</li>
        <li>Jika tidak ada → gunakan <strong>GYS Central Pricing</strong>.</li>
        <li>Setelah scope dipilih, terapkan tier kuantitas (jika ada).</li>
        <li>Harga disnapshot ke pesanan saat dibuat — perubahan harga tidak mengubah pesanan lama.</li>
      </ol>
    </GCard>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari scope…" /></div>
      <select v-model="typeFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Tipe</option>
        <option value="central">Pusat</option>
        <option value="distributor">Distributor</option>
      </select>
      <button v-if="search || typeFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" sortable empty-title="Belum ada pricing scope">
      <template #cell-label="{ row }"><span class="font-medium text-neutral-900">{{ row.label }}</span></template>
      <template #cell-type="{ row }"><GBadge :tone="row.type === 'central' ? 'brand' : 'info'">{{ row.type === 'central' ? 'Pusat' : 'Distributor' }}</GBadge></template>
      <template #cell-notes="{ row }"><span class="text-sm text-neutral-600">{{ row.notes }}</span></template>
      <template #cell-active="{ row }"><GBadge :tone="row.active ? 'success' : 'neutral'">{{ row.active ? 'Aktif' : 'Nonaktif' }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-danger hover:text-red-700 font-medium px-2 py-1" @click.stop="deleteTarget = row">Hapus</button>
        </div>
      </template>
    </GDataTable>

    <GModal :open="showForm" :title="editingId ? 'Ubah Scope' : 'Buat Scope'" @close="showForm = false">
      <div class="space-y-4">
        <div>
          <GLabel for="type">Tipe</GLabel>
          <select id="type" v-model="form.type" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="central">Pusat (GYS)</option>
            <option value="distributor">Distributor</option>
          </select>
        </div>
        <div v-if="form.type === 'distributor'">
          <GLabel for="dist" required>Distributor</GLabel>
          <select id="dist" v-model="form.distributorId" class="w-full h-10 px-3 rounded-md border text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" :class="errors.distributorId ? 'border-danger' : 'border-neutral-300'">
            <option value="">— pilih —</option>
            <option v-for="d in distributors" :key="d.id" :value="d.id">{{ d.legalName }}</option>
          </select>
          <p v-if="errors.distributorId" class="text-xs text-danger mt-1">{{ errors.distributorId }}</p>
        </div>
        <div><GLabel for="label" required>Nama Scope</GLabel><GInput id="label" v-model="form.label" :error="errors.label" placeholder="mis. Harga Khusus Jakarta" /></div>
        <div><GLabel for="notes">Catatan</GLabel><GInput id="notes" v-model="form.notes" placeholder="Opsional" /></div>
        <label class="flex items-center gap-2 text-sm"><input v-model="form.active" type="checkbox" class="rounded border-neutral-300 text-brand-600" /> Aktif</label>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">{{ editingId ? 'Simpan' : 'Buat' }}</GButton>
      </template>
    </GModal>

    <GModal :open="!!deleteTarget" title="Hapus scope?" @close="deleteTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ deleteTarget?.label }}</strong>?</p>
      <template #footer>
        <GButton variant="secondary" @click="deleteTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmDelete">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
