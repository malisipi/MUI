import malisipi.mui
import json

type IntString = int | string

fn C._vinit(int, &&char)

[export: "mui_v_init"]
fn mui_init(argc int, argv &&char){
	C._vinit(argc, argv)
}

[export: "mui_get_null_object"]
fn mui_get_null_object() &map[string]mui.WindowData {
	return &mui.null_object
}

[export: "mui_create"]
fn mui_create(pconf &char, app_data voidptr) &mui.Window {
	unsafe {
		jconf := json.decode(map[string]IntString, pconf.vstring()) or {println("Crashed -> json") exit(0)}
		mut wconf := mui.WindowConfig{app_data: app_data}
		if jconf["title"].type_name() == "string" { wconf.title = jconf["title"] as string }
		if jconf["width"].type_name() == "int" { wconf.width = jconf["width"] as int }
		if jconf["height"].type_name() == "int" { wconf.height = jconf["height"] as int }
		return mui.create(wconf)
	}
}

[export: "mui_change_object_property"]
fn mui_change_object_property(mut window &mui.Window, object &map[string]mui.WindowData, pconf &char){
	unsafe {
		jconf := json.decode(map[string]string, pconf.vstring()) or {println("Crashed -> json") exit(0)}
		property := jconf["property"]
		value := jconf["value"]
		object[property] = mui.WindowData{str: value}
	}
}

fn mui_widget(_type string, mut window &mui.Window, pconf &char, onclk mui.OnEvent, onchg mui.OnEvent, onucl mui.OnEvent, connected_object &map[string]mui.WindowData){
	unsafe {
		jconf := json.decode(map[string]IntString, pconf.vstring()) or {println("Crashed -> json") exit(0)}
		mut wconf := mui.Widget{}

		if jconf["id"].type_name() == "string" { wconf.id = jconf["id"] as string }
		if jconf["x"].type_name() == "string" { wconf.x = jconf["x"] as string }
		if jconf["y"].type_name() == "string" { wconf.y = jconf["y"] as string }
		if jconf["width"].type_name() == "string" { wconf.width = jconf["width"] as string }
		if jconf["height"].type_name() == "string" { wconf.height = jconf["height"] as string }
		if jconf["text"].type_name() == "string" { wconf.text = jconf["text"] as string }
		if jconf["vertical"].type_name() == "string" { wconf.vertical = (jconf["vertical"] as string) == "true" }
		if jconf["icon"].type_name() == "string" { wconf.icon = (jconf["icon"] as string) == "true" }
		if jconf["path"].type_name() == "string" { wconf.path = jconf["path"] as string }
		if jconf["link"].type_name() == "string" { wconf.link = jconf["link"] as string }
		wconf.onclick = onclk
		wconf.onchange = onchg
		wconf.onunclick = onucl
		if _type=="scrollbar" {
			wconf.connected_widget = connected_object
		}

		match _type {
			"button" {
				window.button(wconf)
			} "label" {
				window.label(wconf)
			} "textbox" {
				window.textbox(wconf)
			} "textarea" {
				window.textarea(wconf)
			} "password" {
				window.password(wconf)
			} "scrollbar" {
				window.scrollbar(wconf)
			} "image" {
				window.image(wconf)
			} "link" {
				window.link(wconf)
			} else {
				println(":: Invalid/Unsupported widget type -> ${_type}")
			}
		}

	}
}

[export: "mui_button"]
fn mui_button(mut window &mui.Window, pconf &char, onclk mui.OnEvent){
	mui_widget("button", mut window, pconf, onclk, mui.empty_fn, mui.empty_fn, &mui.null_object)
}

[export: "mui_label"]
fn mui_label(mut window &mui.Window, pconf &char, onclk mui.OnEvent){
	mui_widget("label", mut window, pconf, onclk, mui.empty_fn, mui.empty_fn, &mui.null_object)
}

[export: "mui_textbox"]
fn mui_textbox(mut window &mui.Window, pconf &char, onchg mui.OnEvent){
	mui_widget("textbox", mut window, pconf, mui.empty_fn, onchg, mui.empty_fn, &mui.null_object)
}

[export: "mui_textarea"]
fn mui_textarea(mut window &mui.Window, pconf &char, onchg mui.OnEvent){
	mui_widget("textarea", mut window, pconf, mui.empty_fn, onchg, mui.empty_fn, &mui.null_object)
}

[export: "mui_password"]
fn mui_password(mut window &mui.Window, pconf &char, onchg mui.OnEvent){
	mui_widget("password", mut window, pconf, mui.empty_fn, onchg, mui.empty_fn, &mui.null_object)
}

[export: "mui_link"]
fn mui_link(mut window &mui.Window, pconf &char, onchg mui.OnEvent){
	mui_widget("link", mut window, pconf, mui.empty_fn, onchg, mui.empty_fn, &mui.null_object)
}

[export: "mui_image"]
fn mui_image(mut window &mui.Window, pconf &char, onclk mui.OnEvent){
	mui_widget("image", mut window, pconf, onclk, mui.empty_fn, mui.empty_fn, &mui.null_object)
}

[export: "mui_scrollbar"]
fn mui_scrollbar(mut window &mui.Window, pconf &char, onclk mui.OnEvent, onchg mui.OnEvent, onunclk mui.OnEvent, connected_object &map[string]mui.WindowData){
	mui_widget("scrollbar", mut window, pconf, mui.empty_fn, onchg, mui.empty_fn, connected_object)
}

[export: "mui_get_object_by_id"]
fn mui_get_object_by_id(mut window &mui.Window, id &char) voidptr {
	unsafe {
		return &window.get_object_by_id(id.vstring())[0]
	}
}

pub struct ParsedEventDetails{
pub mut:
	event			&char		// click, value_change, unclick, keypress, files_drop, resize
	trigger			&char		// mouse_left, mouse_right, mouse_middle, keyboard
	value			&char		= c"true"
	target_type		&char		= c"window" //window, menubar, and widget_types
	target_id		&char		= c""
}

[export: "mui_parse_event_details"]
fn mui_parse_event_details(event_details mui.EventDetails) ParsedEventDetails {
	return ParsedEventDetails {
		event: &char(event_details.event.str)
		trigger: &char(event_details.trigger.str)
		value: &char(event_details.value.str)
		target_type: &char(event_details.target_type.str)
		target_id: &char(event_details.target_id.str)
	}
}

[export: "mui_run"]
fn mui_run(mut window &mui.Window){
	window.run()
}

[export: "mui_messagebox"]
fn mui_messagebox(title &char, message &char, _type &char, icon &char) int {
	unsafe {
		return mui.messagebox(
			title.vstring(),
			message.vstring(),
			_type.vstring(),
			icon.vstring()
		)
	}
	return 0
}

[export: "mui_inputbox"]
fn mui_inputbox(title &char, text &char, default_text &char) &char {
	unsafe {
		return &char(mui.inputbox(
			title.vstring(),
			text.vstring(),
			default_text.vstring()
		).str)
	}
	return c""
}

[export: "mui_beep"]
fn mui_beep(){
	mui.beep()
}

[export: "mui_destroy"]
fn mui_destroy(mut window &mui.Window){
	window.destroy()
}
