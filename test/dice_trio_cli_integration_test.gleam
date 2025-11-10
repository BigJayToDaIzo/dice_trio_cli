import dice_trio
import dice_trio_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn should_roll_and_format_single_expression_with_fixed_rng_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  dice_trio_cli.roll_and_format("d6", fixed_rng)
  |> should.equal(Ok("d6: [4]"))
}

pub fn should_return_error_for_invalid_dice_expression_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  dice_trio_cli.roll_and_format("garbage", fixed_rng)
  |> should.equal(Error(dice_trio.MissingSeparator))
}
