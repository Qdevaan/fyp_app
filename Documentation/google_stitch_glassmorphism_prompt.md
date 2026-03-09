# Google Stitch — Glassmorphism UI Generation Prompt for Bubbles

> **App Name:** Bubbles  
> **Platform:** Flutter (Android / iOS / Web)  
> **Type:** AI-Powered Voice Assistant & Communication Coach  
> **Font:** Manrope (Google Fonts) — weights 500, 600, 700, 800  
> **Primary Color:** `#13A4EC` (sky blue) — user-customizable seed color  
> **Design System:** Material 3, custom design tokens  
> **Modes:** Full Dark Mode + Full Light Mode  

---

## MASTER PROMPT

Design a complete, production-ready **glassmorphism UI system** for a mobile application called **"Bubbles"** — an AI-powered voice assistant and communication coaching app built in Flutter. The design must be **cohesive across every single screen, popup, dialog, overlay, loader, splash screen, and micro-interaction** in both dark and light modes.

---

## 1. DESIGN PHILOSOPHY & IDENTITY

**Core Visual Identity:**
- The entire UI is built on layered **frosted glass panels** floating over rich, animated gradient backgrounds — like looking through crystal-clear ice into a deep ocean.
- Every surface is a translucent glass pane: cards, inputs, buttons, dialogs, drawers, bottom sheets, overlays, chat bubbles, notification panels — everything.
- No opaque flat cards. No solid Material surfaces. Every container breathes with the background showing through.
- The app should feel like a **living aquarium of light** — luminous, calm, intelligent, and fluid.

**What makes this different from every other app:**
- **Depth through transparency:** 3–4 distinct glass layers at different blur levels (4px, 12px, 24px, 40px) creating real visual depth, not just a single blurred panel.
- **Ambient light bleeding:** The primary accent color (`#13A4EC`) subtly bleeds through glass edges, borders, and shadows — like bioluminescence in deep water.
- **Micro-prismatic borders:** 1px borders use a subtle rainbow gradient that shifts based on the element's position on screen (top = cool blue, middle = neutral white, bottom = warm amber), giving each glass pane a prismatic edge.
- **Living backgrounds:** Every screen has a slowly morphing gradient mesh background (2–3 colored orbs drifting on sine/cosine curves) that breathes underneath the glass layers.
- **No sharp shadows** — only soft, colored glows and inner light effects.

---

## 2. GLASS MATERIAL SPECIFICATIONS

### Dark Mode Glass
| Layer         | Background                          | Blur       | Border                                      | Shadow / Glow                          |
|---------------|-------------------------------------|------------|----------------------------------------------|----------------------------------------|
| **Base**      | `rgba(16, 28, 34, 0.70)`           | 40px       | 1px `rgba(255,255,255,0.06)`                 | None                                   |
| **Surface**   | `rgba(25, 43, 51, 0.55)`           | 24px       | 1px `rgba(255,255,255,0.08)`                 | 0 8px 32px `rgba(0,0,0,0.3)`          |
| **Elevated**  | `rgba(35, 60, 72, 0.50)`           | 16px       | 1px `rgba(255,255,255,0.10)` + prismatic     | 0 4px 20px `rgba(19,164,236,0.08)`    |
| **Floating**  | `rgba(25, 43, 51, 0.65)`           | 12px       | 1px `rgba(255,255,255,0.12)` + prismatic     | 0 12px 40px `rgba(0,0,0,0.4)`         |
| **Scrim**     | `rgba(10, 18, 22, 0.60)`           | 4px        | None                                         | None                                   |

### Light Mode Glass
| Layer         | Background                          | Blur       | Border                                      | Shadow / Glow                          |
|---------------|-------------------------------------|------------|----------------------------------------------|----------------------------------------|
| **Base**      | `rgba(246, 247, 248, 0.65)`        | 40px       | 1px `rgba(255,255,255,0.80)`                 | None                                   |
| **Surface**   | `rgba(255, 255, 255, 0.50)`        | 24px       | 1px `rgba(255,255,255,0.90)`                 | 0 8px 32px `rgba(0,0,0,0.06)`         |
| **Elevated**  | `rgba(255, 255, 255, 0.60)`        | 16px       | 1px `rgba(255,255,255,0.95)` + prismatic     | 0 4px 20px `rgba(19,164,236,0.06)`    |
| **Floating**  | `rgba(255, 255, 255, 0.70)`        | 12px       | 1px `rgba(255,255,255,0.95)` + prismatic     | 0 12px 40px `rgba(0,0,0,0.08)`        |
| **Scrim**     | `rgba(246, 247, 248, 0.50)`        | 4px        | None                                         | None                                   |

---

## 3. COLOR SYSTEM

### Dark Mode Palette
- **Background Mesh Orbs:** `#13A4EC` (primary blue), `#818CF8` (indigo accent), `#0B8BC9` (deep teal) — slowly drifting blobs at 15–25% opacity
- **Text Primary:** `#F8FAFC` (slate-50)
- **Text Secondary:** `#94A3B8` (slate-400)
- **Text Muted:** `#64748B` (slate-500)
- **Success:** `#22C55E` — green glow
- **Error:** `#EF4444` — red glow
- **Warning:** `#F59E0B` — amber glow
- **Accent:** `#818CF8` — indigo highlights

### Light Mode Palette
- **Background Mesh Orbs:** `#6ECBF5` (light primary), `#A5B4FC` (light indigo), `#BAE6FD` (sky) — at 20–30% opacity
- **Text Primary:** `#0F172A` (slate-900)
- **Text Secondary:** `#475569` (slate-600)
- **Text Muted:** `#94A3B8` (slate-400)
- **Success / Error / Warning:** Same hues, slightly desaturated for light backgrounds

### Accent Color Adaptation
The primary color is user-selectable. All glass border glows, button gradients, focus rings, and ambient light bleeds must dynamically adapt to the user's chosen seed color. Design all accent-dependent elements as tintable.

---

## 4. TYPOGRAPHY ON GLASS

- **Font:** Manrope, all weights from 500 (medium) to 800 (extra-bold)
- **Headers:** 24–30px, weight 800, letter-spacing -0.5px, color: text-primary
- **Subtitles:** 16–18px, weight 600, letter-spacing 0px
- **Body:** 14–15px, weight 500, line-height 1.5
- **Captions:** 11–12px, weight 600, uppercase, letter-spacing 1.0–1.2px, color: text-muted
- **Section Labels:** 12px, weight 700, uppercase, letter-spacing 1.5px, color: primary
- All text on glass must have **no text-shadow** in light mode and a **subtle 0 1px 2px rgba(0,0,0,0.3) text shadow** in dark mode for legibility against translucent backgrounds.

---

## 5. SCREEN-BY-SCREEN DESIGN SPECIFICATIONS

---

### 5.1 SPLASH SCREEN

**Layout:**
- Full-screen animated gradient mesh background (3 orbs: primary, indigo, teal — slowly morphing)
- Centered **Bubbles logo** (80px) floating on a circular frosted glass disc (120px diameter, Elevated layer)
- Below logo: a **glassmorphic progress bar** — a rounded pill (200px wide, 6px tall) with a frosted track and a glowing, gradient-filled progress indicator that pulses with subtle light
- Below progress bar: animated status text ("Initializing…", "Connecting…", "Almost there…") using AnimatedSwitcher with fade+slide

**Micro-interactions:**
- Logo disc has a soft breathing glow (scale 1.0 → 1.02 → 1.0 over 2s)
- Progress bar fill has a traveling shimmer highlight (left to right)
- Background orbs drift slowly the entire time

**Permission / Connectivity Dialogs (on this screen):**
- Glassmorphic AlertDialog (Floating layer) with rounded corners (24px)
- Semi-transparent scrim backdrop
- Dialog title in weight 700, body in weight 500
- Two glass buttons: primary (filled glass with primary tint) and secondary (outlined glass)

---

### 5.2 LOGIN SCREEN

**Layout:**
- Animated gradient mesh background (same orb system as splash, but orbs are positioned lower)
- Top section: Bubbles logo (80px) on glass disc
- **Glassmorphic form card** (Surface layer, rounded 24px) containing:
  - Email input (glass input field — see Component Specs §6.2)
  - Password input with visibility toggle
  - "Forgot Password?" text link (primary color)
  - **Primary login button** — glass pill with gradient fill (primary → primaryDark), white text, subtle inner glow
  - Divider: thin glass line with "or" text badge centered on it
  - **Google Sign-In button** — glass outlined pill with Google logo on left
- Bottom: "Don't have an account? **Sign Up**" link

**States:**
- Loading: button text replaced with a small frosted spinner (3 glass dots pulsing sequentially)
- Error: input border transitions to `#EF4444` with a soft red glow, error text appears below in red
- Success: entire form card does a gentle scale-up + fade-out transition to next screen

**Theme Selection Dialog (post-login):**
- Glassmorphic dialog with 3 options: System / Light / Dark
- Each option is a glass tile with an icon and radio indicator
- Selected option has primary-tinted glass background

---

### 5.3 SIGNUP SCREEN

**Layout:**
- Same animated background as Login
- Back arrow button (glass circle, 40px) top-left
- Glassmorphic form card containing:
  - Email input
  - Password input
  - Confirm Password input
  - **Password strength indicator:** a glass progress bar that transitions through colors:
    - Weak: `#EF4444` (red glow)
    - Fair: `#F59E0B` (amber glow)
    - Good: `#6ECBF5` (blue glow)
    - Strong: `#22C55E` (green glow)
  - Strength label text below bar
  - Signup button (glass gradient pill)
  - Divider + Google signup button
- Bottom: "Already have an account? **Log In**" link

---

### 5.4 VERIFY EMAIL SCREEN

**Layout:**
- Gradient mesh background
- Glass card (Surface layer) centered, containing:
  - Large circular glass disc (100px) with mail icon inside (primary colored, 48px)
  - Title: "Check your inbox" — weight 700
  - Body text: instructions to verify — weight 500, text-secondary
  - **Primary button:** "I've Verified It" — glass gradient pill
  - **Secondary button:** "Resend Email" — glass outlined pill
- Decorative: the circular mail icon disc has a slow ring-pulse animation (expanding ring that fades out, like a radar ping)

---

### 5.5 PROFILE COMPLETION SCREEN

**Layout:**
- Gradient mesh background
- Scrollable glass card (Surface layer) containing:
  - **Avatar picker:** Large glass circle (120px) with camera icon overlay. Tappable. Selected image shown with a glass border ring.
  - Name input (glass input)
  - Date of Birth picker — tapping opens a **glassmorphic date picker dialog** (Floating layer) styled to match the glass system, not stock Material
  - Gender dropdown — glass dropdown with frosted option list
  - Country picker — opens a **glassmorphic DraggableScrollableSheet** from bottom:
    - Glass handle bar at top
    - Search input (glass) at top of sheet
    - Scrollable list of countries in glass tiles
    - Selected country has primary tint + check icon
  - Save button (glass gradient pill)

---

### 5.6 HOME SCREEN

**Layout:**
- **Persistent animated gradient mesh background** (the living background is always visible)
- **Glass header bar** (Base layer, no blur — just slight tint) pinned at top:
  - Left: User avatar in glass circle (40px), tappable → navigates to Settings
  - Center: "Bubbles" title text, weight 800
  - Right: Notification bell icon with glass badge (count number) if unread
- **Content area:** swipeable horizontally (left → entities, right → settings)
- Center content: Greeting text ("Good Morning, [Name]") in large type + contextual subtitle
- Below greeting: Quick action glass pills / cards arranged in a grid or vertical list

**Notification Panel (Bell tap):**
- **DraggableScrollableSheet** with glassmorphic styling:
  - Glass drag handle
  - Glass header with "Notifications" title and "Clear All" text button
  - Two sections: **Highlights** (red accent icon) and **Events** (orange accent icon)
  - Each notification is a glass tile (Elevated layer) with:
    - Icon circle (glass, tinted by type)
    - Title + description text
    - Timestamp in caption style
  - Empty state: glass panel with muted icon and "All caught up" text

**Navigation Drawer:**
- Glass panel (Floating layer) sliding from left, full height
- Glass header section with user avatar (large), name, email
- Menu items: each is a glass tile with icon + label. Active item has primary-tinted glass background.
- Connection status dot at bottom (green = connected, amber = connecting, red = disconnected) — the dot has a subtle pulse glow
- Rounded right edge corners (top-right: 24px, bottom-right: 24px)

---

### 5.7 CONSULTANT SCREEN (AI Chat)

**Layout:**
- Gradient mesh background (subtle, muted orbs so text is readable)
- **Glass AppBar** with:
  - Hamburger menu icon (opens chat history drawer)
  - "Consultant" title
  - Voice mode toggle icon (microphone)
- **Chat area** (scrollable):
  - **AI messages (left-aligned):** Glass bubble (Surface layer, rounded 16px, bottom-left sharp corner). Text in text-primary. Streaming responses show a blinking glass cursor.
  - **User messages (right-aligned):** Glass bubble with primary tint (primary at 12% opacity), rounded 16px, bottom-right sharp corner. Text in white (dark mode) or primary-dark (light mode).
  - Welcome state (no messages): centered glass card with random greeting message + suggestion chips (glass pills)
- **Input bar** pinned at bottom:
  - Glass container (Elevated layer) with:
    - Text input (no border, transparent background, placeholder text)
    - Send button: glass circle (40px) with primary gradient fill and arrow icon
    - Mic button: glass circle (40px) with outline style

**Chat History Drawer:**
- Glass panel (Floating layer) from left
- List of past conversations as glass tiles
- Each tile: title (truncated), date, and active indicator (primary glass dot)
- "New Chat" button at top (glass pill with + icon)

**Voice Mode (in-chat):**
- When activated, the input bar transforms:
  - Expands upward into a glass voice panel
  - Shows animated **voice orb** (see Voice Overlay §5.12)
  - States: Listening (pulsing blue orb), Processing (sequential glass dots), Speaking (glass waveform bars)
  - Dismissible by tapping outside or pressing X

**Not Connected Dialog:**
- Glassmorphic AlertDialog: warning icon, message, "Go to Connections" button (glass pill)

---

### 5.8 SESSIONS / HISTORY SCREEN

**Layout:**
- Gradient mesh background
- **Glass header** with back button, "History" title, sort icon
- **Filter chips row:** horizontal scroll of glass pills ("All", "Wingman", "Consultant")
  - Selected chip: filled glass with primary tint
  - Unselected chip: outlined glass
- **Session list:** vertical scroll of glass tiles (Elevated layer), each showing:
  - Session type icon (glass circle, color-coded)
  - Title, preview text
  - Date/time in caption
  - Right chevron

**Sort Bottom Sheet:**
- Glassmorphic ModalBottomSheet with:
  - Glass handle bar
  - "Sort By" title
  - Options as glass tiles: "Newest First", "Oldest First"
  - Selected option has check icon + primary tint

---

### 5.9 NEW SESSION / LIVE WINGMAN SCREEN

**Layout:**
- **Full-screen animated background:** 3 large gradient orbs (primary, indigo, teal) on sine/cosine animation paths — more vivid and dynamic than other screens to convey "live" energy
- **Pre-session state:**
  - Centered glass card (Floating layer) with:
    - Title: "Live Wingman"
    - Subtitle: description text
    - Speaker swap toggle (glass switch)
    - **Start button:** Large glass circle (80px) with gradient fill, microphone icon, pulsing ring animation
- **Active session state:**
  - Glass header strip: session timer, recording indicator (red pulsing dot in glass badge), end button
  - **Transcript area:** glass cards for each transcript segment, fade-slide animated entry
    - User segments: glass bubble with primary tint
    - Other party segments: neutral glass bubble
  - **AI feedback panel:** glass banner at bottom showing real-time suggestions/analysis
  - **Control bar:** glass pills for: Pause, Swap Speaker, End Session

**End Session Confirmation Dialog:**
- Glassmorphic dialog with:
  - Warning icon
  - "End this session?" title
  - "Your transcript will be saved" body text
  - "End" button (glass pill with red tint) and "Continue" button (glass outlined pill)

---

### 5.10 CONNECTIONS SCREEN

**Layout:**
- Gradient mesh background
- **Glass status card** (Elevated layer) at top:
  - Large connection icon (64px) in a glass circle
  - Status badge: glass pill with pulse dot
    - Connected: green dot + "Connected" text
    - Disconnected: red dot + "Disconnected" text
    - Connecting: amber dot + "Connecting…" text (dot pulses)
  - The entire card has a **colored glow border** matching status (green/red/amber)
- **URL input section:**
  - Glass input field with server URL
  - "Save & Test" glass gradient pill button
  - QR scanner icon button (glass circle)
- **QR Scanner Bottom Sheet:**
  - Glassmorphic ModalBottomSheet with camera preview
  - Glass overlay frame (square cutout with glass border) for scan target
  - Glass close button at bottom

---

### 5.11 SETTINGS SCREEN

**Layout:**
- Slides in from left (glass panel transition)
- Gradient mesh background (very subtle, dimmed)
- **Glass header:** back button + "Settings" title + "Done" text button (primary)
- **Scrollable content** with grouped glass sections:

**Account Section:**
- Section label: "ACCOUNT" in caption style (primary colored)
- **Profile tile:** glass tile (Elevated layer) with avatar circle, name, email. Arrow right.
- **Subscription tile:** glass tile with crown icon, "Free Plan" label, "Upgrade" badge (glass pill with primary tint)

**Preferences Section:**
- Section label: "PREFERENCES"
- **Theme Mode tile:** glass tile, trailing shows current mode. Tap → glassmorphic picker dialog (see below)
- **Accent Color tile:** glass tile, trailing shows color circle. Tap → glassmorphic color picker
- **Language tile:** glass tile, trailing shows current language

**Voice Assistant Section:**
- Section label: "VOICE ASSISTANT"
- **Wake Word toggle:** glass tile with switch (glass switch — track is frosted, thumb is solid glass with glow when on)
- **Voice Input tile:** glass tile, trailing shows current source
- **Enrollment tile:** glass tile for voice enrollment

**Dialogs from Settings:**

*Theme Mode Picker:*
- Glassmorphic dialog with 3 options: System, Light, Dark
- Each is a glass tile with icon (auto/sun/moon), label, and radio indicator
- Selected: primary-tinted glass fill + check

*Accent Color Picker:*
- Glassmorphic dialog with a grid of color circles
- Each circle is a glass disc filled with the color
- Selected color has a glowing ring border + check overlay
- "Custom" option at bottom opens a glass color slider

*Contact Sheet:*
- Glassmorphic bottom sheet with contact options
- Each option: glass tile with icon (email, web, bug) + label

*Coming Soon Snackbar:*
- Glassmorphic floating snackbar at bottom
- Glass pill with info icon + "Coming Soon" text
- Auto-dismisses after 3 seconds with fade-out

---

### 5.12 VOICE OVERLAY (Global — "Hey Bubbles")

**Trigger:** activated by wake word "Hey Bubbles" from any screen

**Layout:**
- **Scrim:** full-screen frosted scrim (Scrim layer) — tappable to dismiss
- **Glass panel** slides up from bottom (Floating layer, rounded top 32px):
  - **Status chip** at top: glass pill with state text and colored dot
    - LISTENING: blue dot, "Listening…"
    - THINKING: amber dot, "Processing…"
    - SPEAKING: green dot, "Speaking…"
    - READY: muted dot, "Ready"
  - **Visual indicator** (center, 160px area):
    - *Listening:* Large pulsing orb — glass sphere with primary gradient, concentric ring animations expanding outward (3 rings, staggered timing), inner core glows brighter on louder input
    - *Processing:* 5 glass dots in horizontal line, sequentially scaling up/down in a wave pattern, each dot is a frosted circle with primary tint
    - *Speaking:* 11 vertical glass bars (waveform), each bar height oscillates independently, bars have vertical gradient (primary → indigo), the whole waveform breathes
    - *Idle:* Subtle glass orb with soft breathing glow (very dim primary), waiting state
  - **Text display** below visual:
    - Listening: shows live transcription text (updating in real-time)
    - Processing: "Thinking..." in secondary text color
    - Speaking: shows AI response text
    - Idle: "Say something..." in muted text
  - **Bottom bar:** glass strip with voice mode badge (glass pill) + dismiss button (glass X circle)

---

### 5.13 ABOUT SCREEN

**Layout:**
- **SliverAppBar** with glassmorphic collapsed/expanded states:
  - Expanded: gradient header (primary → indigo) with large Bubbles logo on glass disc + "Bubbles" title + version badge ("v1.0.4" in glass pill)
  - Collapsed: glass nav bar with "About" title
- **Scrollable glass sections:**
  - **Abstract:** Glass card (Surface layer) with project description
  - **Rationale:** Glass card with motivation text
  - **Team:** Glass tiles for each developer:
    - Glass card with avatar placeholder, name (weight 700), registration number (caption), role label (glass badge)
  - **Affiliation:** Glass card with university/institution info + logo
  - **Footer:** "Crafted with ❤️ by Bubbles Team" in centered muted text on a glass strip

---

### 5.14 ENTITY SCREEN (Knowledge Graph)

**Layout:**
- Slides in from right
- Gradient mesh background
- **Glass search bar** at top: glass input with search icon, debounced filtering
- **Entity type filter:** horizontal scroll of glass chips, color-coded:
  - Person: `#818CF8` (indigo)
  - Place: `#22C55E` (green)
  - Organization: `#F59E0B` (amber)
  - Event: `#EF4444` (red)
  - Object: `#13A4EC` (blue)
  - Concept: `#A855F7` (purple)
- Each chip: glass pill with colored left dot + label. Selected = filled glass with color tint.
- **Entity list:** glass tiles (Elevated layer) for each entity:
  - Left: glass circle (40px) with type-specific icon, tinted by type color
  - Title: entity name
  - Subtitle: type label in caption
  - Expandable: tapping reveals attributes and relations in a glass expansion panel
  - Delete: swipe-to-delete with red glass background, or long-press → glass confirmation dialog

**Delete Confirmation Dialog:**
- Glassmorphic dialog: warning icon, entity name, "This cannot be undone" text
- "Delete" (glass pill, red tint) and "Cancel" (glass outlined pill)

---

## 6. COMPONENT SPECIFICATIONS

### 6.1 Glass Button (AppButton)

**Filled Variant:**
- Background: linear gradient (primary → primaryDark) at 85% opacity over frosted glass
- Border: 1px prismatic border
- Border radius: 12px (md) for standard, 9999px (full) for pills
- Text: white, Manrope 700, 15px
- Shadow: 0 4px 16px primary at 20% opacity
- Hover/Press: glass brightens +10% opacity, glow intensifies
- Loading state: text replaced with 3 frosted dots animating in sequence
- Icon variant: icon on trailing side, separated by 8px

**Outlined Variant:**
- Background: transparent with frosted overlay at 5% opacity
- Border: 1px primary color at 40% opacity
- Text: primary color
- Hover/Press: background fills to primary at 10% opacity

**Disabled State (both):**
- Opacity drops to 40%
- No glow, no gradient animation
- Cursor: not-allowed

### 6.2 Glass Input (AppInput)

- Container: glass (Surface layer for dark, lighter glass for light mode)
- Border: 1px `rgba(255,255,255,0.10)` (dark) or `rgba(0,0,0,0.08)` (light)
- Border radius: 12px
- Focus state: border transitions to primary color at 60% opacity + soft primary glow (0 0 8px primary at 15%)
- Error state: border transitions to error red + soft red glow
- Prefix icon: 20px, text-secondary color
- Suffix (visibility toggle): glass icon button, 20px
- Label: positioned above, 12px, weight 600, text-secondary
- Placeholder text: text-muted color
- Filled text: text-primary color

### 6.3 Glass Card (AppCard)

- Background: Surface layer glass
- Border radius: 16px (lg)
- Entry animation: fade (0→1) + slide-up (20px→0) over 400ms with delay stagger
- Tap: subtle scale (1.0 → 0.98 → 1.0) over 150ms
- Content padding: 18px (md)

### 6.4 Glass Chat Bubble

**AI Bubble (left-aligned):**
- Background: Surface layer glass
- Border radius: 16px top-left, 16px top-right, 16px bottom-right, 4px bottom-left
- Text: text-primary, body size
- Streaming: blinking glass cursor (vertical bar, 2px wide, primary color, blinking 500ms)

**User Bubble (right-aligned):**
- Background: primary color at 12% opacity, frosted
- Border: 1px primary at 15% opacity
- Border radius: 16px top-left, 16px top-right, 4px bottom-right, 16px bottom-left
- Text: white (dark) or slate-900 (light), body size

### 6.5 Glass Navigation Drawer

- Width: 280px
- Background: Floating layer glass
- Border radius: 0 top-right 24px bottom-right 24px 0 0
- Header: 180px tall, glass divider at bottom
  - Avatar: 64px glass circle with image
  - Name: subtitle weight
  - Email: caption style, text-muted
- Menu items: 52px tall glass tiles
  - Active: primary-tinted glass fill + primary text
  - Inactive: transparent + text-secondary
  - Icon: 24px, matching text color
- Connection indicator: 10px glass circle at bottom with status color + pulse

### 6.6 Glass Chips / Pills

- Height: 34px
- Border radius: 9999px (full)
- Padding: 6px horizontal, 12px with text
- Selected: filled glass with primary tint (primary at 15%), primary text, primary border at 30%
- Unselected: outlined glass, transparent fill, text-secondary, border at 10%
- Transition: color + background animates over 200ms

### 6.7 Glass Switch / Toggle

- Track: 48px x 28px, glass (Surface layer), rounded full
- Track ON: primary at 30% opacity glass
- Track OFF: neutral glass (white at 8% dark, black at 5% light)
- Thumb: 22px circle, solid glass with inner highlight
- Thumb ON: white with primary glow
- Thumb OFF: text-muted with no glow
- Transition: thumb slides + color transitions over 200ms

### 6.8 Glass Snackbar / Toast

- Floating at bottom, 16px margin from edges
- Background: Floating layer glass
- Border radius: 12px
- Content: icon (20px, colored by type) + message text
- Types:
  - Info: primary icon
  - Success: green icon + subtle green border glow
  - Error: red icon + subtle red border glow
  - Warning: amber icon + subtle amber border glow
- Auto-dismiss: 3s with fade-out (300ms)
- Swipe to dismiss

### 6.9 Glass Dialog / AlertDialog

- Scrim: Scrim layer glass (full screen)
- Dialog: Floating layer glass
- Border radius: 24px
- Width: min 280px, max 400px
- Padding: 24px
- Title: 18px, weight 700, text-primary
- Body: 14px, weight 500, text-secondary
- Actions row: right-aligned, 12px gap between buttons
- Entry: scale (0.9→1.0) + fade over 300ms
- Exit: scale (1.0→0.95) + fade over 200ms

### 6.10 Glass Bottom Sheet / Modal

- Scrim: Scrim layer glass
- Sheet: Floating layer glass, rounded top 24px
- Drag handle: 36px x 4px, glass pill, centered at top with 12px top padding
- Content area: scrollable with glass section dividers
- Entry: slide-up from bottom, 350ms, ease-out
- Exit: slide-down, 250ms, ease-in

### 6.11 Glass Loading Indicators

**Progress Bar:**
- Track: glass pill (200px x 6px), Surface layer
- Fill: gradient (primary → primaryLight), animated left-to-right
- Shimmer: traveling highlight (white at 30%) moves across fill

**Spinner (3-dot):**
- 3 glass circles (8px each), spaced 6px apart
- Sequential pulse: each dot scales 1.0→1.4→1.0 with 150ms stagger
- Color: primary

**Full-screen Loader:**
- Scrim layer glass covering the entire screen
- Centered: large glass orb (60px) with inner primary gradient, pulsing (scale 1.0→1.1→1.0 over 1.5s)
- Below orb: loading text in text-secondary

**Skeleton / Shimmer:**
- For loading content areas, show glass rectangles (Surface layer) with a traveling shimmer highlight
- Matches the shape of the content that will load (text lines, avatar circles, card shapes)

---

## 7. ANIMATION & TRANSITION SYSTEM

### Page Transitions
- **Default:** Fade + slight scale (0.97→1.0), 350ms, ease-out curve
- **Settings (from left):** Glass panel slides from left, 350ms, ease-in-out
- **Entity (from right):** Glass panel slides from right, 350ms, ease-in-out
- **Dialogs:** Scale (0.9→1.0) + fade, 300ms
- **Bottom sheets:** Slide-up, 350ms, decelerate curve
- All transitions include the gradient mesh background remaining static while glass panels move — creating a parallax-like depth effect.

### Micro-Animations
- **Button press:** Scale 1.0 → 0.97 → 1.0 (150ms)
- **Card entry:** Fade + slide-up (20px), staggered by 80ms per card
- **Chip selection:** Background color fill transition (200ms)
- **Input focus:** Border glow fade-in (200ms)
- **Toggle switch:** Thumb slide + track color (200ms)
- **Notification badge:** Pop-in with overshoot spring (300ms)
- **Voice orb:** Continuous animation (pulsing, ring expansion)
- **Waveform bars:** Independent height oscillation on random curves
- **Background orbs:** Perpetual sine/cosine drift (8s loop)

### Easing Curves
- Entry: `Curves.easeOut`
- Exit: `Curves.easeIn`
- Interactive: `Curves.easeInOut`
- Spring/Bounce: `Curves.elasticOut` (badges, notifications only)
- Orbs: Custom sine-based easing

---

## 8. DARK MODE vs. LIGHT MODE — KEY DIFFERENCES

| Element               | Dark Mode                                         | Light Mode                                        |
|-----------------------|--------------------------------------------------|--------------------------------------------------|
| Background            | Deep teal-black (`#101C22`) mesh                 | Soft gray-white (`#F6F7F8`) mesh                 |
| Glass tint            | White at 6–12% borders                           | White at 80–95% borders                          |
| Glass fill            | Dark translucent fills                           | White translucent fills                          |
| Text shadow           | Subtle dark shadow for legibility                | None                                             |
| Orb colors            | Vivid, 15–25% opacity                            | Pastel, 20–30% opacity                           |
| Glow effects          | Prominent, colored                               | Subtle, barely visible                           |
| Border brightness     | Low-contrast, barely visible                     | High-contrast, bright white                      |
| Button gradients      | Richer, deeper colors                            | Lighter, more pastel                             |
| Shadows               | Colored (primary/black), strong                  | Gray, very soft                                  |
| Prismatic borders     | Visible, adds shimmer                            | Very subtle, almost invisible                    |

---

## 9. ICONOGRAPHY

- Style: **Outlined** icons, 1.5px stroke weight (matching Manrope's clean geometry)
- Sizes: 20px (inline), 24px (navigation/action), 32px (feature), 48px (hero)
- Color: inherits from text color or accent color depending on context
- **Glass icon buttons:** 40px circles with glass background (Surface layer), icon centered
- On active/selected states: icon color transitions to primary

---

## 10. ACCESSIBILITY & USABILITY

- All glass surfaces must maintain **WCAG AA contrast ratio** (4.5:1 for body text, 3:1 for large text) against their effective blurred backgrounds
- In dark mode, increase text opacity if needed to maintain contrast
- In light mode, reduce glass transparency if needed to maintain contrast
- All interactive elements: minimum 44px touch target
- Focus indicators: 2px primary ring with 4px offset (glass glow style)
- Reduced motion preference: disable background orbs, simplify transitions to fades only, remove pulse animations
- Screen reader: all glass decorative elements are aria-hidden, semantic labels on all buttons and inputs

---

## 11. EMPTY STATES & EDGE CASES

**No Data / Empty Lists:**
- Centered glass card (Surface layer) with:
  - Oversized muted icon (64px, text-muted at 30%)
  - Title: "No [items] yet" — weight 600, text-secondary
  - Subtitle: helpful action text — weight 500, text-muted
  - Optional CTA button (glass outlined pill)

**Error States:**
- Full-screen: glass card with error icon (red-tinted glass circle), error title, retry button
- Inline: red-bordered glass input with error text below
- Toast: glass snackbar with red accent

**Offline / No Connection:**
- Glass banner at top of screen (Elevated layer) with warning icon + "No connection" text, amber border glow
- Persistent until connection restored, then fades out

---

## 12. SUMMARY — THE BUBBLES GLASS IDENTITY

The Bubbles app must feel like interacting with an **intelligent aquatic organism** — every surface is translucent like water, every interaction creates ripples of light, and the ambient background is a living, breathing ocean of soft gradients. The glassmorphism is not decoration — it IS the interface.

**Key differentiators from any other app:**
1. **Multi-layer glass depth** — not just one blur level, but a full depth stack (4 layers)
2. **Prismatic micro-borders** — position-aware rainbow shimmer on edges
3. **Living mesh backgrounds** — always moving, never static
4. **Bioluminescent accent bleeding** — the brand color glows through the glass
5. **Voice-first visual language** — orbs, pulses, and waveforms are native UI elements, not afterthoughts
6. **Seamless dark/light duality** — the same glass system works in both modes naturally, like ice in different lighting

Every pixel must serve the illusion that you are interacting with translucent surfaces floating in luminous water.

---

*End of Stitch Prompt — Bubbles Glassmorphism UI System v1.0*
