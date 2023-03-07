#!/usr/bin/python3

import sys
import os
import subprocess

commands = {
    0: {
        'workdir': '/tmp/',
        'command': """
        echo "fn main() {\n    exit(42);\n}" > test.rush &&
        vim test.rush &&
        rush-cli -t b -b riscv test.rush &&
        vim +10 test.s
        """,
    },
    1: {
        'workdir': './deps/rush/samples/tests/',
        'command': """
        python3 main.py run
        """,
    },
}


def run():
    if len(sys.argv) != 2:
        print(f'Expected exactly one argument, got {len(sys.argv) - 1}')
        exit(1)

    command = commands[int(sys.argv[1])]
    start_dir = os.path.realpath(os.curdir)
    os.chdir(os.path.abspath(command['workdir']))

    try:
        subprocess.run(
            command['command'],
            shell=True,
        )
    except KeyboardInterrupt:
        pass

    os.chdir(start_dir)


if __name__ == '__main__':
    run()
