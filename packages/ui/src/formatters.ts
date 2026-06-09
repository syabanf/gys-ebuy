import type { BadgeTone, OrderStatus } from './types'

const idrFormatter = new Intl.NumberFormat('id-ID', {
  style: 'currency',
  currency: 'IDR',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
})

export function formatIDR(amount: number): string {
  return idrFormatter.format(amount).replace('Rp', 'Rp ')
}

const dateFormatter = new Intl.DateTimeFormat('id-ID', { dateStyle: 'medium' })
const dateTimeFormatter = new Intl.DateTimeFormat('id-ID', { dateStyle: 'medium', timeStyle: 'short' })

export function formatDate(iso: string | Date): string {
  const d = typeof iso === 'string' ? new Date(iso) : iso
  return dateFormatter.format(d)
}

export function formatDateTime(iso: string | Date): string {
  const d = typeof iso === 'string' ? new Date(iso) : iso
  return dateTimeFormatter.format(d)
}

const STATUS_LABELS: Record<OrderStatus, string> = {
  draft: 'Draft',
  pending_payment: 'Menunggu Pembayaran',
  paid: 'Sudah Dibayar',
  accepted_by_distributor: 'Diterima Distributor',
  in_fulfillment: 'Dalam Proses',
  shipped: 'Dikirim',
  delivered: 'Terkirim',
  completed: 'Selesai',
  cancelled: 'Dibatalkan',
  disputed: 'Sengketa',
}

const STATUS_TONES: Record<OrderStatus, BadgeTone> = {
  draft: 'neutral',
  pending_payment: 'warning',
  paid: 'info',
  accepted_by_distributor: 'info',
  in_fulfillment: 'info',
  shipped: 'brand',
  delivered: 'success',
  completed: 'success',
  cancelled: 'danger',
  disputed: 'danger',
}

export function statusLabel(s: OrderStatus): string {
  return STATUS_LABELS[s] ?? s
}

export function statusTone(s: OrderStatus): BadgeTone {
  return STATUS_TONES[s] ?? 'neutral'
}
