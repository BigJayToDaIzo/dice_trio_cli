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
args → Command → execute_command() → String → stdout
```

### Command Type
```gleam
pub type Command {
  Help
  BasicRoll(Result(dice_trio.BasicRoll, dice_trio.DiceError))
  BasicRollList(List(Result(dice_trio.BasicRoll, dice_trio.DiceError)))
}
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
// Extension point for libraries
pub type Formatter = fn(String, Int) -> String

pub fn default_format(expr: String, result: Int) -> String {
  expr <> ": [" <> int.to_string(result) <> "]"
}
```

## Session Tracking

### Current Status (Session 2025-10-02 - REFACTOR)
**Decision**: Scrapped complex personality/bolt-on architecture in favor of Unix philosophy minimal core

**Working Tests (3 passing):**
- ✅ `display_help()` - returns usage string
- ✅ `default_format(expr, result)` - pure formatter function
- 🔴 `execute_command(BasicRoll(Ok(...)))` - RED TEST, needs implementation

**Architecture Decisions:**
- Keep Command type for clean separation and testability
- Parse errors bubble up: `Result(BasicRoll, DiceError)` in Command
- execute_command() handles Ok/Error cases and formats output
- Bottom-up TDD: pure functions → integration → full pipeline

### Next Steps (In Order)
1. Implement single expression roll in execute_command()
   - Use dice_trio.roll() with fixed test RNG
   - Reconstruct expression string from BasicRoll for output
   - Use default_format() for output
2. Test multiple expression handling (numbered output)
3. Test error formatting (DiceError → user-friendly string)
4. Implement arg → Command parsing
5. Full integration test through main()

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

### Why Keep Command Type?
**Alternative**: Could parse args directly in main()
**Decision**: Keep Command for testability
- Separates parsing from execution
- execute_command() is pure function (Command → String)
- Easy to test all cases without I/O
- Clean pattern matching on Command variants

### Error Handling Strategy
**Decision**: Errors propagate up to CLI layer
- Command carries `Result(BasicRoll, DiceError)`
- execute_command() unwraps and formats
- CLI owns presentation, dice_trio owns logic
- User-friendly messages at presentation layer

---
*This file tracks Claude-specific development context and command shortcuts*
