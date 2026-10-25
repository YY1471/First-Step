extends RefCounted
## 共用 UI 配色与控件工厂：主菜单、暂停菜单、选项面板共用。
## 引用方式：const UiTheme = preload("res://scripts/ui_theme.gd")

const TEXT := Color("#cfe8d4")
const TEXT_BRIGHT := Color("#eafff0")
const ACCENT := Color("#4fde8e")
const BORDER := Color("#2a6b46")
const PANEL_BG := Color("#0d1b14")
const BTN_BG := Color("#10251a")
const BTN_HOVER := Color("#1a3f2c")
const BTN_PRESSED := Color("#0a1a12")


static func label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


static func button(text: String, handler: Callable, size := Vector2(230, 40)) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = size
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", TEXT)
	btn.add_theme_color_override("font_hover_color", TEXT_BRIGHT)
	btn.add_theme_color_override("font_pressed_color", TEXT_BRIGHT)
	btn.add_theme_color_override("font_focus_color", TEXT_BRIGHT)
	btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.55, 0.5, 0.6))
	btn.add_theme_stylebox_override("normal", button_style(BTN_BG, BORDER))
	btn.add_theme_stylebox_override("hover", button_style(BTN_HOVER, ACCENT))
	btn.add_theme_stylebox_override("pressed", button_style(BTN_PRESSED, ACCENT))
	btn.add_theme_stylebox_override("focus", button_style(BTN_HOVER, ACCENT))
	btn.add_theme_stylebox_override("disabled", button_style(Color(0.07, 0.11, 0.09, 0.5), Color(0.16, 0.22, 0.18)))
	btn.pressed.connect(handler)
	return btn


static func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PANEL_BG, 0.94)
	style.border_color = BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 26.0
	style.content_margin_right = 26.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	return style


static func button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	return style
