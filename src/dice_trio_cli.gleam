import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import argv
import dice_trio
import prng/random

pub type NormalizedExpr {
  NormalizedExpr(normalized_expression: String, roll: dice_trio.BasicRoll)
}

pub fn main() {
  let #(detailed, expressions) = parse_flags(argv.load().arguments)
  case process_args(expressions, detailed) {
    Ok(res) -> io.println(res)
    Error(e) -> io.println_error(e)
  }
}

pub fn parse_flags(args: List(String)) -> #(Bool, List(String)) {
  let flags = ["-d", "--detailed"]
  let contains_flag =
    list.contains(args, "-d") || list.contains(args, "--detailed")
  case contains_flag {
    True -> {
      #(True, list.filter(args, fn(flag) { !list.contains(flags, flag) }))
    }
    False -> #(False, args)
  }
}

pub fn rng_fn(max: Int) {
  let generator = random.int(1, max)
  random.random_sample(generator)
}

pub fn process_args(
  args: List(String),
  detailed: Bool,
) -> Result(String, String) {
  case list.length(args) {
    0 -> show_help()
    1 -> {
      // safe since we've already confirmed there's one item in the list
      let assert Ok(first) = list.first(args)
      normalize(first)
      |> result.map_error(format_error)
      |> result.try(fn(normalized) {
        let total = roll(normalized, rng_fn)
        Ok(format_roll(normalized, total))
      })
    }
    _ -> {
      let outputs =
        args
        |> list.index_map(fn(expr, index) {
          case normalize(expr) |> result.map_error(format_error) {
            Ok(normalized) -> {
              let total = roll(normalized, rng_fn)
              let formatted = format_roll(normalized, total)
              int.to_string(index + 1) <> ". " <> formatted
            }
            Error(msg) -> int.to_string(index + 1) <> ". Error: " <> msg
          }
        })
      string.join(outputs, "\n")
      |> Ok
    }
  }
}

fn show_help() -> Result(_, String) {
  Error("Usage: dtc <expression>\nExample: dtc d6 | dtc d6+2 3d6")
}

pub fn normalize(
  expression: String,
) -> Result(NormalizedExpr, dice_trio.DiceError) {
  use roll <- result.try(dice_trio.parse(expression))
  let normalized_expression = basic_roll_to_expression(roll)
  Ok(NormalizedExpr(normalized_expression:, roll:))
}

pub fn roll(expr: NormalizedExpr, rng_fn: fn(Int) -> Int) -> Int {
  let dice_trio.BasicRoll(count, sides, modifier) = expr.roll
  list.range(1, count)
  |> list.fold(0, fn(acc, _) { acc + rng_fn(sides) })
  |> int.add(modifier)
}

pub fn format_roll(expr: NormalizedExpr, total: Int) -> String {
  expr.normalized_expression <> ": [" <> int.to_string(total) <> "]"
}

pub fn format_detailed_roll(
  expr: NormalizedExpr,
  rolls: List(Int),
  modifier: Int,
) -> String {
  let preamble = expr.normalized_expression <> ": ["
  // how do we not tack on a " +" to the last item in the list?
  let rolls_sum = int.sum(rolls)
  let details =
    rolls
    |> list.map(int.to_string)
    |> string.join(" + ")
  let mod = case expr.roll.modifier {
    0 -> ""
    m if m > 0 -> " +" <> int.to_string(m)
    _ -> " " <> int.to_string(modifier)
  }
  preamble
  <> details
  <> "]"
  <> mod
  <> " = "
  <> int.to_string(rolls_sum + expr.roll.modifier)
}

pub fn format_multiple_rolls(rolls: List(String)) -> String {
  rolls
  |> list.index_map(fn(roll, index) { int.to_string(index + 1) <> ". " <> roll })
  |> string.join("\n")
}

// was made public to run a battery of unit tests, once edge cases were tested
// we made it private and deleted the tests
fn basic_roll_to_expression(basic_roll: dice_trio.BasicRoll) -> String {
  let dice_trio.BasicRoll(count, sides, modifier) = basic_roll
  let count_exp = case count {
    1 -> ""
    _ -> int.to_string(count)
  }
  let count_and_sides = count_exp <> "d" <> int.to_string(sides)
  case modifier {
    m if m == 0 -> count_and_sides
    m if m > 0 -> count_and_sides <> "+" <> int.to_string(modifier)
    _ -> count_and_sides <> int.to_string(modifier)
  }
}

pub fn format_error(e: dice_trio.DiceError) -> String {
  case e {
    dice_trio.MissingSeparator ->
      "Invalid expression. Missing the 'd'. Use format: d6, 2d20, 3d6+5"
    dice_trio.InvalidCount(c) -> "Invalid dice count: '" <> c <> "'"
    dice_trio.InvalidSides(s) -> "Invalid die sides: '" <> s <> "'"
    dice_trio.InvalidModifier(m) -> "Invalid modifier: '" <> m <> "'"
    dice_trio.MalformedInput -> "Malformed dice expression"
  }
}
