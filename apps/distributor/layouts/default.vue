<script setup lang="ts">
import { GAppShell, GToastHost, GCommandPalette } from '@gys/ui'
import { useSessionStore } from '~/composables/useSession'
import { useNotifications } from '~/composables/useNotifications'
import { useToast } from '~/composables/useToast'
import { useMockApi } from '~/composables/useMockApi'

const route = useRoute()
const router = useRouter()
const session = useSessionStore()
const { unread } = useNotifications()
const { toasts, remove: removeToast } = useToast()
const api = useMockApi()

const nav = [
  { items: [{ label: 'Dashboard', to: '/', icon: '⌂' }] },
  { label: 'Operasional', icon: '◷', collapsible: true, items: [
    { label: 'Pesanan', to: '/orders', icon: '◫', badge: '3' },
    { label: 'Pengiriman', to: '/shipments', icon: '✈' },
  ] },
  { label: 'Produk & Stok', icon: '◰', collapsible: true, items: [
    { label: 'Katalog Produk', to: '/catalog', icon: '◷' },
    { label: 'Stok Gudang', to: '/inventory', icon: '☷' },
  ] },
  { label: 'Lainnya', items: [
    { label: 'Laporan', to: '/reports', icon: '◉' },
    { label: 'Pengaturan', to: '/settings', icon: '⚙' },
  ] },
]

// Cross-app demo links (localhost demo ports)
const apps = [
  { label: 'Portal Distributor', sublabel: 'Web distributor', url: 'http://localhost:4000', icon: '◰', current: true },
  { label: 'GYS Internal', sublabel: 'Konsol Sales & IT', url: 'http://localhost:4001', icon: '◉' },
  { label: 'Buyer Mobile', sublabel: 'Aplikasi pembeli (Flutter Web)', url: 'http://localhost:4002', icon: '◫' },
]

const searchItems = ref<{ label: string; sublabel?: string; to: string; group?: string }[]>([])
const paletteOpen = ref(false)
function onKey(e: KeyboardEvent) {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); paletteOpen.value = !paletteOpen.value }
}

onMounted(async () => {
  window.addEventListener('keydown', onKey)
  const distId = session.distributorId ?? 'dist-001'
  const [products, orders, buyers] = await Promise.all([api.listProducts(), api.listOrders({ distributorId: distId }), api.listBuyers()])
  const buyerName = (id: string) => buyers.find((b) => b.id === id)?.companyName ?? ''
  searchItems.value = [
    { label: 'Dashboard', to: '/', group: 'Halaman' },
    { label: 'Pesanan', to: '/orders', group: 'Halaman' },
    { label: 'Stok Gudang', to: '/inventory', group: 'Halaman' },
    { label: 'Laporan', to: '/reports', group: 'Halaman' },
    ...products.map((p) => ({ label: p.name, sublabel: p.sku, to: `/catalog/${p.id}`, group: 'Produk' })),
    ...orders.map((o) => ({ label: o.orderNumber, sublabel: buyerName(o.buyerId), to: `/orders/${o.id}`, group: 'Pesanan' })),
  ]
})
onBeforeUnmount(() => window.removeEventListener('keydown', onKey))

function goPalette(to: string) { paletteOpen.value = false; router.push(to) }

function logout() {
  session.logout()
  router.push('/login')
}
</script>

<template>
  <GAppShell
    app-name="GYS Distributor"
    app-tagline="Portal Distributor"
    storage-key="gys-dist"
    :nav="nav"
    :apps="apps"
    :search-items="searchItems"
    :notif-count="unread"
    :user-name="session.user?.displayName ?? 'Tamu'"
    :user-role="session.user?.role === 'distributor_owner' ? 'Pemilik Distributor' : 'Staff'"
    :current-path="route.path"
    @logout="logout"
    @navigate="(to) => router.push(to)"
  >
    <slot />
  </GAppShell>
  <GToastHost :toasts="toasts" @dismiss="removeToast" />
  <GCommandPalette :open="paletteOpen" :items="searchItems" @select="goPalette" @close="paletteOpen = false" />
</template>
