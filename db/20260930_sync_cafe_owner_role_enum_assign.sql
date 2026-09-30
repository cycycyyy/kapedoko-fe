-- =========================================================
-- KapéDoko — Assign cafe-owner role as enum, not text
-- =========================================================
-- After the role::text compare fix, reject still failed:
-- column "role" is of type user_role but expression is of type text
-- because SET role = CASE … END is typed as text.
-- Also cast admin_set_profile_role's text argument.
-- Apply this in the SQL editor (or it is applied from the app repo).
-- =========================================================

create or replace function public.sync_cafe_owner_role(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_role text;
  has_verified boolean;
  next_role text;
begin
  select role::text into current_role from public.profiles where id = p_user_id;
  if current_role is null or current_role = 'admin' then
    return;
  end if;

  select exists (
    select 1 from public.shop_claims
    where claimant_id = p_user_id
      and status = 'verified'
  ) into has_verified;

  next_role := case when has_verified then 'cafe-owner' else 'user' end;

  update public.profiles
  set role = next_role::public.user_role
  where id = p_user_id
    and role::text is distinct from next_role;
end;
$$;

create or replace function public.admin_set_profile_role(
  p_user_id uuid,
  p_role text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
  remaining_admins integer;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_role not in ('user', 'cafe-owner', 'admin') then
    raise exception 'Unknown role';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'You cannot change your own role.';
  end if;

  if p_role <> 'admin' then
    select count(*) into remaining_admins
    from public.profiles
    where role::text = 'admin'
      and id <> p_user_id;
    if remaining_admins < 1 then
      raise exception 'Cannot demote the last admin.';
    end if;
  end if;

  update public.profiles
  set role = p_role::public.user_role
  where id = p_user_id
  returning * into updated;

  if updated.id is null then
    raise exception 'User was not found';
  end if;

  perform public.admin_write_audit(
    'user.role',
    'profile',
    updated.id::text,
    jsonb_build_object('role', p_role)
  );
  return updated;
end;
$$;

notify pgrst, 'reload schema';
