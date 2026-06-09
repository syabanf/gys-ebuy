const preset = require('@gys/tailwind-preset')

/** @type {import('tailwindcss').Config} */
module.exports = {
  presets: [preset],
  content: [
    './app.vue',
    './pages/**/*.vue',
    './layouts/**/*.vue',
    './components/**/*.vue',
    './composables/**/*.{ts,js}',
    '../../packages/ui/src/**/*.{vue,ts}',
  ],
}
