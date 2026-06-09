<script setup lang="ts">
import { GButton, GDataTable, GInput, GLabel, GModal, GSummaryCard, GBadge } from '@gys/ui'
import { useCatalogStore, type Category } from '~/composables/useCatalogStore'
import { useToast } from '~/composables/useToast'

const store = useCatalogStore()
const toast = useToast()
const loading = ref(true)
const search = ref('')

onMounted(async () => { await store.load(); loading.value = false })

const filtered = computed(() => {
  if (!search.value.trim()) return store.categories
  const q = search.value.toLowerCase()
  return store.categories.filter((c) => c.name.toLowerCase().includes(q) || c.code.toLowerCase().includes(q))
})

const showForm = ref(false)
const editingId = ref<string | null>(null)
const deleteTarget = ref<Category | null>(null)
const errors = ref<Record<string, string>>({})
const form = ref({ code: '', name: '', description: '' })

function openCreate() { editingId.value = null; errors.value = {}; form.value = { code: '', name: '', description: '' }; showForm.value = true }
function openEdit(c: Category) { editingId.value = c.id; errors.value = {}; form.value = { code: c.code, name: c.name, description: c.description ?? '' }; showForm.value = true }
function save() {
  const e: Record<string, string> = {}
  if (!form.value.name.trim()) e.name = 'Nama kategori wajib diisi'
  if (!form.value.code.trim()) e.code = 'Kode wajib diisi'
  errors.value = e
  if (Object.keys(e).length) return
  const payload = { code: form.value.code.trim().toUpperCase(), name: form.value.name.trim(), description: form.value.description.trim() }
  if (editingId.value) { store.updateCategory(editingId.value, payload); toast.success('Kategori diperbarui') }
  else { store.createCategory(payload); toast.success('Kategori ditambahkan') }
  showForm.value = false
}
function confirmDelete() {
  if (deleteTarget.value) {
    if (store.productCountIn(deleteTarget.value.id) > 0) { toast.error('Tidak bisa dihapus: masih ada produk di kategori ini'); deleteTarget.value = null; return }
    store.removeCategory(deleteTarget.value.id); toast.success('Kategori dihapus')
  }
  deleteTarget.value = null
}

const columns = [
  { key: 'code', label: 'Kode', width: '120px', sortable: true },
  { key: 'name', label: 'Nama Kategori', sortable: true },
  { key: 'description', label: 'Deskripsi' },
  { key: 'products', label: 'Produk', align: 'right' as const, width: '110px' },
  { key: 'actions', label: '', width: '120px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-6xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <button class="text-sm text-brand-600 hover:text-brand-700 mb-1" @click="$router.push('/master-data')">← Master Data</button>
        <h1 class="text-2xl font-semibold text-neutral-900">Kategori Produk</h1>
      </div>
      <GButton @click="openCreate">+ Tambah Kategori</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-3 gap-4">
      <GSummaryCard label="Total Kategori" :value="loading ? '…' : store.categories.length" icon="☰" tone="brand" />
      <GSummaryCard label="Total Produk" :value="loading ? '…' : store.products.length" icon="◷" tone="info" />
      <GSummaryCard label="Rata-rata Produk/Kategori" :value="loading ? '…' : (store.categories.length ? Math.round(store.products.length / store.categories.length) : 0)" icon="∼" tone="warning" />
    </div>

    <GInput v-model="search" placeholder="Cari kategori atau kode…" />

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" sortable empty-title="Belum ada kategori">
      <template #cell-code="{ row }"><span class="font-mono text-xs text-neutral-600">{{ row.code }}</span></template>
      <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.name }}</span></template>
      <template #cell-description="{ row }"><span class="text-sm text-neutral-600">{{ row.description || '—' }}</span></template>
      <template #cell-products="{ row }"><GBadge tone="neutral">{{ store.productCountIn(row.id) }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-danger hover:text-red-700 font-medium px-2 py-1" @click.stop="deleteTarget = row">Hapus</button>
        </div>
      </template>
    </GDataTable>

    <GModal :open="showForm" :title="editingId ? 'Ubah Kategori' : 'Tambah Kategori'" @close="showForm = false">
      <div class="space-y-4">
        <div><GLabel for="code" required>Kode</GLabel><GInput id="code" v-model="form.code" :error="errors.code" placeholder="mis. ANG" /></div>
        <div><GLabel for="name" required>Nama Kategori</GLabel><GInput id="name" v-model="form.name" :error="errors.name" placeholder="mis. Besi Siku" /></div>
        <div><GLabel for="desc">Deskripsi</GLabel><GInput id="desc" v-model="form.description" placeholder="Opsional" /></div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">{{ editingId ? 'Simpan' : 'Tambah' }}</GButton>
      </template>
    </GModal>

    <GModal :open="!!deleteTarget" title="Hapus kategori?" @close="deleteTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ deleteTarget?.name }}</strong>? Kategori yang masih dipakai produk tidak dapat dihapus.</p>
      <template #footer>
        <GButton variant="secondary" @click="deleteTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmDelete">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
