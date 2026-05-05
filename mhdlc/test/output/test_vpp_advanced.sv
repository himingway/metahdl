module test_vpp_advanced (
  clk, 
  data_in, 
  data_out, 
  enable, 
  rst_n);

parameter DEBUG_FLAG = 1;
parameter WIDE_BUS = 1;
parameter GT_OK = 1;
parameter EQ_OK = 1;
parameter NE_OK = 1;

input             clk;
input   [31  :0]  data_in;
output  [31  :0]  data_out;
output            enable;
input             rst_n;

wire              bit_0;
wire              bit_1;
wire              bit_2;
wire              bit_3;
wire              bit_4;
wire              bit_5;
wire              bit_6;
wire              bit_7;
wire              clk;
wire    [31  :0]  data_in;
wire    [31  :0]  data_out;
wire              enable;
wire              loop_0;
wire              loop_1;
wire              loop_2;
wire              loop_3;
logic             rst_n;
wire              wide_bus;
wire              word_bus;

assign enable = rst_n;

endmodule
