source ~/pwn_gadget/pwn_gadget.py
source ~/pwndbg/gdbinit.py
source ~/Pwngdb/.gdbinit
source ~/splitmind/gdbinit.py

python
import splitmind
(splitmind.Mind()
	.right('-f', display='backtrace', size='60')
	.show('threads', banner='top')
	.show('expressions', banner='top')
	.above('-f', display='legend', size='30')
	.show('regs')
	.show('stack', banner='top')
	.right(display='code', of='legend', size='88')
	.right(display='disasm', of='legend', size='50%')
).build(nobanner=True)
end

set context-sections regs disasm code stack backtrace threads expressions
set context-disasm-lines 15
set context-code-lines 28
set context-stack-lines 8
set context-backtrace-lines 25
set context-max-threads 4
set disasm-annotations off

set max-visualize-chunk-size 256
set hexdump-bytes 256
set hexdump-width 16

set gdb-workaround-stop-event 1
set bn-rpc-host host.docker.internal
