import atexit
import os
from pwndbg.commands.context import contextoutput
from pwndbg.ui import get_window_size

clearing_code = '\x1b[H\x1b[2J'

class TrimmedFileOutput:
    def __init__(self, *args) -> None:
        self.args = args
        self.cur_line = 0
        self.max_lines = None
        self.handle = None

    def __enter__(self):
        self.handle = open(*self.args)
        self.max_lines = get_window_size(self.handle)[0]
        return self

    def __exit__(self, *args, **kwargs) -> None:
        self.handle.close()

    def __hash__(self):
        return hash(self.args)

    def __eq__(self, other):
        return isinstance(other, TrimmedFileOutput) and self.args == other.args

    def write(self, data):
        for i, line in enumerate(data.split('\n')):
            for j, part in enumerate(line.split(clearing_code)):
                if j > 0:
                    self.handle.write(clearing_code)
                    self.cur_line = 0
                if self.cur_line >= self.max_lines:
                    continue
                if i > 0 and j == 0:
                    self.handle.write('\n')
                self.handle.write(part)
            self.cur_line += 1
        self.cur_line -= 1

    def flush(self):
        return self.handle.flush()

    def isatty(self):
        return self.handle.isatty()

    def fileno(self):
        return self.handle.fileno()

pwndbg.commands.context.FileOutput = TrimmedFileOutput

def split(flags):
    cmd = 'setterm --linewrap off; cat -'
    proc = os.popen(f'tmux split-window -dPF "#{{pane_id}}:#{{pane_tty}}" {flags} "{cmd}"')
    id, tty = proc.read().strip().split(':')
    atexit.register(lambda: os.popen(f'tmux kill-pane -t {id}').read())
    return id, tty

class TmuxLayout(gdb.Command):
    """Setup tmux split layout."""
    enabled = False

    def __init__(self):
        super(TmuxLayout, self).__init__('tmux', gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        if self.enabled:
            print('Layout already initialized!')
            return

        show_src = ('nosrc' not in args)

        right = split('-fhl 60')
        top_left = split('-fvbl 30')
        if show_src:
            top_right = split('-hl 88 -t ' + top_left[0])
        top_middle = split('-hp 50 -t ' + top_left[0])

        contextoutput('legend', top_left[1], True, 'none')
        contextoutput('regs', top_left[1], True, 'none')
        contextoutput('stack', top_left[1], True, 'top')

        contextoutput('disasm', top_middle[1], True, 'none')
        if show_src:
            contextoutput('code', top_right[1], True, 'none')

        contextoutput('backtrace', right[1], True, 'none')
        contextoutput('threads', right[1], True, 'top')
        contextoutput('expressions', right[1], True, 'top')

        self.enabled = True

TmuxLayout()
