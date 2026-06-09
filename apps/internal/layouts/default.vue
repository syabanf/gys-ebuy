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

const nav = computed(() => [
  { items: [{ label: 'Dashboard', to: '/', icon: '⌂' }] },
  { label: 'Pesanan & Pembeli', icon: '◫', collapsible: true, items: [
    { label: 'Pesanan', to: '/orders', icon: '◫' },
    { label: 'Persetujuan Pembeli', to: '/buyer-approvals', icon: '✓', badge: '3' },
  ] },
  { label: 'Katalog & Harga', icon: '◷', collapsible: true, items: [
    { label: 'Katalog Master', to: '/catalog', icon: '◷' },
    { label: 'Pricing Scope', to: '/pricing-scopes', icon: '◉' },
  ] },
  { label: 'Jaringan', icon: '◰', collapsible: true, items: [{ label: 'Distributor', to: '/distributors', icon: '◰' }] },
  { label: 'Master Data', icon: '▤', collapsible: true, items: [
    { label: 'Ringkasan', to: '/master-data', icon: '▦' },
    { label: 'Kategori Produk', to: '/master-data/categories', icon: '☰' },
    { label: 'Satuan (UoM)', to: '/master-data/uom', icon: '⚖' },
    { label: 'Pengguna & Peran', to: '/master-data/users', icon: '◌' },
  ] },
  { label: 'Analitik', items: [{ label: 'Laporan', to: '/reports', icon: '◊' }] },
  ...(session.isItAdmin ? [{ label: 'Sistem', items: [{ label: 'Pengaturan Sistem', to: '/settings', icon: '⚙' }] }] : []),
])

// Cross-app demo links (localhost demo ports)
const apps = [
  { label: 'GYS Internal', sublabel: 'Konsol Sales & IT', url: 'http://localhost:4001', icon: '◉', current: true },
  { label: 'Portal Distributor', sublabel: 'Web distributor', url: 'http://localhost:4000', icon: '◰' },
  { label: 'Buyer Mobile', sublabel: 'Aplikasi pembeli (Flutter Web)', url: 'http://localhost:4002', icon: '◫' },
]

const searchItems = ref<{ label: string; sublabel?: string; to: string; group?: string }[]>([])
const paletteOpen = ref(false)
function onKey(e: KeyboardEvent) {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); paletteOpen.value = !paletteOpen.value }
}

onMounted(async () => {
  window.addEventListener('keydown', onKey)
  const [products, orders, distributors, buyers] = await Promise.all([api.listProducts(), api.listOrders(), api.listDistributors(), api.listBuyers()])
  const buyerName = (id: string) => buyers.find((b) => b.id === id)?.companyName ?? ''
  searchItems.value = [
    { label: 'Dashboard', to: '/', group: 'Halaman' },
    { label: 'Persetujuan Pembeli', to: '/buyer-approvals', group: 'Halaman' },
    { label: 'Katalog Master', to: '/catalog', group: 'Halaman' },
    { label: 'Distributor', to: '/distributors', group: 'Halaman' },
    { label: 'Laporan & Analitik', to: '/reports', group: 'Halaman' },
    { label: 'Master Data', to: '/master-data', group: 'Master Data' },
    { label: 'Kategori Produk', to: '/master-data/categories', group: 'Master Data' },
    { label: 'Satuan (UoM)', to: '/master-data/uom', group: 'Master Data' },
    { label: 'Pengguna & Peran', to: '/master-data/users', group: 'Master Data' },
    ...orders.map((o) => ({ label: o.orderNumber, sublabel: buyerName(o.buyerId), to: `/orders/${o.id}`, group: 'Pesanan' })),
    ...products.map((p) => ({ label: p.name, sublabel: p.sku, to: `/catalog/${p.id}`, group: 'Produk' })),
    ...distributors.map((d) => ({ label: d.legalName, sublabel: d.city, to: `/distributors/${d.id}`, group: 'Distributor' })),
    ...buyers.map((b) => ({ label: b.companyName, sublabel: b.businessType, to: `/buyer-approvals/${b.id}`, group: 'Pembeli' })),
  ]
})
onBeforeUnmount(() => window.removeEventListener('keydown', onKey))

function goPalette(to: string) { paletteOpen.value = false; router.push(to) }

function logout() {
  session.logout()
  router.push('/login')
}

function roleLabel(role?: string) {
  if (role === 'gys_it_admin') return 'IT Admin'
  if (role === 'gys_sales') return 'Sales'
  return 'GYS Internal'
}
</script>

<template>
  <GAppShell
    app-name="GYS Internal"
    app-tagline="Sales & IT Console"
    storage-key="gys-internal"
    :nav="nav"
    :apps="apps"
    :search-items="searchItems"
    :notif-count="unread"
    :user-name="session.user?.displayName ?? 'Tamu'"
    :user-role="roleLabel(session.user?.role)"
    :current-path="route.path"
    @logout="logout"
    @navigate="(to) => router.push(to)"
  >
    <slot />
  </GAppShell>
  <GToastHost :toasts="toasts" @dismiss="removeToast" />
  <GCommandPalette :open="paletteOpen" :items="searchItems" @select="goPalette" @close="paletteOpen = false" />
</template>
