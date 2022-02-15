`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2022 12:15:04 PM
// Design Name: 
// Module Name: ads5404_single
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
//////////////////////////////////////////////////////////////////////////////////


module ads5404_single #(
    parameter NBITS=12,
    parameter USE_SYNC = 1'b0,
    parameter IDELAY_VALUE = 8
  )(
    // External controls
    input rst,
    input clk,
    input enable,
    // IDELAY controls
    input idelay_clk,
    input [31:0] idelay_val,
    input [15:0] idelay_ctrl,
    // ADC DATA INTERFACE
    // Line clock from ADC
    input dclk_p,
    input dclk_n,
    // Overrange from each ADC
    input ovr_p,
    input ovr_n,
    // Sync pin from ADC
    input syncout_p,
    input syncout_n,
    // Parallel data from ADC
    input [NBITS-1:0] d_p,
    input [NBITS-1:0] d_n,
    // Sync output
    output syncout_0,
    output syncout_1,
    // Clock out to user
    output dclk_out,
    // Overrange to user logic
    output ovr_0,
    output ovr_1,
    // Data to user logic
    output [NBITS-1:0] d_0,
    output [NBITS-1:0] d_1
  );
  
  // Buffer the differential inputs
  wire dclk, ovr;
  wire [NBITS-1:0] d;
  wire dclk_bufr;

  IBUFDS ibuf_inst [2 + NBITS - 1:0] (
    .I ({dclk_p, ovr_p, d_p}),
    .IB({dclk_n, ovr_n, d_n}),
    .O({dclk, ovr, d})
  );
  
  wire ovr_delayed;
  wire [NBITS-1:0] d_delayed;
  
  IDELAYE2 #(
    .IDELAY_TYPE("VAR_LOAD"),
    .DELAY_SRC("IDATAIN"),
    .IDELAY_VALUE(IDELAY_VALUE),
    .SIGNAL_PATTERN("DATA")
  ) idelay_inst [1 + NBITS - 1: 0] (
    .C(idelay_clk),
    .CNTVALUEIN(idelay_val[4:0]),
    .LD(idelay_ctrl[1+NBITS-1:0]),
    .IDATAIN({ovr, d}),
    .DATAOUT({ovr_delayed, d_delayed})
  );
  
  BUFR clk_buf_inst (
    .I(dclk),
    .O(dclk_bufr)
  );
  
  wire [NBITS-1:0] d_0_int, d_1_int;
  wire syncout_0_int, syncout_1_int;
  wire ovr_0_int, ovr_1_int;
  
  generate
  if (USE_SYNC) begin : syncgen
    wire syncout;
    wire syncout_delayed;
    IBUFDS sync_ibuf_inst (
      .I (syncout_p),
      .IB(syncout_n),
      .O(syncout)
    );
    
    IDELAYE2 #(
      .IDELAY_TYPE("VAR_LOAD"),
      .DELAY_SRC("IDATAIN"),
      .IDELAY_VALUE(IDELAY_VALUE),
      .SIGNAL_PATTERN("DATA")
    ) idelay_sync_inst (
      .C(idelay_clk),
      .CNTVALUEIN(idelay_val[4:0]),
      .LD(idelay_ctrl[1+NBITS]),
      .IDATAIN(syncout),
      .DATAOUT(syncout_delayed)
    );
  
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
    ) sync_iddr_inst (
      .C(dclk_bufr),
      .CE(1'b1),
      .D(syncout_delayed),
      .R(1'b0),
      .S(1'b0),
      .Q1(syncout_0_int),
      .Q2(syncout_1_int)
    );  
  end else begin
    assign syncout_0_int = 1'b0;
    assign syncout_1_int = 1'b0;
  end
  endgenerate

  // De-interleave the DDR streams
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
  ) data_iddr_inst [1 + NBITS - 1 : 0] (
    .C(dclk_bufr),
    .CE(1'b1),
    .D({ovr_delayed, d_delayed}),
    .R(1'b0),
    .S(1'b0),
    .Q1({ovr_0_int, d_0_int}),
    .Q2({ovr_1_int, d_1_int})
  );
  
  wire fifo_empty;
  reg [36-(4+2*NBITS)-1:0] paddingi = 0;
  wire [36-(4+2*NBITS)-1:0] paddingo;
  
  fifo_36x128 fifo_inst (
    .rst(rst),
    .wr_clk(dclk_bufr),
    .rd_clk(clk),
    .din({paddingi, ovr_0_int, ovr_1_int, syncout_0_int, syncout_1_int, d_0_int, d_1_int}),
    .wr_en(enable),
    .rd_en(~fifo_empty),
    .dout({paddingo, ovr_0, ovr_1, syncout_0, syncout_1, d_0, d_1}),
    .full(),
    .empty(),
    .prog_empty(fifo_empty),
    .wr_rst_busy(),
    .rd_rst_busy()
  );
  
  assign dclk_out = dclk_bufr;
endmodule
