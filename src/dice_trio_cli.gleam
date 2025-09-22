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
  // DetailedRollList(...)
}

pub fn main() {
  let args = argv.load().arguments
  let command = case list.length(args) {
    0 -> Help
    1 -> parse_arg(args)
    _ -> do_parse_args([], args)
  }
  let output = execute_command(command)
  io.println(output)
}

pub fn format_basic_roll(br: dice_trio.BasicRoll, roll_total: Int) -> String {
  case br.roll_count > 1, br.modifier != 0 {
    False, False ->
      side_count_to_str(br.side_count) <> roll_total_to_str(roll_total)
    True, False ->
      roll_count_to_str(br.roll_count)
      <> side_count_to_str(br.side_count)
      <> roll_total_to_str(roll_total)
    False, True ->
      side_count_to_str(br.side_count)
      <> modifier_to_str(br.modifier)
      <> roll_total_to_str(roll_total)
    True, True ->
      roll_count_to_str(br.roll_count)
      <> side_count_to_str(br.side_count)
      <> modifier_to_str(br.modifier)
      <> roll_total_to_str(roll_total)
  }
}

pub fn format_default_success(
  br: dice_trio.BasicRoll,
  roll_total: Int,
) -> String {
  "Process completed successfully! Operation executed: "
  <> format_dice_expression(br)
  <> " returned ["
  <> int.to_string(roll_total)
  <> "]"
}

fn format_dice_expression(br: dice_trio.BasicRoll) -> String {
  case br.roll_count > 1, br.modifier != 0 {
    False, False -> side_count_to_str(br.side_count)
    True, False ->
      roll_count_to_str(br.roll_count) <> side_count_to_str(br.side_count)
    False, True ->
      side_count_to_str(br.side_count) <> modifier_to_str(br.modifier)
    True, True ->
      roll_count_to_str(br.roll_count)
      <> side_count_to_str(br.side_count)
      <> modifier_to_str(br.modifier)
  }
}

fn roll_total_to_str(rt: Int) -> String {
  ": " <> int.to_string(rt)
}

fn modifier_to_str(mod: Int) -> String {
  case mod > 0 {
    True -> "+" <> int.to_string(mod)
    False -> int.to_string(mod)
  }
}

fn side_count_to_str(sc: Int) -> String {
  "d" <> int.to_string(sc)
}

fn roll_count_to_str(dc: Int) -> String {
  int.to_string(dc)
}

pub fn execute_command(c: Command) -> String {
  case c {
    BasicRoll(br) ->
      case br {
        Ok(core_br) -> {
          case dice_trio.roll("d6", fn(_) { 4 }) {
            Ok(total) -> format_default_success(core_br, total)
            Error(e) -> parse_error_msg(e)
          }
        }
        Error(e) -> parse_error_msg(e)
      }
    // BasicRollList(core_brl) -> todo as "list of basic rolls"
    DetailedRoll(core_dr) -> todo as "detailed parsed roll"
    // DetailedRollList(core_drl) -> todo as "list of detailed rolls"
    _ -> display_help()
  }
}

pub fn parse_error_msg(e: dice_trio.DiceError) -> String {
  case e {
    dice_trio.InvalidSides(bad_arg) ->
      "Process terminated! Die sides validation failed: '"
      <> bad_arg
      <> "' requires debugging - try 'd6' or '2d20+3'"

    dice_trio.InvalidCount(bad_arg) ->
      "Process terminated! Die count validation failed: '"
      <> bad_arg
      <> "' requires debugging - try 'd6' or '2d20+3'"
    dice_trio.MissingSeparator ->
      "Process terminated! Dice separator missing: gotta put that d all up in it - try 'd6' or '2d20+3'"
    _ ->
      "Process terminated! Malformed input detected: requires debugging - try 'd6' or '2d20+3'"
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
