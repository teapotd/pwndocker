import pwndbg.aglib.proc
import pwndbg.aglib.vmmap

def set_base_var(name, pattern):
    for p in pwndbg.aglib.vmmap.get():
        if pattern in p.objfile:
            gdb.set_convenience_variable(name, p.vaddr)
            return

class Vars(gdb.Command):
    """Setup some convenience vars."""

    def __init__(self):
        super(Vars, self).__init__('vars', gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        set_base_var('exe', pwndbg.aglib.proc.exe)
        set_base_var('libc', 'libc')
        set_base_var('ld', 'ld-linux')
        set_base_var('heap', '[heap]')
        set_base_var('vvar', '[vvar]')
        set_base_var('vdso', '[vdso]')
        set_base_var('vsyscall', '[vsyscall]')

Vars()
