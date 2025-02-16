enabled = False

def exit_handler(event):
    if enabled and event.inferior == gdb.inferiors()[-1]:
        gdb.execute('quit')

gdb.events.exited.connect(exit_handler)

class Autoexit(gdb.Command):
    """Automatically exit gdb on inferior exit."""
    enabled = False

    def __init__(self):
        super(Autoexit, self).__init__('autoexit', gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        global enabled
        enabled = not enabled
        print(f'autoexit is ' + ('on' if enabled else 'off'))

Autoexit()
