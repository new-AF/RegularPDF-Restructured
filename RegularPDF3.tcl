set W 700
set H 400

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




set main [frame .main]
pack $main -side top -expand 1 -fill both


; #----------------------------------------------------------------------#
; # Top Panedwindow


; #----------------------------------------------------------------------#
; # Top Panedwindow
set tpaned [ttk::panedwindow [fparent main .tpaned] -orient horizontal]
pack $tpaned -side top -fill x

; #----------------------------------------------------------------------#
; # Top Panedwindow/left frame
set left [ttk::labelframe [fparent tpaned .left] -text left ]
$tpaned add $left

; #----------------------------------------------------------------------#
; # Top Panedwindow/right frame
set right [ttk::labelframe [fparent tpaned .right] -text right ]
$tpaned add $right

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
set bpaned [ttk::panedwindow [fparent main .bpaned] ]
pack $bpaned -side bottom -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame 
set bpaned_left [ttk::labelframe [fparent bpaned .lbar] -text Left ]
pack $bpaned_left -side left -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/tool frame
set bpaned_left_tool [ttk::labelframe [fparent bpaned_left .tool] -text {Tools} -labelanchor n]
pack $bpaned_left_tool -side left -fill y

set bpaned_left_tool_hlines [ttk::button [fparent bpaned_left_tool .hlines ] -text $Icon::Unicode::HorizontalLines]
pack $bpaned_left_tool_hlines -side top

$bpaned_left_tool_hlines config -command {console show}


; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/canvas
set bpaned_left_sc [ScrollableCanvas new $bpaned_left]

$bpaned_left_sc executeOn c # config -bg red

$bpaned_left_sc executeOn f pack # -side left -expand 1 -fill both

; #----------------------------------------------------------------------#
set T [Tooltip new]
$T on $bpaned_left_tool_hlines  {Horizontal Lines}

fcenter .



wm title . RegularPDF

