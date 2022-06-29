module mui

import gg
import math
import os

pub fn create(args &WindowConfig)	 &Window{
    mut app := &Window{
        objects: []
        focus: ""
        color_scheme: create_gx_color_from_color_scheme()
        gg: 0
        app_data: args.app_data
    }

    app.gg = gg.new_context(
		bg_color: app.color_scheme[0]
		frame_fn: frame_fn
		click_fn: click_fn
		keydown_fn: keydown_fn
		user_data: app
		window_title: args.title
		move_fn: move_fn
		unclick_fn: unclick_fn
		font_path: args.font
		width: args.width
		height: args.height
		create_window: true
	)

	return app
}

[unsafe]
fn frame_fn(app &Window) {
	unsafe{
		app.gg.begin()
		mut objects:=app.objects.clone()
		if app.focus!="" { objects << get_object_by_id(app, app.focus) }
		window_size:=app.gg.window_size()
		for object in objects{
			if !object["hi"].bol && object["type"].str!="hidden"{
				points:=calc_points(window_size,object["x_raw"].str,object["y_raw"].str,object["w_raw"].str,object["h_raw"].str)
				for w,attr in ["x","y","w","h"]{
					object[attr]=WindowData{num:points[w]}
				}
				match object["type"].str{
					"rect"{
						draw_rect(app, object)
					}"button"{
						draw_button(app, object)
					}"label"{
						draw_label(app, object)
					}"progress"{
						draw_progress(app, object)
					}"textbox"{
						draw_textbox(app, object)
					}"password"{
						draw_password(app, object)
					}"checkbox"{
						draw_checkbox(app, object)
					}"selectbox"{
						draw_selectbox(app, object)
					}"slider"{
						draw_slider(app, object)
					}"link"{
						draw_link(app, object)
					}"radio"{
						draw_radio(app, object)
					}"group"{
						draw_group(app, object)
					}"image"{
						draw_image(app, object)
					}"table"{
						draw_table(app, object)
					}else {}
				}
			}
		}
		app.gg.end()
	}
}

[unsafe]
fn click_fn(x f32, y f32, mb gg.MouseButton, mut app &Window) {
	unsafe{
		if app.focus!="" {
			mut old_focused_object:=get_object_by_id(app, app.focus)
			app.focus=""
			if old_focused_object["type"].str=="selectbox" {
				total_items:=old_focused_object["list"].str.split("\0").len
				list_x:=old_focused_object["x"].num
				list_y:=old_focused_object["y"].num+old_focused_object["h"].num
				list_height:=total_items*old_focused_object["h"].num
				list_width:=old_focused_object["w"].num
				if list_x<x && list_x+list_width>x {
					if list_y<y && list_y+list_height>y {
						old_focused_object["s"]=WindowData{num:int((y-list_y)/(list_height/total_items))}
						old_focused_object["text"]=WindowData{str:old_focused_object["list"].str.split("\0")[old_focused_object["s"].num]}
						old_focused_object["fnchg"].fun(EventDetails{event:"value_change",trigger:"mouse_left",value:old_focused_object["text"].str,target_type:old_focused_object["type"].str,target_id:old_focused_object["id"].str},mut app, mut app.app_data)
						return
					}
				}
			}
		} else {
			app.focus=""
		}

		if mb==gg.MouseButton.left{
			for mut object in app.objects{
				if !object["hi"].bol && object["type"].str!="rect" && object["type"].str!="group" && object["type"].str!="table"{
					if object["x"].num<x && object["x"].num+object["w"].num>x{
						if object["y"].num<y && object["y"].num+object["h"].num>y{
							if object["type"].str!="rect" {
								app.focus=object["id"].str
							}
							match object["type"].str{
								"button" {
									object["fn"].fun(EventDetails{event:"click",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:true.str()},mut app, mut app.app_data)
								} "checkbox" {
									object["c"]=WindowData{bol:!object["c"].bol}
									object["fnchg"].fun(EventDetails{event:"value_change",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:object["c"].bol.str()},mut app, mut app.app_data)
								} "slider" {
									object["val"]=WindowData{num:math.min(int(math.round(f32(x-object["x"].num)/f32(object["w"].num/((object["vlMax"].num-object["vlMin"].num)/object["vStep"].num))))*object["vStep"].num+object["vlMin"].num,object["vlMax"].num)}
									object["click"]=WindowData{bol:true}
									object["fnclk"].fun(EventDetails{event:"click",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:object["val"].num.str()}, mut app, mut app.app_data)
									object["fnchg"].fun(EventDetails{event:"value_change",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:object["val"].num.str()}, mut app, mut app.app_data)
								} "label"{
									object["fnclk"].fun(EventDetails{event:"click",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:true.str()},mut app, mut app.app_data)
								} "link"{
									object["fnclk"].fun(EventDetails{event:"click",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:true.str()},mut app, mut app.app_data)
									os.open_uri(object["link"].str) or {}
								} "textbox", "password"{
									the_text:=object["text"].str.replace("\0","")
									if the_text.len>0{
										mut split_char:=0
										if object["type"].str=="textbox"{
											split_char=math.min(int(math.round((x-object["x"].num)/((app.gg.text_width(the_text)+2)/the_text.len))),the_text.len)
										} else {
											split_char=math.min(int(math.round((x-object["x"].num)/((app.gg.text_width(object["hc"].str)*the_text.len+2)/the_text.len))),the_text.len)
										}
										object["text"]=WindowData{str:the_text[0..split_char]+"\0"+the_text[split_char..math.min(99999,the_text.len)]}
									} else {
										object["text"]=WindowData{str:"\0"}
									}
								} "radio" {
									group_id:=object["id"].str.split("_")#[0..-1].join("_")
									group:=get_object_by_id(app,group_id)
									which_item:=object["id"].str.replace(group_id+"_","").int()
									radio_list_len:=group["len"].num
									for item in 0..radio_list_len {
										app.get_object_by_id(group_id+"_"+item.str())[0]["c"].bol=item==which_item
									}
									group["s"].num=which_item
									group["fnchg"].fun(EventDetails{event:"value_change",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:which_item.str()},mut app, mut app.app_data)
								} "image" {
									object["fnclk"].fun(EventDetails{event:"click",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:true.str()},mut app, mut app.app_data)
								}else {}
							}
							break
						}
					}
				}
			}
		}
	}
}

[unsafe]
fn move_fn(x f32, y f32, mut app &Window){
	unsafe{
		if !(app.focus==""){
			object:=get_object_by_id(app, app.focus)
			if object["type"].str=="slider"{
				if object["click"].bol {
					object["val"]=WindowData{num:math.min(int(math.round(f32(math.min(math.max(x-object["x"].num,0),object["w"].num))/f32(object["w"].num/((object["vlMax"].num-object["vlMin"].num)/object["vStep"].num))))*object["vStep"].num+object["vlMin"].num,object["vlMax"].num)}
					object["fnchg"].fun(EventDetails{event:"value_change",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str,value:object["val"].num.str()},mut app, mut app.app_data)
				}
			}
		}
	}
}

[unsafe]
fn unclick_fn(x f32, y f32, mb gg.MouseButton, mut app &Window){
	unsafe{
		if !(app.focus==""){
			object:=get_object_by_id(app, app.focus)
			if object["type"].str=="slider"{
				object["click"]=WindowData{bol:false}
				object["fnucl"].fun(EventDetails{event:"unclick",trigger:"mouse_left",target_type:object["type"].str,target_id:object["id"].str, value:object["val"].num.str()},mut app, mut app.app_data)
			}
		}
	}
}

[unsafe]
fn keydown_fn(c gg.KeyCode, m gg.Modifier, mut app &Window){
	unsafe{
		if app.focus!="" {
			mut object:=get_object_by_id(app,app.focus)
			key:=parse_key(c, m)
			if key.to_lower()=="escape"{
				app.focus=""
			}
			match object["type"].str {
				"textbox","password" {
					if key.len==1{
						the_text:=object["text"].str
						the_text_part1,the_text_part2:=the_text.split("\0")[0],the_text.split("\0")[1]
						if key!="\b" {
							object["text"]=WindowData{str:the_text_part1+key+"\0"+the_text_part2}
						} else {
							object["text"]=WindowData{str:the_text_part1#[0..-1]+"\0"+the_text_part2}
						}
						object["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:object["text"].str},mut app, mut app.app_data)
					} else if key.to_lower()=="right" || key.to_lower()=="left"{
						the_text:=object["text"].str
						the_text_part1,the_text_part2:=the_text.split("\0")[0],the_text.split("\0")[1]
						if key.to_lower()=="right" {
							if the_text_part2.len==0 { return }
							object["text"]=WindowData{str:the_text_part1+the_text_part2[0..1]+"\0"+the_text_part2[1..the_text_part2.len]}
						} else {
							if the_text_part1.len==0 { return }
							object["text"]=WindowData{str:the_text_part1#[0..-1]+"\0"+the_text_part1[the_text_part1.len-1..the_text_part1.len]+the_text_part2}
						}
					}
				} "button" {
					if key.to_lower()=="enter" || key==" " {
						object["fn"].fun(EventDetails{event:"keypress",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:true.str()},mut app, mut app.app_data)
					}
				} "checkbox" {
					if key.to_lower()=="enter" || key==" " {
						object["c"]=WindowData{bol:!object["c"].bol}
						object["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:object["c"].bol.str()},mut app, mut app.app_data)
					}
				} "slider" {
					if key.to_lower()=="left" {
						object["val"]=WindowData{num:math.max(object["vlMin"].num,object["val"].num-object["vStep"].num)}
						object["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:object["val"].num.str()},mut app, mut app.app_data)
					} else if key.to_lower()=="right" {
						object["val"]=WindowData{num:math.min(object["vlMax"].num,object["val"].num+object["vStep"].num)}
						object["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:object["val"].num.str()},mut app, mut app.app_data)
					}
				} "radio" {
					if key.to_lower()=="up" || key.to_lower()=="down" {
						group_id:=object["id"].str.split("_")#[0..-1].join("_")
						group:=get_object_by_id(app,group_id)
						radio_list_len:=group["len"].num
						mut which_item:=object["id"].str.replace(group_id+"_","").int()
						if key.to_lower()=="up"{
							which_item-=1
							if which_item==-1{
								which_item=radio_list_len-1
							}
						} else {
							which_item+=1
							if which_item==radio_list_len{
								which_item=0
							}
						}
						for item in 0..radio_list_len {
							app.get_object_by_id(group_id+"_"+item.str())[0]["c"].bol=item==which_item
						}
						app.focus=group_id+"_"+which_item.str()
						group["s"].num=which_item
						group["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",target_type:object["type"].str,target_id:group_id+"_"+which_item.str(),value:which_item.str()},mut app, mut app.app_data)
					}
				} "selectbox" {
					if key.to_lower()=="up" || key.to_lower()=="down" {
						list:=object["list"].str.split("\0")
						which_item:=object["s"].num
						if key.to_lower()=="up"{
							which_item-=1
							if which_item==-1{
								which_item=list.len-1
							}
						} else {
							which_item+=1
							if which_item==list.len{
								which_item=0
							}
						}
						object["s"].num=which_item
						object["text"].str=list[which_item]
						object["fnchg"].fun(EventDetails{event:"value_change",trigger:"keyboard",value:object["text"].str,target_type:object["type"].str,target_id:object["id"].str},mut app, mut app.app_data)
					}
				} "image" {
					if key.to_lower()=="enter" || key==" " {
						object["fn"].fun(EventDetails{event:"keypress",trigger:"keyboard",target_type:object["type"].str,target_id:object["id"].str,value:true.str()},mut app, mut app.app_data)
					}
				} else {}
			}
		}
	}
}

pub fn run(mut app &Window){
	app.gg.run()
}
