<script setup lang="ts">
import { GButton, GDataTable, GInput, GLabel, GModal, GSummaryCard, GBadge } from '@gys/ui'
import { useUsersStore, ROLE_LABELS, type ManagedUser } from '~/composables/useUsersStore'
import { useToast } from '~/composables/useToast'

const store = useUsersStore()
const toast = useToast()
const loading = ref(true)
const search = ref('')
const roleFilter = ref('all')
const statusFilter = ref('all')

onMounted(async () => { await store.load(); loading.value = false })

const roleOptions = Object.entries(ROLE_LABELS).map(([value, label]) => ({ value, label }))

const filtered = computed(() => {
  let list = store.items
  if (roleFilter.value !== 'all') list = list.filter((u) => u.role === roleFilter.value)
  if (statusFilter.value !== 'all') list = list.filter((u) => u.status === statusFilter.value)
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter((u) => u.name.toLowerCase().includes(q) || u.username.toLowerCase().includes(q) || u.email.toLowerCase().includes(q))
  }
  return list
})
function resetFilters() { search.value = ''; roleFilter.value = 'all'; statusFilter.value = 'all' }

const showForm = ref(false)
const editingId = ref<string | null>(null)
const deleteTarget = ref<ManagedUser | null>(null)
const errors = ref<Record<string, string>>({})
const blank = () => ({ name: '', username: '', email: '', role: 'gys_sales' as ManagedUser['role'], status: 'active' as ManagedUser['status'] })
const form = ref(blank())

function openCreate() { editingId.value = null; errors.value = {}; form.value = blank(); showForm.value = true }
function openEdit(u: ManagedUser) { editingId.value = u.id; errors.value = {}; form.value = { name: u.name, username: u.username, email: u.email, role: u.role, status: u.status }; showForm.value = true }
function save() {
  const e: Record<string, string> = {}
  if (!form.value.name.trim()) e.name = 'Nama wajib diisi'
  if (!form.value.username.trim()) e.username = 'Username wajib diisi'
  if (!form.value.email.trim()) e.email = 'Email wajib diisi'
  errors.value = e
  if (Object.keys(e).length) return
  const payload = { name: form.value.name.trim(), username: form.value.username.trim(), email: form.value.email.trim(), role: form.value.role, status: form.value.status }
  if (editingId.value) { store.update(editingId.value, payload); toast.success('Pengguna diperbarui') }
  else { store.create(payload); toast.success('Pengguna ditambahkan') }
  showForm.value = false
}
function toggleStatus(u: ManagedUser) {
  store.toggleStatus(u.id)
  toast.success(`${u.name} ${u.status === 'active' ? 'dinonaktifkan' : 'diaktifkan'}`)
}
function confirmDelete() {
  if (deleteTarget.value) { store.remove(deleteTarget.value.id); toast.success('Pengguna dihapus') }
  deleteTarget.value = null
}

function roleTone(role: string) {
  if (role.startsWith('gys_')) return 'brand'
  return 'info'
}

const columns = [
  { key: 'name', label: 'Nama', sortable: true },
  { key: 'username', label: 'Username', width: '170px', sortable: true },
  { key: 'role', label: 'Peran', width: '170px', sortable: true },
  { key: 'status', label: 'Status', width: '110px', sortable: true },
  { key: 'actions', label: '', width: '170px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <button class="text-sm text-brand-600 hover:text-brand-700 mb-1" @click="$router.push('/master-data')">← Master Data</button>
        <h1 class="text-2xl font-semibold text-neutral-900">Pengguna & Peran</h1>
      </div>
      <GButton @click="openCreate">+ Tambah Pengguna</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Pengguna" :value="loading ? '…' : store.items.length" icon="◌" tone="brand" />
      <GSummaryCard label="Aktif" :value="loading ? '…' : store.activeCount" icon="✓" tone="success" />
      <GSummaryCard label="Internal GYS" :value="loading ? '…' : store.internalCount" icon="◉" tone="info" />
      <GSummaryCard label="Disuspend" :value="loading ? '…' : store.items.filter((u) => u.status === 'suspended').length" icon="✕" tone="danger" />
    </div>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari nama, username, atau email…" /></div>
      <select v-model="roleFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Peran</option>
        <option v-for="r in roleOptions" :key="r.value" :value="r.value">{{ r.label }}</option>
      </select>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Status</option>
        <option value="active">Aktif</option>
        <option value="suspended">Disuspend</option>
      </select>
      <button v-if="search || roleFilter !== 'all' || statusFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" sortable empty-title="Tidak ada pengguna">
      <template #cell-name="{ row }">
        <div class="flex items-center gap-2">
          <span class="h-8 w-8 rounded-full bg-brand-500 text-white text-xs font-semibold flex items-center justify-center flex-shrink-0">{{ row.name.slice(0,2).toUpperCase() }}</span>
          <div><p class="font-medium text-neutral-900">{{ row.name }}</p><p class="text-xs text-neutral-500">{{ row.email }}</p></div>
        </div>
      </template>
      <template #cell-username="{ row }"><span class="font-mono text-xs text-neutral-600">{{ row.username }}</span></template>
      <template #cell-role="{ row }"><GBadge :tone="roleTone(row.role)">{{ ROLE_LABELS[row.role] }}</GBadge></template>
      <template #cell-status="{ row }"><GBadge :tone="row.status === 'active' ? 'success' : 'danger'">{{ row.status === 'active' ? 'Aktif' : 'Disuspend' }}</GBadge></template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <button class="text-sm text-brand-600 hover:text-brand-700 font-medium px-2 py-1" @click.stop="openEdit(row)">Ubah</button>
          <button class="text-sm text-neutral-500 hover:text-neutral-700 font-medium px-2 py-1" @click.stop="toggleStatus(row)">{{ row.status === 'active' ? 'Suspend' : 'Aktifkan' }}</button>
        </div>
      </template>
    </GDataTable>

    <GModal :open="showForm" :title="editingId ? 'Ubah Pengguna' : 'Tambah Pengguna'" size="lg" @close="showForm = false">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="sm:col-span-2"><GLabel for="name" required>Nama Lengkap</GLabel><GInput id="name" v-model="form.name" :error="errors.name" /></div>
        <div><GLabel for="username" required>Username</GLabel><GInput id="username" v-model="form.username" :error="errors.username" /></div>
        <div><GLabel for="email" required>Email</GLabel><GInput id="email" v-model="form.email" :error="errors.email" /></div>
        <div>
          <GLabel for="role">Peran</GLabel>
          <select id="role" v-model="form.role" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option v-for="r in roleOptions" :key="r.value" :value="r.value">{{ r.label }}</option>
          </select>
        </div>
        <div>
          <GLabel for="status">Status</GLabel>
          <select id="status" v-model="form.status" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="active">Aktif</option>
            <option value="suspended">Disuspend</option>
          </select>
        </div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">{{ editingId ? 'Simpan' : 'Tambah' }}</GButton>
      </template>
    </GModal>

    <GModal :open="!!deleteTarget" title="Hapus pengguna?" @close="deleteTarget = null">
      <p class="text-sm text-neutral-700">Hapus <strong>{{ deleteTarget?.name }}</strong>?</p>
      <template #footer>
        <GButton variant="secondary" @click="deleteTarget = null">Batal</GButton>
        <GButton variant="danger" @click="confirmDelete">Ya, Hapus</GButton>
      </template>
    </GModal>
  </div>
</template>
