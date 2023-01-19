module window

pub fn hide_console(){ // only windows
	$if windows {
		C.FreeConsole()
		C.AllocConsole()
		hwnd:=C.GetConsoleWindow()
		C.ShowWindow(hwnd, false)
	}
}

pub fn prefer_x11(){ // only linux (if display server is wayland, try to use x11 [xwayland])
	$if linux {
		C.putenv(c"GDK_BACKEND=x11,wayland")
	}
}

pub fn prefer_dark_titlebar(window voidptr, dark bool){ // only windows
	$if windows {
		C.prefer_dark_titlebar(window, dark)
	}
}

pub fn hide(window voidptr){
	$if linux {
		C.gtk_widget_hide(window)
	} $else $if windows {
		C.ShowWindow(window, false)
	}
}

pub fn show(window voidptr){
	$if linux {
		C.gtk_widget_show(window)
	} $else $if windows {
		C.ShowWindow(window, true)
	}
}
