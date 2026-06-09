<script setup lang="ts">
interface Props {
  open: boolean
  title?: string
  size?: 'sm' | 'md' | 'lg'
}

withDefaults(defineProps<Props>(), { size: 'md' })
const emit = defineEmits<{ close: [] }>()

const sizeClasses = {
  sm: 'max-w-md',
  md: 'max-w-xl',
  lg: 'max-w-3xl',
}
</script>

<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-neutral-900/50" @click="emit('close')" />
        <div
          :class="[
            'relative bg-white rounded-lg shadow-elevated w-full max-h-[90vh] overflow-hidden flex flex-col',
            sizeClasses[size],
          ]"
        >
          <header v-if="title || $slots.header" class="px-5 py-4 border-b border-neutral-200 flex items-center justify-between">
            <h2 v-if="title" class="text-base font-semibold text-neutral-900">{{ title }}</h2>
            <slot name="header" />
            <button
              type="button"
              class="text-neutral-400 hover:text-neutral-600 text-2xl leading-none px-2"
              @click="emit('close')"
              aria-label="Close"
            >
              ×
            </button>
          </header>
          <div class="p-5 overflow-y-auto flex-1">
            <slot />
          </div>
          <footer v-if="$slots.footer" class="px-5 py-4 border-t border-neutral-200 bg-neutral-50 flex justify-end gap-2">
            <slot name="footer" />
          </footer>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.15s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
