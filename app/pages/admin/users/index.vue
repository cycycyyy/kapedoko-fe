<template>
  <IonPage>
    <AdminShell
      title="Users"
      lede="Change roles or suspend an account. You cannot suspend or demote yourself, or remove the last admin."
      :status="status"
      :error="error"
    >
      <div class="admin-toolbar">
        <input
          v-model="query"
          class="admin-search"
          type="search"
          placeholder="Search name or email"
          @keydown.enter.prevent="load(query, 1)"
        />
        <button type="button" class="admin-btn" @click="load(query, 1)">Search</button>
      </div>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Person</th>
              <th>Role</th>
              <th>State</th>
              <th>Joined</th>
              <th>Activity</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td>
                <strong>{{ user.displayName || 'Unnamed' }}</strong>
                <p class="admin-meta">{{ user.email }}</p>
              </td>
              <td><span class="admin-status" :class="`admin-status--${user.role}`">{{ user.role }}</span></td>
              <td><span class="admin-status" :class="user.banned ? 'admin-status--banned' : 'admin-status--approved'">{{ user.banned ? 'Suspended' : 'Active' }}</span></td>
              <td>{{ formatAdminDate(user.createdAt) }}</td>
              <td>{{ user.shopCount }} cafes · {{ user.reviewCount }} reviews</td>
              <td>
                <div class="admin-row-actions">
                  <button
                    type="button"
                    class="admin-btn admin-btn--ghost"
                    :disabled="savingId === user.id || user.id === me"
                    @click="toggleRole(user)"
                  >
                    {{ user.role === 'admin' ? 'Make user' : 'Make admin' }}
                  </button>
                  <button
                    type="button"
                    class="admin-btn"
                    :class="user.banned ? '' : 'admin-btn--danger'"
                    :disabled="savingId === user.id || user.id === me"
                    @click="toggleBan(user)"
                  >
                    {{ user.banned ? 'Reactivate' : 'Suspend' }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="admin-cards">
        <article v-for="user in users" :key="user.id" class="admin-card">
          <h2>{{ user.displayName || 'Unnamed' }}</h2>
          <p>{{ user.email }}</p>
          <p>{{ user.role }} · {{ user.banned ? 'Suspended' : 'Active' }}</p>
          <div class="admin-row-actions">
            <button type="button" class="admin-btn admin-btn--ghost" :disabled="savingId === user.id || user.id === me" @click="toggleRole(user)">
              {{ user.role === 'admin' ? 'Make user' : 'Make admin' }}
            </button>
            <button type="button" class="admin-btn" :disabled="savingId === user.id || user.id === me" @click="toggleBan(user)">
              {{ user.banned ? 'Reactivate' : 'Suspend' }}
            </button>
          </div>
        </article>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import type { AdminUserRow } from '~/types/admin'
import { formatAdminDate } from '~/utils/admin-nav'
import { roleChangeError, suspendError } from '~/utils/admin-users'
import { authUserId } from '~/utils/auth'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const { users, status, error, savingId, load, setRole, setBanned } = useAdminUsers()
const sessionUser = useSupabaseUser()
const me = computed(() => authUserId(sessionUser.value))
const query = ref('')
const actionError = ref('')

const toggleRole = async (user: AdminUserRow) => {
  const next = user.role === 'admin' ? 'user' : 'admin'
  const issue = roleChangeError({
    actorId: me.value,
    targetId: user.id,
    nextRole: next,
    adminCount: users.value.filter((row) => row.role === 'admin').length,
    targetRole: user.role,
  })
  if (issue) {
    window.alert(issue)
    return
  }
  try {
    await setRole(user.id, next)
  } catch (err) {
    actionError.value = err instanceof Error ? err.message : 'Could not change this role.'
    window.alert(actionError.value)
  }
}

const toggleBan = async (user: AdminUserRow) => {
  const issue = suspendError({ actorId: me.value, targetId: user.id, banned: user.banned })
  if (issue) {
    window.alert(issue)
    return
  }
  try {
    await setBanned(user.id, !user.banned)
  } catch (err) {
    window.alert(err instanceof Error ? err.message : 'Could not update this account.')
  }
}

onMounted(() => {
  void load()
})
</script>
