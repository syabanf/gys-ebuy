<script setup lang="ts">
interface Props {
  open: boolean
  title?: string
  subtitle?: string
  width?: string
}
withDefaults(defineProps<Props>(), { width: '30rem' })
const emit = defineEmits<{ close: [] }>()
</script>

<template>
  <Teleport to="body">
    <Transition name="drawer-fade">
      <div v-if="open" class="fixed inset-0 z-[60]">
        <div class="absolute inset-0 bg-neutral-900/50" @click="emit('close')" />
        <Transition name="drawer-slide" appear>
          <aside
            v-if="open"
            class="absolute right-0 top-0 bottom-0 bg-white shadow-elevated flex flex-col max-w-[calc(100vw-2rem)]"
            :style="{ width }"
          >
            <header class="px-5 py-4 border-b border-neutral-200 flex items-start justify-between gap-3 flex-shrink-0">
              <div class="min-w-0">
                <h2 v-if="title" class="text-base font-semibold text-neutral-900 truncate">{{ title }}</h2>
                <p v-if="subtitle" class="text-sm text-neutral-500 truncate">{{ subtitle }}</p>
                <slot name="header" />
              </div>
              <button type="button" class="text-neutral-400 hover:text-neutral-600 text-2xl leading-none px-1" aria-label="Tutup" @click="emit('close')">×</button>
            </header>
            <div class="flex-1 overflow-y-auto p-5">
              <slot />
            </div>
            <footer v-if="$slots.footer" class="px-5 py-4 border-t border-neutral-200 bg-neutral-50 flex flex-wrap gap-2 flex-shrink-0">
              <slot name="footer" />
            </footer>
          </aside>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.drawer-fade-enter-active, .drawer-fade-leave-active { transition: opacity 0.2s ease; }
.drawer-fade-enter-from, .drawer-fade-leave-to { opacity: 0; }
.drawer-slide-enter-active, .drawer-slide-leave-active { transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1); }
.drawer-slide-enter-from, .drawer-slide-leave-to { transform: translateX(100%); }
</style>
