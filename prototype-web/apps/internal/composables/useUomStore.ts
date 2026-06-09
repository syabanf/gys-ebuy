import { defineStore } from 'pinia'

export interface Uom {
  id: string
  code: string
  name: string
  active: boolean
}

let seq = 0

export const useUomStore = defineStore('uom', {
  state: () => ({ items: [] as Uom[], loaded: false }),
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 150))
      this.items = [
        { id: 'uom-btg', code: 'batang', name: 'Batang', active: true },
        { id: 'uom-lbr', code: 'lembar', name: 'Lembar', active: true },
        { id: 'uom-kg', code: 'kg', name: 'Kilogram', active: true },
        { id: 'uom-m', code: 'm', name: 'Meter', active: true },
        { id: 'uom-pcs', code: 'pcs', name: 'Pieces', active: true },
        { id: 'uom-roll', code: 'roll', name: 'Roll', active: true },
        { id: 'uom-ton', code: 'ton', name: 'Ton', active: false },
      ]
      this.loaded = true
    },
    create(payload: Omit<Uom, 'id'>) {
      seq += 1
      this.items.push({ ...payload, id: `uom-new-${Date.now()}-${seq}` })
    },
    update(id: string, payload: Partial<Uom>) {
      const idx = this.items.findIndex((u) => u.id === id)
      if (idx !== -1) this.items[idx] = { ...this.items[idx], ...payload }
    },
    remove(id: string) {
      this.items = this.items.filter((u) => u.id !== id)
    },
  },
})
