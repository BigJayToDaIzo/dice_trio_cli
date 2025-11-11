import dice_trio
import dice_trio_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Normalization tests
pub fn should_normalize_simple_expression_test() {
  dice_trio_cli.normalize("1d6")
  |> should.be_ok
  |> fn(normalized) {
    normalized.normalized_expression
    |> should.equal("d6")
  }
}

pub fn should_normalize_removing_redundant_count_test() {
  // "1d6" should normalize to "d6"
  dice_trio_cli.normalize("1d6")
  |> should.be_ok
  |> fn(normalized) {
    normalized.normalized_expression
    |> should.equal("d6")
  }
}

pub fn should_normalize_removing_zero_modifier_test() {
  // "d6+0" should normalize to "d6"
  dice_trio_cli.normalize("d6+0")
  |> should.be_ok
  |> fn(normalized) {
    normalized.normalized_expression
    |> should.equal("d6")
  }
}

pub fn should_normalize_combined_redundancy_test() {
  // "1d20+0" should normalize to "d20"
  dice_trio_cli.normalize("1d20+0")
  |> should.be_ok
  |> fn(normalized) {
    normalized.normalized_expression
    |> should.equal("d20")
  }
}

pub fn should_preserve_significant_parts_test() {
  // "2d20+3" should stay "2d20+3"
  dice_trio_cli.normalize("2d20+3")
  |> should.be_ok
  |> fn(normalized) {
    normalized.normalized_expression
    |> should.equal("2d20+3")
  }
}

pub fn should_return_error_for_invalid_expression_test() {
  dice_trio_cli.normalize("garbage")
  |> should.equal(Error(dice_trio.MissingSeparator))
}

// Roll execution tests
pub fn should_roll_normalized_expression_with_fixed_rng_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  let assert Ok(normalized) = dice_trio_cli.normalize("d6")

  dice_trio_cli.roll(normalized, fixed_rng)
  |> should.equal(4)
}

pub fn should_roll_multiple_dice_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  let assert Ok(normalized) = dice_trio_cli.normalize("3d6")

  // 3 dice, each rolling 4 = 12
  dice_trio_cli.roll(normalized, fixed_rng)
  |> should.equal(12)
}

pub fn should_apply_positive_modifier_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  let assert Ok(normalized) = dice_trio_cli.normalize("d6+3")

  // 1 die rolls 4, plus 3 = 7
  dice_trio_cli.roll(normalized, fixed_rng)
  |> should.equal(7)
}

pub fn should_apply_negative_modifier_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  let assert Ok(normalized) = dice_trio_cli.normalize("d20-1")

  // 1 die rolls 4, minus 1 = 3
  dice_trio_cli.roll(normalized, fixed_rng)
  |> should.equal(3)
}

// Full pipeline tests
pub fn should_normalize_roll_and_format_together_test() {
  let fixed_rng = fn(_max: Int) { 4 }

  let assert Ok(normalized) = dice_trio_cli.normalize("1d6+0")
  let total = dice_trio_cli.roll(normalized, fixed_rng)
  let output = dice_trio_cli.format_roll(normalized, total)

  // Normalized "1d6+0" → "d6", rolled 4
  output
  |> should.equal("d6: [4]")
}

// Error Formatting Tests
pub fn should_format_missing_separator_error_test() {
  dice_trio_cli.format_error(dice_trio.MissingSeparator)
  |> should.equal(
    "Invalid expression. Missing the 'd'. Use format: d6, 2d20, 3d6+5",
  )
}

pub fn should_format_invalid_count_error_test() {
  dice_trio_cli.format_error(dice_trio.InvalidCount("0"))
  |> should.equal("Invalid dice count: '0'")
}

pub fn should_format_invalid_sides_error_test() {
  dice_trio_cli.format_error(dice_trio.InvalidSides("-6"))
  |> should.equal("Invalid die sides: '-6'")
}

pub fn should_format_invalid_modifier_error_test() {
  dice_trio_cli.format_error(dice_trio.InvalidModifier("abc"))
  |> should.equal("Invalid modifier: 'abc'")
}

pub fn should_format_malformed_input_error_test() {
  dice_trio_cli.format_error(dice_trio.MalformedInput)
  |> should.equal("Malformed dice expression")
}
