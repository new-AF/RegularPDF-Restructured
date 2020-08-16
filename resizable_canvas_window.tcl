pack [canvas .c -bg red] -expand 1 -fill both -padx 10 -pady 10
frame .c.f -bg yellow
frame .c.f.f -bg blue
label .c.f.f.l -text t444444444444444444444444444444444444444op
label .c.f.f.left -text left
label .c.f.f.middle -text middle
label .c.f.f.right -text right
proc g [list w row column [list sticky nswe] args] {
	grid $w -row $row -column $column -sticky $sticky {*}$args
}
g .c.f.f.l 0 0 nswe -columnspan 3
g .c.f.f.left 1 0
g .c.f.f.middle 1 1
g .c.f.f.right 1 2
grid columnconfigure .c.f.f all -weight 1 -uniform 1
# id 1

proc onMap [list widget] {
	lassign [set all [.c bbox 1]] ::x ::y ::w ::h
	puts [list onMap widget -> $widget BBox -> $all ]
	.c itemconfig  1 -width $::w
	.c itemconfig  1 -height $::h
	puts [list width -> [winfo width .c.f.f] height -> [winfo height .c.f.f]  ]
	puts [list REQ width -> [set ::w [winfo reqwidth .c.f.f]] height -> [set ::h [winfo reqheight .c.f.f]]  ]
	.c itemconfig  1 -width $::w
	.c itemconfig  1 -height $::h
	place configure .c.f.f -width $::w
}
proc onConfigure [list widget w h _x _y] {
	puts [list onConfigure widget -> $widget x -> $_x y -> $_y]
	puts [list w -> $w h -> $h]
	# # #
	# <Configure> occurs before <Map> 
	# # #

	if {![info exists ::x]} {return}
	
}
set stop no
set cache [dict create]
proc topOnConfigure [list W w h ] {
	puts [list CANVAS w -> $w h -> $h]
	if {![info exists ::x]} {return}
	if {!$::stop} {
			
			set ::stop yes
			set ::max inf
			foreach i [set ::all [lreverse [grid slaves .c.f.f]]] {
				set j [grid info $i]
				#puts "i -> $i $j"
				#if {[set colSpan [dict get $j -columnspan]] != 1} {continue}
				if {[set colWidth [winfo reqwidth $i]] < $::max} {set ::max $colWidth}
				
			}
			set original yes
			lassign [grid size .c.f.f] totalCols totalRows
			set total [expr {$totalCols * $totalRows}]
			set windows [lreverse [grid slaves .c.f.f]]
			set prop [lmap i $windows {concat [grid info $i]}] ; puts $prop
			incr totalCols 1 ; while {[incr totalCols -1] > 0} {
				
				puts [format %10s%10s column $totalCols ]
				set row 0
				set column 0
				set rows [expr {$total / $totalCols}]
				foreach i $windows j $prop {
					set cs [dict get $j -columnspan]
					set rs [dict get $j -rowspan]
					set r [dict get $j -row]
					set c [dict get $j -column]
					set mul [expr {int(ceil(($cs * $rs)/($totalCols + 0.0)))}]
					#incr column [expr {$mul > 1 ? $mul : $totalCols}]
					dict set ::cache $totalCols $i [dict replace $j -column $column -row $row -rowspan $mul]
					#puts [format {%10s %-10s%10s %-10s%10s %-10s%10s %-10s%10s %-10s%10s %-10s%10s %-10s} row $r column $c rowspan $rs colspan $cs mul $mul nextCol $column nextRow $row]
					incr column $cs
					if {$column >= $totalCols} {
						incr row $mul
						set column 0
					}
					#set r [dict get $j -row] ; incr r
					#set c [dict get $j -column] ; incr c ; incr c $lastCs
					
				}
				puts {}
			}
			#grid columnconfigure .c.f.f all -minsize $::max
			puts [list max-> $::max]
			dict for {_i _j} $::cache {
				puts "$_i \n"
				dict for {i j} $_j {
					puts "$i -> $j"
				} 
			}
		}
	set offset [winfo x .c.f]
	if {$w < [expr { $offset + $::w }]} {
		set canFit [expr {($w - $offset) / $::max}]
		puts [list canFit -> $canFit]
		.c itemconfig 1 -width [set newW [expr {$w - $offset - 20}]]
		place configure .c.f.f -width $newW
		if {$canFit == 0} {set canFit 1}
		if {$canFit <= 3} {
			foreach i $::all {
				puts [set tmp [dict get $::cache $canFit $i]]
				grid configure $i {*}$tmp
			}
		}
		#puts "[set s [string repeat * 10]] Less $s"
	}
}
place .c.f.f -x 0 -y 0 -relwidth 0 -relheight 1
#pack .c.f.f -fill both -expand 1
bind .c.f <Unmap> onUnmap
bind .c.f <Map> {onMap %W}
bind .c.f <Configure> {onConfigure %W %w %h %x %y}
bind .c <Configure> {topOnConfigure %W %w %h}
.c create window 50 100 -window .c.f -anchor nw
puts [list ORIGIN REQ 	width -> [set ::w [winfo reqwidth .c.f.f]] height -> [set ::h [winfo reqheight .c.f.f]]  ]
puts [list ORIGIN		width -> [set ::w [winfo width .c.f.f]] height -> [set ::h [winfo height .c.f.f]]  ]
console show