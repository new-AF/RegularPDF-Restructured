# RegularPDF (Code Restructured/Reorganized)
# Author: Abdullah Fatota
# Description: A PDF Authoring Tool

package require Tk

# Window's Path Naming Guide:
# .prefixName[.prefixName[...]]
# Prefix	-> type of Window
# b		=>	Button
# e		=>	Entry
# f		=>	Frame
# l		=>	Label
# lf	=>	Labelframe
# m		=> 	Menu
# pw 	=>	PanedWindow
# sb	=>	Scrollbar
# rb	=> 	ReliefButton
# tl	=>	Toplevel
# ttknb	=>	ttk::notebook
# ttkSG =>	ttk::sizegrip
# ttkSP	=>	ttk::separator

proc eputs args {error $args}
namespace eval RootWindow {
	
	variable wPath {.} \
	width 700 	height 700 	screenW [winfo vrootwidth .] 	screenH [winfo vrootheight .]
	variable x [expr {$screenW / 2 - $width /2}] 	y [expr {$screenH / 2 - $height /2}] os [lindex [array get tcl_platform os] 1]
	
	# center the Root window
	wm title 		. RegularPDF
	wm geometry 	. ${width}x${height}+${x}+${y}
	
	# always on top
	#wm attributes 	. -topmost 1
	
	# the resize grip
	ttk::sizegrip	.ttksgResize
	pack .ttksgResize -side top -fill x
}

namespace eval MainPane {
	
	variable background coral \
	wPath .pwPane
	
	#
	panedwindow $wPath -showhandle 1 -sashwidth 10 -sashpad 20 -sashrelief raised -handlepad 0 -background $background
	pack $wPath -expand 1 -fill both -side bottom

}
namespace eval SecondFrame {
	variable wPath [frame $MainPane::wPath.fSecond -bg red]
		
		variable \
		sbH		[scrollbar $wPath.sbH -orient horizontal -command {$SecondFrame::cC xview}] \
		sbV		[scrollbar $wPath.sbV -orient vertical -command {$SecondFrame::cC yview}] \
		dictId	[dict create] \
		dictY	[dict create] \
		count	0 \
		lastY	0 \
		lastRow 0
		
		variable \
		cC 		[canvas $wPath.cC -background {light blue} -xscrollcommand "$SecondFrame::sbH set" -yscrollcommand "$SecondFrame::sbV set"]
		
		variable \
		sFrame [frame $cC.fScroll -background green]
		
		$cC create window [list 0 0] -window $sFrame -tag win
		
		bind $cC <Configure> {%W configure -scrollregion [%W bbox all] ; }
		
		variable stop no
		
	pack $SecondFrame::sbV -side right -fill y
	#pack $SecondFrame::sbH -side bottom -fill x
	pack $SecondFrame::cC -side left -expand 1 -fill both
	
	

	
	proc add [list path order] {
		#place $Files::wPath -relx 0 -y 0 -relwidth 0.25 -relheight 1
		dict set Toolbar::paneMapPaths $order $path
		grid $path -row 0 -column $order -sticky nswe
		grid columnconfigure $SecondFrame::wPath $order -weight 1  -uniform 1
	}
	
	
	# index as in count, 1-based
	proc show [list lst canFit] {
		if {$SecondFrame::stop} {return}
		; #set args [concat $lst $args]
		#grid columnconfigure $SecondFrame::sFrame all -weight 0 -uniform 1
		#grid rowconfigure $SecondFrame::sFrame all -weight 0 -uniform 1
		
		if {$canFit <= 0} {set canFit 1}
		#puts {}
		set start 0
		set y 0
		set maxWidth [expr {[winfo width $SecondFrame::cC] / ($canFit)}]
		set maxHeight [winfo height $SecondFrame::wPath]
		#Util::verbose
		while {[set sub [lrange $lst $start [expr {$start+$canFit-1}]]] ne {} } {
			#puts [list sub $sub]
			#puts INside
			set x 0
			foreach path $sub {
				place config $path -x $x -y $y -width  $maxWidth -height $maxHeight
				#grid configure $path -row $start -column $column -sticky nswe
				#grid rowconfigure $SecondFrame::sFrame $start -weight 1 -uniform 1
				#grid columnconfigure $SecondFrame::sFrame $column -weight 0 -uniform 1
				puts [list x-y $x $y $path $canFit]
				incr x $maxWidth
			}
			
			incr start $canFit
			incr y $maxHeight
		}
		$SecondFrame::cC moveto win [$SecondFrame::cC canvasx 0] [$SecondFrame::cC canvasy 0]
		$SecondFrame::cC itemconfigure win -height [expr {$y > 0 ? $y : $maxHeight }] -width [winfo width $SecondFrame::cC]
		$SecondFrame::cC configure -scrollregion [$SecondFrame::cC bbox all]
		
	}
	
	
	proc hide [list lst] {
		#set args [concat $lst $args]
		set children [grid slaves $SecondFrame::sFrame]
		foreach path $lst {
			#
			if {$path ni $children} {continue}
			#Util::verbose
			#grid rowconfigure $SecondFrame::sFrame $path -weight 0 -uniform 0
			#grid columnconfigure $SecondFrame::sFrame $path -weight 0 -uniform 0
			grid forget $path
			
			
		}
		
	}
	
	
	

	proc _show [list lst args] {
		set args [concat $lst $args]
		for {set i 0 ; set len [llength $args]} {$i < $len} {} {
			lassign [lrange $args $i  [incr i 3] ] path column _frame
			if ![ReliefButton::isOn $path] {return}
			grid columnconfigure $SecondFrame::wPath $column -weight 1 -minsize 0 -uniform 1
			grid $_frame
		}
	}
	
	proc _hide [list lst args] {
		set args [concat $lst $args]
		for {set i 0 ; set len [llength $args]} {$i < $len} {} {
			lassign [lrange $args $i  [incr i 3] ] path column _frame
			
			grid columnconfigure $SecondFrame::wPath $column -weight 0 -uniform 1
			grid remove $_frame
		}
	}
	
	
}
namespace eval Icon {
	namespace eval Unicode {
		variable Dot		"\ud83d\udf84"
		variable 3Dots		[string repeat $Dot 3] \
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
		Copyright			"\u00a9" \
		DoubleHeadedArrow	"\u2194" \
		NewWindow			"\ud83d\uddd7" \
		HorizontalLines		"\u25a4" \
		Check				"\u2713" \
		Plus				"\u2795"
	}
}
namespace eval Util {
	# due to Tcl's [::tcl::mathfunc::rand]'s shortfallings
	proc semiRandom [list [list subrange 1]] {
		incr subrange -1
		if {$subrange < 0} {
			# Exceptions; while borrowing some Python nomenclature
			throw [list Tcl RangeError RANGE_ZERO_OR_LESS] [list RangeError: subrange must be >= 1 Got ($subrange)]
		}
		return [string range [::tcl::mathfunc::rand] 2 [expr {$subrange + 2}] ]
	}

	# for 0-based indexing purposes
	proc zero_semiRandom [list [list subrange 0]] {
		if {$subrange < 0} {
			# Exceptions; while borrowing some Python nomenclature
			throw [list Tcl RangeError RANGE_LESS_THAN_ZERO] [list RangeError: subrange must be >= 0 Got ($subrange)]
		}
		return [string range [::tcl::mathfunc::rand] 2 [expr {$subrange + 2}] ]
	}
	
	proc injectVariablesAndRemoveSwitchesFromAList [list listName args] {
	
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
	
	proc ifStringFirstFoundReplace [list listName searchString replaceString] {
		upvar 1 $listName targetList
		if { [set Hashtag [string first $searchString $targetList] ]!= {-1} } { set targetList [string replace $targetList $Hashtag $Hashtag $replaceString]  }
	}

	proc splitOnWord [list listName Words] {
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

	proc get_center [list win [list relative_to {}] ] {
		#Todo: implement relative_to
		set RootWindow::screenW [winfo vrootwidth .]
		set RootWindow::screenH [winfo vrootheight .]
		set w [expr "$RootWindow::screenW / 2 - [winfo width $win]/2"]
		set h [expr "$RootWindow::screenH /2 - [winfo height $win]/2"]
		
		return +${w}+${h}
	}
	
	proc show_console {} {
		console show
	}

	proc debug {} {
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
	
	proc max [list a args] {
		#collect all arguments as a list.
		set args [concat $a $args]
		
		return [::tcl::mathfunc::max {*}$args]
	}
	
	proc args {lst args} {
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
	
	proc range [list from to [list by 1]] {
		set ranges 	[list]
		set last	$from
		while { [incr last $by] <= $to } {lappend ranges $last}
		if {$ranges ne {}} {set ranges [linsert $ranges 0 $from]}
		return $ranges
	}
	
	# a hack and a terrible name
	proc len_range [list from to [list by 1]] {
		return [Util::range $from [expr {$to - 1}] $by ]
	}
	
	proc showToplevel [list whichToplevel] {
		wm deicon 	$whichToplevel
		wm geometry $whichToplevel [Util::get_center $whichToplevel]
		#
		#wm attributes .tlAbout -topmost 1
	}

	proc injectVariablesAndRemoveSwitchesFromAList2 {listName args} {
		
		upvar $listName lst
		set want $args
		set toReturn [dict create]
		set rest [list]

		#puts [list newlst -> $lst want -> $want]
		for {set len [llength $lst] ; set i 0} {$i < $len} {} {
		
			if {[set e [lindex $lst $i]] in $want} {
			
				if {[set got [lsearch -exact $lst $e]] != {-1} && [set got [lindex $lst $got+1]] ne {} && [string index $got 0] ne {-}} {dict set toReturn [string range $e 1 end] $got} else {dict set toReturn [string range $e 1 end] No}
				
				puts [list e -> $e got -> $got]
				incr i 2
			} else {
				lappend rest $e
				incr i 1
			}
			
		}
		puts [list REST -> $rest]
		dict for {k v} $toReturn {
			puts [list Upleveling Key $k Value $v]
			uplevel 1 "set $k {$v}"
		}
		set $listName $rest
	}

	proc bindOnce [list on eventType what] {
		bind $on <$eventType> " $what ; bind $on <$eventType> {} "
	}

	proc bindRegular [list on event command] {
		bind $on <$event> "$command"
	}

	proc verbose args {
		# SYNTAX:
		#	Util::verbose -> All variables and their contents in CALLER (unless variable is an array then ARRAY is returned)
		#	Util::verbose [someCommand 123] [another 456] -> Same as above AND values of these commands.
		#	Util:: verbose NO a b c -> Will ONLY Query contents of these variables NAMES (unless a variable is an array)
		if {[lindex $args 0] eq {NO}} {
			set vars [lrange $args 1 end]
			set args [list]
		} else {
			set vars [uplevel 1 {info vars}]
		}
		
		
		puts "
Proc 		-> [expr {[info level] > 1 ? [uplevel 1 {info level 0}] : {TOPLEVEL}}] 
Variables 	-> ($vars)"
		foreach i $vars {
			#puts "puts $i -> (\[set $i\])"
			uplevel 1 "puts \" \[format %10s {$i} \] -> (\[expr {\[array exists {$i}\] ? {ARRAY} :\[set {$i}\]}\])\ \\n \" "
		}
		if [llength $args] {
			puts "Passed \$args Values :="
			foreach i $args {
				puts "[format %10s {}] -> $i"
			}
		}
	}
	

} ; # End of namespace
namespace eval ReliefButton {
	variable on sunken off raised
	proc new [list path args] {
		Util::injectVariablesAndRemoveSwitchesFromAList args -Status -command -WhenOn -WhenOff ; set Status [string tolower $Status]
		set path [button $path {*}$args -relief [if {$Status in [list on off]} {set ReliefButton::$Status} else {concat $ReliefButton::off} ] -command [
			string cat  "ReliefButton::switch $path ;" $command
			]
		]
		if {$WhenOn ne {}}  {
			$path config -command [string cat [$path cget -command] "; if \[ReliefButton::isOn $path\] {$WhenOn}"]
			#puts [list final command =[$path cget -command]=]
		}
		if {$WhenOff ne {}} {
			$path config -command [string cat [$path cget -command] "; if !\[ReliefButton::isOn $path\] {$WhenOff}"]
			#puts [list final command =[$path cget -command]=]
		}
		return $path
	}
	proc isOn path {
		set current [$path cget -relief]
		#Util::verbose
		return [expr {$current eq $ReliefButton::on}]
	}
	proc switch path {
		$path config -relief [lindex [list $ReliefButton::on $ReliefButton::off] [set bool [ReliefButton::isOn $path]]]
		set text [$path cget -text]
		#Util::verbose
		$path config -text [lindex [list [concat $Icon::Unicode::Check $text] [lrange $text 1 end]] $bool]  
	}
}
namespace eval HButtonNS {
	# Highligh Button
	set colorLeave [[button .b123456789 -text {} ] cget -background]
	set colorEnter SkyBlue1; #systemHighlight
	
	bind HButton <Enter> "%W config -background {$colorEnter}"
	
	bind HButton <Leave> "%W config -background {$colorLeave}"
	
	proc doThisOn [list args] {
		foreach _button $args {
			if {{HButton} ni [set all [bindtags $_button]]} {
				bindtags $_button [linsert $all 1 HButton]
				#puts [list tags -> [bindtags $_button]]
			}
		}
	}
	proc new [list args] {
		set _button [button {*}$args]
		HButtonNS::doThisOn $_button
		return $_button
	}
}
proc HButton [list args] {
	HButtonNS::new {*}$args
}
namespace eval CustomSave {
	variable name
	variable extension
	variable path
	variable activeIndex
	variable activeContent
	variable anyway {no} \
	topLabel [list {Enter the File Name to be saved (without .pdf extension)} {Enter the File Name as well its Path (relative or absolute)}] \
	buttonOrder {0} \
	wPath .tlCustomSave
	
	toplevel 			$wPath
	wm withdraw 		$wPath
	wm protocol 		$wPath WM_DELETE_WINDOW {wm withdraw $CustomSave::wPath}
	wm title 			$wPath {Save a File}
	frame				$wPath.fF
	ttk::notebook		$wPath.fF.ttknbHouse
	#frame				$wPath.fF.ttknbHouse.fF1
	panedwindow			$wPath.fF.ttknbHouse.pwF			-orient horizontal -borderwidth 0 -sashrelief raised -handlepad 0 -sashpad 0.1cm
	frame				$wPath.fF.ttknbHouse.fF2
	label				$wPath.fF.lL1 						-text	{}
	entry				$wPath.fF.ttknbHouse.pwF.eName 		-textvariable CustomSave::name 		-relief flat
	entry				$wPath.fF.ttknbHouse.pwF.eExtension -textvariable CustomSave::extension -relief flat -width -1
	entry				$wPath.fF.ttknbHouse.fF2.ePath 		-textvariable CustomSave::path 		-relief flat

	labelframe			$wPath.fF.lbStatus					-text {Operation Status} -relief groove
	label				$wPath.fF.lbStatus.lL1				-text {Ready}
	label				$wPath.fF.lbStatus.lL2				-text {}
	
	ttk::separator		$wPath.fF.lbStatus.sDivider1 		-orient horizontal
	labelframe			$wPath.fF.lbPath					-text {Effective Path} -relief groove
	label				$wPath.fF.lbPath.lL1				-text {}
	button 				$wPath.fF.bB1						-text Proceed
	button 				$wPath.fF.bB2						-text Cancel	-command {
		wm withdraw $wPath
		set CustomSave::anyway no
	}
	#scrollbar 	$wPath.fF.ttknbHouse.fF1.sbH 				-orient vertical -relief groove -command {$Files::wPath.lbR yview}
	#scrollbar 	$wPath.fF.ttknbHouse.fF1.sbH2 				-orient horizontal -relief groove -command {$Files::wPath.lbR xview}
	$wPath.fF.ttknbHouse.pwF.eExtension insert 				0 .pdf
	#$wPath.fF.ttknbHouse add 								$wPath.fF.ttknbHouse.fF1 -sticky nswe -text {Specify File Name}
	$wPath.fF.ttknbHouse add 								$wPath.fF.ttknbHouse.pwF -sticky nswe -text {Specify File Name}
	$wPath.fF.ttknbHouse add 								$wPath.fF.ttknbHouse.fF2 -sticky nswe -text {Specify File Path}
	#pack 													$wPath.fF.ttknbHouse.fF1.eName $wPath.fF.ttknbHouse.fF1.sH1 $wPath.fF.ttknbHouse.fF1.eExtension -side left 
	$wPath.fF.ttknbHouse.pwF add 							$wPath.fF.ttknbHouse.pwF.eName -sticky nswe -stretch always
	$wPath.fF.ttknbHouse.pwF add 							$wPath.fF.ttknbHouse.pwF.eExtension
	#pack configure 										$wPath.fF.ttknbHouse.fF1.eName -expand 1 -fill both
	#pack configure 										$wPath.fF.ttknbHouse.fF1.sH1 -fill y -ipadx 10;#-padx 0.1cm
	pack 													$wPath.fF.lbPath.lL1 $wPath.fF.ttknbHouse.fF2.ePath -expand 1 -fill both
	pack 													$wPath.fF.lL1 $wPath.fF.ttknbHouse $wPath.fF.lbPath $wPath.fF.lbStatus -side top -pady 10 -padx 10 -fill x
	pack 													$wPath.fF.lbStatus.lL1 $wPath.fF.lbStatus.lL2 -side top -expand 1 -fill both
	pack 													$wPath.fF.bB1 $wPath.fF.bB2 -side left -expand 1 -fill none -pady 10 -padx 10
	pack 													$wPath.fF -expand 1 -fill both
	
	pack configure 											$wPath.fF.lL1 -expand 1 -fill none
	bind $wPath.fF.ttknbHouse <<NotebookTabChanged>> { 
		set CustomSave::activeIndex [%W index current] 
		# triggers trace variables, from onset
		append [lindex [list CustomSave::name CustomSave::path] $CustomSave::activeIndex] {}
		$CustomSave::wPath.fF.lL1 config -text [lindex $CustomSave::topLabel $CustomSave::activeIndex] }
	
	$wPath.fF.bB1 config -command {
		try {
			if {$CustomSave::anyway eq {no} && [file exists $CustomSave::activeContent]} {
				$CustomSavew::wPath.fF.lbStatus.lL1 config -text {Above Effective Path Already Exists}
				$CustomSave::wPath.fF.lbStatus.lL2 config -text "and it's a [lindex [list File. Directory. ] [file isdirectory $CustomSave::name]]"
				
				after 50 {
					CustomSave::shuffleButtons Overwrite
				}
				
				set CustomSave::anyway yes
			} else {
				
				set ch [open [$CustomSave::wPath.fF.lbPath.lL1 cget -text ] w]
				puts $ch PDFCOntent 
				$CustomSave::wPath.fF.lbStatus.lL1 config -text Success
				$CustomSave::wPath.fF.lbStatus.lL2 config -text {}
				set CustomSave::anyway no
				# one last time
				CustomSave::shuffleButtons Proceed
			}
			
			
		} trap {} {msg setDict} {
			CustomSave::shuffleButtons {Try Again}
			$CustomSave::wPath.fF.lbStatus.lL1 config -text $msg
			$CustomSave::wPath.fF.lbStatus.lL2 config -text [dict get $setDict -errorcode]
			
		}
	}
	
	
	proc shuffleButtons [list [list buttonText Proceed]] {
		$CustomSave::wPath.fF.bB1 config -text $buttonText
		pack configure $CustomSave::wPath.fF.bB1 [lindex [list -after -befor] $CustomSave::buttonOrder] $CustomSave::wPath.fF.bB2
		set CustomSave::buttonOrder [expr {!$CustomSave::buttonOrder}]
	}
	proc traceName [list before nameOfThisProc empty operation] {
		if {$CustomSave::activeIndex != 0} {return}
		set whatTo [expr {$CustomSave::name eq {}?{}:[string cat [file join $Files::dir $CustomSave::name] $CustomSave::extension]}]
		$CustomSave::wPath.fF.lbPath.lL1 config -text $whatTo
		set CustomSave::activeContent $CustomSave::name
	}
	proc tracePath [list before nameOfThisProc empty operation] {
		if {$CustomSave::activeIndex != 1} {return}
		set whatTo [expr {$CustomSave::path eq {}?{}:[file normalize  $CustomSave::path] }]
		$CustomSave::wPath.fF.lbPath.lL1 config -text $whatTo
		set CustomSave::activeContent $CustomSave::path
		
	}
	proc configure {} {
		trace add variable CustomSave::name write {CustomSave::traceName before}
		trace add variable CustomSave::extension write {CustomSave::traceName before}
		trace add variable CustomSave::path write {CustomSave::tracePath before}
		
	}
	proc show {} {
		Util::showToplevel $CustomSave::wPath
	}

}

namespace eval About {
	variable wPath .tlAbout
	# create a toplevel window ; make it invisible (iconify it) ;  'bind' the X button
	toplevel 	$wPath
	wm withdraw $wPath
	wm protocol $wPath WM_DELETE_WINDOW {wm withdraw $About::wPath}
	wm protocol $wPath WM_DELETE_WINDOW {wm withdraw $About::wPath}
	wm title 	$wPath About
	
	
	# [font configure TkDefaultFont] => e.g. -family {Segoe UI} -size 9 -weight normal -slant roman -underline 0 -overstrike 0
	variable fSize [dict get [font configure TkDefaultFont] -size]
	
	#
	label $wPath.lL1 -text [wm title .] -font [list -family Tahoma -size [expr {$fSize * 2}]]
	label $wPath.lL2 -text {A PDF Authoring Tool} -font [list -family Tahoma -size [expr {int($fSize * 1.5)}]]
	label $wPath.lL3 -text "$Icon::Unicode::Copyright 2020 Abdullah Fatota"
	
	#
	pack $wPath.lL1 $wPath.lL2 $wPath.lL3 -pady 10 -padx 2cm
	
	proc show {} {
		Util::showToplevel $About::wPath
	}
}

namespace eval Files {
	# aesthetic properties
	variable lfRelief ridge toolbarPad 10 highThickness 2 highColor yellow borderWidth 10 frameBorderWidth 5 parentBg [.pwPane cget -background]
	
	variable wPath [ frame 	$SecondFrame::sFrame.lfFiles  -relief $Files::lfRelief -borderwidth $Files::frameBorderWidth ]
	
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
	
	# left listbox for Icons
	listbox		$wPath.lbL		-relief flat -highlightthickness 2 -highlightcolor blue  -background $Files::parentBg -cursor hand2 -activestyle none -selectmode single -listvar Files::Lvar -justify center -width -1 -selectforeground {} -selectbackground $Files::parentBg
	
	# right hand-side listbox for listing files
	listbox 	$wPath.lbR 	-relief flat -highlightthickness 2 -highlightcolor blue  -background $Files::parentBg -cursor hand2 -activestyle none -selectmode browse -listvar Files::Rvar
	
	# toolbar
	frame 		$wPath.fToolbar -relief groove -borderwidth 10 -height 50
	
	# banner
	label		$wPath.lBanner -text {Items in current directory}
	ttk::separator		$wPath.ttkspLine -orient horizontal
	
	# scrollbars
	scrollbar 	$wPath.sbH -orient vertical -relief groove -command {$Files::wPath.lbR yview}
	scrollbar 	$wPath.sbV -orient horizontal -relief groove -command {$Files::wPath.lbR xview}
	
	# {...} menu
	menu 		$wPath.mDots 	-tearoff 0
	
	# toolbar elements
	button 		$wPath.fToolbar.bFilter 	-text "$Icon::Unicode::QuasiFilter Filter PDF Files"			-relief groove -overrelief solid
	button 		$wPath.fToolbar.bReload 	-text "$Icon::Unicode::Reload Reload"							-relief groove -overrelief solid
	button 		$wPath.fToolbar.bCd 		-text "$Icon::Unicode::FolderOpen List via OS' File explorer" 	-relief groove -command {Files::list_ [tk_chooseDirectory -initialdir $Files::dir]}  -overrelief solid
	button 		$wPath.fToolbar.bDots 		-text $Icon::Unicode::3Dots 									-relief groove -overrelief solid
	
	# Invisible Toolbar labels (to be used for event bindings
	label 		$wPath.fToolbar.lL1 -bg blue
	label 		$wPath.fToolbar.lL2 -bg red	
	
	
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
	
	proc configure {args} {
		SecondFrame::add $Files::wPath 1
		# ... Button Post Menu
		$Files::wPath.fToolbar.bDots configure -command [list Menu::post $Files::wPath.fToolbar.bDots $Files::wPath.mDots]
		$Files::wPath.mDots add command -label "$Icon::Unicode::UpBoldArrow Bring Up Toolbar"
		##############################################################################################
		
		# Filter PDFs
		bind $Files::wPath.fToolbar.bFilter <ButtonRelease> {
			set all [$Files::wPath.lbR get [expr $Files::dirLimit + 1] end]
			#puts [list all -> $all]
			#
			set all [lsearch -all -inline $all *.pdf]
			set Files::Bvar Files::Rvar
			set Files::Rvar $all
		}
		##############################################################################################
		
		# configure L and R to update attached scrollbars
		$Files::wPath.lbR configure -yscrollcommand {$Files::wPath.sbH set}
		$Files::wPath.lbR configure -xscrollcommand {$Files::wPath.sbV set}
		##############################################################################################
		
		# pack banner
		pack 		$Files::wPath.lBanner -side top -fill x
		pack		$Files::wPath.ttkspLine -side top -fill x
		##############################################################################################
		
		# pack the scroll bars
		pack 		$Files::wPath.sbH -side right 	-fill y
		pack 		$Files::wPath.sbV -side bottom 	-fill x
		##############################################################################################
		
		# pack the toolbar
		pack $Files::wPath.fToolbar 		-side top 	-fill x		-padx 10 	-pady 10 -expand 0
		##############################################################################################
		
		# pack the list boxes
		pack $Files::wPath.lbL 	-side left 	-fill y
		pack $Files::wPath.lbR 	-side left 	-fill both -expand 1
		##############################################################################################
		
		# grid button(s) on toolbar
		grid $Files::wPath.fToolbar.bFilter 	-row 0 -column 0 -sticky we	
		grid $Files::wPath.fToolbar.bReload 	-row 0 -column 1 -sticky we
		grid $Files::wPath.fToolbar.bCd 		-row 0 -column 2 -sticky we	
		grid $Files::wPath.fToolbar.bDots 	-row 0 -column 3 -sticky we
		##############################################################################################
		
		# uniform width columns
		grid columnconfigure $Files::wPath.fToolbar all -weight 1 -minsize 0 -uniform 1
		grid columnconfigure $Files::wPath.fToolbar 3 -weight 0  -uniform 2
		##############################################################################################
		
		# grid Indicator labels
		grid $Files::wPath.fToolbar.lL1  -row 1 -column 0 -sticky w -columnspan 3
		grid $Files::wPath.fToolbar.lL2  -row 2 -column 0 -sticky w -columnspan 3
		##############################################################################################
		
		
		
		# ON visibility DO 
		# 1) set canonical width of any toolbar button
		# 2) set padx for (invisible) labels
		# 3) bind each on <Map> and <Unmap> effictevly to test if visible with the padding applied.
		bind $Files::wPath.fToolbar.lL1 <Visibility> {
		
			# since Items are returned as LIFO
			set Files::toolbarChildren [lreverse [grid slaves $Files::wPath.fToolbar -row 0]]
			# except ... menu
			set Files::toolbarChildren [lrange $Files::toolbarChildren 0 end-1]
			set Files::toolbarChildrenLength [llength $Files::toolbarChildren]
			# Index of last button
			set Files::indexLastOnToolbar [expr {$Files::toolbarChildrenLength - 1}]
			# Nothing is there
			set Files::indexLastOnMenu -1
			# its columnconfigure
			set Files::Lcolumnconfigure [grid columnconfigure $Files::wPath.fToolbar $Files::indexLastOnToolbar]
			# Width of Toolbar - width(... button)
			#set Files::Lwidth [winfo width [lindex $Files::toolbarChildren $Files::indexLastOnToolbar] ]
			set Files::Lwidth [expr { [winfo width $Files::wPath.fToolbar] - [winfo width $Files::wPath.fToolbar.bDots] }]
			# Invisible Indicators (by magic of [grid]'s -padx option)
			grid config $Files::wPath.fToolbar.lL1 -padx [list [expr {$Files::Lwidth / 2 - [winfo width $Files::wPath.fToolbar.lL1] } ] 0]
			grid config $Files::wPath.fToolbar.lL2 -padx [list [expr {$Files::Lwidth 	 - [winfo width $Files::wPath.fToolbar.lL2] } ] 0]


			# bind <Unmap> and <Map>
			bind $Files::wPath.fToolbar.lL1 <Unmap> {
				set b [lindex $Files::toolbarChildren $Files::indexLastOnToolbar]
				#puts [list b is $b]
				grid forget $b
				# LIFO Order
				$Files::wPath.mDots insert $Files::indexLastOnToolbar command -label [$b cget -text] -command [$b cget -command]
				incr Files::indexLastOnMenu
				
				grid columnconfigure $Files::wPath.fToolbar $Files::indexLastOnToolbar -weight 0 -uniform {}
				# quarter the padding distance
				set _newx1 [list [expr {[winfo width $Files::wPath.fToolbar] / 2  } ]  0]
				set _newx2 [list [expr {[winfo width $Files::wPath.fToolbar] } ]  0]
				grid config $Files::wPath.fToolbar.lL1 -padx $_newx1
				grid config $Files::wPath.fToolbar.lL2 -padx $_newx2
				incr Files::indexLastOnToolbar -1
				}
			bind $Files::wPath.fToolbar.lL2 <Map> {
				if { $Files::indexLastOnMenu  !=  -1 } {
					set _col_target [expr $Files::indexLastOnToolbar+1]
					set b [lindex $Files::toolbarChildren $_col_target]
					#puts [list b is $b ]
					grid $b -row 0 -column $_col_target -sticky we
					$Files::wPath.mDots delete $Files::indexLastOnMenu
					incr Files::indexLastOnMenu -1
					
					grid columnconfigure $Files::wPath.fToolbar $_col_target {*}$Files::Lcolumnconfigure
					# x4 x-padding distance
						#puts [list _backx1 [set _newx1 [list [expr { [lindex [dict get [grid  info $Files::wPath.fToolbar.lL1] -padx] 0] * 2  } ]  0]   ]]
						#puts [list _backx2 [set _newx2 [list [expr { [lindex [dict get [grid  info $Files::wPath.fToolbar.lL2] -padx] 0] * 2  } ]  0]   ]]
					
						grid config $Files::wPath.fToolbar.lL1 -padx $_newx1
						grid config $Files::wPath.fToolbar.lL2 -padx $_newx2

					incr Files::indexLastOnToolbar
				}
					
			}
			# run all above once.
			bind $Files::wPath.fToolbar.lL1 <Visibility> {}
		}
		##############################################################################################
		
		
		# when the pointer hovers on the listbox
		bind $Files::wPath.lbR <Motion> {
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
		bind $Files::wPath.lbR <Leave> {
			#costly
			#for [list set len [expr [%W size] - 1]] {$len >= 0} [list incr len -1] { %W itemconfigure $len -background {}}
			#un-highlight the last index
			if {$Files::last_h > -1 && $Files::last_h < [%W size]} {%W itemconfigure $Files::last_h -background {}}
		}
		##############################################################################################
		
		# when an item is selected
		bind $Files::wPath.lbR <<ListboxSelect>> {
			# current selected Index
			set index 	[%W curselection]
			# what's on it
			set Label 	[$Files::wPath.lbR get $index]
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
	proc list_ [list [list path ./] [list bypass 0] ] {
		
		
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
		#set index [$Files::wPath.lbR index @[winfo x $Files::wPath.lbR],[winfo y $Files::wPath.lbR] ]
		#
		#$Files::wPath.lbR itemconfigure $index -background $Files::highColor
	}
	proc list_volumes lst {
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

}

namespace eval Menu {
	
	variable labels [dict create \
				1 Help \
				2 Debug \
				3 Console \
				4 About \
				5 New  \
				6 {Duplicate} \
				7 Close \
				8 {Add New Page Above} \
				9 {Add New Page Below} \
				10 Delete \
				11 Move  \
				12 {Restore Default} \
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
			12 {} \
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
			12 {} \
	] \
	all [dict create \
	.mRoot 			[dict create 0 {3} 1 {2} 2 {1} commands [list 0 1] separators [list ] cascades [list 2] ] \
	.mDocument 		[dict create 0 {6} 1 {x} 2 {7} commands [list 0 2 ] cascades [list ] separators [list 1] ] \
	.mPage 			[dict create 0 {8} 1 {x} 2 {9} 3 {x} 4 {11} 5 {x} 6 {10} commands [list 0 2 4 6] cascades [list ] separators [list 1 3 5] ] \
	.mRoot.mHelp 	[dict create 0 {4} commands [list 0] cascades [list ] separators [list ] ] \
	.mProperties	[dict create 0 {12} commands [list 0] cascades [list ] separators [list ] ] \
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
	
	proc post {at menu} {
		$menu post [winfo rootx $at ]  [expr [winfo rooty $at ]+[winfo height $at ]]
	}

} ; # end Menu

namespace eval Toolbar {

	variable borderWidth 0
	; # widget path ; to keep track ; its count ; Indicies of Menu buttons in $children ; visiblility? 0/No => Menu Bar is Visible, 1/yes => Menu Buttons are visible ; pack LtR or RtL
	variable \
	wPath  [frame		.fToolbar -borderwidth $Toolbar::borderWidth -relief flat -background lightblue] \
	children [dict create]  \
	childrenCount 0  \
	menuButtons [list]  \
	areMenuButtonsVisible {No} \
	packSide {left} \
	menuButtonChildren [dict create] \
	menuButtonChildrenCount 0 \
	wPath2 [panedwindow .pwPane2 -background green -sashpad 0 -sashwidth 0] \
	maxWidth {No} \
	paneNames [list Files Sequence Properties Tabs] \
	onceStopsId {No} \
	_DrawBarRow 0 \
	_DrawBarColumn 0 \
	
	variable stop no
	
	variable f [frame $wPath2.fF -background blue] \
	paneCount [llength $paneNames]
	
	variable paneRanges [Util::range 1 $paneCount]
	
	variable paneMapNames [dict create {*}[join [lmap i $paneNames j $paneRanges {concat [list $j $i]} ]]] \
	paneMapPaths [dict create ]
	#eputs $paneMapNames
	
	pack 		$wPath -side top  -fill x
	pack 		$wPath2 -side top -fill x
	
	$Toolbar::wPath2 add [frame $Toolbar::wPath2.fDrawBar]
	
	proc wPath2Config {} {
		
		foreach i $Toolbar::paneRanges color [list black green red yellow] bName $Toolbar::paneNames {
			grid [Toolbar::newPayload $Toolbar::f.bB$i -Type ReliefButton::new -text $bName -relief groove -WhenOn "Toolbar::assess" -WhenOff "Toolbar::assess"] -row 0 -column $i -sticky nswe
		}
		
		grid [Toolbar::newPayload $Toolbar::f.lL1 -Type label -text {} -background white				] -row 1 -column 1 -columnspan $Toolbar::paneCount -sticky nsw 
		grid [Toolbar::newPayload $Toolbar::f.lLEnd -Type label -text {} -background white				] -row 2 -column 1 -columnspan $Toolbar::paneCount -sticky nsw 

		
		Util::bindRegular $SecondFrame::wPath Configure {after cancel $Toolbar::onceStopsId ; set Toolbar::onceStopsId [after 50 Toolbar::assess]} 
		
		grid columnconfigure $Toolbar::f $Toolbar::paneRanges -weight 1 -uniform 1

		$Toolbar::wPath2 add $Toolbar::f
		bind $Draw::wPath <Configure> {
			lassign [.pwPane sash coord 0] x y
			$Toolbar::wPath2 sash place 0 [incr x 30] $y
		}
		
		Util::bindOnce ${Toolbar::f} Map {
			variable ::Toolbar::maxWidth [Util::max [set L [lmap e [set L [list Properties Sequence Tabs] ] {concat [winfo reqwidth [set ${e}::wPath]]}] ] ]
			#Util::verbose NO Toolbar::maxWidth
			incr Toolbar::maxWidth [set oneW -[expr {[winfo width %W] / 2}]]
			$MainPane::wPath sash place 0 [expr {[lindex [$MainPane::wPath sash coord 0] 0] + 1}] 1
			$MainPane::wPath sash place 0 [expr {[lindex [$MainPane::wPath sash coord 0] 0] - 1}] 1
			
			variable ::Toolbar::paneIndex $Toolbar::paneCount
		
			
			#dict for {i path} $Toolbar::paneMapPaths {if ![ReliefButton::isOn [set e $Toolbar::f.bB$i]] {grid remove $path}}
		}
		
	}
	proc newPayload [list pathName args] {
		# set the option argument of -Type and remove them from $args
		Util::injectVariablesAndRemoveSwitchesFromAList args -Type -WithSeparator ;#puts [list Vars => [info vars] Type -> $Type Args -> $args] ; if {$Type eq {}} {puts empty}
		if {$Type eq {}} {set Type button}
		
		Util::ifStringFirstFoundReplace args # $pathName
		
		#++childrenCount
		incr Toolbar::childrenCount
		
		lassign [Util::splitOnWord args [list pack grid place]] Attr Geom
		
		#puts [list Attr => $Attr Geom -> $Geom] 
		
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
			place { 
				if {$WithSeparator == 1} {
					throw [list TK UNSUPPORTED UNSUPPORTED_OPTION] [list -WithSeparator Option is not suppoerted in grid/place commands.]
				}
				{*}[linsert $Geom 1 $pathName] 
			}
		}
		return $pathName
	} ; # End newPayload
	
	
	proc newSpaceBlock pathName {
	
		return [Toolbar::newPayload $pathName -background  [$Toolbar::wPath cget -background] -state disabled -relief flat pack -expand 0 -fill y]
		#return $b
	} ; # End newSpaceBlock
	proc createSwitchMenusButton args {
		#Assmes position (it's has been called after create_menu_buttons etc...)
		
		
		# get full window path of the new button
		lassign [Toolbar::newPayload $Toolbar::wPath.bMenuSwitch -relief flat -overrelief groove -text "$Icon::Unicode::UpBoldArrow Bring Up Menu"  pack] b
		
		#then send it, in command
		$b config -command [list Toolbar::switchMenus $b]
		
	}
	proc switchMenus w {
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
	proc createMenuButtons args {
		# Create .toolbar.menu_button_x
		
		set mRootChildren [dict get $Menu::all .mRoot]
		dict for {order i} $mRootChildren {
			if {$order in [dict get $mRootChildren cascades]} {
				# {#} will be replaced with name/path of the button
				dict set Toolbar::menuButtonChildren $Toolbar::wPath.bMB[incr Toolbar::menuButtonChildrenCount] [dict get $Menu::labels $i] 
				Toolbar::newPayload $Toolbar::wPath.bMB$Toolbar::menuButtonChildrenCount -Type button  -text [dict get $Menu::labels $i] -command "Menu::post # [dict get $Menu::cascades $i]" -relief flat -overrelief groove pack
				#lappend NorthBar::menu_button_children $NorthBar::children_count
				} elseif {$order in [dict get $mRootChildren commands]} {
				dict set Toolbar::menuButtonChildren $Toolbar::wPath.bMB[incr Toolbar::menuButtonChildrenCount] [dict get $Menu::labels $i] 
				Toolbar::newPayload $Toolbar::wPath.bMB$Toolbar::menuButtonChildrenCount -Type button  -text [dict get $Menu::labels $i] -command [dict get $Menu::commands $i] -relief flat -overrelief groove pack
				#lappend NorthBar::menu_button_children $NorthBar::children_count
			}
		}
	}
	proc moveBack {} {
		
	
		if {$Toolbar::paneIndex == $Toolbar::paneCount} {
			set i -1
			set a 0
			set b -$Toolbar::maxWidth
		} elseif {$Toolbar::paneIndex == 1} {
			set i 0
			set a 0
			set b 0
			return
		} else {
			set i -1
			set a -$Toolbar::maxWidth
			set b -$Toolbar::maxWidth
		}
		
		puts [list moveBack i,a,b -> $i $a $b]
		SecondFrame::hide $Toolbar::paneIndex
		incr Toolbar::paneIndex $i
		grid configure [set widget ${Toolbar::f}.lL1] -padx [list [incr Toolbar::aPad $a] 0] 			
		grid configure [set widget ${Toolbar::f}.lLEnd] -padx [list [incr Toolbar::bPad $b] 0]
		
	}	
	
	proc moveForeward {} {
		
		
		if {$Toolbar::paneIndex == $Toolbar::paneCount} {
			set i 0
			set a 0
			set b 0
			return
		} elseif {$Toolbar::paneIndex == $Toolbar::paneIndexBefore} {
			set i 1
			set a 0
			set b $Toolbar::maxWidth
		} else {
			set i 1
			set a $Toolbar::maxWidth
			set b $Toolbar::maxWidth
		}
		
		puts [list moveForeward i,a,b -> $i $a $b]
		incr Toolbar::paneIndex $i
		SecondFrame::show $Toolbar::paneIndex
		grid configure [set widget ${Toolbar::f}.lL1] -padx [list [incr Toolbar::aPad $a] 0] 			
		grid configure [set widget ${Toolbar::f}.lLEnd] -padx [list [incr Toolbar::bPad $b] 0] 
		#SecondFrame::show $Toolbar::pa
	}
	
	
	

	proc assess [list [list which no] ] {
		if {$Toolbar::stop} {return}
		set width [winfo width $SecondFrame::wPath]
		set canFit [expr {$width / $Toolbar::maxWidth}]
		
		#Util::verbose $Toolbar::paneMapNames $Toolbar::paneMapPaths
		set yes [list]
		set no [list]
		foreach i $Toolbar::paneRanges {
			
			lappend [lindex [list no yes ] [ReliefButton::isOn $Toolbar::f.bB$i]] [dict get $Toolbar::paneMapPaths $i]
			
		}
		#puts [list canFit $canFit \n]
		#Util::verbose
		#SecondFrame::show [Util::range 1 $canFit]
		#SecondFrame::hide [Util::range [expr {$canFit + 1 }] $Toolbar::paneCount]
	
		set canFit [::tcl::mathfunc::min [llength $yes] $canFit ]
	
		SecondFrame::show $yes $canFit
		SecondFrame::hide $no
		
	}
	
	proc indexToPath [list index] {
		#Util::verbose Toolbar::paneMapNames Toolbar::paneMapPaths
		set i [dict get $Toolbar::paneMapPaths $index]
		#
		return $i
	}
	
	proc addToDrawBar [list name args] {
		set parent $Toolbar::wPath2.fDrawBar
		set name [string replace $name [set i [string first # $name]] $i ${parent}.]
		
		if ![winfo exists ${parent}.l5] {
			grid [label ${parent}.l5 -text {} -background [$parent cget -background]] -row 0 -column 5 -sticky we
		}
		set w [eval "$name $args"]
		
		if {[incr Toolbar::_DrawBarColumn] > 5} {
			set Toolbar::_DrawBarColumn 0
			incr Toolbar::_DrawBarRow
			
		}
		grid $w -row $Toolbar::_DrawBarRow -column $Toolbar::_DrawBarColumn -sticky nswe
		grid columnconfigure $Toolbar::wPath2.fDrawBar all -weight 1 -uniform 1
		# why is -unifor 0 necessary
		grid columnconfigure $Toolbar::wPath2.fDrawBar 5 -weight 0 -uniform 0 -pad [expr {[$MainPane::wPath cget -sashpad] +[$MainPane::wPath cget -sashwidth]}]
		grid rowconfigure $Toolbar::wPath2.fDrawBar all -weight 1 -uniform 1
		
	}

} ; # End of Toolbar

Toolbar::newPayload $Toolbar::wPath.bButton1 -relief raised -text 123 -WithSeparator 1 -Type button pack
namespace eval DartButton {} {
	# numbering according to Toolbar::childrenCount
	variable children [dict create]
	
	proc new [list pathName args] {
		Util::injectVariablesAndRemoveSwitchesFromAList args -variable -Options -DefaultOption -command
		set childCount $Toolbar::childrenCount
		#puts [list DartButton::new>> $pathName $childCount $args >>]
		#the container
		set contain [frame $pathName -relief flat -borderwidth 1]
		#the button
		set b1 [button ${contain}.b1 {*}$args -relief flat -command $command] 
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
		
		# set default -> index
		set $variable $DefaultOption
		
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

}



namespace eval Draw {
	variable \
	wPath [labelframe $MainPane::wPath.lfCanvas]
	
	.pwPane	add $wPath -sticky nswe -stretch always
	
	canvas		$wPath.cC
	
	scrollbar	$wPath.sbV -orient vertical -command {$Draw::wPath.cC yview}
	scrollbar	$wPath.sbH -orient horizontal -command {$Draw::wPath.cC xview}
	
	pack $wPath.sbV -side right -fill y
	
	pack $wPath.sbH -side bottom -fill x
	
	pack $wPath.cC -side left -expand 1 -fill both
	
	$wPath.cC configure -xscrollcommand {$Draw::wPath.sbH set} -yscrollcommand {$Draw::wPath.sbV set}
	
	bind $wPath.cC <Configure> {Draw::onConfigure %w %h}
	
	Util::bindOnce $wPath.cC Map Draw::onMap
	
	proc onMap {} {
		variable \
		::Draw::textTest 	[$Draw::wPath.cC create text 0 0 -text test -fill {}]
		variable \
		::Draw::font 		[$Draw::wPath.cC itemcget $Draw::textTest -font] 
		variable \
		::Draw::fontHeight [dict get [font metrics $::Draw::font] -linespace]
	}
	
	proc onConfigure [list w h] {
		puts Configured
		$Draw::wPath.cC configure -scrollregion [$Draw::wPath.cC bbox all]
		variable \
		::Draw::cW		$w \
		::Draw::cH		$h \
		::Draw::cZeroX		[$Draw::wPath.cC canvasx 0] \
		::Draw::cZeroY 		[$Draw::wPath.cC canvasy 0] \
		#puts [list Draw Configure]
		#eputs $Draw::pCoords
	}
	
	proc updateAndExtractCoords {} {
		Draw::onConfigure
		foreach i $Draw::pCoords j [list pX pY pX2 pY2] {
			variable ::Draw::$j [::tcl::mathfunc::int $i]
		}
		variable \
		::Draw::pH [expr {int($Draw::pY2 - $Draw::pY)}] \
		::Draw::pW [expr {int($Draw::pX2 - $Draw::pX)}]
	}
	
}

namespace eval Tooltip  {
	variable pBG {light yellow} 
	variable wPath [frame .fTooltip -background $pBG -highlightcolor black -highlightthickness 1] \
	title	[dict create] \
	text	[dict create] \
	waitTimeInMS 700
	variable x
	variable y
	variable showTitle
	variable showText
	variable lastAfterId {}
	pack [label $wPath.lUp -bg $pBG] [label $wPath.lDown -bg $pBG -wraplength [font measure TkDefaultFont -displayof $Tooltip::wPath.lUp {Horizontal Guiding Lines}]] -side top

	proc new [list on title text ] {
		dict set Tooltip::title $on $title
		dict set Tooltip::text $on $text
		bind $on <Motion> {Tooltip::onMotion %W} ;
		bind $on <Enter> "Tooltip::onEnter $on" ; # %x %y with <Enter> USELESS
		bind $on <Leave> Tooltip::onLeave
		$on config -command [string cat [$on cget -command] {; after cancel $Tooltip::lastAfterId}]
	} ; # End new

	proc show {} {
		#puts [list -> [place configure $Tooltip::wPath -x $Tooltip::x -y $Tooltip::y ] [focus $Tooltip::wPath]  [winfo width $Tooltip::wPath.lUp] => [info vars]]
		place configure $Tooltip::wPath -x $Tooltip::x -y $Tooltip::y
		focus $Tooltip::wPath
		$Tooltip::wPath.lUp config -text $Tooltip::showTitle
		$Tooltip::wPath.lDown config -text $Tooltip::showText 
	} ; # End show

	proc onMotion [list w] {
		#set Tooltip::x [expr {[winfo pointerx .] - [winfo rootx .]}] ; Tooltip::x [winfo x $w] ; puts [list $Tooltip::x $Tooltip::y]
		set Tooltip::x [winfo width [winfo parent $w]]
		set Tooltip::y [expr {[winfo pointery .] - [winfo rooty .]}]
	} ; # End onMotion
	
	proc onEnter [list on ] {
		if {$Tooltip::lastAfterId ne {}} {after cancel $Tooltip::lastAfterId}
		set Tooltip::showTitle		[dict get $Tooltip::title $on]
		set Tooltip::showText		[dict get $Tooltip::text $on]
		set Tooltip::lastAfterId	[after $Tooltip::waitTimeInMS {puts [Tooltip::show]}]
	} ; # End onEnter
	
	proc onLeave {} {
		after cancel $Tooltip::lastAfterId
		set Tooltip::lastAfterId {}
		place forget $Tooltip::wPath
	} ; # End onLeave
}

namespace eval Tools {
	variable wPath [frame	$Draw::wPath.fTools -borderwidth 2 -relief groove]
	pack $wPath -side left -fill y -before $Draw::wPath.cC
	pack [label 			$wPath.lL -text Tools]
	pack [ttk::separator	$wPath.ttkspH -orient horizontal] -fill x
	pack [button			$wPath.bB1 -text $Icon::Unicode::HorizontalLines -command {HLines::new}  -relief flat -overrelief groove] -fill x
	Tooltip::new $wPath.bB1 {Guiding Horizontal Lines} {A grid's horizontal lines which facilitate writing text onto multiple lines.}
}
namespace eval Properties {
	variable \
	wPath [frame $SecondFrame::sFrame.fProperties -borderwidth 2 -relief groove] \
	labelToWidget [dict create]
	SecondFrame::add $wPath 3
	# Title & Separator
	pack [label	$wPath.lBanner -text Properties] -side top -fill x
	pack [ttk::separator $wPath.ttkspLine -orient horizontal] -side top -fill x -pady [list 0 0.25c]
	label $wPath.lClear -text {No Object is currently selected}

	frame 		$wPath.fInfo
	label		$wPath.fInfo.lLabelName -text {Object's Name}
	label		$wPath.fInfo.lName -text {}
	label		$wPath.fInfo.lLabelType -text {Object's Type}
	label		$wPath.fInfo.lType -text {}
	
	Util::bindOnce $Properties::wPath.lBanner Map {Properties::clear}
	
	proc restore {} {
		if {{$Properties::wPath.fInfo} in [pack slaves $Properties::wPath]} return
		pack forget $Properties::wPath.lClear
		pack $Properties::wPath.fInfo								-side top -fill both
		grid columnconfigure $Properties::wPath.fInfo 1 			-weight 1
		grid columnconfigure $Properties::wPath.fInfo [list 2 3]	-weight 0
		grid $Properties::wPath.fInfo.lLabelName 					-row 0 -column 0 -sticky w
		grid $Properties::wPath.fInfo.lName							-row 0 -column 2 -sticky w
		grid $Properties::wPath.fInfo.lLabelType					-row 1 -column 0 -sticky w
		grid $Properties::wPath.fInfo.lType							-row 1 -column 2 -sticky w
		
	}
	proc map [list realId namespaceName] {
		
		Properties::restore
		set all [lrange [winfo children $Properties::wPath.fInfo ] 5 end]
		if {$all ne {}} {grid forget {*}$all}
		Properties::name $realId
		Properties::type $namespaceName
		set count 2
		dict for {i j} [set ${namespaceName}::property] {
			
			set word $namespaceName^$i ;# HLines^Width
			set call ${namespaceName}::$j ;# HLines::spin
			if ![dict exists $Properties::labelToWidget $Properties::wPath.fInfo.lLabel$word] {
				dict set Properties::labelToWidget $Properties::wPath.fInfo.lLabel$word [set w [$call new $Properties::wPath.fInfo $i $realId] ]
				label $Properties::wPath.fInfo.lLabel$word -text "Object's $i"
				
			} else {
				set w [dict get $Properties::labelToWidget $Properties::wPath.fInfo.lLabel$word]
			}
			
		
			$call setFrom $w $i $realId
			
			grid $w -row $count -column 2 -sticky w
			grid $Properties::wPath.fInfo.lLabel$word -row $count -column 0 -sticky w
			grid [button $Properties::wPath.fInfo.bMenu$word -text $Icon::Unicode::3Dots -command "Menu::post $Properties::wPath.fInfo.bMenu$word .mProperties"] -row $count -column 3 -sticky e
			incr count
		} ; #End dict for
		
	}
	proc name [list [list passed {}]] {
		
		return [$Properties::wPath.fInfo.lName {*}[expr {$passed ne {} ? "config -text #$passed" : {cget -text} }] ]
	}
	
	proc type [list [list passed {}]] {
	
		return [$Properties::wPath.fInfo.lType {*}[expr {$passed ne {} ? "config -text $passed" : {cget -text} }] ]
	}
	 
	
	proc clear {} {
		$Properties::wPath.lClear config -wraplength [winfo width $Properties::wPath]
		$Properties::wPath.lClear config -state disabled
		pack forget $Properties::wPath.fInfo
		pack $Properties::wPath.lClear -fill none -expand 1
		#Properties::clear
	}
	
	
}
namespace eval Sequence {
	variable \
	wPath [frame $SecondFrame::sFrame.fSequence -borderwidth 2 -relief groove] \
	colCount 4 \
	colList [list 0 1 2 3] \
	colLabels [list Order {Instance Type} {Instance Count} Tag]
	
	SecondFrame::add $wPath 2
	
	variable \
	tree [ttk::treeview $wPath.ttktrTree -columns $colList] \
	orderToId [dict create] \
	orderToType [dict create] \
	count 0
	
	pack $tree -expand 1 -fill both 
	
	foreach i $colList j $colLabels {$tree heading $i -text $j -anchor center ; $tree column $i -anchor center}
	
	$tree column #0 -width 0
	
	
	bind $tree <Button> {
		#puts [list [set colId [%W identify row %x %y]]]
		set values [%W item $colId -values]
		Properties::map [string range [lindex $values 2] 1 end] [lindex $values 1] }
	
	# id -> realId ; type -> namespace
	proc add [list id type] {
		dict set Sequence::orderToId [incr Sequence::count ] $id
		dict set Sequence::orderToType $Sequence::count  $type
		$Sequence::tree insert {} $Sequence::count -id $type$id -values [list $Sequence::count $type #$id {}]
	}
}

namespace eval Document {
	variable \
	activeDocCount No \
	modded No 	background [$Draw::wPath.cC config -background]		clearId {}
	
	variable 	documentRowBegin [dict create]		documentRowEnd		[dict create]		documentPageCount [dict create ]		documentCount 0
	
	proc updateScrollRegion {} {
		$Draw::wPath.cC config -scrollregion [$Draw::wPath.cC bbox all]
	}
	proc trackCenter {enable func} {
		"Document::[expr {$enable == 1? {} : {de}}]activateEventCommand" $Draw::wPath.cC <Configure> $func
	}
	proc clear {} {
		if {$Document::clearId eq {}} {
			variable ::Document::parentClearWidget [frame $Draw::wPath.cC.fP]
			variable ::Document::clearWidget [frame $Draw::wPath.cC.fP.fClear ]
			
			grid [set l1 [label $Document::clearWidget.lL1 -text "There are curently no active Documents.\nTo create a new Document Plaese click on"]] -row 0 -column 0 -columnspan 3 -sticky we
			grid [set rb1 [ReliefButton::new $Document::clearWidget.rfBX -text {Tabs}]] -row 1 -column 0 -columnspan 1 -sticky we
			grid [set l2 [label $Document::clearWidget.lL2 -text {then}]] -row 1 -column 1 -columnspan 1 -sticky we
			grid [set l3 [label $Document::clearWidget.lL3 -text $Icon::Unicode::Plus]] -row 1 -column 2 -columnspan 1 -sticky we
			
			grid columnconfigure $Document::clearWidget all -weight 1 -uniform 1
			
			place $Document::clearWidget -x 0 -y 0 -relwidth 1 -relheight 1
			
			set Document::clearId [$Draw::wPath.cC create window 0 0 -window $Document::parentClearWidget]
			
			Document::center $Document::clearId
			
			#eputs [list 123 [$Draw::wPath.cC bbox $Document::clearId ]]
			
			Util::bindOnce $Document::clearWidget Map {Document::clearMap %W}
		}
	}
	proc hideClear {} {
		$Draw::wPath.cC itemconfig $Document::clearId -width 0 -height 0
		Document::updateScrollRegion
	}
	proc showClear {} {
		lassign [list [winfo reqwidth $Document::clearWidget] [winfo reqheight $Document::clearWidget] ] w h
		$Draw::wPath.cC itemconfig $Document::clearId -width $w -height $h
		Document::updateScrollRegion
	}
	proc clearMap {W} {
		puts mapped
		lassign [list [winfo reqwidth $W] [winfo reqheight $W] ] w h
		foreach i [winfo children $W] {$i config -state disabled}
		#Util::verbose
		#Document::center2X $Document::clearId $w
		$Draw::wPath.cC itemconfig $Document::clearId -width $w -height $h
		Document::updateScrollRegion
		Document::trackCenter 1 "Document::center2X $Document::clearId $w"
	}
	proc center [list id] {
		lassign [$Draw::wPath.cC bbox $id ] x y w h
		#Util::verbose
		set x [expr {$Draw::cW /2 - $w /2}]
		set y [expr {$Draw::cH /2 - $h /2}]
		$Draw::wPath.cC moveto $id $x $y
	}
	proc center2 [list id w h] {
		#Util::verbose
		set x [expr {$Draw::cW /2 - $w /2}]
		set y [expr {$Draw::cH /2 - $h /2}]
		$Draw::wPath.cC moveto $id $x $y
	}
	proc center2X [list id w] {
		#Util::verbose
		set x [expr {$Draw::cW /2 - $w /2}]
		$Draw::wPath.cC moveto $id $x {}
	}
	proc center2Y [list id h] {
		#Util::verbose
		set y [expr {$Draw::cH /2 - $h /2}]
		$Draw::wPath.cC moveto $id {} $y
	}
	proc new {} {
		incr Document::documentCount
		dict set documentRowBegin $Document::documentCount	$Tabs::newRow
		dict set documentRowEnd $Document::documentCount $Tabs::newRow
		
		
		#set _return [list $a $b]
		
		Tabs::newDocument
		
		Page::new $Document::documentCount No
		
		Document::modDraw'sOnConfigure
		
		#Tabs::newPage [incr Tabs::newRow]
		
		#return $_return
	}
	proc bbox [list docCount] {
		# No. of pages docCount has
		if ![dict exists $Document::documentPageCount $docCount] {return}
		set count [dict get $Document::documentPageCount $docCount]
		# First page & last pages of $docCount
		set a $docCount^1
		set b $docCount^$count
		set _return [list [dict get $Page::x $a] [dict get $Page::y $a] [dict get $Page::x2 $b] [dict get $Page::y2 $b] ]
		#Util::verbose
		return $_return
		
	}
	proc modDraw'sOnConfigure {} {
		# for true: $modded == 0 and $activeDocCount != 0
		if {$Document::modded eq {No} && $Document::activeDocCount ne {No}} {
			set _body [split [info body Draw::onConfigure] \n]
			set _pattern {*$Draw::wPath.cC configure -scrollregion*\[*\]} 
			#puts [list got -> $_body]
			set i [lsearch -glob -nocase $_body $_pattern]
			set command [lindex $_body $i]
			#puts [list command -+ $command]
			set j [string first { } $command [string first {-scrollregion} $command ]]
			set Document::modded [string range $command $j+1 end]
			set command [string replace $command $j+1 end {[Document::bbox $Document::activeDocCount]}]
			#puts [list command ->> $command]
			#puts [list j ->> $j modded -> $Document::modded command -> $command]
			set _body [join [lreplace $_body $i $i $command ] \n]
			proc ::Draw::onConfigure [info args Draw::onConfigure] $_body
			#puts [info body Draw::onConfigure]
		}
	}
	
	# # # # # # # # # # # # # # # 
	Toolbar::addToDrawBar {ReliefButton::new #bCenter} -text {Center Pages} -WhenOn Document::activateCenter -WhenOff Document::deactivateCenter
	# # # # # # # # # # # # # # # 
	
	proc deactivateCenter {} {
		Document::deactivateEventCommand $Draw::wPath.cC <Configure> Document::centerDocument*
	}
	proc activateCenter {} {
		set _pattern {Document::centerDocument %w}
		Document::activateEventCommand $Draw::wPath.cC <Configure> $_pattern
		[lindex $_pattern 0] [winfo width $Draw::wPath.cC]
	}
	
	proc deactivateEventCommand [list _widget _event _pattern] {
		set _body [split [bind $_widget $_event] \n ]
		set i [lsearch -glob $_body $_pattern]
		if {$i != {-1}} {
			set _body [lreplace $_body $i $i]
			bind $_widget $_event $_body
		}
		#Util::verbose
	}
	proc activateEventCommand [list _widget _event _pattern] {
		set _body [bind $_widget $_event ]
		if {[string first $_pattern $_body ] == {-1}} {
			bind $_widget $_event "+$_pattern"	
		}
		#Util::verbose
	}
	proc centerDocument [list w] {
		#Draw::updateAndExtractCoords
		puts Centered
		set docCount $Document::activeDocCount
		if ![dict exists $Document::documentPageCount $docCount] {return}
		# what if pages of different widths
		set pageW [dict get $Page::w 1^1]
		set x [expr {$w /2 - $pageW/2}]
		#set y [expr {$Draw::cH/2 - $Draw::pH/2}]
		$Draw::wPath.cC moveto _$docCount	$x {}
		#[set y [expr { $y? :}]]
	}
	
}
namespace eval Page {
	variable \
	origY No \
	startX 11 \
	startY 11 \
	id [dict create] \
	x [dict create] \
	y [dict create] \
	w [dict create] \
	h [dict create] \
	x2 [dict create] \
	y2 [dict creat] \
	padY 50
	
	proc new [list docCount _row [list w 300] [list h 500] ] {
		if !$Page::origY {
			set Page::origY [winfo y $Tools::wPath.ttkspH]
			set Page::startY $Page::origY
		}
		set x2 [expr {$Page::startX + $w}]
		set y2 [expr {$Page::startY + $h}]
		if ![dict exists $Document::documentPageCount $docCount] {dict set Document::documentPageCount $docCount 1} else {dict incr Document::documentPageCount $docCount}
		# page No.
		set pageCount [dict get $Document::documentPageCount $docCount]
		
		set id [$Draw::wPath.cC create rectangle [list $Page::startX $Page::startY $x2 $y2 ] -fill {} -outline black -tag _$docCount]
		$Draw::wPath.cC create text [expr $Page::startX +50] [expr $Page::startY + 50 ] -text "Document $docCount"
		
		foreach i [list x y w h id x2 y2] j [list Page::startX Page::startY w h id x2 y2] {
			dict set Page::$i $docCount^$pageCount [set $j]
		}
		incr Page::startY $Page::padY
		incr Page::startY $h
		
		Tabs::newPage $docCount $pageCount $_row
	}
}
namespace eval HLines {
	# objId -> [list id1 id2] ; count ; object's abbreviated name ; ; List of supported Properties besides Name (realId) and Type (namespaceName)
	variable \
	objects [dict create] \
	count 0 \
	propertyAdditional [list {} {} Coordinate Coordinate] \
	property [dict create Width spin Height spin X spin Y spin Line_Space spin] \
	Width [dict create] \
	Height [dict create] \
	X [dict create] \
	Y [dict create] \
	Line_Space [dict create]
	
	namespace eval TextVariable {
	}
	
	
	proc new [list page ] {
		lassign [$Draw::wPath.cC coords $page] x y x2 y2
		#set x [expr { $x ? $x : $Draw::pX }]
		#set height [expr {$y ? ($Draw::pH - $y) : $Draw::pH }]
		#set y [expr { $y ? $y : $Draw::pY }]
		set height [expr {$y2 - $y}]
		
		set howMany [expr {int(floor($height / $Draw::fontHeight))}]
		set count 0
		set objects [list]
		# 1 line less
		set start [expr {int($Draw::fontHeight + $y)}]
		while {$count < $howMany} {
			lappend objects [$Draw::wPath.cC create line $x $start $xy $start -dash .]
			incr start $Draw::fontHeight
			incr count
		}
		dict set HLines::objects	$HLines::count $objects
		#dict set HLines::Width 		$HLines::count [expr {int($Draw::pageW - $x)}]
		#dict set HLines::Height 	$HLines::count $height
		dict set HLines::X 			$HLines::count $x
		dict set HLines::Y 			$HLines::count $y
		dict set HLines::Line_Space $HLines::count $::Draw::fontHeight
		Sequence::add $HLines::count HLines
		incr HLines::count
	}
	proc spin [list args] {
		switch [lindex $args 0] {
			new {
				lassign $args {} parent prop id
				variable ::HLines::TextVariable::#$id
				set w [spinbox $parent.sHLines^$prop -from -inf -to inf -command "HLines::$prop $id %s" ]
				return $w
			}
			setFrom {
				lassign $args {} widget prop id
				#Util::verbose
				set ::HLines::TextVariable::$prop#$id [HLines::$prop $id]
				$widget config -textvariable HLines::TextVariable::$prop#$id
				#eputs [HLines::$prop $id]
				
			}
		}
		
		
	}
	proc Width [list id ] {
		return [dict get $HLines::Width $id]
	}
	proc Height [list id] {
		return [dict get $HLines::Height $id]
	}
	proc X [list id] {
		return [dict get $HLines::X $id]
	}
	proc Y [list id] {
		return [dict get $HLines::Y $id]
	}
	proc Line_Space [list id [list new {}]] {
		
		return [expr {$new eq {} ? [dict get $HLines::Line_Space $id] : 
			{123}} ]
	}
}

namespace eval Tabs {
	variable \
	wPath [labelframe	$SecondFrame::sFrame.lfTabs	-borderwidth 5	-relief groove] \
	newRow 3
	SecondFrame::add $wPath 4
	
	grid	[label	$wPath.lBanner -text {Current Tabs}] 	-row 0 -column 0 -columnspan 2 -sticky nswe
	grid	[button	$wPath.bAdd -text $Icon::Unicode::Plus -relief flat -overrelief groove -command Document::new]	-row 0 -column 2 -columnspan 1 -sticky e
	
	grid	[ttk::separator $wPath.ttkspH -orient horizontal] -row 1 -column 0 -columnspan 3 -sticky nswe
	grid columnconfigure $Tabs::wPath 0 -weight 1 -uniform 1
	grid columnconfigure $Tabs::wPath 1 -weight 2 -uniform 1
	#grid	[button $wPath.bCreate -text {Create New Document} -command Tabs::newDocument -relief groove]	-row 2	-column	0	-columnspan 3 -sticky nswe
	
	
	proc newDocument {} {
		
		set Document::activeDocCount $Document::documentCount
		# redundant; once is enough
		Document::modDraw'sOnConfigure
		# a -> Page 1
		# b -> ... (Dot Menu Button)
		set a [radiobutton		$Tabs::wPath.bD$Document::documentCount		-text "Document $Document::documentCount" -indicatoron 0  -variable Document::activeDocCount -value $Document::documentCount  -command Draw::onConfigure]
		# redundant 
		# Draw::onConfigure
		
		set b [button		$Tabs::wPath.bDM$Document::documentCount	-text $Icon::Unicode::3Dots		-command "Menu::post $Tabs::wPath.bDM$Document::documentCount .mDocument" -relief flat -overrelief groove]
		grid 		$a 	-row $Tabs::newRow	-column 0	-sticky we	-pady [list 0.5c 0] -columnspan 2
		grid 		$b 	-row $Tabs::newRow	-column 2	-sticky es
		
		incr Tabs::newRow
	}
	proc newPage [list  docCount pageCount [list row No]] {
		set row [expr {$row? $row :$Tabs::newRow}]
		
		dict incr Document::documentRowEnd $docCount
		
		set no $pageCount
		#
		frame		$Tabs::wPath.fL$row
		place [ttk::separator $Tabs::wPath.fL$row.ttkspV -orient vertical] -relx 0.5 -y 0  -relheight 0.6 -relwidth 0.1
		place [ttk::separator $Tabs::wPath.fL$row.ttkspH -orient horizontal] -relx 0.5 -rely 0.6  -relheight 1 -relwidth 1
		grid $Tabs::wPath.fL$row -row $row	-column 0	-sticky	nswe
		#
		button		$Tabs::wPath.bP$docCount/$no			-text "Page $no"  -relief flat -overrelief groove -anchor w
		button		$Tabs::wPath.bPM$docCount/$no			-text $Icon::Unicode::3Dots -relief flat -overrelief groove	-command "Menu::post $Tabs::wPath.bPM$docCount/$no .mPage"
		grid		$Tabs::wPath.bP$docCount/$no			-row $row	-column 1 	-sticky we
		grid		$Tabs::wPath.bPM$docCount/$no			-row $row	-column 2	-sticky	e
		incr Tabs::newRow
	}


} ; # End of Tabs

proc doLast {} {
	#create Menu Buttons/Blocks
	Toolbar::createMenuButtons
	Toolbar::newSpaceBlock $Toolbar::wPath.fSpace1
	#create the Menu Buttons switch button
	Toolbar::createSwitchMenusButton
	
	#fDart1 bc it's a frame
	Toolbar::newPayload $Toolbar::wPath.fDart1 -Type DartButton::new -command {[lindex [list CustomSave::show tk_getSaveFile] $DartButton::varSaveMenu]} -text {Save as PDF} -Options [list {Use the built-in File lister} {Use the OS' native File explorer}] -DefaultOption 1 -variable ::DartButton::varSaveMenu pack -pady 3 -padx 5
	
	
	#enview a [label frame] and rest
	Files::configure
	
	#And populate it with dir items
	Files::list_
	
	
	# For Testing purposes only,
	# Before window creation and visibility it's all 0 0 0...
	#puts [list -x [winfo x .pwPane] -y [winfo y .pwPane] \
		  -rootx [winfo rootx .pwPane] -rooty [winfo rooty .pwPane] \
		  -vrootx [winfo vrootx .pwPane] -vrooty [winfo vrooty .pwPane]]
	
	#puts [list ** [winfo width $Properties::wPath] [winfo reqwidth $Properties::wPath] ]
	
	CustomSave::configure
	
	$MainPane::wPath add $SecondFrame::wPath -sticky nswe
	Toolbar::wPath2Config
	#HButtonNS::doThisOn .fToolbar.bMB1
	
	# Todo: Fix Tooltip
	Tooltip::new $Tabs::wPath.bAdd {Create a New Document} {}
	
}


doLast
