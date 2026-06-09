import { defineStore } from 'pinia'
import seedInventory from '../../../mocks/fixtures/inventory.json'
import seedProducts from '../../../mocks/fixtures/products.json'

export interface Product {
  id: string
  sku: string
  name: string
  uom: string
  centralPrice: number
}

export interface InventoryRow {
  distributorId: string
  productId: string
  onHand: number
  reserved: number
  safetyStock: number
  leadTimeDays: number
}

export const useInventoryStore = defineStore('inventory', {
  state: () => ({
    rows: [] as InventoryRow[],
    products: [] as Product[],
    loaded: false,
  }),
  getters: {
    product: (state) => (id: string) => state.products.find((p) => p.id === id),
    rowsFor: (state) => (distributorId: string) =>
      state.rows
        .filter((r) => r.distributorId === distributorId)
        .map((r) => ({ ...r, product: state.products.find((p) => p.id === r.productId) })),
  },
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 200))
      this.rows = JSON.parse(JSON.stringify(seedInventory)) as InventoryRow[]
      this.products = JSON.parse(JSON.stringify(seedProducts)) as Product[]
      this.loaded = true
    },
    availableProducts(distributorId: string) {
      const have = new Set(this.rows.filter((r) => r.distributorId === distributorId).map((r) => r.productId))
      return this.products.filter((p) => !have.has(p.id))
    },
    updateStock(distributorId: string, productId: string, patch: Partial<InventoryRow>) {
      const row = this.rows.find((r) => r.distributorId === distributorId && r.productId === productId)
      if (row) Object.assign(row, patch)
    },
    addRow(distributorId: string, productId: string, init: Partial<InventoryRow> = {}) {
      this.rows.unshift({
        distributorId,
        productId,
        onHand: init.onHand ?? 0,
        reserved: 0,
        safetyStock: init.safetyStock ?? 10,
        leadTimeDays: init.leadTimeDays ?? 3,
      })
    },
    removeRow(distributorId: string, productId: string) {
      this.rows = this.rows.filter((r) => !(r.distributorId === distributorId && r.productId === productId))
    },
  },
})
