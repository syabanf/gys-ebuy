<script setup lang="ts">
import { GBadge, GButton, GDataTable, GInput, GSummaryCard, formatDate, formatDateTime } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useSessionStore } from '~/composables/useSession'

const session = useSessionStore()
const api = useMockApi()
const router = useRouter()

const orders = ref<any[]>([])
const buyers = ref<any[]>([])
const loading = ref(true)
const search = ref('')
const statusFilter = ref('all')

onMounted(async () => {
  const distId = session.distributorId ?? 'dist-001'
  const [o, b] = await Promise.all([api.listOrders({ distributorId: distId }), api.listBuyers()])
  // Only orders that have entered fulfillment are "shipments".
  orders.value = o.filter((x) => ['accepted_by_distributor', 'in_fulfillment', 'shipped', 'delivered', 'completed'].includes(x.status))
  buyers.value = b
  loading.value = false
})

function buyerName(id: string) { return buyers.value.find((b) => b.id === id)?.companyName ?? id }
function tracking(o: any) { return `GYS-SJ-${o.orderNumber.split('-').pop()}` }
function shipStatus(o: any) {
  if (['delivered', 'completed'].includes(o.status)) return { key: 'delivered', label: 'Terkirim', tone: 'success' as const }
  if (o.status === 'shipped') return { key: 'in_transit', label: 'Dalam Perjalanan', tone: 'brand' as const }
  return { key: 'preparing', label: 'Disiapkan', tone: 'warning' as const }
}

const summary = computed(() => ({
  preparing: orders.value.filter((o) => shipStatus(o).key === 'preparing').length,
  inTransit: orders.value.filter((o) => shipStatus(o).key === 'in_transit').length,
  delivered: orders.value.filter((o) => shipStatus(o).key === 'delivered').length,
  total: orders.value.length,
}))

const filtered = computed(() => {
  let list = orders.value
  if (statusFilter.value !== 'all') list = list.filter((o) => shipStatus(o).key === statusFilter.value)
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter((o) => o.orderNumber.toLowerCase().includes(q) || tracking(o).toLowerCase().includes(q) || buyerName(o.buyerId).toLowerCase().includes(q))
  }
  return list
})

function resetFilters() { search.value = ''; statusFilter.value = 'all' }

const columns = [
  { key: 'tracking', label: 'No. Surat Jalan', width: '160px' },
  { key: 'orderNumber', label: 'Pesanan' },
  { key: 'buyer', label: 'Tujuan' },
  { key: 'shippedAt', label: 'Dikirim', width: '150px' },
  { key: 'eta', label: 'Estimasi/Terkirim', width: '150px' },
  { key: 'status', label: 'Status', width: '150px' },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Pengiriman</h1>
        <p class="text-sm text-neutral-500 mt-1">Pantau surat jalan dan status pengiriman.</p>
      </div>
      <GButton variant="secondary">Buat Surat Jalan</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Disiapkan" :value="loading ? '…' : summary.preparing" icon="◷" tone="warning" />
      <GSummaryCard label="Dalam Perjalanan" :value="loading ? '…' : summary.inTransit" icon="✈" tone="brand" />
      <GSummaryCard label="Terkirim" :value="loading ? '…' : summary.delivered" icon="✓" tone="success" />
      <GSummaryCard label="Total" :value="loading ? '…' : summary.total" icon="☷" tone="info" />
    </div>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari surat jalan, pesanan, atau tujuan…" /></div>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Status</option>
        <option value="preparing">Disiapkan</option>
        <option value="in_transit">Dalam Perjalanan</option>
        <option value="delivered">Terkirim</option>
      </select>
      <button v-if="search || statusFilter !== 'all'" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ filtered.length }} pengiriman ditampilkan</p>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" row-key="id" empty-title="Tidak ada pengiriman" empty-description="Pengiriman muncul setelah pesanan diproses." @row-click="(row) => router.push(`/orders/${row.id}`)">
      <template #cell-tracking="{ row }"><span class="font-mono text-xs text-brand-700">{{ tracking(row) }}</span></template>
      <template #cell-orderNumber="{ row }"><span class="font-medium text-neutral-900">{{ row.orderNumber }}</span></template>
      <template #cell-buyer="{ row }">{{ buyerName(row.buyerId) }}</template>
      <template #cell-shippedAt="{ row }"><span class="text-neutral-600 text-sm">{{ row.shippedAt ? formatDateTime(row.shippedAt) : '—' }}</span></template>
      <template #cell-eta="{ row }"><span class="text-neutral-600 text-sm">{{ row.deliveredAt ? formatDate(row.deliveredAt) : 'Diproses' }}</span></template>
      <template #cell-status="{ row }"><GBadge :tone="shipStatus(row).tone">{{ shipStatus(row).label }}</GBadge></template>
    </GDataTable>
  </div>
</template>
