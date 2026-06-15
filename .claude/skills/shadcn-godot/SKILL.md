---
name: shadcn-godot
description: Use when building or editing Godot 4 UI in a project that has the shadcn-godot addon (addons/shadcn). Covers applying the theme, switching base/accent/light-dark color schemes at runtime, and using the Shadcn* component nodes (Button, Chart, Dialog, Calendar, Combobox, DataTable, Toast, etc.).
---

# shadcn-godot

A shadcn/ui look-and-feel for Godot 4: a `.tres` theme that restyles built-in
controls plus `class_name Shadcn*` nodes for components Godot lacks. Pure
GDScript, no GDExtension.

## When to use this skill

The project contains `addons/shadcn/`. Reach for it whenever you create or
restyle UI: pick a `Shadcn*` node for a shadcn component, lean on the theme for
stock controls, and use `ShadcnTokens` for colors instead of hardcoding.

## Applying the theme

Set a bundled theme on the root `Control` (themes cascade to children):

```gdscript
theme = load("res://addons/shadcn/themes/shadcn_dark.tres")   # neutral dark
# or any base × mode: shadcn_<base>_<dark|light>.tres
```

Build one in code for any base + accent + mode:

```gdscript
$Root.theme = ShadcnTheme.build("zinc", "blue", true)  # base, accent, dark
```

## Switching scheme at runtime (theme + components together)

`ShadcnTokens.apply()` rebuilds the theme, assigns it, and refreshes every
custom node (group `shadcn_refresh`) so the whole UI recolors at once:

```gdscript
ShadcnTokens.apply($Root, "stone", "rose", false)  # (root, base, accent, dark)
ShadcnTokens.apply($Root, "neutral", "", true)     # accent "" = base's own primary
```

Bases: `neutral stone zinc mauve olive mist taupe`.
Accents: `amber blue cyan emerald fuchsia green indigo lime orange pink purple
red rose sky teal violet yellow`.

## Reading colors

Never hardcode hex. Use the active palette:

```gdscript
ShadcnTokens.c("primary")            # accent-aware
ShadcnTokens.c("muted_foreground")
ShadcnTokens.c("destructive")
ShadcnTokens.RADIUS_MD               # 8     RADIUS=10  RADIUS_SM=6
ShadcnTokens.FONT_SM                 # 14    FONT_XS=12
ShadcnStyle.flat(bg, radius, border, border_width, Vector4(l,t,r,b))  # StyleBoxFlat
ShadcnStyle.ring(color, width, radius)                                # focus ring
```

## Components

Every node has a `class_name`, so it shows in *Create Node* and works in code.

**Buttons/toggles:** `ShadcnButton` (`variant`: Primary/Secondary/Destructive/
Outline/Ghost/Link, `button_size`: Default/SM/LG/Icon), `ShadcnBadge`,
`ShadcnToggle`, `ShadcnToggleGroup` (`single` = radio), `ShadcnButtonGroup`,
`ShadcnKbd`.

**Inputs:** themed `LineEdit`/`TextEdit`/`OptionButton`/`CheckBox`/`CheckButton`/
`HSlider`; `ShadcnField` (label + `content` slot + error), `ShadcnInputGroup`
(`line_edit`, `add_prefix`/`add_suffix`), `ShadcnInputOTP`, `ShadcnCombobox`,
`ShadcnCalendar`, `ShadcnDatePicker`, `ShadcnSwitch`.

**Feedback:** `ShadcnAlert`, `ShadcnToast` (`ShadcnToast.notify(self, title, desc)`
or autoload `ShadcnToasts.push(...)`), `ShadcnSpinner`, `ShadcnSkeleton`,
themed `ProgressBar`, `ShadcnEmpty`.

**Overlays** (`CanvasLayer`; add to tree then `open()`/`close()`):
`ShadcnDialog` (`body`/`footer`), `ShadcnAlertDialog` (`confirmed`/`canceled`,
`destructive`), `ShadcnSheet` (`side`), `ShadcnDrawer`, `ShadcnTooltip` (child of
any Control, opens above), `ShadcnHoverCard`. Popover/dropdown/context menu =
themed `PopupPanel`/`PopupMenu`/`MenuButton`.

**Navigation/layout:** `ShadcnAccordionItem`, `ShadcnBreadcrumb`,
`ShadcnPagination`, `ShadcnSidebar` (`content`, `toggle()`), `ShadcnCommand`
(`add_item(id,label)`, `selected`), `ShadcnCarousel` (`add_slide`),
`ShadcnCard` (+ `ShadcnCardTitle`/`ShadcnCardDescription`), themed `TabContainer`.

**Data:** `ShadcnAvatar`, `ShadcnItem`, themed `Tree`/`ItemList`,
`ShadcnDataTable` (`set_columns`/`add_row`, click-to-sort + filter),
`ShadcnChart`.

### Charts

One node, many variants:

```gdscript
var c := ShadcnChart.new()
c.kind = ShadcnChart.Kind.AREA   # LINE AREA BAR PIE DONUT RADAR RADIAL
c.curve = ShadcnChart.CurveType.SMOOTH   # LINEAR STEP SMOOTH (line/area)
c.gradient = true                # area fade
# c.horizontal / c.stacked (bar, area); c.show_dots; c.show_values
c.x_labels = ["Jan","Feb","Mar"]
c.add_series([186, 305, 237], "Desktop")
add_child(c)
```

## Gotchas

- **Slots built in `_ready` are null until the node enters the tree.** For
  `ShadcnField.content`, `ShadcnEmpty.actions`, `ShadcnItem.actions`,
  `ShadcnDialog.body`/`footer`, etc., `add_child(node)` first, *then* populate
  the slot.
- **Avoid enum/class name collisions** with Godot globals (e.g. don't name an
  enum `Side` or `Curve`). Keep cross-class references inside function bodies,
  not class-body `const` initializers, to avoid dependency cycles.
- After changing colors, regenerate: `python3 tools/generate_palettes.py` then
  `godot --headless --path . --script res://tools/export_themes.gd`.
- Custom-drawn nodes (chart, switch, spinner, skeleton) read tokens live; the
  themed controls follow the assigned `Theme`. `ShadcnTokens.apply()` covers both.
