// Shared chart palette — real hex values (SVG fills can't use Tailwind classes).
export const chartPalette = [
  '#137A40', // brand
  '#2563EB', // info blue
  '#F59E0B', // amber
  '#3FA86E', // brand light
  '#8B5CF6', // violet
  '#DC2626', // danger red
  '#0EA5E9', // sky
  '#71717A', // neutral
]

export const chartColors = {
  brand: '#137A40',
  brandLight: '#3FA86E',
  brandFaint: '#C2E4D0',
  info: '#2563EB',
  warning: '#F59E0B',
  danger: '#DC2626',
  success: '#16A34A',
  neutral: '#A1A1AA',
  grid: '#E4E4E7',
  axis: '#71717A',
}

export function colorAt(i: number): string {
  return chartPalette[i % chartPalette.length]
}
