
#
# Copyright (C) 2018 - 2020 bolthur project.
#
# This file is part of bolthur/kernel.
#
# bolthur/kernel is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bolthur/kernel is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bolthur/kernel.  If not, see <http://www.gnu.org/licenses/>.
#

import os, system, yaml, yaml, streams
import parseopt

type TDevice = object
  name: string
  arch: string
  tune: string
  float_abi {.defaultVal: "".}: string
  fpu {.defaultVal: "".}: string

type TArchitecture = object
  arm {.defaultVal: @[].}: seq[ TDevice ]
  aarch64 {.defaultVal: @[].}: seq[ TDevice ]

proc `[]`* ( t: TArchitecture, s: string ): seq[ TDevice ] =
  # getter
  case s
  of "arm":
    return t.arm
  of "aarch64":
    return t.aarch64
  else: return @[]

proc main(): int =
  # variables
  var target: string = ""
  var specific_target: string = ""
  var board: string = ""
  var prefix: string = ""
  var build_type: string = ""
  var experimental: bool = false
  var rebuild_binutils: bool = false
  var rebuild_gcc: bool = false
  var rebuild_newlib: bool = false
  var rebuild_gdb: bool = false
  # parse arguments
  var arg_parse = initOptParser()
  # iterate options
  for kind, key, val in arg_parse.getopt():
    case key:
    of "experimental":
      experimental = true
    of "prefix":
      prefix = val
    of "target":
      target = val
    of "specific-target":
      specific_target = val
    of "board":
      board = val
    of "rebuild-binutils":
      rebuild_binutils = true
    of "rebuild-gcc":
      rebuild_gcc = true
    of "rebuild-newlib":
      rebuild_newlib = true
    of "rebuild-gdb":
      rebuild_gdb = true
    of "rebuild-all":
      rebuild_binutils = true
      rebuild_gcc = true
      rebuild_newlib = true
      rebuild_gdb = true
    of "type":
      build_type = val
  # check for valid build type
  if "" == build_type or ( "host" != build_type and "specific" != build_type ):
    echo "Invalid build type only \"host\" or \"specific\" are allowed"
    return 1
  # check for valid board
  if "" == board or not fileExists( "target" & DirSep & board & ".yaml" ):
    echo "Invalid board, \"" &  "target" & DirSep & board & ".yaml\" doesn't exits"
    return 1

  # load board
  let s: FileStream = newFileStream( "target" & DirSep & board & ".yaml" )
  var arch: TArchitecture
  s.load( arch )
  s.close()
  # consider architecture
  let device: seq[ TDevice ] = arch[ target ]
  var chosen: TDevice
  if 1 < device.len:
    # try to get device
    for dev in device:
      if dev.arch == specific_target:
        chosen = dev
  else:
    chosen = device[ 0 ]
  echo chosen

  #for file in walkDirRec( build_type ):
  #  let s: FileStream = newFileStream( file )
  #  var arch: TArchitecture
  #  s.load( arch );
  #  echo arch
  #  s.close();

  return 0


#
#  for file in walkDirRec( "target" ):
#    let s: FileStream = newFileStream( file )
#
#    var arch: TArchitecture
#    s.load( arch );
#    echo arch
#    s.close();
#
when isMainModule:
  quit( main() )
