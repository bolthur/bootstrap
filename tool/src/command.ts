
import { Command } from "commander";

/**
 * Command interface extending commander one
 *
 * @export
 * @interface ICommand
 * @extends {Command}
 */
export interface ICommand extends Command {
  /**
   * Optional package parameter
   *
   * @type {string[]}
   * @memberof ICommand
   */
  package?: string[];

  /**
   * Install flag
   *
   * @type {boolean}
   * @memberof ICommand
   */
  install?: boolean;
}
