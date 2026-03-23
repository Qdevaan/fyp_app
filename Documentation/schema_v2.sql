-- ================================================================================
--  BUBBLES AI ASSISTANT — COMPLETE DATABASE SCHEMA v2.0
--  Date      : March 20, 2026
--  Status    : MASTER DESIGN — run this to rebuild the entire schema from scratch
--  RLS       : DISABLED on all tables (re-enable per table before production)
--  Coverage  : All current tables + all planned feature tables
-- ================================================================================
--
--  TABLE GROUPS
--  ─────────────────────────────────────────────────────────────────────────────
--  GROUP A — Core User          : profiles, user_settings, onboarding_progress
--  GROUP B — Sessions           : sessions, session_logs, consultant_logs,
--                                  audio_sessions, session_analytics
--  GROUP C — Intelligence       : memory, knowledge_graphs, entities,
--                                  entity_attributes, entity_relations
--  GROUP D — Highlights & Events: highlights, events, feedback, sentiment_logs
--  GROUP E — Voice              : voice_enrollments, notification_tokens
--  GROUP F — Notifications      : notifications
--  GROUP G — Exports & Reports  : session_exports, coaching_reports
--  GROUP H — Subscriptions      : subscriptions, subscription_usage
--  GROUP I — Tagging            : tags, session_tags, entity_tags
--  GROUP J — Calendar & Integrations: calendar_integrations, calendar_sync_log,
--                                      integrations
--  GROUP K — Teams (future)     : team_workspaces, team_members, shared_sessions
--  GROUP L — Admin & Compliance : audit_log, data_deletion_requests, api_keys
-- ================================================================================


-- ════════════════════════════════════════════════════════════════════════════════
-- 1. EXTENSIONS
-- ════════════════════════════════════════════════════════════════════════════════
create extension if not exists "uuid-ossp" schema extensions;
create extension if not exists "vector"    schema extensions;
create extension if not exists "pg_trgm"   schema extensions;
create extension if not exists "pg_cron"   schema extensions;  -- future: scheduled jobs


-- ════════════════════════════════════════════════════════════════════════════════
-- 2. DROP EVERYTHING (children first, then parents)
-- ════════════════════════════════════════════════════════════════════════════════

-- Group L
drop table if exists public.api_keys                cascade;
drop table if exists public.data_deletion_requests   cascade;
drop table if exists public.audit_log                cascade;
-- Group K
drop table if exists public.shared_sessions          cascade;
drop table if exists public.team_members             cascade;
drop table if exists public.team_workspaces          cascade;
-- Group J
drop table if exists public.calendar_sync_log        cascade;
drop table if exists public.calendar_integrations    cascade;
drop table if exists public.integrations             cascade;
-- Group I
drop table if exists public.entity_tags              cascade;
drop table if exists public.session_tags             cascade;
drop table if exists public.tags                     cascade;
-- Group H
drop table if exists public.subscription_usage       cascade;
drop table if exists public.subscriptions            cascade;
-- Group G
drop table if exists public.coaching_reports         cascade;
drop table if exists public.session_exports          cascade;
-- Group F
drop table if exists public.notifications            cascade;
-- Group E
drop table if exists public.notification_tokens      cascade;
drop table if exists public.voice_enrollments        cascade;
-- Group D
drop table if exists public.feedback                 cascade;
drop table if exists public.sentiment_logs           cascade;
drop table if exists public.events                   cascade;
drop table if exists public.highlights               cascade;
-- Group C
drop table if exists public.entity_relations         cascade;
drop table if exists public.entity_attributes        cascade;
drop table if exists public.entities                 cascade;
drop table if exists public.knowledge_graphs         cascade;
drop table if exists public.memory                   cascade;
-- Group B
drop table if exists public.session_analytics        cascade;
drop table if exists public.audio_sessions           cascade;
drop table if exists public.consultant_logs          cascade;
drop table if exists public.session_logs             cascade;
drop table if exists public.sessions                 cascade;
-- Group A
drop table if exists public.onboarding_progress      cascade;
drop table if exists public.user_settings            cascade;
drop table if exists public.profiles                 cascade;

drop function if exists public.match_memory(extensions.vector, float, int, uuid)   cascade;
drop function if exists public.match_memory_typed(extensions.vector, float, int, uuid, text) cascade;
drop function if exists public.search_entities(text, uuid, int)                     cascade;


-- ════════════════════════════════════════════════════════════════════════════════
-- 3. CREATE TABLES
-- ════════════════════════════════════════════════════════════════════════════════


-- ─── GROUP A: CORE USER ──────────────────────────────────────────────────────

-- [A1] profiles — 1:1 with auth.users. Display info, avatar, demographics.
create table public.profiles (
    id              uuid        not null primary key references auth.users (id) on delete cascade,
    full_name       text,
    avatar_url      text,
    dob             date,
    gender          text,
    country         text,
    phone           text,
    bio             text,
    timezone        text        default 'UTC',
    language        text        default 'en',
    is_verified     bool        not null default false,
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz
);

-- [A2] user_settings — All per-user preferences (voice, theme, notifications, etc.)
create table public.user_settings (
    user_id                 uuid        not null primary key references auth.users (id) on delete cascade,
    -- Voice assistant
    voice_mode              text        not null default 'neutral'
                                        check (voice_mode in ('male','female','neutral')),
    wake_word_enabled       bool        not null default true,
    tts_enabled             bool        not null default true,
    stt_language            text        not null default 'en-US',
    -- Wingman behaviour
    wingman_mode            text        not null default 'casual'
                                        check (wingman_mode in ('casual','semi-formal','formal','business')),
    wingman_response_length text        not null default 'short'
                                        check (wingman_response_length in ('short','medium','detailed')),
    auto_start_wingman      bool        not null default false,
    -- Consultant behaviour
    consultant_mode         text        not null default 'casual'
                                        check (consultant_mode in ('casual','serious')),
    streaming_enabled       bool        not null default true,
    -- Notifications
    push_highlights         bool        not null default true,
    push_events             bool        not null default true,
    push_weekly_digest      bool        not null default false,
    push_reminders          bool        not null default true,
    -- Privacy
    save_audio_locally      bool        not null default false,
    store_vector_memory     bool        not null default true,
    store_knowledge_graph   bool        not null default true,
    -- Display
    theme                   text        not null default 'dark'
                                        check (theme in ('dark','light','system')),
    accent_color            text        default '#6C63FF',
    font_size               text        not null default 'medium'
                                        check (font_size in ('small','medium','large')),
    -- Misc
    onboarding_complete     bool        not null default false,
    updated_at              timestamptz not null default timezone('utc', now())
);

-- [A3] onboarding_progress — Track which onboarding steps the user has completed.
create table public.onboarding_progress (
    user_id             uuid        not null primary key references auth.users (id) on delete cascade,
    profile_done        bool        not null default false,  -- filled name, avatar
    voice_enrolled      bool        not null default false,  -- completed voice enrollment
    first_wingman       bool        not null default false,  -- ran first live session
    first_consultant    bool        not null default false,  -- asked first consultant question
    server_connected    bool        not null default false,  -- scanned QR / connected server
    tutorial_dismissed  bool        not null default false,
    completed_at        timestamptz,
    updated_at          timestamptz not null default timezone('utc', now())
);


-- ─── GROUP B: SESSIONS ───────────────────────────────────────────────────────

-- [B1] sessions — Top-level record for every wingman or consultant session.
create table public.sessions (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    mode            text        not null default 'consultant'
                                check (mode in ('live_wingman','consultant')),
    status          text        not null default 'active'
                                check (status in ('active','completed','archived','deleted')),
    title           text                 default 'New Conversation',
    summary         text,
    location        text,                -- optional: where the meeting happened
    participants    text[],              -- list of participant names (free text)
    tags            text[],              -- quick string tags for filtering
    is_starred      bool        not null default false,
    is_ephemeral    bool        not null default false, -- Section 5: Ephemeral Sessions
    is_multiplayer  bool        not null default false, -- Section 5: Multiplayer / Co-Pilot Mode
    persona         text                 default 'casual', -- Section 5: Customizable AI Personas
    created_at      timestamptz not null default timezone('utc', now()),
    ended_at        timestamptz,
    deleted_at      timestamptz          -- soft delete
);

-- [B2] session_logs — Full conversation transcript. Realtime-enabled.
create table public.session_logs (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    session_id      uuid        not null references public.sessions (id) on delete cascade,
    role            text        not null check (role in ('user','others','llm','system')),
    content         text        not null,
    speaker_label   text,                -- diarization label e.g. "SPEAKER_00"
    speaker_name    text,                -- resolved name after diarization mapping
    confidence      float,               -- STT confidence (0.0–1.0)
    sentiment_score float,               -- per-turn sentiment (-1.0 to +1.0)
    sentiment_label text                 check (sentiment_label in ('positive','neutral','negative')),
    is_advice       bool        not null default false,  -- true when role='llm' and it's wingman advice
    latency_ms      int,                 -- roundtrip latency for advice rows
    created_at      timestamptz not null default timezone('utc', now())
);

-- [B3] consultant_logs — Lightweight Q&A log for consultant mode (drawer history).
create table public.consultant_logs (
    id          uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id     uuid        not null references auth.users (id) on delete cascade,
    session_id  uuid                 references public.sessions (id) on delete set null,
    question    text,
    answer      text,
    model_used  text,                 -- which LLM model answered
    tokens_used int,                  -- approximate token count
    latency_ms  int,                  -- server response time
    rating      smallint            check (rating in (1,2,3,4,5)),  -- user star rating
    created_at  timestamptz not null default timezone('utc', now())
);

-- [B4] audio_sessions — Device-side audio recording metadata. Binary never stored here.
create table public.audio_sessions (
    id                uuid        not null default extensions.uuid_generate_v4() primary key,
    session_id        uuid        not null references public.sessions (id) on delete cascade,
    user_id           uuid        not null references auth.users (id) on delete cascade,
    local_path        text        not null,
    file_name         text        not null,
    format            text                 default 'aac'
                                  check (format in ('aac','m4a','wav','mp3')),
    duration_seconds  float,
    file_size_bytes   bigint,
    device_id         text,
    sample_rate_hz    int,
    channel_count     smallint,
    is_available      bool        not null default true,
    was_transcribed   bool        not null default false,
    recorded_at       timestamptz not null default timezone('utc', now())
);

-- [B5] session_analytics — Aggregated per-session metrics computed at session end.
create table public.session_analytics (
    session_id              uuid        not null primary key references public.sessions (id) on delete cascade,
    user_id                 uuid        not null references auth.users (id) on delete cascade,
    total_turns             int         default 0,
    user_turns              int         default 0,
    others_turns            int         default 0,
    llm_turns               int         default 0,
    avg_advice_latency_ms   float,
    total_duration_seconds  float,
    total_tokens_used       int,
    entities_extracted      int         default 0,
    memories_saved          int         default 0,
    events_extracted        int         default 0,
    highlights_created      int         default 0,
    conflicts_detected      int         default 0,
    avg_sentiment_score     float,
    dominant_sentiment      text        check (dominant_sentiment in ('positive','neutral','negative')),
    computed_at             timestamptz not null default timezone('utc', now())
);


-- ─── GROUP C: INTELLIGENCE ───────────────────────────────────────────────────

-- [C1] memory — Long-term vector memory. 384-dim MiniLM embeddings.
create table public.memory (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    session_id      uuid                 references public.sessions (id) on delete set null,
    content         text        not null,
    memory_type     text                 default 'fact'
                                check (memory_type in ('fact','summary','event','preference','person','goal')),
    source          text                 default 'session'
                                check (source in ('session','consultant','voice_command','manual')),
    embedding       extensions.vector(384),
    importance      float                default 0.5,  -- 0.0 (low) to 1.0 (critical)
    access_count    int         not null default 0,
    last_accessed   timestamptz,
    is_pinned       bool        not null default false,
    is_archived     bool        not null default false,
    created_at      timestamptz not null default timezone('utc', now()),
    expires_at      timestamptz          -- null = never expires
);

-- [C2] knowledge_graphs — Serialised NetworkX graph as JSONB. One record per user.
create table public.knowledge_graphs (
    user_id         uuid        not null primary key references auth.users (id) on delete cascade,
    graph_data      jsonb,
    node_count      int         generated always as (jsonb_array_length(graph_data->'nodes')) stored,
    edge_count      int,                 -- updated manually on save
    schema_version  text                 default 'v1',
    updated_at      timestamptz          default now()
);

-- [C3] entities — Named entity registry. One row per unique entity per user.
create table public.entities (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    canonical_name  text        not null,
    display_name    text        not null,
    entity_type     text        not null default 'person'
                                check (entity_type in ('person','place','organization','event','object','concept','topic')),
    description     text,
    avatar_url      text,                -- user can set a photo for a person entity
    external_url    text,                -- LinkedIn, company website, etc.
    sentiment       float,               -- overall sentiment towards this entity (-1 to +1)
    importance      float       default 0.5,  -- how significant is this entity to the user
    first_seen_at   timestamptz not null default timezone('utc', now()),
    last_seen_at    timestamptz not null default timezone('utc', now()),
    mention_count   int         not null default 1,
    is_archived     bool        not null default false,
    created_at      timestamptz not null default timezone('utc', now()),
    constraint entities_user_canonical_unique unique (user_id, canonical_name)
);

-- [C4] entity_attributes — Key-value facts per entity. One value per key (upserted).
create table public.entity_attributes (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    entity_id       uuid        not null references public.entities (id) on delete cascade,
    attribute_key   text        not null,
    attribute_value text        not null,
    source_session  uuid                 references public.sessions (id) on delete set null,
    confidence      float                default 1.0,
    is_verified     bool        not null default false,  -- user confirmed this fact
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now()),
    constraint entity_attr_unique unique (entity_id, attribute_key)
);

-- [C5] entity_relations — Directed edges: (source) --[relation]--> (target)
create table public.entity_relations (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    source_id       uuid        not null references public.entities (id) on delete cascade,
    target_id       uuid        not null references public.entities (id) on delete cascade,
    relation        text        not null,
    weight          float                default 1.0,
    source_session  uuid                 references public.sessions (id) on delete set null,
    is_verified     bool                 default false,
    is_archived     bool        not null default false,
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now()),
    constraint entity_relations_unique unique (source_id, target_id, relation)
);


-- ─── GROUP D: HIGHLIGHTS, EVENTS, FEEDBACK, SENTIMENT ────────────────────────

-- [D1] highlights — Home screen flags: conflicts, important facts, suggestions, warnings.
create table public.highlights (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    session_id      uuid                 references public.sessions (id) on delete set null,
    highlight_type  text        not null default 'important'
                                check (highlight_type in ('conflict','important','suggestion','warning','achievement','reminder')),
    title           text        not null,
    body            text        not null,
    related_entity  uuid                 references public.entities (id) on delete set null,
    action_url      text,                -- deep-link route if user taps to act on it
    priority        smallint    not null default 2
                                check (priority between 1 and 5),  -- 1=low, 5=critical
    is_read         bool        not null default false,
    is_resolved     bool        not null default false,
    is_dismissed    bool        not null default false,
    is_pinned       bool        not null default false,
    reviewed_at     timestamptz,
    created_at      timestamptz not null default timezone('utc', now())
);

-- [D2] events — Calendar items and deadlines extracted from conversations.
create table public.events (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    session_id      uuid                 references public.sessions (id) on delete set null,
    title           text        not null,
    description     text,
    location        text,
    due_at          timestamptz,
    due_text        text,                -- raw NL expression e.g. "next Friday 3pm"
    end_at          timestamptz,         -- for duration events (meetings)
    related_entity  uuid                 references public.entities (id) on delete set null,
    recurrence      text,                -- 'daily'|'weekly'|'monthly'|null
    priority        smallint    not null default 2 check (priority between 1 and 5),
    is_completed    bool        not null default false,
    is_cancelled    bool        not null default false,
    calendar_event_id text,              -- ID from Google/Outlook after sync
    synced_at       timestamptz,         -- when it was pushed to external calendar
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now())
);

-- [D3] feedback — User thumbs up/down or star rating on individual advice/answers.
create table public.feedback (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    session_id      uuid                 references public.sessions (id) on delete set null,
    session_log_id  uuid                 references public.session_logs (id) on delete set null,
    consultant_log_id uuid               references public.consultant_logs (id) on delete set null,
    feedback_type   text        not null check (feedback_type in ('thumbs','star','text')),
    value           smallint             check (value between -1 and 5),  -- -1=bad, 0=ok, 1=good; or 1-5 stars
    comment         text,
    created_at      timestamptz not null default timezone('utc', now())
);

-- [D4] sentiment_logs — Per-session rolling sentiment aggregates over time.
create table public.sentiment_logs (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    session_id      uuid        not null references public.sessions (id) on delete cascade,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    turn_index      int         not null,          -- which transcript turn this belongs to
    speaker_role    text        not null check (speaker_role in ('user','others','llm')),
    score           float       not null,           -- -1.0 (negative) to +1.0 (positive)
    label           text        not null check (label in ('positive','neutral','negative')),
    emotion         text,                           -- 'happy'|'frustrated'|'uncertain'|'confident'
    recorded_at     timestamptz not null default timezone('utc', now())
);


-- ─── GROUP E: VOICE ──────────────────────────────────────────────────────────

-- [E1] voice_enrollments — Speaker fingerprint. One row per user. 192-dim ECAPA-TDNN.
create table public.voice_enrollments (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null unique references auth.users (id) on delete cascade,
    embedding       extensions.vector(192),
    model_version   text                 default 'v1',
    audio_duration_s float,              -- length of enrollment sample used
    quality_score   float,               -- confidence in enrollment quality (0-1)
    enrolled_at     timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now())
);

-- [E2] notification_tokens — FCM/APNs push tokens per device.
create table public.notification_tokens (
    id          uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id     uuid        not null references auth.users (id) on delete cascade,
    token       text        not null,
    platform    text        not null check (platform in ('android','ios','web')),
    device_id   text,
    app_version text,
    is_active   bool        not null default true,
    created_at  timestamptz not null default timezone('utc', now()),
    last_seen   timestamptz,
    constraint notification_tokens_unique unique (user_id, token)
);


-- ─── GROUP F: NOTIFICATIONS ──────────────────────────────────────────────────

-- [F1] notifications — All push/in-app notifications sent to a user.
create table public.notifications (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    title           text        not null,
    body            text        not null,
    notif_type      text        not null check (notif_type in ('highlight','event_reminder','weekly_digest','proactive','system','achievement')),
    related_id      uuid,
    related_table   text,
    action_route    text,
    is_read         bool        not null default false,
    is_sent         bool        not null default false,
    sent_at         timestamptz,
    read_at         timestamptz,
    created_at      timestamptz not null default timezone('utc', now())
);


-- ─── GROUP G: EXPORTS & COACHING REPORTS ─────────────────────────────────────

-- [G1] session_exports — Log of every export generated for a session.
create table public.session_exports (
    id                  uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id             uuid        not null references auth.users (id) on delete cascade,
    session_id          uuid        not null references public.sessions (id) on delete cascade,
    format              text        not null check (format in ('pdf','txt','markdown','json','srt')),
    storage_url         text,
    file_size_bytes     bigint,
    include_entities    bool        not null default true,
    include_highlights  bool        not null default true,
    include_events      bool        not null default true,
    include_sentiment   bool        not null default false,
    status              text        not null default 'pending'
                                    check (status in ('pending','generating','ready','failed')),
    error_message       text,
    generated_at        timestamptz,
    expires_at          timestamptz,
    created_at          timestamptz not null default timezone('utc', now())
);

-- [G2] coaching_reports — AI-generated post-session coaching analysis.
create table public.coaching_reports (
    id                  uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id             uuid        not null references auth.users (id) on delete cascade,
    session_id          uuid        not null unique references public.sessions (id) on delete cascade,
    user_talk_pct       float,
    others_talk_pct     float,
    key_topics          text[],
    key_decisions       text[],
    action_items        text[],
    follow_up_people    text[],
    avg_words_per_min   float,
    filler_word_count   int,
    filler_words        text[],
    tone_summary        text,
    engagement_trend    text,
    suggestions         text[],
    strengths           text[],
    report_text         text,
    model_used          text,
    generated_at        timestamptz not null default timezone('utc', now())
);


-- ─── GROUP H: SUBSCRIPTIONS & USAGE ──────────────────────────────────────────

-- [H1] subscriptions — User subscription plan and billing state.
create table public.subscriptions (
    id                      uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id                 uuid        not null unique references auth.users (id) on delete cascade,
    plan                    text        not null default 'free'
                                        check (plan in ('free','pro','team','enterprise')),
    status                  text        not null default 'active'
                                        check (status in ('active','cancelled','expired','past_due','trial')),
    billing_period          text                 check (billing_period in ('monthly','annual')),
    price_usd               numeric(8,2),
    provider                text                 check (provider in ('revenuecat','stripe','none')),
    provider_customer_id    text,
    provider_sub_id         text,
    trial_ends_at           timestamptz,
    current_period_start    timestamptz,
    current_period_end      timestamptz,
    cancelled_at            timestamptz,
    created_at              timestamptz not null default timezone('utc', now()),
    updated_at              timestamptz not null default timezone('utc', now())
);

-- [H2] subscription_usage — Monthly usage counters per feature, per user.
create table public.subscription_usage (
    id                  uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id             uuid        not null references auth.users (id) on delete cascade,
    period_start        date        not null,
    wingman_minutes     float       not null default 0,
    consultant_queries  int         not null default 0,
    exports_generated   int         not null default 0,
    voice_enrollments   int         not null default 0,
    push_notifications  int         not null default 0,
    api_calls           int         not null default 0,
    tokens_consumed     int         not null default 0,
    updated_at          timestamptz not null default timezone('utc', now()),
    constraint subscription_usage_unique unique (user_id, period_start)
);


-- ─── GROUP I: TAGGING ────────────────────────────────────────────────────────

-- [I1] tags — User-defined reusable labels.
create table public.tags (
    id          uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id     uuid        not null references auth.users (id) on delete cascade,
    name        text        not null,
    color       text        default '#6C63FF',
    icon        text,
    created_at  timestamptz not null default timezone('utc', now()),
    constraint tags_user_name_unique unique (user_id, name)
);

-- [I2] session_tags — Many-to-many: sessions to tags.
create table public.session_tags (
    session_id  uuid not null references public.sessions (id) on delete cascade,
    tag_id      uuid not null references public.tags (id) on delete cascade,
    primary key (session_id, tag_id)
);

-- [I3] entity_tags — Many-to-many: entities to tags.
create table public.entity_tags (
    entity_id   uuid not null references public.entities (id) on delete cascade,
    tag_id      uuid not null references public.tags (id) on delete cascade,
    primary key (entity_id, tag_id)
);


-- ─── GROUP J: CALENDAR & INTEGRATIONS ────────────────────────────────────────

-- [J1] calendar_integrations — OAuth2 tokens for Google / Outlook calendar.
create table public.calendar_integrations (
    id                  uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id             uuid        not null references auth.users (id) on delete cascade,
    provider            text        not null check (provider in ('google','outlook','apple')),
    email               text,
    access_token        text,
    refresh_token       text,
    token_expires_at    timestamptz,
    calendar_id         text,
    is_active           bool        not null default true,
    last_synced_at      timestamptz,
    created_at          timestamptz not null default timezone('utc', now()),
    updated_at          timestamptz not null default timezone('utc', now()),
    constraint calendar_integrations_unique unique (user_id, provider)
);

-- [J2] calendar_sync_log — Audit trail of every event pushed to an external calendar.
create table public.calendar_sync_log (
    id                  uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id             uuid        not null references auth.users (id) on delete cascade,
    event_id            uuid        not null references public.events (id) on delete cascade,
    integration_id      uuid        not null references public.calendar_integrations (id) on delete cascade,
    external_event_id   text,
    status              text        not null check (status in ('success','failed','skipped')),
    error_message       text,
    synced_at           timestamptz not null default timezone('utc', now())
);

-- [J3] integrations — Generic third-party integration configs (Slack, Notion, CRM, etc.)
create table public.integrations (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    provider        text        not null check (provider in ('slack','notion','hubspot','salesforce','linear','jira','zapier','webhook')),
    display_name    text,
    webhook_url     text,
    api_key         text,
    config          jsonb,
    is_active       bool        not null default true,
    last_triggered  timestamptz,
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now()),
    constraint integrations_unique unique (user_id, provider)
);


-- ─── GROUP K: TEAMS (future feature) ─────────────────────────────────────────

-- [K1] team_workspaces
create table public.team_workspaces (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    name            text        not null,
    description     text,
    owner_id        uuid        not null references auth.users (id) on delete cascade,
    avatar_url      text,
    plan            text        not null default 'team' check (plan in ('team','enterprise')),
    max_members     int         not null default 5,
    is_active       bool        not null default true,
    created_at      timestamptz not null default timezone('utc', now()),
    updated_at      timestamptz not null default timezone('utc', now())
);

-- [K2] team_members
create table public.team_members (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    workspace_id    uuid        not null references public.team_workspaces (id) on delete cascade,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    role            text        not null default 'member' check (role in ('owner','admin','member','viewer')),
    invited_by      uuid                 references auth.users (id) on delete set null,
    joined_at       timestamptz,
    invite_status   text        not null default 'pending' check (invite_status in ('pending','accepted','declined','revoked')),
    created_at      timestamptz not null default timezone('utc', now()),
    constraint team_members_unique unique (workspace_id, user_id)
);

-- [K3] shared_sessions
create table public.shared_sessions (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    session_id      uuid        not null references public.sessions (id) on delete cascade,
    workspace_id    uuid        not null references public.team_workspaces (id) on delete cascade,
    shared_by       uuid        not null references auth.users (id) on delete cascade,
    permissions     text        not null default 'view' check (permissions in ('view','comment','edit')),
    shared_at       timestamptz not null default timezone('utc', now()),
    constraint shared_sessions_unique unique (session_id, workspace_id)
);


-- ─── GROUP L: ADMIN & COMPLIANCE ─────────────────────────────────────────────

-- [L1] audit_log — Immutable record of sensitive actions.
create table public.audit_log (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid                 references auth.users (id) on delete set null,
    actor_id        uuid                 references auth.users (id) on delete set null,
    action          text        not null,
    resource_type   text,
    resource_id     uuid,
    old_value       jsonb,
    new_value       jsonb,
    ip_address      inet,
    user_agent      text,
    created_at      timestamptz not null default timezone('utc', now())
);

-- [L2] data_deletion_requests — GDPR / user-requested data wipes.
create table public.data_deletion_requests (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    reason          text,
    scope           text        not null default 'all' check (scope in ('all','memory','sessions','entities','profile')),
    status          text        not null default 'pending' check (status in ('pending','processing','completed','failed')),
    requested_at    timestamptz not null default timezone('utc', now()),
    completed_at    timestamptz,
    processed_by    text
);

-- [L3] api_keys — User-generated API keys for integrations.
create table public.api_keys (
    id              uuid        not null default extensions.uuid_generate_v4() primary key,
    user_id         uuid        not null references auth.users (id) on delete cascade,
    name            text        not null,
    key_hash        text        not null unique,
    key_prefix      text        not null,
    scopes          text[]      not null default '{read}',
    last_used_at    timestamptz,
    expires_at      timestamptz,
    is_active       bool        not null default true,
    created_at      timestamptz not null default timezone('utc', now())
);


-- ════════════════════════════════════════════════════════════════════════════════
-- 4. FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════

-- [FN1] match_memory — Vector search over all long-term memory for a user.
create or replace function public.match_memory(
    query_embedding  extensions.vector(384),
    match_threshold  float,
    match_count      int,
    p_user_id        uuid
)
returns table (id uuid, content text, memory_type text, importance float, similarity float)
language sql stable as $$
    select id, content, memory_type, importance,
           1 - (embedding <=> query_embedding) as similarity
    from   public.memory
    where  user_id     = p_user_id
      and  is_archived = false
      and  (expires_at is null or expires_at > now())
      and  1 - (embedding <=> query_embedding) > match_threshold
    order  by embedding <=> query_embedding
    limit  match_count;
$$;

-- [FN2] match_memory_typed — Same but filtered to one memory_type.
create or replace function public.match_memory_typed(
    query_embedding  extensions.vector(384),
    match_threshold  float,
    match_count      int,
    p_user_id        uuid,
    p_memory_type    text
)
returns table (id uuid, content text, memory_type text, importance float, similarity float)
language sql stable as $$
    select id, content, memory_type, importance,
           1 - (embedding <=> query_embedding) as similarity
    from   public.memory
    where  user_id     = p_user_id
      and  memory_type = p_memory_type
      and  is_archived = false
      and  (expires_at is null or expires_at > now())
      and  1 - (embedding <=> query_embedding) > match_threshold
    order  by embedding <=> query_embedding
    limit  match_count;
$$;

-- [FN3] match_voice — Cosine similarity search for speaker identification.
create or replace function public.match_voice(
    query_embedding  extensions.vector(192),
    match_threshold  float,
    match_count      int
)
returns table (user_id uuid, similarity float)
language sql stable as $$
    select user_id,
           1 - (embedding <=> query_embedding) as similarity
    from   public.voice_enrollments
    where  1 - (embedding <=> query_embedding) > match_threshold
    order  by embedding <=> query_embedding
    limit  match_count;
$$;

-- [FN4] get_user_stats — Returns summary counts for a user (home screen dashboard).
create or replace function public.get_user_stats(p_user_id uuid)
returns table (
    total_sessions   bigint,
    total_memories   bigint,
    total_entities   bigint,
    total_highlights bigint,
    open_events      bigint
)
language sql stable as $$
    select
        (select count(*) from public.sessions   where user_id = p_user_id and deleted_at is null),
        (select count(*) from public.memory     where user_id = p_user_id and is_archived = false),
        (select count(*) from public.entities   where user_id = p_user_id and is_archived = false),
        (select count(*) from public.highlights where user_id = p_user_id and is_dismissed = false and is_resolved = false),
        (select count(*) from public.events     where user_id = p_user_id and is_completed = false and is_cancelled = false);
$$;


-- ════════════════════════════════════════════════════════════════════════════════
-- 5. INDEXES
-- ════════════════════════════════════════════════════════════════════════════════

-- HNSW (vector similarity)
create index idx_memory_embedding         on public.memory            using hnsw (embedding vector_cosine_ops);
create index idx_voice_embedding          on public.voice_enrollments using hnsw (embedding vector_cosine_ops);

-- Sessions
create index idx_sessions_user            on public.sessions          (user_id, status);
create index idx_sessions_created         on public.sessions          (user_id, created_at desc);
create index idx_sessions_deleted         on public.sessions          (deleted_at) where deleted_at is null;
create index idx_sessions_starred         on public.sessions          (user_id, is_starred) where is_starred = true;

-- Session logs
create index idx_session_logs_session     on public.session_logs      (session_id, created_at);
create index idx_session_logs_role        on public.session_logs      (session_id, role);

-- Consultant logs
create index idx_consultant_logs_user     on public.consultant_logs   (user_id, created_at desc);
create index idx_consultant_logs_session  on public.consultant_logs   (session_id, created_at);

-- Memory
create index idx_memory_user_type         on public.memory            (user_id, memory_type, created_at desc);
create index idx_memory_active            on public.memory            (user_id, is_archived, expires_at);
create index idx_memory_pinned            on public.memory            (user_id, is_pinned) where is_pinned = true;

-- Entities
create index idx_entities_canonical       on public.entities          (user_id, canonical_name);
create index idx_entities_type            on public.entities          (user_id, entity_type);
create index idx_entities_mention         on public.entities          (user_id, mention_count desc);
create index idx_entities_active          on public.entities          (user_id, is_archived) where is_archived = false;
create index idx_entity_attr_entity       on public.entity_attributes (entity_id);
create index idx_entity_rel_source        on public.entity_relations  (source_id);
create index idx_entity_rel_target        on public.entity_relations  (target_id);
create index idx_entity_rel_user          on public.entity_relations  (user_id);

-- Highlights & events
create index idx_highlights_active        on public.highlights        (user_id, is_dismissed, is_resolved, created_at desc);
create index idx_highlights_priority      on public.highlights        (user_id, priority desc) where is_dismissed = false;
create index idx_events_open              on public.events            (user_id, is_completed, due_at);
create index idx_events_session           on public.events            (session_id);

-- Notifications
create index idx_notifications_unread     on public.notifications     (user_id, is_read, created_at desc);
create index idx_notifications_type       on public.notifications     (user_id, notif_type);
create index idx_notif_tokens_user        on public.notification_tokens (user_id, is_active) where is_active = true;

-- Feedback & sentiment
create index idx_feedback_session         on public.feedback          (session_id);
create index idx_sentiment_session        on public.sentiment_logs    (session_id, turn_index);

-- Audio
create index idx_audio_sessions_session   on public.audio_sessions    (session_id);

-- Subscriptions
create index idx_sub_usage_period         on public.subscription_usage (user_id, period_start desc);

-- Tags
create index idx_tags_user                on public.tags              (user_id);
create index idx_session_tags_tag         on public.session_tags      (tag_id);
create index idx_entity_tags_tag          on public.entity_tags       (tag_id);

-- Calendar
create index idx_cal_sync_event           on public.calendar_sync_log (event_id);

-- Teams
create index idx_team_members_workspace   on public.team_members      (workspace_id);
create index idx_team_members_user        on public.team_members      (user_id);

-- Audit & compliance
create index idx_audit_user               on public.audit_log         (user_id, created_at desc);
create index idx_audit_action             on public.audit_log         (action, created_at desc);

-- Trigram (fuzzy full-text search — requires pg_trgm)
create index idx_entities_name_trgm       on public.entities          using gin (canonical_name gin_trgm_ops);
create index idx_memory_content_trgm      on public.memory            using gin (content gin_trgm_ops);
create index idx_session_logs_trgm        on public.session_logs      using gin (content gin_trgm_ops);


-- ════════════════════════════════════════════════════════════════════════════════
-- 6. REALTIME PUBLICATIONS
-- ════════════════════════════════════════════════════════════════════════════════
alter publication supabase_realtime add table public.session_logs;
alter publication supabase_realtime add table public.highlights;
alter publication supabase_realtime add table public.events;
alter publication supabase_realtime add table public.notifications;


-- ════════════════════════════════════════════════════════════════════════════════
-- 7. ROW LEVEL SECURITY — DISABLED (re-enable per table before production)
-- ════════════════════════════════════════════════════════════════════════════════
alter table public.profiles                 disable row level security;
alter table public.user_settings            disable row level security;
alter table public.onboarding_progress      disable row level security;
alter table public.sessions                 disable row level security;
alter table public.session_logs             disable row level security;
alter table public.consultant_logs          disable row level security;
alter table public.audio_sessions           disable row level security;
alter table public.session_analytics        disable row level security;
alter table public.memory                   disable row level security;
alter table public.knowledge_graphs         disable row level security;
alter table public.entities                 disable row level security;
alter table public.entity_attributes        disable row level security;
alter table public.entity_relations         disable row level security;
alter table public.highlights               disable row level security;
alter table public.events                   disable row level security;
alter table public.feedback                 disable row level security;
alter table public.sentiment_logs           disable row level security;
alter table public.voice_enrollments        disable row level security;
alter table public.notification_tokens      disable row level security;
alter table public.notifications            disable row level security;
alter table public.session_exports          disable row level security;
alter table public.coaching_reports         disable row level security;
alter table public.subscriptions            disable row level security;
alter table public.subscription_usage       disable row level security;
alter table public.tags                     disable row level security;
alter table public.session_tags             disable row level security;
alter table public.entity_tags              disable row level security;
alter table public.calendar_integrations    disable row level security;
alter table public.calendar_sync_log        disable row level security;
alter table public.integrations             disable row level security;
alter table public.team_workspaces          disable row level security;
alter table public.team_members             disable row level security;
alter table public.shared_sessions          disable row level security;
alter table public.audit_log                disable row level security;
alter table public.data_deletion_requests   disable row level security;
alter table public.api_keys                 disable row level security;


-- ════════════════════════════════════════════════════════════════════════════════
-- 8. RLS POLICIES — commented out, restore when hardening for production
-- ════════════════════════════════════════════════════════════════════════════════
-- alter table public.profiles enable row level security;
-- create policy "Own profile"    on public.profiles        for all using (auth.uid() = id);
-- alter table public.user_settings enable row level security;
-- create policy "Own settings"   on public.user_settings   for all using (auth.uid() = user_id);
-- alter table public.sessions enable row level security;
-- create policy "Own sessions"   on public.sessions        for all using (auth.uid() = user_id);
-- alter table public.session_logs enable row level security;
-- create policy "Own logs"       on public.session_logs    for all using (
--     exists (select 1 from public.sessions s where s.id = session_logs.session_id and s.user_id = auth.uid())
-- );
-- alter table public.memory enable row level security;
-- create policy "Own memory"     on public.memory          for all using (auth.uid() = user_id);
-- alter table public.entities enable row level security;
-- create policy "Own entities"   on public.entities        for all using (auth.uid() = user_id);
-- alter table public.entity_attributes enable row level security;
-- create policy "Own attrs"      on public.entity_attributes for all using (
--     exists (select 1 from public.entities e where e.id = entity_attributes.entity_id and e.user_id = auth.uid())
-- );
-- alter table public.entity_relations enable row level security;
-- create policy "Own relations"  on public.entity_relations for all using (auth.uid() = user_id);
-- alter table public.highlights enable row level security;
-- create policy "Own highlights" on public.highlights      for all using (auth.uid() = user_id);
-- alter table public.events enable row level security;
-- create policy "Own events"     on public.events          for all using (auth.uid() = user_id);
-- alter table public.notifications enable row level security;
-- create policy "Own notifs"     on public.notifications   for all using (auth.uid() = user_id);
-- alter table public.subscriptions enable row level security;
-- create policy "Own sub"        on public.subscriptions   for all using (auth.uid() = user_id);
-- alter table public.api_keys enable row level security;
-- create policy "Own api keys"   on public.api_keys        for all using (auth.uid() = user_id);
-- alter table public.tags enable row level security;
-- create policy "Own tags"       on public.tags            for all using (auth.uid() = user_id);
-- (Add equivalent policies for all remaining tables following the same pattern.)


-- ════════════════════════════════════════════════════════════════════════════════
-- 9. TABLE INVENTORY
-- ════════════════════════════════════════════════════════════════════════════════
--
--  GRP  #   Table                    Realtime  Status   Purpose
--  ─────────────────────────────────────────────────────────────────────────────
--  A    1   profiles                 no        LIVE     Display info, avatar, demographics
--  A    2   user_settings            no        LIVE     All per-user preferences (voice, theme, notifs)
--  A    3   onboarding_progress      no        LIVE     Onboarding step completion tracker
--  B    4   sessions                 no        LIVE     Session metadata (mode, status, summary)
--  B    5   session_logs             YES       LIVE     Full conversation transcript per session
--  B    6   consultant_logs          no        LIVE     Consultant Q&A history
--  B    7   audio_sessions           no        LIVE     Device audio recording metadata
--  B    8   session_analytics        no        NEW      Aggregated per-session metrics
--  C    9   memory                   no        LIVE     Long-term vector memory (384-dim MiniLM)
--  C   10   knowledge_graphs         no        LIVE     NetworkX graph as JSONB per user
--  C   11   entities                 no        LIVE     Named entity registry (NER)
--  C   12   entity_attributes        no        LIVE     Key-value facts per entity
--  C   13   entity_relations         no        LIVE     Directed edges between entities
--  D   14   highlights               YES       LIVE     Conflict flags, important facts, warnings
--  D   15   events                   YES       LIVE     Calendar deadlines extracted from convos
--  D   16   feedback                 no        NEW      User thumbs/star ratings on advice
--  D   17   sentiment_logs           no        NEW      Per-turn sentiment scores (-1 to +1)
--  E   18   voice_enrollments        no        LIVE     Speaker fingerprint (ECAPA-TDNN 192-dim)
--  E   19   notification_tokens      no        NEW      FCM/APNs push tokens per device
--  F   20   notifications            YES       NEW      In-app and push notification log
--  G   21   session_exports          no        NEW      Export history (PDF/TXT/MD/JSON/SRT)
--  G   22   coaching_reports         no        NEW      AI post-session coaching analysis
--  H   23   subscriptions            no        FUTURE   Subscription plan + billing state
--  H   24   subscription_usage       no        FUTURE   Monthly feature usage counters
--  I   25   tags                     no        NEW      User-defined reusable labels
--  I   26   session_tags             no        NEW      Many-to-many: sessions to tags
--  I   27   entity_tags              no        NEW      Many-to-many: entities to tags
--  J   28   calendar_integrations    no        FUTURE   Google/Outlook OAuth token store
--  J   29   calendar_sync_log        no        FUTURE   Audit trail of calendar event pushes
--  J   30   integrations             no        FUTURE   Slack, Notion, CRM, webhook configs
--  K   31   team_workspaces          no        FUTURE   Team/org shared workspace
--  K   32   team_members             no        FUTURE   Membership + roles
--  K   33   shared_sessions          no        FUTURE   Sessions shared into a workspace
--  L   34   audit_log                no        NEW      Immutable action log for compliance
--  L   35   data_deletion_requests   no        NEW      GDPR data deletion queue
--  L   36   api_keys                 no        FUTURE   User-generated API keys
--  ─────────────────────────────────────────────────────────────────────────────
--  Total : 36 tables | 4 functions | 40+ indexes | 4 realtime tables
--
--  STATUS KEY:
--    LIVE   = existed in v1 schema and is carried forward (with enhancements)
--    NEW    = new in v2 — implement in the current sprint
--    FUTURE = placeholder — deploy when the feature ships
--
-- ════════════════════════════════════════════════════════════════════════════════
-- END OF SCHEMA v2.0
-- ════════════════════════════════════════════════════════════════════════════════
