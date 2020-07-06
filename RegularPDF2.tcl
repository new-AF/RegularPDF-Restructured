# RegularPDF (Code Restructured/Reorganized )
# Author: Abdullah Fatota
# Description: A PDF Authoring Tool

package require Tk
package require TclOO


namespace eval RootWindow {
	set path {.}
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
	set root_name .menu
	set sub_help [set ::Menu::root_name].help
	set document .mDoc
	set page .mPage
}


proc Menu::create args {
	
	menu $Menu::root_name -tearoff 0
	menu $Menu::sub_help -tearoff 0
	
	#On-screen MenuBar-type ones.
	$Menu::sub_help add command -label About -command About::show 
	$Menu::root_name add cascade -label Help -menu $Menu::sub_help
	$Menu::root_name add command -label Console -command Util::show_console
	$Menu::root_name add command -label Debug -command Util::debug

	#Off-screen 'Context' Menus
	menu $Menu::document -tearoff 0
	menu $Menu::page -tearoff 0
	
		#Context Menu for Document Buttons
		$Menu::document add command -label Delete -command {puts .mDoc_delete}
		$Menu::document add separator
		$Menu::document add command -label Clone -command {puts .mDoc_clone}
		$Menu::document add separator
	
	
		#Context Menu for Page Buttons
		$Menu::page add command -label {Add New Page Above} -command {$whoobject up $whocalled}
		$Menu::page add separator
		$Menu::page add command -label {Add New Page Below} -command {$whoobject down $whocalled}
		$Menu::page add separator
		$Menu::page add command -label Delete -command { .mDoc_delete}
		$Menu::page add separator
		$Menu::page add command -label Clone -command {$whoobject clone $whocalled }
		$Menu::page add separator
		$Menu::page add command -label Move -command {$whoobject rename $whocalled }
	
	#Enview On-screen ones
	$RootWindow::path config -menu $Menu::root_name
}


namespace eval Menu::DocPage {
	#Todo: later
}
namespace eval NorthBar {
	set path .toolbar
	set border_width 0
	
	# Left to right, laying of elements.
	set direction left
	# For positioning purposes
	set children [dict create]
	set children_count 0
	# For space_block buttons
	set space_block_count 0
}
proc NorthBar::create args {
	frame $NorthBar::path -borderwidth $NorthBar::border_width -relief flat -background lightblue
	pack $NorthBar::path -side top -fill x
	# For Testing purposes only.
		#pack [button ${NorthBar::path}.b -text NorthBar] -expand 1
		# 2 Separators
		NorthBar::new_space_block
		NorthBar::new_space_block
		NorthBar::new_button name -text Debug -relief solid pack -expand 0 -padx 2  -with_separator
}
proc NorthBar::new_space_block args {
	
	# specify the button's attributes to make it behave as a textless block, and then call new_button to create it.
	set tmp [NorthBar::new_button space_block_[incr NorthBar::space_block_count] -background [$NorthBar::path cget -background] -state disabled -relief flat pack -expand 0 -fill y]
	puts [list [winfo width $tmp]  [winfo reqwidth $tmp]]
	
	return $tmp
}
proc NorthBar::new_button args {
	
	
	#if vertical ttk::separator should be put, after the button.							# if vertical is not -1, pop it from $args.
	set vertical [lsearch -exact $args -with_separator] ;									if {$vertical != -1} { set args [lreplace $args $vertical $vertical] ; set vertical 1} else {set vertical 0}
	

	#the name/ partial window path name. 													Then 'right shift' the arguments
	set n [string cat $NorthBar::path . [lindex $args 0]] ;										set args [lrange $args 1 end]
		
	
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
	
	#store the name/window path of the button as Value to Key ++children_count
	dict set NorthBar::children [incr NorthBar::children_count] $b
	
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
		place { throw [list UNSUPPORTED UNSUPPORTED_GEOMETRY_MANAGER] [list Only pack GM currently is supported] }
	}
	return $b
}
proc main { } {
	
	#Position the Root window
	RootWindow::modify
	
	#Create on and off-screen Menu's. Enview on-screen ones.
	Menu::create
	
	#create and Enview (cause it to be visible) Top strip/Toolbar
	NorthBar::create
	
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
	place [button [set RootWindow::path]b -text TempButton -command Util::show_console] -x 0 -y 100
}

main
