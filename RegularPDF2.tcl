# RegularPDF (Code Restructured/Reorganized )
# Author: Abdullah Fatota
# Description: A PDF Authoring Tool

package require Tk

# Window Path Naming Guide:
# .Prefix_name[.Prefix_name[...]]
# Prefix	-> type of Window
# b		=>	Button
# f		=>	Frame
# l		=>	Label
# lf	=>	Labelframe
# m		=> 	Menu
# pw 	=>	PanedWindow
# sb	=>	Scrollbar
# tl	=>	Toplevel
# ttkSG =>	ttk::sizegrip
# ttkSP	=>	ttk::Separator

namespace eval RootWindow {
	
	set width	700
	set height	400
	set screen_w	[winfo vrootwidth .]
	set screen_h	[winfo vrootheight .]
	set x			[expr {$RootWindow::screen_w / 2 - $RootWindow::width /2}]
	set y			[expr {$RootWindow::screen_h / 2 - $RootWindow::height /2}]
	#Position the Root window
	wm title 		. RegularPDF
	wm geometry 	. ${RootWindow::width}x${RootWindow::height}+${RootWindow::x}+${RootWindow::y}
	##############################################################################################
}
namespace eval Icon {
	namespace eval Unicode {
		set Dot				"\ud83d\udf84"
		set 3Dots			[string repeat $Icon::Unicode::Dot 3]
		set QuasiFilter		"\u29d6"
		set UpDart 			"\u2b9d"
		set DownDart 		"\u2b9f"
		set DownArrow		"\u25bc"
		set UpBoldArrow		"\ud83e\udc45"
		set DownBoldArrow	"\ud83e\udc47"
		set LeftBarbArrow	"\ud83e\udc60"
		set Save 			"\ud83d\udcbe"
		set FolderOpen 		"\ud83d\udcc2"
		set FolderClosed 	"\ud83d\uddc0"
		set Back 			"\u2190"
		set Reload 			"\u21bb"
		set Folders			"\ud83d\uddc2"
		set Copyright		"\u00a9"
	}
}
namespace eval Util {
	
}
namespace eval About {
	#
	#create a toplevel window, make it invisible (iconify it), and 'bind' the X button
	toplevel 	.tl_about
	wm withdraw .tl_about
	wm protocol .tl_about WM_DELETE_WINDOW {wm withdraw .tl_about}
	wm title 	.tl_about About
	##############################################################################################
	#
	# e.g. -family {Segoe UI} -size 9 -weight normal -slant roman -underline 0 -overstrike 0
	set Font [font configure TkDefaultFont]
	set fsize [dict get $About::Font -size]
	set fname [dict get $About::Font -family]
	#puts [list About default font -> $Font]
	##############################################################################################
	#
	label .tl_about.l_l1 -text [wm title .] -font [list -family Tahoma -size [expr {$About::fsize * 2}]]
	label .tl_about.l_l2 -text {A PDF Authoring Tool} -font [list -family Tahoma -size [expr {int($About::fsize * 1.5)}]]
	label .tl_about.l_l3 -text "$Icon::Unicode::Copyright 2020 Abdullah Fatota"
	##############################################################################################
	#
	pack .tl_about.l_l1 .tl_about.l_l2 .tl_about.l_l3 -pady 10 -padx 2cm
	
}
namespace eval MainPane {
	#set path .pw_pane
	set background coral
}
namespace eval Files {

	#set path 			.pw_pane.lf_files
	#set toolbar 		.pw_pane.lf_files.f_toolbar
	#set toolbar_dots	.pw_pane.lf_files.f_toolbar .b_dots
	#set toolbar_filter	.pw_pane.lf_files.f_toolbar.b_filter
	#set toolbar_reload	.pw_pane.lf_files.f_toolbar.b_reload
	#set toolbar_cd		.pw_pane.lf_files.f_toolbar.b_cd
	#set scrollh 		.pw_pane.lf_files.sb_h
	#set scrollv 		.pw_pane.lf_files.sb_v
	#set dots_menu		.pw_pane.lf_files.m_menu
	#set L				.pw_pane.lf_files.lb_l
	#set R				.pw_pane.lf_files.lb_r	
	# padding for toolbar elements
	
	set toolbar_pad		10
	
	#Icions listbox variable											#Icons listbox variable
	set Lvar {}	;														set Rvar {}
	
	# var for other uses
	set Bvar {}
	# path of current directory											#"Dir Limit" Index
	set dir [pwd]	;													set dir_limit {}												
	
	# index of last highlighted element
	set last_h -1
	
	#aesthetic properties
	set frame_borderwidth 	5
	set highlight_color 	yellow
	
	# toolbar children					# its length
	set toolbar_children [list ]		; set toolbar_children_length {}
	# Index of which one is last non-hidden button?
	set index_last_on_toolbar {}
	# Index last item in ...  menu
	set index_last_on_menu {}
	# its width
	set Lwidth {}
	# columnconfigure of any button on the toolbar 
	set Lcolumnconfigure {}
}
namespace eval Tooltip  {
	set location {}
	set pins 	[dict create]
	set boards 	[dict create]
}
namespace eval Menu {
	
	set children [list .m_root .m_document .m_page .m_root.m_Help]
	#Root Menus
	#set mRoot 		.mRoot
	#set mDocument 	.mDocument	
	#set mPage 		.mPage
	
	#cascade Root Menus
	#set mHelp 		${Menu::mRoot}.mHelp
	
	#labels
	set labels [dict create \
				1 Help \
				2 Debug \
				3 Console \
				4 About \
				5 New  \
				6 Clone \
				7 Close \
				8 {Add New Page Above} \
				9 {Add New Page Below} \
				10 Delete \
				11 Move]
	
	#commands 
	set coms [dict create \
			  1 null \
			  2 Util::debug \
			  3 Util::show_console \
			  4 About::show \
			  5 {} \
			  6 {$whoobject clone $whocalled } \
			  7 {} \
			  8 {$whoobject up $whocalled} \
			  9 {$whoobject down $whocalled} \
			  10 { puts .mDoc_delete} \
			  11 {$whoobject rename $whocalled }
			  ]
	
	# info about each root menu's children
	set chRoot			[dict create menu .m_root  cascade_1	[dict create 1 .m_root.m_Help]  command_1 [list 3 2] ]
							
	set chDocument 		[dict create menu .m_document  command_1	[list 5 6 7] ]
							
	set chPage			[dict create menu .m_page  command_1	[list 8 9]  separator_1 x  command_2 [list 10 11] ]
							
	set chHelp 			[dict create menu .m_root.m_Help  command_1	[list 4] ]

}
namespace eval Menu::DocPage {
	#Todo: later
}
namespace eval NorthBar {
	set path .toolbar
	set border_width 0
	
	# Left to right, direction of laying elements.
	set direction left
	# For positioning purposes
	set children [dict create]
	set children_count 0
	# For space_block buttons
	set space_block_children [list]
	
	# Menu Buttons (or Blocks)
	# 0 => Menu Bar (root Menu) is Visible, 1 => NorthBar Menu Buttons are visible,
	set is_menu_button_mode_active 0
	
	set menu_button_children [list]
	
	set dart_children [dict create]
	set testVar {}
}
proc Util::get_center [ list win [list relative_to {}] ] {
	#Todo: implement relative_to
	set RootWindow::screen_w [winfo vrootwidth .]
	set RootWindow::screen_h [winfo vrootheight .]
	set w [expr "$RootWindow::screen_w / 2 - [winfo width $win]/2"]
	set h [expr "$RootWindow::screen_h /2 - [winfo height $win]/2"]
	
	return +${w}+${h}
}
proc Util::show_console {} {
	console show
}
proc Util::debug {} {
	#objectpages
	#PDF create stream text -text Messages -x 0
	set x [PDF create -ref page]
	set y [PDF create -ref pages]
	set z [PDF create -ref stream text -text HELLO -fontname /Font1 -fontsize 12] ; #-fontname Calibri
	PDF create -hasref dict /Len *8
	PDF update -hasref $x thing /Parent *$y /Contents *$z
	PDF update -hasref 6 thing 0 *1
	PDF update -hasref $y thing /Kids *6 /Count 1
	PDF header
	PDF trailer
	PDF update $z stream add text -x 9 -y 19
	set B [PDF create -ref catalog]
	set I [PDF create -ref info]
	PDF update -hasref end thing /Info *$I /Root *$B
	PDF update -hasref $B thing /Pages *$y
	PDF reftable
	PDF display
	concat
}
proc Util::max [list a args] {
	#collect all arguments as a list.
	set args [concat $a $args]
	
	set args [lsort -decreasing $args]
	return [lindex $args 0]
}
proc Util::args {lst args} {
	#Args $args -angles 60deg -points 0,0 +10,0 -10,-10 -anchor 1 -sides
	#indexes of options: strings starting wtih {-[a...z]}
	set x [lsearch -nocase -all $args -\[a-z\]* ] ;
	#sotrage for thos options/switches
	set d [dict create] ; 
	
	foreach name [list args lst] {
		# 
		upvar 0 $name var
		# j => x[0 : end]	;	i => x[1 : end]
		foreach i [list {*}[lrange $x 1 end] [llength $var]] j $x {
			#puts "i-j  [expr {$i - $j} ] =[lrange $var $j+1 $i-1]="
			# if an 'entry' exists between the two 'switches' set/override it as the value of the option either in args
			dict set d [lindex $var $j] [expr { ($i - $j) > 1 ? [lrange $var $j+1 $i-1] : {} } ]
		}
		# or lst
		set x [lsearch -all $lst -?* ]
		if {$x eq {}} then {break}
	}
	#set con "$d"
	#concat
	set com [string cat {dict for {key value} } "{$d}" { {set [string range $key 1 end] $value}} ]
	
	#'inject' the variables into the calling function.
	uplevel 1 $com
	return x
}
proc Util::range [list from to [list by 1]] {
	set ranges 	[list]
	set last	$from
	while { [incr last $by] <= $to } {lappend ranges $last}
	if {$ranges ne {}} {set ranges [linsert $ranges 0 $from]}
	return $ranges
}
# a hack and a terrible name
proc Util::len_range [list from to [list by 1]] {
	return [Util::range $from [expr {$to - 1}] $by ]
}

proc About::show args {
	wm deicon 	.tl_about
	wm geometry .tl_about [Util::get_center .tl_about]
	#
	#wm attributes .tl_about -topmost 1
}
proc MainPane::create args {
	
	panedwindow .pw_pane -showhandle 1 -sashwidth 10 -sashpad 20 -sashrelief raised -handlepad 0 -background $MainPane::background
	pack 		.pw_pane -expand 1 -fill both -side bottom
	#puts MainPanecreate
}
proc Files::create {args} {
	
	# Constructing Windows/Widgets
	# the frame
	labelframe 	.pw_pane.lf_files 	-text "Items in current directory" -relief ridge -bd $Files::frame_borderwidth
	# frame Parent's background
	set Pbg [.pw_pane cget -background]
	# left listbox for Icons
	listbox		.pw_pane.lf_files.lb_l		-relief flat -highlightthickness 2 -highlightcolor blue  -background $Pbg -cursor hand2 -activestyle none -selectmode single -listvar Files::Lvar -justify center
	# right hand-side listbox for listing files
	listbox 	.pw_pane.lf_files.lb_r -relief flat -highlightthickness 2 -highlightcolor blue \
	-background $Pbg -cursor hand2 -activestyle none -selectmode browse -listvar Files::Rvar
	# toolbar
	frame 		.pw_pane.lf_files.f_toolbar -relief groove -borderwidth 10 -height 50
	# scrollbars
	scrollbar 	.pw_pane.lf_files.sb_h -orient vertical -relief groove -command {.pw_pane.lf_files.lb_r yview}
	scrollbar 	.pw_pane.lf_files.sb_v -orient horizontal -relief groove -command {.pw_pane.lf_files.lb_r xview}
	# {...} menu
	menu 		.pw_pane.lf_files.m_dots 	-tearoff 0
	# toolbar elements
	button 		.pw_pane.lf_files.f_toolbar.b_filter 	-text "$Icon::Unicode::QuasiFilter Filter PDF Files"			-relief groove -overrelief solid
	button 		.pw_pane.lf_files.f_toolbar.b_reload 	-text "$Icon::Unicode::Reload Reload"							-relief groove -overrelief solid
	button 		.pw_pane.lf_files.f_toolbar.b_cd 		-text "$Icon::Unicode::FolderOpen List via OS' File explorer" 	-relief groove -command {Files::list_ [tk_chooseDirectory -initialdir $Files::dir]}  -overrelief solid
	button 		.pw_pane.lf_files.f_toolbar.b_dots 		-text $Icon::Unicode::3Dots 								-relief groove -overrelief solid
	
	# Invisible Toolbar labels (to be used for event bindings
	label 		.pw_pane.lf_files.f_toolbar.l1 -bg blue
	label 		.pw_pane.lf_files.f_toolbar.l2 -bg red
	##############################################################################################	
	
	# ... Button Post Menu
	.pw_pane.lf_files.f_toolbar.b_dots configure -command [list Menu::post .pw_pane.lf_files.f_toolbar.b_dots .pw_pane.lf_files.m_dots]
	.pw_pane.lf_files.m_dots add command -label "$Icon::Unicode::UpBoldArrow Bring Up Toolbar"
	##############################################################################################
	
	# Filter PDFs
	bind .pw_pane.lf_files.f_toolbar.b_filter <ButtonRelease> {
		set all [.pw_pane.lf_files.lb_r get [expr $Files::dir_limit + 1] end]
		#puts [list all -> $all]
		#
		set all [lsearch -all -inline $all *.pdf]
		set Files::Bvar Files::Rvar
		set Files::Rvar $all
	}
	##############################################################################################
	
	# configure L and R to update attached scrollbars
	.pw_pane.lf_files.lb_r configure -yscrollcommand {.pw_pane.lf_files.sb_h set}
	.pw_pane.lf_files.lb_r configure -xscrollcommand {.pw_pane.lf_files.sb_v set}
	##############################################################################################
	
	# Occupy a pane in the panedwindow
	.pw_pane add .pw_pane.lf_files
	##############################################################################################
	
	# pack the scroll bars
	pack 		.pw_pane.lf_files.sb_h -side right 	-fill y
	pack 		.pw_pane.lf_files.sb_v -side bottom 	-fill x
	##############################################################################################
	
	# pack the toolbar
	pack .pw_pane.lf_files.f_toolbar 		-side top 	-fill x		-padx 10 	-pady 10 -expand 0
	##############################################################################################
	
	# pack the list boxes
	pack .pw_pane.lf_files.lb_l 	-side left 	-fill y
	pack .pw_pane.lf_files.lb_r 	-side left 	-fill both -expand 1
	##############################################################################################
	
	# grid button(s) on toolbar
	grid .pw_pane.lf_files.f_toolbar.b_filter 	-row 0 -column 0 -sticky we	
	grid .pw_pane.lf_files.f_toolbar.b_reload 	-row 0 -column 1 -sticky we
	grid .pw_pane.lf_files.f_toolbar.b_cd 		-row 0 -column 2 -sticky we	
	grid .pw_pane.lf_files.f_toolbar.b_dots 	-row 0 -column 3 -sticky we
	##############################################################################################
	
	# uniform width columns
	grid columnconfigure .pw_pane.lf_files.f_toolbar all -weight 1 -minsize 0 -uniform 1
	grid columnconfigure .pw_pane.lf_files.f_toolbar 3 -weight 0  -uniform 2
	##############################################################################################
	
	# grid Indicator labels
	grid .pw_pane.lf_files.f_toolbar.l1  -row 1 -column 0 -sticky w -columnspan 3
	grid .pw_pane.lf_files.f_toolbar.l2  -row 2 -column 0 -sticky w -columnspan 3
	##############################################################################################
	
	
	
	# ON visibility DO 
	# 1) set canonical width of any toolbar button
	# 2) set padx for (invisible) labels
	# 3) bind each on <Map> and <Unmap> effictevly to test if visible with the padding applied.
	bind .pw_pane.lf_files.f_toolbar.l1 <Visibility> {
	
		# since Items are returned as LIFO
		set Files::toolbar_children [lreverse [grid slaves .pw_pane.lf_files.f_toolbar -row 0]]
		# except ... menu
		set Files::toolbar_children [lrange $Files::toolbar_children 0 end-1]
		set Files::toolbar_children_length [llength $Files::toolbar_children]
		# Index of last button
		set Files::index_last_on_toolbar [expr {$Files::toolbar_children_length - 1}]
		# Nothing is there
		set Files::index_last_on_menu -1
		# its columnconfigure
		set Files::Lcolumnconfigure [grid columnconfigure .pw_pane.lf_files.f_toolbar $Files::index_last_on_toolbar]
		# Width of Toolbar - width(... button)
		#set Files::Lwidth [winfo width [lindex $Files::toolbar_children $Files::index_last_on_toolbar] ]
		set Files::Lwidth [expr { [winfo width .pw_pane.lf_files.f_toolbar] - [winfo width .pw_pane.lf_files.f_toolbar.b_dots] }]
		# Invisible Indicators (by magic of [grid]'s -padx option)
		grid config .pw_pane.lf_files.f_toolbar.l1 -padx [list [expr {$Files::Lwidth / 2 - [winfo width .pw_pane.lf_files.f_toolbar.l1] } ] 0]
		grid config .pw_pane.lf_files.f_toolbar.l2 -padx [list [expr {$Files::Lwidth 	 - [winfo width .pw_pane.lf_files.f_toolbar.l2] } ] 0]


		# bind <Unmap> and <Map>
		bind .pw_pane.lf_files.f_toolbar.l1 <Unmap> {
			set b [lindex $Files::toolbar_children $Files::index_last_on_toolbar]
			#puts [list b is $b]
			grid forget $b
			# LIFO Order
			.pw_pane.lf_files.m_dots insert $Files::index_last_on_toolbar command -label [$b cget -text] -command [$b cget -command]
			incr Files::index_last_on_menu
			
			grid columnconfigure .pw_pane.lf_files.f_toolbar $Files::index_last_on_toolbar -weight 0 -uniform {}
			# quarter the padding distance
			puts [list _newx1 [set _newx1 [list [expr {[winfo width .pw_pane.lf_files.f_toolbar] / 2  } ]  0] ]]
			puts [list _newx2 [set _newx2 [list [expr {[winfo width .pw_pane.lf_files.f_toolbar] } ]  0]   ]]
			grid config .pw_pane.lf_files.f_toolbar.l1 -padx $_newx1
			grid config .pw_pane.lf_files.f_toolbar.l2 -padx $_newx2
			incr Files::index_last_on_toolbar -1
			}
		bind .pw_pane.lf_files.f_toolbar.l2 <Map> {
			if { $Files::index_last_on_menu  !=  -1 } {
				set _col_target [expr $Files::index_last_on_toolbar+1]
				set b [lindex $Files::toolbar_children $_col_target]
				puts [list b is $b ]
				grid $b -row 0 -column $_col_target -sticky we
				.pw_pane.lf_files.m_dots delete $Files::index_last_on_menu
				incr Files::index_last_on_menu -1
				
				grid columnconfigure .pw_pane.lf_files.f_toolbar $_col_target {*}$Files::Lcolumnconfigure
				# x4 x-padding distance
					puts [list _backx1 [set _newx1 [list [expr { [lindex [dict get [grid  info .pw_pane.lf_files.f_toolbar.l1] -padx] 0] * 2  } ]  0]   ]]
					puts [list _backx2 [set _newx2 [list [expr { [lindex [dict get [grid  info .pw_pane.lf_files.f_toolbar.l2] -padx] 0] * 2  } ]  0]   ]]
				
					grid config .pw_pane.lf_files.f_toolbar.l1 -padx $_newx1
					grid config .pw_pane.lf_files.f_toolbar.l2 -padx $_newx2

				incr Files::index_last_on_toolbar
			}
				
		}
		# run all above once.
		bind .pw_pane.lf_files.f_toolbar.l1 <Visibility> {}
	}
	##############################################################################################
	
	
	# when the pointer hovers on the listbox
	bind .pw_pane.lf_files.lb_r <Motion> {
		set index [%W index @%x,%y]
		#puts [list index is $index]
		#"deselect" all, costly
		#for [list set len [expr [%W size] - 1]] {$len >= 0} [list incr len -1] { %W itemconfigure $len -background {}}
		#another approach, if the variable holding the last index is not empty, de-highlight it
		# expensive
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $Files::last_h -background {}}
		#hightlight index "cursor" in R
		#
		
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $index -background $Files::highlight_color}
		#in L
		
		#save that that has been highlighted's index
		set Files::last_h $index
	}
	##############################################################################################
	
	# when it leaves
	bind .pw_pane.lf_files.lb_r <Leave> {
		#costly
		#for [list set len [expr [%W size] - 1]] {$len >= 0} [list incr len -1] { %W itemconfigure $len -background {}}
		#un-highlight the last index
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $Files::last_h -background {}}
	}
	##############################################################################################
	
	# when an item is selected
	bind .pw_pane.lf_files.lb_r <<ListboxSelect>> {
		# current selected Index
		set index 	[%W curselection]
		# what's on it
		set Label 	[.pw_pane.lf_files.lb_r get $index]
		# if <-
		
		# Assuming R is cleared
		set Files::last_h {-1}
		
		if {$index == 0} {
			# full path of doing <-
			set Files::dir [file normalize [file join $Files::dir .. ] ]
			puts [list up is $Files::dir]
			# if C:/ D:/ or even /								list volumes					otherwise list the up/dir, glob demands an / on end
			if { $Files::dir in [set volumes [file volumes]] } { Files::list_volumes $volumes } else { Files::list_ [string cat $Files::dir /] }
			# glob tolerates an extra / on end
			# puts [list to is $Files::dir]
		} elseif {$index < $Files::dir_limit} { set Files::dir [file join $Files::dir $Label];  ;Files::list_ [string cat $Files::dir /] } else {
			#
			puts [list file -> [file join $Files::dir $Label]]
		}
	}
	##############################################################################################
}
proc Files::list_ [list [list path ./] [list bypass 0] ] {
	
	
	#files
	set f [concat [glob -nocomplain -path $path -types {f} *] [glob -nocomplain -path $path -types {f hidden} *] ]
	#directories
	set d [concat [glob -nocomplain -path $path -types {d} *] [glob -nocomplain -path $path -types {d hidden} *] ]
	
	#strip $d and $f From $path, by subsetting the string after the $path prefix
	set pathStrLen [string length $path]
	set f [lmap x $f {string range $x $pathStrLen end}]
	set d [lmap x $d {string range $x $pathStrLen end}]
	
	# sort files and directories
	set f [lsort -nocase $f]
	set d [lsort -nocase $d]
	#clear L and R
	set Files::Lvar {} ; set Files::Rvar {}
	
	#set "Limit" Index Beyond which only files exist.
	set Files::dir_limit [expr 1 + [llength $d] ]

	
	#Populate Right listbox
	
	set Files::Rvar [list "$Icon::Unicode::LeftBarbArrow" {*}$d "$Icon::Unicode::DownArrow File(s)" {*}$f]
	
	#Populate Icons
	set Files::Lvar [lrepeat [expr [llength $d ]+ 1 ] $Icon::Unicode::FolderClosed ]
	
	#
	#set index [.pw_pane.lf_files.lb_r index @[winfo x .pw_pane.lf_files.lb_r],[winfo y .pw_pane.lf_files.lb_r] ]
	#
	#.pw_pane.lf_files.lb_r itemconfigure $index -background $Files::highlight_color
}
proc Files::list_volumes lst {
	#lst => list of volumes
	
	#no files
	set f {}
	#only root(s)/drivers c:/ d:/ ...
	set d $lst
	
	#clear L and R
	set Files::Lvar {}
	set Files::Rvar {}
	
	#
	#
	set Files::dir_limit [expr [llength $d] + 1]
	
	#right-populate
	set Files::Rvar [ concat "$Icon::Unicode::LeftBarbArrow" $d ]
	
	#left populate with "volume" icon
	set Files::Lvar [lrepeat [expr [llength $d ] + 1 ] $Icon::Unicode::Folders]
	
}
proc Tooltip::place args {
	#Tooltip::place -widget x -anchor 'ne' -show which Board
	Util::args $args -widget -anchor -show
}
	
proc Menu::create args {
	# Create Menus in the Menu Toolbar, cascade menus, their children commands and associated bindings
	
	#create all Root Menu Widgets
	#get all m* variable names in namespace ::Menu.
	#foreach m [info vars Menu::m*] {
	#	menu [set $m] -tearoff 0
	#}
	foreach m $Menu::children { menu $m -tearoff 0 }
	unset m
	
	
	foreach chDict [list $Menu::chRoot $Menu::chDocument $Menu::chPage $Menu::chHelp] {
		#get children (cascade/command/etc..) and depending on type do the appropriate operation
		dict for {key val} $chDict {
			#Hack to get the menu's path
			if {$key eq {menu} } { set path $val ; continue }
			#split the type from the key (name)
			switch -exact -- [lindex [split $key _] 0] {
				command {
					#access (numeric) elements from the list (val)
					foreach i $val { $path add command -label [dict get $Menu::labels $i] -command [dict get $Menu::coms $i]  } }
				separator {
					$path add separator }
				cascade {
					#access (key, value) pair elements from the dictionary (val)
					dict for {key2 val2} $val { $path add cascade -label [dict get $Menu::labels $key2] -menu $val2 } }
			}
			
		}
	}
	
	#Enview On-screen ones. 
	{.} config -menu .m_root
}
proc Menu::post {at menu} {
	$menu post [winfo rootx $at ]  [expr [winfo rooty $at ]+[winfo height $at ]]
}
proc NorthBar::create args {
	frame		.f_toolbar -borderwidth $NorthBar::border_width -relief flat -background lightblue
	pack 		.f_toolbar -side top -fill x
	# For Testing purposes only.
		#pack [button ${NorthBar::path}.b -text NorthBar] -expand 1
		# 2 Separators
		NorthBar::new_space_block
		NorthBar::new_space_block
		#NorthBar::new_button name -text X -relief solid pack -expand 0 -padx 2  -with_separator
}
proc NorthBar::new_space_block args {
	
	# specify the button's attributes to make it behave as a textless block, and then call new_button to create it.
	# Tomodify: space_block_#Replace count here
	set b [NorthBar::new_button space_block_[incr NorthBar::children_count] -background [.f_toolbar cget -background] -state disabled -relief flat pack -expand 0 -fill y]
	#puts [list [winfo width $b]  [winfo reqwidth $b]]
	
	#append the child
	lappend NorthBar::space_block_children $NorthBar::children_count
	
	return $b
}
proc NorthBar::new_button [list name args] {
	
	# too complicated
	# new button [list name type args]
	# if $name == {}: .toolbar.$type_block_$count ; if -no_count_append => .toolbar.$type_block_
	# eles:			  .toolbar.$type_block_$name ; if -no_count_append => Ignore
	#
	# instead -type Type is implemented
	
	#++children_count
	incr NorthBar::children_count
	
		# if name is empty => .toolbar.button_block_(Count)
		if {$name eq {}} { set n [string cat .f_toolbar {.} button_block_  $NorthBar::children_count] }
	
		# if {#} exists in Button creation arguments:
		if { [set Hashtag [string first {#} $args] ]!= {-1} } { set args [string replace $args $Hashtag $Hashtag $n]  }
	
	#if vertical ttk::separator is present should be put, after the button.							# if vertical is not -1, pop it from $args.
	set vertical [lsearch -exact $args -with_separator] ;									if {$vertical != -1} { set args [lreplace $args $vertical $vertical] ; set vertical 1} else {set vertical 0}
	
	# search for -type
	set type [lsearch -exact $args {-type}]
	# if -type is present, 1) set tmp as the value After it in $args. 2) replace -type and the Value. 3) return just set $type.
	# else set type to 0
	set type [ if {$type == {-1}} {subst 0} else { set tmp [lindex $args $type+1] ; set args [lreplace $args $type $type+1] ; subst $tmp} ]
	
	#get name/ partial window path name from $args[0] if it doesn't exist already.			Then 'right shift' the arguments
	if ![info exists n] { set n [string cat .f_toolbar {.} $name ] } ;					#	set args [lrange $args 1 end]
	
	
	# index of place/pack/grid word.														# the last of those (non-empty ones)
	set index [lmap e [list place pack grid] {concat [lsearch -exact $args $e]}] ;			set index [Util::max $index]

	
	#split args as 1: [button creation arguments (0)- $index-1] 							2: [place/pack/grid INSERTED$name - end]
	set Attr  [lrange $args 0 $index]	;													set Geometry [lrange $args $index end ]
	
	if {$index == -1} {
		set Attr $Geometry
		set Geometry [list]
		
	} else {
		set Attr [lreplace $Attr end end]
		set Geometry [linsert $Geometry 1 $n]
	}
	
	
	#Hackey way of doing it.
	#create the button, by default
	set b [expr { $type == {0} ? [button $n {*}$Attr ] : [NorthBar::new_$type $n $Attr] } ]
	
	#store the name/window path of the button as Value to Key $children_count
	dict set NorthBar::children $NorthBar::children_count $b
	
	#pack/place/grid it
	#{*}$Geometry
	#To ensure conformity to NorthBar::direction.
	switch [lindex $Geometry 0] {
		pack { {*}$Geometry -side $NorthBar::direction
				# if -with_separator is specified in $args, put a vertical ttk::separator in accordance with NorthBar::direction
				if $vertical {
					pack [ttk::separator [string cat $b _separator] -orient vertical] -after $b -side $NorthBar::direction -fill y -expand 0 -padx 1
					}
			}
		grid -
		place { throw [list TK UNSUPPORTED UNSUPPORTED_GEOMETRY_MANAGER] [list Only pack GM currently is supported] }
	}
	return $b
}
proc NorthBar::new_dart [list n Args] {
	
	#n 		=> full window path, pre-created
	#Args 	=> Attr, a list from NorthBar::new_button
	
	#remove Switches
		# search for -options (labels on the menu)
		# -default (index of which label to be ticked/on)
		# -text 	(text on button face)
		set opsWanted 		[list -options -default]
		set opsIndexes 		[lmap e $opsWanted {concat [lsearch -exact $Args $e]}]
		# to find element in args that are not index of -option or after it
		set opsIndexesNot	[Util::len_range 0  [llength $Args]]
		set opsIndexesNot	[lmap e $opsIndexesNot {if {$e in $opsIndexes || ($e - 1) in $opsIndexes } {continue} else {concat $e} }]
		#
		#retrieve and remove
		foreach index $opsIndexes one $opsWanted {
			set [string range $one 1 end] [ if {$index == {-1}} {subst {}} else { set tmp [lindex $Args $index+1] ; ; subst $tmp} ]
		}
		
		#abandoned
		#Util::args $Args -options -default
		#puts [list new dart is $options $default]
		#
		unset -nocomplain tmp
		# to counteract $Args being =>[list {} {} {} {} {}]
		set Args [lmap e $opsIndexesNot {lindex $Args $e}]
	#the container
	set contain [frame $n -relief flat -borderwidth 1]
	
	#the button
	set b1 [button [string cat $contain . b1 ] {*}$Args -relief flat ]
	#separator
	set s [ttk::separator [string cat $contain . s ] -orient vertical]
	#dart "option" button; to trigger a menu of options (not tk_optionMenu)
	set b2 [button [string cat $contain . b2 ] -relief [$b1 cget -relief] -text "$Icon::Unicode::DownDart"]
	#the menu
	set m [menu [string cat $contain . m ] -tearoff 0]
	
	#by controlling -variable sets the default radiobutton
	set NorthBar::testVar $default
	# add option; 0 => buit-in file lister . 1 => OS' native
	foreach op $options value [Util::len_range 0 [llength $options]] { $m add radiobutton -label $op -value $value -variable NorthBar::testVar}
	
	
	
	#dict set NorthBar::dart_children $NorthBar::cildren_count [dict create]
	pack $b1 $s $b2 -side left
	pack configure $s -fill y
	
	#config. Todo:Complete the implementation
	$b2 config -command "Menu::post $b2 $m"
	
	#Emulating -overrelief
	bind $contain <Enter> "$contain config -relief groove"
	bind $contain <Leave> "$contain config -relief flat"
	
	return $contain
	
}
proc NorthBar::create_menu_buttons args {
	# Create .toolbar.menu_button_x
	
	dict for {key val} $Menu::chRoot {
		switch  [lindex [split $key _] 0] {

			command {
				foreach i $val {
					NorthBar::new_button {} -text [dict get $Menu::labels $i] -command [dict get $Menu::coms $i] -relief flat -overrelief groove pack
					lappend NorthBar::menu_button_children $NorthBar::children_count
					}
					
			}
			cascade {
				dict for {key2 val2} $val {
					# {#} will be replaced with name/path of the button
					NorthBar::new_button {} -text [dict get $Menu::labels $key2] -command "Menu::post # $val2" -relief flat -overrelief groove pack }
					lappend NorthBar::menu_button_children $NorthBar::children_count
			}
		}
		
	}
}

proc NorthBar::create_menu_buttons_switch args {
	#Assmes position (it's has been called after create_menu_buttons etc...)
	
	
	# get full window path of the new button
	lassign [NorthBar::new_button menu_switch -relief flat -overrelief groove -text "$Icon::Unicode::UpBoldArrow Bring Up Menu"  pack] b
	
	#then send it, in command
	$b config -command [list NorthBar::menu_buttons_switch $b]
	
}
proc NorthBar::menu_buttons_switch w {
	#$w => full window path of the Switch Button
	
	#the switch button's  text
	set text [$w cget -text]
	
	#str => {Up} or {Down}
	set str [lindex $text 2]
	
	if {$str eq {Up}} {
			#set the Menu Bar
			{.} config -menu .m_root
			#Get all menu buttons
			set all [ lmap e $NorthBar::menu_button_children { concat [dict get $NorthBar::children $e] } ]
			#remove them
			pack forget {*}$all
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Down] 0 0 $Icon::Unicode::DownBoldArrow]
		} else {
			#remove the menu bar
			{.} config -menu {}
			#Get all menu buttons
			set all [ lmap e $NorthBar::menu_button_children { concat [dict get $NorthBar::children $e] } ]
			#pack them, before .toolbar.menu_switch
			pack {*}$all -side $NorthBar::direction -before $w
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Up] 0 0 $Icon::Unicode::UpBoldArrow]
		}
}

proc main { } {
	# always on top
	wm attributes . -topmost 1
	# the resize grip
	ttk::sizegrip	.ttksg_resize
	pack .ttksg_resize -side bottom -fill x
	
	set os [lindex [array get tcl_platform os] 1]

	
	#Create on and off-screen Menu's. Enview .mRoot.
	Menu::create
	
	#create and Enview (cause it to be visible) Top strip/Toolbar
	NorthBar::create
	
	
	#create Menu Buttons/Blocks
	NorthBar::create_menu_buttons
	
	#create the Menu Buttons switch button
	NorthBar::create_menu_buttons_switch
	
	#Test
	NorthBar::new_button {} -type dart -text {Save as PDF} -command {puts [list -> %x %y]} -options [list {Use the built-in File lister} {Use the OS' native File explorer}] -default 1 pack -pady 1
	#create and Enview [panedwindow]
	MainPane::create
	
	#create and enview a [label frame]
	Files::create
	
	#And populate it with dir items
	Files::list_
	
	
	# For Testing purposes only,
	# Before window creation and visibility it's all 0 0 0...
	puts [list -x [winfo x .pw_pane] -y [winfo y .pw_pane] \
		  -rootx [winfo rootx .pw_pane] -rooty [winfo rooty .pw_pane] \
		  -vrootx [winfo vrootx .pw_pane] -vrooty [winfo vrooty .pw_pane]]
	
	# For Testing purposes only, of .pw_pane
	place [button .b -text TempButton -command [list puts [list Only a temporary Button] ]] -x 0 -y 100
	
	
}


main
