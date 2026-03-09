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

---

---

# APPENDIX A — STITCH HTML IMPLEMENTATION REFERENCE

> **Source:** All 40 `code.html` files in `stitch/` — exact CSS classes, values, and structure as built.
> **Purpose:** Ground-truth reference for Flutter implementation. Values here take precedence over design intent above where they differ.

---

## A.1 Universal Design Tokens (Tailwind config, repeated across all 40 files)

```js
tailwind.config = {
  darkMode: "class",       // <html class="dark"> on every screen
  theme: {
    extend: {
      colors: {
        "primary":           "#13bdec",    // cyan-blue brand color
        "background-light":  "#f6f8f8",
        "background-dark":   "#101e22",    // deep teal-black (some screens: #0a1215)
      },
      fontFamily: { "display": ["Manrope", "sans-serif"] },
      borderRadius: {
        DEFAULT: "0.5rem",
        lg:      "1rem",
        xl:      "1.5rem",
        full:    "9999px",
      },
    },
  },
}
```

**Common head imports (all screens):**
```html
<!-- Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;300;400;500;600;700;800&display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<!-- Tailwind CDN -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
```

**Body min-height (all screens):**
```css
body { min-height: max(884px, 100dvh); }
```

---

## A.2 Canonical Glass CSS Classes (exact definitions)

These class definitions appear across all 40 screens — values may vary slightly per file; canonical/most-common values shown.

```css
/* ── Core glass panel (neutral) ── */
.glass / .glass-panel / .glass-card {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.08);   /* some files: 0.1 */
}

/* ── Primary-tinted glass ── */
.glass-primary {
  background: rgba(19, 189, 236, 0.10);          /* range: 0.10–0.15 */
  backdrop-filter: blur(12px);
  border: 1px solid rgba(19, 189, 236, 0.30);
}

/* ── Header / nav glass ── */
.glass-header / .glass-nav {
  background: rgba(16, 30, 34, 0.70);
  backdrop-filter: blur(12px);                   /* some: blur(20px) */
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

/* ── Dark about-page glass ── */
.glass-dark {
  background: rgba(0, 0, 0, 0.30);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.05);
}

/* ── Mesh gradient background ── */
.mesh-gradient / .gradient-mesh / .mesh-bg / .shimmer-bg {
  background-color: #101e22;
  background-image:
    radial-gradient(at 0%   0%,   rgba(19, 189, 236, 0.15) 0px, transparent 50%),
    radial-gradient(at 100% 0%,   rgba(19, 189, 236, 0.10) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(19, 189, 236, 0.15) 0px, transparent 50%),
    radial-gradient(at 0%   100%, rgba(19, 189, 236, 0.10) 0px, transparent 50%);
}

/* ── Prismatic border (signup, end_session, qr_scanner, about_bubbles_redesign) ── */
.prismatic-border::before / ::after {
  content: "";
  position: absolute; inset: -1px; padding: 1px;
  border-radius: inherit;
  background: linear-gradient(45deg,
    rgba(19, 189, 236, 0.5),
    rgba(255, 255, 255, 0.2),
    rgba(19, 189, 236, 0.3),
    transparent
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* ── Full-screen scrim overlays ── */
.frosted-scrim / .glass-scrim {
  background: rgba(16, 30, 34, 0.60);            /* range: 0.60–0.70 */
  backdrop-filter: blur(8px);                    /* range: 8px–20px */
}
.scrim-overlay {                                  /* voice_overlay */
  background: radial-gradient(circle at center,
    rgba(19, 189, 236, 0.10) 0%,
    rgba(16, 30, 34, 0.90) 100%
  );
  backdrop-filter: blur(8px);
}

/* ── Decorative blur orbs ── */
.orb {
  position: absolute; border-radius: 50%;
  filter: blur(80px); opacity: 0.4;
}

/* ── Voice orb glow ── */
.orb-glow {
  box-shadow: 0 0 60px 10px rgba(19, 189, 236, 0.4);
}

/* ── Glassmorphism variant (ai_thinking_state) ── */
.glass-morphism {
  background: rgba(19, 189, 236, 0.05);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(19, 189, 236, 0.20);
}

/* ── Glow border (entity_detail_view) ── */
.glow-border {
  box-shadow: 0 0 20px rgba(19, 189, 236, 0.4);
  border: 2px solid rgba(19, 189, 236, 0.6);
}

/* ── Danger glass ── */
.glass-danger {
  background: rgba(239, 68, 68, 0.10);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(239, 68, 68, 0.20);
}

/* ── Glass input ── */
.glass-input {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.10);
}
.glow-input:focus {
  border-bottom-color: #13bdec;
  box-shadow: 0 4px 12px -2px rgba(19, 189, 236, 0.3);
}

/* ── Glass pill (active filter chip) ── */
.glass-pill { background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.10); }
.glass-pill-active { background: rgba(19, 189, 236, 0.25); border-color: #13bdec; }

/* ── Glass chip (entity/detail views) ── */
.glass-chip {
  background: rgba(19, 189, 236, 0.10);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(19, 189, 236, 0.20);
}

/* ── Glow text ── */
.glow-text { text-shadow: 0 0 20px rgba(19, 189, 236, 0.4); }

/* ── Ocean gradient (voice_enrollment background) ── */
.ocean-gradient {
  background: radial-gradient(circle at center, #1a3a44 0%, #101e22 100%);
}

/* ── Glass effect (voice_enrollment panels) ── */
.glass-effect {
  background: rgba(19, 189, 236, 0.05);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(19, 189, 236, 0.20);
}
```

---

## A.3 Screen-by-Screen Implementation Reference

---

### A.3.1 `splash_screen/`
**Background:** `.mesh-gradient` — `#101e22` + 4-corner primary radials  
**Center logo container:** `w-[120px] h-[120px] rounded-full glass-panel border border-white/10`  
**Inner logo disc:** `bg-primary/20 rounded-full` 80×80px with `bubble_chart` Material Symbol, `text-primary text-5xl`  
**Title text:** `text-slate-100 text-xl font-semibold`  
**Subtitle:** `text-primary/70 text-xs font-bold uppercase tracking-[0.2em]`  
**Progress bar container:** `w-[200px] h-[6px] glass-panel rounded-full`  
**Progress fill:** `bg-gradient-to-r from-primary via-indigo-400 to-teal-400 shadow-[0_0_8px_rgba(19,189,236,0.5)]` width 35%  
**Footer chip:** `.glass-panel rounded-full px-4 py-2 flex items-center gap-2`; teal-400 `animate-pulse` dot + "Secure Connection Established" `text-xs`  
**Decorative orbs:** `absolute top-0 left-0 w-64 h-64 bg-primary/10 blur-[100px]`; `bottom-0 right-0 w-48 h-48 bg-indigo-500/10 blur-[120px]`  
**JavaScript:** None — CSS `animate-pulse` only

---

### A.3.2 `login_screen/`
**Background:** 3 absolute orbs + `bg-background-dark/40 backdrop-blur-3xl` overlay layer  
**Orbs:** `bg-primary/20 blur-[100px] w-64 h-64` top-left; `bg-indigo-500/10 blur-[80px] w-48 h-48` top-right; `bg-teal-500/20 blur-[120px] w-72 h-72` bottom-right  
**Logo disc:** `w-20 h-20 rounded-full bg-white/10 backdrop-blur-md border border-white/20 ring-1 ring-white/5`; inner `w-14 h-14 rounded-full bg-gradient-to-br from-primary to-indigo-500`  
**Form card:** `bg-white/5 backdrop-blur-2xl border border-white/10 rounded-xl p-8 shadow-2xl`  
**Inputs:** `bg-white/5 border border-white/10 rounded-lg py-4 pl-12 pr-4 w-full focus:ring-2 focus:ring-primary/50 focus:border-primary/50`; Material Symbol icon at `left-4 top-1/2 -translate-y-1/2 text-slate-400`  
**Login button:** `w-full py-4 rounded-full relative overflow-hidden`; outer gradient `bg-gradient-to-r from-primary via-[#34d399] to-primary bg-[length:200%_auto]`; inner shine `absolute inset-[1px] rounded-full bg-gradient-to-b from-white/20`  
**Divider:** `border-t border-white/10` + "or" badge `bg-white/5 px-3 py-1 rounded-full border border-white/10 text-slate-400 text-sm`  
**Google button:** `w-full border border-white/10 bg-white/5 hover:bg-white/10 rounded-full py-4`

---

### A.3.3 `login_screen_redesign/`
**Background:** `.mesh-gradient` with 2-corner primary radials + `radial-gradient(at 50% 50%, #101e22 0%, transparent 60%)` center darkening  
**Brand header:** `w-14 h-14 rounded-2xl bg-primary/20 border border-primary/30 backdrop-blur-sm`; `bubble_chart` icon text-primary; title `text-4xl font-extrabold tracking-tight`  
**Login card:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.05); }` `w-full max-w-[440px] rounded-xl p-8 md:p-12`  
**Input labels:** `text-xs font-bold uppercase tracking-[0.2em] text-slate-500`  
**Inputs:** `.glow-input` — underline only `border-b border-slate-700`; focus: `border-bottom-color: #13bdec; box-shadow: 0 4px 12px -2px rgba(19,189,236,0.3);`  
**CTA button:** `.glass-pill { background: rgba(19,189,236,0.15); backdrop-filter: blur(10px); border: 1px solid rgba(19,189,236,0.3); box-shadow: inset 0 0 15px rgba(19,189,236,0.2); }` `rounded-full py-4 w-full text-primary font-bold`  
**Social buttons:** 2-col grid `border border-slate-800 hover:bg-slate-800/40 rounded-lg h-12`  
**Bottom nav:** Fixed `bg-background-dark/80 backdrop-blur-md border-t border-slate-800`; 4 tabs with icon + label

---

### A.3.4 `signup_screen/`
**Background:** `.gradient-mesh` — 4-corner radials using primary (0.15) and `rgba(139,92,246,0.15)` purple  
**Logo:** `w-12 h-12 rounded-full bg-primary shadow-[0_0_20px_rgba(19,189,236,0.4)]` centered  
**Outer card wrapper:** `.prismatic-border` — `::before` gradient border at `opacity: 0.5`  
**Inner card:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.1); }` `rounded-xl p-8`  
**Inputs:** `bg-slate-900/50 border border-slate-700/50 rounded-xl px-4 py-3.5`; focus `ring-2 ring-primary/50`  
**Password strength bar:** 3 segments; active segments `bg-primary shadow-[0_0_10px_rgba(19,189,236,0.6)]`  
**CTA:** `bg-gradient-to-r from-primary to-[#00d2ff] rounded-full py-4 text-slate-900 font-bold`  
**Google button:** `bg-white/5 border border-slate-700/50 rounded-xl w-full py-3`

---

### A.3.5 `verify_email/`
**Background:** `.mesh-gradient` (4-corner)  
**Card:** `.glass-card` `w-full max-w-md rounded-xl p-8` centered  
**Icon disc:** `w-24 h-24 rounded-full glass-card`; pulse ring animation: `@keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(19,189,236,0.4); } 70% { box-shadow: 0 0 0 20px transparent; } }`  
**Icon:** `mail` Material Symbol `text-primary text-5xl`  
**Primary button:** `bg-primary rounded-full py-4 font-bold w-full`  
**Secondary button:** `border border-primary/30 text-primary rounded-full py-4 w-full`  
**Bottom nav:** `.glass-card rounded-full` floating pill — 4 icons

---

### A.3.6 `complete_profile/`
**Background:** `.gradient-mesh` (4-corner primary)  
**Card:** `.glass-panel` `w-full max-w-[480px] rounded-xl p-6 md:p-8 overflow-y-auto max-h-[85vh]`  
**Avatar container:** `w-30 h-30 rounded-full glass-input border-2 border-primary/30`; camera overlay; `+` FAB `bg-primary rounded-full w-8 h-8`  
**All inputs:** `.glass-input { background: rgba(255,255,255,0.05); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.10); }` `h-14 pl-12 rounded-lg`; icon at `left-4`  
**Fields:** Full name, DOB (text input), Gender (select `bg-background-dark`), Location (select)  
**CTA:** `bg-gradient-to-r from-primary to-primary/80 rounded-full h-14 w-full font-bold`  
**Progress dots:** 3 pills `h-1.5 w-8 rounded-full` — 2 `bg-primary`, 1 `bg-slate-700`

---

### A.3.7 `home_screen/`
**Background base:** Fixed `#0a1215` (darker variant); 5-point mesh including center radial  
**Header:** `.glass-header { background: rgba(19,189,236,0.03); backdrop-filter: blur(12px); border-bottom: 1px solid rgba(255,255,255,0.05); }` sticky; avatar `w-10 h-10 border border-primary/30`; `bubble_chart` title `.glow-text { text-shadow: 0 0 20px rgba(19,189,236,0.4); } text-primary`; notification Glass card badge `bg-primary rounded-full w-3 h-3 border-2 border-background-dark`  
**Greeting:** `text-5xl font-[800] text-slate-100`; name `text-primary glow-text`  
**Session card:** `.glass-card rounded-xl p-6` flex row; icon `w-14 h-14 bg-primary/20 rounded-full`; hover glow `bg-primary/10 blur-2xl`  
**Feature grid:** 2-col; each `glass-card rounded-xl p-6 aspect-square`  
**Stats chart:** `.glass-card rounded-xl p-6`; 7-bar mini chart — inactive `bg-primary/10`; active `bg-primary/30 border-t-2 border-primary`  
**Glass classes:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 8px 32px 0 rgba(0,0,0,0.3); }` `.glass-badge { background: rgba(19,189,236,0.2); backdrop-filter: blur(4px); border: 1px solid rgba(19,189,236,0.3); }`  
**Bottom nav:** `glass-header border-t border-primary/10 rounded-t-xl pb-8 pt-4`; active tab `text-primary`; inactive `text-slate-500`

---

### A.3.8 `home_screen_redesign/`
**Background:** `body { background: radial-gradient(circle at top right, #1a2e35, #101e22); }`  
**Glass:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }`  
**Header:** Minimalist; avatar with online dot `bg-primary`; `more_horiz` button in `.glass-card`  
**Greeting:** `text-4xl font-light`; name `font-bold text-primary`  
**Start Session card:** `glass-card rounded-xl p-6`; thumbnail image + play FAB `bg-primary text-background-dark rounded-full w-10 h-10`  
**2-col grid:** `glass-card rounded-xl p-5 aspect-square` — one tinted primary, one slate-800  
**Progress card:** `glass-card rounded-xl p-4`; inline `bg-primary w-2/3`; metric `text-2xl font-bold text-primary`  
**Bottom nav:** `glass-card rounded-full flex items-center justify-around p-2 mx-4 mb-4`; active item `bg-primary text-background-dark rounded-full w-12 h-12 flex items-center justify-center`

---

### A.3.9 `consultant_ai_chat/`
**Background:** `.bg-gradient-mesh { background-color: #101e22; }` 2-point radials + center darkener  
**Glass:** `.glass { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }` `.glass-primary { background: rgba(19,189,236,0.15); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.3); }`  
**Header:** `glass border-b border-white/5 px-4 py-3`; AI name + `animate-pulse` primary status dot  
**Date chip:** `bg-white/5 rounded-full text-[11px] px-3 py-1`  
**AI messages:** `glass rounded-xl rounded-bl-none px-4 py-3 text-sm text-slate-200`; avatar `w-8 h-8 bg-primary/20 border border-primary/30 rounded-full`  
**User messages:** `glass-primary rounded-xl rounded-br-none px-4 py-3 text-sm text-slate-100`; read receipt `done_all text-primary`  
**Input bar:** `glass rounded-2xl p-2 flex items-center border border-white/10`; send FAB `bg-primary text-background-dark w-10 h-10 rounded-xl shadow-primary/20`  
**Footer:** Fixed `p-4 pb-8` — input bar + ghost suggestion chips below

---

### A.3.10 `ai_chat_redesign/`
**Background:** `.mesh-bg` — very subtle 2-point radials at `rgba(19,189,236,0.05)` and `0.02`  
**Glass:** `.glass-ai { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.05); }` `.glass-user { background: rgba(19,189,236,0.10); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.2); }` `.glass-nav { background: rgba(16,30,34,0.70); backdrop-filter: blur(20px); }`  
**Header:** `glass-nav`; centered "CONSULTANT" label + title; pulsing online dot  
**AI avatar:** `w-10 h-10 glass-ai border border-white/10 rounded-full`; `auto_awesome` icon text-primary  
**AI bubble:** `glass-ai rounded-xl rounded-tl-none p-4`  
**User bubble:** `glass-user rounded-xl rounded-tr-none p-4 shadow-sm shadow-primary/5`  
**Suggestion chips:** 2-col grid of `glass-ai rounded-lg py-2 px-3 text-primary text-[12px]`  
**Input:** `glass-ai rounded-full flex items-center p-2 pl-6`; `arrow_upward` FAB `bg-primary rounded-full w-10 h-10`  
**Bottom nav:** `glass-nav border-t border-white/5`; 4 tabs: DASHBOARD, CONSULT (active primary), INSIGHTS, PROFILE

---

### A.3.11 `session_history/`
**Background:** `.gradient-mesh` (5-point including center at `rgba(19,189,236,0.04)`)  
**Header:** `.glass-header { background: rgba(16,30,34,0.70); backdrop-filter: blur(20px); border-bottom: 1px solid rgba(19,189,236,0.10); }` sticky; "History" centered  
**Filter chips:** Active `bg-primary text-slate-900 shadow-primary/20 rounded-full`; inactive `.glass rounded-full text-slate-300 hover:bg-white/10`  
**Session cards:** `.glass rounded-xl p-4 flex items-center gap-4`; icon `w-12 h-12 rounded-lg bg-primary/20 border border-primary/30`; title `font-bold truncate`; timestamp `text-[10px] uppercase text-slate-500`; description `line-clamp-1 text-slate-400`; `chevron_right` text-primary  
**Color coding:** primary=chat, emerald=work, purple=psychology, amber=lightbulb, rose=favorite  
**Date dividers:** centered `text-[11px] font-bold uppercase tracking-[0.2em] text-slate-600`  
**Bottom nav:** Fixed `.glass-header border-t border-white/10`; center FAB `bg-primary w-14 h-14 rounded-full border-4 border-background-dark -mt-7 z-10`; `add` icon text-background-dark

---

### A.3.12 `live_wingman_session/`
**Background:** 3 `.orb { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.4; }` — `bg-primary w-[400px]` top-left; `bg-blue-500 w-[300px]` bottom-right; `bg-cyan-400 w-[250px]` center  
**Header:** `.glass mx-4 mt-4 px-6 py-4 rounded-xl`; timer badge `bg-slate-900/50 rounded-full border border-white/10`; recording red pulsing dot  
**Pre-session card:** `.glass max-w-sm w-full p-8 rounded-xl text-center`; voice mic circle `w-24 h-24 bg-primary/10 rounded-full border-2 border-primary/30`; 3 nested pulse rings using `scale-125`, `scale-150` + absolute positioning  
**Start button:** `w-full bg-primary text-background-dark font-bold py-4 rounded-xl shadow-primary/20`  
**Active transcript:** `glass rounded-xl p-4`; user msg `bg-primary/20 border border-primary/30 rounded-2xl px-4 py-2`  
**AI feedback panel:** `glass rounded-xl border-t-2 border-primary/30`; `lightbulb` icon; suggestion chips `bg-white/5 border border-white/10 rounded-full text-[10px]`  
**Bottom nav:** `glass mx-4 mb-4 p-2 rounded-full border border-white/10`; active tab `text-primary bg-primary/10`

---

### A.3.13 `connections/`
**Background:** `.gradient-bg { background: radial-gradient(circle at 0% 0%, #101e22, #101e22 50%, #0d2a33 100%); }` + mesh overlay gradient orb top-right  
**Status card:** `.glass-primary rounded-xl p-8 flex-col items-center shadow-[0_0_30px_rgba(19,189,236,0.15)] border-primary/40`; avatar `w-20 h-20 glass border-primary/50 border-2 rounded-full`; animated badge `bg-emerald-500 animate-ping`  
**URL input group:** Grouped `glass rounded-l-xl` icon + `glass w-full border-l-0 border-r-0` input + `glass rounded-r-xl` copy button; focus glow: `absolute -inset-0.5 bg-primary/20 blur opacity-30 group-focus-within:opacity-100`  
**Buttons:** `glass rounded-xl py-3` (Reset) + `bg-primary rounded-xl py-3` (Save & Test)  
**Stats grid:** 2-col `glass p-4 rounded-xl` — Latency 24ms, Uptime 99.98%  
**Bottom nav:** Fixed `.glass border-t border-white/10 pb-8 pt-4`; active `text-primary`

---

### A.3.14 `settings_screen/`
**Background:** `.bg-mesh` (4-corner primary radials, lighter bottom-right)  
**Header:** `.glass-panel { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }` sticky; "Settings" + `search` icon  
**Section headers:** `text-xs font-bold uppercase tracking-widest text-primary/80`  
**Item groups:** `.glass-panel rounded-xl overflow-hidden divide-y divide-white/5`  
**Each row:** `flex items-center gap-4 p-4 hover:bg-white/5`; leading icon in `rounded-lg bg-{color}/10 w-10 h-10 flex items-center justify-center`  
**Toggle ON:** `w-12 h-6 bg-primary rounded-full`; thumb `w-4 h-4 bg-white rounded-full absolute right-1`  
**Toggle OFF:** `bg-slate-700`; thumb `bg-slate-400`  
**Accent swatches:** `w-5 h-5 rounded-full` dots: primary, `bg-purple-500`, `bg-rose-500`  
**Logout button:** `border border-rose-500/30 text-rose-500 rounded-xl hover:bg-rose-500/10 py-4 w-full`  
**Bottom nav:** `sticky bottom-0 glass-panel border-t border-white/10`; 4 tabs; active "Settings" `text-primary font-bold`

---

### A.3.15 `navigation_drawer/`
**Layout:** `w-80` left sidebar + `ml-80` main area  
**Drawer:** `.glass-panel { background: rgba(19,189,236,0.05); backdrop-filter: blur(16px); border-right: 1px solid rgba(255,255,255,0.1); }` `rounded-tr-[24px] rounded-br-[24px]`  
**Header section:** `p-8 bg-white/5 border-b border-white/5`; avatar `rounded-2xl border-2 border-primary shadow-primary/20`; verified badge `bg-primary rounded-full w-6 h-6`  
**Nav tiles:** `.glass-tile { background: rgba(255,255,255,0.03); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.05); }` `rounded-xl`  
**Active tile:** `.glass-tile-active { background: rgba(19,189,236,0.2); border: 1px solid rgba(19,189,236,0.3); }`  
**Hover:** `hover:bg-white/10`  
**Footer:** `p-6 bg-white/5 border-t border-white/5`; `.pulse-glow { @keyframes pulse { box-shadow rings from 0→10px } }` green status dot  
**Background:** `.gradient-mesh { radial-gradient from #13bdec33 at corners; center #101e22→#081114 }`

---

### A.3.16 `voice_overlay/`
**Layout:** Full-screen overlay on blurred app content (`opacity-30 grayscale` behind)  
**Scrim:** `.scrim-overlay { background: radial-gradient(circle at center, rgba(19,189,236,0.1) 0%, rgba(16,30,34,0.9) 100%); backdrop-filter: blur(8px); }`  
**Voice orb rings:** `border-primary/10`, `border-primary/20`, `border-primary/30` concentric circles  
**Center orb:** `w-24 h-24 rounded-full bg-primary/40 ring-4 ring-primary/20 orb-glow { box-shadow: 0 0 60px 10px rgba(19,189,236,0.4); }`; `bubble_chart` icon white text-4xl  
**Transcription:** italic `text-slate-400 text-lg`; query `text-slate-100 text-3xl font-bold`; highlighted words `text-primary`  
**Bottom panel:** `.glass-panel { background: rgba(16,30,34,0.7); backdrop-filter: blur(24px); border-top: 1px solid rgba(19,189,236,0.2); }` `rounded-t-xl`; drag handle `bg-slate-600/50`  
**Status chip:** `bg-primary/10 border border-primary/20 rounded-full`; `animate-ping` + `animate-pulse` dot; "LISTENING" uppercase `text-[10px]`  
**Tabs:** Active `bg-primary/10 border border-primary/20`; inactive `hover:bg-slate-800/40`

---

### A.3.17 `entity_knowledge_graph/`
**Background:** `.mesh-bg` (4-corner primary)  
**Header:** Sticky `backdrop-blur-md`; hamburger + title + `bubble_chart` in `.glass` rounded  
**Search bar:** `.glass rounded-xl h-14`; `search` icon primary left; `mic` right  
**Filter chips:** Scrollable; `.glass rounded-full h-10 px-5`; active `bg-primary/20 text-primary`; emerald(place), amber(event), purple(org), pink(concept)  
**Entity tiles:** `.glass rounded-xl p-4 hover:border-primary/50`; icon `w-12 h-12 rounded-lg bg-{color}/20 border border-{color}/30`  
**Expanded tile:** `.glass bg-primary/5 border-primary/30`; connection chips `px-2 py-1 rounded bg-white/5 border border-white/10 text-xs`  
**Bottom nav:** `.glass border-t-0 backdrop-blur-xl pb-6 pt-3 rounded-t-xl`; center FAB `bg-primary rounded-full w-12 h-12 -top-8 border-4 border-background-dark`

---

### A.3.18 `about_bubbles/`
**Header:** `.glass-dark { background: rgba(0,0,0,0.3); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.05); }` sticky; `bubble_chart` in `rounded-lg bg-primary/20 border-primary/30`  
**Hero:** `.glass { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.1); }` wrapper; gradient banner `from-primary/40 to-background-dark`; `blur_on` icon  
**Content cards:** `glass p-6 rounded-xl space-y-4`; section headers `text-primary` with Material Symbol  
**Team grid:** 2-col; each `glass p-4 rounded-xl flex items-center`; avatar `rounded-full bg-primary/20 border border-primary/30 w-14 h-14`  
**Footer:** `border-t border-primary/10 py-8 text-center text-slate-500`

---

### A.3.19 `notifications/`
**Background:** `.gradient-mesh` with additional orange accent: `radial-gradient(at 100% 0%, rgba(249,115,22,0.1))` + `at 0% 100%` orange 0.15  
**Sheet layout:** `absolute inset-x-0 bottom-0 top-12 bg-background-dark/95 rounded-t-xl`; drag handle `w-12 h-1.5 bg-slate-700 rounded-full`  
**Header:** `.glass-header { background: rgba(16,30,34,0.7); backdrop-filter: blur(12px); border-bottom: 1px solid rgba(19,189,236,0.1); }` sticky inside sheet  
**Tabs:** `border-b border-slate-800`; active `border-b-2 border-primary text-primary`; events tab `border-orange-500 text-orange-500`  
**Notification tiles:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.05); }` `rounded-lg p-4`; unread `border-l-2 border-l-primary`; icons in `rounded-lg bg-{color}/20`  
**Events:** `bg-orange-500/20 border border-orange-500/30`; timestamp `text-orange-500 font-semibold uppercase` ("In 15 min")

---

### A.3.20 `pop_ups_dialogs/`
**Background:** `.mesh-bg` (4-corner primary)  
**Theme picker:** `.glass rounded-xl p-2 flex gap-2`; `has-[:checked]:bg-primary has-[:checked]:text-background-dark`  
**Delete dialog:** `.glass rounded-xl p-6 border-red-500/20`; icon disc `w-16 h-16 bg-red-500/20 rounded-full text-red-500`; Cancel `bg-white/10 rounded-lg`; Delete `bg-red-500 text-white rounded-lg`  
**Sort bottom sheet:** `.glass rounded-t-xl p-4`; drag handle `bg-white/20`; active `bg-primary/10 text-primary` + `check_circle`; inactive `hover:bg-white/5`  
**Info snackbar:** `.glass bg-primary/20 border-primary/30 rounded-lg p-4` fixed above nav; "Dismiss" `text-primary font-bold`  
**Bottom nav:** Fixed `.glass border-t border-white/10`; center FAB `bg-primary w-14 h-14 rounded-full border-4 border-background-dark -mt-10 z-10`

---

### A.3.21 `end_session_dialog/`
**Background:** `.mesh-gradient` — HSLA 193 corners at 0.3 (stronger than usual)  
**Scrim:** `bg-background-dark/60 backdrop-blur-sm` fixed full-screen  
**Dialog:** `.glass-panel { background: rgba(25,43,51,0.65); backdrop-filter: blur(12px); }` + `.prismatic-border::before { background: linear-gradient(45deg, #13bdec44, #ffffff22, #13bdec44); }` `w-full max-w-sm rounded-xl p-8 text-center`  
**Warning icon:** `w-20 h-20 glass-panel rounded-full`; inner `w-14 h-14 bg-orange-500/20 rounded-full`; `warning` icon `text-orange-400 text-3xl`  
**End button:** `w-full h-14 rounded-full bg-red-500/20 border border-red-500/30 hover:bg-red-500/30 text-red-400 font-bold`  
**Continue button:** `w-full h-14 rounded-full border border-primary/20 hover:bg-primary/10 text-slate-300 font-semibold`  
**Handle:** `h-1 w-12 rounded-full bg-primary/20 mx-auto mt-4`

---

### A.3.22 `success_overlay/`
**Scrim:** `.frosted-scrim { background: rgba(16,30,34,0.7); backdrop-filter: blur(8px); }` fixed  
**Dialog:** `.glass-card { background: rgba(28,36,39,0.6); backdrop-filter: blur(16px); border: 1px solid rgba(255,255,255,0.1); }` `w-full max-w-sm rounded-xl p-8 text-center`  
**Success icon:** `w-20 h-20 bg-green-500/20 border border-green-400/30 rounded-full`; `.glow-green { box-shadow: 0 0 20px rgba(34,197,94,0.4); }`; `check` icon `text-green-400 text-4xl`  
**Title:** "Session Saved" `text-2xl font-bold text-slate-100`  
**Action button:** `bg-primary/20 hover:bg-primary/30 text-primary border border-primary/30 rounded-full py-3 backdrop-blur-md`

---

### A.3.23 `loading_overlay/`
**Background:** `.mesh-gradient` (5-point including center `rgba(19,189,236,0.04)`)  
**Scrim:** `.glass-scrim { background: rgba(16,30,34,0.6); backdrop-filter: blur(20px); }` fixed z-50  
**Loading orb glow ring:** `absolute w-24 h-24 bg-primary/20 rounded-full blur-2xl animate-pulse`  
**Orb:** `.orb-glass { background: radial-gradient(circle at 30% 30%, rgba(255,255,255,0.2), transparent); box-shadow: 0 0 40px rgba(19,189,236,0.4), inset 0 0 20px rgba(255,255,255,0.1); }` `w-15 h-15 rounded-full`; specular `top-2 left-3 w-4 h-4 bg-white/30 blur-[2px]`  
**Text:** `text-xl font-bold text-slate-100`  
**Progress track:** `w-48 h-1 bg-slate-800/30 rounded-full`; fill `bg-primary w-1/3 animate-[shimmer_2s_infinite]`  
**Ghosted nav:** `opacity-30 backdrop-blur-md`

---

### A.3.24 `offline_state/`
**Background:** `.mesh-gradient` with amber accents: `radial-gradient(at 100% 0%, rgba(245,158,11,0.1))` + `at 0% 100%` amber 0.1  
**Amber glow:** `absolute w-72 h-72 bg-amber-400/10 blur-[100px] rounded-full` centered  
**Error card:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` `border-amber-400/30 ring-1 ring-amber-400/20 w-full max-w-md rounded-xl p-8`  
**Icon:** `w-20 h-20 bg-slate-800/50 rounded-full text-slate-500`; `wifi_off` `text-5xl`  
**Progress bar:** `w-full h-1 bg-slate-800`; fill `bg-primary w-1/3 opacity-80`  
**Retry button:** `border border-slate-700 hover:border-primary rounded-full h-12 px-8`; `refresh` icon `text-primary`  
**Status text:** `text-slate-500 text-[10px] font-bold uppercase tracking-widest` — "Network Status: Offline"

---

### A.3.25 `subscription_screen/`
**Background orbs:** `bg-primary w-[500px] h-[500px] -top-20 -left-20 blur-[80px] opacity-[0.06]`; `bg-blue-500 w-[400px]` bottom-right; `bg-cyan-400 w-[300px]` center `opacity-[0.03]`  
**Main card:** `.glass { background: rgba(255,255,255,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` `rounded-xl overflow-hidden shadow-2xl w-full max-w-lg`  
**Feature tiles:** 3-col grid `glass p-4 rounded-xl flex-col items-center`; icon disc `w-10 h-10 bg-primary/20 rounded-full text-primary`  
**Pricing card:** `glass bg-white/5 border-primary/30 p-6 rounded-xl`; highlight orb `-top-10 -right-10 w-32 h-32 bg-primary/10 blur-2xl`; price `text-3xl font-black text-white`  
**Features list:** `check_circle text-primary text-lg` preceding each item  
**CTA:** `w-full py-4 rounded-full bg-gradient-to-r from-primary to-cyan-400 text-white font-bold shadow-primary/30`

---

### A.3.26 `voice_enrollment/`
**Background:** `.ocean-gradient { background: radial-gradient(circle at center, #1a3a44 0%, #101e22 100%); }`  
**Glass:** `.glass-effect { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.2); }`  
**Progress pills:** 5-pip row — completed `bg-primary/30 h-1.5 w-8`; active `bg-primary h-2 w-12 shadow-[0_0_10px_rgba(19,189,236,0.5)]`; future `bg-primary/10`  
**Voice orb:** `w-40 h-40 bg-gradient-to-br from-primary to-primary/40 rounded-full orb-glow { box-shadow: 0 0 60px 10px rgba(19,189,236,0.4); }`; outer rings `border border-primary/10` + `border-primary/20 animate-pulse`; `graphic_eq` icon white text-5xl center  
**Status badge:** `absolute -bottom-4 glass-effect px-4 py-1.5 rounded-full`; red dot `shadow-[0_0_8px_#ef4444] animate-pulse`; "Listening..." `text-[10px] uppercase tracking-widest`  
**Phrase card:** `glass-effect rounded-xl p-8`; left accent bar `w-1 h-full bg-primary`; italic quoted phrase; highlighted word `text-primary font-bold`  
**Play sample button:** `glass-effect rounded-xl hover:bg-primary/20 px-6 py-3`  
**CTA:** `w-full bg-primary rounded-xl py-5 text-background-dark font-extrabold shadow-[0_0_30px_rgba(19,189,236,0.2)]`  
**Footer ambient:** Fixed bottom `h-32 bg-gradient-to-t from-primary/40 to-transparent opacity-20 pointer-events-none`

---

### A.3.27 `advanced_filter_overlay/`
**Backdrop:** `bg-background-dark/60 backdrop-blur-sm` fixed (behind sheet)  
**Sheet:** `.glass-dark { background: rgba(16,30,34,0.8); backdrop-filter: blur(20px); border-top: 1px solid rgba(255,255,255,0.1); }` `max-h-[90vh] rounded-t-2xl`; drag handle `bg-slate-100/20 w-12 h-1 rounded-full`  
**Glass classes:** `.glass { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` `.glass-pill { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); }` `.glass-pill-active { background: rgba(19,189,236,0.25); border-color: #13bdec; }`  
**Calendar:** `glass rounded-xl p-4`; 7-col grid; selected range `bg-primary/20 text-primary font-bold`; range endpoints `rounded-l-lg` / `rounded-r-lg`  
**Session type / Sentiment chips:** `glass-pill rounded-full px-5 py-2.5`; active `glass-pill-active text-primary`  
**Apply button:** `w-full bg-gradient-to-r from-primary to-cyan-400 text-slate-900 font-bold py-4 rounded-xl shadow-primary/20`; sticky footer `border-t border-white/5 bg-background-dark/40 backdrop-blur-md pt-4`

---

### A.3.28 `search_discovery/`
**Background:** `.mesh-bg` (4-corner primary, lighter bottom-right at 0.08)  
**Header:** `.glass-panel { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` sticky; "Discovery" + QR scanner button  
**Search bar:** `.glass-card { background: rgba(19,189,236,0.05); backdrop-filter: blur(8px); border: 1px solid rgba(19,189,236,0.2); }` `h-12 rounded-xl`; primary `search` icon + `mic` right  
**Filter chips:** Active `bg-primary shadow-primary/20 text-white`; inactive `.glass-card text-slate-300`  
**Recent searches:** `.glass-card rounded-xl` flex row; `history` icon + text + `close` icon `text-slate-500`  
**Trending circles:** `w-20 h-20 glass-card border-2 border-primary/40 rounded-full`  
**Suggested vertical cards:** `glass-card rounded-2xl overflow-hidden`; image header; badge `glass-panel rounded-lg text-[10px]`; JOIN button `bg-primary text-white text-[10px] rounded-full px-3 py-1`  
**Bottom nav:** `.glass-panel border-t border-primary/10`; FAB `-top-6 w-14 h-14 bg-primary border-4 border-background-dark rounded-full`

---

### A.3.29 `expanded_user_profile/`
**Background:** Fixed corner orbs `bg-primary/10 blur-[100px]` top-left; `bg-primary/5 blur-[100px]` bottom-right  
**Header:** `.glass-header { background: rgba(16,30,34,0.8); backdrop-filter: blur(8px); }` sticky; back + "Profile" + settings  
**Avatar ring:** `ring-2 ring-white/10` glass wrapper; `w-32 h-32 rounded-full border-4 border-background-dark`; ambient `bg-primary/20 blur-3xl scale-150 opacity-30`; LVL badge `bg-primary text-white text-xs px-3 py-1 rounded-full absolute bottom-1 right-1`  
**Glass:** `.glass { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.1); }`  
**Stats grid:** 3-col `glass p-5 rounded-xl flex-col items-center`; icon `text-primary text-3xl`; value `text-2xl font-bold`  
**Achievement tiles:** `glass p-4 rounded-xl flex items-center hover:bg-primary/10`; icon `w-12 h-12 bg-primary/20 rounded-lg`; progress bar `bg-slate-800 h-1.5`; fill `bg-primary h-full w-[65%]`  
**Locked achievement:** `opacity-60`; icon `bg-slate-700`; `lock` overlay

---

### A.3.30 `entity_detail_view/`
**Glass classes:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }` `.glass-chip { background: rgba(19,189,236,0.1); backdrop-filter: blur(8px); border: 1px solid rgba(19,189,236,0.2); }` `.glow-border { box-shadow: 0 0 20px rgba(19,189,236,0.4); border: 2px solid rgba(19,189,236,0.6); }` `.glass-danger { background: rgba(239,68,68,0.1); backdrop-filter: blur(8px); border: 1px solid rgba(239,68,68,0.2); }`  
**Entity avatar:** `w-40 h-40 rounded-full glow-border bg-background-dark/40`; gradient overlay `from-primary/20`; `blur_on` icon `text-primary text-6xl`; ambient ring `-inset-1 bg-primary/20 blur-xl opacity-50`  
**At a Glance card:** `.glass-card rounded-xl p-5`; rows divided by `h-[1px] bg-white/5`  
**Connection chips:** `glass-chip px-4 py-2 rounded-full`; `hub` icon primary xs  
**Mention cards:** `glass-card rounded-xl p-4 flex gap-4`; icon `w-12 h-12 bg-primary/10 rounded-lg`; `line-clamp-1`  
**Danger action:** `glass-danger w-full py-4 rounded-xl text-red-400 hover:bg-red-500/10`

---

### A.3.31 `ai_insights_dashboard/`
**Header:** `bg-background-dark/80 backdrop-blur-md border-b border-primary/10`; `bubble_chart` icon primary; "AI Insights" centered  
**Glass:** `.glass-panel { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.1); }`  
**Recent sessions row:** Horizontal scroll; active `w-16 h-16 rounded-full bg-primary/20 border-2 border-primary/40`; inactive `bg-slate-800 w-16 h-16 rounded-full`  
**Emotional Trends:** `glass-panel rounded-xl p-5 border border-primary/20`; SVG line chart `stroke="#13bdec" stroke-width="3"`; `linearGradient` fill from `rgba(19,189,236,0.4)` to transparent; data points as `cx,cy r="4" fill="#13bdec"`  
**Key discoveries grid:** 2×2 `glass-panel p-4 rounded-xl`; category `text-[10px] uppercase tracking-widest text-primary font-bold`  
**AI recommendation chip:** `bg-primary/10 border border-primary/30 p-4 rounded-xl`; `auto_awesome` icon primary  
**Bottom nav:** `bg-background-dark/95 backdrop-blur-lg border-t border-primary/10`; FAB `-top-6 bg-primary w-14 h-14 rounded-full`

---

### A.3.32 `qr_scanner_sheet/`
**Backdrop:** `bg-black/40 backdrop-blur-sm` fixed  
**Sheet:** `.glass-panel { background: rgba(25,43,51,0.65); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` `rounded-t-[24px]`  
**Camera preview area:** `w-64 h-64 rounded-2xl bg-black/40`; inner `w-48 h-48 rounded-xl border-2 border-primary/40` wrapped in `.prismatic-border { padding: 3px; background: linear-gradient(135deg, rgba(19,189,236,0.4), rgba(255,255,255,0.2), rgba(19,189,236,0.4)); }`  
**Scan line:** `absolute top-0 left-0 right-0 h-0.5 bg-primary/60 shadow-[0_0_15px_rgba(19,189,236,0.8)] animate-pulse`  
**Corner accents:** `border-t-4 border-l-4 border-primary rounded-tl-lg w-6 h-6` × 4 corners  
**Controls:** `w-12 h-12 bg-white/5 border border-white/10 rounded-full` (Gallery, Torch); center `w-16 h-16 bg-primary rounded-full shadow-primary/20` (Scan FAB)  
**Close button:** `w-14 h-14 bg-white/10 border border-white/20 rounded-full backdrop-blur-md`

---

### A.3.33 `history_empty_state/`
**Background orbs:** `w-64 h-64 bg-primary/20 blur-[100px] rounded-full` centered; `w-32 h-32 bg-primary/10 blur-[60px]` top-right  
**Glass:** `.glass-effect { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }` `.glass-card { background: linear-gradient(135deg, rgba(19,189,236,0.1) 0%, rgba(19,189,236,0.05) 100%); backdrop-filter: blur(20px); border: 1px solid rgba(19,189,236,0.2); }`  
**Empty state icon:** `w-32 h-32 glass-card rounded-3xl shadow-2xl`; `chat_bubble` FILL `text-primary/40 text-7xl`  
**Title:** "No Bubbles Yet" `text-2xl font-extrabold`  
**CTA button:** `bg-primary rounded-full px-8 py-4 shadow-primary/25 flex items-center gap-2`; `add_circle` icon  
**Header:** `glass-effect sticky`  
**Bottom nav:** `glass-effect border-t border-white/5`; active with FILL icon style

---

### A.3.34 `reconnecting_state/`
**Background:** `.mesh-bg` 3-point primary radials (lighter variant); center glow `absolute w-[500px] h-[500px] bg-primary/10 rounded-full blur-[120px] -z-10`  
**Card:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }` `w-full max-w-sm rounded-xl p-8 text-center shadow-2xl`  
**Animated dots:** 3 `w-3 h-3 bg-primary rounded-full`; `.dot-pulse { animation: pulse 1.5s infinite ease-in-out; }` @ `@keyframes pulse { 0%,100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 1; transform: scale(1.2); } }` — delays: 0s, 0.2s, 0.4s  
**Title:** "Reconnecting..." `text-2xl font-extrabold text-slate-100`  
**Progress bar:** `w-full h-1 bg-white/5`; fill `bg-primary/40 w-2/3`  
**Cancel button:** `py-3 px-6 glass-card rounded-lg font-semibold hover:bg-white/10`

---

### A.3.35 `coming_soon_screen/`
**Background orbs:** `bg-primary/20 w-[400px] h-[400px] blur-[120px]` top-left; `bg-primary/10 w-[300px] h-[300px] blur-[120px]` bottom-right  
**Card wrapper:** `relative group`; glow layer `-inset-0.5 bg-gradient-to-r from-primary to-primary/30 rounded-xl blur opacity-25 group-hover:opacity-40 duration-1000`; inner `bg-slate-900/40 backdrop-blur-2xl border border-slate-700/50 rounded-xl p-8`  
**Icon container:** `w-20 h-20 bg-primary/10 border border-primary/30 rounded-full`; `lock` FILL icon `text-primary text-4xl`; blur ring `bg-primary/20 blur-xl scale-150 absolute`  
**Badge:** `bg-primary/10 border border-primary/20 text-primary text-xs uppercase px-3 py-1 rounded-full`; `w-1.5 h-1.5 bg-primary animate-pulse rounded-full`  
**Primary CTA:** `bg-primary text-white rounded-lg py-4 w-full font-bold shadow-primary/25`  
**Secondary CTA:** `border border-slate-700 rounded-lg text-slate-300 hover:bg-slate-800 py-4 w-full`  
**Waitlist avatars:** Overlapping `-space-x-3 flex`; count badge `bg-primary text-[10px] rounded-full w-8 h-8 flex items-center justify-center`  
**Bottom nav:** `bg-slate-900/40 backdrop-blur-xl border-t border-slate-200/10`; 4 tabs

---

### A.3.36 `permission_request/`
**Background:** `.mesh-gradient` (4-corner primary) + fixed corner orbs  
**Card:** `.glass-card { background: rgba(255,255,255,0.03); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.08); }` `w-full max-w-[440px] rounded-xl p-8`  
**Icon disc:** `.glass-disc { background: rgba(19,189,236,0.1); backdrop-filter: blur(10px); border: 1px solid rgba(19,189,236,0.3); }` `w-32 h-32 rounded-full`; pulse scale rings `scale-125` and behind `blur-xl`; `mic` FILL `text-primary !text-6xl`  
**Title:** `text-4xl font-extrabold tracking-tight`  
**Allow button:** `.glass-pill { background: linear-gradient(135deg, rgba(19,189,236,0.8), #13bdec); box-shadow: 0 8px 32px 0 rgba(19,189,236,0.3); }` `w-full h-14 rounded-full text-background-dark font-bold`  
**Not Now button:** `border border-primary/30 text-primary h-14 rounded-full hover:bg-primary/5 w-full`  
**Footer:** "Privacy First Architecture" `text-xs uppercase tracking-widest text-slate-500`

---

### A.3.37 `privacy_data_management/`
**Layout:** `max-w-md mx-auto border-x border-slate-800 shadow-2xl min-h-screen`  
**Glass:** `.glass { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }` `.glass-hover:hover { background: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.12); }`  
**Header:** `glass px-4 py-4 sticky`; back button `glass-hover rounded-full`  
**Section headers:** `text-sm font-bold uppercase tracking-widest text-primary`  
**Item groups:** `glass rounded-xl overflow-hidden divide-y divide-white/5`  
**Toggle ON:** `bg-primary rounded-full h-[28px] w-[48px]`; white thumb slide  
**Export progress:** `w-full bg-white/5 h-2 rounded-full`; fill `bg-primary w-[42%]`; labels "Preparing archives..." + "Estimate: 4m"  
**Delete account row:** `text-red-500 hover:bg-red-500/10`; `delete_forever` icon + `warning` accent

---

### A.3.38 `splash_screen_redesign/`
**Background:** 3 `.light-leak { filter: blur(80px); opacity: 0.15; }` orbs — `bg-primary/20` top-left, `bg-white/5` bottom-right, `bg-primary/10` center  
**Glass:** `.glass-panel { background: rgba(255,255,255,0.03); backdrop-filter: blur(24px); border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 8px 32px 0 rgba(0,0,0,0.3); }`  
**Logo container:** `w-48 h-48 glass-panel rounded-full`; inner `bg-gradient-to-tr from-primary/10 to-transparent`; `B` letter `text-7xl font-bold bg-gradient-to-br from-white to-primary/60 bg-clip-text text-transparent`; ring `border border-white/5`  
**Title:** "BUBBLES" `text-4xl font-light tracking-[0.2em] uppercase text-slate-100`  
**Progress bar:** `h-[2px] bg-slate-100/10 rounded-full w-48`; fill `bg-primary shadow-[0_0_8px_rgba(19,189,236,0.6)] w-[42%]`; label `text-[10px] uppercase tracking-widest text-slate-100/40`; percentage `text-primary text-xs tabular-nums`  
**Footer:** "Premium Experience • v2.0" `text-[10px] tracking-[0.3em] uppercase text-slate-100/20`

---

### A.3.39 `about_bubbles_redesign/`
**Background:** `.shimmer-bg { background: radial-gradient(circle at 50% 0%, rgba(19,189,236,0.15) 0%, transparent 70%), radial-gradient(circle at 100% 100%, rgba(19,189,236,0.05) 0%, transparent 50%); }`  
**Glass:** `.glass-panel { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.10); }`  
**Prismatic border (team cards):** `.prismatic-border::after { background: linear-gradient(45deg, transparent, rgba(19,189,236,0.5), transparent, rgba(19,189,236,0.3), transparent); -webkit-mask: … mask-composite: exclude; opacity: 1; pointer-events: none; }`  
**Header:** `bg-background-dark/80 backdrop-blur-md`; `arrow_back` in `w-10 h-10 rounded-full bg-slate-800/50 text-primary`; "Philosophy" label `text-sm font-medium tracking-[0.2em] uppercase text-primary`  
**Hero:** `p-6` subtitle `text-primary text-xs font-bold tracking-[0.3em] uppercase`; title `text-5xl font-extralight leading-[1.1] tracking-tight`; italic primary accent; divider `w-full h-[1px] bg-gradient-to-r from-primary/50 to-transparent`  
**Vision image:** `relative group`; glow `-inset-1 bg-gradient-to-r from-primary/20 to-transparent blur-xl opacity-50`; image `grayscale hover:grayscale-0 transition-all duration-700`; quote overlay `text-3xl font-thin tracking-tighter italic`  
**Team cards:** `glass-panel prismatic-border rounded-xl p-4 flex flex-col items-center text-center`; avatar `w-20 h-20 rounded-full border-2 border-primary/30 p-1 grayscale overflow-hidden`; role label `text-[10px] text-primary tracking-widest uppercase`  
**Principles section:** numbered `text-primary text-xs font-mono` + italic hover-reveal labels; body `text-slate-300 font-light`  
**Bottom nav:** `sticky bottom-0 glass-panel border-t border-white/10 px-6 py-4`; active item "About" `text-primary font-bold` with `w-1.5 h-1.5 bg-primary rounded-full` top dot

---

### A.3.40 `ai_thinking_state/`
**Background:** 3 absolute orbs — `w-[50%] h-[50%] bg-primary/10 blur-[120px]` top-left; `w-[60%] h-[60%] bg-primary/5 blur-[150px]` bottom-right; `w-[30%] h-[30%] bg-primary/10 blur-[100px]` top-right  
**Glass:** `.glass-morphism { background: rgba(19,189,236,0.05); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid rgba(19,189,236,0.2); }`  
**Prismatic border on orb:** `.prismatic-border { border: 1px solid transparent; background-clip: padding-box; } ::after { background: linear-gradient(45deg, #13bdec, transparent, #13bdec, transparent); z-index: -1; opacity: 0.3; border-radius: inherit; }`  
**Orb glow:** `.orb-glow { box-shadow: 0 0 80px 20px rgba(19,189,236,0.15); }`  
**Header:** `flex items-center justify-between p-6`; `close` + `settings` in `w-10 h-10 rounded-full glass-morphism`; "Bubbles AI" `text-sm font-medium tracking-wider uppercase opacity-70`; status dot `w-2 h-2 rounded-full bg-primary`  
**Central orb:** `w-64 h-64 rounded-full glass-morphism prismatic-border orb-glow`; outer rings `w-80 border-primary/10`, `w-[340px] border-primary/5`  
**Processing dots (wave pattern):** 5 `w-3 h-3 rounded-full bg-primary` at staggered `scale` and `opacity` values: 0.75/0.4, 1.0/0.7, 1.25/1.0, 1.0/0.7, 0.75/0.4; each with glow `shadow-[0_0_10px_rgba(19,189,236,0.5–0.9)]`  
**Status text:** "Analyzing Intent" `text-2xl font-bold tracking-tight`; "Processing your request..." `text-slate-400 font-medium`  
**Suggestion chips:** Scrollable row `overflow-x-auto`; each `whitespace-nowrap px-6 py-3 rounded-full glass-morphism border border-primary/20 text-sm font-semibold`  
**Bottom control bar:** `glass-morphism rounded-2xl p-2 prismatic-border flex items-center justify-between`; `keyboard` + `image` side buttons `text-slate-400`; center mic FAB `w-14 h-14 rounded-full bg-primary text-background-dark shadow-lg shadow-primary/20`  
**Ground ambient glow:** `fixed bottom-[-100px] left-1/2 -translate-x-1/2 w-full h-[300px] bg-primary/10 blur-[80px] pointer-events-none`

---

## A.4 Bottom Navigation Patterns Summary

All screens use one of these 4 bottom nav patterns:

| Pattern | Description | Screens |
|---------|-------------|---------|
| **Fixed glass bar** | `fixed bottom-0 glass-header/glass-panel border-t`; icon + label per tab | home, settings, session_history, connections, search_discovery, about_bubbles, notifications, entity_knowledge_graph |
| **Floating glass pill** | `glass-card/glass-panel rounded-full`; active tab `bg-primary rounded-full`; floats with `mx-4 mb-4` | home_redesign, live_wingman, consultant_chat redesign |
| **FAB center nav** | Fixed glass bar with oversized `-mt-6/-mt-10` FAB center button `bg-primary border-4 border-background-dark rounded-full` | session_history, pop_ups_dialogs, search_discovery, ai_insights_dashboard |
| **No nav** | Standalone screen / overlay / dialog | splash, login, signup, verify_email, end_session, success_overlay, loading_overlay, offline_state, subscription, voice_enrollment, voice_overlay, advanced_filter, qr_scanner, reconnecting, coming_soon, permission_request, ai_thinking_state |

---

## A.5 Animation & JS Summary (from HTML files)

All screens are **static HTML — no JavaScript framework animations**. Animations are pure CSS:

| Animation | CSS | Screens |
|-----------|-----|---------|
| `animate-pulse` | Tailwind built-in — 2s ease-in-out infinite opacity 0.5↔1 | Splash dots, voice dots, status badge, scan line |
| `animate-ping` | Tailwind built-in — 1s linear infinite scale + opacity 0→75% | Connection badge, notification dot |
| Custom dot-pulse | `@keyframes pulse { 0%,100%: opacity 0.3 scale(1); 50%: opacity 1 scale(1.2) }` 1.5s staggered 0s/0.2s/0.4s | reconnecting_state |
| Pulse ring | `@keyframes pulse { 0%: box-shadow 0px rgba(19,189,236,0.4); 70%: box-shadow 20px transparent }` 2s | verify_email icon |
| Pulse glow | `@keyframes pulse { box-shadow radius rings }` | navigation_drawer status dot |
| Shimmer | `@keyframes shimmer { 0%: translateX(-100%); 100%: translateX(100%) }` | loading_overlay progress fill |
| `transition-all duration-700` | Tailwind hover grayscale remove | about_bubbles_redesign vision image |
| `group-hover:opacity-40 duration-1000` | Tailwind hover glow intensify | coming_soon card glow layer |

---

*End of Appendix A — Stitch Implementation Reference (40 screens)*
