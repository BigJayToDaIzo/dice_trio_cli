# dice_trio_cli - Development Context

## Project Overview
**Project Name**: `dice_trio_cli`
**Goal**: Build a minimal, Unix-philosophy command-line interface for the `dice_trio` core library

**Philosophy**: Do one thing well - roll dice and show results. Keep it simple, composable, and pipeable. Build on the bulletproof `dice_trio` foundation without unnecessary complexity.

**Development Approach**: Test-Driven Development (TDD) using Red-Green-Refactor cycle. Bottom-up approach - test pure functions first, then compose into larger integration tests.

**Parent Library Status**: `dice_trio` core is production-ready with 56 comprehensive tests, DetailedRoll functionality, and bulletproof parsing. Ready to build minimal CLI on this solid foundation.

## Current Status (Session 2025-11-14 - DETAILED FLAG COMPLETE)

### Feature Complete: Detailed Flag Implementation
**Major Progress**: Implemented `-d`/`--detailed` flag with full test coverage

**What Changed This Session:**
- Implemented detailed roll format: `3d6: [4 + 2 + 5] = 11`
- Refactored `process_args()` for maintainability and separation of concerns
- Extracted `process_expressions()` helper to eliminate duplication
- Fixed RNG injection for deterministic testing
- Added comprehensive test coverage (45 tests passing)

**Working Implementation:**
**Tests (45 passing - unit, integration, and CLI tests):**
- ✅ Format functions (simple and detailed)
- ✅ Normalization (all edge cases)
- ✅ Flag parsing (`-d`, `--detailed`)
- ✅ Detailed roll formatting with modifiers
- ✅ Roll execution with deterministic RNG in tests
- ✅ Error formatting
- ✅ CLI process_args() - single, multiple, mixed valid/invalid, both modes
- ✅ Edge cases (empty strings, whitespace, mixed valid/invalid)

**Current Public API:**
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

**Architecture Flow:**
```
args → parse_flags → process_args(detailed, rng) → process_expressions → normalize/roll/format → String → stdout
```

**CLI Usage:**
```bash
# Simple format (default)
dtc d6              # Output: d6: [4]
dtc d6 2d20+3       # Output: 1. d6: [3]
                    #         2. 2d20+3: [15]

# Detailed format (shows individual rolls)
dtc -d d6           # Output: d6: [4] = 4
dtc -d 3d6+2        # Output: 3d6+2: [4 + 3 + 5] +2 = 14
dtc --detailed 2d20 # Output: 2d20: [12 + 18] = 30
```

### To Be Determined
1. **Help/Usage Message Enhancement** - Current help doesn't mention `-d`/`--detailed` flag. Options:
   - Update basic help message to include flag documentation
   - Add proper `--help`/`-h` flag support
   - Hybrid: short message + "run dtc --help for more"
   - Decision pending until next session

### Refactor Opportunities (Optional)
1. **Magic strings** - "Error: " prefix and `7` magic number for error detection
2. **Type safety** - `process_expressions()` returns `List(String)` mixing results and errors
3. **Dead comment** - Line 112 in `format_detailed_roll()` about " + " handling

### Next Steps (In Order)
1. **Decide on help message approach** - How to surface flag documentation
2. **Update hexdocs** - Add module and function documentation
3. **Consider refactors** - If time and interest permit

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

### Session 4 (2025-11-11 - NORMALIZED EXPR REFACTOR & CLI IMPLEMENTATION)
- **Documentation sync** - Fixed stale references to Command type
- **NormalizedExpr refactor** - Eliminated double-parsing by storing both BasicRoll and normalized string
- **Added prng dependency** - Gleam-native RNG, removed glint (staying minimal)
- **Implemented process_args()** - Full CLI arg processing with inline error handling
- **21 tests passing** - Single rolls, multiple rolls, mixed valid/invalid expressions
- **Key decision**: Position-based numbering for both results and errors
- **Next session**: Implement main() entry point and test end-to-end

### Session 5 (2025-11-14 - DETAILED FLAG COMPLETE)
- **Detailed flag implementation** - Added `-d`/`--detailed` for showing individual die rolls
- **Major refactor** - Extracted `process_expressions()` to eliminate duplication and simplify detailed branching
- **Fixed `format_detailed_roll()` signature** - Removed redundant modifier parameter
- **RNG injection fix** - Added `rng_fn` parameter throughout for deterministic testing
- **45 tests passing** - All simple/detailed modes with deterministic assertions
- **Key wins**: Clean separation of concerns, maintainable code, comprehensive test coverage
- **Manual testing confirmed** - CLI works with both simple and detailed modes
- **Session retrospective completed** - Identified TBD (help message) and refactor opportunities
- **Next session**: Decide on help message approach, add hexdocs

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
