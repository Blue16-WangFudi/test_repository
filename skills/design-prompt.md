# CampusPi UI Design Specification (v1.0)

## 0. Purpose & Scope

This document defines the visual language and interaction patterns for CampusPie’s core utility experiences (Grades, Schedule, Tasks). It ensures a consistent look and feel across **iOS/Android (Flutter)**, **iPad**, **Web/Desktop**, and **Mini Program**.

**Design goals**

* Fast scanning for information-dense lists
* Calm, soft, modern “academic utility” vibe
* Clear hierarchy with minimal visual noise
* Highly reusable component system

**Primary design language**

* **Soft Surface UI** (matte light-gray backgrounds + white surfaces)
* **Large Title header** (iOS-inspired information hierarchy)
* **Card-first summaries + list detail**
* **Pill-based controls** (segmented controls, chips, icon buttons)

---

## 1. Brand & Visual Language

### 1.1 Material & Depth

* Use **matte light-gray** page backgrounds instead of pure white.
* Content lives on **white surface cards** with subtle elevation.
* Avoid heavy shadows; rely on **contrast, spacing, and rounded corners**.

**Depth rules**

* Cards: very subtle elevation
* Modals/Sheets: one level higher than cards
* Floating menus: highest (but still subtle)

### 1.2 Shape System (Rounded Geometry)

The UI uses consistent rounded shapes to feel friendly and cohesive.

**Radius ladder**

* **R-L (Large cards):** 16–20
* **R-M (List items / containers):** 12–16
* **R-S (Badges / small blocks):** 10–12
* **R-Pill (Chips / segmented / icon buttons):** 999

> Rule: anything “selectable” should lean pill-like (chips, segmented controls, icon button containers).

### 1.3 Color Strategy

* **Primary (Blue)** = selection + key actions + highlight metrics
* **Semantic colors** (Success/Warning/Info) used mostly as **tints** (soft background) with readable text.
* Avoid full-saturation large fills. Prefer **tint backgrounds**.

**Use cases**

* Primary: selected tab, important numeric emphasis, primary CTA
* Semantic: score level, task status, calendar blocks

### 1.4 Typography Hierarchy

* Strong hierarchy; most screens should be scannable in 2–3 seconds.

**Type scale (semantic naming)**

* `Title / Large` (page title): very large, bold
* `Title / Section` (section headings): medium-large, semibold
* `Body / Primary` (list item title): medium, semibold
* `Body / Secondary` (subtitle): smaller, regular, muted
* `Caption` (chips, metadata): small, medium weight

**General rules**

* Use **bold only for primary labels** (course names, section titles).
* Secondary lines should be **muted** and never compete.

---

## 2. Layout & Information Hierarchy

### 2.1 Standard Page Structure

Most utility pages follow:

1. **Header (Large Title)**
2. **Context Switcher** (segmented control / filters)
3. **Summary Card** (key metrics)
4. **Detail List** (items)
5. **Optional Detail Surface** (modal/sheet or right pane on tablet)

### 2.2 Spacing System (8-pt grid)

Use an 8-pt grid with defined increments:

* `4, 8, 12, 16, 20, 24`

**Common spacing**

* Screen horizontal padding: **16**
* Card padding: **16** (20 for dense summary cards)
* List item vertical padding: **12–16**
* Section spacing: **16–24**

### 2.3 Dividers vs Spacing

* Prefer **spacing** over strong dividers.
* If dividers exist, they must be **very subtle**.

---

## 3. Responsive & Multi-Device Rules

### 3.1 Breakpoints (conceptual)

* **Compact (phone):** single column
* **Regular (tablet/desktop):** master-detail (two columns)
* **Expanded (wide desktop):** keep two columns; optionally add a third info rail

### 3.2 Navigation Pattern by Form Factor

**Phone**

* List → Detail via **Push** or **Bottom Sheet** (choose one per module)
* Favor bottom sheets for quick inspection, push for deep workflows

**Tablet (iPad)**

* Always prefer **Master–Detail**

  * Left: list (fixed width)
  * Right: detail panel (fluid)
* Empty state shown in detail panel when nothing selected

**Desktop/Web**

* Same as tablet; keep layout stable
* Use hover states carefully (optional)

---

## 4. Component System

### 4.1 Page Header (Large Title Header)

**Purpose:** Establish location + primary actions

**Anatomy**

* Left: back button (if navigable)
* Title: large, bold
* Right: action group (icon buttons)
* Optional: small contextual link (term/year selector)

**Rules**

* Max 3 icon actions on the right
* Icon buttons must be same size and evenly spaced

**States**

* Default
* Scrolled (optional condensed title)
* Disabled action
* Loading (for refresh)

---

### 4.2 Icon Button (Circular Container)

**Style**

* Circular background (pill/round)
* Subtle border or tint background
* Minimal elevation

**States**

* Default: neutral background
* Pressed: slightly darker tint
* Disabled: low contrast icon + container
* Active: optional primary tint

---

### 4.3 Segmented Control (Pill Switcher)

**Use:** switching between modes (e.g., Overall / Research / Composite)

**Style**

* Outer container: light gray pill
* Selected segment: white pill + clearer text
* Unselected: muted text

**States**

* Default
* Selected
* Disabled segment

**Rule**

* Selection must be visible using **at least 2 cues** (background + text color/weight).

---

### 4.4 Card (Surface Container)

**Use:** summaries, key metrics, section bodies, sheets

**Variants**

* `Card / Default`
* `Card / Summary` (slightly more padding; stronger title)
* `Card / Info` (for explanations)
* `Card / Elevated` (for modal content)

**Rules**

* Cards should not be cramped—always preserve breathing room.

---

### 4.5 List Item (Three-Column Pattern)

**This is your signature list pattern.**

**Anatomy**

* **Leading:** Score badge / status icon
* **Main:** Title + subtitle(s)
* **Trailing:** Chips (0–2) or disclosure indicator

**Alignment rules**

* Main text left-aligned
* Trailing chips right-aligned, vertically centered
* Keep trailing area width consistent for stable scan rhythm

**States**

* Default
* Pressed
* Selected (tablet master-detail)
* Disabled
* Loading skeleton (optional)

---

### 4.6 Score Badge (Rounded Square)

**Use:** course grade / evaluation label

**Style**

* Rounded square with tint background
* Centered number/letter
* Semantic mapping recommended:

  * High score: blue tint
  * Passing: green tint
  * Low score: orange tint
  * Special/Exempt: neutral tint

---

### 4.7 Chip (Pill Label)

**Use:** credits, GPA points, tags, small metadata

**Style**

* Small pill
* Tint background + colored text
* Compact typography (caption)

**Rules**

* Chips should never overpower titles.
* Use consistent order (e.g., Credits first, GPA second).

---

### 4.8 Bottom Sheet / Modal

Two standardized types:

**A) Picker Sheet**

* For term selection, filters, small choices
* Compact height
* Tap outside to dismiss

**B) Detail Sheet**

* For course detail, analytics, explanations
* May include charts + metrics + CTA
* Clear primary action at bottom

**Close behavior**

* Tap outside (optional)
* Swipe down (mobile)
* Explicit close button for complex sheets

---

### 4.9 Calendar / Schedule Components

**Views**

* Summary / Day / Week / Month switch (segmented)
* Date strip for week navigation (pill highlight)
* Time grid with subtle lines
* Event blocks with semantic tints

**Event block rules**

* Tint fill, readable label
* Avoid heavy borders
* Minimum block height for tap targets

---

## 5. Interaction & Behavioral Standards

### 5.1 Primary Interaction Flow

* **Summary first, details next**
* Lists are optimized for scanning; details provide depth without cluttering the list

### 5.2 Feedback & Motion

* Feedback must be visible but soft:

  * pressed state: tint darken
  * selection: background + text change
* Animations should be short and subtle:

  * 150–250ms
  * ease-out for expansions

### 5.3 Empty / Loading / Error States

**Empty**

* Provide a friendly explanation + next action
* Tablet detail pane: show “Select an item on the left”

**Loading**

* Skeleton placeholders recommended for list + summary

**Error**

* Inline message + retry
* Avoid blocking dialogs unless necessary

---

## 6. Accessibility & Usability Rules

### 6.1 Tap Targets

* Minimum target size: **44x44**
* Icon buttons must respect this even if visually smaller

### 6.2 Contrast

* Ensure text on tint backgrounds remains readable
* Secondary text must still be legible on matte backgrounds

### 6.3 Icon-Only Actions

Icon-only controls can reduce discoverability.

* Provide tooltip (desktop) or long-press hint (mobile)
* Consider one labeled action on key screens (e.g., “Add”)

---

## 7. Design Tokens (Implementation-Ready)

### 7.1 Color Tokens (semantic)

* `color.bg` (matte page background)
* `color.surface` (card background)
* `color.primary`
* `color.text.primary`
* `color.text.secondary`
* `color.text.tertiary`
* `color.border.subtle`
* `color.semantic.success`
* `color.semantic.warning`
* `color.semantic.info`
* `color.semantic.*.tint` (tint backgrounds)

### 7.2 Radius Tokens

* `radius.card = 16–20`
* `radius.item = 12–16`
* `radius.badge = 10–12`
* `radius.pill = 999`

### 7.3 Spacing Tokens

* `space.4, space.8, space.12, space.16, space.20, space.24`

### 7.4 Elevation Tokens (subtle)

* `elevation.0` (flat)
* `elevation.1` (card)
* `elevation.2` (modal/sheet)
* `elevation.3` (floating menu)

### 7.5 Typography Tokens (semantic)

* `type.title.large`
* `type.title.section`
* `type.body.primary`
* `type.body.secondary`
* `type.caption`

---

## 8. Page Templates (Recommended)

### 8.1 Grades Page Template

* Header (Large Title + icon actions)
* Segmented: Overall / Research / Composite
* Summary Card: Credits, Rank, GPA, Passed
* List: course items (badge + title + subtitle + chips)
* Detail: sheet (phone) / right panel (tablet)

### 8.2 Schedule & Tasks Template

* Header (Large Title + icon actions)
* Segmented: Summary / Day / Week / Month
* Date strip (week)
* Time grid (day/week)
* Task list grouped by Today / Upcoming / Unscheduled

---

## 9. Governance: How to Keep Consistency

* All new UI must be built from the component list above.
* New components require:

  1. purpose + anatomy
  2. states
  3. tokens used
  4. responsive behavior

---

## Appendix A: Component Inventory Checklist

* [ ] Page Header (Large Title)
* [ ] Icon Button (circular)
* [ ] Segmented Control (pill)
* [ ] Card (default/summary/info)
* [ ] List Item (3-column)
* [ ] Score Badge
* [ ] Chip
* [ ] Bottom Sheet (picker/detail)
* [ ] Calendar Grid + Event Block
* [ ] Empty/Loading/Error patterns