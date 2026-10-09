---
name: The Curbside Ledger
description: NYC taxi business KPIs set as a monthly business-page broadsheet, newsprint and ink.
colors:
  ink: "#191917"
  ink-2: "#45443f"
  ink-3: "#6b6960"
  rule-strong: "#8f8b80"
  rule: "#c9c6bb"
  ground: "#e9e7df"
  paper: "#f6f5f0"
  taxi-yellow: "#f3c613"
  taxi-wash: "rgba(243,198,19,.38)"
  ink-dark: "#eeece4"
  ink-2-dark: "#c4c1b6"
  ink-3-dark: "#9a978c"
  rule-strong-dark: "#6a675d"
  rule-dark: "#36352f"
  ground-dark: "#141413"
  paper-dark: "#1c1c1a"
  taxi-yellow-dark: "#e8b923"
  taxi-wash-dark: "rgba(232,185,35,.28)"
typography:
  display:
    fontFamily: "Newsreader, Georgia, 'Times New Roman', serif"
    fontSize: "clamp(38px, 7.2vw, 86px)"
    fontWeight: 800
    lineHeight: 0.95
    letterSpacing: "-0.025em"
    fontVariation: "'opsz' 72"
  headline:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "clamp(30px, 4.6vw, 54px)"
    fontWeight: 700
    lineHeight: 1.03
    letterSpacing: "-0.02em"
    fontVariation: "'opsz' 60"
  title:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.01em"
  deck:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "clamp(18px, 1.9vw, 22px)"
    fontWeight: 400
    lineHeight: 1.35
  body:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.5
    fontFeature: "tnum, lnum"
  caption:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Libre Franklin, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "0.05em"
  meta:
    fontFamily: "Libre Franklin, system-ui, sans-serif"
    fontSize: "12.5px"
    fontWeight: 500
    lineHeight: 1.35
rounded:
  none: "0"
spacing:
  cell: "6px"
  sm: "8px"
  md: "16px"
  item: "22px"
  gutter: "24px"
  sheet: "clamp(16px, 3.4vw, 44px)"
components:
  verdict-off:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    padding: "2px 5px"
  verdict-watch:
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    padding: "1px 4px"
  verdict-on:
    textColor: "{colors.ink-2}"
    typography: "{typography.label}"
  stock-row-open:
    backgroundColor: "{colors.taxi-wash}"
    textColor: "{colors.ink}"
    padding: "7px 6px"
  item-head:
    textColor: "{colors.ink}"
    typography: "{typography.title}"
    padding: "8px 0 0"
  edition-picker:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.none}"
    padding: "4px 26px 4px 8px"
  theme-button:
    textColor: "{colors.ink-2}"
    rounded: "{rounded.none}"
    padding: "4px 10px"
---

# Design System: The Curbside Ledger

## Overview

**Creative North Star: "The Business Section, One Edition a Month"**

The system is a newspaper business page printed from data. A centred masthead with ears, a double rule and a dateline holding the edition picker; a headline and italic deck written from the month's numbers; a stock-table scorecard beside the lead chart; shorter news items in ruled columns; the press strip at the foot. Structure comes from rules of graded weight, never from boxes, cards or fills. Density is broadsheet density: small sans furniture, serif text, figures that line up.

Colour is newsprint and ink. Taxi yellow is the only hue and it never carries text or meaning by itself: it is a highlighter wash laid behind ink, marking what the reader has selected or which edition is in view. Verdicts are carried by words and ink weight. The page refuses the KPI-tile grid.

**Key Characteristics:**
- Newsprint paper sheet on a slightly darker ground, flat, square-cornered.
- Rules do the structural work: 4px double under the masthead, 3px ink between sections, 1px ink over heads, 1px hairline column and row rules.
- Newsreader serif for everything read; Libre Franklin only for labels, table heads, axes and meta.
- Tabular lining figures everywhere.
- Taxi yellow as wash only; charts and bars are ink.

## Colors

A warm newsprint-and-ink grey scale with one highlighter. Dark theme inverts paper and ink (the `-dark` tokens) and keeps the same roles; it follows `prefers-color-scheme` and can be forced from the footer.

### Primary
- **Press Ink** (ink): all text, rules over heads, chart lines, ink bars, heatmap cells, the reversed Off track stamp.

### Secondary
- **Taxi Highlighter** (taxi-wash, from taxi-yellow): hover and open state of scorecard rows, the open trend row, the edition band on the daily chart, `mark` text highlights (wash spans 12% to 88% of line height). Full-strength taxi-yellow is a source value, not a fill for marks or text.

### Neutral
- **Second Ink** (ink-2): body copy, deck, table heads, On track verdicts.
- **Third Ink** (ink-3): categories under measure names, axes, notes, bylines, flat changes, "no target".
- **Column Rule** (rule-strong): vertical column rules between sections and items, theme button border.
- **Hairline** (rule): table row lines, chart gridlines, press-strip dividers.
- **Newsprint** (paper): the sheet. **Ground** (ground): the margin outside the 1280px sheet.

### Named Rules
**The Highlighter Rule.** Yellow appears only as a translucent wash behind ink, marking selection or the current edition. Never as text colour, bar fill, border, or status signal.

**The Words-Not-Colour Rule.** Status is a word set in ink: reversed for Off track, boxed for Watch, plain for On track. Changes carry ▲ / ▼ plus a number; flat changes go grey.

**The No-Hue Rule.** No blue, orange, green, plum, lime or rust anywhere; those belong to other portfolio projects.

## Typography

**Display Font:** Newsreader (with Georgia, Times New Roman), optical size axis in use
**Body Font:** Newsreader
**Label/Mono Font:** Libre Franklin (with system-ui)

**Character:** A text-face newspaper serif doing headlines, body and figures, with a sober grotesque reserved for the furniture a newspaper sets in sans: table heads, axes, ears, datelines, notes.

### Hierarchy
- **Display** (800, clamp to 86px, 0.95): the masthead title only.
- **Headline** (700, clamp to 54px, 1.03, max 30ch, balanced): the edition headline, written from the data.
- **Deck** (italic 400, clamp to 22px, 1.35, max 62ch, ink-2): one deck under the headline.
- **Title** (700, 24px, 1.15): item heads, set as full sentences from the data, with a 1px ink rule above.
- **Body** (400, 17px, 1.5; 16.5px in items): running text in ink-2. Tables set at 15 to 15.5px serif.
- **Caption** (italic 400, 14px): chart captions under each figure.
- **Label** (Libre Franklin 700, 10.5 to 11px, 0.05em, uppercase): table column heads and press-strip step names only.
- **Meta** (Libre Franklin 500, 11 to 13px): ears, dateline, byline, categories, axes, notes, footer.

The static detector reads clamp() fallbacks as a flat ramp; rendered sizes are 86 / 54 / 24 / 22 / 17px. That exception, and the newspaper column setting flagged as cramped padding, are recorded in `.impeccable/config.json`.

### Named Rules
**The Heads-Are-News Rule.** Every section head is a serif sentence stating the finding ("Manhattan takes 91% of trips"). No kicker or eyebrow labels above heads.

**The Tabular Rule.** All figures are tabular lining numerals so columns of numbers align.

## Layout

One centred sheet, max 1280px, side padding clamp(16px, 3.4vw, 44px). Below the masthead and front, a two-column body (1.12fr / 1fr) with a 24px gutter and a 1px column rule: scorecard left, lead daily chart and hour-of-week heatmap right. Then a four-up row of news items (22px inner padding, ruled left and below), then the five-step press strip between a 3px and a 1px ink rule, then the footer. Responsive: columns stack under 920px (column rule becomes a top rule); items go two-up under 1100px and one-up under 700px; press strip stacks under 900px; the left ear hides under 720px; under 600px the scorecard drops the on-month and target columns and moves the target under the value. Charts are SVG sized to their column and redrawn on resize.

## Elevation & Depth

Flat. No shadows. Depth is the paper sheet against the ground and the weight of the rules. The only inset box-shadow is the scorecard row focus ring (2px ink lines top and bottom).

### Named Rules
**The Printed Page Rule.** Nothing floats. Separation is by rule weight: 4px double, 3px, 1px ink, 1px hairline.

## Shapes

Square corners throughout (0). Rectangles only: verdict stamps, the edition select, the theme button, heatmap cells, ink bars. The select's chevron is drawn with gradients, not an icon.

## Components

### Masthead
Ears in Libre Franklin meta (left: source; right: pipeline totals), the display title, a 1px ink rule, the dateline with the edition picker, closed by a 4px double ink rule.

### Edition Picker
- **Style:** native select restyled, paper background, 1px ink border, Libre Franklin 700 14px, square, gradient chevron.
- **Behaviour:** changing it re-renders every story for that month.

### Stock-Table Scorecard (signature)
- Columns: Measure (serif 600 name, sans category beneath), value (bold), On month, On year, Target, Verdict. Heads are uppercase sans labels over a 1px ink rule; rows sit on hairlines.
- Changes: ▲ / ▼ at 0.7em before the figure; percent units in points.
- Verdicts: Off track reversed (ink ground, paper text), Watch boxed (1px ink), On track plain ink-2, no target in ink-3 lowercase.
- **Hover / Open:** taxi wash behind the row. **Focus:** 2px ink lines top and bottom.
- **Trend row:** selecting a row opens a washed row beneath it with a 19-month ink line (2px), dashed ink-3 target line, the edition point as an open circle, then the definition and target in serif.

### Lead Chart and Heatmap
Ink polyline (1.1px) of daily trips over hairline gridlines, the current edition as a taxi-wash band, ink triangles for snow days, sans axes. The hour-of-week heatmap is ink cells whose opacity runs 0.06 to 1.0 with volume. Each figure has an italic serif caption.

### News Items
Item head (serif title over a 1px ink rule), then a small table or numbered list. Small tables carry ink bars (9px tall, up to 40px) inline before the figure.

### Press Strip
Five steps (Extract, Load, Validate, Model, Report): uppercase sans step name over a serif sentence, divided by hairlines.

### Theme Button
Libre Franklin 600 12px, no fill, 1px column-rule border, square.

## Do's and Don'ts

### Do:
- **Do** separate with rules of graded weight (4px double, 3px ink, 1px ink, 1px hairline), not boxes.
- **Do** write every head and the headline as a sentence from the data.
- **Do** carry status in words and ink weight: reversed, boxed, plain.
- **Do** use taxi yellow only as a wash behind ink for selection and the current edition.
- **Do** set every figure in tabular lining numerals.

### Don't:
- **Don't** build KPI tiles, cards, rounded corners or shadows.
- **Don't** put kicker or eyebrow labels above heads.
- **Don't** fill bars, lines, text or borders with yellow, or signal status by colour alone.
- **Don't** introduce blue, orange, green, plum, lime or rust.
