source ~/pwn_gadget/pwn_gadget.py
source ~/pwndbg/gdbinit.py
source ~/Pwngdb/.gdbinit

source ~/gdb-extras/autoexit.py
source ~/gdb-extras/layout.py

set context-sections regs disasm code stack backtrace threads expressions
set context-disasm-lines 28
set context-code-lines 28
set context-stack-lines 25
set context-backtrace-lines 25
set context-max-threads 4

set disasm-annotations off
set show-compact-regs on

set max-visualize-chunk-size 256
set hexdump-bytes 256
set hexdump-width 16

set gdb-workaround-stop-event 1
set bn-rpc-host host.docker.internal
