# Schema v2 Implementation Tasks

## 1. Planning
- [x] Read schema_v2.sql (36 tables, 12 groups)
- [x] Survey all existing Flutter screens, providers, services
- [x] Survey server/new_server.py endpoints
- [x] Write implementation plan & get approval

## 2. Backend — server/new_server.py
- [x] Add `/v1/save_feedback` endpoint (writes to `feedback` table)
- [x] Add `/v1/session_analytics/{session_id}` GET endpoint (reads `session_analytics`)
- [x] Add `/v1/coaching_report/{session_id}` GET endpoint (reads `coaching_reports`)
- [x] Ensure `session_analytics` row upserted when `/v1/end_session` is called
- [x] Ensure `sentiment_logs` rows written during live session processing

## 3. Flutter — Supabase service layer / API service
- [x] [api_service.dart](file:///d:/FYP/fyp_app/lib/services/api_service.dart) — add `saveFeedback()` method
- [x] [api_service.dart](file:///d:/FYP/fyp_app/lib/services/api_service.dart) — add `getSessionAnalytics()` method
- [x] [api_service.dart](file:///d:/FYP/fyp_app/lib/services/api_service.dart) — add `getCoachingReport()` method

## 4. Flutter — New: `user_settings` Supabase sync
- [x] [settings_provider.dart](file:///d:/FYP/fyp_app/lib/providers/settings_provider.dart) — load/save voice_mode, wingman_mode, consultant_mode, theme, push prefs from `user_settings` table (currently only uses SharedPreferences)

## 5. Flutter — New: `onboarding_progress` tracking
- [x] [auth_service.dart](file:///d:/FYP/fyp_app/lib/services/auth_service.dart) / new helper — upsert `onboarding_progress` rows at correct milestones (profile done, voice enrolled, first wingman, first consultant)

## 6. Flutter — New screens / features (from NEW tables in schema)

### 6a. Feedback (D3) — Thumbs up/down on advice
- [x] Add thumbs up/down buttons to session detail view (session_logs)
- [x] Add star rating to consultant answer bubbles
- [x] Wire to `saveFeedback()` API call

### 6b. Session Analytics (B5) & Coaching Report (G2)
- [x] New screen: `session_analytics_screen.dart` — shows post-session stats
- [x] Shows: total_turns, avg_latency, sentiment, entities extracted, etc.
- [x] Shows coaching_report if available: key_topics, action_items, suggestions
- [x] Add "View Report" button from sessions detail / sessions list

### 6c. Tags (I1-I3) — User-defined labels for sessions
- [x] New `tags_provider.dart` — CRUD for tags (load, create, delete)
- [x] Add tag chip UI to sessions list (session_tags)
- [x] Add "Add Tag" bottom sheet in session detail

### 6d. Notifications (F1) — In-app notification log
- [x] [home_provider.dart](file:///d:/FYP/fyp_app/lib/providers/home_provider.dart) — extend to read `notifications` table (not just highlights)
- [x] Update [_showNotificationsPanel](file:///d:/FYP/fyp_app/lib/screens/home_screen.dart) in [home_screen.dart](file:///d:/FYP/fyp_app/lib/screens/home_screen.dart) to show `notifications` rows
- [x] Subscribe to Realtime `notifications` inserts

### 6e. Session Export (G1) — Export session as PDF/TXT/Markdown
- [x] Add "Export" button in session detail screen
- [x] New `ExportBottomSheet` widget — pick format (pdf/txt/markdown/json/srt)
- [x] POST to `/v1/export_session` and show status

## 7. Flutter — Settings screen enhancements
- [x] Sync theme/voice/notifications prefs to `user_settings` table on change
- [ ] Show subscription plan from `subscriptions` table (currently hardcoded "Free Plan")

## 8. Route registration
- [x] Add `/session-analytics` route in [app_routes.dart](file:///d:/FYP/fyp_app/lib/routes/app_routes.dart) and [main.dart](file:///d:/FYP/fyp_app/lib/main.dart)

## 9. Verification
- [x] Run `flutter analyze` to check for errors
- [ ] Manually test feedback thumbs in session detail
- [ ] Manually test notifications panel showing `notifications` table rows
- [ ] Manually test tag creation and tagging a session
