from elftools.elf.elffile import ELFFile
import pwndbg.aglib.kernel

class KernelSymbols(gdb.Command):
    """Load and rebase kernel symbols from ELF file."""

    def __init__(self):
        super(KernelSymbols, self).__init__('ksyms', gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        base = pwndbg.aglib.kernel.kbase()

        if base is None:
            print('Unable to locate the kernel base')
            return

        gdb.execute('set $kbase={}'.format(hex(base)))

        # https://stackoverflow.com/a/33087762
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

KernelSymbols()
