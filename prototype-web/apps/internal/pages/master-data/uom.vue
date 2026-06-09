<script setup lang="ts">
import { GButton, GDataTable, GInput, GLabel, GModal, GSummaryCard, GBadge } from '@gys/ui'
import { useUomStore, type Uom } from '~/composables/useUomStore'
import { useToast } from '~/composables/useToast'

const store = useUomStore()
const toast = useToast()
const loading = ref(true)

onMounted(async () => { await store.load(); loading.value = false })

const showForm = ref(false)
const editingId = ref<string | null>(null)
const deleteTarget = ref<Uom | null>(null)
const errors = ref<Record<string, string>>({})
const form = ref({ code: '', name: '', active: true })

function openCreate() { editingId.value = null; errors.value = {}; form.value = { code: '', name: '', active: true }; showForm.value = true }
function openEdit(u: Uom) { editingId.value = u.id; errors.value = {}; form.value = { code: u.code, name: u.name, active: u.active }; showForm.value = true }
function save() {
  const e: Record<string, string> = {}
  if (!form.value.code.trim()) e.code = 'Kode wajib diisi'
  if (!form.value.name.trim()) e.name = 'Nama wajib diisi'
  errors.value = e
  if (Object.keys(e).length) return
  const payload = { code: form.value.code.trim(), name: form.value.name.trim(), active: form.value.active }
  if (editingId.value) { store.update(editingId.value, payload); toast.success('Satuan diperbarui') }
  else { store.create(payload); toast.success('Satuan ditambahkan') }
  showForm.value = false
}
function confirmDelete() {
  if (deleteTarget.value) { store.remove(deleteTarget.value.id); toast.success('Satuan dihapus') }
  deleteTarget.value = null
}

const columns = [
  { key: 'code', label: 'Kode', width: '160px', sortable: true },
  { key: 'name', label: 'Nama', sortable: true },
  { key: 'active', label: 'Status', width: '120px', sortable: true },
  { key: 'actions', label: '', width: '120px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-5xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <button class="text-sm text-brand-600 hover:text-brand-700 mb-1" @click="$router.push('/master-data')">← Master Data</button>
        <h1 class="text-2xl font-semibold text-neutral-900">Satuan (Unit of Measure)</h1>
      </div>
      <GButton @click="openCreate">+ Tambah Satuan</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-3 gap-4">
      <GSummaryCard label="Total Satuan" :value="loading ? '…' : store.items.length" icon="⚖" tone="brand" />
      <GSummaryCard label="Aktif" :value="loading ? '…' : store.items.filter((u) => u.active).length" icon="✓" tone="success" />
      <GSummaryCard label="Nonaktif" :value="loading ? '…' : store.items.filter((u) => !u.active).length" icon="○" tone="neutral" />
    </div>

    <GDataTable :columns="columns" :rows="store.items" :loading="loading" sortable empty-title="Belum ada satuan">
      <template #cell-code="{ row }"><span class="font-mono text-sm text-neutral-700">{{ row.code }}</span></template>
      <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.name }}</span></template>
      <template #cell-active="{ row }"><GBadge :tone="row.active ? 'success' : 'neutral'">{{ row.active ? 'Aktif' : 'Nonaktif' }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-danger hover:text-red-700 font-medium px-2 py-1" @click.stop="deleteTarget = row">Hapus</button>
        </div>
      </template>
    </GDataTable>

    <GModal :open="showForm" :title="editingId ? 'Ubah Satuan' : 'Tambah Satuan'" @close="showForm = false">
      <div class="space-y-4">
        <div><GLabel for="code" required>Kode</GLabel><GInput id="code" v-model="form.code" :error="errors.code" placeholder="mis. batang" /></div>
        <div><GLabel for="name" required>Nama</GLabel><GInput id="name" v-model="form.name" :error="errors.name" placeholder="mis. Batang" /></div>
        <label class="flex items-center gap-2 text-sm"><input v-model="form.active" type="checkbox" class="rounded border-neutral-300 text-brand-600" /> Aktif</label>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">{{ editingId ? 'Simpan' : 'Tambah' }}</GButton>
      </template>
    </GModal>

    <GModal :open="!!deleteTarget" title="Hapus satuan?" @close="deleteTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ deleteTarget?.name }}</strong> ({{ deleteTarget?.code }})?</p>
      <template #footer>
        <GButton variant="secondary" @click="deleteTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmDelete">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
