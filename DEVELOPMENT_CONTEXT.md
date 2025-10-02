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
**Tests (3 total):**
- ✅ `display_help()` - returns usage string
- ✅ `default_format(expr, result)` - pure formatter function
- 🔴 `execute_command(BasicRoll(Ok(...)))` - RED TEST, needs implementation next

**Architecture Flow:**
```
args → Command → execute_command() → String → stdout
```

**Command Type:**
```gleam
pub type Command {
  Help
  BasicRoll(Result(dice_trio.BasicRoll, dice_trio.DiceError))
  BasicRollList(List(Result(dice_trio.BasicRoll, dice_trio.DiceError)))
}
```

### Next Steps (In Order)
1. **Implement single expression roll**
   - execute_command() handles BasicRoll(Ok(br))
   - Call dice_trio.roll() with test RNG
   - Reconstruct expression string from BasicRoll
   - Use default_format() for output
2. **Test multiple expression handling**
   - Numbered output format (1. expr: [result])
   - BasicRollList command variant
3. **Test error formatting**
   - Handle BasicRoll(Error(e))
   - User-friendly error messages to stderr
4. **Implement arg → Command parsing**
   - Parse argv into Command variants
5. **Full integration through main()**
   - End-to-end test with real RNG

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

### Why Keep Command Type?
**Alternative**: Could parse args directly in main()
**Decision**: Keep Command for testability and separation of concerns
**Benefits**:
- execute_command() is pure function (Command → String)
- Easy to test all cases without I/O
- Clean pattern matching on Command variants
- Separates parsing from execution

### Error Handling Strategy
**Decision**: Errors propagate up to CLI layer
**Pattern**: Command carries `Result(BasicRoll, DiceError)`, execute_command() unwraps and formats
**Benefits**:
- CLI owns presentation, dice_trio owns logic
- User-friendly messages at presentation layer
- Type-safe error handling throughout

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
- **Current status**: 3 tests (2 passing, 1 red), ready to implement single roll execution
- **Architecture**: Clean Command → execute_command() → String flow
- **Collaboration note**: thiccjay returning to coding after 2 weeks of laptop setup work
- **Commit plan**: This commit documents refactor, next commit will implement + review

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
