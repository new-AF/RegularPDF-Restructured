pack [canvas .c -bg red] -expand 1 -fill both -padx 10 -pady 10
frame .c.f -bg red
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
# id 1

proc onMap [list widget] {
	lassign [set all [.c bbox 1]] ::x ::y ::w ::h
	puts [list widget -> $widget all -> $all ]
	.c itemconfig  1 -width $::w
	.c itemconfig  1 -height $::h
	puts [list width -> [winfo width .c.f.f] height -> [winfo height .c.f.f]  ]
	puts [list width -> [winfo reqwidth .c.f.f] height -> [winfo reqheight .c.f.f]  ]
}
place .c.f.f -x 0 -y 0 -relwidth 1 -relheight 1
#pack .c.f.f -fill both -expand 1
bind .c.f <Unmap> onUnmap
bind .c.f <Map> {onMap %W}
.c create window 200 100 -window .c.f
console show