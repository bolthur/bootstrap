#!/usr/bin/env node

// node dependencies
import { resolve, join } from "path";
import { readdirSync, readFileSync } from "fs";

// module dependencies
import chalk from "chalk";
import program from "commander";
import figlet from "figlet";
import YAML from "yaml";

// initial banner
console.log( chalk.red( figlet.textSync( "bolthur toolchain", "Slant" ) ) );

// program
program
  .version( "Version 0.1.0", "-v, --version", "output version number" )
  .description( "bolthur toolchain cli" )
  .option( "-i, --install", "install all toolchain packages" )
  .option( "-p, --package <package>", "install specified package only" )
  .parse( process.argv );

// handle no parameters
if ( 0 >= program.args.length ) {
  program.outputHelp();
  process.exit( 1 );
}

// TODO: Add handle for option -i/--install
// TODO: Add handle for option -p/--package
