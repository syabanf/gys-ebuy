<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
  to?: string
  fullWidth?: boolean
  icon?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
  type: 'button',
  fullWidth: false,
})

const variantClasses: Record<NonNullable<Props['variant']>, string> = {
  primary: 'bg-brand-500 text-white shadow-sm hover:bg-brand-600 hover:shadow-md active:bg-brand-700 disabled:bg-neutral-300 disabled:text-neutral-500 disabled:shadow-none',
  secondary: 'bg-white text-neutral-800 border border-neutral-300 hover:bg-neutral-50 hover:border-neutral-400 active:bg-neutral-100 disabled:bg-neutral-100 disabled:text-neutral-400',
  ghost: 'bg-transparent text-neutral-700 hover:bg-neutral-100 active:bg-neutral-200 disabled:text-neutral-400',
  danger: 'bg-danger text-white shadow-sm hover:bg-red-700 hover:shadow-md active:bg-red-800 disabled:bg-neutral-300 disabled:text-neutral-500 disabled:shadow-none',
}

const sizeClasses: Record<NonNullable<Props['size']>, string> = {
  sm: 'h-8 px-3 text-sm rounded-md',
  md: 'h-10 px-4 text-sm rounded-lg',
  lg: 'h-12 px-6 text-base rounded-lg',
}
</script>

<template>
  <component
    :is="to ? 'a' : 'button'"
    :href="to"
    :type="to ? undefined : type"
    :disabled="disabled || loading"
    :class="[
      'inline-flex items-center justify-center font-medium gap-2 select-none',
      'transition-all duration-150 active:scale-[0.98] disabled:cursor-not-allowed disabled:active:scale-100',
      variantClasses[variant],
      sizeClasses[size],
      fullWidth && 'w-full',
    ]"
  >
    <svg v-if="loading" class="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
    </svg>
    <span v-else-if="icon" class="text-base leading-none">{{ icon }}</span>
    <slot />
  </component>
</template>
