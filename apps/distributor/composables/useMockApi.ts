import products from '../../../mocks/fixtures/products.json'
import categories from '../../../mocks/fixtures/categories.json'
import distributors from '../../../mocks/fixtures/distributors.json'
import buyers from '../../../mocks/fixtures/buyers.json'
import orders from '../../../mocks/fixtures/orders.json'
import users from '../../../mocks/fixtures/users.json'
import inventory from '../../../mocks/fixtures/inventory.json'
import pricingScopes from '../../../mocks/fixtures/pricing-scopes.json'

const sleep = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms))
// Light artificial latency so loading states are visible without feeling sluggish.
const latency = () => 120 + Math.floor(Math.random() * 160)

export function useMockApi() {
  return {
    async listOrders(filters?: { distributorId?: string; status?: string }) {
      await sleep(latency())
      let result = [...orders]
      if (filters?.distributorId) result = result.filter((o) => o.distributorId === filters.distributorId)
      if (filters?.status) result = result.filter((o) => o.status === filters.status)
      return result.sort((a, b) => (a.placedAt < b.placedAt ? 1 : -1))
    },

    async getOrder(id: string) {
      await sleep(latency())
      return orders.find((o) => o.id === id) ?? null
    },

    async listProducts(filters?: { categoryId?: string; search?: string }) {
      await sleep(latency())
      let result = [...products]
      if (filters?.categoryId) result = result.filter((p) => p.categoryId === filters.categoryId)
      if (filters?.search) {
        const q = filters.search.toLowerCase()
        result = result.filter((p) => p.name.toLowerCase().includes(q) || p.sku.toLowerCase().includes(q))
      }
      return result
    },

    async getProduct(id: string) {
      await sleep(latency())
      return products.find((p) => p.id === id) ?? null
    },

    async listCategories() {
      await sleep(latency())
      return categories
    },

    async listDistributors() {
      await sleep(latency())
      return distributors
    },

    async getDistributor(id: string) {
      await sleep(latency())
      return distributors.find((d) => d.id === id) ?? null
    },

    async listBuyers(filters?: { approvalStatus?: string }) {
      await sleep(latency())
      let result = [...buyers]
      if (filters?.approvalStatus) result = result.filter((b) => b.approvalStatus === filters.approvalStatus)
      return result
    },

    async getBuyer(id: string) {
      await sleep(latency())
      return buyers.find((b) => b.id === id) ?? null
    },

    async listInventory(distributorId: string) {
      await sleep(latency())
      return inventory
        .filter((i) => i.distributorId === distributorId)
        .map((i) => ({
          ...i,
          product: products.find((p) => p.id === i.productId),
        }))
    },

    async listPricingScopes() {
      await sleep(latency())
      return pricingScopes
    },

    async findUser(username: string, _password: string) {
      await sleep(latency())
      return users.find((u) => u.username === username) ?? null
    },
  }
}
