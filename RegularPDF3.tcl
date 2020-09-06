set W 700
set H 400

proc put args {
	set len [llength $args]
	set len [expr {($len / 2)*2}]
	for {set i 0} {$i < $len} {incr i 2} {
		
		set lev [lindex $args $i]
		if {[string index $lev 0] != {#}} {
			incr lev
		}
		set a [lindex $args $i+1]
		upvar $lev $a b
		puts [list  [format %15s $a] -> $b]
	}
}

proc dset args {
if {[llength $args] == 1} {
	dict create {*}$args {}
} else {
	dict set {*}$args
	}
}

proc dget args {
	set a [set [lindex $args 0] ]
	set args [lremove $args 0 0]
	dict get $a {*}$args
}

proc dlappend args {
	dict lappend {*}$args 
}

proc dincr args {
	dict incr {*}$args
}


proc mybool [list args] {
	set l [llength args]
	set r [lmap v $args {expr {$v eq no || $v eq {} || $v eq 0}}]
	if {$l == 1} {
		return [lindex $r 0]
	}
	return $r
}

proc llength>0 {L} {
	return [expr {[llength $L] > 0}]
}

proc getrangepath {str r1 r2} {
	set str [split $str /]
	set str [lmap v $str {expr {$v eq {} ? [continue] : $v }} ]
	set str [lrange $str $r1 $r2]
	set str [join $str .]
}

proc replace {a b c} {
	set a [split $a {}]
	set f [lsearch -exact -all $a $b]
	foreach v $f {
		set a [lreplace $a $v $v $c]
	}
	set a [join $a {}]
	return $a
}

proc widgetname args {
	set r [lmap v $args {replace $v / .}]
	return $r
}

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
}

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
}

proc choplist {args} {
	set delim [lindex $args end]
	set args [lrange $args 0 end-1]
	set all [lsearch -exact -not -inline -all $args $delim]
	return $all
}

proc widgetmake1 {args} {
	set args [choplist $args |]
	set geometry {}
	foreach line $args {
	lset line 1 [widgetname [lindex $line 1]]
		set geometry_index [lsearch -glob $line \+*] ;#how to get \++
		if {$geometry_index != -1} {
			set geometry [lrange $line $geometry_index end]
			lset geometry 0 [string range [lindex $geometry 0] 1 end]
			set line [lrange $line 0 $geometry_index-1]
			
		}
		#error [list $geometry $line]
		set tmp [lindex $line 0]
		lset line 0 [expr {[string is upper [string index $line 0]] ? "ttk::[string tolower $tmp]" : $tmp}]
		#error [list $geometry $line]
		set name [{*}$line]
		{*}[expr {$geometry ne {} ? [linsert $geometry 1 $name] : {}}]
		return $name
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

proc fcat {args} {
	return [string cat {*}$args]
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


proc fcenter {widget {w no} {h no}} {
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
}

# concatinates last word (new widget) with previous variable names
proc fparent {args} {
	set widget [lindex $args end]
	set args [lreplace $args end end]
	
	set vars [lmap i $args {set ::$i}]
	
	lappend vars $widget
	
	set final [join $vars {}]
	
	return $final
}

proc sash0_position_of {w {new {}} } {

	return [$w sashpos 0 {*}$new]

}

proc sash0_equalize {primary replica} {
	set x [sash0_position_of $primary]
	sash0_position_of $replica $x
}

proc fgcoleq {args} {
	set parent [winfo parent [lindex $args 0]]
	set last [lindex $args end]
	
	set uniform 1
	
	
	if [string is digit $last] {
		set uniform $last
		set args [lreplace $args end end]
	}
	
	foreach i $args {
		grid columnconfigure $parent $i -weight 1 -uniform $uniform
	}
}

proc fgrid {args} {
	set l [llength $args]
	
	
	foreach i [list -col -colspan -st] ii [list -column -columnspan -sticky] {
		set found [lsearch -exact -all $args $i]
		foreach j $found {
			set args [lreplace $args $j $j $ii]
		}
	}
	
	grid {*}$args
	
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
		#puts EXIT
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

widgetmake1 Sizegrip /s +pack -side bottom -fill x


set main [frame .main]
pack $main -side top -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Top Panedwindow
set tpaned [widgetmake1 Panedwindow [widgetname /main/tpaned] -orient horizontal +pack  -side top -fill x]

; #----------------------------------------------------------------------#
; # Top Panedwindow/left frame
set left [ttk::labelframe [fparent tpaned .left] -text left ]
$tpaned add $left

; #----------------------------------------------------------------------#
; # Top Panedwindow/right frame
set right [ttk::labelframe [fparent tpaned .right] -text right ]
$tpaned add $right

set rb1 [checkbutton [fparent right .rb1] -indicatoron 0 -text Files]
set rb2 [checkbutton [fparent right .rb2] -indicatoron 0 -text Tabs]

fgrid $rb1 -row 0 -col 0 -st nswe
fgrid $rb2 -row 0 -col 1 -st nswe

fgcoleq $rb1 $rb2 1

; #----------------------------------------------------------------------#
; # Top Panedwindow/left frame/menu frame
set mbar [ttk::labelframe [fparent left .mbar] -text Menu ]
pack $mbar -side top -fill x

; #----------------------------------------------------------------------#
; # Top Panedwindow/left frame/canvas toolbar
set cbar [ttk::labelframe [fparent left .cbar] -text {Tool bar} ]
pack $cbar -side top -fill x -after $mbar

; #----------------------------------------------------------------------#
; # Bottom Panedwindow
set bpaned [ttk::panedwindow [fparent main .bpaned] -orient horizontal]
pack $bpaned -side bottom -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame 
set bpaned_left [ttk::labelframe [fparent bpaned .lbar] -text Left ]
$bpaned add $bpaned_left 

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/tools frame
set bpaned_left_tool [ttk::labelframe [fparent bpaned_left .tool] -text {Tools} -labelanchor n]
pack $bpaned_left_tool -side left -fill y

; # Bottom Panedwindow/left frame/tools frame/HLines
set bpaned_left_tool_hlines [button [fparent bpaned_left_tool .hlines ] -text $Icon::Unicode::HorizontalLines -relief flat -overrelief groove ]
pack $bpaned_left_tool_hlines -side top -fill x

$bpaned_left_tool_hlines config -command {console show}


; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/canvas
set bpaned_left_sc [ScrollableCanvas new $bpaned_left]

$bpaned_left_sc executeOn c # config -bg red

$bpaned_left_sc executeOn f pack # -side left -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/right frame
set bpaned_right [ScrollableCanvas new $bpaned]
$bpaned add [$bpaned_right get f]

set TABS [Tabs new [$bpaned_right get f] [$bpaned_right get c]]
$TABS window 0 0


bind $bpaned <Map> {
	set w [winfo reqwidth $main]
	set w [expr {$w / 2}]
	puts [list w-> $w]
	sash0_position_of %W $w
	
	bind %W <Map> {}
}

bind $bpaned_left <Configure> {
	sash0_equalize $bpaned $tpaned
}

; #----------------------------------------------------------------------#

set T [Tooltip new]
$T on $bpaned_left_tool_hlines  {Horizontal Lines}

fcenter .



wm title . RegularPDF

