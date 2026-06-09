<script setup lang="ts">
import {
  GButton, GCard, GSummaryCard, GDataTable, GLineChart, GBarChart, GDonutChart,
  formatIDR, chartColors,
} from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useToast } from '~/composables/useToast'

const api = useMockApi()
const toast = useToast()
const orders = ref<any[]>([])
const distributors = ref<any[]>([])
const buyers = ref<any[]>([])
const products = ref<Record<string, any>>({})
const loading = ref(true)

const TODAY = new Date('2026-06-09T23:59:59+07:00')
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']

const period = ref<'all' | '30' | '90' | 'custom'>('all')
const fromDate = ref('')
const toDate = ref('')
const distributorFilter = ref('all')
const fulfillmentFilter = ref('all')

onMounted(async () => {
  const [o, d, b, p] = await Promise.all([api.listOrders(), api.listDistributors(), api.listBuyers(), api.listProducts()])
  orders.value = o
  distributors.value = d
  buyers.value = b
  products.value = Object.fromEntries(p.map((x) => [x.id, x]))
  loading.value = false
})

const range = computed(() => {
  if (period.value === 'all') return null
  if (period.value === 'custom') {
    return { from: fromDate.value ? new Date(fromDate.value) : null, to: toDate.value ? new Date(`${toDate.value}T23:59:59`) : null }
  }
  const days = Number(period.value)
  return { from: new Date(TODAY.getTime() - days * 86400000), to: TODAY }
})

const scoped = computed(() => {
  let list = orders.value
  const r = range.value
  if (r) {
    list = list.filter((o) => {
      const d = new Date(o.placedAt)
      if (r.from && d < r.from) return false
      if (r.to && d > r.to) return false
      return true
    })
  }
  if (fulfillmentFilter.value === 'gys_direct') list = list.filter((o) => o.fulfillmentType === 'gys_direct')
  else if (fulfillmentFilter.value === 'distributor') list = list.filter((o) => o.fulfillmentType === 'via_distributor')
  if (distributorFilter.value !== 'all') list = list.filter((o) => o.distributorId === distributorFilter.value)
  return list
})

const completed = computed(() => scoped.value.filter((o) => ['completed', 'delivered'].includes(o.status)))
const revenue = computed(() => completed.value.reduce((s, o) => s + o.total, 0))
const aov = computed(() => completed.value.length ? Math.round(revenue.value / completed.value.length) : 0)
const cancelRate = computed(() => scoped.value.length ? (scoped.value.filter((o) => o.status === 'cancelled').length / scoped.value.length) * 100 : 0)
const itemsSold = computed(() => completed.value.reduce((s, o) => s + (o.items ?? []).reduce((a: number, it: any) => a + it.qty, 0), 0))

const monthlyTrend = computed(() => {
  const map = new Map<string, number>()
  for (const o of completed.value) {
    const d = new Date(o.placedAt)
    const key = `${d.getFullYear()}-${String(d.getMonth()).padStart(2, '0')}`
    map.set(key, (map.get(key) ?? 0) + o.total)
  }
  const keys = [...map.keys()].sort()
  if (!keys.length) return [{ label: '—', value: 0 }]
  return keys.map((k) => ({ label: MONTHS[Number(k.split('-')[1])], value: map.get(k)! }))
})

const revenueByDistributor = computed(() => {
  const map = new Map<string, number>()
  for (const o of completed.value) {
    const key = o.distributorId ?? 'gys'
    map.set(key, (map.get(key) ?? 0) + o.total)
  }
  return [...map.entries()]
    .map(([k, v]) => ({ label: k === 'gys' ? 'GYS' : (distributors.value.find((d) => d.id === k)?.city ?? k), value: v }))
    .sort((a, b) => b.value - a.value)
})

const statusDistribution = computed(() => {
  const groups = [
    { label: 'Menunggu', color: chartColors.warning, statuses: ['pending_payment'] },
    { label: 'Diproses', color: chartColors.info, statuses: ['paid', 'accepted_by_distributor', 'in_fulfillment'] },
    { label: 'Dikirim', color: chartColors.brand, statuses: ['shipped'] },
    { label: 'Selesai', color: chartColors.success, statuses: ['delivered', 'completed'] },
    { label: 'Batal', color: chartColors.danger, statuses: ['cancelled'] },
  ]
  return groups.map((g) => ({ label: g.label, color: g.color, value: scoped.value.filter((o) => g.statuses.includes(o.status)).length })).filter((s) => s.value > 0)
})

const productAgg = computed(() => {
  const map = new Map<string, { qty: number; revenue: number }>()
  for (const o of completed.value) {
    for (const it of o.items ?? []) {
      const cur = map.get(it.productId) ?? { qty: 0, revenue: 0 }
      cur.qty += it.qty
      cur.revenue += it.subtotal
      map.set(it.productId, cur)
    }
  }
  return [...map.entries()]
    .map(([pid, v]) => ({ sku: products.value[pid]?.sku ?? pid, name: products.value[pid]?.name ?? pid, ...v }))
    .sort((a, b) => b.revenue - a.revenue)
})
const topProductsChart = computed(() => productAgg.value.slice(0, 6).map((p) => ({ label: p.sku, value: p.revenue, caption: p.name })))

const salesByDistributor = computed(() => {
  const rows = distributors.value.map((d) => {
    const list = completed.value.filter((o) => o.distributorId === d.id)
    const rev = list.reduce((s, o) => s + o.total, 0)
    return { name: d.legalName, city: d.city, orders: list.length, revenue: rev, aov: list.length ? Math.round(rev / list.length) : 0 }
  })
  const gys = completed.value.filter((o) => !o.distributorId)
  if (gys.length) rows.push({ name: 'GYS Langsung', city: '—', orders: gys.length, revenue: gys.reduce((s, o) => s + o.total, 0), aov: Math.round(gys.reduce((s, o) => s + o.total, 0) / gys.length) })
  return rows.filter((r) => r.orders > 0).sort((a, b) => b.revenue - a.revenue)
})

const idrCompact = (n: number) => `${(n / 1_000_000).toFixed(1)}jt`
function resetFilters() { period.value = 'all'; fromDate.value = ''; toDate.value = ''; distributorFilter.value = 'all'; fulfillmentFilter.value = 'all' }

function exportSalesCsv() {
  downloadCsv('laporan-penjualan-distributor.csv', salesByDistributor.value, [
    { key: 'name', label: 'Distributor' }, { key: 'city', label: 'Kota' }, { key: 'orders', label: 'Pesanan' }, { key: 'revenue', label: 'Pendapatan' }, { key: 'aov', label: 'AOV' },
  ])
  toast.success('Laporan penjualan diekspor ke CSV')
}
function exportProductsCsv() {
  downloadCsv('laporan-top-produk.csv', productAgg.value, [
    { key: 'sku', label: 'SKU' }, { key: 'name', label: 'Produk' }, { key: 'qty', label: 'Qty Terjual' }, { key: 'revenue', label: 'Pendapatan' },
  ])
  toast.success('Laporan produk diekspor ke CSV')
}

const distColumns = [
  { key: 'name', label: 'Distributor', sortable: true },
  { key: 'city', label: 'Kota', width: '140px' },
  { key: 'orders', label: 'Pesanan', align: 'right' as const, width: '110px', sortable: true },
  { key: 'aov', label: 'AOV', align: 'right' as const, width: '150px', sortable: true },
  { key: 'revenue', label: 'Pendapatan', align: 'right' as const, width: '170px', sortable: true },
]
const prodColumns = [
  { key: 'sku', label: 'SKU', width: '130px', sortable: true },
  { key: 'name', label: 'Produk', sortable: true },
  { key: 'qty', label: 'Qty Terjual', align: 'right' as const, width: '130px', sortable: true },
  { key: 'revenue', label: 'Pendapatan', align: 'right' as const, width: '170px', sortable: true },
]
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Laporan & Analitik</h1>
        <p class="text-sm text-neutral-500 mt-1">Analisis penjualan, distributor, dan produk.</p>
      </div>
      <div class="flex gap-2">
        <GButton variant="secondary" size="sm" icon="↓" @click="exportSalesCsv">Ekspor Penjualan</GButton>
        <GButton variant="secondary" size="sm" icon="↓" @click="exportProductsCsv">Ekspor Produk</GButton>
      </div>
    </div>

    <GCard>
      <div class="flex flex-wrap items-end gap-3">
        <div>
          <label class="block text-xs font-medium text-neutral-500 mb-1">Periode</label>
          <select v-model="period" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="all">Sepanjang waktu</option>
            <option value="30">30 hari terakhir</option>
            <option value="90">90 hari terakhir</option>
            <option value="custom">Rentang kustom…</option>
          </select>
        </div>
        <template v-if="period === 'custom'">
          <div>
            <label class="block text-xs font-medium text-neutral-500 mb-1">Dari</label>
            <input v-model="fromDate" type="date" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" />
          </div>
          <div>
            <label class="block text-xs font-medium text-neutral-500 mb-1">Sampai</label>
            <input v-model="toDate" type="date" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" />
          </div>
        </template>
        <div>
          <label class="block text-xs font-medium text-neutral-500 mb-1">Fulfillment</label>
          <select v-model="fulfillmentFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="all">Semua</option>
            <option value="gys_direct">GYS Langsung</option>
            <option value="distributor">Via Distributor</option>
          </select>
        </div>
        <div v-if="fulfillmentFilter !== 'gys_direct'">
          <label class="block text-xs font-medium text-neutral-500 mb-1">Distributor</label>
          <select v-model="distributorFilter" class="h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
            <option value="all">Semua Distributor</option>
            <option v-for="d in distributors" :key="d.id" :value="d.id">{{ d.legalName }}</option>
          </select>
        </div>
        <button class="h-10 px-3 text-sm text-neutral-500 hover:text-neutral-700" @click="resetFilters">Reset</button>
        <div class="ml-auto text-sm text-neutral-500 self-center">{{ scoped.length }} pesanan dalam periode</div>
      </div>
    </GCard>

    <div class="grid grid-cols-2 lg:grid-cols-5 gap-4">
      <GSummaryCard label="Pendapatan" :value="loading ? '…' : formatIDR(revenue)" icon="◉" tone="brand" />
      <GSummaryCard label="Pesanan Selesai" :value="loading ? '…' : completed.length" icon="✓" tone="success" />
      <GSummaryCard label="AOV" :value="loading ? '…' : formatIDR(aov)" icon="∼" tone="info" />
      <GSummaryCard label="Item Terjual" :value="loading ? '…' : itemsSold" icon="☷" tone="warning" />
      <GSummaryCard label="Cancel Rate" :value="loading ? '…' : `${cancelRate.toFixed(1)}%`" icon="✕" tone="danger" />
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Tren Pendapatan" description="Per bulan dalam periode">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <GLineChart v-else :data="monthlyTrend" :height="210" :format-value="idrCompact" />
      </GCard>
      <GCard title="Distribusi Status" description="Pesanan dalam periode">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <div v-else-if="statusDistribution.length" class="py-2"><GDonutChart :data="statusDistribution" :size="160" :thickness="20" /></div>
        <p v-else class="text-sm text-neutral-500 py-8 text-center">Tidak ada data pada periode ini.</p>
      </GCard>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <GCard title="Pendapatan per Distributor">
        <div v-if="loading" class="h-44 bg-neutral-100 rounded animate-pulse" />
        <GBarChart v-else-if="revenueByDistributor.length" :data="revenueByDistributor" :height="170" :format-value="idrCompact" />
        <p v-else class="text-sm text-neutral-500 py-8 text-center">Tidak ada data.</p>
      </GCard>
      <GCard title="Produk Terlaris" description="Berdasarkan pendapatan">
        <div v-if="loading" class="h-44 bg-neutral-100 rounded animate-pulse" />
        <GBarChart v-else-if="topProductsChart.length" :data="topProductsChart" :height="170" :format-value="idrCompact" />
        <p v-else class="text-sm text-neutral-500 py-8 text-center">Tidak ada data.</p>
      </GCard>
    </div>

    <div>
      <h2 class="text-base font-semibold text-neutral-900 mb-3">Penjualan per Distributor</h2>
      <GDataTable :columns="distColumns" :rows="salesByDistributor" :loading="loading" sortable row-key="name" empty-title="Tidak ada penjualan pada periode ini">
        <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.name }}</span></template>
        <template #cell-aov="{ row }">{{ formatIDR(row.aov) }}</template>
        <template #cell-revenue="{ row }"><span class="font-semibold">{{ formatIDR(row.revenue) }}</span></template>
      </GDataTable>
    </div>

    <div>
      <h2 class="text-base font-semibold text-neutral-900 mb-3">Laporan Produk</h2>
      <GDataTable :columns="prodColumns" :rows="productAgg" :loading="loading" sortable row-key="sku" empty-title="Belum ada produk terjual">
        <template #cell-sku="{ row }"><span class="font-mono text-xs text-neutral-600">{{ row.sku }}</span></template>
        <template #cell-name="{ row }"><span class="font-medium text-neutral-900">{{ row.name }}</span></template>
        <template #cell-revenue="{ row }"><span class="font-semibold">{{ formatIDR(row.revenue) }}</span></template>
      </GDataTable>
    </div>
  </div>
</template>
