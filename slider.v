module mui

import gg
import gx

pub fn add_slider(mut app &Window, val int, min int, max int, step int, id string, x string|int, y string|int, w string|int, h string|int, vert bool, hi bool, bg gx.Color,  bfg gx.Color, fg gx.Color, fnclk OnEvent, fnchg OnEvent, fnucl OnEvent, value_map ValueMap){
	    app.objects << {
        "type": WindowData{str:"slider"},
        "id":   WindowData{str:id},
        "val":  WindowData{num:val-(val-min)%step},
        "vlMin":WindowData{num:min},
        "vlMax":WindowData{num:max-(max-min)%step},
        "vlMap":WindowData{vmp:value_map},
        "vStep":WindowData{num:step},
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
        "bfg":  WindowData{clr:bfg},
        "fg":   WindowData{clr:fg},
        "click":WindowData{bol:false},
        "vert": WindowData{bol:vert},
        "fnclk":WindowData{fun:fnclk},
        "fnchg":WindowData{fun:fnchg},
        "fnucl":WindowData{fun:fnucl}
    }
}

[unsafe]
fn draw_slider(app &Window, object map[string]WindowData){
	unsafe{
        if !object["vert"].bol {
            app.gg.draw_rect_filled(object["x"].num, object["y"].num, object["w"].num, object["h"].num, object["bg"].clr)
            width_of_thumb:=int(f32(object["w"].num)/(f32(object["vlMax"].num-object["vlMin"].num)/object["vStep"].num)*(f32(object["val"].num-object["vlMin"].num)/object["vStep"].num))-3
            app.gg.draw_rect_filled(object["x"].num+width_of_thumb, object["y"].num, 6, object["h"].num, object["bfg"].clr)
            app.gg.draw_text(object["x"].num+object["w"].num+6, object["y"].num+object["h"].num/2, object["vlMap"].vmp(object["val"].num), gx.TextCfg{
                color: object["fg"].clr
                size: 20
                align: .left
                vertical_align: .middle
            })
        } else {
            app.gg.draw_rect_filled(object["x"].num, object["y"].num, object["w"].num, object["h"].num, object["bg"].clr)
            height_of_thumb:=int(f32(object["h"].num)/(f32(object["vlMax"].num-object["vlMin"].num)/object["vStep"].num)*(f32(object["val"].num-object["vlMin"].num)/object["vStep"].num))-3
            app.gg.draw_rect_filled(object["x"].num, object["y"].num+height_of_thumb, object["w"].num, 6, object["bfg"].clr)
            app.gg.draw_text(object["x"].num+object["w"].num/2, object["y"].num+object["h"].num+6, object["vlMap"].vmp(object["val"].num), gx.TextCfg{
                color: object["fg"].clr
                size: 20
                align: .center
                vertical_align: .top
            })
        }
	}
}
