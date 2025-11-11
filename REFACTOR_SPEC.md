# NormalizedRoll Refactor Specification

## Overview
Refactor to normalize expressions at the boundary, then use structured data throughout the pipeline.

## New API Design

### Type Definition
```gleam
pub type NormalizedRoll {
  NormalizedRoll(data: dice_trio.BasicRoll, expression: String)
}
```

### Public Functions to Implement

#### 1. `normalize(expression: String) -> Result(NormalizedRoll, dice_trio.DiceError)`
**Purpose:** Parse and normalize expression at entry point

**Implementation:**
- Call `dice_trio.parse(expression)` to get `BasicRoll`
- Call `basic_roll_to_expression(basic_roll)` to get normalized string
- Return `NormalizedRoll(data: basic_roll, expression: normalized_expr)`

**Test coverage:**
- `should_normalize_simple_expression_test` - "d6" → "d6"
- `should_normalize_removing_redundant_count_test` - "1d6" → "d6"
- `should_normalize_removing_zero_modifier_test` - "d6+0" → "d6"
- `should_normalize_combined_redundancy_test` - "1d20+0" → "d20"
- `should_preserve_significant_parts_test` - "2d20+3" → "2d20+3"
- `should_return_error_for_invalid_expression_test` - "garbage" → Error

---

#### 2. `roll(normalized: NormalizedRoll, rng_fn: fn(Int) -> Int) -> Int`
**Purpose:** Execute dice roll from normalized data

**Implementation:**
- Destructure `normalized.data` to get `BasicRoll(count, sides, modifier)`
- Roll `count` dice, each 1-to-`sides` using `rng_fn`
- Sum all rolls and add `modifier`
- Return total

**Helper function (private):**
```gleam
fn execute_roll(basic_roll: dice_trio.BasicRoll, rng_fn: fn(Int) -> Int) -> Int {
  let dice_trio.BasicRoll(count, sides, modifier) = basic_roll
  list.range(1, count)
  |> list.fold(0, fn(acc, _) { acc + rng_fn(sides) })
  |> int.add(modifier)
}
```

**Test coverage:**
- `should_roll_normalized_expression_with_fixed_rng_test` - d6 with rng(4) → 4
- `should_roll_multiple_dice_test` - 3d6 with rng(4) → 12
- `should_apply_positive_modifier_test` - d6+3 with rng(4) → 7
- `should_apply_negative_modifier_test` - d20-1 with rng(4) → 3

---

#### 3. `format_roll(normalized: NormalizedRoll, total: Int) -> String`
**Purpose:** Format normalized roll result for display

**Implementation:**
- Use `normalized.expression` (already normalized!)
- Call existing `format_single_roll(normalized.expression, total)`
- Return formatted string

**Test coverage:**
- `should_format_normalized_roll_with_result_test` - NormalizedRoll("d6", ...) with 4 → "d6: [4]"
- `should_normalize_roll_and_format_together_test` - Full pipeline test

---

### Functions to Keep (Unchanged)

#### `format_multiple_rolls(rolls: List(String)) -> String`
No changes needed - already works with formatted strings

#### `format_error(e: dice_trio.DiceError) -> String`
No changes needed - error formatting stays the same

---

### Private Functions

#### `basic_roll_to_expression(basic_roll: dice_trio.BasicRoll) -> String`
Keep as-is (already implemented and private)

---

## Migration Path

### Old API (remove these):
- ❌ `roll_and_format(expression: String, rng_fn) -> Result(String, DiceError)`
- ❌ `format_single_roll(expression: String, total: Int) -> String` *(make private, used internally)*

### New API (implement these):
- ✅ `normalize(expression: String) -> Result(NormalizedRoll, DiceError)`
- ✅ `roll(normalized: NormalizedRoll, rng_fn) -> Int`
- ✅ `format_roll(normalized: NormalizedRoll, total: Int) -> String`

---

## Implementation Order

1. **Add `NormalizedRoll` type** to `src/dice_trio_cli.gleam`
2. **Implement `normalize()`** - Use existing `parse()` + `basic_roll_to_expression()`
3. **Implement `roll()`** - Extract rolling logic (no re-parsing!)
4. **Implement `format_roll()`** - Use normalized expression
5. **Make `format_single_roll()` private** - Only used by `format_roll()` now
6. **Remove old `roll_and_format()`** - No longer needed

---

## Benefits After Refactor

✅ **Single parse** - Parse once at boundary, never again
✅ **No double-parse bug** - Roll works with structured data
✅ **Normalized everywhere** - Clean "d6" not ugly "1d6+0"
✅ **Type-safe** - `NormalizedRoll` carries both data and string
✅ **Composable** - Functions have clear single responsibilities
✅ **Testable** - Each function tested in isolation

---

## Test Status

**Before refactor:** 12 tests passing
**After refactor:** Will have ~15 tests (added normalization + roll execution tests)

Run `gleam test` to see current RED state - all tests expect new API!
