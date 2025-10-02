import dice_trio
import dice_trio_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn should_display_help_when_no_arguments_test() {
  dice_trio_cli.display_help()
  |> should.equal("Usage: dtc <EXPRESSION>\nExample: dtc d6 | dtc 2d20+3")
}

pub fn should_format_single_expression_with_result_test() {
  dice_trio_cli.default_format("d6", 4)
  |> should.equal("d6: [4]")
}

pub fn should_execute_single_roll_command_with_fixed_rng_test() {
  let parsed = dice_trio.parse("d6")
  let command = dice_trio_cli.BasicRoll(parsed)

  dice_trio_cli.execute_command(command)
  |> should.equal("d6: [4]")
}
