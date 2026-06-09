export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  devtools: { enabled: false },
  ssr: false,
  // Force static output (.output/public). Without this, Nitro auto-detects
  // Vercel and writes to .vercel/output, which breaks the single-root assembly.
  nitro: { preset: 'static' },
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
  // Branded loading screen shown instantly while the SPA bundle boots.
  spaLoadingTemplate: 'spa-loading-template.html',
  app: {
    // Base path for single-root deployment (Vercel serves this app under
    // /internal/). Defaults to '/' for local dev / `pnpm preview`.
    baseURL: process.env.NUXT_APP_BASE_URL || '/',
    pageTransition: { name: 'page', mode: 'out-in' },
    head: {
      title: 'GYS Internal — E-Ordering',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Portal internal GYS untuk mengelola E-Ordering Platform' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ],
    },
  },
  runtimeConfig: {
    public: {
      appName: 'GYS Internal',
      appTagline: 'Sales & IT Console',
    },
  },
})
