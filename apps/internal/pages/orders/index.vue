<script setup lang="ts">
import { GBadge, GButton, GCard, GDataTable, GDrawer, GInput, GSummaryCard, formatIDR, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useToast } from '~/composables/useToast'

const api = useMockApi()
const router = useRouter()
const toast = useToast()
const orders = ref<any[]>([])
const distributors = ref<any[]>([])
const buyers = ref<any[]>([])
const productsMap = ref<Record<string, any>>({})
const loading = ref(true)
const distributorFilter = ref('all')
const statusFilter = ref('all')
const periodFilter = ref('all')
const search = ref('')
const TODAY = new Date('2026-06-09T23:59:59+07:00')

onMounted(async () => {
  const [o, d, b, p] = await Promise.all([api.listOrders(), api.listDistributors(), api.listBuyers(), api.listProducts()])
  orders.value = o
  distributors.value = d
  buyers.value = b
  productsMap.value = Object.fromEntries(p.map((x) => [x.id, x]))
  loading.value = false
})

// ---- Quick-view drawer (no page navigation) ----
const drawerOrder = ref<any>(null)
const statusValues: OrderStatus[] = ['pending_payment', 'paid', 'accepted_by_distributor', 'in_fulfillment', 'shipped', 'delivered', 'completed', 'cancelled']
function openDrawer(o: any) { drawerOrder.value = o }
function updateStatus(s: string) {
  const o = drawerOrder.value
  if (!o || o.status === s) return
  o.status = s
  const now = new Date().toISOString()
  if (s === 'shipped' && !o.shippedAt) o.shippedAt = now
  if (s === 'delivered' && !o.deliveredAt) o.deliveredAt = now
  if (s === 'completed' && !o.completedAt) o.completedAt = now
  toast.success(`Status ${o.orderNumber} → ${statusLabel(s as OrderStatus)}`)
}
function printInvoice() {
  const o = drawerOrder.value
  if (!o) return
  const buyer = buyers.value.find((b) => b.id === o.buyerId)
  const rows = o.items.map((it: any) => `<tr><td>${productsMap.value[it.productId]?.name ?? ''}<br><span class="muted">${productsMap.value[it.productId]?.sku ?? ''}</span></td><td class="r">${it.qty}</td><td class="r">${formatIDR(it.unitPrice)}</td><td class="r">${formatIDR(it.subtotal)}</td></tr>`).join('')
  printHtml(`Invoice ${o.orderNumber}`, `
    <div class="head"><div style="display:flex;gap:10px;align-items:center"><div class="logo">GYS</div><div><strong>PT Garuda Yamato Steel</strong><div class="muted">garudayamatosteel.com</div></div></div>
      <div style="text-align:right"><h1>INVOICE</h1><div class="muted">${o.orderNumber}</div><div class="muted">${formatDateTime(o.placedAt)}</div></div></div>
    <div class="grid"><div><h3>Ditagihkan ke</h3><strong>${buyer?.companyName ?? ''}</strong><div class="muted">${buyer?.address ?? ''}</div></div>
      <div><h3>Status</h3>${statusLabel(o.status as OrderStatus)}<div class="muted">${distName(o.distributorId)}</div></div></div>
    <table><thead><tr><th>Produk</th><th class="r">Qty</th><th class="r">Harga</th><th class="r">Subtotal</th></tr></thead><tbody>${rows}</tbody>
      <tfoot><tr><td colspan="3" class="r">Subtotal</td><td class="r">${formatIDR(o.subtotal)}</td></tr>
      <tr><td colspan="3" class="r">Biaya Kirim</td><td class="r">${formatIDR(o.shippingFee)}</td></tr>
      <tr><td colspan="3" class="r tot">Total</td><td class="r tot">${formatIDR(o.total)}</td></tr></tfoot></table>`)
}

function distName(id: string | null) {
  if (!id) return 'GYS Langsung'
  return distributors.value.find((d) => d.id === id)?.legalName ?? id
}
function buyerName(id: string) {
  return buyers.value.find((b) => b.id === id)?.companyName ?? id
}

const summary = computed(() => ({
  total: orders.value.length,
  inFlight: orders.value.filter((o) => ['paid', 'accepted_by_distributor', 'in_fulfillment', 'shipped'].includes(o.status)).length,
  done: orders.value.filter((o) => ['delivered', 'completed'].includes(o.status)).length,
  revenue: orders.value.filter((o) => ['delivered', 'completed'].includes(o.status)).reduce((s, o) => s + o.total, 0),
}))

const filtered = computed(() => {
  let rows = orders.value
  if (distributorFilter.value === 'gys_direct') rows = rows.filter((o) => o.fulfillmentType === 'gys_direct')
  else if (distributorFilter.value !== 'all') rows = rows.filter((o) => o.distributorId === distributorFilter.value)
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

function resetFilters() { distributorFilter.value = 'all'; statusFilter.value = 'all'; periodFilter.value = 'all'; search.value = '' }

function exportCsv() {
  const rows = filtered.value.map((o) => ({
    orderNumber: o.orderNumber, buyer: buyerName(o.buyerId), fulfillment: distName(o.distributorId),
    date: formatDateTime(o.placedAt), total: o.total, status: statusLabel(o.status as OrderStatus),
  }))
  downloadCsv(`pesanan-${rows.length}.csv`, rows, [
    { key: 'orderNumber', label: 'No. Pesanan' }, { key: 'buyer', label: 'Pembeli' }, { key: 'fulfillment', label: 'Fulfillment' },
    { key: 'date', label: 'Tanggal' }, { key: 'total', label: 'Total' }, { key: 'status', label: 'Status' },
  ])
  toast.success(`${rows.length} pesanan diekspor ke CSV`)
}

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

const columns = [
  { key: 'orderNumber', label: 'No. Pesanan' },
  { key: 'buyer', label: 'Pembeli' },
  { key: 'distributor', label: 'Fulfillment' },
  { key: 'placedAt', label: 'Tanggal', width: '160px' },
  { key: 'total', label: 'Total', align: 'right' as const, width: '150px' },
  { key: 'status', label: 'Status', width: '160px' },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Pesanan</h1>
        <p class="text-sm text-neutral-500 mt-1">Monitoring semua pesanan di platform.</p>
      </div>
      <GButton variant="secondary" @click="exportCsv">Ekspor CSV</GButton>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GSummaryCard label="Total Pesanan" :value="loading ? '…' : summary.total" icon="◫" tone="brand" />
      <GSummaryCard label="Berjalan" :value="loading ? '…' : summary.inFlight" icon="◷" tone="info" />
      <GSummaryCard label="Selesai" :value="loading ? '…' : summary.done" icon="✓" tone="success" />
      <GSummaryCard label="Pendapatan" :value="loading ? '…' : formatIDR(summary.revenue)" icon="◉" tone="warning" />
    </div>

    <div class="flex flex-col sm:flex-row gap-3">
      <div class="flex-1"><GInput v-model="search" placeholder="Cari no. pesanan atau pembeli…" /></div>
      <select v-model="statusFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option v-for="o in statusOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
      </select>
      <select v-model="distributorFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Fulfillment</option>
        <option value="gys_direct">GYS Langsung</option>
        <option v-for="d in distributors" :key="d.id" :value="d.id">{{ d.legalName }}</option>
      </select>
      <select v-model="periodFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
        <option value="all">Semua Tanggal</option>
        <option value="7">7 hari terakhir</option>
        <option value="30">30 hari terakhir</option>
        <option value="90">90 hari terakhir</option>
      </select>
      <button v-if="statusFilter !== 'all' || distributorFilter !== 'all' || periodFilter !== 'all' || search" class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
    </div>

    <p class="text-sm text-neutral-500">{{ filtered.length }} pesanan ditampilkan</p>

    <GDataTable :columns="columns" :rows="filtered" :loading="loading" empty-title="Tidak ada pesanan" empty-description="Coba ubah filter." @row-click="openDrawer">
      <template #cell-orderNumber="{ row }"><span class="font-medium text-neutral-900">{{ row.orderNumber }}</span></template>
      <template #cell-buyer="{ row }">{{ buyerName(row.buyerId) }}</template>
      <template #cell-distributor="{ row }"><span class="text-neutral-600">{{ distName(row.distributorId) }}</span></template>
      <template #cell-placedAt="{ row }"><span class="text-neutral-600 text-sm">{{ formatDateTime(row.placedAt) }}</span></template>
      <template #cell-total="{ row }"><span class="font-semibold">{{ formatIDR(row.total) }}</span></template>
      <template #cell-status="{ row }"><GBadge :tone="statusTone(row.status as OrderStatus)">{{ statusLabel(row.status as OrderStatus) }}</GBadge></template>
    </GDataTable>

    <!-- Quick-view drawer -->
    <GDrawer :open="!!drawerOrder" :title="drawerOrder?.orderNumber" :subtitle="drawerOrder ? formatDateTime(drawerOrder.placedAt) : ''" @close="drawerOrder = null">
      <template v-if="drawerOrder">
        <div class="space-y-5">
          <div class="flex items-center gap-2">
            <GBadge :tone="statusTone(drawerOrder.status as OrderStatus)" size="md">{{ statusLabel(drawerOrder.status as OrderStatus) }}</GBadge>
            <span class="text-sm text-neutral-500">{{ drawerOrder.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor' }}</span>
          </div>

          <div class="grid grid-cols-2 gap-3 text-sm">
            <div><p class="text-xs text-neutral-500">Pembeli</p><p class="font-medium">{{ buyerName(drawerOrder.buyerId) }}</p></div>
            <div><p class="text-xs text-neutral-500">Fulfillment</p><p class="font-medium">{{ distName(drawerOrder.distributorId) }}</p></div>
          </div>

          <div>
            <p class="text-xs font-medium text-neutral-500 mb-1.5">Ubah Status</p>
            <select :value="drawerOrder.status" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" @change="updateStatus(($event.target as HTMLSelectElement).value)">
              <option v-for="s in statusValues" :key="s" :value="s">{{ statusLabel(s) }}</option>
            </select>
          </div>

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
        <GButton variant="secondary" icon="⎙" @click="printInvoice">Cetak Invoice</GButton>
        <GButton class="ml-auto" @click="router.push(`/orders/${drawerOrder.id}`)">Halaman lengkap →</GButton>
      </template>
    </GDrawer>
  </div>
</template>
