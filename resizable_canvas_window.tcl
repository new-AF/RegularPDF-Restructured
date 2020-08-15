pack [canvas .c -bg red] -expand 1 -fill both -padx 10 -pady 10
frame .c.f
label .c.f.l -text top
label .c.f.left -text left
label .c.f.middle -text middle
label .c.f.right -text right
proc g [list w row column [list sticky nswe] args] {
	grid $w -row $row -column $column -sticky $sticky {*}$args
}
g .c.f.l 0 0 nswe -columnspan 3
g .c.f.left 1 0
g .c.f.middle 1 1
g .c.f.right 1 2
# id 1
bind .c.f <Unmap> {puts [list unmap]}
bind .c.f <Map> {puts [list map]}
.c create window 200 100 -window .c.f
console show