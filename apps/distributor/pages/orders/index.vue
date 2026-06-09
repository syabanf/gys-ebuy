<script setup lang="ts">
import { GBadge, GButton, GDataTable, GDrawer, GInput, GSummaryCard, formatIDR, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useSessionStore } from '~/composables/useSession'
import { useToast } from '~/composables/useToast'

const session = useSessionStore()
const api = useMockApi()
const router = useRouter()
const toast = useToast()

const orders = ref<any[]>([])
const buyers = ref<any[]>([])
const productsMap = ref<Record<string, any>>({})
const loading = ref(true)
const statusFilter = ref<string>('all')
const periodFilter = ref('all')
const search = ref('')
const TODAY = new Date('2026-06-09T23:59:59+07:00')

onMounted(async () => {
  const distId = session.distributorId ?? 'dist-001'
  const [o, b, p] = await Promise.all([api.listOrders({ distributorId: distId }), api.listBuyers(), api.listProducts()])
  orders.value = o
  buyers.value = b
  productsMap.value = Object.fromEntries(p.map((x) => [x.id, x]))
  loading.value = false
})

// ---- Quick-view drawer (process without leaving the list) ----
const drawerOrder = ref<any>(null)
function openDrawer(o: any) { drawerOrder.value = o }
function accept() {
  if (drawerOrder.value) { drawerOrder.value.status = 'accepted_by_distributor'; toast.success(`${drawerOrder.value.orderNumber} diterima`) }
}
function markShipped() {
  if (drawerOrder.value) { drawerOrder.value.status = 'shipped'; drawerOrder.value.shippedAt = new Date().toISOString(); toast.success(`${drawerOrder.value.orderNumber} ditandai dikirim`) }
}

function buyerName(buyerId: string) {
  return buyers.value.find((b) => b.id === buyerId)?.companyName ?? '—'
}

// Summary (over all orders, not filtered)
const summary = computed(() => ({
  total: orders.value.length,
  processing: orders.value.filter((o) => ['paid', 'accepted_by_distributor', 'in_fulfillment'].includes(o.status)).length,
  shipped: orders.value.filter((o) => o.status === 'shipped').length,
  revenue: orders.value.filter((o) => ['delivered', 'completed'].includes(o.status)).reduce((s, o) => s + o.total, 0),
}))

const filteredOrders = computed(() => {
  let rows = orders.value
  if (statusFilter.value !== 'all') rows = rows.filter((o) => o.status === statusFilter.value)
  if (periodFilter.value !== 'all') {
    const cutoff = new Date(TODAY.getTime() - Number(periodFilter.value) * 86400000)
    rows = rows.filter((o) => new Date(o.placedAt) >= cutoff)
  }
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    rows = rows.filter((o) => o.orderNumber.toLowerCase().includes(q) || buyerName(o.buyerId).toLowerCase().includes(q))
  }
  return rows
})

const columns = [
  { key: 'orderNumber', label: 'No. Pesanan' },
  { key: 'buyer', label: 'Pembeli' },
  { key: 'placedAt', label: 'Tanggal' },
  { key: 'items', label: 'Item', align: 'right' as const },
  { key: 'total', label: 'Total', align: 'right' as const },
  { key: 'status', label: 'Status' },
]

const statusOptions = [
  { value: 'all', label: 'Semua Status' },
  { value: 'pending_payment', label: 'Menunggu Pembayaran' },
  { value: 'paid', label: 'Sudah Dibayar' },
  { value: 'accepted_by_distributor', label: 'Diterima' },
  { value: 'in_fulfillment', label: 'Dalam Proses' },
  { value: 'shipped', label: 'Dikirim' },
  { value: 'delivered', label: 'Terkirim' },
  { value: 'completed', label: 'Selesai' },
  { value: 'cancelled', label: 'Dibatalkan' },
]

function resetFilters() {
  statusFilter.value = 'all'
  periodFilter.value = 'all'
  search.value = ''
}
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-neutral-900">Pesanan</h1>
      <p class="text-sm text-neutral-500 mt-1">Kelola dan pantau pesanan masuk.</p>
    </div>

    <!-- Summary cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Pesanan" :value="loading ? '…' : summary.total" icon="◫" tone="brand" />
      <GSummaryCard label="Perlu Diproses" :value="loading ? '…' : summary.processing" icon="◷" tone="info" />
      <GSummaryCard label="Dikirim" :value="loading ? '…' : summary.shipped" icon="✈" tone="warning" />
      <GSummaryCard label="Pendapatan" :value="loading ? '…' : formatIDR(summary.revenue)" icon="◉" tone="success" />
    </div>

    <!-- Filters -->
    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1">
        <GInput v-model="search" placeholder="Cari no. pesanan atau nama pembeli…" />
      </div>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option v-for="o in statusOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
      </select>
      <select v-model="periodFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Tanggal</option>
        <option value="7">7 hari terakhir</option>
        <option value="30">30 hari terakhir</option>
        <option value="90">90 hari terakhir</option>
      </select>
      <button v-if="statusFilter !== 'all' || periodFilter !== 'all' || search" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <div class="flex items-center justify-between">
      <p class="text-sm text-neutral-500">{{ filteredOrders.length }} pesanan ditampilkan</p>
    </div>

    <GDataTable
      :columns="columns" :rows="filteredOrders" :loading="loading"
      empty-title="Tidak ada pesanan" empty-description="Coba ubah filter atau kata kunci pencarian."
      @row-click="openDrawer"
    >
      <template #cell-orderNumber="{ row }"><span class="font-medium text-neutral-900">{{ row.orderNumber }}</span></template>
      <template #cell-buyer="{ row }">{{ buyerName(row.buyerId) }}</template>
      <template #cell-placedAt="{ row }"><span class="text-neutral-600">{{ formatDateTime(row.placedAt) }}</span></template>
      <template #cell-items="{ row }"><span class="text-neutral-600">{{ row.items.length }}</span></template>
      <template #cell-total="{ row }"><span class="font-semibold">{{ formatIDR(row.total) }}</span></template>
      <template #cell-status="{ row }"><GBadge :tone="statusTone(row.status as OrderStatus)">{{ statusLabel(row.status as OrderStatus) }}</GBadge></template>
    </GDataTable>

    <!-- Quick-view & process drawer -->
    <GDrawer :open="!!drawerOrder" :title="drawerOrder?.orderNumber" :subtitle="drawerOrder ? formatDateTime(drawerOrder.placedAt) : ''" @close="drawerOrder = null">
      <template v-if="drawerOrder">
        <div class="space-y-5">
          <GBadge :tone="statusTone(drawerOrder.status as OrderStatus)" size="md">{{ statusLabel(drawerOrder.status as OrderStatus) }}</GBadge>

          <div class="text-sm"><p class="text-xs text-neutral-500">Pembeli</p><p class="font-medium">{{ buyerName(drawerOrder.buyerId) }}</p></div>

          <div>
            <p class="text-xs font-medium text-neutral-500 mb-2">Item ({{ drawerOrder.items.length }})</p>
            <ul class="divide-y divide-neutral-100 border border-neutral-200 rounded-lg overflow-hidden">
              <li v-for="it in drawerOrder.items" :key="it.productId" class="px-3 py-2.5 flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <p class="text-sm font-medium text-neutral-900 truncate">{{ productsMap[it.productId]?.name ?? it.productId }}</p>
                  <p class="text-xs text-neutral-500">{{ it.qty }} × {{ formatIDR(it.unitPrice) }}</p>
                </div>
                <span class="text-sm font-semibold flex-shrink-0">{{ formatIDR(it.subtotal) }}</span>
              </li>
            </ul>
          </div>

          <div class="space-y-1 text-sm border-t border-neutral-100 pt-3">
            <div class="flex justify-between text-neutral-500"><span>Subtotal</span><span>{{ formatIDR(drawerOrder.subtotal) }}</span></div>
            <div class="flex justify-between text-neutral-500"><span>Biaya Kirim</span><span>{{ formatIDR(drawerOrder.shippingFee) }}</span></div>
            <div class="flex justify-between font-semibold text-base text-neutral-900 pt-1"><span>Total</span><span>{{ formatIDR(drawerOrder.total) }}</span></div>
          </div>
        </div>
      </template>
      <template #footer>
        <GButton v-if="drawerOrder?.status === 'paid'" @click="accept">Terima Pesanan</GButton>
        <GButton v-else-if="['accepted_by_distributor','in_fulfillment'].includes(drawerOrder?.status)" @click="markShipped">Tandai Dikirim</GButton>
        <GButton variant="secondary" class="ml-auto" @click="router.push(`/orders/${drawerOrder.id}`)">Halaman lengkap →</GButton>
      </template>
    </GDrawer>
  </div>
</template>
