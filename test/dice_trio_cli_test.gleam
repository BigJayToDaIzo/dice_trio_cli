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

pub fn should_format_single_die_roll_result_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 1, side_count: 6, modifier: 0)
  let rolled_value = 4
  let result = dice_trio_cli.format_basic_roll(basic_roll, rolled_value)

  assert result == "d6: 4"
}

pub fn should_format_multi_die_roll_without_modifier_basic_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 3, side_count: 6, modifier: 0)
  let total = 11
  let result = dice_trio_cli.format_basic_roll(basic_roll, total)

  assert result == "3d6: 11"
}

pub fn should_format_single_die_with_positive_modifier_basic_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 1, side_count: 6, modifier: 2)
  let total = 6
  let result = dice_trio_cli.format_basic_roll(basic_roll, total)

  assert result == "d6+2: 6"
}

pub fn should_format_single_die_with_negative_modifier_basic_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 1, side_count: 20, modifier: -1)
  let total = 15
  let result = dice_trio_cli.format_basic_roll(basic_roll, total)

  assert result == "d20-1: 15"
}

pub fn should_format_multi_die_with_positive_modifier_basic_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 2, side_count: 6, modifier: 3)
  let total = 11
  let result = dice_trio_cli.format_basic_roll(basic_roll, total)

  assert result == "2d6+3: 11"
}

pub fn should_format_multi_die_with_negative_modifier_basic_test() {
  let basic_roll =
    dice_trio.BasicRoll(roll_count: 3, side_count: 8, modifier: -2)
  let total = 14
  let result = dice_trio_cli.format_basic_roll(basic_roll, total)

  assert result == "3d8-2: 14"
}
