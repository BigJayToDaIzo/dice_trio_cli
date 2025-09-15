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

## Collaboration Guidelines
- **Rubber Duck Philosophy**: Serve as rubber duck debugger and strategic advisor, not code generator
- **NO CODE IMPLEMENTATION** unless explicitly requested
- **NO GIT COMMANDS** unless explicitly requested - thiccjay uses lazygit tab for all repo management
- **NO DEPENDENCY CHANGES** unless explicitly requested - no modifications to gleam.toml
- **TEST SAFETY**: After applying refactors/code changes when requested, automatically run test suite without asking permission to verify no regressions
- Provide ideas, strategies, and architectural guidance only
- Focus on planning, design patterns, and approach discussions
- Support independent problem-solving while maintaining full transparency about AI contributions

## Current Architecture Notes
- **CLI Interface**: Command-line wrapper for dice_trio library
- **Core Integration**: Leverage dice_trio for dice rolling logic
- **User Experience**: Focus on intuitive CLI design and helpful error messages
- **Future Extensions**: Support for advanced dice expressions and output formats

## Session Tracking
*Use this section for quick development notes during Claude Code sessions*

### Active Development Areas
- [ ] Define CLI argument structure and parsing
- [ ] Implement basic dice expression input handling
- [ ] Design output formatting for roll results
- [ ] Error handling and user feedback
- [ ] Help system and usage documentation

### Quick Links
- Main module: `src/dice_trio_cli.gleam`
- Tests: `test/dice_trio_cli_test.gleam`
- Parent library: `../dice_trio/`

## Technical Decisions Log
*Track key technical choices made during development*

### CLI Argument Strategy
- TBD: Choose CLI argument parsing approach
- Priority: Simple dice expression as positional argument
- Consider: Flag options for output format, verbosity, etc.

### Output Formatting
- TBD: Define output format for roll results
- Consider: JSON output option for scripting
- Priority: Human-readable default output

### Error Handling
- TBD: User-friendly error messages for invalid input
- Use Gleam Result types for predictable error handling
- Focus on helpful feedback for CLI users

---
*This file tracks Claude-specific development context and command shortcuts*