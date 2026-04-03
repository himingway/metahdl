// test_sv_module.v
// SystemVerilog Parser Input Test
//
// Grammar features tested (per svparser.y):
//
// MODULE DEFINITIONS (lines 382-432):
//   - Module with ANSI port declarations (line 389)
//   - Module with parameter port list (lines 403-416)
//   - Module without IO / no port list (lines 418-432)
//
// PORT DECLARATIONS (non-ANSI, lines 863-949):
//   - port_direction: input, output, inout, nonport (line 965)
//   - var_type_opt: reg, wire, logic (lines 847-851)
//   - Simple port declarations (line 864)
//   - Range-declared ports (line 882)
//   - 2D range-declared ports (line 912)
//
// ANSI PORT DECLARATIONS (lines 767-844):
//   - port_direction var_type_opt net_name (line 767)
//   - With range [expr:expr] (line 782)
//   - 2D with range (line 810)
//
// PARAMETER DECLARATIONS (lines 974-1031):
//   - parameter + parameter_assignment
//   - localparam
//   - parameter reg type
//   - parameter with range [expr:expr]
//
// BODY (lines 444-451):
//   - Only port_declaration, parameter_declaration, `line accepted
//   NOTE: wire/reg/logic/var declarations, assign, always_comb
//   are COMMENTED OUT in the grammar.
//
// EXPRESSIONS (lines 573-733):
//   - Binary: +, -, *, /, %, **, <<, >>
//   - Conditional: ||, &&, ==, !=, <, >, <=, >=
//   - Unary: ~, !, |, &, ^
//   - Ternary: ? :
//   - $clog2, concatenation, duplication concatenation
//   - Function calls

// ============================================================================
// Module with parameter ports + ANSI port declarations
// tests: module_def variant 2 (line 403: module ID #(params) (ports); body)
//        ansi_port_declaration with range (line 782)
//        parameter_assignment with expressions (lines 994)
// ============================================================================
module alu_core #(
    parameter WIDTH = 32,
    parameter ADDR_W = 16
) (
    input wire clk,
    input wire rst_n,
    input wire [WIDTH-1:0] operand_a,
    input wire [WIDTH-1:0] operand_b,
    output reg [WIDTH-1:0] alu_result,
    output reg carry_out,
    inout wire control_line,
    input wire enable
);

    // Parameter declarations in body
    parameter MAX_DELAY = 100;
    localparam IDLE_OP = 4'b0000;
    localparam MASK_ALL = {WIDTH{1'b1}};
    localparam LOG2_WIDTH = $clog2(WIDTH);
    parameter reg RESET_PATTERN = 32'hDEADBEEF;

    // Non-ANSI port declarations in body (svparser.y: port_declaration)
    input wire overflow_flag;
    output wire [WIDTH/2-1:0] half_result;
    nonport internal_busy;

    // Variable-type ports (var_type_opt: reg/wire/logic)
    input wire [ADDR_W+WIDTH-1:0] extended_addr;

    // line directive
    `line 70 "test_sv_module.v"

endmodule


// ============================================================================
// Module with no ports at all
// tests: module_def variant 3 (line 418: module ID; body endmodule)
// ============================================================================
module empty_module;

    parameter COUNT = 42;
    localparam LABEL = "test";

    parameter SIZE = 8;

    `line 90 "test_sv_module.v"

endmodule


// ============================================================================
// Module with non-ANSI legacy-style port definitions
// tests: module_def variant 1 (line 389: module ID (ports); body)
//        net_names (multiple names comma-separated)
//        parameter with range [msb:lsb] ID = expression (line 1013)
// ============================================================================
module legacy_mux (
    sel_a, sel_b, data_in, data_out, ctrl_sig, status
);

    // Non-ANSI port declarations with var_type_opt
    input wire sel_a, sel_b;
    input wire [15:0] data_in;
    output reg data_out;
    inout wire ctrl_sig;
    output wire [7:0] status;

    // Parameter declarations with range syntax
    parameter [31:0] DELAY = 32'h0000_0005;
    localparam THRESHOLD = 128;

    `line 108 "test_sv_module.v"

endmodule


// ============================================================================
// Module with 2D port declarations
// tests: 2D ansi_port_declaration (line 810: port_dir var_type [e:e][e:e] name)
//        2D non-ANSI port_declaration (line 912)
// ============================================================================
module matrix_op #(
    parameter ROWS = 4,
    parameter COLS = 4
) (
    input wire [COLS-1:0][31:0] matrix_a,
    input wire [COLS-1:0][31:0] matrix_b,
    output reg [COLS-1:0][31:0] matrix_out,
    input wire start_op
);

    parameter SCALE_FACTOR = 2;
    localparam ZERO = 32'd0;

    // 2D non-ANSI port declaration
    input wire [7:0][15:0] config_matrix;

    `line 125 "test_sv_module.v"

endmodule


// ============================================================================
// Module with complex expressions in port ranges and params
// tests: expression variants used in port widths and parameter values
// ============================================================================
module expr_test #(
    parameter BASE = 10,
    parameter SHIFT = 2,
    parameter WIDTH = BASE << SHIFT
) (
    input wire clk,
    input wire [(BASE * 2) - 1:0] data_in,
    output reg data_out
);

    // Expression-based parameters
    parameter HALF_W = WIDTH / 2;
    localparam MASK = (1 << WIDTH) - 1;
    parameter [3:0] NIBBLE = 4'hF;

    `line 148 "test_sv_module.v"

endmodule
