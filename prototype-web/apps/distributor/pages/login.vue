<script setup lang="ts">
import { GButton, GInput, GLabel } from '@gys/ui'
import { useSessionStore } from '~/composables/useSession'

definePageMeta({ layout: false })

const session = useSessionStore()
const route = useRoute()
const router = useRouter()

const username = ref('budi.mitrabaja')
const password = ref('demo')
const loading = ref(false)
const error = ref<string | null>(null)

async function onSubmit() {
  error.value = null
  loading.value = true
  await new Promise((r) => setTimeout(r, 600))
  loading.value = false
  const ok = session.login(username.value.trim())
  if (!ok) {
    error.value = 'Username atau password tidak ditemukan. Coba budi.mitrabaja atau sri.suryalogam.'
    return
  }
  router.push((route.query.redirect as string) || '/')
}

const demoAccounts = [
  { username: 'budi.mitrabaja', name: 'PT Mitra Baja Sentosa', city: 'Jakarta' },
  { username: 'sri.suryalogam', name: 'CV Surya Logam', city: 'Surabaya' },
  { username: 'rahmat.andalas', name: 'PT Andalas Steel', city: 'Medan' },
  { username: 'asep.priangan', name: 'PT Priangan Baja', city: 'Bandung' },
]
function quickLogin(uname: string) {
  if (session.login(uname)) router.push((route.query.redirect as string) || '/')
}

const perks = [
  { icon: '◫', title: 'Kelola pesanan real-time', body: 'Terima, proses, dan lacak pengiriman dalam satu layar.' },
  { icon: '☷', title: 'Kontrol stok & harga', body: 'Atur inventori dan harga produk dengan mudah.' },
  { icon: '◉', title: 'Laporan & analitik', body: 'Pantau performa penjualan distributor Anda.' },
]
</script>

<template>
  <div class="min-h-screen flex">
    <!-- Brand panel -->
    <div class="hidden lg:flex flex-col justify-between w-1/2 bg-gradient-to-br from-brand-600 via-brand-700 to-brand-900 p-12 text-white relative overflow-hidden">
      <div class="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-white/5" />
      <div class="absolute -left-10 bottom-10 h-40 w-40 rounded-full bg-white/5" />
      <div class="relative flex items-center gap-3">
        <div class="h-11 w-11 rounded-xl bg-white text-brand-700 font-bold flex items-center justify-center">GYS</div>
        <div>
          <p class="font-semibold leading-tight">GYS Distributor</p>
          <p class="text-xs text-white/70">Garuda Yamato Steel</p>
        </div>
      </div>
      <div class="relative">
        <h1 class="text-3xl font-bold leading-tight">Portal Distributor<br />GYS E-Ordering</h1>
        <p class="mt-3 text-white/80 max-w-sm">Satu platform untuk mengelola pesanan, stok, pengiriman, dan laporan bisnis distribusi baja Anda.</p>
        <ul class="mt-8 space-y-4">
          <li v-for="p in perks" :key="p.title" class="flex items-start gap-3">
            <span class="h-9 w-9 rounded-lg bg-white/15 flex items-center justify-center text-lg flex-shrink-0">{{ p.icon }}</span>
            <div>
              <p class="font-medium">{{ p.title }}</p>
              <p class="text-sm text-white/70">{{ p.body }}</p>
            </div>
          </li>
        </ul>
      </div>
      <p class="relative text-xs text-white/60">© 2026 PT Garuda Yamato Steel · Prototype Phase 0</p>
    </div>

    <!-- Form panel -->
    <div class="flex-1 flex items-center justify-center bg-neutral-50 p-6">
      <div class="w-full max-w-sm">
        <div class="lg:hidden text-center mb-8">
          <div class="inline-flex h-14 w-14 rounded-xl bg-brand-500 text-white items-center justify-center font-bold text-xl shadow-elevated">GYS</div>
        </div>
        <h2 class="text-2xl font-semibold text-neutral-900">Selamat datang 👋</h2>
        <p class="text-sm text-neutral-500 mt-1 mb-8">Masuk untuk melanjutkan ke portal distributor.</p>

        <form class="space-y-4" @submit.prevent="onSubmit">
          <div>
            <GLabel for="username" required>Username</GLabel>
            <GInput id="username" v-model="username" autocomplete="username" placeholder="contoh: budi.mitrabaja" />
          </div>
          <div>
            <GLabel for="password" required>Password</GLabel>
            <GInput id="password" v-model="password" type="password" autocomplete="current-password" />
            <p class="text-xs text-neutral-500 mt-1">Prototype: password apa saja diterima.</p>
          </div>
          <p v-if="error" class="text-sm text-danger bg-red-50 border border-red-200 rounded-lg px-3 py-2">{{ error }}</p>
          <GButton type="submit" :loading="loading" full-width size="lg">Masuk</GButton>
        </form>

        <div class="mt-8 pt-6 border-t border-neutral-200">
          <p class="text-xs font-semibold uppercase tracking-wider text-neutral-400 mb-3">Login Cepat (Demo)</p>
          <div class="grid grid-cols-2 gap-2">
            <button
              v-for="a in demoAccounts"
              :key="a.username"
              type="button"
              class="flex items-center gap-2.5 p-2.5 rounded-lg border border-neutral-200 hover:border-brand-400 hover:bg-brand-50 transition-colors text-left"
              @click="quickLogin(a.username)"
            >
              <span class="h-8 w-8 rounded-lg bg-brand-50 text-brand-700 text-sm flex items-center justify-center flex-shrink-0">◰</span>
              <span class="min-w-0">
                <span class="block text-sm font-medium text-neutral-900 truncate">{{ a.name }}</span>
                <span class="block text-xs text-neutral-500">{{ a.city }}</span>
              </span>
            </button>
          </div>
        </div>

        <p class="text-center text-xs text-neutral-500 mt-6">Belum punya akun distributor? Hubungi tim GYS Sales.</p>
      </div>
    </div>
  </div>
</template>
