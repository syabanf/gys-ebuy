<script setup lang="ts">
import { GBadge, GButton, GCard, GInput, GLabel, GModal, GSummaryCard, formatDate } from '@gys/ui'
import { useDistributorsStore } from '~/composables/useDistributorsStore'
import { useToast } from '~/composables/useToast'

const store = useDistributorsStore()
const router = useRouter()
const toast = useToast()
const loading = ref(true)
const search = ref('')
const statusFilter = ref('all')
const provinceFilter = ref('all')

onMounted(async () => { await store.load(); loading.value = false })

const summary = computed(() => {
  const areas = new Set<string>()
  store.list.forEach((d) => d.serviceAreas.forEach((a) => areas.add(a)))
  return { total: store.list.length, active: store.activeCount, provinces: store.provinces.length, areas: areas.size }
})

const filtered = computed(() => {
  let list = store.list
  if (statusFilter.value !== 'all') list = list.filter((d) => d.status === statusFilter.value)
  if (provinceFilter.value !== 'all') list = list.filter((d) => d.province === provinceFilter.value)
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter((d) => d.legalName.toLowerCase().includes(q) || d.city.toLowerCase().includes(q) || d.code.toLowerCase().includes(q))
  }
  return list
})
function resetFilters() { search.value = ''; statusFilter.value = 'all'; provinceFilter.value = 'all' }

// Onboard
const showForm = ref(false)
const errors = ref<Record<string, string>>({})
const form = ref({ legalName: '', city: '', province: '', npwp: '', contactName: '', phone: '', email: '', serviceAreas: '' })
function openCreate() { errors.value = {}; form.value = { legalName: '', city: '', province: '', npwp: '', contactName: '', phone: '', email: '', serviceAreas: '' }; showForm.value = true }
function save() {
  const e: Record<string, string> = {}
  if (!form.value.legalName.trim()) e.legalName = 'Nama wajib diisi'
  if (!form.value.city.trim()) e.city = 'Kota wajib diisi'
  if (!form.value.province.trim()) e.province = 'Provinsi wajib diisi'
  errors.value = e
  if (Object.keys(e).length) return
  store.create({
    legalName: form.value.legalName.trim(), city: form.value.city.trim(), province: form.value.province.trim(),
    npwp: form.value.npwp.trim(), contactName: form.value.contactName.trim(), phone: form.value.phone.trim(), email: form.value.email.trim(),
    serviceAreas: form.value.serviceAreas.split(',').map((s) => s.trim()).filter(Boolean),
  })
  toast.success(`Distributor "${form.value.legalName}" berhasil di-onboard`)
  showForm.value = false
}
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Distributor</h1>
        <p class="text-sm text-neutral-500 mt-1">Kelola jaringan distributor GYS.</p>
      </div>
      <GButton @click="openCreate">+ Onboard Distributor Baru</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Distributor" :value="loading ? '…' : summary.total" icon="◰" tone="brand" />
      <GSummaryCard label="Aktif" :value="loading ? '…' : summary.active" icon="✓" tone="success" />
      <GSummaryCard label="Provinsi Terlayani" :value="loading ? '…' : summary.provinces" icon="◈" tone="info" />
      <GSummaryCard label="Wilayah Layanan" :value="loading ? '…' : summary.areas" icon="☷" tone="warning" />
    </div>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari nama, kota, atau kode…" /></div>
      <select v-model="provinceFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Provinsi</option>
        <option v-for="p in store.provinces" :key="p" :value="p">{{ p }}</option>
      </select>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Status</option>
        <option value="active">Aktif</option>
        <option value="inactive">Nonaktif</option>
      </select>
      <button v-if="search || statusFilter !== 'all' || provinceFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ filtered.length }} distributor ditampilkan</p>

    <div v-if="loading" class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <div v-for="i in 4" :key="i" class="h-40 bg-neutral-100 rounded-lg animate-pulse" />
    </div>
    <div v-else-if="filtered.length === 0" class="text-center py-12 text-sm text-neutral-500">Tidak ada distributor yang cocok.</div>
    <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <GCard v-for="d in filtered" :key="d.id">
        <div class="flex items-start justify-between gap-4">
          <div class="min-w-0 flex-1">
            <div class="flex items-center gap-2">
              <h2 class="text-base font-semibold text-neutral-900 truncate">{{ d.legalName }}</h2>
              <GBadge :tone="d.status === 'active' ? 'success' : 'neutral'">{{ d.status === 'active' ? 'Aktif' : d.status }}</GBadge>
            </div>
            <p class="text-sm text-neutral-500 mt-0.5">{{ d.code }} · {{ d.city }}, {{ d.province }}</p>
            <dl class="mt-4 grid grid-cols-2 gap-y-2 gap-x-4 text-sm">
              <div><dt class="text-neutral-500 text-xs">PIC</dt><dd class="font-medium">{{ d.contact.name || '—' }}</dd></div>
              <div><dt class="text-neutral-500 text-xs">Bergabung</dt><dd class="font-medium">{{ formatDate(d.joinedAt) }}</dd></div>
              <div class="col-span-2"><dt class="text-neutral-500 text-xs">Wilayah Layanan</dt>
                <dd class="font-medium"><span v-for="area in d.serviceAreas" :key="area" class="inline-block mr-2">{{ area }}</span></dd>
              </div>
            </dl>
          </div>
          <div class="flex flex-col gap-2 flex-shrink-0">
            <GButton size="sm" variant="secondary" @click="router.push(`/distributors/${d.id}`)">Detail</GButton>
            <GButton size="sm" variant="ghost">Pricing</GButton>
          </div>
        </div>
      </GCard>
    </div>

    <GModal :open="showForm" title="Onboard Distributor Baru" size="lg" @close="showForm = false">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="sm:col-span-2"><GLabel for="ln" required>Nama Perusahaan</GLabel><GInput id="ln" v-model="form.legalName" :error="errors.legalName" placeholder="PT / CV …" /></div>
        <div><GLabel for="city" required>Kota</GLabel><GInput id="city" v-model="form.city" :error="errors.city" /></div>
        <div><GLabel for="prov" required>Provinsi</GLabel><GInput id="prov" v-model="form.province" :error="errors.province" /></div>
        <div><GLabel for="npwp">NPWP</GLabel><GInput id="npwp" v-model="form.npwp" /></div>
        <div><GLabel for="pic">Nama PIC</GLabel><GInput id="pic" v-model="form.contactName" /></div>
        <div><GLabel for="ph">Telepon</GLabel><GInput id="ph" v-model="form.phone" /></div>
        <div><GLabel for="em">Email</GLabel><GInput id="em" v-model="form.email" /></div>
        <div class="sm:col-span-2"><GLabel for="sa">Wilayah Layanan (pisah dengan koma)</GLabel><GInput id="sa" v-model="form.serviceAreas" placeholder="DKI Jakarta, Banten" /></div>
      </div>
      <template #footer>
        <GButton variant="secondary" @click="showForm = false">Batal</GButton>
        <GButton @click="save">Onboard</GButton>
      </template>
    </GModal>
  </div>
</template>
