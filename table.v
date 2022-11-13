module mui

import gg
import gx

pub fn add_table(mut app &Window, table [][]string, id string, x IntOrString, y IntOrString, w IntOrString, h IntOrString, hi bool, bg gx.Color, bfg gx.Color, fg gx.Color, frame string, zindex int){
    app.objects << {
        "type": WindowData{str:"table"},
		"table":WindowData{tbl:table},
        "id":   WindowData{str:id},
		"in":   WindowData{str:frame},
        "z_ind":WindowData{num:zindex},
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
    }
}

[unsafe]
fn draw_table(app &Window, object map[string]WindowData){
	unsafe{

		table:=object["table"].tbl
		table_y:=table.len
		table_x:=table[0].len
		per_cell:=[object["w"].num/table_x,object["h"].num/table_y]

		app.gg.draw_rect_filled(object["x"].num, object["y"].num, per_cell[0]*table_x, per_cell[1]*table_y, object["bg"].clr)

		for wy,y_ in table{
			for wx,x_ in y_{
				app.gg.draw_rect_empty(object["x"].num+per_cell[0]*wx, object["y"].num+per_cell[1]*wy, per_cell[0], per_cell[1], object["bfg"].clr)
				app.gg.draw_text(object["x"].num+per_cell[0]*wx+per_cell[0]/2, object["y"].num+per_cell[1]*wy+per_cell[1]/2, x_, gx.TextCfg{
					color: object["fg"].clr
					size: 20
					align: .center
					vertical_align: .middle
				})
			}
		}
	}
}
