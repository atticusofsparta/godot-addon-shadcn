#!/usr/bin/env python3
"""Generate one MDX page per component under website/content/docs/components/.
Each page embeds the live demo (?c=<id>) and a usage snippet."""
import os

BASE = "/godot-addon-shadcn/example/index.html"
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "website", "content", "docs", "components")

# (id, title, description, gdscript usage)
C = [
("button", "Button", "Clickable button with variants and sizes.",
 'var b := ShadcnButton.new()\nb.variant = ShadcnButton.Variant.PRIMARY  # PRIMARY/SECONDARY/DESTRUCTIVE/OUTLINE/GHOST/LINK\nb.button_size = ShadcnButton.Size.DEFAULT\nb.text = "Continue"\nadd_child(b)'),
("badge", "Badge", "Small status label.",
 'var bd := ShadcnBadge.new()\nbd.variant = ShadcnBadge.Variant.SECONDARY\nbd.text = "New"'),
("button-group", "Button Group", "Joins related buttons with a shared border.",
 'var g := ShadcnButtonGroup.new()\nfor t in ["Left", "Center", "Right"]:\n\tvar b := Button.new(); b.text = t; g.add_child(b)\nadd_child(g)'),
("toggle", "Toggle", "Two-state button; on = accent fill.",
 'var t := ShadcnToggle.new()\nt.variant = ShadcnToggle.Variant.DEFAULT\nt.text = "Bold"'),
("toggle-group", "Toggle Group", "A row of toggles; `single` = radio behavior.",
 'var g := ShadcnToggleGroup.new()\ng.single = true\nfor x in ["B", "I", "U"]:\n\tvar t := ShadcnToggle.new(); t.text = x; g.add_child(t)'),
("kbd", "Kbd", "Keyboard key cap.",
 'var k := ShadcnKbd.new()\nk.text = "Ctrl"'),
("input", "Input", "Single-line text input (themed LineEdit).",
 'var le := LineEdit.new()\nle.placeholder_text = "Email"'),
("textarea", "Textarea", "Multi-line text input (themed TextEdit).",
 'var te := TextEdit.new()\nte.placeholder_text = "Message"'),
("input-group", "Input Group", "Input with leading/trailing addons.",
 'var ig := ShadcnInputGroup.new()\nig.placeholder = "Search…"\nvar icon := Label.new(); icon.text = "🔍"\nig.add_prefix(icon)\nprint(ig.line_edit.text)'),
("input-otp", "Input OTP", "One-time-code boxes with auto-advance.",
 'var otp := ShadcnInputOTP.new()\notp.length = 6\notp.completed.connect(func(code): print(code))'),
("field", "Field", "Label + control slot + helper/error text.",
 'var f := ShadcnField.new()\nf.label = "Email"\nf.description = "We never share it."\nadd_child(f)\nf.content.add_child(LineEdit.new())'),
("select", "Select", "Dropdown of options (themed OptionButton).",
 'var opt := OptionButton.new()\nopt.add_item("Light"); opt.add_item("Dark")'),
("combobox", "Combobox", "Searchable select.",
 'var cb := ShadcnCombobox.new()\ncb.items = ["Next.js", "Nuxt", "Godot"]\ncb.selected.connect(func(v): print(v))'),
("checkbox", "Checkbox", "Toggle a checked state (accent-aware icon).",
 'var c := CheckBox.new()\nc.text = "Accept terms"'),
("radio-group", "Radio Group", "Mutually exclusive checkboxes via a ButtonGroup.",
 'var group := ButtonGroup.new()\nfor x in ["A", "B"]:\n\tvar r := CheckBox.new(); r.text = x; r.button_group = group'),
("switch", "Switch", "Animated pill toggle.",
 'var s := ShadcnSwitch.new()\ns.switched.connect(func(on): print(on))'),
("slider", "Slider", "Pick a value in a range (themed HSlider).",
 'var sl := HSlider.new()\nsl.value = 40'),
("calendar", "Calendar", "Month grid with date selection.",
 'var cal := ShadcnCalendar.new()\ncal.date_selected.connect(func(y, m, d): print(y, m, d))'),
("date-picker", "Date Picker", "Button that opens a calendar popover.",
 'var p := ShadcnDatePicker.new()\np.date_selected.connect(func(y, m, d): print(y, m, d))'),
("alert", "Alert", "Callout for user attention.",
 'var a := ShadcnAlert.new()\na.variant = ShadcnAlert.Variant.DESTRUCTIVE\na.title = "Error"\na.description = "Your session expired."'),
("toast", "Toast", "Temporary notification (shadcn Sonner).",
 'ShadcnToast.notify(self, "Event created", "Sunday at 9:00 AM.")\n# or via the autoload:\nShadcnToasts.push("Saved", "Your changes were saved.")'),
("progress", "Progress", "Completion indicator (themed ProgressBar).",
 'var pb := ProgressBar.new()\npb.value = 60'),
("spinner", "Spinner", "Indeterminate loading spinner.",
 'var sp := ShadcnSpinner.new()\nsp.diameter = 28'),
("skeleton", "Skeleton", "Pulsing loading placeholder.",
 'var sk := ShadcnSkeleton.new()\nsk.custom_minimum_size = Vector2(180, 24)'),
("empty", "Empty", "Empty-state placeholder with actions.",
 'var e := ShadcnEmpty.new()\ne.title = "No projects"\ne.description = "Create one to get started."\nadd_child(e)\nvar b := ShadcnButton.new(); b.text = "New"; e.actions.add_child(b)'),
("avatar", "Avatar", "Circular image with initials fallback.",
 'var av := ShadcnAvatar.new()\nav.fallback = "CN"\nav.diameter = 40'),
("card", "Card", "Bordered surface with title/description.",
 'var card := ShadcnCard.new()\nvar box := VBoxContainer.new(); card.add_child(box)\nvar t := ShadcnCardTitle.new(); t.text = "Create project"\nbox.add_child(t)'),
("item", "Item", "Media + title + description + actions row.",
 'var it := ShadcnItem.new()\nit.icon_text = "📁"\nit.title = "Documents"\nit.description = "12 files"'),
("accordion", "Accordion", "Collapsible titled section.",
 'var a := ShadcnAccordionItem.new()\na.title = "Is it accessible?"\na.body = "Yes."\na.expanded = true'),
("tabs", "Tabs", "Layered content panels (themed TabContainer).",
 'var tabs := TabContainer.new()\nvar page := VBoxContainer.new(); page.name = "Account"\ntabs.add_child(page)'),
("breadcrumb", "Breadcrumb", "Navigation trail.",
 'var bc := ShadcnBreadcrumb.new()\nbc.items = ["Home", "Components", "Breadcrumb"]'),
("pagination", "Pagination", "Page navigation.",
 'var pg := ShadcnPagination.new()\npg.page_count = 10\npg.page_changed.connect(func(p): print(p))'),
("sidebar", "Sidebar", "Collapsible side panel.",
 'var sb := ShadcnSidebar.new()\nadd_child(sb)\nsb.content.add_child(my_nav)\nsb.toggle()'),
("menubar", "Menubar", "Desktop-style menu bar (themed MenuBar).",
 'var menu := MenuBar.new()\nvar file := PopupMenu.new(); file.name = "File"; file.add_item("New")\nmenu.add_child(file)'),
("command", "Command", "Command palette (search + actions).",
 'var cmd := ShadcnCommand.new()\ncmd.add_item("new", "New File")\ncmd.selected.connect(func(id): print(id))'),
("carousel", "Carousel", "Pager with prev/next and dots.",
 'var car := ShadcnCarousel.new()\ncar.add_slide(my_slide)\nadd_child(car)'),
("separator", "Separator", "Visual divider (themed HSeparator/VSeparator).",
 'var sep := HSeparator.new()'),
("table", "Table", "Simple table (themed Tree).",
 'var tree := Tree.new()\ntree.columns = 3\ntree.column_titles_visible = true'),
("data-table", "Data Table", "Filterable, sortable table.",
 'var dt := ShadcnDataTable.new()\ndt.set_columns(["Invoice", "Status", "Amount"])\ndt.add_row(["INV001", "Paid", "$250"])'),
("chart", "Chart", "Line / area / bar / pie / donut / radar / radial.",
 'var c := ShadcnChart.new()\nc.kind = ShadcnChart.Kind.AREA\nc.gradient = true\nc.x_labels = ["Jan", "Feb", "Mar"]\nc.add_series([186, 305, 237], "Desktop")'),
("dialog", "Dialog", "Modal dialog.",
 'var d := ShadcnDialog.new()\nd.title = "Edit profile"\nadd_child(d)\nd.open()'),
("alert-dialog", "Alert Dialog", "Confirmation dialog.",
 'var a := ShadcnAlertDialog.new()\na.title = "Are you sure?"\na.destructive = true\na.confirmed.connect(func(): pass)\nadd_child(a); a.open()'),
("sheet", "Sheet", "Slide-out panel from any edge.",
 'var s := ShadcnSheet.new()\ns.side = ShadcnSheet.SheetSide.RIGHT\ns.title = "Settings"\nadd_child(s); s.open()'),
("drawer", "Drawer", "Bottom drawer.",
 'var dr := ShadcnDrawer.new()\ndr.title = "Move goal"\nadd_child(dr); dr.open()'),
("popover", "Popover", "Rich content in a floating panel.",
 'var pop := PopupPanel.new()\npop.wrap_controls = true\npop.add_child(content)\nadd_child(pop)\npop.popup(Rect2i(btn.get_screen_position() + Vector2(0, btn.size.y + 6), Vector2i.ZERO))'),
("dropdown", "Dropdown Menu", "Menu triggered by a button (themed MenuButton).",
 'var mb := MenuButton.new()\nmb.get_popup().add_item("Profile")'),
("context-menu", "Context Menu", "Right-click menu (themed PopupMenu).",
 'var pm := PopupMenu.new()\npm.add_item("Cut"); pm.add_item("Copy")'),
("tooltip", "Tooltip", "Hover tooltip that opens above the trigger.",
 'var tip := ShadcnTooltip.new()\ntip.text = "Add to library"\nmy_button.add_child(tip)'),
("hover-card", "Hover Card", "Rich content shown on hover.",
 'var hc := ShadcnHoverCard.new()\nmy_link.add_child(hc)\n# populate hc.body'),
("label", "Label", "Accessible text label (themed Label).",
 'var l := Label.new()\nl.text = "Email"'),
]

ORDER = [c[0] for c in C]


def page(cid, title, desc, code):
    return f'''---
title: {title}
description: {desc}
---

{desc}

<ExampleFrame src="{BASE}?c={cid}" />

Use the panel on the left of the demo to customize this component live, and the
toolbar to switch base color, accent and light/dark.

## Usage

```gdscript
{code}
```
'''


def main():
    os.makedirs(OUT, exist_ok=True)
    # remove old grouped pages
    for old in ["buttons", "inputs", "feedback", "overlays", "navigation", "data-display", "charts"]:
        p = os.path.join(OUT, old + ".mdx")
        if os.path.exists(p):
            os.remove(p)
    for cid, title, desc, code in C:
        with open(os.path.join(OUT, cid + ".mdx"), "w") as f:
            f.write(page(cid, title, desc, code))
    meta = '{\n  "title": "Components",\n  "pages": [\n    "index",\n'
    meta += ",\n".join('    "%s"' % c for c in ORDER)
    meta += "\n  ]\n}\n"
    with open(os.path.join(OUT, "meta.json"), "w") as f:
        f.write(meta)
    print("wrote %d component pages" % len(C))


if __name__ == "__main__":
    main()
