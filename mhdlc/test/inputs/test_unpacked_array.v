// test_unpacked_array.v - Test Verilog unpacked array port syntax
// Tests: input [WIDTH-1:0] din [CNT-1:0]
module test_unpacked (
    din,
    sel,
    dout
);

    parameter WIDTH = 8;
    parameter CNT   = 4;

    // Verilog-style unpacked array port: packed range before name, unpacked after
    input [WIDTH-1:0]  din [CNT-1:0];
    input [CNT-1:0]    sel;
    output [WIDTH-1:0] dout;

    wire [WIDTH-1:0]   din [CNT-1:0];
    wire [CNT-1:0]     sel;
    wire [WIDTH-1:0]   dout;

    // Simple mux using unpacked array
    assign dout = din[sel[1:0]];

endmodule
