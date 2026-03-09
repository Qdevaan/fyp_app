# Bubbles UI Implementation

## Overview

Complete UI overhaul of the Bubbles Flutter app based on 40 glassmorphism HTML stitch designs.  
All screens were built from scratch and are organized under `lib/screens/`, with shared components in `lib/widgets/` and design tokens in `lib/theme/`.

---

## Design System

### Color Tokens (`lib/theme/design_tokens.dart`)

| Token | Value | Usage |
|---|---|---|
| `BubblesColors.primary` | `#13BDEC` | Buttons, accents, active states |
| `BubblesColors.bgDark` | `#101E22` | Dark background |
| `BubblesColors.bgLight` | `#F6F8F8` | Light background |
| `BubblesColors.glassDark` | `rgba(255,255,255,0.03)` | Glass cards (dark) |
| `BubblesColors.glassBorderDark` | `rgba(255,255,255,0.08)` | Card borders (dark) |
| `BubblesColors.glassPrimary` | `rgba(19,189,236,0.15)` | Primary-tinted glass |
| `BubblesColors.glassPrimaryBorder` | `rgba(19,189,236,0.30)` | Primary-tinted border |
| `BubblesColors.glassHeaderDark` | `rgba(16,30,34,0.70)` | App bar / header glass |
| `BubblesColors.textPrimaryDark` | `#E8F4F8` | Primary text (dark mode) |
| `BubblesColors.textSecondaryDark` | `rgba(232,244,248,0.6)` | Secondary text (dark) |
| `BubblesColors.textMutedDark` | `rgba(232,244,248,0.35)` | Muted / label text |

### Typography
- **Font**: Manrope (via `google_fonts`)  
- **Weights used**: 400 body, 600 semi-bold, 700 bold, 800 extra-bold

### Glassmorphism Pattern
All cards use `BackdropFilter` + `ImageFilter.blur` (sigma 12) with low-opacity background fill and a `Border` using `glassBorderDark`.  
Helper widget: `GlassBox` in `lib/widgets/shared_widgets.dart`.

---

## Screens

### Auth Flow
| Screen | File | Route |
|---|---|---|
| Splash Screen | `lib/screens/splash_screen.dart` | Initial route |
| Login | `lib/screens/login_screen.dart` | `/login` |
| Sign Up | `lib/screens/signup_screen.dart` | `/signup` |
| Verify Email | `lib/screens/verify_email_screen.dart` | `/verify-email` |
| Complete Profile | `lib/screens/profile_completion_screen.dart` | `/profile-completion` |

**Auth Flow**: `SplashScreen` → checks Supabase session → `HomeScreen` (if logged in) or `LoginScreen`.

### Main Navigation
| Screen | File | Route | Nav Index |
|---|---|---|---|
| Home Dashboard | `lib/screens/home_screen.dart` | `/home` | 0 |
| AI Consultant (Chat) | `lib/screens/consultant_screen.dart` | `/consultant` | 1 |
| Sessions Overview | `lib/screens/sessions_screen.dart` | `/sessions` | 2 |
| Connections | `lib/screens/connections_screen.dart` | `/connections` | 3 |
| Settings | `lib/screens/settings_screen.dart` | `/settings` | 4 |

Navigation is handled by `BubblesBottomNav` (5 tabs) in `lib/widgets/shared_widgets.dart`.

### Feature Screens
| Screen | File | Route | Description |
|---|---|---|---|
| Session History | `lib/screens/session_history_screen.dart` | `/session-history` | Filterable list of all past sessions |
| Live Wingman | `lib/screens/new_session_screen.dart` | `/new-session` | Pre-session mode card picker + active session with live transcript and AI feedback |
| Knowledge Graph | `lib/screens/entity_screen.dart` | `/entities` | Searchable entity list (Person / Place / Org / Event / Object / Concept) |
| About | `lib/screens/about_screen.dart` | `/about` | Team cards, mission statement, version info |
| Subscription | `lib/screens/subscription_screen.dart` | `/subscription` | Free / Pro / Enterprise plan cards |
| Profile | `lib/screens/expanded_user_profile_screen.dart` | `/profile` | Editable user profile with stats and badges |
| Search & Discovery | `lib/screens/search_discovery_screen.dart` | `/search` | Category browse and keyword search |
| AI Insights Dashboard | `lib/screens/ai_insights_dashboard_screen.dart` | `/ai-insights` | Monthly stats, AI observations, skill bars, heatmap |

---

## Widgets

### Core Components (`lib/widgets/`)

#### `shared_widgets.dart`
| Widget | Description |
|---|---|
| `GlassBox` | Core glass card container. Params: `borderRadius`, `padding`, `bgColor`, `borderColor`, `margin`, `child`. |
| `GlassPrimaryBox` | Primary-tinted glass card (uses `glassPrimary` + `glassPrimaryBorder`). |
| `BgMesh` | Full-screen gradient background with two radial orb blobs — used on all primary screens. |
| `GlassAppBar` | `PreferredSizeWidget` app bar with blurred glass background and primary bottom border. |
| `BubblesBottomNav` | Custom 5-tab bottom navigation (Home, Consult, Sessions, Connect, Settings). Glowing active indicator. |
| `StatusBadge` | Connected / Connecting / Disconnected pill badge with animated pulse for connecting state. |

#### `app_button.dart`
| Widget | Description |
|---|---|
| `AppButton` | Full-width button with four variants: `filled` (gradient), `outlined` (primary border), `ghost`, `danger` (red). Supports `loading` state and `icon`. |
| `CircleIconBtn` | Round icon button (glass or primary). |

#### `app_input.dart`
| Widget | Description |
|---|---|
| `AppInput` | Styled text field with uppercase tracking label, focus glow animation (primary), error glow (red), password visibility toggle, prefix/suffix icon support. |

#### `voice_overlay.dart`
| Widget | Description |
|---|---|
| `VoiceOverlay` | Full-screen frosted scrim overlay shown during voice interaction. Displays animated orb (listening/thinking/speaking states), live transcript, and AI response panel. Triggered by `VoiceAssistantService.isOverlayVisible`. |

#### `navigation_drawer.dart`
| Widget | Description |
|---|---|
| `BubblesNavigationDrawer` | Glass side-drawer with user header (avatar, name, email), full navigation menu, and version footer. |

#### `auth_guard.dart` (existing, kept)
Protects routes by checking Supabase auth session. Redirects unauthenticated users to `/login`, or authenticated users away from auth screens.

---

## Navigation Flow

```
SplashScreen
├── [session exists] → HomeScreen
└── [no session]    → LoginScreen
                         ├── → SignupScreen → VerifyEmailScreen → ProfileCompletionScreen → HomeScreen
                         └── → HomeScreen (on login)

HomeScreen (tabs)
├── Tab 0: HomeScreen
├── Tab 1: ConsultantScreen
├── Tab 2: SessionsScreen
│              └── SessionHistoryScreen (history tab)
├── Tab 3: ConnectionsScreen
└── Tab 4: SettingsScreen
              ├── → AboutScreen
              └── → SubscriptionScreen

HomeScreen (quick actions)
├── → NewSessionScreen (Live Wingman)
├── → ConsultantScreen
└── → SessionHistoryScreen

NavigationDrawer (any screen)
├── → AiInsightsDashboardScreen
├── → EntityScreen (Knowledge Graph)
├── → SearchDiscoveryScreen
└── → ExpandedUserProfileScreen
```

---

## State Management

| Provider | File | Scope |
|---|---|---|
| `ThemeProvider` | `lib/providers/theme_provider.dart` | Dark/light theme toggle. Provides `lightTheme` / `darkTheme` (ThemeData). |
| `ConsultantProvider` | `lib/providers/consultant_provider.dart` | Chat message list for AI Consultant screen. |
| `SessionProvider` | `lib/providers/session_provider.dart` | Live Wingman session state. |
| `HomeProvider` | `lib/providers/home_provider.dart` | Home dashboard data. |
| `VoiceAssistantService` | `lib/services/voice_assistant_service.dart` | Wake word, listening state, overlay visibility. |
| `ConnectionService` | `lib/services/connection_service.dart` | WebSocket connection to Python server. |
| `LiveKitService` | `lib/services/livekit_service.dart` | LiveKit room audio/video. |
| `DeepgramService` | `lib/services/deepgram_service.dart` | Speech-to-text streaming. |
| `WakeWordService` | `lib/services/wake_word_service.dart` | Porcupine wake word detection. |

---

## Backend

- **Supabase** (`supabase_flutter ^2.8.1`): Authentication (email/password), user metadata (full_name, avatar_url, bio), database.
- **Python Server** (`server/new_server.py`): WebSocket backend for AI logic.
- **LiveKit**: Real-time audio rooms for Live Wingman sessions.
- **Deepgram**: Streaming transcription for voice sessions.
- **Porcupine**: On-device wake word ("Hey Bubbles").

---

## Key Packages

```yaml
flutter_animate: ^4.5.0       # UI animations
google_fonts: ^6.2.1          # Manrope font
provider: ^6.1.5              # State management
supabase_flutter: ^2.8.1      # Auth + DB
livekit_client: ^2.4.0        # Real-time audio
record: ^5.0.5                # Microphone recording
speech_to_text: ^7.0.0        # On-device STT
porcupine_flutter: ^3.0.5     # Wake word
connectivity_plus: ^6.1.0     # Network status
flutter_tts: ^4.2.0           # Text-to-speech
mobile_scanner: ^6.0.10       # QR code scanning
image_picker: ^1.1.2          # Avatar selection
```

---

## Files Created (New UI)

### Theme
- `lib/theme/design_tokens.dart` — Color constants + ThemeData (BubblesColors, BubblesTheme)

### Widgets
- `lib/widgets/shared_widgets.dart` — GlassBox, GlassPrimaryBox, BgMesh, GlassAppBar, BubblesBottomNav, StatusBadge
- `lib/widgets/app_button.dart` — AppButton, CircleIconBtn
- `lib/widgets/app_input.dart` — AppInput
- `lib/widgets/voice_overlay.dart` — VoiceOverlay (fullscreen voice UI)
- `lib/widgets/navigation_drawer.dart` — BubblesNavigationDrawer

### Screens (13 total)
- `lib/screens/splash_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/signup_screen.dart`
- `lib/screens/verify_email_screen.dart`
- `lib/screens/profile_completion_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/consultant_screen.dart`
- `lib/screens/session_history_screen.dart`
- `lib/screens/new_session_screen.dart`
- `lib/screens/connections_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/entity_screen.dart`
- `lib/screens/about_screen.dart`
- `lib/screens/subscription_screen.dart`
- `lib/screens/expanded_user_profile_screen.dart`
- `lib/screens/search_discovery_screen.dart`
- `lib/screens/sessions_screen.dart`
- `lib/screens/ai_insights_dashboard_screen.dart`

### Updated Files
- `lib/main.dart` — Added all screen imports, fixed VoiceOverlayWrapper, added routes
- `lib/routes/app_routes.dart` — Added route constants for all new screens

### Kept Unchanged
- `lib/providers/` — All providers intact
- `lib/services/` — All services intact
- `lib/widgets/auth_guard.dart` — Kept as-is

---

## Stitch Source Files

Each screen was adapted from the corresponding HTML file in `stitch/<screen_name>/code.html`.
The 40 stitch folders covered: about_bubbles, about_bubbles_redesign, advanced_filter_overlay, ai_chat_redesign, ai_insights_dashboard, ai_thinking_state, coming_soon_screen, complete_profile, connections, consultant_ai_chat, end_session_dialog, entity_detail_view, entity_knowledge_graph, expanded_user_profile, history_empty_state, home_screen, home_screen_redesign, live_wingman_session, loading_overlay, login_screen, login_screen_redesign, navigation_drawer, notifications, offline_state, permission_request, pop_ups_dialogs, privacy_data_management, qr_scanner_sheet, reconnecting_state, search_discovery, session_history, settings_screen, subscription_screen, voice_overlay, and others.
