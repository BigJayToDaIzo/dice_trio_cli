import dice_trio_cli
import gleam/string
import gleeunit

import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// parse_flags() tests
pub fn should_extract_short_flag_before_expression_test() {
  dice_trio_cli.parse_flags(["-d", "d6"])
  |> should.equal(#(True, ["d6"]))
}

pub fn should_extract_long_flag_after_expression_test() {
  dice_trio_cli.parse_flags(["d6", "--detailed"])
  |> should.equal(#(True, ["d6"]))
}

pub fn should_return_false_when_no_flags_present_test() {
  dice_trio_cli.parse_flags(["d6", "2d20"])
  |> should.equal(#(False, ["d6", "2d20"]))
}

pub fn should_extract_multiple_flags_from_multiple_expressions_test() {
  dice_trio_cli.parse_flags(["-d", "d6", "2d20", "--detailed"])
  |> should.equal(#(True, ["d6", "2d20"]))
}

pub fn should_handle_empty_args_list_test() {
  dice_trio_cli.parse_flags([])
  |> should.equal(#(False, []))
}

pub fn should_extract_flags_from_middle_of_args_test() {
  dice_trio_cli.parse_flags(["d6", "-d", "2d20"])
  |> should.equal(#(True, ["d6", "2d20"]))
}

pub fn should_format_single_roll_expression_with_result_test() {
  let assert Ok(norm_expr) = dice_trio_cli.normalize("d6")
  dice_trio_cli.format_roll(norm_expr, 4)
  |> should.equal("d6: [4]")
}

pub fn should_format_multiple_rolls_with_numbering_test() {
  let formatted_rolls = ["d6: [4]", "d20: [15]", "d8: [7]"]

  dice_trio_cli.format_multiple_rolls(formatted_rolls)
  |> should.equal("1. d6: [4]\n2. d20: [15]\n3. d8: [7]")
}

// Detailed roll formatting tests
pub fn should_format_detailed_single_die_no_modifier_test() {
  // d6 rolling [4]
  let assert Ok(norm_expr) = dice_trio_cli.normalize("d6")
  dice_trio_cli.format_detailed_roll(norm_expr, [4], 0)
  |> should.equal("d6: [4] = 4")
}

pub fn should_format_detailed_multiple_dice_no_modifier_test() {
  // 3d6 rolling [4, 2, 5]
  let assert Ok(norm_expr) = dice_trio_cli.normalize("3d6")
  dice_trio_cli.format_detailed_roll(norm_expr, [4, 2, 5], 0)
  |> should.equal("3d6: [4 + 2 + 5] = 11")
}

pub fn should_format_detailed_multiple_dice_with_positive_modifier_test() {
  // 2d20+3 rolling [7, 18]
  let assert Ok(norm_expr) = dice_trio_cli.normalize("2d20+3")
  dice_trio_cli.format_detailed_roll(norm_expr, [7, 18], 3)
  |> should.equal("2d20+3: [7 + 18] +3 = 28")
}

pub fn should_format_detailed_multiple_dice_with_negative_modifier_test() {
  // 2d20-1 rolling [7, 18]
  let assert Ok(norm_expr) = dice_trio_cli.normalize("2d20-1")
  dice_trio_cli.format_detailed_roll(norm_expr, [7, 18], -1)
  |> should.equal("2d20-1: [7 + 18] -1 = 24")
}

pub fn should_format_detailed_single_die_with_positive_modifier_test() {
  // d6+2 rolling [4]
  let assert Ok(norm_expr) = dice_trio_cli.normalize("d6+2")
  dice_trio_cli.format_detailed_roll(norm_expr, [4], 2)
  |> should.equal("d6+2: [4] +2 = 6")
}

pub fn should_return_usage_message_when_no_args_provided_test() {
  dice_trio_cli.process_args([], False)
  |> should.equal(Error(
    "Usage: dtc <expression>\nExample: dtc d6 | dtc d6+2 3d6",
  ))
}

pub fn should_handle_empty_string_as_single_argument_test() {
  let result = dice_trio_cli.process_args([""], False)
  result
  |> should.be_error()

  // Verify it returns a descriptive error message
  let assert Error(msg) = result
  msg
  |> should.equal(
    "Invalid expression. Missing the 'd'. Use format: d6, 2d20, 3d6+5",
  )
}

pub fn should_handle_whitespace_only_string_as_argument_test() {
  let result = dice_trio_cli.process_args(["  "], False)
  result
  |> should.be_error()

  let assert Error(msg) = result
  msg
  |> should.equal(
    "Invalid expression. Missing the 'd'. Use format: d6, 2d20, 3d6+5",
  )
}

pub fn should_handle_all_invalid_expressions_test() {
  let result = dice_trio_cli.process_args(["garbage", "invalid", "bad"], False)
  result
  |> should.be_ok()

  // All three should produce numbered error messages
  let assert Ok(output) = result
  string.contains(output, "1. Error:")
  |> should.be_true()
  string.contains(output, "2. Error:")
  |> should.be_true()
  string.contains(output, "3. Error:")
  |> should.be_true()
}

pub fn should_handle_empty_string_mixed_with_valid_expression_test() {
  let result = dice_trio_cli.process_args(["", "d6", ""], False)
  result
  |> should.be_ok()

  // Should have errors at positions 1 and 3, result at position 2
  let assert Ok(output) = result
  string.contains(output, "1. Error:")
  |> should.be_true()
  string.contains(output, "2. d6: [")
  |> should.be_true()
  string.contains(output, "3. Error:")
  |> should.be_true()
}

pub fn should_handle_whitespace_mixed_with_valid_expressions_test() {
  let result = dice_trio_cli.process_args(["  ", "d6", "  "], False)
  result
  |> should.be_ok()

  let assert Ok(output) = result
  string.contains(output, "1. Error:")
  |> should.be_true()
  string.contains(output, "2. d6: [")
  |> should.be_true()
  string.contains(output, "3. Error:")
  |> should.be_true()
}
