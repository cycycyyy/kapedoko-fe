-- =========================================================
-- KapéDoko — Compare profiles.role as text in claim sync
-- =========================================================
-- Rejecting (or verifying) an ownership claim calls
-- sync_cafe_owner_role. Live profiles.role is enum
-- public.user_role; comparing it to a text CASE failed with
-- "operator does not exist: user_role = text" and rolled back
-- the whole moderate_shop_claim transaction.
-- Apply this in the SQL editor; the pending claim is unchanged.
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

notify pgrst, 'reload schema';
