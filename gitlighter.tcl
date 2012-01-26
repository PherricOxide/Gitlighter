#! /usr/bin/wish -f

if {[llength $argv] == 0} {set days 7} else {set days [lindex $argv 0]}

set filePath [tk_getOpenFile]
cd [file dirname $filePath]
set data [split [exec "C:/Program Files (x86)/Git/bin/git.exe" blame -te $filePath] "\n"]

proc dualScroll {arg1 arg2} {
    .code yview $arg1 $arg2
    .sidebar yview $arg1 $arg2
}

set lastHighlight [clock add [clock seconds] "-$days" days]

text .code -width 100 -height 400 -bg white -yscrollcommand ".ys set" 
text .sidebar -width 28 -height 400 -bg grey -yscrollcommand ".ys set" 

scrollbar .ys -command "dualScroll"

pack .ys -side right -fill y
pack .sidebar -side left
pack .code

set lineNumber 0
foreach line $data {
    if {[regexp {([^(]+) (\([^)]+\)) (.*)} $line -> commit inf txt]} {
	set currentTime [lindex $inf 1]
	set user [lindex $inf 0]

	if {$currentTime > $lastHighlight} {
            set tag "highlight"
	} else {
            set tag "noHighlight"
	}
        
        .code insert $lineNumber.0 "$txt\n" $tag
        .sidebar insert $lineNumber.0 "$user\n" $tag
    }
    incr lineNumber
}

.code tag configure "highlight" -background orange
.sidebar tag configure "highlight" -background lightgreen

