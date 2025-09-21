import dice_trio
import dice_trio_cli
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn should_parse_single_die_expression_from_command_line_arguments_test() {
  let args = ["d6"]
  let result = dice_trio_cli.parse_arg(args)

  assert result
    == dice_trio_cli.BasicRoll(
      Ok(dice_trio.BasicRoll(roll_count: 1, side_count: 6, modifier: 0)),
    )
}

pub fn should_parse_multiple_dice_expressions_from_command_line_arguments_test() {
  let args = ["d6", "2d8+1", "d20"]
  let result = dice_trio_cli.do_parse_args([], args)

  assert result
    == dice_trio_cli.BasicRollList([
      Ok(dice_trio.BasicRoll(roll_count: 1, side_count: 20, modifier: 0)),
      Ok(dice_trio.BasicRoll(roll_count: 2, side_count: 8, modifier: 1)),
      Ok(dice_trio.BasicRoll(roll_count: 1, side_count: 6, modifier: 0)),
    ])
}

pub fn should_generate_correct_help_text_test() {
  let result = dice_trio_cli.display_help()
  assert result == "Usage: dtc d6 or dtc 2d20+3"
}
