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
              <td>
                <label class="sr-only" :for="`role-${user.id}`">Role for {{ user.displayName || user.email || 'this person' }}</label>
                <select
                  :id="`role-${user.id}`"
                  class="admin-search"
                  :value="user.role"
                  :disabled="savingId === user.id || user.id === me"
                  @change="onRole(user, ($event.target as HTMLSelectElement).value)"
                >
                  <option value="user">User</option>
                  <option value="cafe-owner">Cafe owner</option>
                  <option value="auditor">Auditor</option>
                  <option value="admin">Admin</option>
                </select>
              </td>
              <td><span class="admin-status" :class="user.banned ? 'admin-status--banned' : 'admin-status--approved'">{{ user.banned ? 'Suspended' : 'Active' }}</span></td>
              <td>{{ formatAdminDate(user.createdAt) }}</td>
              <td>{{ user.shopCount }} cafes · {{ user.reviewCount }} reviews</td>
              <td>
                <div class="admin-row-actions">
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
          <p>{{ user.banned ? 'Suspended' : 'Active' }}</p>
          <label class="sr-only" :for="`role-card-${user.id}`">Role for {{ user.displayName || user.email || 'this person' }}</label>
          <select
            :id="`role-card-${user.id}`"
            class="admin-search"
            :value="user.role"
            :disabled="savingId === user.id || user.id === me"
            @change="onRole(user, ($event.target as HTMLSelectElement).value)"
          >
            <option value="user">User</option>
            <option value="cafe-owner">Cafe owner</option>
            <option value="auditor">Auditor</option>
            <option value="admin">Admin</option>
          </select>
          <div class="admin-row-actions">
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
import type { ProfileRole } from '~/types/shop'
import { formatAdminDate } from '~/utils/admin-nav'
import { roleChangeError, suspendError } from '~/utils/admin-users'
import { authUserId } from '~/utils/auth'
import { isProfileRole } from '~/utils/profile-role'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const { users, status, error, savingId, load, setRole, setBanned } = useAdminUsers()
const sessionUser = useSupabaseUser()
const me = computed(() => authUserId(sessionUser.value))
const query = ref('')
const actionError = ref('')

const onRole = async (user: AdminUserRow, nextRaw: string) => {
  if (!isProfileRole(nextRaw)) return
  const next = nextRaw as ProfileRole
  if (next === user.role) return
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

<style scoped>
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>

