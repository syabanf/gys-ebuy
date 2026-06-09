<script setup lang="ts">
import { GBadge, GButton, GCard, formatIDR } from '@gys/ui'
import { useCatalogStore } from '~/composables/useCatalogStore'

const route = useRoute()
const router = useRouter()
const store = useCatalogStore()
const loading = ref(true)
const product = ref<any>(null)

onMounted(async () => {
  await store.load()
  product.value = store.getById(route.params.id as string)
  loading.value = false
  if (!product.value) router.push('/catalog')
})
</script>

<template>
  <div v-if="loading" class="p-6 max-w-5xl mx-auto">
    <div class="h-8 bg-neutral-100 rounded w-64 animate-pulse mb-4" />
    <div class="h-64 bg-neutral-100 rounded animate-pulse" />
  </div>

  <div v-else-if="product" class="p-6 max-w-5xl mx-auto space-y-6">
    <div>
      <button class="text-sm text-brand-600 hover:text-brand-700 mb-2" @click="router.push('/catalog')">← Kembali ke katalog</button>
      <div class="flex items-center gap-3 flex-wrap">
        <h1 class="text-2xl font-semibold text-neutral-900">{{ product.name }}</h1>
        <GBadge :tone="product.status === 'active' ? 'success' : 'neutral'" size="md">{{ product.status === 'active' ? 'Aktif' : 'Nonaktif' }}</GBadge>
      </div>
      <p class="text-sm text-neutral-500 mt-1 font-mono">SKU {{ product.sku }}</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <GCard class="lg:col-span-2" title="Detail Produk">
        <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 text-sm">
          <div><dt class="text-neutral-500 text-xs">Nama</dt><dd class="font-medium">{{ product.name }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">SKU</dt><dd class="font-mono">{{ product.sku }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Kategori</dt><dd class="font-medium">{{ store.categoryName(product.categoryId) }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Satuan</dt><dd class="font-medium">{{ product.uom }}</dd></div>
          <div><dt class="text-neutral-500 text-xs">Berat</dt><dd class="font-medium">{{ product.weightKg }} kg</dd></div>
          <div><dt class="text-neutral-500 text-xs">Status</dt><dd class="font-medium">{{ product.status === 'active' ? 'Aktif' : 'Nonaktif' }}</dd></div>
        </dl>
      </GCard>

      <div class="space-y-6">
        <GCard title="Harga Pusat">
          <p class="text-3xl font-bold text-brand-700">{{ formatIDR(product.centralPrice) }}</p>
          <p class="text-sm text-neutral-500 mt-1">per {{ product.uom }}</p>
          <p class="text-xs text-neutral-400 mt-3">Berlaku ke semua distributor kecuali ada override per-distributor.</p>
        </GCard>
        <GButton variant="secondary" full-width @click="router.push('/catalog')">Ubah di Katalog</GButton>
      </div>
    </div>
  </div>
</template>
