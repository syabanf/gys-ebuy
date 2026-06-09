<script setup lang="ts">
import { GCard } from '@gys/ui'
import { useCatalogStore } from '~/composables/useCatalogStore'
import { useUomStore } from '~/composables/useUomStore'
import { useUsersStore } from '~/composables/useUsersStore'
import { useDistributorsStore } from '~/composables/useDistributorsStore'
import { usePricingStore } from '~/composables/usePricingStore'

const catalog = useCatalogStore()
const uom = useUomStore()
const users = useUsersStore()
const distributors = useDistributorsStore()
const pricing = usePricingStore()
const loading = ref(true)

onMounted(async () => {
  await Promise.all([catalog.load(), uom.load(), users.load(), distributors.load(), pricing.load()])
  loading.value = false
})

const entities = computed(() => [
  { label: 'Produk', icon: '◷', tone: 'brand', count: catalog.products.length, to: '/catalog', desc: 'Katalog master produk & harga pusat' },
  { label: 'Kategori', icon: '☰', tone: 'info', count: catalog.categories.length, to: '/master-data/categories', desc: 'Kelompok produk baja' },
  { label: 'Satuan (UoM)', icon: '⚖', tone: 'warning', count: uom.items.length, to: '/master-data/uom', desc: 'Unit of measure: batang, lembar, kg…' },
  { label: 'Distributor', icon: '◰', tone: 'success', count: distributors.list.length, to: '/distributors', desc: 'Jaringan distributor' },
  { label: 'Pricing Scope', icon: '◉', tone: 'brand', count: pricing.scopes.length, to: '/pricing-scopes', desc: 'Strategi harga pusat vs distributor' },
  { label: 'Pengguna & Peran', icon: '◌', tone: 'danger', count: users.items.length, to: '/master-data/users', desc: 'Akun internal & distributor' },
])

const toneBg: Record<string, string> = {
  brand: 'bg-brand-50 text-brand-700', info: 'bg-blue-50 text-blue-700', warning: 'bg-amber-50 text-amber-700',
  success: 'bg-emerald-50 text-emerald-700', danger: 'bg-red-50 text-red-700',
}
</script>

<template>
  <div class="p-6 max-w-7xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-neutral-900">Master Data</h1>
      <p class="text-sm text-neutral-500 mt-1">Kelola data acuan platform: produk, kategori, satuan, distributor, harga, dan pengguna.</p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      <NuxtLink v-for="e in entities" :key="e.to" :to="e.to" class="group">
        <GCard class="transition-all duration-200 group-hover:shadow-elevated group-hover:border-brand-300 group-hover:-translate-y-0.5">
          <div class="flex items-start gap-4">
            <div class="h-12 w-12 rounded-xl flex items-center justify-center text-xl flex-shrink-0" :class="toneBg[e.tone]">{{ e.icon }}</div>
            <div class="min-w-0 flex-1">
              <div class="flex items-center justify-between gap-2">
                <h2 class="text-base font-semibold text-neutral-900">{{ e.label }}</h2>
                <span class="text-lg font-bold text-neutral-900 tabular-nums">{{ loading ? '…' : e.count }}</span>
              </div>
              <p class="text-sm text-neutral-500 mt-1">{{ e.desc }}</p>
              <p class="text-sm text-brand-600 font-medium mt-3 group-hover:text-brand-700">Kelola →</p>
            </div>
          </div>
        </GCard>
      </NuxtLink>
    </div>
  </div>
</template>
