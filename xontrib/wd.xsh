import os
import sys
import subprocess
from pathlib import Path

CONFIGFILE = os.path.expanduser('~/.warprc')
Path(CONFIGFILE).touch()

def read_config():
    data = {}
    with open(CONFIGFILE) as fd:
        for line in fd:
            key, path = line.split(':', 1)
            data[key] = os.path.expanduser(path.strip())
    return data

def shorten_path(path):
    homedir = os.path.expanduser('~')
    if homedir in path:
        path = '~{}'.format(path[len(homedir):])
    return path

def write_config(data):
    with open(CONFIGFILE, 'w+') as fd:
        for key, value in data.items():
            fd.write("{}:{}\n".format(key, shorten_path(value)))

def select_item_fzf(items, prompt):
    proc = subprocess.Popen(['fzf', '--prompt', prompt], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    proc.stdin.write(('\n'.join(items)).encode('utf-8'))
    proc.stdin.close()
    proc.wait()
    return proc.stdout.read().strip().decode('utf-8')

def cmd(args):
    if len(args) == 0:
    	args = ["select"]
    if len(args) == 1:
        data = read_config()
        if args[0] in data:
            os.chdir(data[args[0]])
            return
        elif args[0] == 'list':
            for key in data:
                print(' * {}'.format(key))
            return
        elif args[0] == 'select':
            key = select_item_fzf(list(data.keys()), 'Select warp dir')
	    if len(key):
	            os.chdir(data[key])
            return
        else:
            print('No such bookmark {}'.format(args[0]))
            return 1
    elif len(args) == 2:
        data = read_config()
        if args[0] not in ['add!', 'add', 'remove', 'list']:
            print('Invalid command {}'.format(args[0]))
            return  1
        elif args[0] == 'add':
            if args[1] in data:
                print('Bookmark {} already exists with value {}. To overwrite use `add!`.'.format(args[1], data[args[1]]))
                return 1
            data[args[1]] = os.path.abspath(os.curdir)
            write_config(data)
        elif args[0] == 'add':
            data[args[1]] = os.path.abspath(os.curdir)
            write_config(data)
        elif args[0] == 'remove':
            if args[1] in data:
                data.pop(args[1])
                write_config(data)
    else:
        print('Invalid amount of commands')
        return


aliases['wd'] = cmd
