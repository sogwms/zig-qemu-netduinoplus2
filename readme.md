## Environement

- zig@0.11.0
- qemu@8.0.0
- git-bash (needed on windows)

## Usage

- use elf
```shell
zig build 

bash runqemu-elf.sh
```

Or

- use bin
```shell
zig build

bash runqemu-bin.sh
```

## Debug

see runqemu-gdb.sh and doc/gdb.md