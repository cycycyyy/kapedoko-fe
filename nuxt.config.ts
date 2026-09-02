// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/ionic', '@nuxtjs/tailwindcss', 'shadcn-nuxt'],
  css: ['~/assets/css/tailwind.css', '~/assets/css/ionic.css'],
  ionic: {
    css: {
      core: false,
      basic: false,
      utilities: false
    }
  },
  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css'
  },
  shadcn: {
    prefix: 'Ui',
    componentDir: './app/components/ui'
  }
})
