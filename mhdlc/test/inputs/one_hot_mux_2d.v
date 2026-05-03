// one_hot_mux_2d - One-hot multiplexer with 2D packed arrays
// Original used unpacked arrays (din [CNT-1:0]) which the SV parser
// doesn't support. Converted to packed dimensions.
module one_hot_mux_2d
  (
   din,
   sel,
   dout,
   err
   );

   parameter WIDTH         = 32;
   parameter CNT           = 5;
   parameter ONE_HOT_CHECK = 0;

   // Packed 2D: [CNT-1:0][WIDTH-1:0] instead of unpacked din [CNT-1:0]
   input wire [CNT-1:0][WIDTH-1:0]  din;
   input wire [CNT-1:0]             sel;
   output reg [WIDTH-1:0]           dout;
   output reg                       err;

   wire [CNT-1:0][WIDTH-1:0]        data_2d;
   wire [WIDTH-1:0][CNT-1:0]        data_2d_t;

   genvar                            cnt, w;

   // Select: zero out unselected inputs
   generate
      for (cnt = 0; cnt < CNT; cnt = cnt + 1)
        assign data_2d[cnt] = sel[cnt] ? din[cnt] : {WIDTH{1'b0}};
   endgenerate

   // Transpose: swap packed dimensions
   generate
      for (cnt = 0; cnt < CNT; cnt = cnt + 1) begin: xpose_outer
         for (w = 0; w < WIDTH; w = w + 1) begin: xpose_inner
            assign data_2d_t[w][cnt] = data_2d[cnt][w];
         end
      end
   endgenerate

   // OR-reduce across selected inputs
   generate
      for (w = 0; w < WIDTH; w = w + 1)
        assign dout[w] = |data_2d_t[w];
   endgenerate

   // Optional one-hot check
   generate
      if (ONE_HOT_CHECK) begin: hotchk
         wire [WIDTH-1:0] sel_m1, sel_msk;

         assign sel_m1  = sel - 1'b1;
         assign sel_msk = ~(sel_m1 ^ sel);
         assign err     = |(sel_msk & sel);
      end
      else begin: nochk
         assign err = 1'b0;
      end
   endgenerate

endmodule
