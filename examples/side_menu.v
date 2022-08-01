import malisipi.mui as m

fn toggle_menu(event_details m.EventDetails,mut app &m.Window, app_data voidptr){
	unsafe{
		app.get_object_by_id("menu_frame")[0]["hi"].bol=!app.get_object_by_id("menu_frame")[0]["hi"].bol
	}
}

fn menu_open(event_details m.EventDetails,mut app &m.Window, app_data voidptr){
    toggle_menu(event_details,mut app, app_data)
    unsafe {
        app.get_object_by_id("text")[0]["text"].str="You clicked "+app.get_object_by_id(event_details.target_id)[0]["text"].str
    }
}

mut app:=m.create(m.WindowConfig{ title:"Side Menu - MUI Example", height:600, width:800 })

app.frame(m.Widget{ id:"menu_frame", x:"0", y:"0", width:"300", height:"100%y", hidden:true })
app.button(m.Widget{ id:"menu_1", x:"10", y:"60", width:"280", height:"30", text:"Welcome", icon:false, frame:"menu_frame", onclick:menu_open })
app.button(m.Widget{ id:"menu_2", x:"10", y:"90", width:"280", height:"30", text:"Edit", icon:false, frame:"menu_frame", onclick:menu_open })
app.button(m.Widget{ id:"menu_3", x:"10", y:"120", width:"280", height:"30", text:"About", icon:false, frame:"menu_frame", onclick:menu_open })
app.button(m.Widget{ id:"menu_open", x:"10", y:"10", width:"30", height:"30", text:"↩", icon:true, onclick:toggle_menu })
app.label(m.Widget{ id:"text", x:"# 10", y:"# 10", width:"100", height:"25", text_align:2 text:"" })

app.run()
