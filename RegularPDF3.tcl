set W 700
set H 400

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


; #----------------------------------------------------------------------#
; # Top Panedwindow
set tpaned [ttk::panedwindow .tpaned -orient horizontal]
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
set bpaned [ttk::panedwindow .bpaned ]
pack $bpaned -side bottom -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame 
set bpaned_left [ttk::labelframe [fparent bpaned .lbar] -text Left ]
pack $bpaned_left -side left -expand 1 -fill both

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/tool frame
set bpaned_left_tool [ttk::labelframe [fparent bpaned_left .tool] -text {Tools} ]
pack $bpaned_left_tool -side left -fill y

; #----------------------------------------------------------------------#
; # Bottom Panedwindow/left frame/canvas
set bpaned_left_sc [ScrollableCanvas new $bpaned_left]

$bpaned_left_sc executeOn c # config -bg red

$bpaned_left_sc executeOn f pack # -side left -expand 1 -fill both

fcenter .

wm title . RegularPDF

