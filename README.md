# MetaHDL

MetaHDL is a hardware description language for synthesizable digital VLSI designs (RTL). It selectively inherits SystemVerilog syntax, eliminates unnecessary variants, extends existing synthesizable language structures, and adds new grammars to simplify RTL coding.

## Project Structure

```
metahdl/
├── mhdlc/              # MetaHDL compiler (C++)
│   ├── src/            # Compiler source code
│   ├── test/           # Test suite
│   └── doc/tex/        # Documentation (LaTeX)
├── fifo/               # FIFO generators (Perl)
│   ├── gen_afifo.pl    # Async FIFO generator
│   └── gen_sfifo.pl    # Sync FIFO generator
├── xregs/              # Register file utilities
├── scripts/            # Utility scripts
│   └── vp2mhdl.pl      # VPP to MHDL converter
├── python/             # Python utilities
└── org/                # Project notes (Org-mode)
```

## Compiler Pipeline

The `mhdlc` compiler processes files based on extension:

```
.mhdl files  →  VPP  →  MPP  →  MHDL parser  →  SystemVerilog
.v/.sv/.vh   →  VPP  →  SV parser  →  SystemVerilog
```

- **VPP** (Verilog PreProcessor): `` `ifdef ``, `` `ifndef ``, `` `if ``, `` `let ``, `` `for ``, `` `while ``, `` `switch ``
- **MPP** (MetaHDL PreProcessor): `` `define ``, `` `foreach ``, `` `elsif ``, arithmetic functions
- **MHDL parser**: MetaHDL-specific constructs (ff, fsm, generate, metahdl control)
- **SV parser**: SystemVerilog module parsing with dependency resolution

## Building

```bash
cd mhdlc/src
make -j$(nproc)
```

Requires: `g++`, `flex`, `bison` (3.8+)

## Usage

```bash
# Compile a MetaHDL file
./mhdlc/src/mhdlc -mb <macro_dir> -o <output_dir> <input.mhdl>

# Compile a Verilog/SystemVerilog file
./mhdlc/src/mhdlc -mb <macro_dir> -o <output_dir> <input.v>

# Options
#   -mb <dir>   Macro base directory (search path for source files)
#   -ib <dir>   IP base directory (search path for IP modules)
#   -o  <dir>   Output directory for generated SV files
```

## Testing

```bash
cd mhdlc/test
make test
```

This runs the comprehensive test suite (6 tests):

| Test | File | Parser |
|------|------|--------|
| VPP preprocessor | `test_vpp.vh` | SV |
| SV parser | `test_sv_module.v` | SV |
| MHDL parser | `test_mh_basic.mhdl` | MHDL |
| MPP preprocessor | `test_mpp.mhdl` | MHDL |
| IP module (packed 2D) | `one_hot_mux_2d.v` | SV |
| Unpacked array ports | `test_unpacked_array.v` | SV |

Individual targets: `make test_vpp`, `make test_sv`, `make test_mhdl`, `make test_mpp`, `make test_ip`, `make test_unpacked`

## MetaHDL Language Features

### Metahdl Control

```systemverilog
metahdl + portchk;           // Enable port checking
metahdl modname = my_module; // Set module name
metahdl clock = clk;         // Set default clock
metahdl reset = rst_n;       // Set default reset
```

### FF Blocks

```systemverilog
ff clk, rst_n;
    counter, counter + 1, 8'd0;
endff
```

### FSM Blocks

```systemverilog
fsm ctrl_fsm;
    output_sig = 1'b0;
    IDLE: begin
        if (start) goto RUN;
    end
    RUN: begin
        output_sig = 1'b1;
        goto IDLE;
    end
endfsm
```

### Generate Blocks

```systemverilog
generate
    for (i = 0; i < 4; i = i + 1)
        assign out[i*8 +: 8] = in[i*8 +: 8];
endgenerate
```

### Port Declarations (both styles supported)

```systemverilog
// SystemVerilog packed dimensions
input wire [CNT-1:0][WIDTH-1:0] din;

// Verilog unpacked array
input [WIDTH-1:0] din [CNT-1:0];
```

## Documentation

Full documentation is in `mhdlc/doc/tex/`. Build with:

```bash
cd mhdlc/doc/tex
make
```

## License

See individual source files for license information.
