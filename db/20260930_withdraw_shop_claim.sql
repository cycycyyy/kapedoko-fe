create or replace function public.withdraw_shop_claim(p_claim_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  gone uuid;
  shop uuid;
begin
  if uid is null then
    raise exception 'Sign in to withdraw this claim.';
  end if;

  delete from public.shop_claims
  where id = p_claim_id
    and claimant_id = uid
    and status = 'pending'
  returning id, shop_id into gone, shop;

  if gone is null then
    raise exception 'This claim is not waiting for review.';
  end if;

  perform public.admin_write_audit(
    'claim.withdraw',
    'shop_claim',
    gone::text,
    jsonb_build_object('shop_id', shop)
  );
end;
$$;

revoke all on function public.withdraw_shop_claim(uuid) from public, anon;
grant execute on function public.withdraw_shop_claim(uuid) to authenticated;

notify pgrst, 'reload schema';
