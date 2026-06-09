<script setup lang="ts">
import {
  GBadge, GButton, GCard, GStatCard, GLineChart, GBarChart, GDonutChart,
  formatIDR, formatDate, formatDateTime, statusLabel, statusTone, chartColors,
} from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useSessionStore } from '~/composables/useSession'

const session = useSessionStore()
const api = useMockApi()

const orders = ref<any[]>([])
const buyers = ref<any[]>([])
const distributors = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const [o, b, d] = await Promise.all([api.listOrders(), api.listBuyers(), api.listDistributors()])
  orders.value = o
  buyers.value = b
  distributors.value = d
  loading.value = false
})

const completed = computed(() => orders.value.filter((o) => ['completed', 'delivered'].includes(o.status)))
const totalRevenue = computed(() => completed.value.reduce((s, o) => s + o.total, 0))
const pendingApprovals = computed(() => buyers.value.filter((b) => b.approvalStatus === 'pending').length)
const activeDistributors = computed(() => distributors.value.filter((d) => d.status === 'active').length)
const ordersInFlight = computed(() => orders.value.filter((o) => ['paid', 'accepted_by_distributor', 'in_fulfillment', 'shipped'].includes(o.status)).length)
const avgOrderValue = computed(() => completed.value.length ? Math.round(totalRevenue.value / completed.value.length) : 0)

// Revenue trend — synthesized 6-month series anchored on actual total for a believable graphic.
const revenueTrend = computed(() => {
  const base = totalRevenue.value || 40_000_000
  const factors = [0.42, 0.55, 0.61, 0.74, 0.86, 1]
  const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun']
  return labels.map((label, i) => ({ label, value: Math.round(base * factors[i]) }))
})

// Revenue by distributor (completed orders)
const revenueByDistributor = computed(() => {
  const map = new Map<string, number>()
  for (const o of completed.value) {
    if (!o.distributorId) {
      map.set('gys', (map.get('gys') ?? 0) + o.total)
      continue
    }
    map.set(o.distributorId, (map.get(o.distributorId) ?? 0) + o.total)
  }
  const rows = distributors.value.map((d) => ({ label: d.city, value: map.get(d.id) ?? 0 }))
  const gys = map.get('gys') ?? 0
  if (gys > 0) rows.push({ label: 'GYS Langsung', value: gys })
  return rows.sort((a, b) => b.value - a.value)
})

// Order status distribution
const statusDistribution = computed(() => {
  const groups: Record<string, { label: string; color: string; statuses: string[] }> = {
    pending: { label: 'Menunggu Bayar', color: chartColors.warning, statuses: ['pending_payment'] },
    processing: { label: 'Diproses', color: chartColors.info, statuses: ['paid', 'accepted_by_distributor', 'in_fulfillment'] },
    shipped: { label: 'Dikirim', color: chartColors.brand, statuses: ['shipped'] },
    done: { label: 'Selesai', color: chartColors.success, statuses: ['delivered', 'completed'] },
    cancelled: { label: 'Dibatalkan', color: chartColors.danger, statuses: ['cancelled'] },
  }
  return Object.values(groups)
    .map((g) => ({ label: g.label, color: g.color, value: orders.value.filter((o) => g.statuses.includes(o.status)).length }))
    .filter((s) => s.value > 0)
})

const recentOrders = computed(() => orders.value.slice(0, 5))
function buyerName(id: string) { return buyers.value.find((b) => b.id === id)?.companyName ?? id }
const idrCompact = (n: number) => `${(n / 1_000_000).toFixed(1)}jt`
const today = formatDate('2026-06-09')

const topBuyers = computed(() => {
  const map = new Map<string, { revenue: number; orders: number }>()
  for (const o of completed.value) {
    const cur = map.get(o.buyerId) ?? { revenue: 0, orders: 0 }
    cur.revenue += o.total
    cur.orders += 1
    map.set(o.buyerId, cur)
  }
  return [...map.entries()]
    .map(([id, v]) => ({ id, name: buyerName(id), type: buyers.value.find((b) => b.id === id)?.businessType ?? '', ...v }))
    .sort((a, b) => b.revenue - a.revenue)
    .slice(0, 5)
})
function buyerTypeLabel(t: string) {
  return ({ fabricator: 'Fabrikator', contractor: 'Kontraktor', retailer: 'Retail', 'sub-distributor': 'Sub-Distributor' } as Record<string, string>)[t] ?? t
}
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-brand-600 via-brand-700 to-brand-800 px-6 py-7 text-white">
      <div class="absolute -right-12 -top-12 h-44 w-44 rounded-full bg-white/5" />
      <div class="absolute right-20 bottom-0 h-28 w-28 rounded-full bg-white/5" />
      <div class="relative flex items-center justify-between gap-4 flex-wrap">
        <div>
          <p class="text-sm text-white/70">{{ today }}</p>
          <h1 class="text-2xl font-bold mt-1">Halo, {{ session.user?.displayName }} 👋</h1>
          <p class="text-white/80 mt-1 text-sm"><strong>{{ pendingApprovals }}</strong> pembeli menunggu persetujuan · <strong>{{ ordersInFlight }}</strong> pesanan berjalan.</p>
        </div>
        <div class="flex gap-2">
          <GButton variant="secondary" size="sm" @click="() => $router.push('/buyer-approvals')">Persetujuan</GButton>
          <GButton variant="secondary" size="sm" @click="() => $router.push('/reports')">Laporan</GButton>
        </div>
      </div>
    </div>

    <!-- Summary cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <GStatCard label="Total Pendapatan" :value="loading ? '…' : formatIDR(totalRevenue)" icon="◉" trend="up" trend-value="+24% MoM" :spark="[12, 18, 16, 24, 28, 34, 42]" />
      <GStatCard label="Pesanan Berjalan" :value="loading ? '…' : ordersInFlight" icon="◫" hint="Belum selesai" :spark="[4, 6, 5, 7, 6, 8, 7]" :spark-color="chartColors.info" />
      <GStatCard label="Distributor Aktif" :value="loading ? '…' : activeDistributors" icon="◰" trend="up" trend-value="+1 bulan ini" :spark="[1, 1, 2, 2, 2, 3, 3]" :spark-color="chartColors.warning" />
      <GStatCard label="Menunggu Persetujuan" :value="loading ? '…' : pendingApprovals" icon="✓" :trend="pendingApprovals > 0 ? 'down' : 'flat'" :trend-value="pendingApprovals > 0 ? 'Perlu tindakan' : 'Bersih'" :spark="[0, 1, 1, 2, 1, 2, 3]" :spark-color="chartColors.danger" />
    </div>

    <!-- Charts row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Tren Pendapatan" description="6 bulan terakhir (rupiah)">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <GLineChart v-else :data="revenueTrend" :height="210" :format-value="idrCompact" />
      </GCard>
      <GCard title="Status Pesanan" description="Distribusi seluruh pesanan">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <div v-else-if="statusDistribution.length" class="py-2">
          <GDonutChart :data="statusDistribution" :size="160" :thickness="20" />
        </div>
      </GCard>
    </div>

    <!-- Revenue by distributor + AOV -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Pendapatan per Distributor" description="Pesanan selesai & terkirim">
        <div v-if="loading" class="h-48 bg-neutral-100 rounded animate-pulse" />
        <GBarChart v-else-if="revenueByDistributor.length" :data="revenueByDistributor" :height="170" :format-value="idrCompact" />
      </GCard>
      <div class="space-y-4">
        <GStatCard label="Rata-rata Nilai Pesanan" :value="loading ? '…' : formatIDR(avgOrderValue)" icon="∼" hint="AOV (selesai)" />
        <GStatCard label="Total Pesanan" :value="loading ? '…' : orders.length" icon="Σ" hint="Sepanjang waktu" />
      </div>
    </div>

    <!-- Top buyers table -->
    <GCard title="Pembeli Teratas" description="Berdasarkan nilai pesanan selesai">
      <template #header>
        <NuxtLink to="/buyer-approvals" class="text-sm text-brand-600 hover:text-brand-700 font-medium">Kelola pembeli →</NuxtLink>
      </template>
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 5" :key="i" class="h-10 bg-neutral-100 rounded animate-pulse" />
      </div>
      <table v-else class="w-full text-sm -mx-5" style="width:calc(100% + 2.5rem)">
        <thead class="text-xs uppercase text-neutral-500 border-b border-neutral-100">
          <tr>
            <th class="text-left px-5 py-2 font-medium">#</th>
            <th class="text-left px-5 py-2 font-medium">Pembeli</th>
            <th class="text-left px-5 py-2 font-medium">Tipe</th>
            <th class="text-right px-5 py-2 font-medium">Pesanan</th>
            <th class="text-right px-5 py-2 font-medium">Total Belanja</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-100">
          <tr v-for="(b, i) in topBuyers" :key="b.id" class="hover:bg-neutral-50">
            <td class="px-5 py-3 text-neutral-400 font-semibold">{{ i + 1 }}</td>
            <td class="px-5 py-3 font-medium text-neutral-900">{{ b.name }}</td>
            <td class="px-5 py-3"><GBadge tone="neutral">{{ buyerTypeLabel(b.type) }}</GBadge></td>
            <td class="px-5 py-3 text-right text-neutral-600">{{ b.orders }}</td>
            <td class="px-5 py-3 text-right font-semibold text-neutral-900">{{ formatIDR(b.revenue) }}</td>
          </tr>
        </tbody>
      </table>
    </GCard>

    <!-- Recent orders -->
    <GCard title="Pesanan Terbaru" description="Aliran pesanan terbaru di seluruh distributor">
      <template #header>
        <NuxtLink to="/orders" class="text-sm text-brand-600 hover:text-brand-700 font-medium">Lihat semua →</NuxtLink>
      </template>
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 4" :key="i" class="h-12 bg-neutral-100 rounded animate-pulse" />
      </div>
      <ul v-else class="divide-y divide-neutral-100 -mx-5 -my-5">
        <li v-for="order in recentOrders" :key="order.id" class="px-5 py-3.5 hover:bg-neutral-50 transition-colors">
          <div class="flex items-center justify-between gap-4">
            <div class="min-w-0">
              <p class="text-sm font-medium text-neutral-900 truncate">{{ order.orderNumber }} · {{ buyerName(order.buyerId) }}</p>
              <p class="text-xs text-neutral-500 mt-0.5">{{ formatDateTime(order.placedAt) }} · {{ order.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor' }}</p>
            </div>
            <div class="text-right flex-shrink-0">
              <p class="text-sm font-semibold text-neutral-900">{{ formatIDR(order.total) }}</p>
              <GBadge :tone="statusTone(order.status as OrderStatus)" class="mt-1">{{ statusLabel(order.status as OrderStatus) }}</GBadge>
            </div>
          </div>
        </li>
      </ul>
    </GCard>
  </div>
</template>
