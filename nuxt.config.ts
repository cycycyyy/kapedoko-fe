// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: false },
  app: {
    head: {
      link: [
        { rel: "preconnect", href: "https://fonts.googleapis.com" },
        {
          rel: "preconnect",
          href: "https://fonts.gstatic.com",
          crossorigin: "",
        },
        {
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Kumbh+Sans:wght,YOPQ@100..900,300&display=swap",
        },
      ],
    },
  },
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
    redirect: false,
    useSsrCookies: process.env.NUXT_PUBLIC_AUTH_STORAGE !== "local",
    cookieOptions: {
      maxAge: 60 * 60 * 24 * 400,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      path: "/",
    },
    clientOptions: {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        flowType: "pkce",
      },
    },
    redirectOptions: {
      login: "/login",
      callback: "/confirm",
      exclude: ["/**"],
      saveRedirectToCookie: false,
    },
  },
  runtimeConfig: {
    public: {
      mapTiles: {
        url:
          process.env.NUXT_PUBLIC_MAP_TILE_URL ||
          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        attribution:
          process.env.NUXT_PUBLIC_MAP_ATTRIBUTION ||
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      },
      r2PublicBaseUrl: process.env.NUXT_PUBLIC_R2_PUBLIC_BASE_URL || "",
    },
  },
});
