---
name: metahdl-patterns
description: Coding patterns extracted from metahdl - a MetaHDL compiler/transpiler for HDL code generation
version: 1.0.0
source: local-git-analysis
analyzed_commits: 126
---

# MetaHDL Patterns

## Project Overview

MetaHDL is a hardware description language compiler (`mhdlc`) that transpiles `.mhdl` source files into Verilog/SystemVerilog RTL. It consists of a preprocessor, MHDL parser, and SV parser, built with Flex/Bison and C++.

## Commit Conventions

This project uses **free-form commit messages** (no conventional commits). Common patterns:

- **Add/Fix/Remove/Support/Update** prefixes for feature and bug descriptions
- Occasional `+` / `!` prefixes for significance markers (rare, legacy)
- Messages describe the HDL domain concept, not the code change (e.g., "Support 2D port connection" not "add array to parser")
- Commits are typically single-purpose but not strictly scoped

### Commit Message Style

```
Support 2D port direction in mhdl source
Fix 2D property propagation.
Report detailed expression on width mismatch in assign statement
Remove "_1" suffix from singular instance.
```

- Sentence case, no trailing period consistency
- Past/present tense mixed (imperative preferred recently)
- Short and descriptive of the HDL behavior change

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
│   │   ├── Expression.hh   # Expression AST nodes
│   │   ├── Table.hh        # Symbol table
│   │   ├── Statement.hh    # Statement AST nodes
│   │   ├── CodeBlock.hh    # Code block structures
│   │   ├── Wrapper.hh      # Wrapper classes
│   │   ├── Mfunc.cc/.hh    # Utility functions
│   │   ├── CMacro.hh       # Macro handling
│   │   └── Makefile         # Build system
│   ├── test/               # Test suite
│   │   ├── mhdl/           # .mhdl source test inputs
│   │   ├── rtl/            # Expected/generated Verilog output
│   │   ├── ip/             # IP test modules
│   │   └── Makefile        # Test build
│   └── doc/                # Documentation (LaTeX, UML)
├── xregs/                  # Register file RTL IP (Verilog)
├── fifo/                   # FIFO RTL IP
├── scripts/                # Build/utility scripts
└── .gitignore
```

### Key Source Files by Change Frequency

| File | Changes | Role |
|------|---------|------|
| `mparser.y` | 38 | MHDL grammar - primary development focus |
| `Expression.hh` | 24 | Expression AST - width/type checking |
| `Mfunc.cc` | 21 | Utility functions |
| `Statement.hh` | 13 | Statement AST nodes |
| `vpp.l` | 12 | Verilog preprocessor lexer |
| `Table.hh` | 12 | Symbol table management |

## Workflows

### Parser Development (Most Common)

Files that change together: `mparser.y`, `Expression.hh`, `Table.hh`

1. Modify `mparser.y` (Bison grammar) to add/fix syntax rules
2. Update `Expression.hh` for new AST node properties (e.g., 2D array support)
3. Update `Table.hh` for symbol table changes
4. Add test case in `test/mhdl/a.mhdl`
5. Update expected output in `test/rtl/a.v`
6. Build with `make` in `mhdlc/src/`

### Preprocessor Changes

Files that change together: `vpp.l`, `vpp.y`

1. Modify lexer (`vpp.l`) and grammar (`vpp.y`) together
2. Both files must stay in sync for token definitions

### Width/Type Checking Improvements

Typical commit pattern: parser + expression + test files

1. Add checking logic in `mparser.y`
2. Add error reporting with detailed location info
3. Add test cases exercising the new check
4. Always include expression details in error messages

## Testing Patterns

- **Test inputs**: `mhdlc/test/mhdl/*.mhdl` (MetaHDL source files)
- **Expected outputs**: `mhdlc/test/rtl/*.v` (generated Verilog)
- **IP modules**: `mhdlc/test/ip/*.v` (test IP dependencies)
- **Test execution**: Via Makefile using `mhdlc` compiler with flags like `-verilog --macro-case-modifier`
- Tests verify transpiler output matches expected Verilog
- Test files are named simply (`a.mhdl`, `b.mhdl`) - not descriptive

## Build System

- **Build tool**: GNU Make
- **Compiler**: g++ with Perl embedding (`ExtUtils::Embed`)
- **Parser generators**: Flex (lexers) + Bison 2.5 (grammars)
- **Build commands**:
  - `make` in `mhdlc/src/` - debug build
  - `make release` - optimized build (`-O3`)
  - `make clean` - remove generated files
  - `make tar` - create source archive

### Generated Files (auto-cleaned)

Flex generates `.flex.cc` files, Bison generates `.bison.cc` and `.bison.hh` files. These are in `.gitignore` and cleaned by `make clean`.

## Language & Tooling

- **Primary language**: C++ (compiler), Verilog/SystemVerilog (RTL output)
- **Parser framework**: Flex + Bison (classic lex/yacc)
- **Domain**: Hardware design, HDL transpilation
- **Perl**: Embedded for macro processing
- **Documentation**: LaTeX (`mhdlc/doc/tex/`)

## Naming Conventions

### C++ Source

- Classes: `C` prefix (e.g., `CSymbol`, `CVariable`, `CParameter`, `CMacro`)
- Header files: PascalCase with `.hh` extension
- Source files: PascalCase or lowercase with `.cc` extension
- Bison/Flex: lowercase with parser type suffix (`.y`, `.l`)

### Verilog RTL

- Modules: `snake_case` (e.g., `one_hot_mux`, `binary_aggregator`)
- Files match module names with `.v` extension
- Parameters: `UPPER_SNAKE_CASE`

## Domain-Specific Patterns

### 2D Array Support (Recent Focus)

Major recent development effort. Changes span:
- Parser grammar for 2D port declarations
- Expression nodes for `length_msb` tracking
- Symbol table for 2D property propagation
- Width mismatch checking for 2D connections

### Error Reporting

Consistent pattern: always include detailed location and expression info in error/warning messages. Recent commits specifically improve diagnostic detail.

### Width Checking

The compiler performs width mismatch detection for:
- Assign statements
- Blocking/non-blocking assignments
- Port connections

Error messages include the actual expression, not just a generic warning.
