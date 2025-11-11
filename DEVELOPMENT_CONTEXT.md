# dice_trio_cli - Development Context

## Project Overview
**Project Name**: `dice_trio_cli`
**Goal**: Build a minimal, Unix-philosophy command-line interface for the `dice_trio` core library

**Philosophy**: Do one thing well - roll dice and show results. Keep it simple, composable, and pipeable. Build on the bulletproof `dice_trio` foundation without unnecessary complexity.

**Development Approach**: Test-Driven Development (TDD) using Red-Green-Refactor cycle. Bottom-up approach - test pure functions first, then compose into larger integration tests.

**Parent Library Status**: `dice_trio` core is production-ready with 56 comprehensive tests, DetailedRoll functionality, and bulletproof parsing. Ready to build minimal CLI on this solid foundation.

## Current Status (Session 2025-10-02 - REFACTOR)

### Major Decision: Return to Unix Philosophy
**What Changed**: Scrapped complex feature creep in favor of minimal core

**OLD Approach (discarded)**:
- Corporate/gaming/pirate personality pools
- TOML configuration files
- Interactive REPL mode
- Bolt-on discovery system
- Multiple output modes

**NEW Approach (current)**:
- Simple default output: `expr: [result]`
- Composable with other tools via stdout
- Extensions via separate packages, not core complexity
- Core does ONE thing: roll dice, show results

### Working Implementation
**Tests (4 passing - 2 unit, 2 integration):**
- ✅ `format_single_roll(expression, total)` - pure formatter: `"d6: [4]"`
- ✅ `format_multiple_rolls(rolls)` - adds "1. ", "2. " numbering to list
- ✅ `roll_and_format("d6", fixed_rng)` - integration: roll + format with RNG
- ✅ `roll_and_format("garbage", rng)` - integration: error handling

**Current Public API:**
```gleam
pub fn format_single_roll(expression: String, total: Int) -> String
pub fn format_multiple_rolls(rolls: List(String)) -> String
pub fn roll_and_format(
  expression: String,
  rng_fn: fn(Int) -> Int
) -> Result(String, dice_trio.DiceError)
```

**Architecture Flow:**
```
args → parse expressions → roll + format → String → stdout
```

### Next Steps (In Order)
1. **Add `basic_roll_to_expression()` helper** (test publicly, then make private)
   - Convert `BasicRoll(2, 6, 3)` → `"2d6+3"`
   - Handle smart defaults (hide "1d", hide "+0")
   - Test edge cases: simple die, multiple dice, modifiers (positive/negative)
2. **Refactor to use parsing for consistent formatting**
   - Use `dice_trio.parse()` to get `BasicRoll`
   - Reconstruct expression with `basic_roll_to_expression()`
   - Ensures consistent output regardless of input format
3. **Add error formatting**
   - Convert `DiceError` variants to user-friendly messages
   - Map to stderr output
4. **Implement CLI arg parsing**
   - Handle no args (help/usage)
   - Single expression
   - Multiple expressions
5. **Full integration through main()**
   - End-to-end test with real RNG
   - Exit codes for errors

## Development Flow

**Environment**: Local development using zellij terminal multiplexer for session management

**Editor & Layout Setup**:
- **Editor**: Helix - precise, fast, and perfect for functional programming patterns
- **Multiplexer**: Zellij - modern terminal management with intuitive pane handling
- **Primary Layout**: Split pane setup with editor on left, Claude Code CLI on right for seamless collaboration
- **Secondary Tab**: Dedicated lazygit tab for clean repository management

**Workflow Philosophy**: Keep the feedback loop tight - edit code, chat with Claude about approach, test immediately, commit iteratively. TDD-first approach with red tests before any functionality implementation.

**Collaboration Rules**:
- Full transparency about Claude's contributions
- Claude serves as rubber duck debugger and strategic advisor, not code generator
- NO CODE IMPLEMENTATION unless explicitly requested
- NO GIT COMMANDS unless explicitly requested - thiccjay uses lazygit tab
- NO DEPENDENCY CHANGES unless explicitly requested
- TEST SAFETY: Auto-run test suite after code changes to verify no regressions

## Technical Approach

**Language**: Gleam (leveraging existing dice_trio library)
**Architecture**: Minimal CLI wrapper around dice_trio core
**Argument Parsing**: Pattern matching approach (Gleam idioms)
**Output Design**: Simple default format, extensible via libraries
**Error Handling**: User-friendly CLI error messages building on dice_trio's Result types

## CLI Design (Minimal Version)

### Usage Examples
```bash
# Help (no args)
dtc
# Output: Usage: dtc <EXPRESSION>
#         Example: dtc d6 | dtc 2d20+3

# Single expression
dtc d6
# Output: d6: [4]

# Multiple expressions
dtc d6 2d20+3 d8
# Output: 1. d6: [3]
#         2. 2d20+3: [15]
#         3. d8: [7]

# Error case
dtc invalid
# stderr: Invalid dice expression
# exit code: 1
```

### Output Format Rules
- **Single roll**: `expr: [result]`
- **Multiple rolls**: Numbered format `1. expr: [result]`
- **Errors**: Simple message to stderr, non-zero exit code
- **Pipeable**: Clean stdout for composing with other tools

## Extension Strategy (Future)

Core stays minimal. Advanced features via separate tools:

### 1. Formatter Libraries
```bash
dtc d6 | dtc-format-gaming    # "Critical Hit! You rolled [20]!"
dtc d6 | dtc-format-json      # {"expression":"d6","result":4}
```

### 2. Wrapper Tools
```bash
dtc-repl          # Interactive REPL that calls dtc internally
dtc-detailed 3d6  # Shows individual die values [3,5,2]
```

### 3. Public API for Composition
```gleam
// Export for other Gleam tools
pub type Formatter = fn(String, Int) -> String
pub fn default_format(expr: String, result: Int) -> String
pub fn execute_command(cmd: Command) -> String
```

## Parent Library Integration

**dice_trio Core Features Available:**
- `dice_trio.roll(expression, rng_fn) -> Result(Int, DiceError)` - Basic rolling
- `dice_trio.detailed_roll(expression, rng_fn) -> Result(DetailedRoll, DiceError)` - Individual die values
- `dice_trio.parse(expression) -> Result(BasicRoll, DiceError)` - Parse without rolling
- Full error handling with descriptive `DiceError` types
- Production-tested performance (handles `1000d6`, `100d100+50`)

**RNG Integration**: Use `prng` library (recommended by parent project) for CLI random number generation

**Usage Pattern:**
```gleam
import dice_trio
import prng/random

let rng = fn(max: Int) {
  let generator = random.int(1, max)
  random.random_sample(generator)
}

dice_trio.roll("d6", rng)           // Ok(4)
dice_trio.roll("2d6+3", rng)       // Ok(11)
```

## Technical Decisions Log

### Why Minimal Architecture?
**Problem**: Original design had feature creep that violated Unix philosophy
**Decision**: Strip to basics - core does ONE thing well
**Benefits**:
- Composable with other tools
- Fast and predictable
- Easy to maintain
- Extensions don't bloat core

### Why Pure Functions Over Command Type?
**Alternative**: Could use a Command ADT for arg parsing (Help | Roll | RollList)
**Decision**: Use direct pure functions - simplest thing that works
**Benefits**:
- Functions are immediately testable without wrapper types
- Composable - other tools can import and use directly
- Less indirection - clearer data flow
- Easy to add Command type later if complexity demands it

### Error Handling Strategy
**Decision**: Errors propagate up to CLI layer via Result types
**Pattern**: Functions return `Result(String, DiceError)`, main() unwraps and formats for stderr
**Benefits**:
- CLI owns presentation, dice_trio owns logic
- User-friendly messages at presentation layer
- Type-safe error handling throughout
- Easy to test error formatting separately

## Session Notes

### Session 1 (2025-09-15)
- Established CLI project context building on dice_trio foundation
- Created DEVELOPMENT_CONTEXT.md for work/home session continuity
- Confirmed parent library is production-ready with comprehensive test suite
- Project scaffolding in place

### Session 2 (2025-09-21)
- Implemented CLI argument parsing and Command architecture
- Designed GM-focused output formatting
- Created randomized error formatting system (later discarded in refactor)
- Established integration test structure

### Session 3 (2025-10-02 - REFACTOR)
- **Major decision**: Scrapped complex personality/bolt-on architecture
- **Rationale**: Feature creep violated Unix philosophy
- **New direction**: Minimal core, extensions via separate packages
- **Current status**: 2 passing tests for pure formatting functions
- **Architecture**: Simple pure functions - format_single_roll, format_multiple_rolls, roll_and_format
- **Collaboration note**: thiccjay returning to coding after 2 weeks of laptop setup work

### Session 4 (2025-11-11 - DOCUMENTATION SYNC)
- **Updated docs** to match actual implementation (removed references to Command type)
- **Next up**: Implement `basic_roll_to_expression()` helper with comprehensive edge case tests
- **Strategy**: Test publicly first, then make private once bulletproof

---

## ⚠️ IMPORTANT REMINDER FOR NEXT SESSION
**BEFORE NEXT COMMIT**: Perform full code and documentation review
- Current commit is location-change only (refactor docs, no implementation)
- Next commit should include working code + thorough review
- Verify all docs match implementation state
- Clean up any stale TODOs or outdated sections
- Ensure consistency across CLAUDE.md, DEVELOPMENT_CONTEXT.md, and code

---
*Update this document after each coding session to maintain context across locations*
