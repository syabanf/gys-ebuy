<script setup lang="ts">
import {
  GCard, GStatCard, GBadge, GButton, GLineChart, GBarChart, GDonutChart,
  formatIDR, formatDate, formatDateTime, statusLabel, statusTone, chartColors,
} from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useSessionStore } from '~/composables/useSession'
import { useInventoryStore } from '~/composables/useInventoryStore'

const session = useSessionStore()
const api = useMockApi()
const inventory = useInventoryStore()

const orders = ref<any[]>([])
const loading = ref(true)
const distId = computed(() => session.distributorId ?? 'dist-001')

onMounted(async () => {
  await inventory.load()
  orders.value = await api.listOrders({ distributorId: distId.value })
  loading.value = false
})

const completed = computed(() => orders.value.filter((o) => ['completed', 'delivered'].includes(o.status)))
const pendingOrders = computed(() => orders.value.filter((o) => ['paid', 'accepted_by_distributor', 'in_fulfillment'].includes(o.status)))
const revenue = computed(() => completed.value.reduce((s, o) => s + o.total, 0))
const invRows = computed(() => inventory.rowsFor(distId.value))
const lowStock = computed(() => invRows.value.filter((i) => (i.onHand - i.reserved) <= i.safetyStock))
const fulfillmentRate = computed(() => {
  const active = orders.value.filter((o) => o.status !== 'cancelled')
  if (!active.length) return 0
  return Math.round((completed.value.length / active.length) * 100)
})

const revenueTrend = computed(() => {
  const base = revenue.value || 20_000_000
  const factors = [0.38, 0.5, 0.59, 0.7, 0.85, 1]
  return ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'].map((label, i) => ({ label, value: Math.round(base * factors[i]) }))
})

const statusDistribution = computed(() => {
  const groups = [
    { label: 'Menunggu Bayar', color: chartColors.warning, statuses: ['pending_payment'] },
    { label: 'Diproses', color: chartColors.info, statuses: ['paid', 'accepted_by_distributor', 'in_fulfillment'] },
    { label: 'Dikirim', color: chartColors.brand, statuses: ['shipped'] },
    { label: 'Selesai', color: chartColors.success, statuses: ['delivered', 'completed'] },
    { label: 'Dibatalkan', color: chartColors.danger, statuses: ['cancelled'] },
  ]
  return groups
    .map((g) => ({ label: g.label, color: g.color, value: orders.value.filter((o) => g.statuses.includes(o.status)).length }))
    .filter((s) => s.value > 0)
})

const topProducts = computed(() => {
  const map = new Map<string, number>()
  for (const o of orders.value) {
    for (const it of o.items ?? []) {
      map.set(it.productId, (map.get(it.productId) ?? 0) + it.subtotal)
    }
  }
  return [...map.entries()]
    .map(([pid, val]) => ({ label: inventory.product(pid)?.sku ?? pid, value: val, caption: inventory.product(pid)?.name }))
    .sort((a, b) => b.value - a.value)
    .slice(0, 5)
})

const recentOrders = computed(() => orders.value.slice(0, 5))
const idrCompact = (n: number) => `${(n / 1_000_000).toFixed(1)}jt`
const today = formatDate('2026-06-09')
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
          <p class="text-white/80 mt-1 text-sm">Ada <strong>{{ pendingOrders.length }}</strong> pesanan menunggu diproses hari ini.</p>
        </div>
        <div class="flex gap-2">
          <GButton variant="secondary" size="sm" @click="() => $router.push('/orders')">Lihat Pesanan</GButton>
          <GButton variant="secondary" size="sm" @click="() => $router.push('/reports')">Laporan</GButton>
        </div>
      </div>
    </div>

    <!-- Summary cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <GStatCard label="Pesanan Tertunda" :value="loading ? '…' : pendingOrders.length" icon="◫" hint="Perlu diproses" :spark="[3, 5, 4, 6, 5, 7, 6]" :spark-color="chartColors.info" />
      <GStatCard label="Pendapatan" :value="loading ? '…' : formatIDR(revenue)" icon="◉" trend="up" trend-value="+18% MoM" :spark="[8, 11, 10, 14, 16, 20, 23]" />
      <GStatCard label="Stok Rendah" :value="loading ? '…' : lowStock.length" icon="◰" :trend="lowStock.length > 0 ? 'down' : 'flat'" :trend-value="lowStock.length > 0 ? 'Perlu restock' : 'Aman'" :spark="[1, 2, 2, 3, 4, 3, 4]" :spark-color="chartColors.danger" />
      <GStatCard label="Tingkat Penyelesaian" :value="loading ? '…' : `${fulfillmentRate}%`" icon="✓" trend="up" trend-value="On track" :spark="[70, 74, 78, 80, 84, 88, 92]" :spark-color="chartColors.success" />
    </div>

    <!-- Charts row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Tren Pendapatan" description="6 bulan terakhir (rupiah)">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <GLineChart v-else :data="revenueTrend" :height="210" :format-value="idrCompact" />
      </GCard>
      <GCard title="Status Pesanan" description="Distribusi pesanan Anda">
        <div v-if="loading" class="h-52 bg-neutral-100 rounded animate-pulse" />
        <div v-else-if="statusDistribution.length" class="py-2">
          <GDonutChart :data="statusDistribution" :size="160" :thickness="20" />
        </div>
      </GCard>
    </div>

    <!-- Top products + low stock -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Produk Terlaris" description="Berdasarkan nilai pesanan">
        <div v-if="loading" class="h-44 bg-neutral-100 rounded animate-pulse" />
        <GBarChart v-else-if="topProducts.length" :data="topProducts" :height="170" :format-value="idrCompact" />
        <p v-else class="text-sm text-neutral-500 py-8 text-center">Belum ada penjualan.</p>
      </GCard>
      <GCard title="Stok Perlu Perhatian">
        <template #header>
          <NuxtLink to="/inventory" class="text-sm text-brand-600 hover:text-brand-700 font-medium">Kelola →</NuxtLink>
        </template>
        <div v-if="loading" class="space-y-3">
          <div v-for="i in 3" :key="i" class="h-12 bg-neutral-100 rounded animate-pulse" />
        </div>
        <p v-else-if="lowStock.length === 0" class="text-sm text-neutral-500 text-center py-8">Semua stok aman.</p>
        <ul v-else class="divide-y divide-neutral-100 -mx-5 -my-5">
          <li v-for="item in lowStock.slice(0, 5)" :key="item.productId" class="px-5 py-3 flex items-center justify-between gap-3">
            <div class="min-w-0">
              <p class="text-sm font-medium text-neutral-900 truncate">{{ item.product?.name }}</p>
              <p class="text-xs text-neutral-500">SKU: {{ item.product?.sku }}</p>
            </div>
            <div class="text-right flex-shrink-0">
              <p class="text-sm font-semibold text-danger">{{ item.onHand - item.reserved }}</p>
              <p class="text-xs text-neutral-500">safety {{ item.safetyStock }}</p>
            </div>
          </li>
        </ul>
      </GCard>
    </div>

    <!-- Recent orders -->
    <GCard title="Pesanan Terbaru">
      <template #header>
        <NuxtLink to="/orders" class="text-sm text-brand-600 hover:text-brand-700 font-medium">Lihat semua →</NuxtLink>
      </template>
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="h-12 bg-neutral-100 rounded animate-pulse" />
      </div>
      <ul v-else class="divide-y divide-neutral-100 -mx-5 -my-5">
        <li v-for="order in recentOrders" :key="order.id" class="px-5 py-3.5 hover:bg-neutral-50 transition-colors">
          <NuxtLink :to="`/orders/${order.id}`" class="flex items-center justify-between gap-4">
            <div class="min-w-0">
              <p class="text-sm font-medium text-neutral-900 truncate">{{ order.orderNumber }}</p>
              <p class="text-xs text-neutral-500 mt-0.5">{{ formatDateTime(order.placedAt) }}</p>
            </div>
            <div class="text-right flex-shrink-0">
              <p class="text-sm font-semibold text-neutral-900">{{ formatIDR(order.total) }}</p>
              <GBadge :tone="statusTone(order.status as OrderStatus)" class="mt-1">{{ statusLabel(order.status as OrderStatus) }}</GBadge>
            </div>
          </NuxtLink>
        </li>
      </ul>
    </GCard>
  </div>
</template>
