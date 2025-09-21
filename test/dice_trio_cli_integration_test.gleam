import dice_trio
import dice_trio_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Integration tests - full pipeline from Command to final string output
pub fn execute_help_command_full_pipeline_test() {
  dice_trio_cli.execute_command(dice_trio_cli.Help)
  |> should.equal("Usage: dtc d6 or dtc 2d20+3")
}

pub fn parse_and_execute_invalid_dice_expression_full_pipeline_test() {
  let args = ["d7x"]
  let command = dice_trio_cli.parse_arg(args)
  dice_trio_cli.execute_command(command)
  |> should.equal(
    "Process terminated! Die sides validation failed: '7x' requires debugging - try 'd6' or '2d20+3'",
  )
}

pub fn parse_and_execute_invalid_count_expression_full_pipeline_test() {
  let args = ["0d6"]
  let command = dice_trio_cli.parse_arg(args)
  dice_trio_cli.execute_command(command)
  |> should.equal(
    "Process terminated! Die count validation failed: '0' requires debugging - try 'd6' or '2d20+3'",
  )
}

pub fn parse_and_execute_missing_separator_expression_full_pipeline_test() {
  let args = ["garbage"]
  let command = dice_trio_cli.parse_arg(args)
  dice_trio_cli.execute_command(command)
  |> should.equal(
    "Process terminated! Dice separator missing: gotta put that d all up in it - try 'd6' or '2d20+3'",
  )
}

pub fn parse_and_execute_malformed_input_expression_full_pipeline_test() {
  let args = ["2d6++3"]
  let command = dice_trio_cli.parse_arg(args)
  dice_trio_cli.execute_command(command)
  |> should.equal(
    "Process terminated! Malformed input detected: requires debugging - try 'd6' or '2d20+3'",
  )
}
