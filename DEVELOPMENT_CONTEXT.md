# dice_trio_cli - Development Context

## Project Overview
**Project Name**: `dice_trio_cli`
**Goal**: Build a command-line interface for the `dice_trio` core library, focused on intuitive UX and helpful output formatting

**Philosophy**: Build on the bulletproof `dice_trio` foundation with maximum CLI usability. Follow Unix philosophy - simple, predictable, composable. Focus on game master and developer workflows with clear, readable output.

**Bolt-On Architecture Philosophy**: The CLI serves as an orchestrator for the dice_trio ecosystem, automatically discovering and integrating extension libraries through a standardized flag-based interface. Each bolt-on library (dice_trio_dnd, dice_trio_stats, etc.) declares its own flags and processing logic, keeping the core CLI simple while enabling rich functionality.

**Development Approach**: Test-Driven Development (TDD) using Red-Green-Refactor cycle. Start with absolute simplest case first - basic dice expression parsing before advanced features. CLI-focused testing for argument parsing and output formatting.

**Parent Library Status**: `dice_trio` core is production-ready with 56 comprehensive tests, DetailedRoll functionality, and bulletproof parsing. Ready to build CLI on this solid foundation.

## Current Status
- **Phase**: Initial CLI architecture and argument parsing design
- **Achievements**:
  - Basic Gleam project scaffolding in place
  - Parent library `dice_trio` is production-ready (56 tests, DetailedRoll, performance validated)
  - CLAUDE.md configuration established with TDD workflow
  - Development context established for work/home continuity
- **Next Steps**: Define CLI argument structure and implement basic dice expression handling

## Key Decisions Made
- Build on `dice_trio` core library rather than reinventing dice logic
- Focus on CLI-specific concerns: argument parsing, output formatting, error display
- Start simple: positional argument for dice expression, optional flags for formatting
- Prioritize human-readable output with consideration for JSON/scripting options

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
- **Language**: Gleam (leveraging existing dice_trio library)
- **Architecture**: CLI wrapper around dice_trio core with focus on UX
- **Argument Parsing**: Pattern matching approach (Gleam idioms)
- **Output Design**: Human-readable default, consider JSON option for scripting
- **Error Handling**: User-friendly CLI error messages building on dice_trio's Result types

## CLI Design Priorities

### Argument Structure (TBD)
- **Simple case**: `dice_trio_cli d6` → roll single die, show result
- **Complex case**: `dice_trio_cli "2d6+3"` → roll expression, show breakdown
- **Flags consideration**: `--verbose`, `--json`, `--help`

### Output Formatting (TBD)
- **Default**: Human-readable with clear result display
- **Verbose**: Show individual die rolls and breakdown
- **JSON**: Machine-readable for scripting integration
- **Error display**: Clear, actionable error messages for CLI users

### User Experience Goals
- **Intuitive**: Game masters should understand output immediately
- **Helpful**: Clear error messages for invalid dice expressions
- **Scriptable**: Optional JSON output for automation
- **Fast**: Immediate response for basic rolls

## Parent Library Integration
**dice_trio Core Features Available:**
- `dice_trio.roll(expression, rng_fn) -> Result(Int, DiceError)` - Basic rolling
- `dice_trio.detailed_roll(expression, rng_fn) -> Result(DetailedRoll, DiceError)` - Individual die values
- `dice_trio.parse(expression) -> Result(BasicRoll, DiceError)` - Parse without rolling
- Full error handling with descriptive `DiceError` types
- Production-tested performance (handles `1000d6`, `100d100+50`)

**RNG Integration**: Use `prng` library (recommended by parent project) for CLI random number generation

## Active Development Areas
- [x] **COMPLETED**: Define CLI argument structure and parsing strategy
- [x] **COMPLETED**: Implement basic dice expression input handling with dice_trio integration
- [ ] Test existing single and multiple expression functionality
- [ ] **NEW FEATURE**: Implement --interactive flag for loop mode while preserving one-off roll behavior
- [ ] Design output formatting for roll results (human-readable default)
- [ ] Error handling and user-friendly feedback for CLI context
- [ ] Help system and usage documentation
- [ ] Consider advanced features: verbose output, JSON format, batch rolling
- [x] **COMPLETED**: Bolt-on architecture interface contract design
- [x] **COMPLETED**: Flag-based extension system documentation

### Interactive Mode Design (Session 2025-09-21)
**Goal**: Add `--interactive` flag for REPL-style dice rolling while preserving one-off command behavior

**Usage Patterns**:
```bash
dtc d6                    # One-off roll and exit
dtc d6 2d8+1 d20         # Multiple one-off rolls and exit
dtc --interactive        # Enter interactive loop mode
```

**Architecture Considerations**:
- Interactive mode: REPL loop for game sessions with repeated rolls
- One-off mode: Fast execution for scripting and quick rolls
- Bolt-on loading: Extensions may behave differently in interactive vs one-off modes
- Help system: Update to document both modes

**Implementation Steps**:
1. Add --interactive flag parsing to Command type
2. Design interactive loop architecture (input/output cycle)
3. Update help documentation for both modes
4. Consider bolt-on extension behavior in each mode

### GM-Focused Output Formatting (Session 2025-09-21)
**Goal**: Clean, table-friendly output that GMs can read instantly during sessions

**Formatting Rules**:
- **Single roll**: Clean format without numbering (`d6: 4`)
- **Multiple rolls**: Numbered for tracking (`1. d6: 4`, `2. 2d6+3: [4,2] + 3 = 9`)
- **Breakdown display**: Show individual dice for multi-die rolls
- **Modifier clarity**: Clear addition/subtraction display

**Output Examples**:
```bash
# Single expression
d6: 4

# Multiple expressions
1. d6: 4
2. 2d6+3: [4,2] + 3 = 9
3. 3d6: [4,2,5] = 11
4. d20-1: 15 - 1 = 14
```

**Test Writing Order**:
1. Single die roll formatting (`d6: 4`)
2. Multi-die roll without modifier (`3d6: [4,2,5] = 11`)
3. Single die with modifier (`d6+2: 4 + 2 = 6`)
4. Multi-die roll with modifier (`2d6+3: [4,2] + 3 = 9`)
5. Error formatting (user-friendly messages)
6. Multiple roll results formatting (numbered batch output)

## Questions to Resolve
- CLI argument parsing approach: manual pattern matching vs library?
- Output format priorities: verbose by default or simple?
- JSON output: separate flag or format option?
- Batch operations: support multiple expressions in one command?

### Bolt-On Architecture Concerns
- **Flag Conflict Resolution**: How to handle when multiple bolt-ons want the same flag name?
- **Help System Aggregation**: How does `--help` combine information from core + all discovered bolt-ons?
- **Error Message Strategy**: Unified error format and styling across core and bolt-on libraries
- **Configuration File Alternative**: If dynamic discovery becomes problematic, design bolt-on configuration file approach
- **Output Format Standards**: Ensure bolt-ons produce consistent display formatting and metadata structure
- **Dynamic Discovery Implementation**: Gleam package scanning and dynamic import patterns - may need fallback to explicit configuration

## Session Notes
### Session 1 (Date: 2025-09-15)
- Established CLI project context building on dice_trio foundation
- Created DEVELOPMENT_CONTEXT.md for work/home session continuity
- Confirmed parent library is production-ready with comprehensive test suite
- Ready to begin CLI-specific development with TDD approach
- Project scaffolding in place, ready for argument parsing implementation

## Bolt-On Interface Contract

### Flag-Based Extension System
Each bolt-on library must implement a standardized interface for CLI integration:

```gleam
// Required exports for bolt-on libraries
pub type CliFlag {
  CliFlag(name: String, description: String, takes_value: Bool)
}

pub type BoltOnResult {
  BoltOnResult(
    modified_result: Result(Int, String),
    display_info: List(String),
    metadata: Dict(String, String)
  )
}

// Each bolt-on library exports these functions:
pub fn cli_flags() -> List(CliFlag)
pub fn process_roll(
  basic_result: BasicRoll,
  detailed_result: DetailedRoll,
  flags: Dict(String, String)
) -> BoltOnResult
```

### Discovery Pattern
```gleam
// CLI scans for installed packages matching dice_trio_*
// Dynamically imports and calls cli_flags() + process_roll()
// Libraries are responsible for their own flag validation
```

### Usage Examples
```bash
# dice_trio_dnd bolt-on provides:
dice_trio_cli d20 --advantage
dice_trio_cli d20 --disadvantage
dice_trio_cli d20 --crit-range 19

# dice_trio_stats bolt-on provides:
dice_trio_cli 3d6 --probability
dice_trio_cli 2d6 --distribution
dice_trio_cli 4d6 --drop-lowest --stats

# Multiple bolt-ons can be combined:
dice_trio_cli d20 --advantage --stats --verbose
```

### Bolt-On Responsibilities
- **Flag Declaration**: Export available flags with descriptions
- **Input Validation**: Validate their own flag values
- **Result Processing**: Transform basic/detailed results as needed
- **Display Enhancement**: Provide additional information for output formatting
- **Error Handling**: Return descriptive errors for invalid flag combinations

### CLI Orchestration Flow
1. Parse dice expression with dice_trio core
2. Scan for available bolt-on libraries (dice_trio_*)
3. Collect flags from each discovered bolt-on
4. Route relevant flags to appropriate bolt-on processors
5. Combine results and format output

## Code Snippets & Examples
*(To be added as CLI-specific patterns emerge)*

### Parent Library Usage Examples:
```gleam
import dice_trio
import prng/random

// Basic rolling - what CLI will wrap
let rng = fn(max: Int) {
  let generator = random.int(1, max)
  random.random_sample(generator)
}

dice_trio.roll("d6", rng)           // Ok(4)
dice_trio.roll("2d6+3", rng)       // Ok(11)
dice_trio.detailed_roll("2d6", rng) // Ok(DetailedRoll with individual rolls)
```

---
*Update this document after each coding session to maintain context across locations*