<script setup lang="ts">
import { GBadge, GButton, GCard, GStatCard, GDataTable, formatIDR, formatDate, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useDistributorsStore } from '~/composables/useDistributorsStore'

const route = useRoute()
const router = useRouter()
const api = useMockApi()
const distStore = useDistributorsStore()

const distributor = ref<any>(null)
const orders = ref<any[]>([])
const inventory = ref<any[]>([])
const buyers = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const id = route.params.id as string
  await distStore.load()
  const d = distStore.getById(id) ?? (await api.getDistributor(id))
  if (!d) { router.push('/distributors'); return }
  distributor.value = d
  const [o, inv, b] = await Promise.all([api.listOrders({ distributorId: id }), api.listInventoryFor(id), api.listBuyers()])
  orders.value = o
  inventory.value = inv
  buyers.value = b
  loading.value = false
})

const completed = computed(() => orders.value.filter((o) => ['delivered', 'completed'].includes(o.status)))
const revenue = computed(() => completed.value.reduce((s, o) => s + o.total, 0))
const lowStock = computed(() => inventory.value.filter((i) => (i.onHand - i.reserved) <= i.safetyStock).length)
function buyerName(id: string) { return buyers.value.find((b) => b.id === id)?.companyName ?? id }

const orderColumns = [
  { key: 'orderNumber', label: 'No. Pesanan' },
  { key: 'buyer', label: 'Pembeli' },
  { key: 'placedAt', label: 'Tanggal', width: '150px' },
  { key: 'total', label: 'Total', align: 'right' as const, width: '140px' },
  { key: 'status', label: 'Status', width: '150px' },
]
</script>

<template>
  <div v-if="loading" class="p-6 max-w-7xl mx-auto">
    <div class="h-8 bg-neutral-100 rounded w-64 animate-pulse mb-4" />
    <div class="h-96 bg-neutral-100 rounded animate-pulse" />
  </div>

  <div v-else-if="distributor" class="p-6 max-w-7xl mx-auto space-y-6">
    <div>
      <button class="text-sm text-brand-600 hover:text-brand-700 mb-2" @click="router.push('/distributors')">← Kembali ke daftar distributor</button>
      <div class="flex items-center gap-3 flex-wrap">
        <h1 class="text-2xl font-semibold text-neutral-900">{{ distributor.legalName }}</h1>
        <GBadge :tone="distributor.status === 'active' ? 'success' : 'neutral'" size="md">{{ distributor.status === 'active' ? 'Aktif' : distributor.status }}</GBadge>
      </div>
      <p class="text-sm text-neutral-500 mt-1">{{ distributor.code }} · {{ distributor.city }}, {{ distributor.province }}</p>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GStatCard label="Pendapatan" :value="formatIDR(revenue)" icon="◉" />
      <GStatCard label="Total Pesanan" :value="orders.length" icon="◫" />
      <GStatCard label="SKU di Stok" :value="inventory.length" icon="◰" />
      <GStatCard label="Stok Rendah" :value="lowStock" icon="▼" :trend="lowStock > 0 ? 'down' : 'flat'" :trend-value="lowStock > 0 ? 'Perlu perhatian' : 'Aman'" />
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-1" title="Informasi">
        <dl class="space-y-3 text-sm">
          <div><dt class="text-neutral-500 text-xs">NPWP</dt><dd class="font-mono">{{ distributor.npwp }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">PIC</dt><dd class="font-medium">{{ distributor.contact.name }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Telepon</dt><dd>{{ distributor.contact.phone }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Email</dt><dd>{{ distributor.contact.email }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Bergabung</dt><dd>{{ formatDate(distributor.joinedAt) }}</dd></div>
          <div>
            <dt class="text-neutral-500 text-xs mb-1">Wilayah Layanan</dt>
            <dd class="flex flex-wrap gap-1">
              <GBadge v-for="area in distributor.serviceAreas" :key="area" tone="neutral">{{ area }}</GBadge>
            </dd>
          </div>
        </dl>
        <div class="mt-4 pt-4 border-t border-neutral-100 flex gap-2">
          <GButton size="sm" variant="secondary">Kelola Pricing</GButton>
          <GButton size="sm" variant="ghost">Nonaktifkan</GButton>
        </div>
      </GCard>

      <div class="lg:col-span-2 space-y-6">
        <GCard title="Pesanan Terbaru" :description="`${orders.length} total pesanan`">
          <GDataTable :columns="orderColumns" :rows="orders.slice(0, 6)" empty-title="Belum ada pesanan" @row-click="(row) => router.push(`/orders/${row.id}`)">
            <template #cell-orderNumber="{ row }"><span class="font-medium text-neutral-900">{{ row.orderNumber }}</span></template>
            <template #cell-buyer="{ row }">{{ buyerName(row.buyerId) }}</template>
            <template #cell-placedAt="{ row }"><span class="text-neutral-600 text-sm">{{ formatDateTime(row.placedAt) }}</span></template>
            <template #cell-total="{ row }"><span class="font-semibold">{{ formatIDR(row.total) }}</span></template>
            <template #cell-status="{ row }"><GBadge :tone="statusTone(row.status as OrderStatus)">{{ statusLabel(row.status as OrderStatus) }}</GBadge></template>
          </GDataTable>
        </GCard>
      </div>
    </div>
  </div>
</template>
