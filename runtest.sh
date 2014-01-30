#!/bin/sh

proc_num=$(ps aux | grep node | grep -v grep | wc -l)
proc_num_s=$(echo $proc_num)
if [ "$proc_num_s" = "0" ]; then
    mocha --reporter list --compilers coffee:coffee-script test/
else
	echo "kill running server instances"
	ps aux | grep node
fi

