# RegularPDF
# Author: Abdullah Fatota
# Description: PDF Authoring Tool

package require Tk
package require TclOO

wm title . RegularPDF
wm geometry . "700x400+[expr [winfo vrootwidth .]/2-350]+[expr [winfo vrootheight .]/2-200]"

#namespace eval Ui {
#	set About .top
#	set MainPane .pane
#	set Files [set ::Ui::MainPane].files
#}

namespace eval Util {
	
}

proc Util::get_center {win {before 1}} {
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
namespace eval About {
	set path_name .top
}


proc About::create {args} {
	toplevel $About::path_name
	wm withdraw $About::path_name
	wm protocol $About::path_name WM_DELETE_WINDOW {wm withdraw $About::path_name}
	wm title $About::path_name About
	#place [button .b -command [list wm deicon $Ui::About]] -x 0 -y 0
	#puts Aboutcreate
}

proc About::show args {
	wm deicon $About::path_name
	wm geometry $About::path_name [Util::get_center $About::path_name]
}
namespace eval MainPane {
	set path_name .pane
}

proc MainPane::create args {
	place [panedwindow $MainPane::path_name -showhandle 1 -sashwidth 10 -sashpad 20 -sashrelief raised -handlepad 0] -x 0 -y 0 -relwidth 1 -relheight 0.9
	#puts MainPanecreate
}

namespace eval Files {
	set path_name [set ::MainPane::path_name].files
}

proc Files::create {args} {
	labelframe $Files::path_name  -text "Items in current directory" -relief ridge -bd 5
	#puts Filecreate
}

namespace eval Menu {
	set root_name .menu
	set sub_help [set Menu::root_name].help
	set document .mDoc
	set page .mPage
}


proc Menu::create args {
	
	menu $Menu::root_name -tearoff 0
	menu $Menu::sub_help -tearoff 0
	
	$Menu::sub_help add command -label About -command About::show 
	$Menu::root_name add cascade -label Help -menu $Menu::sub_help
	$Menu::root_name add command -label Console -command Util::show_console
	$Menu::root_name add command -label Debug -command Util::debug

	$Menu::document add command -label Delete -command {puts .mDoc_delete}
	$Menu::document add separator
	$Menu::document add command -label Clone -command {puts .mDoc_clone}
	$Menu::document add separator
	
	#Context Menu for Pages
	
	$Menu::Page add command -label {Add New Page Above} -command {$whoobject up $whocalled}
	$Menu::Page add separator
	$Menu::Page add command -label {Add New Page Below} -command {$whoobject down $whocalled}
	$Menu::Page add separator
	
	
	$Menu::Page add command -label Delete -command { .mDoc_delete}
	$Menu::Page add separator
	$Menu::Page add command -label Clone -command {$whoobject clone $whocalled }
	$Menu::Page add separator
	$Menu::Page add command -label Move -command {$whoobject rename $whocalled }
}
namespace eval Menu::DocPage {
	#later
}

proc main { } {
	
	Menu::create
	MainPane::create
	About::create
	Files::create
}

main
