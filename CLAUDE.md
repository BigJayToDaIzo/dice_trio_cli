# Claude Code Configuration & Development Notes

## Project Commands
```bash
# Test suite
gleam test

# Format code
gleam format

# Type check
gleam check

# Build
gleam build

# Run CLI locally
gleam run

# Run REPL for testing
gleam shell
```

## Development Workflow
- **TDD Approach**: Red-Green-Refactor cycle strictly enforced
- **CLI Focus**: Command-line interface for dice_trio library
- **Testing**: Use gleeunit for comprehensive test coverage
- **Integration**: Build on dice_trio core library functionality

## Code Style & Patterns
- Clarity over brevity - prioritize readable, self-documenting code
- Gleam functional programming idioms
- Pattern matching for CLI argument parsing
- Pure functions for core logic
- Clear error handling with Result types
- User-friendly CLI output and error messages

## Testing Philosophy
- Descriptive test names: 30-40+ characters for clarity, avoid approaching 80-column limit
- Test CLI argument parsing and output formatting
- Red-Green-Refactor cycle strictly enforced
- **NO CODE IMPLEMENTATION** until a red test has been written first - ALWAYS red test before any functionality
- Bottom-up TDD: Test pure functions first, then compose into integration tests

## Collaboration Guidelines
- **Rubber Duck Philosophy**: Serve as rubber duck debugger and strategic advisor, not code generator
- **NO CODE IMPLEMENTATION** unless explicitly requested
- **NO GIT COMMANDS** unless explicitly requested - thiccjay uses lazygit tab for all repo management
- **NO DEPENDENCY CHANGES** unless explicitly requested - no modifications to gleam.toml
- **TEST SAFETY**: After applying refactors/code changes when requested, automatically run test suite without asking permission to verify no regressions
- Provide ideas, strategies, and architectural guidance only
- Focus on planning, design patterns, and approach discussions
- Support independent problem-solving while maintaining full transparency about AI contributions

## Current Architecture - MINIMAL UNIX PHILOSOPHY

**Core Philosophy**: Do one thing well - roll dice and show results. Keep it simple, composable, and pipeable.

### Architecture Flow
```
args → parse expressions → roll + format → String → stdout
```

### Current Public API
```gleam
// Pure formatting functions (composable, testable)
pub fn format_single_roll(expression: String, total: Int) -> String
pub fn format_multiple_rolls(rolls: List(String)) -> String

// Integrated roll + format (convenience wrapper)
pub fn roll_and_format(
  expression: String,
  rng_fn: fn(Int) -> Int
) -> Result(String, dice_trio.DiceError)
```

### Output Format (Minimal Default)
```bash
# Single expression
dtc d6              # Output: d6: [4]

# Multiple expressions
dtc d6 2d20+3 d8    # Output:
                    # 1. d6: [3]
                    # 2. 2d20+3: [15]
                    # 3. d8: [7]

# Errors to stderr
dtc invalid         # stderr: Invalid dice expression
```

### Extension Strategy
Core stays minimal. Advanced features via:
1. **Formatter libraries**: `dice_trio_format_*` packages wrap output
2. **Wrapper tools**: `dtc-repl`, `dtc-detailed`, etc. compose core
3. **Public API**: Export pure functions for other tools to use

```gleam
// Extension point for libraries - current implementation
pub type Formatter = fn(String, Int) -> String

pub fn format_single_roll(expr: String, result: Int) -> String {
  expr <> ": [" <> int.to_string(result) <> "]"
}
```

## Session Tracking

### Current Status (Session 2025-11-11 - NORMALIZED EXPR & CLI IMPLEMENTATION)
**Major Refactor**: Implemented `NormalizedExpr` type to eliminate double-parsing and normalize expressions at the boundary

**Working Tests (21 passing):**
- ✅ All existing formatter and normalization tests
- ✅ `process_args()` single expression - full pipeline with real RNG (prng)
- ✅ `process_args()` multiple expressions - numbered output
- ✅ `process_args()` mixed valid/invalid - inline error handling

**Current Implementation:**
```gleam
pub type NormalizedExpr {
  NormalizedExpr(normalized_expression: String, roll: dice_trio.BasicRoll)
}

pub fn normalize(expression: String) -> Result(NormalizedExpr, dice_trio.DiceError)
pub fn roll(expr: NormalizedExpr, rng_fn: fn(Int) -> Int) -> Int
pub fn format_roll(expr: NormalizedExpr, total: Int) -> String
pub fn process_args(args: List(String)) -> Result(String, String)
```

**Key Architecture Wins:**
- ✅ Parse once at boundary, use structured data everywhere (no double-parse!)
- ✅ Real RNG using `prng` library (Gleam-native)
- ✅ Normalized expressions: "1d6+0" → "d6"
- ✅ Inline error handling: mixed valid/invalid expressions show both results and errors
- ✅ Position-based numbering: errors and rolls numbered by argument position

**Dependencies:**
- `dice_trio` - Core dice rolling library
- `prng` - Gleam-native RNG (removed glint, staying minimal)

### Next Steps (In Order)
1. **Implement `main()` entry point** - Wire `process_args()` to CLI argv
2. **Handle empty args** - Show usage/help message
3. **Test end-to-end** - Manual CLI testing with `gleam run`
4. **Consider `--detailed` flag** - Use `dice_trio.detailed_roll()` for individual die values (future enhancement)

### ⚠️ IMPORTANT REMINDER
**BEFORE NEXT COMMIT**: Perform full code and documentation review
- Current commit is location-change only (refactor docs, no implementation)
- Next commit should include working code + thorough review
- Verify all docs match implementation state
- Clean up any stale TODOs or outdated sections

### Quick Links
- Main module: `src/dice_trio_cli.gleam`
- Tests: `test/dice_trio_cli_test.gleam`
- Parent library: `../dice_trio/`

## Technical Decisions Log

### Why Minimal Architecture?
**Problem**: Original design had feature creep
- Corporate/gaming/pirate personality pools
- TOML configuration files
- Interactive REPL mode
- Bolt-on discovery system
- Multiple output modes

**Decision**: Strip to Unix philosophy basics
- Simple default output: `expr: [result]`
- Composable with other tools via stdout
- Extensions via separate packages, not core complexity
- Core does ONE thing: roll dice, show results

### Why Pure Functions Over Command Type?
**Alternative**: Could use Command ADT for arg parsing
**Decision**: Use pure functions - simplest thing that works
- Functions are immediately testable
- Composable by other tools
- Less indirection, clearer flow
- Can add Command type later if needed

### Error Handling Strategy
**Decision**: Errors propagate up to CLI layer via Result types
- Functions return `Result(String, DiceError)`
- main() unwraps and formats for stderr
- CLI owns presentation, dice_trio owns logic
- User-friendly messages at presentation layer

---
*This file tracks Claude-specific development context and command shortcuts*
