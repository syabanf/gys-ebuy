const tokens = require('./tokens.js')

/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: tokens.brand,
        neutral: tokens.neutral,
        success: tokens.semantic.success,
        warning: tokens.semantic.warning,
        danger:  tokens.semantic.danger,
        info:    tokens.semantic.info,
      },
      fontFamily: tokens.fontFamily,
      borderRadius: tokens.radius,
      boxShadow: {
        card: '0 1px 2px 0 rgb(0 0 0 / 0.04), 0 1px 3px 0 rgb(0 0 0 / 0.06)',
        elevated: '0 4px 6px -1px rgb(0 0 0 / 0.08), 0 2px 4px -2px rgb(0 0 0 / 0.06)',
      },
    },
  },
}
