#!/usr/bin/env node

// node dependencies
import { parse } from "path";
import { readdirSync } from "fs";

// module dependencies
import chalk from "chalk";
import program from "commander";
import figlet from "figlet";

// initial banner
console.log( chalk.red( figlet.textSync( "bolthur toolchain", "Slant" ) ) );

// program
program
  .version( "Version 0.1.0", "-v, --version", "output version number" )
  .description( "bolthur toolchain cli" )
  .option( "-i, --install", "install toolchain" )
  .parse( process.argv );

// handle no parameters
if ( 0 >= program.args.length ) {
  program.outputHelp();
  process.exit( 1 );
}

// TODO: Add handle for option -i/--install
