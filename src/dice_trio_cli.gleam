import gleam/int
import gleam/list
import gleam/string

import dice_trio

pub fn format_single_roll(expression: String, total: Int) -> String {
  expression <> ": [" <> int.to_string(total) <> "]"
}

pub fn roll_and_format(
  expression: String,
  rng_fn: fn(Int) -> Int,
) -> Result(String, dice_trio.DiceError) {
  case dice_trio.roll(expression, rng_fn) {
    Ok(result) -> Ok(format_single_roll(expression, result))
    Error(e) -> Error(e)
  }
}

pub fn format_multiple_rolls(rolls: List(String)) -> String {
  rolls
  |> list.index_map(fn(roll, index) { int.to_string(index + 1) <> ". " <> roll })
  |> string.join("\n")
}
