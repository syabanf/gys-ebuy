<script setup lang="ts">
import { GBadge, GButton, GCard, formatIDR, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'
import { useToast } from '~/composables/useToast'

const route = useRoute()
const router = useRouter()
const api = useMockApi()
const toast = useToast()

const statusOptions: OrderStatus[] = ['pending_payment', 'paid', 'accepted_by_distributor', 'in_fulfillment', 'shipped', 'delivered', 'completed', 'cancelled']
function updateStatus(s: string) {
  if (!order.value || order.value.status === s) return
  order.value.status = s
  const now = new Date().toISOString()
  if (s === 'shipped' && !order.value.shippedAt) order.value.shippedAt = now
  if (s === 'delivered' && !order.value.deliveredAt) order.value.deliveredAt = now
  if (s === 'completed' && !order.value.completedAt) order.value.completedAt = now
  toast.success(`Status diperbarui ke "${statusLabel(s as OrderStatus)}"`)
}

const order = ref<any>(null)
const buyer = ref<any>(null)
const distributor = ref<any>(null)
const products = ref<Record<string, any>>({})
const loading = ref(true)

onMounted(async () => {
  const o = await api.getOrder(route.params.id as string)
  if (!o) { router.push('/orders'); return }
  order.value = o
  const [b, dists, all] = await Promise.all([api.getBuyer(o.buyerId), api.listDistributors(), api.listProducts()])
  buyer.value = b
  distributor.value = o.distributorId ? dists.find((d) => d.id === o.distributorId) : null
  products.value = Object.fromEntries(all.map((p) => [p.id, p]))
  loading.value = false
})

function printInvoice() {
  const o = order.value
  if (!o) return
  const rows = o.items.map((it: any) => `<tr><td>${products.value[it.productId]?.name ?? ''}<br><span class="muted">${products.value[it.productId]?.sku ?? ''}</span></td><td class="r">${it.qty}</td><td class="r">${formatIDR(it.unitPrice)}</td><td class="r">${formatIDR(it.subtotal)}</td></tr>`).join('')
  printHtml(`Invoice ${o.orderNumber}`, `
    <div class="head"><div><div style="display:flex;gap:10px;align-items:center"><div class="logo">GYS</div><div><strong>PT Garuda Yamato Steel</strong><div class="muted">garudayamatosteel.com</div></div></div></div>
      <div style="text-align:right"><h1>INVOICE</h1><div class="muted">${o.orderNumber}</div><div class="muted">${formatDateTime(o.placedAt)}</div></div></div>
    <div class="grid">
      <div><h3>Ditagihkan ke</h3><strong>${buyer.value?.companyName ?? ''}</strong><div class="muted">${buyer.value?.address ?? ''}</div><div class="muted">NPWP: ${buyer.value?.npwp ?? '-'}</div></div>
      <div><h3>Fulfillment</h3>${o.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor'}<div class="muted">${distributor.value?.legalName ?? ''}</div><h3 style="margin-top:12px">Status</h3>${statusLabel(o.status as OrderStatus)}</div>
    </div>
    <table><thead><tr><th>Produk</th><th class="r">Qty</th><th class="r">Harga</th><th class="r">Subtotal</th></tr></thead>
      <tbody>${rows}</tbody>
      <tfoot>
        <tr><td colspan="3" class="r">Subtotal</td><td class="r">${formatIDR(o.subtotal)}</td></tr>
        <tr><td colspan="3" class="r">Biaya Kirim</td><td class="r">${formatIDR(o.shippingFee)}</td></tr>
        <tr><td colspan="3" class="r tot">Total</td><td class="r tot">${formatIDR(o.total)}</td></tr>
      </tfoot></table>
    <p class="muted" style="margin-top:32px">Dokumen ini dibuat otomatis oleh GYS E-Ordering Platform · Prototype.</p>
  `)
}

const timeline = computed(() => {
  if (!order.value) return []
  const o = order.value
  return [
    { label: 'Pesanan Dibuat', at: o.placedAt },
    o.status !== 'cancelled' ? { label: 'Pembayaran Diterima', at: o.placedAt } : null,
    o.shippedAt ? { label: 'Dikirim', at: o.shippedAt } : null,
    o.deliveredAt ? { label: 'Terkirim ke Pembeli', at: o.deliveredAt } : null,
    o.completedAt ? { label: 'Pesanan Selesai', at: o.completedAt } : null,
    o.cancelledAt ? { label: 'Dibatalkan', at: o.cancelledAt, danger: true } : null,
  ].filter(Boolean) as Array<{ label: string; at: string; danger?: boolean }>
})
</script>

<template>
  <div v-if="loading" class="p-6 max-w-7xl mx-auto">
    <div class="h-8 bg-neutral-100 rounded w-64 animate-pulse mb-4" />
    <div class="h-96 bg-neutral-100 rounded animate-pulse" />
  </div>

  <div v-else-if="order" class="p-6 max-w-7xl mx-auto space-y-6">
    <div>
      <button class="text-sm text-brand-600 hover:text-brand-700 mb-2" @click="router.push('/orders')">← Kembali ke daftar pesanan</button>
      <div class="flex items-center gap-3 flex-wrap">
        <h1 class="text-2xl font-semibold text-neutral-900">{{ order.orderNumber }}</h1>
        <GBadge :tone="statusTone(order.status as OrderStatus)" size="md">{{ statusLabel(order.status as OrderStatus) }}</GBadge>
      </div>
      <p class="text-sm text-neutral-500 mt-1">Dibuat {{ formatDateTime(order.placedAt) }} · {{ order.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor' }}</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <GCard title="Item Pesanan">
          <table class="w-full text-sm -mx-5">
            <thead class="text-xs uppercase text-neutral-500">
              <tr class="border-b border-neutral-100">
                <th class="text-left px-5 py-2">Produk</th>
                <th class="text-right px-5 py-2">Qty</th>
                <th class="text-right px-5 py-2">Harga</th>
                <th class="text-right px-5 py-2">Subtotal</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-neutral-100">
              <tr v-for="item in order.items" :key="item.productId">
                <td class="px-5 py-3">
                  <p class="font-medium text-neutral-900">{{ products[item.productId]?.name }}</p>
                  <p class="text-xs text-neutral-500">SKU: {{ products[item.productId]?.sku }}</p>
                </td>
                <td class="px-5 py-3 text-right text-neutral-700">{{ item.qty }} {{ products[item.productId]?.uom }}</td>
                <td class="px-5 py-3 text-right text-neutral-700">{{ formatIDR(item.unitPrice) }}</td>
                <td class="px-5 py-3 text-right font-semibold text-neutral-900">{{ formatIDR(item.subtotal) }}</td>
              </tr>
            </tbody>
            <tfoot class="border-t border-neutral-200">
              <tr><td colspan="3" class="px-5 py-2 text-right text-neutral-500">Subtotal</td><td class="px-5 py-2 text-right font-medium">{{ formatIDR(order.subtotal) }}</td></tr>
              <tr><td colspan="3" class="px-5 py-2 text-right text-neutral-500">Biaya Kirim</td><td class="px-5 py-2 text-right font-medium">{{ formatIDR(order.shippingFee) }}</td></tr>
              <tr class="bg-neutral-50"><td colspan="3" class="px-5 py-3 text-right font-semibold">Total</td><td class="px-5 py-3 text-right font-bold text-lg">{{ formatIDR(order.total) }}</td></tr>
            </tfoot>
          </table>
        </GCard>

        <GCard title="Timeline">
          <ol class="space-y-4">
            <li v-for="(evt, i) in timeline" :key="i" class="flex gap-3">
              <div :class="['h-3 w-3 rounded-full mt-1.5 flex-shrink-0', evt.danger ? 'bg-danger' : 'bg-brand-500']" />
              <div class="flex-1">
                <p class="text-sm font-medium text-neutral-900">{{ evt.label }}</p>
                <p class="text-xs text-neutral-500">{{ formatDateTime(evt.at) }}</p>
              </div>
            </li>
          </ol>
        </GCard>
      </div>

      <div class="space-y-6">
        <GCard title="Pembeli">
          <p class="font-medium text-neutral-900">{{ buyer?.companyName }}</p>
          <p class="text-sm text-neutral-500 mt-0.5">{{ buyer?.businessType }}</p>
          <div class="mt-3 space-y-1 text-sm">
            <p>{{ buyer?.contactName }}</p>
            <p class="text-neutral-600">{{ buyer?.phone }}</p>
            <p class="text-neutral-600">{{ buyer?.email }}</p>
          </div>
          <p class="text-sm text-neutral-600 mt-3 pt-3 border-t border-neutral-100">{{ buyer?.address }}</p>
        </GCard>

        <GCard title="Ubah Status Pesanan">
          <label class="block text-sm text-neutral-600 mb-2">Status saat ini: <GBadge :tone="statusTone(order.status as OrderStatus)">{{ statusLabel(order.status as OrderStatus) }}</GBadge></label>
          <select :value="order.status" class="w-full h-10 px-3 rounded-md border border-neutral-300 bg-white text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" @change="updateStatus(($event.target as HTMLSelectElement).value)">
            <option v-for="s in statusOptions" :key="s" :value="s">{{ statusLabel(s) }}</option>
          </select>
          <p class="text-xs text-neutral-400 mt-2">Perubahan status memicu notifikasi otomatis ke pembeli (di MVP1).</p>
        </GCard>

        <GCard title="Fulfillment">
          <p class="text-sm"><span class="text-neutral-500">Tipe:</span><span class="font-medium ml-2">{{ order.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor' }}</span></p>
          <p v-if="distributor" class="text-sm mt-2"><span class="text-neutral-500">Distributor:</span><span class="font-medium ml-2">{{ distributor.legalName }}</span></p>
          <NuxtLink v-if="distributor" :to="`/distributors/${distributor.id}`" class="text-sm text-brand-600 hover:text-brand-700 mt-2 inline-block">Lihat distributor →</NuxtLink>
        </GCard>

        <GButton variant="secondary" full-width icon="⎙" @click="printInvoice">Cetak Invoice</GButton>
      </div>
    </div>
  </div>
</template>
