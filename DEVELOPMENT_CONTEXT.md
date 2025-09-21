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
1. ✅ Single die roll formatting (`d6: 4`)
2. ✅ Multi-die roll without modifier (`3d6: 11`)
3. ✅ Single die with modifier (`d6+2: 6`)
4. ✅ Multi-die roll with modifier (`2d6+3: 11`)
5. **IN PROGRESS**: Randomized error formatting (gaming-themed messages)
6. Multiple roll results formatting (numbered batch output)

### Randomized Error Formatting Design (Session 2025-09-21)
**Goal**: Make error messages entertaining with double-randomized gaming personality

**Double Random Pool Architecture**:
- **Pool 1 - Gaming Expressions**: `["Critical Fail!", "Natural 1!", "Fumble!", "Epic Fail!", "Botched roll!", "Snake Eyes!", "Cursed dice!", "The dice gods frown!"]`
- **Pool 2 - Casual Descriptions**: `["are whack, dawg", "need some work", "aren't gonna fly", "are totally busted", "make no sense", "are broken, chief", "are cursed", "need fixing"]`

**Error Message Pattern**:
```gleam
format_error(error: DiceError, rng_fn: fn(Int) -> Int) -> String
// [Random Gaming] + specific error + [Random Casual] + helpful examples
```

**Example Error Outputs**:
```bash
"Critical Fail! Your die sides are whack, dawg: 'abc' - try 'd6' or '2d20+3'"
"Natural 1! Missing separator isn't gonna fly - try 'd6' or '3d8+2'"
"Fumble! Zero dice are totally busted, chief - need at least 1 die!"
"Epic Fail! That modifier makes no sense: '+abc' - try '+3' or '-2'"
```

**Successful Roll Personality** (Session 2025-09-21):
**IMPORTANT**: Apply personalities to successful rolls too - fun shouldn't be limited to errors!

**Success Expression Pools**:
- **Gaming Success**: `["Critical Hit!", "Natural 20!", "Perfect Roll!", "Legendary!", "Epic Success!", "Rolling Hot!", "Dice Blessed!", "Victory!"]`
- **Casual Success**: `["crushed it", "nailed it", "killed it", "owned that", "destroyed", "dominated", "slayed", "absolutely wrecked"]`

**Example Success Outputs**:
```bash
"Critical Hit! You crushed it: d6 rolled [6]!"
"Natural 20! You nailed it: 2d6+3 rolled [11]!"
"Perfect Roll! You killed it: 3d8-2 rolled [18]!"
"Epic Success! You dominated: d20 rolled [20]!"
```

**Corporate Success Theme Examples**:
```bash
"Process completed successfully! Operation executed: d6 returned [4]"
"Task accomplished! Function optimized: 2d6+3 returned [9]"
"System operating nominally! Query processed: d20-1 returned [15]"
```

### Quiet/Minimal Output Modes (Session 2025-09-21)
**Goal**: Allow GMs to disable personalities for speed during intense sessions

**CLI Mode Usage** (one-off rolls):
```bash
dtc d6                    # Default personality: "Critical Hit! You crushed it: d6 rolled [4]!"
dtc --quiet d6            # Minimal output: "d6: [4]"
dtc --minimal d6          # Ultra-fast output: "[4]"
dtc --interactive --quiet # Start REPL in quiet mode
```

**REPL Mode Usage** (interactive session):
```bash
dtc --interactive         # Enter REPL with default personality
> d6                      # "Critical Hit! You crushed it: d6 rolled [4]!"
> /quiet                  # Switch to quiet mode for fast combat
> d6                      # "d6: [4]"
> 2d6+3                   # "2d6+3: [9]"
> /minimal                # Switch to ultra-minimal
> d20                     # "[15]"
> /personality gaming     # Switch back to full personality
> d6                      # "Natural 20! You dominated: d6 rolled [6]!"
> /help                   # Show available REPL commands
```

**REPL Commands**:
- `/quiet` - Minimal output with dice expression
- `/minimal` - Ultra-minimal, just results in brackets
- `/personality [theme]` - Full personality mode (gaming, corporate, pirate, etc.)
- `/help` - Show available commands
- `/status` - Show current output mode and personality theme

**Persistent Session Settings**: REPL remembers your preferred mode throughout the session - perfect for switching between narrative moments (personality) and fast-paced combat (quiet).

**Functions**:
- `pick_random_expression(pool: List(String), rng_fn: fn(Int) -> Int) -> String`
- `format_error(error: DiceError, rng_fn: fn(Int) -> Int) -> String`
- Error-specific helper functions for different `DiceError` types

### Custom Personality Pools (Session 2025-09-21)
**REVOLUTIONARY IDEA**: Allow DMs to pass their own personality lists for error messages!

**Configuration Options**:
```bash
# Default gaming personality
dtc d6

# Custom personality file
dtc --personality ./my_pirate_errors.toml d6

# Built-in personality themes
dtc --personality medieval d6
dtc --personality sci-fi d6
dtc --personality corporate d6
```

**Personality File Format**:
```toml
[expressions]
gaming = ["Critical Fail!", "Natural 1!", "Epic Fail!"]
casual = ["are whack, dawg", "need some work", "are broken"]

[expressions.pirate]
gaming = ["Arr matey!", "Shiver me timbers!", "Blimey!"]
casual = ["be cursed", "need fixin'", "be broken"]

[expressions.medieval]
gaming = ["By the gods!", "Cursed fate!", "A pox upon thee!"]
casual = ["art broken", "doth not work", "be cursed"]

[expressions.corporate]
gaming = ["Error 404!", "System failure!", "Process terminated!"]
casual = ["require debugging", "are not optimal", "need refactoring"]
```

**Use Cases**:
- **Corporate DM**: Professional error messages for work D&D sessions
- **Medieval Campaign**: Period-appropriate error messages matching campaign setting
- **Kids Table**: Clean, age-appropriate fun messages
- **Homebrew Worlds**: Custom error messages matching unique campaign themes
- **Multilingual**: Error messages in different languages

**Bolt-On Integration**: Custom personalities could be packaged as extensions in the dice_trio ecosystem, automatically discovered and loaded!

### Personality Template & Community Sharing (Session 2025-09-21)
**NEXT-LEVEL IDEA**: Ship with pre-written personality template for community customization and sharing!

**Include in Project**:
- `personalities.toml` - Template file with all built-in personalities
- Serves as both functional defaults AND documentation/examples
- Community can copy, modify, and share their own personality files
- GitHub/forums can become personality sharing hubs

**Community Ecosystem Potential**:
- **dice_trio_personalities_star_wars**: Galactic error messages
- **dice_trio_personalities_cyberpunk**: Matrix-style error responses
- **dice_trio_personalities_wholesome**: Encouraging, positive error messages
- **dice_trio_personalities_savage**: Brutal roast-mode error messages
- **dice_trio_personalities_multilingual**: Error messages in multiple languages

**Sharing Workflow**:
1. Copy `personalities.toml` template
2. Customize gaming/casual expression pools
3. Share on GitHub/community forums
4. Others download and use: `dtc --personality ./downloaded_personality.toml d6`

**Template Benefits**:
- Shows format clearly with working examples
- Demonstrates variety of tone options
- Encourages community creativity and contribution
- Makes CLI instantly more fun and customizable

### Test Structure & Methodology (Session 2025-09-21)
**Following dice_trio Core Library Patterns**

**Test File Organization**:
- `dice_trio_cli_test.gleam` - Unit tests for individual functions
- `dice_trio_cli_integration_test.gleam` - Full pipeline tests (Command → execute_command() → String output)
- Future: `dice_trio_cli_e2e_test.gleam` - End-to-end CLI behavior tests

**Integration Test Pattern** (matching dice_trio core):
```gleam
import dice_trio_cli
import gleeunit
import gleeunit/should

// Integration tests - full pipeline from Command to final string output
pub fn execute_help_command_full_pipeline_test() {
  dice_trio_cli.execute_command(dice_trio_cli.Help)
  |> should.equal("Usage: dtc d6 or dtc 2d20+3")
}
```

**Test Philosophy**:
- **Unit tests**: Pure functions, individual components
- **Integration tests**: Full workflows, Command → String pipelines
- **E2E tests**: Actual CLI invocation and stdout capture
- Same structure and naming as dice_trio core for consistency

**Benchmark Implementation** (matching dice_trio core):
- `dev/dice_trio_cli_dev.gleam` - Performance benchmarks using `gleamy/bench`
- Track CLI performance over time with timing history comments
- Benchmark key operations: argument parsing, command execution, output formatting
- Pattern matching dice_trio's comprehensive benchmark suite:

```gleam
import dice_trio_cli
import gleamy/bench
import gleam/io

pub fn main() {
  io.println("🎲 dice_trio_cli Performance Benchmarks")

  argument_parsing_benchmark()
  command_execution_benchmark()
  output_formatting_benchmark()
}

fn argument_parsing_benchmark() {
  // Timing history: [date]: [performance], [previous], [previous]
  bench.run(
    [bench.Input("d6", ["d6"])],
    [bench.Function("parse_arg", dice_trio_cli.parse_arg)],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}
```

**Performance Tracking**: Same timing history pattern as dice_trio core for regression detection

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

### Session 2 (Date: 2025-09-21)
- Implemented comprehensive CLI argument parsing and Command architecture
- Designed GM-focused output formatting with clean helper functions
- Created randomized error formatting system with gaming personality
- Established integration test structure matching dice_trio core patterns

**thiccjay's feedback on collaboration:**
- "claude you just saved me hours of distracted boilerplate. u da best buddy." - appreciation for documenting test methodology, benchmark patterns, and community personality ecosystem, keeping focus on creative work instead of tedious setup

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