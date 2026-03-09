-- Copyright (c) 2026 Cole Hoffman
-- Licensed under MIT License - see LICENSE file for details
--
-- Migration: 001_initial_schema.sql
-- Purpose: Sessions, hands, and player actions for poker coaching

-- Sessions: one per game configuration
create table public.sessions (
  id           uuid        primary key default gen_random_uuid(),
  created_at   timestamptz default now(),
  players      int         not null,
  position     text        not null,
  small_blind  numeric     not null,
  big_blind    numeric     not null,
  buy_in       numeric
);

-- Hands: one per dealt hand within a session
create table public.hands (
  id              uuid        primary key default gen_random_uuid(),
  session_id      uuid        references public.sessions(id) on delete cascade,
  created_at      timestamptz default now(),
  hole_cards      text[]      not null,
  community_cards text[]      default '{}',
  final_hand      text,
  hand_strength   numeric,
  phase_reached   text
);

-- Player actions: one per betting round per hand
create table public.player_actions (
  id         uuid        primary key default gen_random_uuid(),
  hand_id    uuid        references public.hands(id) on delete cascade,
  created_at timestamptz default now(),
  phase      text        not null,  -- preflop | flop | turn | river
  action     text        not null,  -- fold | check | call | bet | raise
  amount     numeric                -- for bet/raise only
);

-- RLS
alter table public.sessions       enable row level security;
alter table public.hands          enable row level security;
alter table public.player_actions enable row level security;

-- Anon access policies (MVP - no auth)
create policy "anon insert sessions"  on public.sessions       for insert to anon with check (true);
create policy "anon select sessions"  on public.sessions       for select to anon using (true);
create policy "anon insert hands"     on public.hands          for insert to anon with check (true);
create policy "anon select hands"     on public.hands          for select to anon using (true);
create policy "anon update hands"     on public.hands          for update to anon using (true);
create policy "anon insert actions"   on public.player_actions for insert to anon with check (true);
create policy "anon select actions"   on public.player_actions for select to anon using (true);
