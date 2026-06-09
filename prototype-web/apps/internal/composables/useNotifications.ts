import { computed, ref } from 'vue'

export interface AppNotification {
  id: string
  type: 'buyer' | 'order' | 'distributor' | 'system'
  title: string
  body: string
  at: string
  read: boolean
  to?: string
}

const items = ref<AppNotification[]>([
  { id: 'n1', type: 'buyer', title: 'Pendaftar baru', body: 'Toko Besi Sumber Rejeki mengajukan pendaftaran dan menunggu persetujuan.', at: '2026-06-09T08:10:00+07:00', read: false, to: '/buyer-approvals' },
  { id: 'n2', type: 'buyer', title: 'Pendaftar baru', body: 'CV Bangun Cipta Sarana mengajukan pendaftaran.', at: '2026-06-08T16:30:00+07:00', read: false, to: '/buyer-approvals' },
  { id: 'n3', type: 'order', title: 'Pesanan GYS Langsung', body: 'GYS-2026-000121 perlu dibuatkan Sales Order.', at: '2026-06-04T11:25:00+07:00', read: false, to: '/orders' },
  { id: 'n4', type: 'distributor', title: 'Distributor baru aktif', body: 'PT Andalas Steel Distribusi telah onboarding.', at: '2026-06-01T10:00:00+07:00', read: true, to: '/distributors' },
  { id: 'n5', type: 'system', title: 'Reminder', body: 'Integrasi SAP & TADA dijadwalkan untuk MVP2 (Nov 2026).', at: '2026-05-30T09:00:00+07:00', read: true },
])

export function useNotifications() {
  const unread = computed(() => items.value.filter((n) => !n.read).length)
  function markRead(id: string) { const n = items.value.find((x) => x.id === id); if (n) n.read = true }
  function markAllRead() { items.value.forEach((n) => (n.read = true)) }
  return { items, unread, markRead, markAllRead }
}
