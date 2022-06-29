module mui

import gg

pub fn add_image(mut app &Window, path string, id string, x string|int, y string|int, w string|int, h string|int, hi bool, fun OnEvent){
    app.objects << {
        "type": WindowData{str:"image"},
        "id":   WindowData{str:id},
		"image":WindowData{img:app.gg.create_image(path)}
        "x":    WindowData{num:0},
        "y":    WindowData{num:0},
        "w":    WindowData{num:0},
        "h":    WindowData{num:0},
		"x_raw":WindowData{str: match x{ int{ x.str() } string{ x } } },
		"y_raw":WindowData{str: match y{ int{ y.str() } string{ y } } },
		"w_raw":WindowData{str: match w{ int{ w.str() } string{ w } } },
		"h_raw":WindowData{str: match h{ int{ h.str() } string{ h } } },
        "hi":	WindowData{bol:hi},
        "fn":   WindowData{fun:fun}
    }
}

[unsafe]
fn draw_image(app &Window, object map[string]WindowData){
	unsafe{
		app.gg.draw_image(object["x"].num, object["y"].num, object["w"].num, object["h"].num, object["image"].img)
	}
}
