import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.kapedoko.fe',
  appName: 'KapeDoko',
  webDir: 'dist',
  android: {
    appendUserAgent: 'KapeDoko/1.0',
  },
  ios: {
    appendUserAgent: 'KapeDoko/1.0',
  },
}

export default config
