-- AFFARYETTE — Schéma complet / mise à niveau Supabase
-- Exécuter dans Supabase > SQL Editor. Compatible avec la base initiale.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null default '',
 role text not null default 'user' check (role in ('user','admin')),
 created_at timestamptz not null default now()
);
alter table public.profiles add column if not exists full_name text not null default '';
alter table public.profiles add column if not exists role text not null default 'user';

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=''
as $$
begin
 insert into public.profiles(id,full_name)
 values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''))
 on conflict(id) do update set full_name=excluded.full_name;
 return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.products(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 category text not null check(category in ('Vêtements','Chaussures','Accessoires','Maison','Beauté')),
 price numeric(10,2) not null check(price>0),
 city text not null, description text not null, image_url text,
 created_at timestamptz not null default now()
);
-- Remove the old books constraint and prevent new book category entries.
alter table public.products drop constraint if exists products_category_check;
alter table public.products add constraint products_category_check
 check(category in ('Vêtements','Chaussures','Accessoires','Maison','Beauté')) not valid;

create table if not exists public.messages(
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users(id) on delete set null,
 name text not null,email text not null,subject text not null,message text not null,
 created_at timestamptz not null default now()
);
create table if not exists public.orders(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 items jsonb not null,
 total numeric(10,2) not null check(total>=0),
 status text not null default 'pending',
 created_at timestamptz not null default now()
);
alter table public.orders add column if not exists delivery_fee numeric(10,2) not null default 0;
alter table public.orders add column if not exists full_name text;
alter table public.orders add column if not exists phone text;
alter table public.orders add column if not exists city text;
alter table public.orders add column if not exists address text;
alter table public.orders add column if not exists payment_method text not null default 'cash_on_delivery';
-- Modes de paiement proposés : espèces à la livraison ou règlement électronique/virement confirmé manuellement.

alter table public.orders drop constraint if exists orders_status_check;
alter table public.orders add constraint orders_status_check
 check(status in ('pending','confirmed','shipped','delivered','cancelled')) not valid;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=''
as $$
 select exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin');
$$;

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.messages enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles for select to authenticated
using(id=(select auth.uid()) or public.is_admin());
drop policy if exists "Users update own profile name" on public.profiles;
create policy "Users update own profile name" on public.profiles for update to authenticated
using(id=(select auth.uid())) with check(id=(select auth.uid()) and role='user');

drop policy if exists "Anyone can read products" on public.products;
create policy "Anyone can read products" on public.products for select to anon,authenticated using(true);
drop policy if exists "Authenticated users create own products" on public.products;
create policy "Authenticated users create own products" on public.products for insert to authenticated
with check(user_id=(select auth.uid()));
drop policy if exists "Owners and admins update products" on public.products;
create policy "Owners and admins update products" on public.products for update to authenticated
using(user_id=(select auth.uid()) or public.is_admin())
with check(user_id=(select auth.uid()) or public.is_admin());
drop policy if exists "Owners and admins delete products" on public.products;
create policy "Owners and admins delete products" on public.products for delete to authenticated
using(user_id=(select auth.uid()) or public.is_admin());

drop policy if exists "Anyone can send contact messages" on public.messages;
create policy "Anyone can send contact messages" on public.messages for insert to anon,authenticated with check(true);
drop policy if exists "Admins read messages" on public.messages;
create policy "Admins read messages" on public.messages for select to authenticated using(public.is_admin());
drop policy if exists "Admins delete messages" on public.messages;
create policy "Admins delete messages" on public.messages for delete to authenticated using(public.is_admin());

drop policy if exists "Users create own orders" on public.orders;
create policy "Users create own orders" on public.orders for insert to authenticated
with check(user_id=(select auth.uid()));
drop policy if exists "Users read own orders" on public.orders;
create policy "Users read own orders" on public.orders for select to authenticated
using(user_id=(select auth.uid()) or public.is_admin());
drop policy if exists "Admins update orders" on public.orders;
create policy "Admins update orders" on public.orders for update to authenticated
using(public.is_admin()) with check(public.is_admin());

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('product-images','product-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=5242880,
allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images" on storage.objects for select to anon,authenticated
using(bucket_id='product-images');
drop policy if exists "Users upload to own folder" on storage.objects;
create policy "Users upload to own folder" on storage.objects for insert to authenticated
with check(bucket_id='product-images' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Owners and admins delete product images" on storage.objects;
create policy "Owners and admins delete product images" on storage.objects for delete to authenticated
using(bucket_id='product-images' and ((storage.foldername(name))[1]=(select auth.uid())::text or public.is_admin()));

-- Après création du compte, donner le rôle administrateur en remplaçant l'adresse :
-- update public.profiles set role='admin'
-- where id=(select id from auth.users where email='VOTRE_EMAIL');
