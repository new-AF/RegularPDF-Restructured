# RegularPDF (Code Restructured/Reorganized)
# Author: Abdullah Fatota
# Description: A PDF Authoring Tool

package require Tk

# Window Path Naming Guide:
# .Prefix_name[.Prefix_name[...]]
# Prefix	-> type of Window
# b		=>	Button
# e		=>	Entry
# f		=>	Frame
# l		=>	Label
# lf	=>	Labelframe
# m		=> 	Menu
# pw 	=>	PanedWindow
# sb	=>	Scrollbar
# tl	=>	Toplevel
# ttknb	=>	ttk::notebook
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

namespace eval CustomSave {
	variable name
	variable extension
	variable path
	variable activeIndex
	variable activeContent
	variable anyway no
	variable topLabel [list {Enter the File Name to be saved (without .pdf extension)} {Enter the File Name as well its Path (relative or absolute)}]
	variable buttonOrder 0
	toplevel 	.tlCustomSave
	wm withdraw .tlCustomSave
	wm protocol .tlCustomSave WM_DELETE_WINDOW {wm withdraw .tlCustomSave}
	wm title 	.tlCustomSave {Save a File}
	frame		.tlCustomSave.fF
	ttk::notebook	.tlCustomSave.fF.ttknbHouse
	#frame		.tlCustomSave.fF.ttknbHouse.fF1
	panedwindow	.tlCustomSave.fF.ttknbHouse.pwF				-orient horizontal -borderwidth 0 -sashrelief raised -handlepad 0 -sashpad 0.1cm
	frame		.tlCustomSave.fF.ttknbHouse.fF2
	label		.tlCustomSave.fF.lL1 						-text	{}
	entry		.tlCustomSave.fF.ttknbHouse.pwF.eName 		-textvariable CustomSave::name 		-relief flat
	entry		.tlCustomSave.fF.ttknbHouse.pwF.eExtension 	-textvariable CustomSave::extension -relief flat -width -1
	entry		.tlCustomSave.fF.ttknbHouse.fF2.ePath 		-textvariable CustomSave::path 		-relief flat

	labelframe	.tlCustomSave.fF.lbStatus					-text {Operation Status} -relief groove
	label		.tlCustomSave.fF.lbStatus.lL1				-text {Ready}
	label		.tlCustomSave.fF.lbStatus.lL2				-text {}
	
	ttk::separator	.tlCustomSave.fF.lbStatus.sDivider1 	-orient horizontal
	labelframe	.tlCustomSave.fF.lbPath						-text {Effective Path} -relief groove
	label		.tlCustomSave.fF.lbPath.lL1					-text {}
	button 		.tlCustomSave.fF.bB1						-text Proceed
	button 		.tlCustomSave.fF.bB2						-text Cancel	-command {
		wm withdraw .tlCustomSave
		set CustomSave::anyway no
	}
	#scrollbar 	.tlCustomSave.fF.ttknbHouse.fF1.sbH 		-orient vertical -relief groove -command {.pwPane.lfFiles.lbR yview}
	#scrollbar 	.tlCustomSave.fF.ttknbHouse.fF1.sbH2 		-orient horizontal -relief groove -command {.pwPane.lfFiles.lbR xview}
	.tlCustomSave.fF.ttknbHouse.pwF.eExtension insert 0 .pdf
	#.tlCustomSave.fF.ttknbHouse add .tlCustomSave.fF.ttknbHouse.fF1 -sticky nswe -text {Specify File Name}
	.tlCustomSave.fF.ttknbHouse add .tlCustomSave.fF.ttknbHouse.pwF -sticky nswe -text {Specify File Name}
	.tlCustomSave.fF.ttknbHouse add .tlCustomSave.fF.ttknbHouse.fF2 -sticky nswe -text {Specify File Path}
	#pack .tlCustomSave.fF.ttknbHouse.fF1.eName .tlCustomSave.fF.ttknbHouse.fF1.sH1 .tlCustomSave.fF.ttknbHouse.fF1.eExtension -side left 
	.tlCustomSave.fF.ttknbHouse.pwF	add .tlCustomSave.fF.ttknbHouse.pwF.eName -sticky nswe -stretch always
	.tlCustomSave.fF.ttknbHouse.pwF	add .tlCustomSave.fF.ttknbHouse.pwF.eExtension
	#pack configure .tlCustomSave.fF.ttknbHouse.fF1.eName -expand 1 -fill both
	#pack configure .tlCustomSave.fF.ttknbHouse.fF1.sH1 -fill y -ipadx 10;#-padx 0.1cm
	pack .tlCustomSave.fF.lbPath.lL1 .tlCustomSave.fF.ttknbHouse.fF2.ePath -expand 1 -fill both
	pack .tlCustomSave.fF.lL1 .tlCustomSave.fF.ttknbHouse .tlCustomSave.fF.lbPath .tlCustomSave.fF.lbStatus -side top -pady 10 -padx 10 -fill x
	pack .tlCustomSave.fF.lbStatus.lL1 .tlCustomSave.fF.lbStatus.lL2 -side top -expand 1 -fill both
	pack .tlCustomSave.fF.bB1 .tlCustomSave.fF.bB2 -side left -expand 1 -fill none -pady 10 -padx 10
	pack .tlCustomSave.fF -expand 1 -fill both
	
	pack configure .tlCustomSave.fF.lL1 -expand 1 -fill none
	bind .tlCustomSave.fF.ttknbHouse <<NotebookTabChanged>> { 
		set CustomSave::activeIndex [%W index current] 
		# triggers trace variables, from onset
		append [lindex [list CustomSave::name CustomSave::path] $CustomSave::activeIndex] {}
		.tlCustomSave.fF.lL1 config -text [lindex $CustomSave::topLabel $CustomSave::activeIndex] }
	
	.tlCustomSave.fF.bB1 config -command {
		try {
			if {$CustomSave::anyway eq {no} && [file exists $CustomSave::activeContent]} {
				.tlCustomSave.fF.lbStatus.lL1 config -text {Above Effective Path Already Exists}
				.tlCustomSave.fF.lbStatus.lL2 config -text "and it's a [lindex [list File. Directory. ] [file isdirectory $CustomSave::name]]"
				
				after 50 {
					CustomSave::shuffleButtons Overwrite
				}
				
				set CustomSave::anyway yes
			} else {
				
				set ch [open [.tlCustomSave.fF.lbPath.lL1 cget -text ] w]
				puts $ch PDFCOntent 
				.tlCustomSave.fF.lbStatus.lL1 config -text Success
				.tlCustomSave.fF.lbStatus.lL2 config -text {}
				set CustomSave::anyway no
				# one last time
				CustomSave::shuffleButtons Proceed
			}
			
			
		} trap {} {msg setDict} {
			CustomSave::shuffleButtons {Try Again}
			.tlCustomSave.fF.lbStatus.lL1 config -text $msg
			.tlCustomSave.fF.lbStatus.lL2 config -text [dict get $setDict -errorcode]
			
		}
	}
	
}
proc CustomSave::shuffleButtons [list [list buttonText Proceed]] {
	.tlCustomSave.fF.bB1 config -text $buttonText
	pack configure .tlCustomSave.fF.bB1 [lindex [list -after -befor] $CustomSave::buttonOrder] .tlCustomSave.fF.bB2
	set CustomSave::buttonOrder [expr {!$CustomSave::buttonOrder}]
}
proc CustomSave::traceName [list before nameOfThisProc empty operation] {
	if {$CustomSave::activeIndex != 0} {return}
	set whatTo [expr {$CustomSave::name eq {}?{}:[string cat [file join $Files::dir $CustomSave::name] $CustomSave::extension]}]
	.tlCustomSave.fF.lbPath.lL1 config -text $whatTo
	set CustomSave::activeContent $CustomSave::name
}
proc CustomSave::tracePath [list before nameOfThisProc empty operation] {
	if {$CustomSave::activeIndex != 1} {return}
	set whatTo [expr {$CustomSave::path eq {}?{}:[file normalize  $CustomSave::path] }]
	.tlCustomSave.fF.lbPath.lL1 config -text $whatTo
	set CustomSave::activeContent $CustomSave::path
	
}

proc CustomSave::configure {} {
	trace add variable CustomSave::name write {CustomSave::traceName before}
	trace add variable CustomSave::extension write {CustomSave::traceName before}
	trace add variable CustomSave::path write {CustomSave::tracePath before}
	
}
proc CustomSave::show {} {
	Util::showToplevel .tlCustomSave
}
# due to Tcl's [::tcl::mathfunc::rand]'s shortfallings
proc Util::semiRandom [list [list subrange 1]] {
	incr subrange -1
	if {$subrange < 0} {
		# Exceptions; while borrowing some Python nomenclature
		throw [list Tcl RangeError RANGE_ZERO_OR_LESS] [list RangeError: subrange must be >= 1 Got ($subrange)]
	}
	return [string range [::tcl::mathfunc::rand] 2 [expr {$subrange + 2}] ]
}

# for 0-based indexing purposes
proc Util::zero_semiRandom [list [list subrange 0]] {
	if {$subrange < 0} {
		# Exceptions; while borrowing some Python nomenclature
		throw [list Tcl RangeError RANGE_LESS_THAN_ZERO] [list RangeError: subrange must be >= 0 Got ($subrange)]
	}
	return [string range [::tcl::mathfunc::rand] 2 [expr {$subrange + 2}] ]
}
proc Util::injectVariablesAndRemoveSwitchesFromAList [list listName args] {
	
	# args -> list of one or more wanted switches
	# emulate (passing by refernce) in Tcl
	upvar 1 $listName targetList
	
	set isPadded no
	#puts [list injectVariablesAndRemoveSwitchesFromAList $targetList $args]
	# spare one
	try {
		set dictList [dict create {*}$targetList ]
	} trap {TCL WRONGARGS} {} {
		set isPadded yes
		set dictList [dict create {*}$targetList {}]
	}
	
	
	#puts [list injectVariablesAndRemoveSwitchesFromAList $dictList $args ]
	
	# inject
	foreach option $args {
		try {
			set afterIndex [dict get $dictList $option]
			set dictList [dict remove $dictList $option]
		} trap {TCL LOOKUP DICT} {} {
			set afterIndex {}
		}
		uplevel 1 "set [string range $option 1 end] {$afterIndex}"
	}
	#puts [list injectVariablesAndRemoveSwitchesFromAList $dictList $args ]
	# remove
	set targetList [list {*}$dictList]
	if {$isPadded} {set targetList [lrange $targetList 0 end-1]}
		
}
proc Util::ifStringFirstFoundReplace [list listName searchString replaceString] {
	upvar 1 $listName targetList
	if { [set Hashtag [string first $searchString $targetList] ]!= {-1} } { set targetList [string replace $targetList $Hashtag $Hashtag $replaceString]  }
}
proc Util::splitOnWord [list listName Words] {
	upvar 1 $listName targetList
	# index of place/pack/grid word.														# the last of those (non-empty ones)
	set index [lmap e $Words {concat [lsearch -exact $targetList $e]}] ;					set index [Util::max $index]

	if {$index == -1} {
		set Attr $targetList
		set Geometry [list]
		
	} else {
		#split args as 1: [button creation arguments (0)- $index-1] 							2: [place/pack/grid INSERTED$name - end]
		set Attr  [lrange $targetList 0 [expr {$index - 1}] ]	;									set Geometry [lrange $targetList $index end ]
	}
	return [list $Attr $Geometry]
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
proc Util::showToplevel [list whichToplevel] {
	wm deicon 	$whichToplevel
	wm geometry $whichToplevel [Util::get_center $whichToplevel]
	#
	#wm attributes .tlAbout -topmost 1
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
proc About::show {} {
	Util::showToplevel .tlAbout
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
	listbox		.pwPane.lfFiles.lbL		-relief flat -highlightthickness 2 -highlightcolor blue  -background $Files::parentBg -cursor hand2 -activestyle none -selectmode single -listvar Files::Lvar -justify center -width -1 -selectforeground {} -selectbackground $Files::parentBg
	
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
	.mRoot 			[dict create 0 {3} 1 {2} 2 {1} commands [list 0 1] separators [list ] cascades [list 2] ] \
	.mDocument 		[dict create 0 {5} 1 {6} 2 {7} commands [list 0 1 2] cascades [list ] separators [list ] ] \
	.mPage 			[dict create 0 {8} 1 {9} 2 {x} 3 {10} 4 {11} commands [list 0 1 3 4] cascades [list ] separators [list 2] ] \
	.mRoot.mHelp 	[dict create 0 {4} commands [list 0] cascades [list ] separators [list ] ] \
	]
	
	# creation
	dict for {Key Value} $Menu::all {
		menu $Key -tearoff 0
		foreach order [dict get $Value cascades] {set element [dict get $Value $order]; $Key insert $order cascade -label [dict get $Menu::labels $element] -menu [dict get $Menu::cascades $element] }
		foreach order [dict get $Value commands] {set element [dict get $Value $order];  $Key insert $order command -label [dict get $Menu::labels $element] -command [dict get $Menu::commands $element] }
		foreach order [dict get $Value separators] {set element [dict get $Value $order];  $Key insert $order separator  }
		
	}
	
	# creation
	
	# Enview root's elements. 
	. config -menu .mRoot
	
	# end
}
namespace eval Menu::DocPage {
	#Todo: later
}
namespace eval Toolbar {

	variable borderWidth 0
	
	frame		.fToolbar -borderwidth $Toolbar::borderWidth -relief flat -background lightblue
	pack 		.fToolbar -side top -fill x
	
	# Left to right, direction of laying elements.
	#set direction left
	
	# to keep track ; its count ; Indicies of Menu buttons in $children ; visiblility? 0/No => Menu Bar is Visible, 1/yes => Menu Buttons are visible ; pack LtR or RtL
	variable children [dict create]  childrenCount 0  menuButtons [list]  areMenuButtonsVisible {No} packSide {left} menuButtonChildren [dict create] menuButtonChildrenCount 0
	

}
proc Toolbar::newPayload [list pathName args] {
	# set the option argument of -Type and remove them from $args
	Util::injectVariablesAndRemoveSwitchesFromAList args -Type -WithSeparator ;#puts [list Vars => [info vars] Type -> $Type Args -> $args] ; if {$Type eq {}} {puts empty}
	if {$Type eq {}} {set Type button}
	
	Util::ifStringFirstFoundReplace args # $pathName
	
	#++childrenCount
	incr Toolbar::childrenCount
	
	lassign [Util::splitOnWord args [list pack grid plcae]] Attr Geom
	
	puts [list Attr => $Attr Geom -> $Geom] 
	
	# creation of button/...
	set pathName [$Type $pathName {*}$Attr]
	
	#store the name/window path of the button as Value to Key $children_count
	dict set Toolbar::children $Toolbar::childrenCount $pathName
	
	#pack/place/grid it
	#{*}$Geometry
	#To ensure conformity to NorthBar::direction.
	switch [lindex $Geom 0] {
		pack {
			{*}[linsert $Geom 1 $pathName] -side $Toolbar::packSide
			# if -with_separator is specified in $args, put a vertical ttk::separator in accordance with NorthBar::direction
			if {$WithSeparator == 1} {
				pack [ttk::separator ${pathName}_separator -orient vertical] -after $pathName -side $Toolbar::packSide -fill y -expand 0 -padx 1
				}
			}
		grid -
		place { throw [list TK UNSUPPORTED UNSUPPORTED_GEOMETRY_MANAGER] [list Only pack GM currently is supported] }
	}
	return $pathName
}
Toolbar::newPayload .fToolbar.bButton1 -relief raised -text 123 -WithSeparator 1 -Type button pack
namespace eval DartButton {} {
	# numbering according to Toolbar::childrenCount
	variable children [dict create]
}
proc DartButton::new [list pathName  args] {
	Util::injectVariablesAndRemoveSwitchesFromAList args -variable -Options -DefaultIndex
	set childCount $Toolbar::childrenCount
	puts [list DartButton::new>> $pathName $childCount $args >>]
	#the container
	set contain [frame $pathName -relief flat -borderwidth 1]
	
	#the button
	set b1 [button ${contain}.b1 {*}$args -relief flat ]
	#separator
	set s [ttk::separator ${contain}.s -orient vertical]
	#dart "option" button; to trigger a menu of options (not tk_optionMenu)
	set b2 [button ${contain}.b2 -relief [$b1 cget -relief] -text "$Icon::Unicode::DownDart"]
	#the menu
	set m [menu ${contain}.m -tearoff 0]
	
	#by controlling -variable sets the default radiobutton
	if {$variable eq {}} {
		set variable DartButton::variable$childCount
		# create it in the name space
		variable variable$childCount {}
	} elseif ![info exists $variable] {
		set $variable {}
	}
	# add option; 0 => buit-in file lister . 1 => OS' native
	foreach op $Options value [Util::len_range 0 [llength $Options]] { $m add radiobutton -label $op -value $value -variable $variable}
	
	# set default
	set $variable $DefaultIndex
	
	#dict set NorthBar::dart_children $NorthBar::cildren_count [dict create]
	dict set DartButton::children $childCount $contain
	
	pack $b1 $s $b2 -side $Toolbar::packSide
	pack configure $s -fill y
	
	#config. Todo:Complete the implementation
	$b2 config -command "Menu::post $b2 $m"
	
	#Emulating -overrelief
	bind $contain <Enter> "$contain config -relief groove"
	bind $contain <Leave> "$contain config -relief flat"
	
	return $contain
}
namespace eval NorthBar {}


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
			# if C:/ D:/ or even /													list volumes			otherwise list the up/dir, glob demands an / on end
			if { $Files::dir in [set volumes [file volumes]] } { set Files::dir / ; Files::list_volumes $volumes } else { Files::list_ [string cat $Files::dir /] }
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

proc NorthBar::new_space_block args {
	
	# specify the button's attributes to make it behave as a textless block, and then call new_button to create it.
	# Tomodify: space_block_#Replace count here
	#set b [NorthBar::new_button space_block_[incr NorthBar::children_count] -background [.fToolbar cget -background] -state disabled -relief flat pack -expand 0 -fill y]
	#puts [list [winfo width $b]  [winfo reqwidth $b]]
	
	#append the child
	#lappend NorthBar::space_block_children $NorthBar::children_count
	
	#return $b
}


proc Toolbar::createMenuButtons args {
	# Create .toolbar.menu_button_x
	
	set mRootChildren [dict get $Menu::all .mRoot]
	dict for {order i} $mRootChildren {
		if {$order in [dict get $mRootChildren cascades]} {
			# {#} will be replaced with name/path of the button
			dict set Toolbar::menuButtonChildren .fToolbar.bMB[incr Toolbar::menuButtonChildrenCount] [dict get $Menu::labels $i] 
			Toolbar::newPayload .fToolbar.bMB$Toolbar::menuButtonChildrenCount -Type button  -text [dict get $Menu::labels $i] -command "Menu::post # [dict get $Menu::cascades $i]" -relief flat -overrelief groove pack
			#lappend NorthBar::menu_button_children $NorthBar::children_count
			} elseif {$order in [dict get $mRootChildren commands]} {
			dict set Toolbar::menuButtonChildren .fToolbar.bMB[incr Toolbar::menuButtonChildrenCount] [dict get $Menu::labels $i] 
			Toolbar::newPayload .fToolbar.bMB$Toolbar::menuButtonChildrenCount -Type button  -text [dict get $Menu::labels $i] -command [dict get $Menu::commands $i] -relief flat -overrelief groove pack
			#lappend NorthBar::menu_button_children $NorthBar::children_count
		}
	}
}

proc Toolbar::createSwitchMenusButton args {
	#Assmes position (it's has been called after create_menu_buttons etc...)
	
	
	# get full window path of the new button
	lassign [Toolbar::newPayload .fToolbar.bMenuSwitch -relief flat -overrelief groove -text "$Icon::Unicode::UpBoldArrow Bring Up Menu"  pack] b
	
	#then send it, in command
	$b config -command [list Toolbar::switchMenus $b]
	
}
proc Toolbar::switchMenus w {
	#$w => full window path of the Switch Button
	
	#the switch button's  text
	set text [$w cget -text]
	
	#str => {Up} or {Down}
	set str [lindex $text 2]
	
	if {$str eq {Up}} {
			#set the Menu Bar
			{.} config -menu .mRoot
			
			#remove them
			pack forget {*}[dict keys $Toolbar::menuButtonChildren *]
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Down] 0 0 $Icon::Unicode::DownBoldArrow]
		} else {
			#remove the menu bar
			{.} config -menu {}
			
			#pack them, before .toolbar.menu_switch
			pack {*}[dict keys $Toolbar::menuButtonChildren *] -side $Toolbar::packSide -before $w
			#rename the button
			$w config -text [lreplace [lreplace $text 2 2 Up] 0 0 $Icon::Unicode::UpBoldArrow]
		}
}
namespace eval Tabs {
	
	labelframe	.pwPane.lfTabs	-text {Current Tabs} -borderwidth 5	-relief groove
	button		.pwPane.lfTabs.bB0	-text {Create New Document}		-command Tabs::newDocument
	.pwPane add .pwPane.lfTabs		-stretch always
	grid		.pwPane.lfTabs.bB0	-row 0	-column	0	-columnspan 2 -sticky nswe
	
	variable 	documentRowBegin [dict create]		documentRowEnd		[dict create]		documentPageCount [dict create ]		documentCount 0		pages [dict create]		pagesCount 0 	newRow 1
}

proc Tabs::newDocument {} {
	
	incr Tabs::documentCount
	dict set documentRowBegin $Tabs::documentCount	$Tabs::newRow
	dict set documentRowEnd $Tabs::documentCount $Tabs::newRow
	button		.pwPane.lfTabs.bD$Tabs::documentCount	-text "Blank Document $Tabs::documentCount"
	button		.pwPane.lfTabs.bDM$Tabs::documentCount	-text $Icon::Unicode::3Dots		-command "Menu::post .pwPane.lfTabs.bDM$Tabs::documentCount .mDocument"	
	
	grid 		.pwPane.lfTabs.bD$Tabs::documentCount 	-row $Tabs::newRow	-column 0	-sticky we	-pady [list 0.5c 0]
	grid 		.pwPane.lfTabs.bDM$Tabs::documentCount 	-row $Tabs::newRow	-column 1	-sticky es
	
	incr Tabs::newRow
	Tabs::newPage $Tabs::newRow
}
proc Tabs::newPage row {
	
	incr 		Tabs::pagesCount
	dict incr Tabs::documentRowEnd $Tabs::documentCount
	if ![dict exists $Tabs::documentPageCount $Tabs::documentCount] {dict set Tabs::documentPageCount $Tabs::documentCount 1} else {dict incr Tabs::documentPageCount $Tabs::documentCount}
	# page No.
	set no [dict get $Tabs::documentPageCount $Tabs::documentCount]
	#
	button		.pwPane.lfTabs.bP$Tabs::documentCount/$no					-text "Page $no"
	button		.pwPane.lfTabs.bPM$Tabs::documentCount/$no					-text $Icon::Unicode::3Dots		-command "Menu::post .pwPane.lfTabs.bPM$Tabs::documentCount/$no .mPage"
	grid		.pwPane.lfTabs.bP$Tabs::documentCount/$no					-row $row	-column 0 	-sticky we	-padx [list 0.5c 0]
	grid		.pwPane.lfTabs.bPM$Tabs::documentCount/$no					-row $row	-column 1	-sticky	e
	incr Tabs::newRow
}
namespace eval Draw {
	labelframe	.pwPane.lfCanvas
	.pwPane	add .pwPane.lfCanvas -sticky nswe -stretch always
	frame		.pwPane.lfCanvas.fTools -borderwidth 2 -relief groove
	pack .pwPane.lfCanvas.fTools -side left -fill y
	pack [label 		.pwPane.lfCanvas.fTools.lL -text Tools]
	pack [ttk::separator	.pwPane.lfCanvas.fTools.sLine -orient horizontal] -fill x -pady [list 0 0.5c]
	pack [button		.pwPane.lfCanvas.fTools.bB1 -text {Helper Lines} -command Draw::hLines]
	canvas		.pwPane.lfCanvas.cC
	scrollbar	.pwPane.lfCanvas.sbV -orient vertical -command {.pwPane.lfCanvas.cC yview}
	scrollbar	.pwPane.lfCanvas.sbH -orient horizontal -command {.pwPane.lfCanvas.cC xview}
	pack .pwPane.lfCanvas.sbV -side right -fill y
	pack .pwPane.lfCanvas.sbH -side bottom -fill x
	pack .pwPane.lfCanvas.cC -side left -fill both
	.pwPane.lfCanvas.cC configure -xscrollcommand {.pwPane.lfCanvas.sbH set} -yscrollcommand {.pwPane.lfCanvas.sbV set}
	bind .pwPane.lfCanvas.cC <Configure> {%W configure -scrollregion [%W bbox all]}
	
	
	# new page
	.pwPane.lfCanvas.cC 	create rectangle [list 11 11 300 500] -fill {} -outline black
	#variable tTest		.pwPane.lfCanvas.cC create text 8 8 -text 123
	#puts ==[.pwPane.lfCanvas.cC itemcget [] -font]==
	bind .pwPane.lfCanvas.cC <Map> {
		variable ::Draw::cX 	[.pwPane.lfCanvas.cC canvasx 0] ::Draw::cY [.pwPane.lfCanvas.cC canvasy 0]
		variable ::Draw::tTest 	[.pwPane.lfCanvas.cC create text $Draw::cX $Draw::cY -text test -fill {}]
		variable ::Draw::f 		[.pwPane.lfCanvas.cC itemcget $Draw::tTest -font]
		variable ::Draw::fHeight [dict get [font metrics $::Draw::f] -linespace]
		lassign 				[.pwPane.lfCanvas.cC coords {all} ] {} {} ::Draw::cW ::Draw::cH
		Draw::hLines
		bind .pwPane.lfCanvas.cC <Map> {}
	}
}
proc Draw::hLines {} {
	set howMany [expr {int(floor($Draw::cH / $Draw::fHeight))}]
	set count 0
	# 1 line less
	set start [expr {int($Draw::fHeight + $Draw::cY)}]
	while {[incr count] < $howMany} {
		.pwPane.lfCanvas.cC create line $Draw::cX $start $Draw::cW $start -dash .
		incr start $Draw::fHeight
	}
}
proc main { } {
	
	
	
	set os [lindex [array get tcl_platform os] 1]
	
	#create and Enview (cause it to be visible) Top strip/Toolbar
	#NorthBar::create
	
	
	#create Menu Buttons/Blocks
	Toolbar::createMenuButtons
	
	#create the Menu Buttons switch button
	Toolbar::createSwitchMenusButton
	
	#Test
	#NorthBar::new_button {} -type dart -text {Save as PDF} -command {puts [list -> %x %y]} -options [list {Use the built-in File lister} {Use the OS' native File explorer}] -default 1 pack -pady 1
	#fDart1 bc it's a frame
	Toolbar::newPayload .fToolbar.fDart1 -Type DartButton::new -text {Save as PDF} -Options [list {Use the built-in File lister} {Use the OS' native File explorer}] -DefaultIndex 1 -variable ::DartButton::varSaveMenu pack -pady 3 -padx 5
	.fToolbar.fDart1.b1 configure -command {
		[lindex [list CustomSave::show tk_getSaveFile] $DartButton::varSaveMenu]
	}
	
	#enview a [label frame] and rest
	Files::configure
	
	#And populate it with dir items
	Files::list_
	
	
	# For Testing purposes only,
	# Before window creation and visibility it's all 0 0 0...
	puts [list -x [winfo x .pwPane] -y [winfo y .pwPane] \
		  -rootx [winfo rootx .pwPane] -rooty [winfo rooty .pwPane] \
		  -vrootx [winfo vrootx .pwPane] -vrooty [winfo vrooty .pwPane]]
	
	
	CustomSave::configure
	
	# order of panes
	.pwPane paneconfigure  .pwPane.lfCanvas -after  .pwPane.lfFiles
	.pwPane paneconfigure .pwPane.lfTabs -after .pwPane.lfCanvas
}


main
