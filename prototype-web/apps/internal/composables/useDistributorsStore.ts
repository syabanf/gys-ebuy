import { defineStore } from 'pinia'
import seed from '../../../mocks/fixtures/distributors.json'

export interface Distributor {
  id: string
  code: string
  legalName: string
  npwp: string
  city: string
  province: string
  serviceAreas: string[]
  contact: { name: string; phone: string; email: string }
  status: string
  joinedAt: string
}

let seq = 0

export const useDistributorsStore = defineStore('distributors', {
  state: () => ({ list: [] as Distributor[], loaded: false }),
  getters: {
    activeCount: (state) => state.list.filter((d) => d.status === 'active').length,
    provinces: (state) => [...new Set(state.list.map((d) => d.province))].sort(),
  },
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 200))
      this.list = JSON.parse(JSON.stringify(seed)) as Distributor[]
      this.loaded = true
    },
    getById(id: string) { return this.list.find((d) => d.id === id) ?? null },
    create(payload: { legalName: string; city: string; province: string; npwp: string; contactName: string; phone: string; email: string; serviceAreas: string[] }) {
      seq += 1
      const n = this.list.length + 1
      this.list.unshift({
        id: `dist-new-${Date.now()}-${seq}`,
        code: `DST-NEW-${String(n).padStart(2, '0')}`,
        legalName: payload.legalName,
        npwp: payload.npwp,
        city: payload.city,
        province: payload.province,
        serviceAreas: payload.serviceAreas.length ? payload.serviceAreas : [payload.province],
        contact: { name: payload.contactName, phone: payload.phone, email: payload.email },
        status: 'active',
        joinedAt: '2026-06-09',
      })
    },
  },
})
