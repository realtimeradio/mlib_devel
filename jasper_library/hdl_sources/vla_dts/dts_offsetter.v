`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 06:12:20 PM
// Design Name: 
// Module Name: dts_align
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// Align multiple DTS streams, using the "sync" output of the DTS deformatter
//////////////////////////////////////////////////////////////////////////////////


module dts_offsetter #(
    parameter MUX_FACTOR_BITS=0
  ) (
    input clk_in,
    input clk_out,
    input rst,
    input [127:0] din,
    //input din_locked,
    input din_one_sec,
    input din_ten_sec,
    input din_index,
    input din_sync,
       
    input advance,
    input delay,
    output almost_full,
    output almost_empty,
    output overflow,
    output underflow,
    output [7:0] overflow_cnt,
    output [7:0] underflow_cnt,
    
    output [(128>>MUX_FACTOR_BITS)-1:0] dout,
    //output dout_locked,
    output dout_one_sec,
    output dout_ten_sec,
    output dout_index,
    output dout_sync
  );
  localparam MUX_FACTOR = (1<<MUX_FACTOR_BITS);
  localparam MID_FIFO_DEPTH = 32 * MUX_FACTOR;
  
  
  /* Detect positive edges of the advance/delay lines */
  // Advances slip a write
  reg advanceR;
  wire advance_strobe = advance & ~advanceR;
  always @(posedge clk_in) begin
    advanceR <= advance;
  end
  wire fifo_wr_en = ~advance_strobe;

  // Delays slip 128 bits of read
  reg delayR;
  wire delay_strobe = delay & ~delayR;
  always @(posedge clk_out) begin
    delayR <= delay;
  end
  wire fifo_rd_en;

  generate
  if (MUX_FACTOR > 1) begin
    // Shift register for extending the delay strobe, since we potentially read
    // 128-bit data out of the FIFO in multiple words
    reg [MUX_FACTOR-1:0] delay_strobe_sr = {MUX_FACTOR{1'b0}};
    always @(posedge clk_out) begin
      delay_strobe_sr <= {delay_strobe_sr[MUX_FACTOR-2:0], delay_strobe}; 
    end
    assign fifo_rd_en = delay_strobe_sr == {MUX_FACTOR{1'b0}};
  end else begin
    assign fifo_rd_en = ~delay_strobe;
  end
  endgenerate
  
  /* 
   * After a reset, release the FIFO read enable reset after 16 clocks,
   * so that the FIFO is half full.
   */
  reg rd_block;
  (* async_reg = "true" *) reg rst_wr_clk;
  (* async_reg = "true" *) reg rst_wr_clkR;
  reg [15:0] rst_ctr = 16'b0;
  always @(posedge clk_out) begin
    rst_wr_clk <= rst;
    rst_wr_clkR <= rst_wr_clk;
    if (rst_wr_clkR) begin
      rd_block <= 1'b1;
      rst_ctr <= MID_FIFO_DEPTH;
    end else begin
      if (rd_block && (rst_ctr == 16'b0)) begin
        rd_block <= 1'b0;
      end else begin
        rst_ctr <= rst_ctr - 1'b1;
      end
    end
  end
  
  wire [144-1:0] fifo_din;
  wire [(16>>MUX_FACTOR_BITS)*9 - 1:0] fifo_dout;

  generate
  if (MUX_FACTOR_BITS == 0) begin
    assign fifo_din = {12'b0, din_one_sec, din_ten_sec, din_index, din_sync, din};
    assign dout_one_sec = fifo_dout[131];
    assign dout_ten_sec = fifo_dout[130];
    assign dout_index   = fifo_dout[129];
    assign dout_sync    = fifo_dout[128];
    assign dout         = fifo_dout[127:0];
  end else if (MUX_FACTOR_BITS == 1) begin
    assign fifo_din = {4'b0, din_one_sec, din_ten_sec, din_index, din_sync, din[127:64],
                       4'b0, din_one_sec, din_ten_sec, din_index, din_sync, din[63:0]};
    assign dout_one_sec = fifo_dout[67];
    assign dout_ten_sec = fifo_dout[66];
    assign dout_index   = fifo_dout[65];
    assign dout_sync    = fifo_dout[64];
    assign dout         = fifo_dout[63:0];
  end else if (MUX_FACTOR_BITS == 2) begin
    assign fifo_din = {din_one_sec, din_ten_sec, din_index, din_sync, din[127:96],
                       din_one_sec, din_ten_sec, din_index, din_sync, din[95:64],
                       din_one_sec, din_ten_sec, din_index, din_sync, din[63:32],
                       din_one_sec, din_ten_sec, din_index, din_sync, din[31:0]};
    assign dout_one_sec = fifo_dout[35];
    assign dout_ten_sec = fifo_dout[34];
    assign dout_index   = fifo_dout[33];
    assign dout_sync    = fifo_dout[32];
    assign dout         = fifo_dout[31:0];
  end
  endgenerate 

  dts_offset_fifo dts_offset_fifo_inst (
    .rst(rst),
    // Write side
    .wr_clk(clk_in),
    .almost_full(almost_full),
    .overflow(overflow),
    .din(fifo_din),
    .wr_en(fifo_wr_en),
    .full(),
    // Read side
    .rd_clk(clk_out),
    .almost_empty(almost_empty),
    .underflow(underflow),
    .dout(fifo_dout),
    .rd_en(fifo_rd_en & ~rd_block),
    .empty()
  );

  reg [7:0] overflow_cnt_reg;
  reg [7:0] underflow_cnt_reg;
  assign overflow_cnt = overflow_cnt_reg;
  assign underflow_cnt = underflow_cnt_reg;
  always @(posedge clk_in) begin
    if (rst) begin
      overflow_cnt_reg <= 8'b0;
    end else begin
      if (overflow) begin
        overflow_cnt_reg <= overflow_cnt_reg + 1'b1;
      end
    end
  end

  always @(posedge clk_out) begin
    if (rst) begin
      underflow_cnt_reg <= 8'b0;
    end else begin
      if (underflow) begin
        underflow_cnt_reg <= underflow_cnt_reg + 1'b1;
      end
    end
  end
  
endmodule
