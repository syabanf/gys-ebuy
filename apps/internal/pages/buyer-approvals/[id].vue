<script setup lang="ts">
import { GBadge, GButton, GCard, GStatCard, GDataTable, GLabel, GModal, formatIDR, formatDate, formatDateTime, statusLabel, statusTone } from '@gys/ui'
import type { OrderStatus } from '@gys/ui'
import { useMockApi } from '~/composables/useMockApi'

const route = useRoute()
const router = useRouter()
const api = useMockApi()

const buyer = ref<any>(null)
const orders = ref<any[]>([])
const loading = ref(true)
const showApprove = ref(false)
const showReject = ref(false)
const rejectReason = ref('')

onMounted(async () => {
  const id = route.params.id as string
  buyer.value = await api.getBuyer(id)
  if (!buyer.value) { router.push('/buyer-approvals'); return }
  const all = await api.listOrders()
  orders.value = all.filter((o) => o.buyerId === id)
  loading.value = false
})

const stats = computed(() => {
  const completed = orders.value.filter((o) => ['completed', 'delivered'].includes(o.status))
  const spent = completed.reduce((s, o) => s + o.total, 0)
  return {
    orders: orders.value.length,
    spent,
    aov: completed.length ? Math.round(spent / completed.length) : 0,
    lastOrder: orders.value.length ? orders.value.map((o) => o.placedAt).sort().at(-1) : null,
  }
})

const orderColumns = [
  { key: 'orderNumber', label: 'No. Pesanan' },
  { key: 'placedAt', label: 'Tanggal', width: '160px' },
  { key: 'items', label: 'Item', align: 'right' as const, width: '90px' },
  { key: 'total', label: 'Total', align: 'right' as const, width: '150px' },
  { key: 'status', label: 'Status', width: '150px' },
]

function approve() {
  buyer.value.approvalStatus = 'approved'
  buyer.value.approvedAt = new Date().toISOString()
  showApprove.value = false
}

function reject() {
  buyer.value.approvalStatus = 'rejected'
  buyer.value.rejectedReason = rejectReason.value
  showReject.value = false
}

function businessTypeLabel(t: string) {
  return { fabricator: 'Fabrikator', contractor: 'Kontraktor', retailer: 'Retail', 'sub-distributor': 'Sub-Distributor' }[t] ?? t
}
</script>

<template>
  <div v-if="loading" class="p-6 max-w-5xl mx-auto">
    <div class="h-8 bg-neutral-100 rounded w-64 animate-pulse mb-4" />
    <div class="h-96 bg-neutral-100 rounded animate-pulse" />
  </div>

  <div v-else-if="buyer" class="p-6 max-w-5xl mx-auto space-y-6">
    <div>
      <button class="text-sm text-brand-600 hover:text-brand-700 mb-2" @click="router.push('/buyer-approvals')">← Kembali ke daftar</button>
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <div class="flex items-center gap-3">
            <h1 class="text-2xl font-semibold text-neutral-900">{{ buyer.companyName }}</h1>
            <GBadge
              :tone="buyer.approvalStatus === 'approved' ? 'success' : buyer.approvalStatus === 'rejected' ? 'danger' : 'warning'"
              size="md"
            >
              {{ { pending: 'Menunggu', approved: 'Disetujui', rejected: 'Ditolak' }[buyer.approvalStatus as string] }}
            </GBadge>
          </div>
          <p class="text-sm text-neutral-500 mt-1">{{ businessTypeLabel(buyer.businessType) }} · Diajukan {{ formatDate(buyer.submittedAt ?? buyer.approvedAt) }}</p>
        </div>
        <div v-if="buyer.approvalStatus === 'pending'" class="flex gap-2">
          <GButton variant="danger" @click="showReject = true">Tolak</GButton>
          <GButton @click="showApprove = true">Setujui</GButton>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <GCard title="Detail Perusahaan">
          <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 text-sm">
            <div><dt class="text-neutral-500">Nama Perusahaan</dt><dd class="font-medium mt-0.5">{{ buyer.companyName }}</dd></div>
            <div><dt class="text-neutral-500">Tipe Bisnis</dt><dd class="font-medium mt-0.5">{{ businessTypeLabel(buyer.businessType) }}</dd></div>
            <div><dt class="text-neutral-500">NPWP</dt><dd class="font-mono mt-0.5">{{ buyer.npwp }}</dd></div>
            <div><dt class="text-neutral-500">Email</dt><dd class="font-medium mt-0.5">{{ buyer.email }}</dd></div>
            <div><dt class="text-neutral-500">Kontak Utama</dt><dd class="font-medium mt-0.5">{{ buyer.contactName }}</dd></div>
            <div><dt class="text-neutral-500">Telepon</dt><dd class="font-medium mt-0.5">{{ buyer.phone }}</dd></div>
            <div class="sm:col-span-2"><dt class="text-neutral-500">Alamat</dt><dd class="font-medium mt-0.5">{{ buyer.address }}</dd></div>
          </dl>
        </GCard>

        <GCard title="Dokumen KYC" :description="`${buyer.kycDocs.length} berkas diunggah`">
          <ul class="divide-y divide-neutral-100 -mx-5 -my-5">
            <li v-for="doc in buyer.kycDocs" :key="doc.fileName" class="px-5 py-3 flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="h-10 w-10 rounded-md bg-brand-50 text-brand-700 flex items-center justify-center font-semibold text-xs">PDF</div>
                <div>
                  <p class="text-sm font-medium text-neutral-900">{{ doc.type.replace('_', ' ') }}</p>
                  <p class="text-xs text-neutral-500">{{ doc.fileName }} · diunggah {{ formatDate(doc.uploadedAt) }}</p>
                </div>
              </div>
              <button class="text-sm text-brand-600 hover:text-brand-700 font-medium">Pratinjau</button>
            </li>
          </ul>
        </GCard>
      </div>

      <div class="space-y-6">
        <GCard title="Checklist Verifikasi">
          <ul class="space-y-3 text-sm">
            <li class="flex items-start gap-2"><input type="checkbox" class="mt-1" /><span>NPWP sesuai dengan dokumen NIB</span></li>
            <li class="flex items-start gap-2"><input type="checkbox" class="mt-1" /><span>KTP direksi terbaca jelas</span></li>
            <li class="flex items-start gap-2"><input type="checkbox" class="mt-1" /><span>Alamat sesuai NIB</span></li>
            <li class="flex items-start gap-2"><input type="checkbox" class="mt-1" /><span>Tidak ada indikasi sanksi/pengaduan</span></li>
          </ul>
        </GCard>

        <GCard title="Riwayat">
          <ol class="space-y-3 text-sm">
            <li>
              <p class="font-medium text-neutral-900">Pendaftaran Diajukan</p>
              <p class="text-xs text-neutral-500">{{ formatDate(buyer.submittedAt ?? buyer.approvedAt) }}</p>
            </li>
            <li v-if="buyer.approvedAt">
              <p class="font-medium text-success">Disetujui</p>
              <p class="text-xs text-neutral-500">{{ formatDate(buyer.approvedAt) }}</p>
            </li>
          </ol>
        </GCard>
      </div>
    </div>

    <!-- Stats + order history -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <GStatCard label="Total Pesanan" :value="stats.orders" icon="◫" />
      <GStatCard label="Total Belanja" :value="formatIDR(stats.spent)" icon="◉" />
      <GStatCard label="Rata-rata Pesanan" :value="formatIDR(stats.aov)" icon="∼" />
      <GStatCard label="Pesanan Terakhir" :value="stats.lastOrder ? formatDate(stats.lastOrder) : '—'" icon="◷" />
    </div>

    <div>
      <h2 class="text-base font-semibold text-neutral-900 mb-3">Riwayat Pesanan</h2>
      <GDataTable :columns="orderColumns" :rows="orders" empty-title="Belum ada pesanan dari pembeli ini" @row-click="(row) => router.push(`/orders/${row.id}`)">
        <template #cell-orderNumber="{ row }"><span class="font-medium text-neutral-900">{{ row.orderNumber }}</span></template>
        <template #cell-placedAt="{ row }"><span class="text-neutral-600 text-sm">{{ formatDateTime(row.placedAt) }}</span></template>
        <template #cell-items="{ row }"><span class="text-neutral-600">{{ row.items.length }}</span></template>
        <template #cell-total="{ row }"><span class="font-semibold">{{ formatIDR(row.total) }}</span></template>
        <template #cell-status="{ row }"><GBadge :tone="statusTone(row.status as OrderStatus)">{{ statusLabel(row.status as OrderStatus) }}</GBadge></template>
      </GDataTable>
    </div>

    <GModal :open="showApprove" title="Setujui pendaftaran?" @close="showApprove = false">
      <p class="text-sm text-neutral-700">Pembeli akan dapat mengakses katalog dan melakukan pemesanan setelah disetujui. Tindakan ini akan mengirim notifikasi otomatis ke email pembeli.</p>
      <template #footer>
        <GButton variant="secondary" @click="showApprove = false">Batal</GButton>
        <GButton @click="approve">Ya, Setujui</GButton>
      </template>
    </GModal>

    <GModal :open="showReject" title="Tolak pendaftaran" @close="showReject = false">
      <GLabel for="reason" required>Alasan penolakan</GLabel>
      <textarea
        id="reason"
        v-model="rejectReason"
        rows="4"
        class="w-full p-3 rounded-md border border-neutral-300 text-sm focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500"
        placeholder="Jelaskan alasan penolakan; akan dikirimkan ke pembeli melalui email."
      />
      <template #footer>
        <GButton variant="secondary" @click="showReject = false">Batal</GButton>
        <GButton variant="danger" :disabled="!rejectReason.trim()" @click="reject">Tolak Pendaftaran</GButton>
      </template>
    </GModal>
  </div>
</template>
