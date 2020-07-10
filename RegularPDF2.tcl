# RegularPDF (Code Restructured/Reorganized )
# Author: Abdullah Fatota
# Description: A PDF Authoring Tool

package require Tk
package require TclOO


namespace eval RootWindow {
	set path {.}
}

namespace eval Icon {
	namespace eval Unicode {
		set UpDart 			"\u2b9d"
		set DownDart 		"\u2b9f"
		set UpBoldArrow		"\ud83e\udc45"
		set DownBoldArrow	"\ud83e\udc47"
	}
}

proc RootWindow::modify {} {
	wm title $RootWindow::path RegularPDF
	wm geometry $RootWindow::path "700x400+[expr [winfo vrootwidth $RootWindow::path]/2-350]+[expr [winfo vrootheight $RootWindow::path]/2-200]"

}

namespace eval Util {
	
}

proc Util::get_center [ list win [list relative_to {}] ] {
	#Todo: implement relative_to
	set w [expr "[winfo vrootwidth .]/2 - [winfo width $win]/2"]
	set h [expr "[winfo vrootheight .]/2 - [winfo height $win]/2"]
	
	return +$w+$h
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
namespace eval About {
	set path .top
}


proc About::create {args} {
	toplevel $About::path
	wm withdraw $About::path
	wm protocol $About::path WM_DELETE_WINDOW {wm withdraw $About::path}
	wm title $About::path About
	#puts Aboutcreate
}

proc About::show args {
	wm deicon $About::path
	wm geometry $About::path [Util::get_center $About::path]
}
namespace eval MainPane {
	set path .pane
}

proc MainPane::create args {
	panedwindow $MainPane::path -showhandle 1 -sashwidth 10 -sashpad 20 -sashrelief raised -handlepad 0 -bg coral
	pack $MainPane::path -expand 1 -fill both -side bottom
	#puts MainPanecreate
}

namespace eval Files {
	set path [set ::MainPane::path].files
}

proc Files::create {args} {
	labelframe $Files::path  -text "Items in current directory" -relief ridge -bd 5
	#puts Filecreate
}

namespace eval Menu {
	
	#Root Menus
	set mRoot 		.mRoot
	set mDocument 	.mDocument	
	set mPage 		.mPage
	
	#cascade Root Menus
	set mHelp 		${Menu::mRoot}.mHelp
	
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
	set chRoot			[dict create menu $Menu::mRoot		cascade_1	[dict create 1 $Menu::mHelp] command_1 [list 3 2]]
	set chDocument 		[dict create menu $Menu::mDocument	command_1	[list 5 6 7] ]
	set chPage			[dict create menu $Menu::mPage	command_1	[list 8 9] separator_1 x command_2 [list 10 11]]
	set chHelp 			[dict create menu $Menu::mHelp	command_1	[list 4]]

	 
}

	
proc Menu::create args {
	# Create Menus in the Menu Toolbar, cascade menus, their children commands and associated bindings
	
	#create all Root Menu Widgets
	#get all m* variable names in namespace ::Menu.
	#foreach m [info vars Menu::m*] {
	#	menu [set $m] -tearoff 0
	#}
	foreach m [list $Menu::mRoot $Menu::mDocument $Menu::mPage $Menu::mHelp] { menu $m -tearoff 0 }
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
	$RootWindow::path config -menu $Menu::mRoot
}


namespace eval Menu::DocPage {
	#Todo: later
}

proc Menu::post {at menu} {
	$menu post [winfo rootx $at ]  [expr [winfo rooty $at ]+[winfo height $at ]]
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
	
}

proc NorthBar::create args {
	frame $NorthBar::path -borderwidth $NorthBar::border_width -relief flat -background lightblue
	pack $NorthBar::path -side top -fill x
	# For Testing purposes only.
		#pack [button ${NorthBar::path}.b -text NorthBar] -expand 1
		# 2 Separators
		NorthBar::new_space_block
		NorthBar::new_space_block
		NorthBar::new_button name -text X -relief solid pack -expand 0 -padx 2  -with_separator
}
proc NorthBar::new_space_block args {
	
	# specify the button's attributes to make it behave as a textless block, and then call new_button to create it.
	# Tomodify: space_block_#Replace count here
	set b [NorthBar::new_button space_block_[incr NorthBar::children_count] -background [$NorthBar::path cget -background] -state disabled -relief flat pack -expand 0 -fill y]
	#puts [list [winfo width $b]  [winfo reqwidth $b]]
	
	#append the child
	lappend NorthBar::space_block_children $NorthBar::children_count
	
	return $b
}
proc NorthBar::new_button args {
	
	#++children_count
	incr NorthBar::children_count
	
		# if path/$n/name is empty: .toolbar.button_block_1
		if {[lindex $args 0] eq {}} {set n ${NorthBar::path}.button_block_$NorthBar::children_count  }
	
		# if {#} exists in Button creation arguments:
		if {[set Hashtag [string first {#} $args] ]!= {-1} } { set args [string replace $args $Hashtag $Hashtag $n]  }
	
	#if vertical ttk::separator is present should be put, after the button.							# if vertical is not -1, pop it from $args.
	set vertical [lsearch -exact $args -with_separator] ;									if {$vertical != -1} { set args [lreplace $args $vertical $vertical] ; set vertical 1} else {set vertical 0}
	

	#get name/ partial window path name from $args[0] if it doesn't exist already.			Then 'right shift' the arguments
	if ![info exists n] { set n ${NorthBar::path}.[lindex $args 0] } ;						set args [lrange $args 1 end]
	
	
	
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
	
	
	#create the button.	
	set b [button $n {*}$Attr ]
	
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
			$RootWindow::path config -menu $Menu::mRoot
			#Get all menu buttons
			set all [ lmap e $NorthBar::menu_button_children { concat [dict get $NorthBar::children $e] } ]
			#remove them
			pack forget {*}$all
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Down] 0 0 $Icon::Unicode::DownBoldArrow]
		} else {
			#remove the menu bar
			$RootWindow::path config -menu {}
			#Get all menu buttons
			set all [ lmap e $NorthBar::menu_button_children { concat [dict get $NorthBar::children $e] } ]
			#pack them, before .toolbar.menu_switch
			pack {*}$all -side $NorthBar::direction -before $w
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Up] 0 0 $Icon::Unicode::UpBoldArrow]
		}
}
proc main { } {
	
	#Position the Root window
	RootWindow::modify
	
	#Create on and off-screen Menu's. Enview .mRoot.
	Menu::create
	
	#create and Enview (cause it to be visible) Top strip/Toolbar
	NorthBar::create
	
	
	#create Menu Buttons/Blocks
	NorthBar::create_menu_buttons
	
	#create the Menu Buttons switch button
	NorthBar::create_menu_buttons_switch
	
	#create and Enview [panedwindow]
	MainPane::create
	
	#in-memory create a [label frame]
	Files::create
	
	#create a [toplevel] window, make it invisible (iconify it), and 'bind' the X button
	About::create
	
	# For Testing purposes only,
	# Before window creation and visibility it's all 0 0 0...
	puts [list -x [winfo x $MainPane::path] -y [winfo y $MainPane::path] \
		  -rootx [winfo rootx $MainPane::path] -rooty [winfo rooty $MainPane::path] \
		  -vrootx [winfo vrootx $MainPane::path] -vrooty [winfo vrooty $MainPane::path]]
	
	# For Testing purposes only, of $MainPane::path
	place [button [set RootWindow::path]b -text TempButton -command [list puts [list Only a temporary Button] ]] -x 0 -y 100
}


main
