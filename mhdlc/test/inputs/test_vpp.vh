// ============================================================================
// test_vpp.vh - VPP Preprocessor Input Test
// ============================================================================
// VPP Grammar features tested (per vpp.y + vpp.l):
//
// `define MACROS (vpp.l lines 259-293):
//   - Object macro: `define NAME definition
//   - Function-like macro: `define NAME(params) body
//   - Macros stored in Defines_Table and expanded by lexer
//
// `ifdef/`endif CONDITIONALS (vpp.y lines 420-499):
//   - ifdef_declaration: TTIFDEF expression
//   - if_declaration: TTIF expression
//   - else_declaration: TTELSE
//   - endif_declaration: TTENDIF
//
// `let ASSIGNMENTS (vpp.y lines 510-529):
//   - TTLET identifier '=' expression
//   - Creates variables in head_variable_list
//
// ARITHMETIC EXPRESSIONS (vpp.y lines 535-586):
//   - Unary: +, -, !, ~, &, |, ^, TTL_NAND, TTL_NOR, TTL_XNOR
//   - Binary: +, -, *, /, %, ==, !=, &&, ||, <, <=, >, >=
//             &, |, ^, TTL_SHIFTR, TTL_SHIFTL, TT_POWER
//   - Functions: LOG2, ROUND, CEIL, FLOOR, MAX, MIN, ABS
//                EVEN, ODD, STOI, ITOS, SUBSTR, SYSTEM
//   - Primary: TTNUM, TTREALNUM, TTNAME, TTQS (quoted string)
//
// `for/`endfor LOOPS (vpp.y lines 319-371):
//   - TTFOR '(' identifier '=' expression ';' expression ';'
//             identifier '=' expression ')'
//
// `while/`endwhile LOOPS (vpp.y lines 302-400)
//
// `switch/`case/`endswitch (vpp.y lines 190-300)
//   - switch_declaration, case_declaration, endswitch_declaration
//   - breaksw_declaration, default_declaration

// ============================================================================
// 1. `define macros (object and function-like)
// ============================================================================
`define WIDTH 32
`define CLOCK_FREQ 100000000

// ============================================================================
// 2. `ifdef / `endif conditionals
// ============================================================================
`ifdef DEBUG
parameter SIM_LEVEL = 5;
`endif

`ifndef RELEASE
parameter DEBUG_FLAG = 1;
`else
parameter RELEASE_FLAG = 1;
`endif

// ============================================================================
// 3. `if conditionals
// ============================================================================
`if WIDTH > 16
parameter EXTENDED = 1;
`else
parameter EXTENDED = 0;
`endif

// ============================================================================
// 4. `let assignments
// ============================================================================
`let counter = 0
`let threshold = 128
`let half_width = WIDTH / 2

// ============================================================================
// 5. Arithmetic expressions (within `if and `let)
// ============================================================================
// Binary: +, -, *, /, %
`if counter + threshold > 100
parameter OVER_LIMIT = 1;
`endif

// Shift operators: >>, <<
`if 32 >> 4 == 2
parameter SHIFT_OK = 1;
`endif

// Power operator: **
`if 2 ** 8 == 256
parameter POWER_OK = 1;
`endif

// Logical operators: &&, ||
`if 5 > 3 && 10 < 20
parameter AND_OK = 1;
`endif

`if 0 || (1 && 1)
parameter LOGIC_OK = 1;
`endif

// Bitwise: &, |, ^
`if 0xFF & 0x0F
parameter BAND_OK = 1;
`endif

// Unary: ~, !
`if !(0)
parameter NOT_OK = 1;
`endif

// Ternary operator (within `let)
`let ternary_val = 10 > 5 ? 100 : 0

// Parenthesized expressions
`let grouped = ((1 + 2) * 3) - 4

// Compound expression with multiple operators
`let complex = 100 / 10 + 3 * 4 - 2

// ============================================================================
// 6. Built-in math functions
// ============================================================================
`if LOG2(256) == 8
parameter LOG2_OK = 1;
`endif

`let rounded = ROUND(3.7)
`let ceiled = CEIL(4.1)
`let floored = FLOOR(4.9)

`let max_val = MAX(42, 100)
`let min_val = MIN(42, 100)
`let abs_val = ABS(-99)

`let even_val = EVEN(8)
`let odd_val = ODD(7)

// String conversion functions
`let hex_str = HEX(255)
`let dec_str = DEC(100)

// ============================================================================
// 7. `for loop
// ============================================================================
`for (i = 0; i < WIDTH; i = i + 1)
wire bit_`i;
`endfor

// ============================================================================
// 8. `while loop
// ============================================================================
`let counter = 0
`while (counter < threshold)
cycle_`counter;
`endwhile

// ============================================================================
// 9. `switch / `case / `endswitch
// ============================================================================
`switch WIDTH
`case 8
type BYTE_TYPE
`case 16
type WORD_TYPE
`case 32
type DWORD_TYPE
`default
type GENERIC_TYPE
`endswitch

// ============================================================================
// 10. `breaksw
// ============================================================================
`switch half_width
`case 4
value_four
`breaksw
`case 8
value_eight
`breaksw
`endswitch

// ============================================================================
// 11. Post-increment/decrement (expanded by lexer to name = name +/- 1)
// ============================================================================
counter++
counter--

// ============================================================================
// 12. Quoted strings, real numbers, plain numbers (primary expressions)
// ============================================================================
`let filename = "test_file.txt"
`let pi = 3.14159
`let plain = 42
