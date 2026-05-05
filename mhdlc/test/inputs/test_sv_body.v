// Test: SV parser tolerance of arbitrary body content
// The parser should extract the module interface even with complex body.
module sv_with_body #(
    parameter WIDTH = 32,
    parameter DEPTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);

    // wire declarations — should be skipped by lexer
    wire [WIDTH-1:0] internal_bus;
    wire valid_flag;
    wire [DEPTH-1:0] count_wire;

    // assign statements — should be skipped
    assign valid_flag = (data_in != 0);
    assign internal_bus = data_in ^ {WIDTH{rst_n}};

    // reg declarations — should be skipped
    reg [WIDTH-1:0] storage_reg;
    reg [DEPTH-1:0] counter;

    // always_ff block — should be skipped
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            storage_reg <= 0;
        end else begin
            counter <= counter + 1;
            storage_reg <= data_in;
        end
    end

    // always_comb block — should be skipped
    always_comb begin
        data_out = storage_reg & internal_bus;
    end

    // generate block — should be skipped
    genvar i;
    generate
        for (i = 0; i < DEPTH; i = i + 1) begin : gen_delay
            assign count_wire[i] = counter[i];
        end
    endgenerate

    // localparam in body — should be parsed
    localparam MAX_COUNT = DEPTH - 1;

    // function — should be skipped by sc_function state
    function automatic [WIDTH-1:0] reverse_bits;
        input [WIDTH-1:0] bits_in;
        integer j;
        begin
            reverse_bits = 0;
            for (j = 0; j < WIDTH; j = j + 1)
                reverse_bits[WIDTH-1-j] = bits_in[j];
        end
    endfunction

    // task — should be skipped by sc_task state
    task reset_all;
        begin
            counter = 0;
            storage_reg = 0;
        end
    endtask

endmodule
