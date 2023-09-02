module mui

import malisipi.mfb as gg
import gx

[autofree_bug; manualfree]
pub fn add_button(mut app &Window, text string, id string, x IntOrString, y IntOrString, w IntOrString, h IntOrString, hi bool, bg gx.Color, fg gx.Color, fnclk OnEvent, fnucl OnEvent, icon bool, dialog bool, frame string, zindex int, tSize int){
    widget:={
        "type": WindowData{str:"button"},
        "id":   WindowData{str:id},
        "in":   WindowData{str:frame},
        "z_ind":WindowData{num:zindex},
        "text": WindowData{str:text},
        "x":    WindowData{num:0},
        "y":    WindowData{num:0},
        "w":    WindowData{num:0},
        "h":    WindowData{num:0},
		"x_raw":WindowData{str: match x{ int{ x.str() } string{ x } } },
		"y_raw":WindowData{str: match y{ int{ y.str() } string{ y } } },
		"w_raw":WindowData{str: match w{ int{ w.str() } string{ w } } },
		"h_raw":WindowData{str: match h{ int{ h.str() } string{ h } } },
        "hi":	WindowData{bol:hi},
        "bg":   WindowData{clr:bg},
        "fg":   WindowData{clr:fg},
        "fnclk":WindowData{fun:fnclk},
        "fnucl":WindowData{fun:fnucl},
        "icon": WindowData{bol:icon},
        "tSize":WindowData{num:tSize},
        "tabvw":WindowData{str:""}, // for tabbed view
    }
    if dialog {app.dialog_objects << widget.clone()} else {app.objects << widget.clone()}
}

[unsafe]
fn draw_button(app &Window, object map[string]WindowData){
	unsafe{
		app.gg.draw_rounded_rect_filled(object["x"].num, object["y"].num, object["w"].num, object["h"].num, app.round_corners, object["bg"].clr)
		app.gg.draw_text(object["x"].num+object["w"].num/2, object["y"].num+object["h"].num/2, object["text"].str, gx.TextCfg{
			color: object["fg"].clr
			size: object["tSize"].num
			align: .center
			vertical_align: .middle
			bold: object["icon"].bol
		})
	}
}
