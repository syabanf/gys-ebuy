<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import GSidebarNav from './SidebarNav.vue'

interface NavItem { label: string; to: string; icon?: string; badge?: string | number }
interface NavGroup { label?: string; icon?: string; collapsible?: boolean; items: NavItem[] }
interface SearchItem { label: string; sublabel?: string; to: string; group?: string }
interface AppLink { label: string; sublabel?: string; url?: string; icon?: string; current?: boolean; disabled?: boolean }

interface Props {
  appName: string
  appTagline?: string
  nav: NavGroup[]
  userName: string
  userRole?: string
  currentPath: string
  searchItems?: SearchItem[]
  notifCount?: number
  notifTo?: string
  storageKey?: string
  apps?: AppLink[]
}

const props = withDefaults(defineProps<Props>(), {
  searchItems: () => [],
  notifCount: 0,
  notifTo: '/notifications',
  storageKey: 'gys',
  apps: () => [],
})
const emit = defineEmits<{ logout: []; navigate: [to: string] }>()

const collapsed = ref(false)
const mobileOpen = ref(false)
const userMenuOpen = ref(false)
const launcherOpen = ref(false)
const searchQuery = ref('')
const searchFocused = ref(false)

onMounted(() => {
  const saved = localStorage.getItem(`${props.storageKey}-sidebar-collapsed`)
  if (saved === '1') collapsed.value = true
})
function toggleCollapsed() {
  collapsed.value = !collapsed.value
  localStorage.setItem(`${props.storageKey}-sidebar-collapsed`, collapsed.value ? '1' : '0')
}

function go(to: string) {
  emit('navigate', to)
  mobileOpen.value = false
  searchQuery.value = ''
  searchFocused.value = false
  userMenuOpen.value = false
}

// Flattened items for the collapsed rail
const flatItems = computed(() => props.nav.flatMap((g) => g.items))
function isActive(p: string) {
  if (p === '/') return props.currentPath === '/'
  return props.currentPath.startsWith(p)
}

// Breadcrumb
const activeItem = computed(() => {
  let best: NavItem | null = null
  for (const g of props.nav) {
    for (const it of g.items) {
      if (it.to === '/' ? props.currentPath === '/' : props.currentPath.startsWith(it.to)) {
        if (!best || it.to.length > best.to.length) best = it
      }
    }
  }
  return best
})
const isDetail = computed(() => {
  const a = activeItem.value
  return !!a && a.to !== '/' && props.currentPath.length > a.to.length
})

// Global search
const searchResults = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return []
  return props.searchItems
    .filter((s) => s.label.toLowerCase().includes(q) || (s.sublabel ?? '').toLowerCase().includes(q))
    .slice(0, 8)
})
</script>

<template>
  <div class="min-h-screen flex bg-neutral-50">
    <!-- Desktop sidebar -->
    <aside class="hidden lg:flex flex-col flex-shrink-0 border-r border-neutral-200 bg-white transition-all duration-200" :class="collapsed ? 'w-16' : 'w-64'">
      <div class="px-4 py-5 border-b border-neutral-200 flex items-center gap-2" :class="collapsed && 'justify-center px-0'">
        <div class="h-9 w-9 rounded-md bg-brand-500 text-white font-bold flex items-center justify-center text-sm flex-shrink-0">GYS</div>
        <div v-if="!collapsed" class="min-w-0">
          <p class="font-semibold text-neutral-900 text-sm leading-tight truncate">{{ appName }}</p>
          <p v-if="appTagline" class="text-xs text-neutral-500 truncate">{{ appTagline }}</p>
        </div>
      </div>

      <!-- Collapsed rail -->
      <nav v-if="collapsed" class="flex-1 px-2 py-3 space-y-1 overflow-y-auto">
        <a
          v-for="item in flatItems"
          :key="item.to"
          :href="item.to"
          :title="item.label"
          :class="['flex items-center justify-center h-10 rounded-md transition-colors relative', isActive(item.to) ? 'bg-brand-50 text-brand-700' : 'text-neutral-600 hover:bg-neutral-100']"
          @click.prevent="go(item.to)"
        >
          <span class="text-base">{{ item.icon ?? '•' }}</span>
          <span v-if="item.badge" class="absolute top-1 right-1 h-1.5 w-1.5 rounded-full bg-brand-500" />
        </a>
      </nav>
      <!-- Full nav -->
      <GSidebarNav v-else :nav="nav" :current-path="currentPath" @navigate="go" />

      <div class="border-t border-neutral-200 p-3">
        <div class="flex items-center gap-3" :class="collapsed && 'justify-center'">
          <div class="h-9 w-9 rounded-full bg-neutral-200 flex items-center justify-center text-sm font-semibold text-neutral-600 flex-shrink-0">{{ userName.slice(0, 2).toUpperCase() }}</div>
          <div v-if="!collapsed" class="flex-1 min-w-0">
            <p class="text-sm font-medium text-neutral-900 truncate">{{ userName }}</p>
            <p v-if="userRole" class="text-xs text-neutral-500">{{ userRole }}</p>
          </div>
          <button v-if="!collapsed" type="button" class="text-neutral-400 hover:text-danger text-sm" title="Logout" @click="$emit('logout')">↪</button>
        </div>
      </div>
    </aside>

    <!-- Mobile drawer -->
    <Transition name="drawer">
      <div v-if="mobileOpen" class="fixed inset-0 z-50 lg:hidden">
        <div class="absolute inset-0 bg-neutral-900/50" @click="mobileOpen = false" />
        <aside class="absolute left-0 top-0 bottom-0 w-64 bg-white border-r border-neutral-200 flex flex-col">
          <div class="px-4 py-5 border-b border-neutral-200 flex items-center gap-2">
            <div class="h-9 w-9 rounded-md bg-brand-500 text-white font-bold flex items-center justify-center text-sm">GYS</div>
            <div><p class="font-semibold text-neutral-900 text-sm leading-tight">{{ appName }}</p><p v-if="appTagline" class="text-xs text-neutral-500">{{ appTagline }}</p></div>
          </div>
          <GSidebarNav :nav="nav" :current-path="currentPath" @navigate="go" />
          <div class="border-t border-neutral-200 p-3">
            <button type="button" class="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm text-danger hover:bg-red-50" @click="$emit('logout')">↪ Keluar</button>
          </div>
        </aside>
      </div>
    </Transition>

    <!-- Main -->
    <div class="flex-1 min-w-0 flex flex-col">
      <header class="sticky top-0 z-30 bg-white border-b border-neutral-200 px-4 py-2.5 flex items-center gap-3">
        <button class="lg:hidden h-9 w-9 rounded-md hover:bg-neutral-100 text-neutral-600 text-lg" @click="mobileOpen = true">☰</button>
        <button class="hidden lg:flex h-9 w-9 rounded-md hover:bg-neutral-100 text-neutral-500 items-center justify-center" :title="collapsed ? 'Perluas' : 'Ciutkan'" @click="toggleCollapsed">
          <span class="text-base">{{ collapsed ? '»' : '«' }}</span>
        </button>

        <!-- Breadcrumb -->
        <nav class="hidden sm:flex items-center gap-1.5 text-sm min-w-0">
          <span class="text-neutral-400">{{ appName }}</span>
          <template v-if="activeItem">
            <span class="text-neutral-300">/</span>
            <span :class="isDetail ? 'text-neutral-400' : 'text-neutral-700 font-medium'">{{ activeItem.label }}</span>
            <template v-if="isDetail"><span class="text-neutral-300">/</span><span class="text-neutral-700 font-medium">Detail</span></template>
          </template>
        </nav>

        <!-- Global search -->
        <div class="ml-auto relative w-44 sm:w-64" @focusout="searchFocused = false" tabindex="-1">
          <input
            v-model="searchQuery"
            type="search"
            placeholder="Cari…"
            class="w-full h-9 pl-9 pr-3 rounded-md border border-neutral-300 bg-neutral-50 text-sm focus:bg-white focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500"
            @focus="searchFocused = true"
          />
          <span class="absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400 text-sm">⌕</span>
          <div v-if="searchFocused && searchQuery && searchResults.length" class="absolute mt-1 w-full bg-white rounded-lg border border-neutral-200 shadow-elevated overflow-hidden z-40">
            <button
              v-for="(r, i) in searchResults"
              :key="i"
              type="button"
              class="w-full text-left px-3 py-2 hover:bg-neutral-50 flex items-center justify-between gap-2"
              @mousedown.prevent="go(r.to)"
            >
              <div class="min-w-0">
                <p class="text-sm text-neutral-900 truncate">{{ r.label }}</p>
                <p v-if="r.sublabel" class="text-xs text-neutral-500 truncate">{{ r.sublabel }}</p>
              </div>
              <span v-if="r.group" class="text-[10px] text-neutral-400 flex-shrink-0">{{ r.group }}</span>
            </button>
          </div>
          <div v-else-if="searchFocused && searchQuery" class="absolute mt-1 w-full bg-white rounded-lg border border-neutral-200 shadow-elevated px-3 py-3 text-sm text-neutral-500 z-40">
            Tidak ada hasil untuk "{{ searchQuery }}"
          </div>
        </div>

        <!-- App switcher -->
        <div v-if="apps.length" class="relative" tabindex="-1" @focusout="launcherOpen = false">
          <button class="h-9 w-9 rounded-md hover:bg-neutral-100 text-neutral-600 flex items-center justify-center" title="Pindah aplikasi" @click="launcherOpen = !launcherOpen">
            <span class="text-lg leading-none">▦</span>
          </button>
          <div v-if="launcherOpen" class="absolute right-0 mt-1 w-64 bg-white rounded-lg border border-neutral-200 shadow-elevated overflow-hidden z-40">
            <p class="px-3 pt-2.5 pb-1 text-[11px] font-semibold uppercase tracking-wider text-neutral-400">Aplikasi GYS</p>
            <template v-for="app in apps" :key="app.label">
              <a
                v-if="!app.disabled && app.url"
                :href="app.url"
                target="_blank"
                rel="noopener"
                class="flex items-center gap-3 px-3 py-2.5 hover:bg-neutral-50"
                @click="launcherOpen = false"
              >
                <span class="h-9 w-9 rounded-lg bg-brand-50 text-brand-700 flex items-center justify-center text-base flex-shrink-0">{{ app.icon ?? '▦' }}</span>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-medium text-neutral-900 truncate">{{ app.label }}</p>
                  <p v-if="app.sublabel" class="text-xs text-neutral-500 truncate">{{ app.sublabel }}</p>
                </div>
                <span v-if="app.current" class="text-[10px] bg-brand-100 text-brand-700 font-semibold px-2 py-0.5 rounded-full flex-shrink-0">Saat ini</span>
                <span v-else class="text-neutral-300 text-xs flex-shrink-0">↗</span>
              </a>
              <div v-else class="flex items-center gap-3 px-3 py-2.5 opacity-60 cursor-not-allowed">
                <span class="h-9 w-9 rounded-lg bg-neutral-100 text-neutral-400 flex items-center justify-center text-base flex-shrink-0">{{ app.icon ?? '▦' }}</span>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-medium text-neutral-700 truncate">{{ app.label }}</p>
                  <p v-if="app.sublabel" class="text-xs text-neutral-500 truncate">{{ app.sublabel }}</p>
                </div>
              </div>
            </template>
          </div>
        </div>

        <!-- Bell -->
        <a :href="notifTo" class="relative h-9 w-9 rounded-md hover:bg-neutral-100 text-neutral-600 flex items-center justify-center" title="Notifikasi" @click.prevent="go(notifTo)">
          <span class="text-base">◔</span>
          <span v-if="notifCount > 0" class="absolute top-1 right-1 min-w-4 h-4 px-1 rounded-full bg-danger text-white text-[10px] font-bold flex items-center justify-center">{{ notifCount > 9 ? '9+' : notifCount }}</span>
        </a>

        <!-- User menu -->
        <div class="relative" @focusout="userMenuOpen = false" tabindex="-1">
          <button class="h-9 w-9 rounded-full bg-brand-500 text-white text-sm font-semibold flex items-center justify-center" @click="userMenuOpen = !userMenuOpen">
            {{ userName.slice(0, 2).toUpperCase() }}
          </button>
          <div v-if="userMenuOpen" class="absolute right-0 mt-1 w-48 bg-white rounded-lg border border-neutral-200 shadow-elevated overflow-hidden z-40">
            <div class="px-3 py-2.5 border-b border-neutral-100">
              <p class="text-sm font-medium text-neutral-900 truncate">{{ userName }}</p>
              <p v-if="userRole" class="text-xs text-neutral-500">{{ userRole }}</p>
            </div>
            <button class="w-full text-left px-3 py-2 text-sm text-danger hover:bg-red-50" @mousedown.prevent="$emit('logout')">Keluar</button>
          </div>
        </div>
      </header>

      <div class="flex-1 overflow-y-auto">
        <slot />
      </div>
    </div>
  </div>
</template>

<style scoped>
.drawer-enter-active, .drawer-leave-active { transition: opacity 0.2s ease; }
.drawer-enter-from, .drawer-leave-to { opacity: 0; }
</style>
