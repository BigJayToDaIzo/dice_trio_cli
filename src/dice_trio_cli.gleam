import gleam/int
import gleam/io
import gleam/list

import argv
import dice_trio

pub type Command {
  Help
  BasicRoll(Result(dice_trio.BasicRoll, dice_trio.DiceError))
  BasicRollList(List(Result(dice_trio.BasicRoll, dice_trio.DiceError)))
  DetailedRoll(Result(dice_trio.DetailedRoll, dice_trio.DiceError))
  DetailedRollList(List(Result(dice_trio.DetailedRoll, dice_trio.DiceError)))
}

pub fn main() {
  let args = argv.load().arguments
  let command = case list.length(args) {
    0 -> Help
    // 1 -> parse_arg(args)
    // _ -> do_parse_args([], args)
    _ -> todo
  }
  let output = execute_command(command)
  io.println(output)
}

pub fn execute_command(c: Command) -> String {
  case c {
    Help -> display_help()
    BasicRoll(res) ->
      case res {
        Ok(br) -> {
          todo as "handle success"
        }
        Error(e) -> todo as "handle error"
      }
    _ -> todo
  }
}

pub fn display_help() -> String {
  "Usage: dtc <EXPRESSION>\nExample: dtc d6 | dtc 2d20+3"
}

pub fn default_format(exp: String, roll_result: Int) -> String {
  exp <> ": [" <> int.to_string(roll_result) <> "]"
}
