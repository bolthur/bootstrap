#!/usr/bin/env node

// node dependencies
import { resolve, join } from "path";
import { readdirSync, existsSync } from "fs";

// module dependencies
import chalk from "chalk";
import program from "commander";
import figlet from "figlet";
import YAML from "yaml";

// local dependencies
import { ICommand } from "./command"

// initial banner
console.log( chalk.red( figlet.textSync( "bolthur toolchain", "Slant" ) ) );

// program
const cmd: ICommand = program
  .version( "Version 0.1.0", "-v, --version", "output version number" )
  .description( "bolthur toolchain cli" )
  .option(
    "-p, --package <package>",
    "specify package to be installed ( comma separated list ), e.g. cross-gcc@9.1",
    ( val: string ) => val.split( "," )
  )
  .requiredOption( "-i, --install", "install all toolchain packages" )
  .parse( process.argv );

// handle no parameters
if ( ! process.argv.slice(2).length ) {
  program.outputHelp();
  process.exit( 0 );
}

// check for packages are existing
if (
  "undefined" !== typeof cmd.package
  && 0 < cmd.package.length
) {
  // get possible packages
  const packageDir: string[] = readdirSync( resolve( "package" ) );
  // get filter valid packages from cmd
  const packageCmd: string[] = cmd.package.filter( ( item: string ) => {
    // split by @
    const s: string[] = item.split( "@" );
    // set package
    const pkg: string = s[ 0 ];
    // use version if existing, else fallback to latest
    const version: string = 2 === s.length ? s[ 1 ] : "latest";

    // check for package
    const found: number|undefined = packageDir.indexOf( pkg );
    // handle skip
    if ( -1 === found ) {
      return false;
    }

    // check for config file
    return existsSync( resolve( join( "package", pkg, version + ".yml" ) ) );
  } );

  // Gather unknown packages
  const packageUnknown: string[] = cmd.package.filter(
    ( item: string ) => 0 > packageCmd.indexOf( item )
  );

  // print error
  if ( 0 < packageUnknown.length ) {
    for ( const unknown of packageUnknown ) {
      console.log( chalk.bold.red( `Unknown package "${unknown}"` ) );
    }
    // exit on invalid package
    process.exit( 1 );
  }
}

// TODO: Prepare list of packages to be built
//   - all packages when package parameter is not set
//   - only specified packages when package parameter is set

// TODO: Add handle for option -i/--install
