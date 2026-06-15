@tool
class_name ShadcnButton
extends Button
## shadcn Button with all variants and sizes. Styles itself at runtime, so it
## looks correct even without the shadcn theme applied.

enum Variant { PRIMARY, SECONDARY, DESTRUCTIVE, OUTLINE, GHOST, LINK }
enum Size { DEFAULT, SM, LG, ICON }

@export var variant: Variant = Variant.PRIMARY:
	set(v): variant = v; _apply()
@export var button_size: Size = Size.DEFAULT:
	set(v): button_size = v; _apply()


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_apply()


func refresh() -> void:
	_apply()


func _get_pad() -> Vector4:
	match button_size:
		Size.SM: return Vector4(12, 6, 12, 6)
		Size.LG: return Vector4(20, 10, 20, 10)
		Size.ICON: return Vector4(8, 8, 8, 8)
		_: return Vector4(16, 9, 16, 9)


func _apply() -> void:
	if not is_inside_tree() and not Engine.is_editor_hint():
		return
	var T := ShadcnTokens
	var pad := _get_pad()
	var radius := T.RADIUS_MD
	var bg: Color
	var bg_hover: Color
	var fg: Color
	var border: Variant = null
	var bw := 0

	match variant:
		Variant.SECONDARY:
			bg = T.c("secondary"); bg_hover = T.mix(bg, T.c("foreground"), 0.05); fg = T.c("secondary_foreground")
		Variant.DESTRUCTIVE:
			bg = T.c("destructive"); bg_hover = T.mix(bg, T.c("background"), 0.10); fg = T.c("destructive_foreground")
		Variant.OUTLINE:
			bg = T.c("background"); bg_hover = T.c("accent"); fg = T.c("foreground")
			border = T.c("input"); bw = 1
		Variant.GHOST:
			bg = Color(0, 0, 0, 0); bg_hover = T.c("accent"); fg = T.c("foreground")
		Variant.LINK:
			bg = Color(0, 0, 0, 0); bg_hover = Color(0, 0, 0, 0); fg = T.c("primary")
		_:  # PRIMARY
			bg = T.c("primary"); bg_hover = T.mix(bg, T.c("background"), 0.10); fg = T.c("primary_foreground")

	var normal := ShadcnStyle.flat(bg if bg.a > 0 else null, radius, border, bw, pad)
	var hover := ShadcnStyle.flat(bg_hover if bg_hover.a > 0 else null, radius, border, bw, pad)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", hover)
	add_theme_stylebox_override("hover_pressed", hover)  # toggle-mode checked + hover
	add_theme_stylebox_override("disabled", normal)
	add_theme_stylebox_override("focus", ShadcnStyle.ring(T.c("ring"), 2, radius))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		add_theme_color_override(c, fg)
	add_theme_color_override("font_disabled_color", Color(fg.r, fg.g, fg.b, 0.5))
	add_theme_color_override("icon_normal_color", fg)
	add_theme_color_override("icon_hover_color", fg)
	add_theme_constant_override("h_separation", 8)
	add_theme_constant_override("outline_size", 0)
	add_theme_font_size_override("font_size", T.FONT_SM)
	if button_size == Size.ICON:
		custom_minimum_size = Vector2(36, 36)
	if variant == Variant.LINK:
		add_theme_constant_override("underline", 1)
