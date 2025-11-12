// Integration tests for main() CLI entry point
import dice_trio_cli
import gleam/int
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Test: CLI should handle single basic roll expression
pub fn should_handle_single_basic_roll_expression_test() {
  // Simulate: dtc d6
  let args = ["d6"]
  let output = dice_trio_cli.process_args(args, False)

  // Output should be formatted roll result like "d6: [4]"
  let assert Ok(result) = output

  // Verify format: starts with "d6: [" and ends with "]"
  string.starts_with(result, "d6: [") |> should.be_true
  string.ends_with(result, "]") |> should.be_true

  // Verify that rolled number is between 1 and 6 (valid d6 result)
  // Extract number from "d6: [4]"
  let assert Ok(after_bracket) =
    result
    |> string.split("[")
    |> list.last
  let assert Ok(number_str) =
    after_bracket
    |> string.split("]")
    |> list.first
  let assert Ok(number_part) = int.parse(number_str)
  should.be_true(number_part >= 1)
  should.be_true(number_part <= 6)
}

// Test: CLI should handle multiple roll expressions
pub fn should_handle_multiple_roll_expressions_test() {
  // Simulate: dtc d6 2d20+3 d8
  let args = ["d6", "2d20+3", "d8"]
  let output = dice_trio_cli.process_args(args, False)

  // Output should be numbered list format
  let assert Ok(result) = output

  // Verify numbered format
  string.contains(result, "1. d6: [") |> should.be_true
  string.contains(result, "2. 2d20+3: [") |> should.be_true
  string.contains(result, "3. d8: [") |> should.be_true

  // Verify newlines separate results
  string.contains(result, "\n") |> should.be_true
}

// Test: CLI should handle mix of valid and invalid expressions
pub fn should_handle_mixed_valid_and_invalid_expressions_test() {
  // Simulate: dtc d6 garbage 2d20+3
  let args = ["d6", "garbage", "2d20+3"]
  let output = dice_trio_cli.process_args(args, False)

  // Should still return Ok (processed all args)
  let assert Ok(result) = output

  // Should contain valid rolls (numbered by position, not by valid count)
  string.contains(result, "1. d6: [") |> should.be_true
  string.contains(result, "3. 2d20+3: [") |> should.be_true  // Position 3 (index 2)

  // Should contain error message for "garbage"
  string.contains(result, "Invalid expression") |> should.be_true
  string.contains(result, "Missing the 'd'") |> should.be_true
}
