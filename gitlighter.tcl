# This file is part of Gitlighter by PherricOxide
#
# Gitlighter is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.

# Gitlighter is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Gitlighter. If not, see <http://www.gnu.org/licenses/>.

#! /usr/bin/wish -f

set gitExec "git"
# Uncomment this for windows Vista + 
# set gitExec "C:/Program Files (x86)/Git/bin/git.exe"

if {[llength $argv] == 0} {
	set days 7
	puts "Warning: No arguements given."
	puts "Usage: wish gitlighter.tcl days"
} else {
	set days [lindex $argv 0]
}

proc dualScroll {arg1 arg2} {
    .code yview $arg1 $arg2
    .sidebar yview $arg1 $arg2
}

proc display {} {
    set filePath [lindex $::fileList [.fw.lb curselection]]
    set data [split [exec $::gitExec blame -te $filePath] "\n"]

    global lastHighlight
    .code delete 0.0 end
    .sidebar delete 0.0 end
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
}


set lastHighlight [clock add [clock seconds] "-$days" days]

text .code -width 200 -height 400 -bg white -yscrollcommand ".ys set" 
text .sidebar -width 35 -height 400 -bg grey -yscrollcommand ".ys set" 
scrollbar .ys -command "dualScroll"

pack .ys -side right -fill y
pack .sidebar -side left
pack .code

set folder [tk_getOpenFile]
cd [file dirname $folder]

set tmpFileList [exec $gitExec log --pretty=format: --name-only "--since=\"7 days ago\""]
set tmpFileList [lsort -unique -increasing $tmpFileList]
foreach fileName $tmpFileList {
    if {[file exists $fileName]} {
	lappend fileList $fileName
    }
}

toplevel .fw
frame .fw.f
listbox .fw.lb -height 90 -width 90
scrollbar .fw.sb -command [list .fw.lb yview]
.fw.lb configure -yscrollcommand [list .fw.sb set]
for {set item 0} {$item < [llength $fileList]} {incr item} {.fw.lb insert $item [lindex $fileList $item]}
pack .fw.lb .fw.sb -in .fw.f -side left -expand 1 -fill both
pack .fw.f

.code tag configure "highlight" -background orange
.sidebar tag configure "highlight" -background lightgreen

bind .fw.lb <<ListboxSelect>> [list display]

