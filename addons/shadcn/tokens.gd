@tool
class_name ShadcnTokens
extends RefCounted
## Active shadcn design tokens. Palettes live in the generated palettes.gd
## (parsed from shadcn/ui themes.ts). Components read colors via ShadcnTokens.c().
##
## Switch the whole UI at runtime with:
##   ShadcnTokens.apply(root_control, "zinc", "blue", true)  # base, accent, dark

static var base: String = "neutral"
static var accent: String = ""        # "" = use the base color's own primary
static var dark: bool = true

const RADIUS := 10
const RADIUS_MD := 8
const RADIUS_SM := 6
const FONT_SM := 14
const FONT_XS := 12

const _FONT_PATH := "res://addons/shadcn/fonts/Inter-Regular.woff2"
static var _font: Font


## Bundled Inter font (used by custom-drawn nodes so their text matches the
## themed controls and renders glyphs on web). Falls back to the engine font.
static func font() -> Font:
	if _font == null and ResourceLoader.exists(_FONT_PATH):
		_font = load(_FONT_PATH)
	return _font if _font else ThemeDB.fallback_font


## Resolved palette (base + accent override) for the active mode.
static func palette() -> Dictionary:
	return ShadcnTheme.resolve(base, accent, dark)


## Fetch a token colour by name for the active scheme.
static func c(name: String) -> Color:
	return palette().get(name, Color.MAGENTA)


## Blend two colours (t in 0..1).
static func mix(a: Color, b: Color, t: float) -> Color:
	return a.lerp(b, t)


## Apply a scheme to a Control subtree: rebuilds + assigns the theme and tells
## every shadcn component to restyle itself. accent "" means "use the base
## color's own primary".
static func apply(root: Control, p_base := "neutral", p_accent := "", p_dark := true) -> void:
	base = p_base
	accent = p_accent
	dark = p_dark
	root.theme = ShadcnTheme.build(base, accent, dark)
	if root.is_inside_tree():
		root.get_tree().call_group("shadcn_refresh", "refresh")
