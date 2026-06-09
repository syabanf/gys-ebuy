<script setup lang="ts">
interface Toast {
  id: number
  type: 'success' | 'error' | 'info'
  message: string
}

defineProps<{ toasts: Toast[] }>()
const emit = defineEmits<{ dismiss: [id: number] }>()

const styles: Record<Toast['type'], { ring: string; icon: string; iconColor: string }> = {
  success: { ring: 'border-emerald-200', icon: '✓', iconColor: 'bg-emerald-100 text-emerald-700' },
  error: { ring: 'border-red-200', icon: '✕', iconColor: 'bg-red-100 text-red-700' },
  info: { ring: 'border-blue-200', icon: 'i', iconColor: 'bg-blue-100 text-blue-700' },
}
</script>

<template>
  <Teleport to="body">
    <div class="fixed bottom-5 right-5 z-[60] flex flex-col gap-2 w-80 max-w-[calc(100vw-2.5rem)]">
      <TransitionGroup name="toast">
        <div
          v-for="t in toasts"
          :key="t.id"
          :class="['bg-white rounded-lg shadow-elevated border px-4 py-3 flex items-center gap-3', styles[t.type].ring]"
        >
          <span :class="['h-6 w-6 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0', styles[t.type].iconColor]">{{ styles[t.type].icon }}</span>
          <p class="text-sm text-neutral-800 flex-1">{{ t.message }}</p>
          <button class="text-neutral-400 hover:text-neutral-600 text-lg leading-none" @click="emit('dismiss', t.id)">×</button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toast-enter-active, .toast-leave-active { transition: all 0.25s ease; }
.toast-enter-from { opacity: 0; transform: translateX(20px); }
.toast-leave-to { opacity: 0; transform: translateX(20px); }
</style>
