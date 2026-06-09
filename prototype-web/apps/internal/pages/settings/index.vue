<script setup lang="ts">
import { GBadge, GButton, GCard, GInput, GLabel } from '@gys/ui'
import { useSessionStore } from '~/composables/useSession'

const session = useSessionStore()

const general = ref({
  platformName: 'GYS E-Ordering',
  supportEmail: 'support@gys.co.id',
  defaultTax: 11,
  currency: 'IDR',
})

const integrations = [
  { name: 'SAP S/4HANA', desc: 'Contract & Sales Order, Customer Master', status: 'pending', note: 'MVP2' },
  { name: 'TADA Loyalty', desc: 'Akrual poin & tier member', status: 'pending', note: 'MVP2' },
  { name: 'LDAP / Active Directory', desc: 'Autentikasi internal GYS', status: 'connected', note: '' },
  { name: 'Midtrans Payment', desc: 'Virtual Account, QRIS, Kartu Kredit', status: 'connected', note: '' },
  { name: 'Firebase Cloud Messaging', desc: 'Push notification mobile', status: 'connected', note: '' },
]

const features = reactive({
  buyerSelfOnboard: false,
  perDistributorPricing: true,
  autoDisbursement: false,
  multiLanguage: false,
})

const saved = ref(false)
function save() { saved.value = true; setTimeout(() => (saved.value = false), 2000) }

function statusBadge(s: string) {
  return s === 'connected'
    ? { label: 'Terhubung', tone: 'success' as const }
    : { label: 'Belum dikonfigurasi', tone: 'warning' as const }
}
</script>

<template>
  <div class="p-6 max-w-4xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-neutral-900">Pengaturan Sistem</h1>
      <p class="text-sm text-neutral-500 mt-1">Konfigurasi platform, integrasi, dan fitur. Khusus IT Admin.</p>
    </div>

    <GCard title="Umum">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div><GLabel for="pn">Nama Platform</GLabel><GInput id="pn" v-model="general.platformName" /></div>
        <div><GLabel for="se">Email Support</GLabel><GInput id="se" v-model="general.supportEmail" /></div>
        <div><GLabel for="tx">PPN Default (%)</GLabel><GInput id="tx" v-model="general.defaultTax" type="number" /></div>
        <div><GLabel for="cu">Mata Uang</GLabel><GInput id="cu" v-model="general.currency" /></div>
      </div>
    </GCard>

    <GCard title="Integrasi" description="Status koneksi sistem eksternal">
      <ul class="divide-y divide-neutral-100 -my-2">
        <li v-for="i in integrations" :key="i.name" class="flex items-center justify-between py-3 gap-4">
          <div class="min-w-0">
            <p class="text-sm font-medium text-neutral-900">{{ i.name }} <span v-if="i.note" class="text-xs text-neutral-400 font-normal">· {{ i.note }}</span></p>
            <p class="text-xs text-neutral-500">{{ i.desc }}</p>
          </div>
          <GBadge :tone="statusBadge(i.status).tone">{{ statusBadge(i.status).label }}</GBadge>
        </li>
      </ul>
    </GCard>

    <GCard title="Fitur Platform">
      <ul class="divide-y divide-neutral-100 -my-2">
        <li v-for="(item, key) in { buyerSelfOnboard: 'Pendaftaran pembeli mandiri (tanpa approval manual)', perDistributorPricing: 'Harga per-distributor', autoDisbursement: 'Disbursement otomatis ke distributor', multiLanguage: 'Dukungan multi-bahasa (EN)' }" :key="key" class="flex items-center justify-between py-3 gap-4">
          <span class="text-sm text-neutral-700">{{ item }}</span>
          <button type="button" :class="['relative h-6 w-11 rounded-full transition-colors flex-shrink-0', features[key] ? 'bg-brand-500' : 'bg-neutral-300']" @click="features[key] = !features[key]">
            <span :class="['absolute top-0.5 h-5 w-5 rounded-full bg-white transition-transform', features[key] ? 'translate-x-5' : 'translate-x-0.5']" />
          </button>
        </li>
      </ul>
    </GCard>

    <div class="flex items-center gap-3">
      <GButton @click="save">Simpan Perubahan</GButton>
      <span v-if="saved" class="text-sm text-success">✓ Tersimpan</span>
      <span class="text-xs text-neutral-400 ml-auto">Masuk sebagai {{ session.user?.displayName }} (IT Admin)</span>
    </div>
  </div>
</template>
