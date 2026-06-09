import { defineStore } from 'pinia'

export interface ManagedUser {
  id: string
  name: string
  username: string
  email: string
  role: 'gys_it_admin' | 'gys_sales' | 'distributor_owner' | 'distributor_staff'
  status: 'active' | 'suspended'
}

export const ROLE_LABELS: Record<ManagedUser['role'], string> = {
  gys_it_admin: 'IT Admin',
  gys_sales: 'Sales',
  distributor_owner: 'Pemilik Distributor',
  distributor_staff: 'Staff Distributor',
}

let seq = 0

export const useUsersStore = defineStore('users', {
  state: () => ({ items: [] as ManagedUser[], loaded: false }),
  getters: {
    activeCount: (state) => state.items.filter((u) => u.status === 'active').length,
    internalCount: (state) => state.items.filter((u) => u.role.startsWith('gys_')).length,
  },
  actions: {
    async load() {
      if (this.loaded) return
      await new Promise((r) => setTimeout(r, 150))
      this.items = [
        { id: 'u-1', name: 'Andi Wijaya', username: 'andi.sales', email: 'andi.wijaya@gys.co.id', role: 'gys_sales', status: 'active' },
        { id: 'u-2', name: 'Rina Permata', username: 'rina.it', email: 'rina.permata@gys.co.id', role: 'gys_it_admin', status: 'active' },
        { id: 'u-3', name: 'Dimas Saputra', username: 'dimas.sales', email: 'dimas.saputra@gys.co.id', role: 'gys_sales', status: 'active' },
        { id: 'u-4', name: 'Putri Handayani', username: 'putri.sales', email: 'putri.handayani@gys.co.id', role: 'gys_sales', status: 'suspended' },
        { id: 'u-5', name: 'Eko Nugroho', username: 'eko.it', email: 'eko.nugroho@gys.co.id', role: 'gys_it_admin', status: 'active' },
        { id: 'u-6', name: 'Budi Santoso', username: 'budi.mitrabaja', email: 'budi@mitrabaja.co.id', role: 'distributor_owner', status: 'active' },
        { id: 'u-7', name: 'Sri Wahyuni', username: 'sri.suryalogam', email: 'sri@suryalogam.co.id', role: 'distributor_owner', status: 'active' },
        { id: 'u-8', name: 'Rahmat Hidayat', username: 'rahmat.andalas', email: 'rahmat@andalassteel.co.id', role: 'distributor_owner', status: 'active' },
        { id: 'u-9', name: 'Joko Susilo', username: 'joko.tegalbaja', email: 'joko@tegalbaja.co.id', role: 'distributor_staff', status: 'active' },
      ]
      this.loaded = true
    },
    create(payload: Omit<ManagedUser, 'id'>) {
      seq += 1
      this.items.unshift({ ...payload, id: `u-new-${Date.now()}-${seq}` })
    },
    update(id: string, payload: Partial<ManagedUser>) {
      const idx = this.items.findIndex((u) => u.id === id)
      if (idx !== -1) this.items[idx] = { ...this.items[idx], ...payload }
    },
    toggleStatus(id: string) {
      const u = this.items.find((x) => x.id === id)
      if (u) u.status = u.status === 'active' ? 'suspended' : 'active'
    },
    remove(id: string) {
      this.items = this.items.filter((u) => u.id !== id)
    },
  },
})
