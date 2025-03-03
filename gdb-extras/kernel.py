from elftools.elf.elffile import ELFFile
import pwndbg.aglib.kernel
import pwndbg.aglib.typeinfo
import pwndbg.gdblib.hooks
from pwndbg.gdblib.functions import GdbFunction

class KernelSymbols(gdb.Command):
    """Load and rebase kernel symbols from ELF file."""

    def __init__(self):
        super(KernelSymbols, self).__init__('ksyms', gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):
        # Workaround pwndbg not updating arch on startup.
        for i in range(2):
            pwndbg.gdblib.hooks.init()

        base = pwndbg.aglib.kernel.kbase()

        if base is None:
            print('Unable to locate the kernel base')
            return

        gdb.set_convenience_variable('kbase', base)

        # Relocate all sections properly (https://stackoverflow.com/a/33087762)
        with open(args, 'rb') as f:
            elf = ELFFile(f)
            offset = base - elf.get_section_by_name('.text').header.sh_addr
            cmd = f'add-symbol-file {args} 0x{base:X}'
            for sec in elf.iter_sections():
                if not sec.name or sec.name == '.text' or sec.header.sh_addr == 0:
                    continue
                addr = sec.header.sh_addr + offset
                cmd += f' -s {sec.name} 0x{addr:X}'
            gdb.execute(cmd)

class KernelScripts(gdb.Command):
    """Initialize kernel GDB scripts."""

    def __init__(self):
        super(KernelScripts, self).__init__('kscripts', gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):
        if pwndbg.aglib.typeinfo.load("struct file") is None:
            gdb.execute(f'add-symbol-file {args}/vmlinux.types')
        gdb.execute(f'source {args}/vmlinux-gdb.py')

KernelSymbols()
KernelScripts()

@GdbFunction(only_when_running=True)
def virt2phys(value):
    return pwndbg.aglib.kernel.virt_to_phys(int(value))

@GdbFunction(only_when_running=True)
def phys2virt(value):
    return pwndbg.aglib.kernel.phys_to_virt(int(value))

@GdbFunction(only_when_running=True)
def phys2pfn(value):
    return pwndbg.aglib.kernel.phys_to_pfn(int(value))

@GdbFunction(only_when_running=True)
def pfn2phys(value):
    return pwndbg.aglib.kernel.pfn_to_phys(int(value))

@GdbFunction(only_when_running=True)
def pfn2page(value):
    return pwndbg.aglib.kernel.pfn_to_page(int(value))

@GdbFunction(only_when_running=True)
def page2pfn(value):
    return pwndbg.aglib.kernel.page_to_pfn(int(value))

@GdbFunction(only_when_running=True)
def virt2pfn(value):
    return pwndbg.aglib.kernel.virt_to_pfn(int(value))

@GdbFunction(only_when_running=True)
def pfn2virt(value):
    return pwndbg.aglib.kernel.pfn_to_virt(int(value))

@GdbFunction(only_when_running=True)
def phys2page(value):
    return pwndbg.aglib.kernel.phys_to_page(int(value))

@GdbFunction(only_when_running=True)
def page2phys(value):
    return pwndbg.aglib.kernel.page_to_phys(int(value))

@GdbFunction(only_when_running=True)
def virt2page(value):
    return pwndbg.aglib.kernel.virt_to_page(int(value))

@GdbFunction(only_when_running=True)
def page2virt(value):
    return pwndbg.aglib.kernel.page_to_virt(int(value))
