<script setup lang="ts">
import { GButton, GCard, GInput, GLabel } from '@gys/ui'
import { useSessionStore } from '~/composables/useSession'

const session = useSessionStore()

const company = ref({
  name: 'PT Mitra Baja Sentosa',
  npwp: '01.234.567.8-001.000',
  phone: '+62-21-5550-1234',
  email: 'budi@mitrabaja.co.id',
})

const shipping = ref({ defaultLeadTime: 3, freeShippingMin: 50000000, baseCost: 250000 })

const notif = reactive({ newOrder: true, lowStock: true, payment: true, weekly: false })
const saved = ref(false)
function save() { saved.value = true; setTimeout(() => (saved.value = false), 2000) }
</script>

<template>
  <div class="p-6 max-w-4xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-neutral-900">Pengaturan</h1>
      <p class="text-sm text-neutral-500 mt-1">Kelola profil distributor, pengiriman, dan notifikasi.</p>
    </div>

    <GCard title="Profil Perusahaan">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div><GLabel for="cn">Nama Perusahaan</GLabel><GInput id="cn" v-model="company.name" /></div>
        <div><GLabel for="np">NPWP</GLabel><GInput id="np" v-model="company.npwp" /></div>
        <div><GLabel for="ph">Telepon</GLabel><GInput id="ph" v-model="company.phone" /></div>
        <div><GLabel for="em">Email</GLabel><GInput id="em" v-model="company.email" /></div>
      </div>
    </GCard>

    <GCard title="Pengaturan Pengiriman">
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div><GLabel for="lt">Lead Time Default (hari)</GLabel><GInput id="lt" v-model="shipping.defaultLeadTime" type="number" /></div>
        <div><GLabel for="fm">Min. Gratis Ongkir (IDR)</GLabel><GInput id="fm" v-model="shipping.freeShippingMin" type="number" /></div>
        <div><GLabel for="bc">Biaya Dasar (IDR)</GLabel><GInput id="bc" v-model="shipping.baseCost" type="number" /></div>
      </div>
    </GCard>

    <GCard title="Notifikasi">
      <ul class="divide-y divide-neutral-100 -my-2">
        <li v-for="(item, key) in { newOrder: 'Pesanan baru masuk', lowStock: 'Peringatan stok rendah', payment: 'Pembayaran diterima', weekly: 'Ringkasan mingguan' }" :key="key" class="flex items-center justify-between py-3">
          <span class="text-sm text-neutral-700">{{ item }}</span>
          <button
            type="button"
            :class="['relative h-6 w-11 rounded-full transition-colors', notif[key] ? 'bg-brand-500' : 'bg-neutral-300']"
            @click="notif[key] = !notif[key]"
          >
            <span :class="['absolute top-0.5 h-5 w-5 rounded-full bg-white transition-transform', notif[key] ? 'translate-x-5' : 'translate-x-0.5']" />
          </button>
        </li>
      </ul>
    </GCard>

    <div class="flex items-center gap-3">
      <GButton @click="save">Simpan Perubahan</GButton>
      <span v-if="saved" class="text-sm text-success">✓ Tersimpan</span>
      <span class="text-xs text-neutral-400 ml-auto">Masuk sebagai {{ session.user?.displayName }}</span>
    </div>
  </div>
</template>
