// GYS brand tokens
// Primary green sampled from garudayamatosteel.com (logo + nav).
// Eyedropper exact hex in week 1 of Phase 0 if more precision is needed.
// The 500 step is the brand anchor; the rest of the palette is derived.

const brand = {
  50:  '#E6F4EC',
  100: '#C2E4D0',
  200: '#9AD2B2',
  300: '#6FBF92',
  400: '#3FA86E',
  500: '#137A40', // GYS primary green
  600: '#0F6837',
  700: '#0B552D',
  800: '#084223',
  900: '#052E18',
  950: '#02180C',
}

const neutral = {
  50:  '#FAFAFA',
  100: '#F4F4F5',
  200: '#E4E4E7',
  300: '#D4D4D8',
  400: '#A1A1AA',
  500: '#71717A',
  600: '#52525B',
  700: '#3F3F46',
  800: '#27272A',
  900: '#18181B',
  950: '#09090B',
}

const semantic = {
  success: '#16A34A',
  warning: '#F59E0B',
  danger:  '#DC2626',
  info:    '#2563EB',
}

module.exports = {
  brand,
  neutral,
  semantic,
  fontFamily: {
    sans: ['Inter', 'ui-sans-serif', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'sans-serif'],
  },
  radius: {
    none: '0px',
    sm: '4px',
    md: '8px',
    lg: '12px',
    xl: '16px',
    full: '9999px',
  },
}
