import { useSessionStore } from '~/composables/useSession'

export default defineNuxtRouteMiddleware((to) => {
  const session = useSessionStore()
  if (import.meta.client && !session.user) session.hydrate()

  const isAuthPage = to.path === '/login'
  if (!session.isAuthenticated && !isAuthPage) {
    return navigateTo({ path: '/login', query: { redirect: to.fullPath } })
  }
  if (session.isAuthenticated && isAuthPage) {
    return navigateTo('/')
  }
})
