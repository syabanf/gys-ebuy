import { computed, ref } from 'vue'

export interface AppNotification {
  id: string
  type: 'order' | 'stock' | 'payment' | 'system'
  title: string
  body: string
  at: string
  read: boolean
  to?: string
}

const items = ref<AppNotification[]>([
  { id: 'n1', type: 'order', title: 'Pesanan baru', body: 'GYS-2026-000123 dari CV Fabrikasi Maju Jaya menunggu diproses.', at: '2026-06-09T08:20:00+07:00', read: false, to: '/orders' },
  { id: 'n2', type: 'stock', title: 'Stok rendah', body: 'Besi Beton Ulir 22mm di bawah safety stock.', at: '2026-06-09T07:40:00+07:00', read: false, to: '/inventory' },
  { id: 'n3', type: 'payment', title: 'Pembayaran diterima', body: 'Pembayaran GYS-2026-000123 telah dikonfirmasi.', at: '2026-06-08T13:05:00+07:00', read: false, to: '/orders' },
  { id: 'n4', type: 'order', title: 'Pesanan dikirim', body: 'GYS-2026-000120 telah ditandai dikirim.', at: '2026-06-06T14:35:00+07:00', read: true, to: '/orders' },
  { id: 'n5', type: 'system', title: 'Pembaruan sistem', body: 'Fitur laporan baru tersedia di menu Laporan.', at: '2026-06-05T09:00:00+07:00', read: true },
])

export function useNotifications() {
  const unread = computed(() => items.value.filter((n) => !n.read).length)
  function markRead(id: string) { const n = items.value.find((x) => x.id === id); if (n) n.read = true }
  function markAllRead() { items.value.forEach((n) => (n.read = true)) }
  return { items, unread, markRead, markAllRead }
}
