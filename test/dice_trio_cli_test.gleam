import dice_trio_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn should_format_single_roll_expression_with_result_test() {
  dice_trio_cli.format_single_roll("d6", 4)
  |> should.equal("d6: [4]")
}

pub fn should_format_multiple_rolls_with_numbering_test() {
  let formatted_rolls = ["d6: [4]", "d20: [15]", "d8: [7]"]

  dice_trio_cli.format_multiple_rolls(formatted_rolls)
  |> should.equal("1. d6: [4]\n2. d20: [15]\n3. d8: [7]")
}
