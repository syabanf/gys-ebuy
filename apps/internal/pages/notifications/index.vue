<script setup lang="ts">
import { GButton, GCard, formatDateTime } from '@gys/ui'
import { useNotifications } from '~/composables/useNotifications'

const router = useRouter()
const { items, unread, markRead, markAllRead } = useNotifications()

const iconFor: Record<string, { icon: string; tone: string }> = {
  buyer: { icon: '✓', tone: 'bg-blue-50 text-blue-700' },
  order: { icon: '◫', tone: 'bg-brand-50 text-brand-700' },
  distributor: { icon: '◰', tone: 'bg-amber-50 text-amber-700' },
  system: { icon: 'ⓘ', tone: 'bg-neutral-100 text-neutral-600' },
}

function open(n: any) {
  markRead(n.id)
  if (n.to) router.push(n.to)
}
</script>

<template>
  <div class="p-6 max-w-3xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">Notifikasi</h1>
        <p class="text-sm text-neutral-500 mt-1">{{ unread }} belum dibaca</p>
      </div>
      <GButton v-if="unread > 0" variant="secondary" size="sm" @click="markAllRead">Tandai semua dibaca</GButton>
    </div>

    <GCard :padded="false">
      <ul class="divide-y divide-neutral-100">
        <li
          v-for="n in items"
          :key="n.id"
          class="px-5 py-4 flex items-start gap-3 hover:bg-neutral-50 cursor-pointer transition-colors"
          :class="!n.read && 'bg-brand-50/40'"
          @click="open(n)"
        >
          <span class="h-9 w-9 rounded-full flex items-center justify-center text-sm flex-shrink-0" :class="iconFor[n.type].tone">{{ iconFor[n.type].icon }}</span>
          <div class="min-w-0 flex-1">
            <div class="flex items-center gap-2">
              <p class="text-sm font-medium text-neutral-900">{{ n.title }}</p>
              <span v-if="!n.read" class="h-2 w-2 rounded-full bg-brand-500 flex-shrink-0" />
            </div>
            <p class="text-sm text-neutral-600 mt-0.5">{{ n.body }}</p>
            <p class="text-xs text-neutral-400 mt-1">{{ formatDateTime(n.at) }}</p>
          </div>
        </li>
      </ul>
    </GCard>
  </div>
</template>
