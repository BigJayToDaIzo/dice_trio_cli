import argv
import dice_trio
import gleam/io
import gleam/list

pub type Command {
  Help
  BasicRoll(Result(dice_trio.BasicRoll, dice_trio.DiceError))
  BasicRollList(List(Result(dice_trio.BasicRoll, dice_trio.DiceError)))
  // DetailedRoll(...)
  // DetailedRollList(...)
}

pub fn main() {
  let args = argv.load().arguments
  let command = case list.length(args) {
    0 -> Help
    1 -> parse_arg(args)
    _ -> do_parse_args([], args)
  }
  execute_command(command)
}

pub fn execute_command(c: Command) {
  case c {
    Help -> io.println(display_help())
    _ -> todo as "rest of the commands"
  }
}

pub fn parse_arg(arg: List(String)) -> Command {
  // we know this list only has a single arg
  // so we can let assert knowing main won't pass any other sized array
  let assert Ok(arg) = list.first(arg)
  BasicRoll(dice_trio.parse(arg))
}

pub fn do_parse_args(
  acc: List(Result(dice_trio.BasicRoll, dice_trio.DiceError)),
  args: List(String),
) -> Command {
  case args {
    [] -> BasicRollList(acc)
    [arg, ..rest] -> do_parse_args([dice_trio.parse(arg), ..acc], rest)
  }
}

pub fn display_help() -> String {
  "Usage: dtc d6 or dtc 2d20+3"
}
