def exit_handler(event):
    if event.inferior == gdb.inferiors()[-1]:
        gdb.execute('quit')

gdb.events.exited.connect(exit_handler)
