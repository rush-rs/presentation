#!/bin/python3
import os
import sys
import subprocess
from pathlib import Path
from enum import Enum

LINT_ALL_SKIP = ['listings/incompatible_types.rush']


class Backend(Enum):
    analyzer = 0


JOBS = [
    {
        'in': 'listings/incompatible_types.rush',
        'out': 'listings/generated/incompatible_types.rush.out',
        'show_filename': 'incompatible_types.rush',
        'backend': Backend.analyzer,
    },
    {
        'in': 'listings/invalid_main_fn.rush',
        'out': 'listings/generated/invalid_main_fn.rush.out',
        'show_filename': 'invalid_main_fn.rush',
        'backend': Backend.analyzer,
    }
]


def analyzer_output(source: str, output: str, show_filename: str):
    input_path = os.path.realpath(source)
    output_path = os.path.realpath(output)

    start_dir = os.path.realpath(os.curdir)
    target_dir = os.path.realpath('./deps/rush/crates/rush-analyzer/')
    os.chdir(target_dir)

    res = subprocess.run(
        f'cargo r {input_path}',
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    if res.returncode != 1:
        print('analyzer returned non 1 exit-code')
        sys.stdout.buffer.write(res.stderr)
        sys.stdout.buffer.write(res.stdout)
        exit(1)

    # replace filename
    out = res.stdout.decode('utf-8').replace(input_path, show_filename)

    with open(output_path, 'w') as file:
        file.write(out)

    os.chdir(start_dir)

    print(f'generated analyzer output of {output_path}')


def riscv_hex(source: str, output: str, linewidth: int, head: str):
    input_path = os.path.realpath(source)
    output_path = os.path.realpath(output)

    start_dir = os.path.realpath(os.curdir)
    target_dir = os.path.realpath('./deps/rush/crates/rush-cli/')
    os.chdir(target_dir)

    subprocess.run(
        f'cargo r -- -t b -b riscv {input_path} -o output',
        shell=True,
        cwd=target_dir,
    ).check_returncode()

    res = subprocess.run('hexdump output', shell=True, stdout=subprocess.PIPE)
    if res.returncode:
        print('generating hexdump failed')
        sys.stdout.buffer.write(res.stderr)
        sys.stdout.buffer.write(res.stdout)
        exit(1)

    with open(output_path, 'w') as file:
        file.write(
            head
            + '\n'.join(
                [
                    line[:linewidth]
                    for line in res.stdout.decode('utf-8').split('\n')
                ]
            )
        )

    os.chdir(start_dir)

    print(f'generated {output_path}')


def lint_all():
    rush_files = list(Path('.').rglob('*.rush'))
    for rush_path in rush_files:
        if str(rush_path).startswith('deps/rush'):
            continue

        input_path = os.path.realpath(rush_path)

        skip = False
        for should_skip in LINT_ALL_SKIP:
            if os.path.realpath(should_skip) == input_path:
                should_skip = True
                break

        if skip:
            continue

        start_dir = os.path.realpath(os.curdir)
        os.chdir('./deps/rush/crates/rush-analyzer/')

        res = subprocess.run(
            f'cargo r {input_path}',
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        if res.returncode:
            print('\x1b[1;31m=== CHECK FAILURE ===\x1b[1;m')
            sys.stdout.buffer.write(res.stderr)
            sys.stdout.buffer.write(res.stdout)
            exit(1)

        os.chdir(start_dir)
        print(f'ok: {input_path}')
    print('\x1b[1;32m=== CHECK SUCCESS ===\x1b[1;m')


def assure_used_listings():
    unused = list()
    files = list(Path('.').rglob('listings/**/*'))
    for f_path in files:
        if not str(f_path).startswith('.git') and not str(f_path).startswith(
            'deps'
        ):
            res = subprocess.run(
                f'rg -q {f_path} -t tex',
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            if res.returncode:
                unused.append(str(f_path))
            print(f'ok (used): {f_path}')
    if unused:
        print('\x1b[1;31m=== CHECK FAILURE: NOT ALL USED ===\x1b[1;m')
        for f_path in unused:
            print(f'UNUSED: {f_path}')
        exit(1)
    print('\x1b[1;32m=== CHECK SUCCESS ===\x1b[1;m')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f'Expected exactly one argument, got {len(sys.argv) - 1}')
        exit(1)

    if sys.argv[1] == 'check':
        lint_all()
    elif sys.argv[1] == 'used':
        assure_used_listings()
    elif sys.argv[1] == 'hexdump':
        riscv_hex(
            './deps/paper/listings/simple.rush',
            './listings/rush_simple.hexdump',
            23,
            '; RISC-V binary\n',
        )
    elif sys.argv[1] == 'build':
        for job in JOBS:
            if job['backend'] == Backend.analyzer:
                analyzer_output(job['in'], job['out'], job['show_filename'])
            else:
                raise Exception('Invalid enum in job')
    else:
        print(f'Invalid command-line argument: {sys.argv[1]}')
        exit(1)
