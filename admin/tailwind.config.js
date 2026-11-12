/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        midnightNavy: '#101A2B',
        deepNavy: '#17263D',
        surfaceNavy: '#1E314F',
        premiumGold: '#D4AF62',
        lightGold: '#E8C882',
        mutedGrey: '#8B95A5',
        borderGrey: '#2A3B53',
      },
    },
  },
  plugins: [],
};
