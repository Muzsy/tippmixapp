drop policy if exists "avatars insert own" on storage.objects;
drop policy if exists "avatars update own" on storage.objects;
drop policy if exists "avatars delete own" on storage.objects;
drop policy if exists "avatars read own"   on storage.objects;

create policy "avatars insert own"
  on storage.objects for insert to authenticated
  with check (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

create policy "avatars update own"
  on storage.objects for update to authenticated
  using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text)
  with check (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

create policy "avatars delete own"
  on storage.objects for delete to authenticated
  using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

create policy "avatars read own"
  on storage.objects for select to authenticated
  using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);

