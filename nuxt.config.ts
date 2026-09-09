// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: false },
  modules: [
    "@nuxtjs/ionic",
    "@nuxtjs/tailwindcss",
    "shadcn-nuxt",
    "@nuxtjs/supabase",
    "@nuxt/image",
  ],
  css: ["~/assets/css/ionic.css", "~/assets/css/tailwind.css"],
  ionic: {
    css: {
      core: false,
      basic: false,
      utilities: false,
    },
  },
  tailwindcss: {
    cssPath: "~/assets/css/tailwind.css",
  },
  shadcn: {
    prefix: "Ui",
    componentDir: "./app/components/ui",
  },
  supabase: {
    url: process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL,
    key: process.env.NUXT_PUBLIC_SUPABASE_KEY || process.env.SUPABASE_KEY,
    cookieOptions: {
      secure: process.env.NODE_ENV === "production",
    },
    redirectOptions: {
      login: "/login",
      callback: "/confirm",
      include: undefined, // protect all routes by default...
      exclude: ["/app", "/app/onboarding", "/app/search", "/app/favorites", "/register"], // ...except these
      saveRedirectToCookie: true, // remember where user was headed
    },
  },
});
