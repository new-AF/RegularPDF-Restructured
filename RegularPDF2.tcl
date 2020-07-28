# RegularPDF (Code Restructured/Reorganized)
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
	
	variable width 700 	height 400 	screenW [winfo vrootwidth .] 	screenH [winfo vrootheight .]
	variable x [expr {$RootWindow::screenW / 2 - $RootWindow::width /2}] 	y [expr {$RootWindow::screenH / 2 - $RootWindow::height /2}]
	
	# center the Root window
	wm title 		. RegularPDF
	wm geometry 	. ${RootWindow::width}x${RootWindow::height}+${RootWindow::x}+${RootWindow::y}
	
	# always on top
	wm attributes 	. -topmost 1
	
	# the resize grip
	ttk::sizegrip	.ttksgResize
	pack .ttksgResize -side top -fill x
}
namespace eval Icon {
	namespace eval Unicode {
		variable Dot		"\ud83d\udf84"
		variable 3Dots		[string repeat $Icon::Unicode::Dot 3] \
		QuasiFilter			"\u29d6" \
		UpDart 				"\u2b9d" \
		DownDart 			"\u2b9f" \
		DownArrow			"\u25bc" \
		UpBoldArrow			"\ud83e\udc45" \
		DownBoldArrow		"\ud83e\udc47" \
		LeftBarbArrow		"\ud83e\udc60" \
		Save 				"\ud83d\udcbe" \
		FolderOpen 			"\ud83d\udcc2" \
		FolderClosed 		"\ud83d\uddc0" \
		Back 				"\u2190" \
		Reload 				"\u21bb" \
		Folders				"\ud83d\uddc2" \
		Copyright			"\u00a9"
	}
}
namespace eval Util {
	
}
namespace eval About {
	
	# create a toplevel window ; make it invisible (iconify it) ;  'bind' the X button
	toplevel 	.tlAbout
	wm withdraw .tlAbout
	wm protocol .tlAbout WM_DELETE_WINDOW {wm withdraw .tlAbout}
	wm title 	.tlAbout About
	
	
	# [font configure TkDefaultFont] => e.g. -family {Segoe UI} -size 9 -weight normal -slant roman -underline 0 -overstrike 0
	variable fSize [dict get [font configure TkDefaultFont] -size]
	
	#
	label .tlAbout.lL1 -text [wm title .] -font [list -family Tahoma -size [expr {$About::fSize * 2}]]
	label .tlAbout.lL2 -text {A PDF Authoring Tool} -font [list -family Tahoma -size [expr {int($About::fSize * 1.5)}]]
	label .tlAbout.lL3 -text "$Icon::Unicode::Copyright 2020 Abdullah Fatota"
	
	#
	pack .tlAbout.lL1 .tlAbout.lL2 .tlAbout.lL3 -pady 10 -padx 2cm
	
}
namespace eval MainPane {
	
	variable background coral
	
	#
	panedwindow .pwPane -showhandle 1 -sashwidth 10 -sashpad 20 -sashrelief raised -handlepad 0 -background $MainPane::background
	pack .pwPane -expand 1 -fill both -side bottom

}
namespace eval Files {
	# aesthetic properties
	variable lfRelief ridge toolbarPad 10 highThickness 2 highColor yellow borderWidth 10 frameBorderWidth 5 parentBg [.pwPane cget -background]
	
	#Icons listbox -textvariable											
	variable Lvar
	
	#Icons listbox -textvariable
	variable Rvar
	
	# -textvariable for other uses
	variable tmpVar
	
	# path of current directory ; index of last highlighted element
	variable dir [pwd]  last_h -1
	
	# (>dirLimit) - files start
	variable dirLimit
	
	# Constructing Windows/Widgets
	# the frame
	labelframe 	.pwPane.lfFiles 	-text {Items in current directory} -relief $Files::lfRelief -borderwidth $Files::frameBorderWidth
	
	# left listbox for Icons
	listbox		.pwPane.lfFiles.lbL		-relief flat -highlightthickness 2 -highlightcolor blue  -background $Files::parentBg -cursor hand2 -activestyle none -selectmode single -listvar Files::Lvar -justify center
	
	# right hand-side listbox for listing files
	listbox 	.pwPane.lfFiles.lbR 	-relief flat -highlightthickness 2 -highlightcolor blue  -background $Files::parentBg -cursor hand2 -activestyle none -selectmode browse -listvar Files::Rvar
	
	# toolbar
	frame 		.pwPane.lfFiles.fToolbar -relief groove -borderwidth 10 -height 50
	
	# scrollbars
	scrollbar 	.pwPane.lfFiles.sbH -orient vertical -relief groove -command {.pwPane.lfFiles.lbR yview}
	scrollbar 	.pwPane.lfFiles.sbV -orient horizontal -relief groove -command {.pwPane.lfFiles.lbR xview}
	
	# {...} menu
	menu 		.pwPane.lfFiles.mDots 	-tearoff 0
	
	# toolbar elements
	button 		.pwPane.lfFiles.fToolbar.bFilter 	-text "$Icon::Unicode::QuasiFilter Filter PDF Files"			-relief groove -overrelief solid
	button 		.pwPane.lfFiles.fToolbar.bReload 	-text "$Icon::Unicode::Reload Reload"							-relief groove -overrelief solid
	button 		.pwPane.lfFiles.fToolbar.bCd 		-text "$Icon::Unicode::FolderOpen List via OS' File explorer" 	-relief groove -command {Files::list_ [tk_chooseDirectory -initialdir $Files::dir]}  -overrelief solid
	button 		.pwPane.lfFiles.fToolbar.bDots 		-text $Icon::Unicode::3Dots 									-relief groove -overrelief solid
	
	# Invisible Toolbar labels (to be used for event bindings
	label 		.pwPane.lfFiles.fToolbar.lL1 -bg blue
	label 		.pwPane.lfFiles.fToolbar.lL2 -bg red	
	
	
	# toolbar's children ; its length ; Index of which one is last non-hidden button? ; 
	variable toolbarChildren [list ] toolbarChildrenLength 0
	
	#
	variable indexLastOnToolbar
	
	# Index last item in ...  menu
	variable indexLastOnMenu
	
	# its width
	variable Lwidth
	
	# columnconfigure of any button on the toolbar 
	variable Lcolumnconfigure
}
namespace eval Tooltip  {
	set location {}
	set pins 	[dict create]
	set boards 	[dict create]
}
namespace eval Menu {
	
	
	variable labels [dict create \
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
				11 Move  \
				] \
	\
	commands [dict create \
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
			11 {$whoobject rename $whocalled } \
			] \
	\
	cascades [dict create \
			1 .mRoot.mHelp \
			2 {} \
			3 {} \
			4 {} \
			5 {} \
			6 {} \
			7 {} \
			8 {} \
			9 {} \
			10 {} \
			11 {} \
	] \
	all [dict create \
	.mRoot 			[dict create cascades [list 1] commands [list 3 2] cascadesOrder [list 2 ] commandsOrder [list 0 1] separators [list ] separatorsOrder [list ] ] \
	.mDocument 		[dict create cascades [list ] commands [list 5 6 7] cascadesOrder [list ] commandsOrder [list 0 1 2] separators [list ] separatorsOrder [list ] ] \
	.mPage 			[dict create cascades [list ] commands [list 8 9 10 11] cascadesOrder [list ] commandsOrder [list 0 1 3 4] separators [list x] separatorsOrder [list 2] ] \
	.mRoot.mHelp 	[dict create cascades [list ] commands [list 4] cascadesOrder [list ] commandsOrder [list 0] separators [list ] separatorsOrder [list ] ] \
	]
	
	# creation
	dict for {Key Value} $Menu::all {
		menu $Key -tearoff 0
		foreach element [dict get $Value cascades] order [dict get $Value cascadesOrder] { $Key insert $order cascade -label [dict get $Menu::labels $element] -menu [dict get $Menu::cascades $element] }
		foreach element [dict get $Value commands] order [dict get $Value commandsOrder] { $Key insert $order command -label [dict get $Menu::labels $element] -command [dict get $Menu::commands $element] }
		foreach element [dict get $Value separators] order [dict get $Value separatorsOrder] { $Key insert $order separator  }
		
	}
	
	# Enview root's elements. 
	. config -menu .mRoot
	

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
proc Util::get_center [list win [list relative_to {}] ] {
	#Todo: implement relative_to
	set RootWindow::screenW [winfo vrootwidth .]
	set RootWindow::screenH [winfo vrootheight .]
	set w [expr "$RootWindow::screenW / 2 - [winfo width $win]/2"]
	set h [expr "$RootWindow::screenH /2 - [winfo height $win]/2"]
	
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
	wm deicon 	.tlAbout
	wm geometry .tlAbout [Util::get_center .tlAbout]
	#
	#wm attributes .tlAbout -topmost 1
}
proc Files::configure {args} {
	
	
	
	# ... Button Post Menu
	.pwPane.lfFiles.fToolbar.bDots configure -command [list Menu::post .pwPane.lfFiles.fToolbar.bDots .pwPane.lfFiles.mDots]
	.pwPane.lfFiles.mDots add command -label "$Icon::Unicode::UpBoldArrow Bring Up Toolbar"
	##############################################################################################
	
	# Filter PDFs
	bind .pwPane.lfFiles.fToolbar.bFilter <ButtonRelease> {
		set all [.pwPane.lfFiles.lbR get [expr $Files::dirLimit + 1] end]
		#puts [list all -> $all]
		#
		set all [lsearch -all -inline $all *.pdf]
		set Files::Bvar Files::Rvar
		set Files::Rvar $all
	}
	##############################################################################################
	
	# configure L and R to update attached scrollbars
	.pwPane.lfFiles.lbR configure -yscrollcommand {.pwPane.lfFiles.sbH set}
	.pwPane.lfFiles.lbR configure -xscrollcommand {.pwPane.lfFiles.sbV set}
	##############################################################################################
	
	# Occupy a pane in the panedwindow
	.pwPane add .pwPane.lfFiles
	##############################################################################################
	
	# pack the scroll bars
	pack 		.pwPane.lfFiles.sbH -side right 	-fill y
	pack 		.pwPane.lfFiles.sbV -side bottom 	-fill x
	##############################################################################################
	
	# pack the toolbar
	pack .pwPane.lfFiles.fToolbar 		-side top 	-fill x		-padx 10 	-pady 10 -expand 0
	##############################################################################################
	
	# pack the list boxes
	pack .pwPane.lfFiles.lbL 	-side left 	-fill y
	pack .pwPane.lfFiles.lbR 	-side left 	-fill both -expand 1
	##############################################################################################
	
	# grid button(s) on toolbar
	grid .pwPane.lfFiles.fToolbar.bFilter 	-row 0 -column 0 -sticky we	
	grid .pwPane.lfFiles.fToolbar.bReload 	-row 0 -column 1 -sticky we
	grid .pwPane.lfFiles.fToolbar.bCd 		-row 0 -column 2 -sticky we	
	grid .pwPane.lfFiles.fToolbar.bDots 	-row 0 -column 3 -sticky we
	##############################################################################################
	
	# uniform width columns
	grid columnconfigure .pwPane.lfFiles.fToolbar all -weight 1 -minsize 0 -uniform 1
	grid columnconfigure .pwPane.lfFiles.fToolbar 3 -weight 0  -uniform 2
	##############################################################################################
	
	# grid Indicator labels
	grid .pwPane.lfFiles.fToolbar.lL1  -row 1 -column 0 -sticky w -columnspan 3
	grid .pwPane.lfFiles.fToolbar.lL2  -row 2 -column 0 -sticky w -columnspan 3
	##############################################################################################
	
	
	
	# ON visibility DO 
	# 1) set canonical width of any toolbar button
	# 2) set padx for (invisible) labels
	# 3) bind each on <Map> and <Unmap> effictevly to test if visible with the padding applied.
	bind .pwPane.lfFiles.fToolbar.lL1 <Visibility> {
	
		# since Items are returned as LIFO
		set Files::toolbarChildren [lreverse [grid slaves .pwPane.lfFiles.fToolbar -row 0]]
		# except ... menu
		set Files::toolbarChildren [lrange $Files::toolbarChildren 0 end-1]
		set Files::toolbarChildrenLength [llength $Files::toolbarChildren]
		# Index of last button
		set Files::indexLastOnToolbar [expr {$Files::toolbarChildrenLength - 1}]
		# Nothing is there
		set Files::indexLastOnMenu -1
		# its columnconfigure
		set Files::Lcolumnconfigure [grid columnconfigure .pwPane.lfFiles.fToolbar $Files::indexLastOnToolbar]
		# Width of Toolbar - width(... button)
		#set Files::Lwidth [winfo width [lindex $Files::toolbarChildren $Files::indexLastOnToolbar] ]
		set Files::Lwidth [expr { [winfo width .pwPane.lfFiles.fToolbar] - [winfo width .pwPane.lfFiles.fToolbar.bDots] }]
		# Invisible Indicators (by magic of [grid]'s -padx option)
		grid config .pwPane.lfFiles.fToolbar.lL1 -padx [list [expr {$Files::Lwidth / 2 - [winfo width .pwPane.lfFiles.fToolbar.lL1] } ] 0]
		grid config .pwPane.lfFiles.fToolbar.lL2 -padx [list [expr {$Files::Lwidth 	 - [winfo width .pwPane.lfFiles.fToolbar.lL2] } ] 0]


		# bind <Unmap> and <Map>
		bind .pwPane.lfFiles.fToolbar.lL1 <Unmap> {
			set b [lindex $Files::toolbarChildren $Files::indexLastOnToolbar]
			#puts [list b is $b]
			grid forget $b
			# LIFO Order
			.pwPane.lfFiles.mDots insert $Files::indexLastOnToolbar command -label [$b cget -text] -command [$b cget -command]
			incr Files::indexLastOnMenu
			
			grid columnconfigure .pwPane.lfFiles.fToolbar $Files::indexLastOnToolbar -weight 0 -uniform {}
			# quarter the padding distance
			puts [list _newx1 [set _newx1 [list [expr {[winfo width .pwPane.lfFiles.fToolbar] / 2  } ]  0] ]]
			puts [list _newx2 [set _newx2 [list [expr {[winfo width .pwPane.lfFiles.fToolbar] } ]  0]   ]]
			grid config .pwPane.lfFiles.fToolbar.lL1 -padx $_newx1
			grid config .pwPane.lfFiles.fToolbar.lL2 -padx $_newx2
			incr Files::indexLastOnToolbar -1
			}
		bind .pwPane.lfFiles.fToolbar.lL2 <Map> {
			if { $Files::indexLastOnMenu  !=  -1 } {
				set _col_target [expr $Files::indexLastOnToolbar+1]
				set b [lindex $Files::toolbarChildren $_col_target]
				puts [list b is $b ]
				grid $b -row 0 -column $_col_target -sticky we
				.pwPane.lfFiles.mDots delete $Files::indexLastOnMenu
				incr Files::indexLastOnMenu -1
				
				grid columnconfigure .pwPane.lfFiles.fToolbar $_col_target {*}$Files::Lcolumnconfigure
				# x4 x-padding distance
					puts [list _backx1 [set _newx1 [list [expr { [lindex [dict get [grid  info .pwPane.lfFiles.fToolbar.lL1] -padx] 0] * 2  } ]  0]   ]]
					puts [list _backx2 [set _newx2 [list [expr { [lindex [dict get [grid  info .pwPane.lfFiles.fToolbar.lL2] -padx] 0] * 2  } ]  0]   ]]
				
					grid config .pwPane.lfFiles.fToolbar.lL1 -padx $_newx1
					grid config .pwPane.lfFiles.fToolbar.lL2 -padx $_newx2

				incr Files::indexLastOnToolbar
			}
				
		}
		# run all above once.
		bind .pwPane.lfFiles.fToolbar.lL1 <Visibility> {}
	}
	##############################################################################################
	
	
	# when the pointer hovers on the listbox
	bind .pwPane.lfFiles.lbR <Motion> {
		set index [%W index @%x,%y]
		#puts [list index is $index]
		#"deselect" all, costly
		#for [list set len [expr [%W size] - 1]] {$len >= 0} [list incr len -1] { %W itemconfigure $len -background {}}
		#another approach, if the variable holding the last index is not empty, de-highlight it
		# expensive
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $Files::last_h -background {}}
		#hightlight index "cursor" in R
		#
		
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $index -background $Files::highColor}
		#in L
		
		#save that that has been highlighted's index
		set Files::last_h $index
	}
	##############################################################################################
	
	# when it leaves
	bind .pwPane.lfFiles.lbR <Leave> {
		#costly
		#for [list set len [expr [%W size] - 1]] {$len >= 0} [list incr len -1] { %W itemconfigure $len -background {}}
		#un-highlight the last index
		if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $Files::last_h -background {}}
	}
	##############################################################################################
	
	# when an item is selected
	bind .pwPane.lfFiles.lbR <<ListboxSelect>> {
		# current selected Index
		set index 	[%W curselection]
		# what's on it
		set Label 	[.pwPane.lfFiles.lbR get $index]
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
		} elseif {$index < $Files::dirLimit} { set Files::dir [file join $Files::dir $Label];  ;Files::list_ [string cat $Files::dir /] } else {
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
	set Files::dirLimit [expr 1 + [llength $d] ]

	
	#Populate Right listbox
	
	set Files::Rvar [list "$Icon::Unicode::LeftBarbArrow" {*}$d "$Icon::Unicode::DownArrow File(s)" {*}$f]
	
	#Populate Icons
	set Files::Lvar [lrepeat [expr [llength $d ]+ 1 ] $Icon::Unicode::FolderClosed ]
	
	#
	#set index [.pwPane.lfFiles.lbR index @[winfo x .pwPane.lfFiles.lbR],[winfo y .pwPane.lfFiles.lbR] ]
	#
	#.pwPane.lfFiles.lbR itemconfigure $index -background $Files::highColor
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
	set Files::dirLimit [expr [llength $d] + 1]
	
	#right-populate
	set Files::Rvar [ concat "$Icon::Unicode::LeftBarbArrow" $d ]
	
	#left populate with "volume" icon
	set Files::Lvar [lrepeat [expr [llength $d ] + 1 ] $Icon::Unicode::Folders]
	
}
proc Tooltip::place args {
	#Tooltip::place -widget x -anchor 'ne' -show which Board
	Util::args $args -widget -anchor -show
}
	

proc Menu::post {at menu} {
	$menu post [winfo rootx $at ]  [expr [winfo rooty $at ]+[winfo height $at ]]
}
proc NorthBar::create args {
	frame		.fToolbar -borderwidth $NorthBar::border_width -relief flat -background lightblue
	pack 		.fToolbar -side top -fill x
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
	set b [NorthBar::new_button space_block_[incr NorthBar::children_count] -background [.fToolbar cget -background] -state disabled -relief flat pack -expand 0 -fill y]
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
		if {$name eq {}} { set n [string cat .fToolbar {.} button_block_  $NorthBar::children_count] }
	
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
	if ![info exists n] { set n [string cat .fToolbar {.} $name ] } ;					#	set args [lrange $args 1 end]
	
	
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
			{.} config -menu .mRoot
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
	
	
	
	set os [lindex [array get tcl_platform os] 1]
	
	#create and Enview (cause it to be visible) Top strip/Toolbar
	NorthBar::create
	
	
	#create Menu Buttons/Blocks
	# NorthBar::create_menu_buttons
	
	#create the Menu Buttons switch button
	NorthBar::create_menu_buttons_switch
	
	#Test
	NorthBar::new_button {} -type dart -text {Save as PDF} -command {puts [list -> %x %y]} -options [list {Use the built-in File lister} {Use the OS' native File explorer}] -default 1 pack -pady 1

	#enview a [label frame] and rest
	Files::configure
	
	#And populate it with dir items
	Files::list_
	
	
	# For Testing purposes only,
	# Before window creation and visibility it's all 0 0 0...
	puts [list -x [winfo x .pwPane] -y [winfo y .pwPane] \
		  -rootx [winfo rootx .pwPane] -rooty [winfo rooty .pwPane] \
		  -vrootx [winfo vrootx .pwPane] -vrooty [winfo vrooty .pwPane]]
	
	# For Testing purposes only, of .pwPane
	place [button .b -text TempButton -command [list puts [list Only a temporary Button] ]] -x 0 -y 100
	
	
}


main
