
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

import os, yaml, yaml, streams

type TDevice = object
  name: string
  arch: string
  tune: string
  float_abi {.defaultVal: "".}: string
  fpu {.defaultVal: "".}: string

type TArchitecture = object
  arm {.defaultVal: @[].}: seq[TDevice]
  aarch64 {.defaultVal: @[].}: seq[TDevice]

proc main() =
  for file in walkDirRec "target":
    let s: FileStream = newFileStream( file )

    var arch: TArchitecture
    load(s, arch);
    echo arch
    s.close();

when isMainModule:
  main()
