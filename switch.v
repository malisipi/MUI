module mui

import gg
import gx

pub fn add_switch(mut app &Window, text string, id string, x string|int, y string|int, w string|int, h string|int, checked bool, hi bool, bg gx.Color, bfg gx.Color, fg gx.Color, fnchg OnEvent, frame string, zindex int){
    app.objects << {
        "type": WindowData{str:"switch"},
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
        "bg":   WindowData{clr:bg},
        "bfg":	WindowData{clr:bfg},
        "fg":   WindowData{clr:fg},
        "c":	WindowData{bol:checked}
        "hi":	WindowData{bol:hi}
        "fnchg":WindowData{fun:fnchg}
    }
}

[unsafe]
fn draw_switch(app &Window, object map[string]WindowData){
	unsafe{
		app.gg.draw_rect_filled(object["x"].num, object["y"].num, object["w"].num, object["h"].num, object["bg"].clr)
		if !object["c"].bol{
			app.gg.draw_rect_filled(object["x"].num+2, object["y"].num+2, (object["w"].num-4)/2, object["h"].num-4, object["bfg"].clr)
		} else {
			app.gg.draw_rect_filled(object["x"].num+2+(object["w"].num-4)/2, object["y"].num+2, (object["w"].num-4)/2, object["h"].num-4, object["bfg"].clr)
		}
		app.gg.draw_text(object["x"].num+object["w"].num+4, object["y"].num+object["h"].num/2, object["text"].str, gx.TextCfg{
			color: object["fg"].clr
			size: 20
			align: .left
			vertical_align: .middle
		})
	}
}
