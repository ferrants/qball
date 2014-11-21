#!/bin/sh

proc_num=$(ps aux | grep node | grep -v grep | wc -l)
proc_num_s=$(echo $proc_num)
if [ "$proc_num_s" = "0" ]; then
    mv balls.json balls.json.orig
    ./node_modules/mocha/bin/mocha --reporter list --compilers coffee:coffee-script/register test/
    mv balls.json.orig balls.json
else
	echo "kill running server instances"
	ps aux | grep node
fi

