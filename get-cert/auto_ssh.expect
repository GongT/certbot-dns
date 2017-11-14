#!/usr/bin/expect --


if { [info exists ::env(TIMEOUT) ] } {
	set TIMEOUT $::env(TIMEOUT)
} else {
	set TIMEOUT 2
}

proc reset_timeout {} {
	global TIMEOUT
	set timeout $TIMEOUT
}

proc cancel_timeout {} {
	set timeout -1
}

proc usage {} {
	puts "Usage: auto_ssh uri \[args to ssh\]"
	puts "\tURI must contain username, password and host. Optional port and path."
	puts "example:\n\tauto_ssh root:123456@localhost:22/data/web\n"
	exit 255
}

# Start
reset_timeout


if { ![ string length $argv ] } {
	usage
}


set HOST [ lindex $argv 0 ]
set ARGS [ lrange $argv 1 end ]

if {
	! [ regexp -expanded { ^([^:@]+)(?:\:(.*)|)@([a-z0-9A-Z_\.\-]+)?:?([0-9]+)?(.*)? } $HOST -> USER PASS HOST PORT PATH ]
} {
	if {
		! [ regexp -expanded { ([a-z0-9A-Z_\.\-]+)?:?([0-9]+)?(.*)? } $HOST -> HOST PORT PATH ]
	} {
		puts "URI parse error. ($HOST)\n"
		usage
	}
	set USER ""
	set PASS ""
}

if { ![ string length $PASS ] } {
	puts " --> WARN: No password given.\n"
}

proc command_exist {} {
	global spawn_id
	set ret [wait]
	set CODE [ lindex $ret 3 ]
	if { $CODE==0 } {
		send_user " ---> Command finished successfully.\n"
		exit 0
	} else {
		send_user " ---> ERROR: Command exited unexpectedly. (ret=$CODE)\n"
		exit 2
	}
}

proc real_spawn_ssh {} {
	global TIMEOUT
	global HOST
	global PORT
	global USER
	global ARGS
	global spawn_id
	
	global name
	global slave
	global cols
	global rows
	global spawn_out


	if { [ string length $PORT ] } {
		set RUN "/usr/bin/ssh -p $PORT"
	} else {
		set RUN "/usr/bin/ssh"
	}
	if { [ string length $USER ] } {
		set RUNUSER "$USER@"
	} else {
		set RUNUSER ""
	}
	
	send_user " ---> spawning process $RUN $RUNUSER$HOST $ARGS\n"
	if [catch "spawn $RUN $RUNUSER$HOST $ARGS" reason] {
		send_user " ---> ERROR: spawn: $reason\n"
		exit 255
	}
	trap { # trap sigwinch and pass it to the child we spawned
		set rows [stty rows]
		set cols [stty columns]
		stty rows $rows columns $cols < $spawn_out(slave,name)
	} WINCH
}

proc main {} {
	global PASS
	global TIMEOUT
	
	real_spawn_ssh
	
	send_user " ---> login start.\n"
	expect {
		"No route to host" {
			send_user " ---> ERROR: cannot connect to host.\n"
			exit 3
		}
		"Connection refused" {
			send_user " ---> ERROR: cannot connect to host.\n"
			exit 4
		}
		"Permission denied" {
			send_user "\n ---> ERROR: password wrong.\n"
			exit 3
		}
		"Too many authentication failures" {
			send_user "\n ---> ERROR: password wrong.\n"
			exit 3
		}
		
		-re "Connection to .* closed\.|Connection closed by remote host" {
			send_user " ---> Session finished successfully.\n"
			exit 0
		}
		eof {
			command_exist
		}
		
		timeout {
			send_user " ---> Timeout !! (after waitting for $TIMEOUT seconds)\n"
			exit 1
		}
		
		-re "^debug\d+:" {
			exp_continue
		}
		"yes/no)?" {
			send "yes\n"
			exp_continue
		}
		"assword:" {
			send_user "$PASS\n"
			send "$PASS\n"
			cancel_timeout
			send_user " ---> waitting prompt."
			exp_continue
		}
		"]#" { return 0 }
		"]\$" { return 0 }
		"~#" { return 0 }
		"~\$" { return 0 }
		"Last login:" { return 0 }
		"Entering interactive session" { return 0 }
		default {
			send_user " ---> listen.\n"
			exp_continue
		}
	}
	
	
	send_user " ---> ERROR: Command exited unexpectedly (2) .\n"
	return 1
}


if { [catch { main } err] } {
	send_user "错误： $err ：\n"
	exit
}

if { [catch { send "\n" } err] } {
	send_user "$err \n"
	send_user " ---> Session finished successfully.\n"
	wait -nowait
} else {
	if { [info exists PATH ] && [ string length $PATH ] } {
		send "if \[ -f \"$PATH\" \]; then cd `dirname \"$PATH\"`; vi \"$PATH\"; else if \[ -d \"$PATH\" \]; then cd \"$PATH\" else pwd; fi; fi\n"
	}
	send_user " ---> Login complete.\n"
	interact
	wait -nowait
}

