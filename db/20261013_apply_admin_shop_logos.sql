-- =========================================================
-- KapéDoko — Stamp one cafe logo onto many shops
-- =========================================================
-- Run AFTER 20260929_admin_portal.sql.
-- Adds apply_admin_shop_logos: an admin copies one stored
-- logo object key onto ticked shops without rewriting hours
-- or identity. Coverage is bypassed the same way as other
-- admin shop writes.
-- =========================================================

create or replace function public.apply_admin_shop_logos(
  p_shop_ids uuid[],
  p_logo_object_key text
)
returns setof public.shops
language plpgsql
security definer
set search_path = public
as $$
declare
  clean_key text := nullif(btrim(coalesce(p_logo_object_key, '')), '');
  changed integer := 0;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_shop_ids is null or cardinality(p_shop_ids) < 1 then
    raise exception 'Tick at least one cafe.';
  end if;
  if cardinality(p_shop_ids) > 2000 then
    raise exception 'Stamp at most 2000 cafes at a time.';
  end if;
  if clean_key is null or clean_key !~ '^[a-zA-Z0-9][a-zA-Z0-9/_.:-]*$' then
    raise exception 'Choose a logo to stamp.';
  end if;

  perform set_config('app.admin_shop_write', 'on', true);

  return query
    update public.shops
    set logo_object_key = clean_key
    where id = any (p_shop_ids)
    returning *;

  get diagnostics changed = row_count;
  if changed = 0 then
    raise exception 'Cafe was not found';
  end if;

  perform public.admin_write_audit(
    'shop.logos',
    'shop',
    null,
    jsonb_build_object(
      'count', changed,
      'logo_object_key', clean_key
    )
  );
end;
$$;

revoke all on function public.apply_admin_shop_logos(uuid[], text) from public, anon;
grant execute on function public.apply_admin_shop_logos(uuid[], text) to authenticated;

notify pgrst, 'reload schema';
