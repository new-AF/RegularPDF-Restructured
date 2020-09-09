#RegularPDF3
#a regular pdf document creator
#author:abdullah fatota

namespace eval util {
	proc put args {
	for {set i 0 ; set len [expr {([llength $args] / 2)*2}]} {$i < $len} {incr i 2} {
		
		set lev [lindex $args $i]
		set except #
		if {[string index $lev 0] != $except} {
			incr lev }
		set varname [lindex $args $i+1]
		upvar $lev $varname var
		puts [list  [format %15s $varname] -> $var] }
	} ;#put
	
	proc nonempty [list check command] {
		set result {}
		if ![expr {$check eq no || $check eq {} || $check eq 0}] {
			set result [{*}$command] }
		return $result
	} ;#nonempty
	
	proc semiRandom [list [list subrange 1]] {
		incr subrange -1
		if {$subrange < 0} {
			# Exception, while borrowing some Python nomenclature
			throw [list Tcl RangeError RANGE_ZERO_OR_LESS] [list RangeError: subrange must be >= 1 Got ($subrange)]
		}
		return [string range [::tcl::mathfunc::rand] 2 [expr {$subrange + 2}] ]
	} ;#semiRandom
	
	proc ontrue [list check command] {
		uplevel 1 "
			if ![expr {$check eq no || $check eq {} || $check eq 0}] {$command}
		"
	} ;#ontrue
	
	proc getrangepath {str r1 r2} {
		set str [split $str /]
		if {[string index $str 0] eq {/}} {set str [lrange $str 1 end]}
		if {[string index $str end] eq {/}} {set str [lrange $str 0 end-1]}
		set str [lrange $str $r1 $r2]
		set str [join $str .]
	} ;#getrangepath
	
	proc replace {a b c} {
		set a [split $a {}]
		set f [lsearch -exact -all $a $b]
		foreach v $f {
			set a [lreplace $a $v $v $c]
		}
		set a [join $a {}]
		return $a
	} ;#replace
	
	proc chopstring {args} {
		set delim [lindex $args end]
		set args [lrange $args 0 end-1]
		set a [join $args {}]
		set new [list]
		while {[set index [string first | $a]] != -1  } {
			lappend new [string range $a 0 $index-1]
			set a [string range $a $index+1 end]
		}
	
		lappend new [string range $a 0 [string length $a]]
		
		return $new
	} ;#chopstring
	
	proc chopstring2 {args} {
		set delim [lindex $args end]
		set args [lrange $args 0 end-1]
		set new [list]
		foreach v $args {
			set s [split $v $delim]
			set s [join $s ]
			lappend new $s
		}
		return $new
	} ;#chopstring2
	
	proc choplist {args} {
		set delim [lindex $args end]
		set args [lrange $args 0 end-1]
		set all [lsearch -exact -not -inline -all $args $delim]
		return $all
	} ;#choplist
	
	proc cat {args} {
		return [string cat {*}$args]
	} ;#cat
	
	proc dcreate {name args} {
		uplevel 1 "
			set $name [dict create {*}$args] 
		"
	} ;#dcreate
	
	proc dset {name args} {
		uplevel 1 "
			dict set $name {*}$args
		"
	} ;#dset
	
	proc dget {name args} {
		ser r [uplevel 1 "
			dict get $$name {*}$args
		"]
		return $r
	} ;#dget
}

namespace eval widget {
		
		proc name args {
			set r [lmap v $args {util::replace $v / .}]
			return $r
		} ; #widget::name
	
		proc make {args} {
		set args [util::choplist $args |]
		set geometry {}
		foreach line $args {
		lset line 1 [widget::name [lindex $line 1]]
			set geometry_index [lsearch -glob $line \+*] ;#how to get \++
			if {$geometry_index != -1} {
				set geometry [lrange $line $geometry_index end]
				lset geometry 0 [string range [lindex $geometry 0] 1 end]
				set line [lrange $line 0 $geometry_index-1]
				
			}
			#puts [list widget::make $geometry $line]
			#error [list $geometry $line]
			set tmp [lindex $line 0]
			lset line 0 [expr {[string is upper [string index $line 0]] ? "ttk::[string tolower $tmp]" : $tmp}]
			#error [list $geometry $line]
			set name [{*}$line]
			{*}[expr {$geometry ne {} ? [linsert $geometry 1 $name] : {}}]
			return $name
		}
		
	} ;#widget::make
	
	proc center {widget {w no} {h no}} {
		set sw [winfo vrootwidth .]
		set sh [winfo vrootheight .]
		
		set s1 {}
		if {!$w || !$h} {
			set w [winfo reqwidth $widget]
			set h [winfo reqheight $widget]
			
			append s1 ${w}x${h}
		}
		
		
		
		set x [expr {$sw/2 - $w/2}]
		set y [expr {$sh/2 - $h/2}]
		
		set s +${x}+${y}
		
		if {$s1 ne {}} {set s $s1$s }
		
		wm geometry $widget $s
	} ;#center
	
	proc sash0_position_of {w {new {}} } {
	
		return [$w sashpos 0 {*}$new]
	
	} ;#sash0_position_of
	
	proc sash0_equalize {primary replica} {
		set x [widget::sash0_position_of $primary]
		widget::sash0_position_of $replica $x
	} ;#sash0_position_of

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




oo::class create ScrollableCanvas {
	variable f c sbv sbh packinfo
	constructor master {
		set f [frame $master.f ]
		set c [canvas $f.c]
		set sbv [scrollbar $f.sbv -orient vertical -command {$c yview}]
		set sbh [scrollbar $f.sbh -orient horizontal -command {$c xview}]
		
		$c config -xscrollcommand "$sbh set" -yscrollcommand "$sbv set"
		
		pack $sbv -side right -fill y
		pack $sbh -side bottom -fill x
		pack $c -side top -expand 1 -fill both

	}
	method updatesregion {{tag all} {bbox 1}} {
		$c config -scrollregion [expr { $bbox == 1 ? $tag : $bbox  }]
	}
	method get {what} {
		return [my Translate $what]
	}
	method Translate {str} {
		set var [switch $str {
			sbv { concat $sbv }
			sbh { concat $sbh }
			c { concat $c }
			f {concat $f}
		}]
		return $var
	}
	method qutoehide {who} {
		set var [my Translate $who]
		if ![dict exists $packinfo $var] {
			dict set packinfo $who [pack info $var]
		}
		pack forget $var
	}
	method show {who} {
		set var [my Translate $who]
		pack $var {*}[dict get $packinfo $var]
	}
	method executeOn {who args} {
		set var [my Translate $who]
		
		set i 0
		while {[set i [string first # $args ]] != -1 } {
			
			set args [string replace $args $i $i $var]
			#puts [list args-> $args]
		}
		
		#puts $args
		
		{*}$args
	}
}




oo::class create Tooltip {
	variable f l dtext text id waitms classname
	constructor {} {
		set f [frame ._tooltip -bg {light yellow} -highlightthickness 1 -highlightbackground black -width 100 -height 100]
		
		set l [label $f._label ]
		$l config -wraplength [font measure [$l cget -font] {Horizontal Guiding Lines}]
		
		pack $l -side top -expand 1 -fill both
		
		set dtext [dict create]
		set id {}
		set waitms 500
		set classname {TooltipClass}
		
		bind $classname <Enter> "[self]  enter %W"
		bind $classname <Leave> "[self]  exit %W"
		
		
	}
	method on {w t} {
		set bt [bindtags $w]
		
		if {$classname in $bt} {return}
		
		dict set dtext $w $t
		set bt [linsert $bt 2 $classname]
		
		bindtags $w $bt
	}
	method enter w {
		if {$id ne {}} {
			after cancel $id
		}
		set id [after $waitms "[self] show $w"]
		set text [dict get $dtext $w]
		$l config -text $text
	}
	method show w {
		lassign [list [winfo rootx .] [winfo rooty .] [winfo rootx $w] [winfo rooty $w]] mx my x y
		
		set w [winfo width $w]
		
		incr x -$mx
		incr x $w
		incr y -$my
		
		
		place $f -x $x -y $y
		
		puts [list SHOWN $text]
	}
	method exit w {
		#puts TOOLTIP_EXIT
		place forget $f
		
		after cancel $id
	}
	
}

oo::class create Tabs {
	variable f0 f row wid parent c
	constructor args {
		lassign $args parent c
		set row 0
		set f0 [labelframe $parent.f0 -bg red]
		set f [ttk::labelframe $f0.f]
		set h1 [ttk::separator $f.h1 -orient horizontal]
		set h2 [ttk::separator $f.h2 -orient horizontal]
		
		set ban [ttk::label $f.banner -text Tabs]
		 
		fgrid $h1 -row [incr row] -col 0 -colspan 4 -st nswe
		fgrid $ban -row [incr row] -col 0 -colspan 4 -st nswe
		fgrid $h2 -row [incr row] -col 0 -colspan 4 -st nswe
		
		place $f -x 0 -y 0 -relwidth 1 -relheight 1
		bind $c <Configure> "+ [self] oncon %w %h"
	}
	method window {x y} {
		if ![winfo exists wid] {
			set wid [$c create window 0 0]
		}
		$c itemconfig $wid -window $f0
		$c moveto $wid $x $y
		
	}
	method oncon {w h} {
		set x [$c canvasx 0]
		set y [$c canvasy 0]
		
		$c itemconfig $wid -width $w -height $h
		$c moveto $wid $x $y
	}
}

oo::class create Tabs2 {
	variable h1 h2 banner parent row d dcount dlast  dcb_vars
	constructor {_parent new_row} {
		set parent $_parent
		set row $new_row
		set d [dict create]
		set dcount 0
		set dlast None
		#set dcb_vars [dict create]
		
		set h1 [widget::make Separator $parent/tabs_h1 -orient horizontal +grid -row $row -column 0 -columnspan 3 -sticky we]
		incr row
 		set banner [widget::make label $parent/tabs_banner -text Tabs +grid -row $row -column 0 -columnspan 2 -sticky nswe]
		set add [widget::make button $parent/tabs_add +grid -row $row -column 2 -columnspan 1 -sticky e]
		$add config -text $Icon::Unicode::Plus -command "[self] new_doc" -relief flat -overrelief groove
		incr row
		set h2 [widget::make Separator $parent/tabs_h2 -orient horizontal +grid -row $row -column 0 -columnspan 3 -sticky we]
		incr row
		grid columnconfigure $parent [list 0 1] -weight 1 -uniform 1
		grid columnconfigure $parent [list 2] -weight 0 -uniform 0
	
		#util::dset d []
	} ;#constructor
	
	method new_doc {} {
		dict set d #$dcount [dict create]
		dict set d #$dcount label [my new_doc_widget $dcount]
		incr row
		dict set d #$dcount pcount 0
		dict set d #$dcount pages [dict create ]
		my new_page $dcount
		incr row
		incr dcount ;#increment document count
	} ;#new_doc
	
	method new_doc_widget {count} {
		set w [widget::make checkbutton $parent/tabs_doccb_$count -text "Document $count" +grid -row $row -column 0 -columnspan 3 -sticky nswe]
		dict set dcb_vars $count 0
		$w config -indicatoron 0
		return $w
	} ;#new_doc_widget
	
	method doc_press {count} {
		my doc_hide all
		my doc_show count
	} ;# doc_press
	
	method new_page {count } {
		set pcount [dict get $d #$count pcount] ; #queries $d #count
		incr pcount
		dict set d #$count pcount $pcount
		set w [my new_page_widget $count $pcount]
		dict set d #$count pages @$pcount $w ;#modifies $d #count pages @pcount
		return $w
	} ;#new_page
	
	method new_page_widget {c1 c2} {
		set w [widget::make label $parent/tabs_pagelabel_${c1}_${c2} -text "Page $c2" +grid -row $row -column 0 -columnspan 3 -sticky nswe]
		grid remove $w
		return $w
	} ;#new_page_widget
	
	method doc_show {word} {
		set all [expr {$word eq {all} ? [dict keys $d #* ] : [list $word]}]
		foreach v $all {
			set pgs [dict keys [dict get $d #$v] @+]
			foreach w $pgs { grid remove $w } 
		}
	} ;#doc_show
	
	method doc_hide {word} {
		if {$dlast eq {None}} {return}
		set all none
	} ;#doc_hode
} 

proc create_overall_ui {} {
	widget::make Sizegrip /s +pack -side bottom -fill x
	set ::Main [widget::make frame /main +pack -side top -expand 1 -fill both]
	# Top Panedwindow
	set ::TopPaned [set top_paned [widget::make Panedwindow $::Main/top_paned -orient horizontal +pack -side top -fill x] ]
	
	# Top Panedwindow/left frame
	set ::TopPaned_Left [set top_paned_left [widget::make Labelframe $::TopPaned/left -text left] ]
	$top_paned add $top_paned_left
	
	# Top Panedwindow/right frame
	set ::TopPaned_Right [set top_paned_right [widget::make Labelframe $::TopPaned/right -text right] ]
	$top_paned add $top_paned_right
	
	# Bottom Panedwindow
	set ::BottomPaned [set bottom_paned [widget::make Panedwindow $::Main/bottom_paned -orient horizontal +pack -side bottom -expand 1 -fill both] ]
	
	# Bottom Panedwindow/left frame 
	set ::BottomPaned_Left [set bottom_paned_left [widget::make Labelframe $::BottomPaned/left -text Left]  ]
	$bottom_paned add $bottom_paned_left

}
proc config_top_paned_right {} {
	set top_right $::TopPaned_Right
	# Top Panedwindow/right frame/checkbutton 1
	set ::TopPaned_Right_Cb1 [set top_right_cb1 [widget::make checkbutton $::TopPaned_Right/cb1  -text Files +grid -row 0 -column 0 -sticky nswe] ]
	$top_right_cb1 config -indicatoron 0
	
	# Top Panedwindow/right frame/checkbutton 2
	set ::TopPaned_Right_Cb2 [set top_right_cb2 [widget::make checkbutton $::TopPaned_Right/cb2  -text Tabs +grid -row 0 -column 1 -sticky nswe] ]
	$top_right_cb2 config -indicatoron 0
	
	grid columnconfigure $top_right [list 0 1] -weight 1 -uniform 1
	
}

proc config_top_paned_left {} {
	# Top Panedwindow/left frame/main frame
	set ::TopPaned_Left_Main [set top_left_main [widget::make Labelframe $::TopPaned_Left/main -text Menu +pack -side top -fill x] ]
	
	# Top Panedwindow/left frame/canvas toolbar
	set ::TopPaned_Left_Cbar [set top_left_cbar [widget::make Labelframe $::TopPaned_Left/cbar -text {Tool bar} +pack -side top -fill x -after $::TopPaned_Left_Main] ]
}
proc config_bottom_paned_left {} {
	#----------------------------------------------------------------------#
	#bgerror  Error in bgerror: invalid command name "ttk::label"
	#foreach v [list Panedwindow Button Label Labelframe Separator Scrollbar] {
	#	rename ttk::[string tolower $v] $v }
	#----------------------------------------------------------------------#
	set bottom_paned_left $::BottomPaned_Left
	# Bottom Panedwindow/left frame/Hlines button
	# a conscious effort not to nest frame; ideally hlines would be in a separate frame
	set last_row 0
	set ::BottomPaned_Left_Hlines [set bottom_paned_left_hlines [widget::make button $::BottomPaned_Left/hlines -text $Icon::Unicode::HorizontalLines +grid -row $last_row -column 0 -sticky nw] ]
	$bottom_paned_left_hlines config -command {console show} -relief flat -overrelief groove 
	
	# Bottom Panedwindow/left frame/canvas
	set ::BottomPaned_Left_C [set bottom_paned_left_c [widget::make canvas $::BottomPaned_Left/c -bg gray +grid -row $last_row -column 1 -sticky nswe ] ]
	$bottom_paned_left_c config -xscrollcommand {$::BottomPaned_Left_Hsb set} -yscrollcommand {$::BottomPaned_Left_Vsb set}
	
	# Bottom Panedwindow/left frame/vertical scrollbar
	set ::BottomPaned_Left_Vsb [set bottom_paned_left_sbv [widget::make scrollbar $::BottomPaned_Left/sbv -orient vertical  +grid -row $last_row -column 2 -sticky ns] ]
	$bottom_paned_left_sbv config -command {$::BottomPaned_Left_C yview}
	incr last_row
	
	# Bottom Panedwindow/left frame/horizontal scrollbar
	set ::BottomPaned_Left_Hsb [set bottom_paned_left_sbh [widget::make scrollbar $::BottomPaned_Left/sbh -orient horizontal +grid -row $last_row -column 0 -columnspan 3 -sticky we ] ]
	$bottom_paned_left_sbh config -command {$::BottomPaned_Left_C xview}
	
	grid columnconfigure $bottom_paned_left 0 -weight 0 -uniform 0 -pad 10
	grid columnconfigure $bottom_paned_left 1 -weight 1 -uniform 1
	grid columnconfigure $bottom_paned_left 2 -weight 0 -uniform 00
	
	for {set i 0 } {$i < $last_row} {incr i} {
		grid rowconfigure $bottom_paned_left $i -weight 0 -uniform x$i }
	
	grid rowconfigure $bottom_paned_left [expr {$last_row - 1}] -weight 1
}

proc config_bottom_paned_right {} {
	set bottom_paned $::BottomPaned
	# Bottom Panedwindow/right frame
	set ::BottomPaned_Right [set bottom_paned_right [widget::make frame $::BottomPaned/right -bg blue +grid -row -0 -column 0 -sticky nswe] ]
	$bottom_paned add $bottom_paned_right
	
	set ::BottomPaned_Right_C [set bottom_paned_right_c [widget::make canvas $::BottomPaned_Right/c -bg gray] ]
	set ::BottomPaned_Right_C_F [set bottom_paned_right_cf [widget::make labelframe $::BottomPaned_Right_C/cf -text {"cf"} -bg gray +pack -side top -fill both -expand 1] ]

	set ::BottomPaned_Right_Vsb [set bottom_paned_right_sbv [widget::make scrollbar $::BottomPaned_Right/sbv -orient vertical -command {$bottom_paned_right_c yview} ] ]
	set ::BottomPaned_Right_Hsb [set bottom_paned_right_sbh [widget::make scrollbar $::BottomPaned_Right/sbh -orient horizontal -command {$bottom_paned_right_c xview} ] ]
	$bottom_paned_right_c config -xscrollcommand {$::BottomPaned_Right_Hsb set} -yscrollcommand {$::BottomPaned_Right_Vsb set} 
	
	grid $bottom_paned_right_c -row 0 -column 0 -sticky nswe
	grid $bottom_paned_right_sbv -row 0 -column 1 -rowspan 2 -sticky ns
	grid $bottom_paned_right_sbh -row 1 -column 0 -columnspan 2 -sticky we
	
	grid columnconfigure $bottom_paned_right 0 -weight 1 -uniform 1
	grid rowconfigure $bottom_paned_right 0 -weight 1 -uniform 1
	grid columnconfigure $bottom_paned_right 1 -weight 0 -uniform 00
	grid rowconfigure $bottom_paned_right 1 -weight 0 -uniform 00

}

proc bottom_paned_onmap {W} {
	set w [winfo reqwidth $::Main]
	set w [expr {$w / 2}]
	puts [list w-> $w]
	widget::sash0_position_of $W $w
	
	bind $W <Map> {}
}

proc bottom_paned_onconfig {} {
	widget::sash0_equalize $::BottomPaned $::TopPaned
}

proc start {} {
	set ::T [Tooltip new]
	
	
	create_overall_ui
	config_top_paned_left
	config_top_paned_right
	config_bottom_paned_left
	config_bottom_paned_right
	
	set ::Tabs2 [Tabs2 new $::BottomPaned_Right_C_F 0]
	$::T on $::BottomPaned_Left_Hlines  {Horizontal Lines}
	bind $::BottomPaned <Map> {bottom_paned_onmap %W}
	bind $::BottomPaned_Left <Configure> bottom_paned_onconfig
	
	widget::center {.}
	wm title {.} RegularPDF
	
}

puts [start]
