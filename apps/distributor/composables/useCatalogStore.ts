import { defineStore } from 'pinia'
import seedProducts from '../../../mocks/fixtures/products.json'
import seedCategories from '../../../mocks/fixtures/categories.json'

export interface Product {
  id: string
  sku: string
  name: string
  categoryId: string
  uom: string
  weightKg: number
  centralPrice: number
  status: string
}

export interface Category { id: string; code: string; name: string; description?: string }

let seq = 0

export const useCatalogStore = defineStore('distCatalog', {
  state: () => ({ products: [] as Product[], categories: [] as Category[], loaded: false }),
  getters: {
    categoryName: (state) => (id: string) => state.categories.find((c) => c.id === id)?.name ?? '—',
    activeCount: (state) => state.products.filter((p) => p.status === 'active').length,
  },
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 200))
      this.products = JSON.parse(JSON.stringify(seedProducts)) as Product[]
      this.categories = JSON.parse(JSON.stringify(seedCategories)) as Category[]
      this.loaded = true
    },
    getById(id: string) { return this.products.find((p) => p.id === id) ?? null },
    create(payload: Omit<Product, 'id'>) {
      seq += 1
      const id = `p-dist-${Date.now()}-${seq}`
      this.products.unshift({ ...payload, id })
      return id
    },
    update(id: string, payload: Partial<Product>) {
      const idx = this.products.findIndex((p) => p.id === id)
      if (idx !== -1) this.products[idx] = { ...this.products[idx], ...payload }
    },
    remove(id: string) { this.products = this.products.filter((p) => p.id !== id) },
    removeMany(ids: string[]) { const s = new Set(ids); this.products = this.products.filter((p) => !s.has(p.id)) },
  },
})
