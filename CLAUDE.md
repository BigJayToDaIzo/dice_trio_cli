# Claude Code Configuration & Development Notes

## Required Reading
**ALWAYS read DEVELOPMENT_CONTEXT.md at the start of each session** - Contains comprehensive session history, current implementation status, and project context.

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
// Core types
pub type NormalizedExpr {
  NormalizedExpr(normalized_expression: String, roll: dice_trio.BasicRoll)
}

// Flag parsing
pub fn parse_flags(args: List(String)) -> #(Bool, List(String))

// Expression normalization and rolling
pub fn normalize(expression: String) -> Result(NormalizedExpr, dice_trio.DiceError)
pub fn roll(expr: NormalizedExpr, rng_fn: fn(Int) -> Int) -> Int

// Formatting
pub fn format_roll(expr: NormalizedExpr, total: Int) -> String
pub fn format_detailed_roll(expr: NormalizedExpr, rolls: List(Int), modifier: Int) -> String
pub fn format_multiple_rolls(rolls: List(String)) -> String
pub fn format_error(e: dice_trio.DiceError) -> String

// CLI processing
pub fn process_args(args: List(String), detailed: Bool) -> Result(String, String)
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

### Current Status (Session 2025-11-14 - DETAILED FLAG COMPLETE ✅)
**Feature Complete**: `-d`/`--detailed` flag fully implemented with comprehensive test coverage

**Working Tests (45 passing):**
- ✅ All formatter tests (simple and detailed)
- ✅ `parse_flags()` - 6 tests for flag extraction
- ✅ `format_detailed_roll()` - 5 tests for detailed output format
- ✅ `process_expressions()` - Unit tests for both simple and detailed modes
- ✅ `process_args()` - Integration tests for both modes
- ✅ Edge case handling (empty strings, whitespace, mixed valid/invalid)
- ✅ Deterministic testing with RNG injection

**Current Implementation:**
```gleam
pub type NormalizedExpr {
  NormalizedExpr(normalized_expression: String, roll: dice_trio.BasicRoll)
}

pub fn parse_flags(args: List(String)) -> #(Bool, List(String))
pub fn normalize(expression: String) -> Result(NormalizedExpr, dice_trio.DiceError)
pub fn roll(expr: NormalizedExpr, rng_fn: fn(Int) -> Int) -> Int
pub fn format_roll(expr: NormalizedExpr, total: Int) -> String
pub fn format_detailed_roll(expr: NormalizedExpr, rolls: List(Int)) -> String
pub fn format_multiple_rolls(rolls: List(String)) -> String
pub fn format_error(e: dice_trio.DiceError) -> String
pub fn process_expressions(args: List(String), detailed: Bool, rng_fn: fn(Int) -> Int) -> List(String)
pub fn process_args(args: List(String), detailed: Bool, rng_fn: fn(Int) -> Int) -> Result(String, String)
pub fn main()
```

**Key Architecture Wins:**
- ✅ Clean separation of concerns - `process_expressions()` for processing, `process_args()` for presentation
- ✅ Deterministic testing via RNG injection
- ✅ Parse once at boundary, use structured data everywhere
- ✅ Real RNG using `prng` library (Gleam-native)
- ✅ Flag parsing separated from expression processing
- ✅ Detailed format: `3d6: [4 + 2 + 5] = 11` with modifier support
- ✅ `main()` wired to argv, errors go to stderr

**Dependencies:**
- `dice_trio` - Core dice rolling library
- `prng` - Gleam-native RNG
- `argv` - Cross-platform argument parsing

### To Be Determined
1. **Help/Usage Message** - Current help doesn't mention `-d`/`--detailed` flag
   - Options: Update basic help, add `--help` flag, or hybrid approach
   - Decision pending next session

### Refactor Opportunities (Optional)
1. Magic strings - "Error: " prefix and `7` for error detection
2. Type safety - `process_expressions()` returns `List(String)` mixing results/errors
3. Dead comment at line 112 in `format_detailed_roll()`

### Next Steps (In Order)
1. **Decide on help message approach** - How to surface flag documentation
2. **Add hexdocs** - Module and function documentation
3. **Consider refactors** - If time/interest permit

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
