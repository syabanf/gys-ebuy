<script setup lang="ts">
import { GBadge, GButton, GDataTable, GInput, GSummaryCard, formatDate } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'

const api = useMockApi()
const router = useRouter()
const all = ref<any[]>([])
const loading = ref(true)
const tab = ref<'pending' | 'approved' | 'rejected'>('pending')
const search = ref('')
const typeFilter = ref('all')

onMounted(async () => {
  all.value = await api.listBuyers()
  loading.value = false
})

const summary = computed(() => ({
  pending: all.value.filter((b) => b.approvalStatus === 'pending').length,
  approved: all.value.filter((b) => b.approvalStatus === 'approved').length,
  rejected: all.value.filter((b) => b.approvalStatus === 'rejected').length,
  total: all.value.length,
}))

const filtered = computed(() => {
  let list = all.value.filter((b) => b.approvalStatus === tab.value)
  if (typeFilter.value !== 'all') list = list.filter((b) => b.businessType === typeFilter.value)
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter((b) => b.companyName.toLowerCase().includes(q) || (b.npwp ?? '').toLowerCase().includes(q))
  }
  return list
})

function resetFilters() { search.value = ''; typeFilter.value = 'all' }

function businessTypeLabel(t: string) {
  return ({ fabricator: 'Fabrikator', contractor: 'Kontraktor', retailer: 'Retail', 'sub-distributor': 'Sub-Distributor' } as Record<string, string>)[t] ?? t
}

const columns = [
  { key: 'companyName', label: 'Nama Perusahaan' },
  { key: 'businessType', label: 'Tipe Bisnis', width: '160px' },
  { key: 'contactName', label: 'Kontak', width: '180px' },
  { key: 'submittedAt', label: 'Diajukan', width: '140px' },
  { key: 'docs', label: 'Dokumen', width: '110px', align: 'center' as const },
  { key: 'action', label: '', width: '110px', align: 'right' as const },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-neutral-900">Persetujuan Pembeli</h1>
      <p class="text-sm text-neutral-500 mt-1">Tinjau dan setujui pendaftaran pembeli baru.</p>
    </div>

    <!-- Summary cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Menunggu" :value="loading ? '…' : summary.pending" icon="◷" tone="warning" />
      <GSummaryCard label="Disetujui" :value="loading ? '…' : summary.approved" icon="✓" tone="success" />
      <GSummaryCard label="Ditolak" :value="loading ? '…' : summary.rejected" icon="✕" tone="danger" />
      <GSummaryCard label="Total Pendaftar" :value="loading ? '…' : summary.total" icon="☰" tone="brand" />
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 border-b border-neutral-200">
      <button
        v-for="t in (['pending', 'approved', 'rejected'] as const)"
        :key="t"
        :class="['px-4 py-2 text-sm font-medium transition-colors border-b-2 -mb-px', tab === t ? 'border-brand-500 text-brand-700' : 'border-transparent text-neutral-500 hover:text-neutral-700']"
        @click="tab = t"
      >
        {{ ({ pending: 'Menunggu', approved: 'Disetujui', rejected: 'Ditolak' } as Record<string, string>)[t] }}
      </button>
    </div>

    <!-- Filters -->
    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari perusahaan atau NPWP…" /></div>
      <select v-model="typeFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Tipe Bisnis</option>
        <option value="fabricator">Fabrikator</option>
        <option value="contractor">Kontraktor</option>
        <option value="retailer">Retail</option>
        <option value="sub-distributor">Sub-Distributor</option>
      </select>
      <button v-if="search || typeFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ filtered.length }} pendaftar ditampilkan</p>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" empty-title="Tidak ada pendaftaran" empty-description="Coba ubah filter atau tab." @row-click="(row) => router.push(`/buyer-approvals/${row.id}`)">
      <template #cell-companyName="{ row }">
        <div><p class="font-medium text-neutral-900">{{ row.companyName }}</p><p class="text-xs text-neutral-500 mt-0.5">NPWP: {{ row.npwp }}</p></div>
      </template>
      <template #cell-businessType="{ row }"><GBadge tone="neutral">{{ businessTypeLabel(row.businessType) }}</GBadge></template>
      <template #cell-contactName="{ row }">
        <div><p class="text-sm text-neutral-900">{{ row.contactName }}</p><p class="text-xs text-neutral-500">{{ row.phone }}</p></div>
      </template>
      <template #cell-submittedAt="{ row }"><span class="text-sm text-neutral-600">{{ formatDate(row.submittedAt ?? row.approvedAt ?? '') }}</span></template>
      <template #cell-docs="{ row }"><span class="text-sm">{{ row.kycDocs.length }} berkas</span></template>
      <template #cell-action="{ row }"><GButton size="sm" variant="secondary" @click.stop="router.push(`/buyer-approvals/${row.id}`)">Tinjau</GButton></template>
    </GDataTable>
  </div>
</template>
