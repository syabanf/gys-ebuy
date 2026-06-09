import { defineStore } from 'pinia'
import users from '../../../mocks/fixtures/users.json'

interface SessionUser {
  id: string
  username: string
  displayName: string
  email: string
  role: string
  ldapGroups?: string[]
}

export const useSessionStore = defineStore('session', {
  state: () => ({
    user: null as SessionUser | null,
  }),
  getters: {
    isAuthenticated: (state) => state.user !== null,
    isItAdmin: (state) => state.user?.role === 'gys_it_admin',
  },
  actions: {
    login(username: string) {
      const match = users.find((u) => u.username === username && u.role.startsWith('gys_'))
      if (!match) return false
      this.user = match as SessionUser
      if (import.meta.client) {
        localStorage.setItem('gys-internal-session', JSON.stringify(match))
      }
      return true
    },
    logout() {
      this.user = null
      if (import.meta.client) {
        localStorage.removeItem('gys-internal-session')
      }
    },
    hydrate() {
      if (import.meta.client) {
        const raw = localStorage.getItem('gys-internal-session')
        if (raw) {
          try { this.user = JSON.parse(raw) } catch { /* ignore */ }
        }
      }
    },
  },
})
