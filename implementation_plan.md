# Schema v2 Alignment — Implementation Plan

Bring the Bubbles app fully in line with **schema_v2.sql** by implementing the tables tagged **NEW** (v2 tables that must be implemented now). Tables tagged **FUTURE** (subscriptions, calendar, teams, api_keys) are scaffolded in the database but are not implemented in this sprint.

## Groups being implemented
| Group | Tables | Status |
|-------|--------|--------|
| A – Core User | `profiles` ✓, `user_settings` (Supabase sync), `onboarding_progress` | partial → full |
| B – Sessions | `sessions` ✓, `session_logs` ✓, `consultant_logs` ✓, `audio_sessions` ✓, **`session_analytics`** | NEW |
| D – Highlights/Events | `highlights` ✓, `events` ✓, **`feedback`**, **`sentiment_logs`** | NEW |
| F – Notifications | **`notifications`** | NEW |
| G – Exports | **`session_exports`**, **`coaching_reports`** | NEW |
| I – Tagging | **`tags`**, **`session_tags`**, **`entity_tags`** | NEW |

---

## Proposed Changes

### Backend — [server/new_server.py](file:///d:/FYP/fyp_app/server/new_server.py)

#### [MODIFY] [new_server.py](file:///d:/FYP/fyp_app/server/new_server.py)
1. **`/v1/end_session`** — After marking session complete, upsert a `session_analytics` row with computed values (turn counts, avg latency, sentiment averages, entity/memory/event/highlight counts from their respective tables).
2. **`/v1/save_feedback`** (NEW) — Accept `{user_id, session_log_id?, consultant_log_id?, feedback_type, value, comment}` and insert into `feedback`.
3. **`/v1/session_analytics/<session_id>`** (NEW GET) — Return the `session_analytics` row for a session (for the detail screen). Returns 404 if not computed yet.
4. **`/v1/coaching_report/<session_id>`** (NEW GET) — Return the `coaching_reports` row. Returns 404 if not generated yet; optionally triggers generation on first request.

---

### Flutter — API layer

#### [MODIFY] [api_service.dart](file:///d:/FYP/fyp_app/lib/services/api_service.dart)
- Add `saveFeedback({required String userId, String? sessionLogId, String? consultantLogId, required String feedbackType, required int value, String? comment})` — POST to `/v1/save_feedback`.
- Add `getSessionAnalytics(String sessionId)` — GET `/v1/session_analytics/<id>`.
- Add `getCoachingReport(String sessionId)` — GET `/v1/coaching_report/<id>`.

---

### Flutter — Settings / Onboarding sync

#### [MODIFY] [settings_provider.dart](file:///d:/FYP/fyp_app/lib/providers/settings_provider.dart)
- On load, read `user_settings` from Supabase after SharedPreferences.
- On every setter ([setDefaultLiveTone](file:///d:/FYP/fyp_app/lib/providers/settings_provider.dart#38-44), etc.) also upsert the matching column in `user_settings`.
- Map app tones to `wingman_mode`/`consultant_mode` columns.

#### [MODIFY] [auth_service.dart](file:///d:/FYP/fyp_app/lib/services/auth_service.dart)
- After profile save → upsert `onboarding_progress.profile_done = true`.
- After first voice enrollment → upsert `onboarding_progress.voice_enrolled = true`.
- After first live session end → upsert `onboarding_progress.first_wingman = true`.
- After first consultant question → upsert `onboarding_progress.first_consultant = true`.

---

### Flutter — Notifications panel

#### [MODIFY] [home_provider.dart](file:///d:/FYP/fyp_app/lib/providers/home_provider.dart)
- Add `_notifications` list; load from `notifications` table (ordered by `created_at desc`, limit 20, `is_read = false`).
- Subscribe to Realtime inserts on `notifications` table (filtered by `user_id`).
- Expose `markNotificationRead(String id)` — update `is_read = true`.

#### [MODIFY] [home_screen.dart](file:///d:/FYP/fyp_app/lib/screens/home_screen.dart)
- Show `notifications` items in the existing [_showNotificationsPanel](file:///d:/FYP/fyp_app/lib/screens/home_screen.dart#43-202) alongside highlights/events, using a different icon/colour per `notif_type`.
- Call `markNotificationRead` when user taps a notification item.

---

### Flutter — Feedback (Thumbs / Stars)

#### [MODIFY] [sessions_screen.dart](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart)
- In [GenericSessionDetail](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart#760-775) for **live sessions**: add 👍/👎 icon buttons next to each LLM advice bubble. On tap, call `api.saveFeedback(feedbackType: 'thumbs', value: 1/-1, sessionLogId: log['id'])`.
- In [GenericSessionDetail](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart#760-775) for **consultant sessions**: add ⭐ rating row (1–5 stars) below each AI answer. On tap, call `api.saveFeedback(feedbackType: 'star', value: rating, consultantLogId: log['id'])`.
- Show a small confirmation snackbar on submission.

---

### Flutter — Session Analytics & Coaching Report

#### [NEW] [session_analytics_screen.dart](file:///d:/FYP/fyp_app/lib/screens/session_analytics_screen.dart)
- Full-screen detail showing `session_analytics` + `coaching_reports` for a given `session_id`.
- Sections: **At a Glance** (turns, duration, latency), **Sentiment** (avg score + dominant), **Memory & Entities** (counts), **Coaching Report** (key_topics chips, action_items list, suggestions, strengths, tone_summary).
- If analytics not available, shows a loading state and polls `/v1/session_analytics/<id>`.

#### [MODIFY] [sessions_screen.dart](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart)
- Add "📊 View Report" button in [GenericSessionDetail](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart#760-775) header (live sessions only). Navigation to `SessionAnalyticsScreen`.

#### [MODIFY] [app_routes.dart](file:///d:/FYP/fyp_app/lib/routes/app_routes.dart)
- Add `static const sessionAnalytics = '/session-analytics';`

#### [MODIFY] [main.dart](file:///d:/FYP/fyp_app/lib/main.dart)
- Register `/session-analytics` route mapping to `SessionAnalyticsScreen`.

---

### Flutter — Tags

#### [NEW] [tags_provider.dart](file:///d:/FYP/fyp_app/lib/providers/tags_provider.dart)
- `loadTags()` — fetch all tags for current user from `tags` table.
- `createTag(String name, String color)` — insert into `tags`.
- `deleteTag(String tagId)` — delete from `tags` (cascade removes `session_tags` + `entity_tags`).
- `tagSession(String sessionId, String tagId)` — insert into `session_tags`.
- `untagSession(String sessionId, String tagId)` — delete from `session_tags`.
- `getTagsForSession(String sessionId)` — query `session_tags` join `tags`.

#### [MODIFY] [sessions_screen.dart](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart)
- In each session list card, show tag chips (coloured pills) beneath the title if the session has tags.
- In [GenericSessionDetail](file:///d:/FYP/fyp_app/lib/screens/sessions_screen.dart#760-775), add "+ Add Tag" button that opens a `TagsBottomSheet`.

#### [NEW] `lib/widgets/tags_bottom_sheet.dart`
- Lists existing tags with checkboxes (checked = already tagged on this session).
- "＋ New tag" field at bottom.
- On confirm: calls `tagsProvider.tagSession / untagSession`.

#### [MODIFY] [main.dart](file:///d:/FYP/fyp_app/lib/main.dart)
- Register `TagsProvider` in `MultiProvider`.

---

## Verification Plan

### Automated / Static
```
# Run from d:\FYP\fyp_app
flutter analyze
```
Expected: no new errors introduced.

### Manual tests (run the app on a device/emulator)

1. **Feedback — Live session**
   - Start & end a live session.
   - Open the session from History → tap 👍 on any Wingman advice bubble.
   - Expected: thumbs icon filled, snackbar "Feedback saved", row appears in Supabase `feedback` table.

2. **Feedback — Consultant**
   - Ask a question in Consultant mode.
   - Tap a star rating (e.g. 4 stars) on the AI reply.
   - Expected: stars highlighted, row in `feedback` with `feedback_type='star', value=4`.

3. **Session Analytics**
   - After a live session ends, go to History → that session → tap "View Report".
   - Expected: `SessionAnalyticsScreen` loads with analytics data; if coaching report exists it shows key topics and action items.

4. **Notifications**
   - Ask consultant a question or run a session (server generates highlights).
   - Go to HomeScreen bell icon → tap.
   - Expected: `notifications` table rows visible alongside highlights (if any).

5. **Tags**
   - Open History, tap a session → tap "+ Add Tag" → create a tag "Test" with a colour → confirm.
   - Expected: tag chip appears on the card in the sessions list; row in `session_tags`.
   - Delete the tag from TagsBottomSheet — expected: chip disappears.

6. **Settings sync**
   - Change Live Tone in Settings → restart app → re-open Settings.
   - Expected: tone persists (Supabase `user_settings.wingman_mode` updated).
