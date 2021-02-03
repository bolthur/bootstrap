
import argparse
import yaml
import os
import requests
import shutil
import pathlib
import multiprocessing
import subprocess


# generate argument parser
parser = argparse.ArgumentParser()
# add supported arguments
parser.add_argument( '--host', help='build host toolchain', action='store_true' )
# parse arguments
args = parser.parse_args()



# base dir
base_directory = 'build'
source_directory = 'source'
# handle host build
if args.host:
  tool_directory = os.path.join( 'build', 'host' )
  tool_information_file = os.path.join( 'build', 'host.yaml' )



# check for set tool directory
try:
  tool_directory
except NameError:
  print( 'No tool directory set to be built' )
  quit()
# check for set tool information
try:
  tool_information_file
except NameError:
  print( 'No tool information file set' )
  quit()



# parse tool file
with open( tool_information_file, 'r' ) as stream:
  # parse yaml file
  try:
    tool_information = yaml.load( stream, Loader=yaml.FullLoader )
  except yaml.YAMLError as exception:
    print( exception )
    quit()



env_cross_prefix = os.path.join( tool_information[ 'prefix' ], 'cross' )
env_source_directory = os.path.join( tool_information[ 'prefix' ], 'source' )
env_build_directory = os.path.join( tool_information[ 'prefix' ], 'build' )
env_experimental = tool_information[ 'experimental' ]



# packages array
package_list = []



# search helper for check if exists
def lookup_package( package_list, **kw ):
  return filter( lambda i: all(( i[ k ] == v for ( k, v ) in kw.items() ) ), package_list )

# function to parse yaml and push to packages with recursive dependency handling
def prepare_package_order( package_list, path, base ):
  # skip non yaml files
  if not path.endswith( '.yaml' ):
    return

  # load and parse file
  with open( path, 'r' ) as stream:
    # parse yaml file
    try:
      data = yaml.load( stream, Loader=yaml.FullLoader )
    except yaml.YAMLError as exception:
      print( exception )
      quit()

  idx = None
  # handle possible dependencies
  try:
    # iterate over dependencies
    for dependency in data[ 'dependency' ]:
      # skip already handled stuff
      if list( lookup_package( package_list, name=dependency ) ):
        continue
      # prepare path list for join
      path_list = [ base ] + ( dependency + '.yaml' ).split( '-', 1 )
      # recursive call
      prepare_package_order( package_list, os.path.join( *path_list ), base )
    # iterate again over dependencies to get max insert index
    for dependency in data[ 'dependency' ]:
      current = next( ( index for ( index, d ) in enumerate( package_list ) if d[ 'name' ] == dependency ), None )
      if current is None:
        continue
      if idx is None or idx < current:
        idx = current
    # remove useless dependency key
    del data[ 'dependency' ]
  except KeyError:
    pass

  # skip already handled stuff
  if list( lookup_package( package_list, name=data[ 'name' ] ) ):
    return
  # push back tool
  if idx is None:
    package_list.append( data )
  else:
    package_list.insert( idx + 1, data )

# prepare package source
def prepare_package( package_list, base ):
  for package in package_list:
    # get name and version information
    info = package[ 'source' ].split( '@' )
    name = info[ 0 ]
    version = info[ 1 ]

    # build path to file
    path = os.path.join( *[ base, name + '.yaml' ] )
    # load and parse file
    with open( path, 'r' ) as stream:
      # parse yaml file
      try:
        data = yaml.load( stream, Loader=yaml.FullLoader )
      except yaml.YAMLError as exception:
        print( exception )
        quit()

    # matching = [ s for s in some_list if 'abc' in s]
    if not version in data[ 'allowed_version' ]:
      print( 'used version is not allowed!' )
      quit()

    # prepare url for fetch
    data[ 'url' ] = data[ 'url' ].replace( '{VERSION}', version )
    data[ 'extract_name' ] = data[ 'extract_name' ].replace( '{VERSION}', version )
    data[ 'version' ] = version
    try:
      data[ 'url_file_overwrite' ] = data[ 'url_file_overwrite' ].replace( '{VERSION}', version )
    except KeyError:
      pass
    # replace source information of package with data from source file
    package[ 'source' ] = data

# download sources from package data
def download_package( package_list, base ):
  # create folder
  if not os.path.exists( base ):
    os.makedirs( base )

  # iterate packages and download sources
  for package in package_list:
    # cache url and extract filename
    url = package[ 'source' ][ 'url' ]
    filename = url.split( '/' )[ -1 ]
    # handle optional file overwrite
    try:
      filename = package[ 'source' ][ 'url_file_overwrite' ]
    except KeyError:
      pass
    # get target file
    target_file = os.path.join( base, filename )

    # skip if already loaded
    if not os.path.exists( target_file ):
      print( '-> loading ' + target_file )
      # request file
      response = requests.get( url, stream=True )
      # handle invalid status code
      if response.status_code != 200:
        print( 'unable to download file ' + url )
        quit()
      # save file
      with open( target_file, 'wb' ) as stream:
        stream.write( response.raw.read() )

    # Extract sources
    if not os.path.exists( os.path.join( base, package[ 'source' ][ 'extract_name' ] ) ):
      print( '-> extracting ' + target_file )
      shutil.unpack_archive( target_file, base )

# apply patches to sources if set
def patch_package( package_list, source_directory, patch_directory ):
  for package in package_list:
    # get extract name
    extract_name = os.path.join(
      source_directory,
      package[ 'source' ][ 'extract_name' ],
      '.patch.applied'
    )
    # skip if already patched
    if os.path.exists( extract_name ):
      continue

    print( '-> patching ' + package[ 'source' ][ 'extract_name' ] )
    # set
    package_patch_folder = None

    # check for experimental folder
    if env_experimental:
      # build patch folder
      package_patch_folder = os.path.join(
        patch_directory,
        '.experimental',
        package[ 'source' ][ 'name' ],
        package[ 'source' ][ 'version' ]
      )
      # remove if not set
      if not os.path.exists( package_patch_folder ):
        package_patch_folder = None

    # check for patch folder is not set
    if package_patch_folder is None:
      # build default patch dir
      package_patch_folder = os.path.join(
        patch_directory,
        package[ 'source' ][ 'name' ],
        package[ 'source' ][ 'version' ]
      )
      # check if folder exists
      if not os.path.exists( package_patch_folder ):
        package_patch_folder = None

    # skip if not set
    if package_patch_folder is None:
      # mark as patched
      pathlib.Path( extract_name ).touch()
      # skip rest
      continue

    # apply patch
    source_folder = os.path.abspath( os.path.join( source_directory, package[ 'source' ][ 'extract_name' ] ) )
    patch_folder = os.path.abspath( package_patch_folder )
    # patch command template
    patch_command = 'patch -d {SOURCE} -p0 < {PATCH}'
    # file by file
    for subdir, _dirs, files in os.walk( patch_folder ):
      for filename in files:
        # build patch file
        patch_file = os.path.abspath( os.path.join( subdir, filename ) )
        # build command to execute
        to_execute = patch_command.replace( '{SOURCE}', source_folder )
        to_execute = to_execute.replace( '{PATCH}', patch_file )
        print( to_execute )
        ## apply patch
        if 0 != subprocess.call( to_execute, cwd=source_folder, shell=True ):
          print( 'Error on patching ' + package[ 'source' ][ 'extract_name' ] )
          quit()

    # mark as patched
    pathlib.Path( extract_name ).touch()

def prepare_command( command, version, out_prefix, source_directory ):
  to_execute = command.replace( '{VERSION}', version )
  to_execute = to_execute.replace( '{PREFIX}', os.path.abspath( out_prefix ) )
  to_execute = to_execute.replace( '{CPU_COUNT}', str( multiprocessing.cpu_count() ) )
  to_execute = to_execute.replace( '{SOURCE_DIR}', os.path.abspath( source_directory ) )
  to_execute = to_execute.replace( '{SYSROOT}', os.path.abspath( os.path.join( out_prefix, '..', 'sysroot' ) ) )
  return to_execute

# build and install packages
def build_install_package( package_list, out_prefix, build_directory, source_directory ):
  for package in package_list:
    # get extract name
    build_folder = os.path.join( build_directory, package[ 'source' ][ 'extract_name' ] )
    build_file = os.path.join( build_folder, '.build.applied' )
    install_file = os.path.join( build_folder, '.install.applied' )
    configure_file = os.path.join( build_folder, '.configure.applied' )

    # create build folder if not existing
    if not os.path.exists( build_folder ):
      os.makedirs( build_folder )

    # possible prefix suffix
    prefix_suffix = None
    try:
      prefix_suffix = package[ 'prefix_suffix' ]
    except KeyError:
      pass

    used_prefix = out_prefix
    if not prefix_suffix is None:
      used_prefix = os.path.join( out_prefix, prefix_suffix )

    env = dict( **os.environ )
    try:
      for ext in package[ 'path' ]:
        env_str = os.path.abspath( ext.replace( '{PREFIX}', used_prefix ) )
        env[ 'PATH' ] = env_str + os.pathsep + env[ 'PATH' ]
    except KeyError:
      pass

    # execute configure steps if not done
    if not os.path.exists( configure_file ):
      try:
        for command in package[ 'configure' ]:
          # default source path
          source_path = os.path.join( source_directory, package[ 'source' ][ 'extract_name' ] )
          # handle possible differences
          if not isinstance( command, str ):
            source_path = command[ 'folder' ].replace( '{SOURCE_DIR}', source_path )
            to_execute = command[ 'command' ]
          else:
            to_execute = command
          # path extension
          # if not env_path is None:

          # execute command
          if 0 != subprocess.call( to_execute, cwd=os.path.abspath( source_path ), shell=True, env=env ):
            print( 'Error on configure ' + package[ 'source' ][ 'extract_name' ] )
            quit()
      except KeyError:
        pass
      # create file
      pathlib.Path( configure_file ).touch()

    # execute build steps if not done
    if not os.path.exists( build_file ):
      # execute build commands
      print( '-> building ' + package[ 'source' ][ 'extract_name' ] )
      # execute command by command
      for command in package[ 'build' ]:
        # prepare command to execute
        to_execute = prepare_command(
          command,
          package[ 'source' ][ 'version' ],
          used_prefix,
          os.path.join( source_directory, package[ 'source' ][ 'extract_name' ] )
        )
        # execute command in folder
        if 0 != subprocess.call( to_execute, cwd=os.path.abspath( build_folder ), shell=True, env=env ):
          print( 'Error on installing ' + package[ 'source' ][ 'extract_name' ] )
          quit()
      # create file
      pathlib.Path( build_file ).touch()

    # execute install commands if not done
    if not os.path.exists( install_file ):
      # execute commands
      print( '-> installing ' + package[ 'source' ][ 'extract_name' ] )
      # command by command
      for command in package[ 'install' ]:
        # prepare command to execute
        to_execute = prepare_command(
          command,
          package[ 'source' ][ 'version' ],
          used_prefix,
          os.path.join( source_directory, package[ 'source' ][ 'extract_name' ] )
        )
        # execute command in folder
        if 0 != subprocess.call( to_execute, cwd=os.path.abspath( build_folder ), shell=True, env=env ):
          print( 'Error on installing ' + package[ 'source' ][ 'extract_name' ] )
          quit()
      # create file
      pathlib.Path( install_file ).touch()


# iterate through files and populate packages
for subdir, dirs, files in os.walk( tool_directory ):
  for filename in files:
    prepare_package_order( package_list, os.path.join( subdir, filename ), base_directory )
# prepare package source data
prepare_package( package_list, source_directory )
# download sources
download_package( package_list, env_source_directory )
# apply package patches if set
patch_package( package_list, env_source_directory, 'patch' )
# build and install packages
build_install_package( package_list, env_cross_prefix, env_build_directory, env_source_directory )
