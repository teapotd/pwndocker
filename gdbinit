source ~/pwn_gadget/pwn_gadget.py
source ~/pwndbg/gdbinit.py
source ~/Pwngdb/.gdbinit

set bn-rpc-host host.docker.internal

set context-clear-screen on
set context-sections regs disasm code stack backtrace expressions threads heap_tracker
set context-disasm-lines 8
set context-code-lines 8
set context-stack-lines 5
set context-backtrace-lines 5

set max-visualize-chunk-size 256
set hexdump-bytes 256
set hexdump-width 32

set gdb-workaround-stop-event 1
