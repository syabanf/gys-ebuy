import { defineStore } from 'pinia'
import seed from '../../../mocks/fixtures/pricing-scopes.json'

export interface Scope {
  id: string
  type: 'central' | 'distributor'
  label: string
  distributorId: string | null
  active: boolean
  notes?: string
}

let seq = 0

export const usePricingStore = defineStore('pricing', {
  state: () => ({ scopes: [] as Scope[], loaded: false }),
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 200))
      this.scopes = JSON.parse(JSON.stringify(seed)) as Scope[]
      this.loaded = true
    },
    create(payload: Omit<Scope, 'id'>) {
      seq += 1
      this.scopes.unshift({ ...payload, id: `scope-new-${Date.now()}-${seq}` })
    },
    update(id: string, payload: Partial<Scope>) {
      const idx = this.scopes.findIndex((s) => s.id === id)
      if (idx !== -1) this.scopes[idx] = { ...this.scopes[idx], ...payload }
    },
    remove(id: string) { this.scopes = this.scopes.filter((s) => s.id !== id) },
  },
})
