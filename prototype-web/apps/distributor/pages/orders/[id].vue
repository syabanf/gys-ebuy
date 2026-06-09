<script setup lang="ts">
import { GBadge, GButton, GCard, formatIDR, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'

const route = useRoute()
const router = useRouter()
const api = useMockApi()

const order = ref<any>(null)
const buyer = ref<any>(null)
const products = ref<Record<string, any>>({})
const loading = ref(true)

onMounted(async () => {
  const o = await api.getOrder(route.params.id as string)
  if (!o) {
    router.push('/orders')
    return
  }
  order.value = o
  buyer.value = await api.getBuyer(o.buyerId)
  const all = await api.listProducts()
  products.value = Object.fromEntries(all.map((p) => [p.id, p]))
  loading.value = false
})

const timeline = computed(() => {
  if (!order.value) return []
  const o = order.value
  const events = [
    { label: 'Pesanan Dibuat', at: o.placedAt },
    o.status !== 'cancelled' && { label: 'Pembayaran Diterima', at: o.placedAt },
    o.shippedAt && { label: 'Dikirim', at: o.shippedAt },
    o.deliveredAt && { label: 'Terkirim ke Pembeli', at: o.deliveredAt },
    o.completedAt && { label: 'Pesanan Selesai', at: o.completedAt },
    o.cancelledAt && { label: 'Dibatalkan', at: o.cancelledAt, danger: true },
  ].filter(Boolean) as Array<{ label: string; at: string; danger?: boolean }>
  return events
})

function printDeliveryNote() {
  const o = order.value
  if (!o) return
  const rows = o.items.map((it: any) => `<tr><td>${products.value[it.productId]?.name ?? ''}<br><span class="muted">${products.value[it.productId]?.sku ?? ''}</span></td><td class="r">${it.qty} ${products.value[it.productId]?.uom ?? ''}</td></tr>`).join('')
  printHtml(`Surat Jalan ${o.orderNumber}`, `
    <div class="head"><div style="display:flex;gap:10px;align-items:center"><div class="logo">GYS</div><div><strong>PT Garuda Yamato Steel</strong><div class="muted">Surat Jalan / Delivery Note</div></div></div>
      <div style="text-align:right"><h1>SURAT JALAN</h1><div class="muted">${o.orderNumber}</div><div class="muted">${formatDateTime(o.placedAt)}</div></div></div>
    <div class="grid">
      <div><h3>Kirim ke</h3><strong>${buyer.value?.companyName ?? ''}</strong><div class="muted">${buyer.value?.address ?? ''}</div><div class="muted">${buyer.value?.phone ?? ''}</div></div>
      <div><h3>Pengiriman</h3>${o.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Via Distributor'}<div class="muted">No. SJ: GYS-SJ-${o.orderNumber.split('-').pop()}</div></div>
    </div>
    <table><thead><tr><th>Produk</th><th class="r">Qty</th></tr></thead><tbody>${rows}</tbody></table>
    <div class="grid" style="margin-top:48px">
      <div><div class="muted">Pengirim,</div><div style="margin-top:48px;border-top:1px solid #18181b;width:160px"></div></div>
      <div style="text-align:right"><div class="muted">Penerima,</div><div style="margin-top:48px;border-top:1px solid #18181b;width:160px;margin-left:auto"></div></div>
    </div>
  `)
}

function accept() {
  order.value.status = 'accepted_by_distributor'
}

function markShipped() {
  order.value.status = 'shipped'
  order.value.shippedAt = new Date().toISOString()
}
</script>

<template>
  <div v-if="loading" class="p-6 max-w-7xl mx-auto">
    <div class="h-8 bg-neutral-100 rounded w-64 animate-pulse mb-4" />
    <div class="h-96 bg-neutral-100 rounded animate-pulse" />
  </div>

  <div v-else-if="order" class="p-6 max-w-7xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <button class="text-sm text-brand-600 hover:text-brand-700 mb-2" @click="router.push('/orders')">← Kembali ke daftar pesanan</button>
        <div class="flex items-center gap-3">
          <h1 class="text-2xl font-semibold text-neutral-900">{{ order.orderNumber }}</h1>
          <GBadge :tone="statusTone(order.status as OrderStatus)" size="md">{{ statusLabel(order.status as OrderStatus) }}</GBadge>
        </div>
        <p class="text-sm text-neutral-500 mt-1">Dibuat {{ formatDateTime(order.placedAt) }}</p>
      </div>
      <div class="flex gap-2">
        <GButton v-if="order.status === 'paid'" @click="accept">Terima Pesanan</GButton>
        <GButton v-if="order.status === 'accepted_by_distributor' || order.status === 'in_fulfillment'" @click="markShipped">Tandai Dikirim</GButton>
        <GButton variant="secondary" icon="⎙" @click="printDeliveryNote">Cetak Surat Jalan</GButton>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <GCard title="Item Pesanan">
          <table class="w-full text-sm -mx-5">
            <thead class="text-xs uppercase text-neutral-500">
              <tr class="border-b border-neutral-100">
                <th class="text-left px-5 py-2">Produk</th>
                <th class="text-right px-5 py-2">Qty</th>
                <th class="text-right px-5 py-2">Harga Satuan</th>
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
              <tr>
                <td colspan="3" class="px-5 py-2 text-right text-neutral-500">Subtotal</td>
                <td class="px-5 py-2 text-right font-medium">{{ formatIDR(order.subtotal) }}</td>
              </tr>
              <tr>
                <td colspan="3" class="px-5 py-2 text-right text-neutral-500">Biaya Kirim</td>
                <td class="px-5 py-2 text-right font-medium">{{ formatIDR(order.shippingFee) }}</td>
              </tr>
              <tr class="bg-neutral-50">
                <td colspan="3" class="px-5 py-3 text-right font-semibold">Total</td>
                <td class="px-5 py-3 text-right font-bold text-lg">{{ formatIDR(order.total) }}</td>
              </tr>
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

        <GCard title="Pengiriman">
          <p class="text-sm">
            <span class="text-neutral-500">Tipe:</span>
            <span class="font-medium ml-2">{{ order.fulfillmentType === 'gys_direct' ? 'GYS Langsung' : 'Melalui Distributor' }}</span>
          </p>
          <p v-if="order.shippedAt" class="text-sm mt-2">
            <span class="text-neutral-500">Dikirim:</span>
            <span class="font-medium ml-2">{{ formatDateTime(order.shippedAt) }}</span>
          </p>
          <p v-if="order.deliveredAt" class="text-sm mt-2">
            <span class="text-neutral-500">Diterima:</span>
            <span class="font-medium ml-2">{{ formatDateTime(order.deliveredAt) }}</span>
          </p>
        </GCard>
      </div>
    </div>
  </div>
</template>
