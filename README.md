# bootstrap

> bootsrap is a project to build all the necessary software on host system for development of kernel and other related projects.

## Requirements

* Linux or macOS
* python 3

## Usage

To build all the necessary software for development just execute one of the following commands.

```bash
./tool.py --host
```

```bash
python3 tool.py --host
```

All host software installed with this python script is installed into folder `/opt/bolthur`, so it needs to be ensured, that write access for user is set correctly.

## Hacking

[hacking](hacking.md) contains a bunch of libraries and/or programs with compile/configure commands, which are not yet ported but somehow planned to be ported.

## License
[GPL-3.0](LICENSE)
