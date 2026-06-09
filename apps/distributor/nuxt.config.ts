// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  devtools: { enabled: false },
  ssr: false,
  modules: ['@nuxtjs/tailwindcss', '@pinia/nuxt', '@vueuse/nuxt'],
  // Point the Tailwind module at our CSS so it doesn't inject its own default
  // stylesheet (which breaks the production CSS build).
  tailwindcss: {
    cssPath: '~/assets/css/main.css',
  },
  // Transpile the shared workspace UI package so Vite doesn't re-optimize on
  // every navigation (a common cause of slow dev reloads in pnpm monorepos).
  build: {
    transpile: ['@gys/ui'],
  },
  // Branded loading screen shown instantly while the SPA bundle boots,
  // instead of a blank white page.
  spaLoadingTemplate: 'spa-loading-template.html',
  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
    head: {
      title: 'GYS Distributor — E-Ordering',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Portal distributor untuk GYS E-Ordering Platform' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ],
    },
  },
  runtimeConfig: {
    public: {
      appName: 'GYS Distributor',
      appTagline: 'Portal Distributor',
    },
  },
})
