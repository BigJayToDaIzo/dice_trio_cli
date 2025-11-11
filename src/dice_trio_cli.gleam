import gleam/int
import gleam/list
import gleam/result
import gleam/string

import dice_trio
import prng/random

pub type NormalizedExpr {
  NormalizedExpr(normalized_expression: String, roll: dice_trio.BasicRoll)
}

pub fn process_args(args: List(String)) -> Result(String, String) {
  let rng_fn = fn(max: Int) {
    let generator = random.int(1, max)
    random.random_sample(generator)
  }
  case list.length(args) {
    0 -> todo as "show usage help"
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
