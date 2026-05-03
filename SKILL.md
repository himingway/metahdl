---
name: metahdl-patterns
description: Coding patterns extracted from metahdl - a MetaHDL compiler/transpiler for HDL code generation
version: 2.0.0
source: local-git-analysis
analyzed_commits: 47
---

# MetaHDL Patterns

## Project Overview

MetaHDL is a hardware description language compiler (`mhdlc`) that transpiles `.mhdl` source files into Verilog/SystemVerilog RTL. It consists of a preprocessor (VPP/MPP), MHDL parser, and SV parser, built with Flex/Bison and C++.

## Commit Conventions

Mixed conventions observed:

- **Conventional commits** (recent): `feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`
- **Free-form** (older): `Add`, `Fix`, `Remove`, `Support`, `Update` prefixes
- Messages describe HDL domain concepts, not code changes
- Sentence case, no trailing period consistency

### Recent Style (preferred)

```
feat: support \U and \L for case transform
fix: refine regex_replace with regex_constants::match_not_null
test(parser): add minimal test input files for all 4 parsers
chore(parser): upgrade bison directives to 3.8
docs: add initial README.md with project overview
```

## Code Architecture

```
metahdl/
├── mhdlc/                  # Main compiler
│   ├── src/                # C++ source with Flex/Bison parsers
│   │   ├── mhdlc.cc        # Entry point
│   │   ├── mparser.y       # MHDL grammar (Bison) - most changed file
│   │   ├── mlexer.l        # MHDL lexer (Flex)
│   │   ├── svparser.y      # SystemVerilog grammar (Bison)
│   │   ├── svlexer.l       # SystemVerilog lexer (Flex)
│   │   ├── vpp.y / vpp.l   # Verilog preprocessor parser/lexer
│   │   ├── mpp.y / mpp.l   # MetaHDL preprocessor parser/lexer
│   │   ├── Expression.hh   # Expression AST nodes + CSymbol
│   │   ├── Statement.hh    # Statement AST nodes + CCaseItem
│   │   ├── CodeBlock.hh    # Code block structures (FF, FSM, Generate)
│   │   ├── Wrapper.hh      # CMHDLwrapper, CSVwrapper
│   │   ├── Mfunc.cc/.hh    # Utility functions, GetOpt, SearchFile
│   │   └── Makefile         # Build system
│   ├── test/               # Comprehensive test suite
│   │   ├── inputs/         # All test input files
│   │   ├── output/         # Generated output (gitignored)
│   │   └── Makefile        # Test runner (make test)
│   └── doc/tex/            # Documentation (LaTeX)
├── xregs/                  # Register file RTL IP (Verilog)
├── fifo/                   # FIFO RTL IP generators (Perl)
├── scripts/                # Build/utility scripts
│   └── vp2mhdl.pl          # VPP to MHDL converter
├── python/                 # Python utilities
├── org/                    # Project notes (Org-mode)
└── README.md               # Project documentation
```

## Compiler Pipeline

```
.mhdl files  →  VPP  →  MPP  →  MHDL parser  →  SystemVerilog
.v/.sv/.vh   →  VPP  →  SV parser  →  SystemVerilog
```

File extension determines parser: `.mhdl` → MHDL parser, everything else → SV parser.

### Key Source Files by Change Frequency

| File | Changes | Role |
|------|---------|------|
| `mparser.y` | 15 | MHDL grammar - primary development focus |
| `Expression.hh` | 11 | Expression AST + CSymbol (width, type, unpacked arrays) |
| `svparser.y` | 9 | SystemVerilog grammar |
| `Mfunc.cc` | 8 | Utility functions, GetOpt, SearchFile |

## Workflows

### Parser Development (Most Common)

Files that change together: `mparser.y`, `Expression.hh`, `Statement.hh`

1. Modify `mparser.y` (Bison grammar) to add/fix syntax rules
2. Update `Expression.hh` for new AST node properties (e.g., unpacked array fields)
3. Update `Statement.hh` for new statement types if needed
4. Update `CodeBlock.hh` for new code block types if needed
5. Add test case in `test/inputs/`
6. Build with `make` in `mhdlc/src/`
7. Run `make test` in `mhdlc/test/`

### SV Parser Changes

Files that change together: `svparser.y`, `Expression.hh`

1. Modify `svparser.y` for new grammar rules
2. Update `CSymbol` in `Expression.hh` for new symbol properties
3. Update `PrintPort`/`PrintDeclare` for output generation
4. Add test in `test/inputs/test_sv_module.v` or new test file

### Preprocessor Changes

Files that change together: `vpp.l` + `vpp.y` (VPP) or `mpp.l` + `mpp.y` (MPP)

1. Modify lexer (`.l`) and grammar (`.y`) together
2. Both files must stay in sync for token definitions
3. VPP runs first for ALL file types; MPP only for `.mhdl`

### Bug Fix Pattern

1. Run `gdb -batch -ex run -ex bt -ex quit --args ./mhdlc ...` to get backtrace
2. Fix in grammar (`.y`) or AST (`Expression.hh`, `Statement.hh`, `CodeBlock.hh`)
3. Add regression test in `test/inputs/`
4. Run `make test` to verify

## Testing Patterns

### Test Structure

All test files are in `test/inputs/`:

| File | Parser | Purpose |
|------|--------|---------|
| `test_vpp.vh` | SV | VPP preprocessor features |
| `test_sv_module.v` | SV | SystemVerilog module parsing |
| `test_mh_basic.mhdl` | MHDL | Full MHDL feature coverage |
| `test_mpp.mhdl` | MHDL | MPP preprocessor (VPP-compatible only) |
| `one_hot_mux_2d.v` | SV | IP module with 2D packed arrays |
| `test_unpacked_array.v` | SV | Verilog unpacked array port syntax |

### Running Tests

```bash
cd mhdlc/test
make test              # Run all 6 tests
make test_vpp          # Individual test
make test_mhdl         # Individual test
make clean             # Remove output/
```

### Test File Conventions

- VPP/MPP tests must be valid SV after preprocessing (wrap in `module ... endmodule`)
- `.mhdl` files use MHDL parser; `.v`/`.sv`/`.vh` use SV parser
- VPP runs first for all files — MPP-only features can't be tested in `.mhdl`
- FSM blocks require a default statement before state items
- Generate blocks support both `begin: name ... end` and bare `begin ... end`
- FF items use comma syntax: `dest, src;` or `dest, src, reset;`
- FSM combinational blocks use blocking assignments (`=`), not non-blocking (`<=`)

### Key Grammar Limitations

- FF items only support single `net_lval`, not concatenation LHS
- SV parser supports packed 2D (`[a:0][b:0]`) and unpacked (`name [a:0]`) arrays
- Generate `for`/`if` take a single `generate_statement`, not `begin...end` blocks (use bare `begin` without label)
- SV parser body only has `port_declaration` and `parameter_declaration` — no wire/reg/logic body declarations

## Build System

- **Build tool**: GNU Make
- **Compiler**: g++ (C++11+)
- **Parser generators**: Flex + Bison 3.8+
- **Build**: `make -C mhdlc/src`
- **Test**: `make -C mhdlc/test test`

### Generated Files (auto-cleaned)

Flex generates `.flex.cc` files, Bison generates `.bison.cc` and `.bison.hh` files.

## Language & Tooling

- **Primary language**: C++ (compiler), Verilog/SystemVerilog (RTL output)
- **Parser framework**: Flex + Bison (classic lex/yacc)
- **Domain**: Hardware design, HDL transpilation
- **Documentation**: LaTeX (`mhdlc/doc/tex/`)

## Naming Conventions

### C++ Source

- Classes: `C` prefix (e.g., `CSymbol`, `CVariable`, `CFFItem`, `CBlkFSM`)
- Header files: PascalCase with `.hh` extension
- Source files: lowercase with `.cc` extension
- Bison/Flex: lowercase with parser type suffix (`.y`, `.l`)

### Verilog RTL

- Modules: `snake_case`
- Files match module names with `.v` extension
- Parameters: `UPPER_SNAKE_CASE`

## Domain-Specific Patterns

### Width Checking

The compiler performs width mismatch detection for:
- Assign statements
- Blocking/non-blocking assignments
- Port connections
- FF src/dst and reset values

Error messages include the actual expression and width values.

### Metahdl Control

Module-level directives set compiler behavior:
```
metahdl + portchk;           // Enable port checking
metahdl - exitonportchk;    // Don't exit on port warnings
metahdl modname = name;      // Set output module name
metahdl clock = clk;         // Set default clock
metahdl reset = rst_n;       // Set default reset
```

### Symbol Table (CSymbol)

Key fields for port/signal tracking:
- `msb`, `lsb` — packed dimension
- `is_2D`, `length_msb` — packed 2D arrays
- `is_unpacked`, `unpacked_msb`, `unpacked_lsb` — Verilog unpacked arrays
- `direction` — INPUT/OUTPUT/INOUT/NONPORT
- `type` — WIRE/REG/LOGIC/INT/INTEGER
- `width_fixed`, `io_fixed` — declaration constraints
