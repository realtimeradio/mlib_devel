`timescale 1ns / 1ps

/*
 * Convert triplets of 128-bit data streams
 * to ADC sample streams.
 *
 * Inputs:
 * din[3*INPUT_WIDTH-1:0] : 3 concatenated, deformatted streams
 *                          From MSBs to LSBs these should be
 *                          "top", "middle", and "bottom".
 *                          Earliest samples in MSBs
 * is_three_bit : 1 if the input data should be interpretted as 3-bit, 0 for 8-bit
 *
 * Outputs:
 * dout[3*INPUT_WIDTH-1:0] : Sample streams, with earliest sample in MSBs.
 *                           
 *                           In 3-bit mode, words are constructed by interleaving
 *                           "top", "middle", and "bottom" streams bitwise.
 *                           "top" -> MSB, "bottom" -> LSB.
 *                           
 *                           In 8-bit mode, the MSBs represent the samples from the
 *                           "top" stream, cast (by left shift) to 12-bits.
 *                           The LSBs repressent the samples from the "middle" stream,
 *                           cast to 12-bits. This cast means the output data rate of
 *                           both 3- and 8-bit modes is kept consistent.                            
 */                            

module dts_build_samples #(
    INPUT_WIDTH = 128
  ) (
    input is_three_bit,
    input [3*INPUT_WIDTH-1 : 0] din,
    output [3*INPUT_WIDTH-1 : 0] dout
  );

  wire [INPUT_WIDTH-1:0] din_b = din[1*INPUT_WIDTH-1:0*INPUT_WIDTH]; // bottom
  wire [INPUT_WIDTH-1:0] din_m = din[2*INPUT_WIDTH-1:1*INPUT_WIDTH]; // middle
  wire [INPUT_WIDTH-1:0] din_t = din[3*INPUT_WIDTH-1:2*INPUT_WIDTH]; // top

  wire [3*INPUT_WIDTH-1:0] dout_3bit;
  wire [3*INPUT_WIDTH-1:0] dout_12bit;

  // Generate 3-bit output.
  // Interleave bits from 3 streams
  generate
  for (genvar i=0; i<INPUT_WIDTH; i=i+1) begin
    assign dout_3bit[(i+1)*3 - 1] = din_t[i]; // output MSBs
    assign dout_3bit[(i+1)*3 - 2] = din_m[i];
    assign dout_3bit[(i+1)*3 - 3] = din_b[i]; // output LSBs
  end
  endgenerate
  
  // Generate 8-bit output (cast to 12 bits).
  // Interleave words from top and bottom streams
  // Assume that the oldest word is in the "top" stream.
  localparam INPUT_NWORDS = (INPUT_WIDTH >> 3);
  generate
  for (genvar i=0; i<INPUT_NWORDS; i=i+1) begin
    assign dout_12bit[(2*(i+1))*12   - 1     -: 8] = din_t[(i+1)*8-1:i*8]; // Output MSBs
    assign dout_12bit[(2*(i+1))*12   - 1 - 8 -: 4] = 4'b0;
    assign dout_12bit[(2*(i+1)-1)*12 - 1     -: 8] = din_b[(i+1)*8-1:i*8];
    assign dout_12bit[(2*(i+1)-1)*12 - 1 - 8 -: 4] = 4'b0;                 // Output LSBs
  end
  endgenerate

  assign dout = is_three_bit ? dout_3bit : dout_12bit;


endmodule
