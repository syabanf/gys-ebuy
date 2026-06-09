import { ref } from 'vue'

interface Toast {
  id: number
  type: 'success' | 'error' | 'info'
  message: string
}

const toasts = ref<Toast[]>([])
let seq = 0

function push(type: Toast['type'], message: string, ms = 2600) {
  const id = ++seq
  toasts.value.push({ id, type, message })
  if (import.meta.client) setTimeout(() => remove(id), ms)
}

function remove(id: number) {
  toasts.value = toasts.value.filter((t) => t.id !== id)
}

export function useToast() {
  return {
    toasts,
    success: (m: string) => push('success', m),
    error: (m: string) => push('error', m),
    info: (m: string) => push('info', m),
    remove,
  }
}
