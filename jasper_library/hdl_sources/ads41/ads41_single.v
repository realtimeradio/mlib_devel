`timescale 1ns / 1ps

module ads41_single #(
    parameter NBITS=12,
    parameter IDELAY_VALUE = 8,
    parameter FLIP_PN = 16'b0
  )(
    // External controls
    input rst,
    input clk,     // FIFO read clock
    input enable,  // FIFO wr enable
    // IDELAY controls
    input idelay_clk,
    input [31:0] idelay_val,
    input [15:0] idelay_ctrl,
    // ADC DATA INTERFACE
    // Line clock from ADC
    input dclk_p,
    input dclk_n,
    // Overrange from ADC
    input ovr,
    // Parallel data from ADC. Even bits on rising dclk edge, odd on falling
    input [NBITS/2-1:0] d_p,
    input [NBITS/2-1:0] d_n,
    // Clock out to user
    output dclk_out,
    // Overrange to user logic
    output ovr_out,
    // Data to user logic
    output [NBITS-1:0] d_out
  );
  
  // Buffer the differential inputs
  wire dclk_buf, ovr_buf;
  wire [NBITS/2-1:0] d_buf;

  IBUFDS ibufds_inst [NBITS/2 + 1 - 1:0] (
    .I ({dclk_p, d_p}),
    .IB({dclk_n, d_n}),
    .O({dclk_buf, d_buf})
  );

  IBUF ibuf_inst (
    .I(ovr),
    .O(ovr_buf)
  );
  
  // IDELAYS on data and OVR
  wire ovr_delayed;
  wire [NBITS/2-1:0] d_delayed;
  
  reg [15:0] idelay_ctrl_reg = 0;
  wire [15:0] idelay_ctrl_strobe = idelay_ctrl & ~idelay_ctrl_reg; // posedge. Was 0, now 1
  always @(posedge idelay_clk) begin
    idelay_ctrl_reg <= idelay_ctrl;
  end
  
  IDELAYE2 #(
    .IDELAY_TYPE("VARIABLE"),
    .DELAY_SRC("IDATAIN"),
    .IDELAY_VALUE(IDELAY_VALUE),
    .SIGNAL_PATTERN("DATA")
  ) idelay_inst [1 + NBITS/2 - 1: 0] (
    .C(idelay_clk),
    .LD(rst),
    .CE(idelay_ctrl_strobe[1+NBITS/2-1:0]),
    .INC(idelay_val[1+NBITS/2-1:0]),
    .IDATAIN({ovr_buf, d_buf}),
    .DATAOUT({ovr_delayed, d_delayed})
  );
  
  wire dclk_bufr;

  BUFR clk_buf_inst (
    .I(dclk_buf),
    .O(dclk_bufr)
  );
  
  // Register / De-interleave the DDR streams
  reg ovr_reg; // Not time aligned with data
  always @(posedge dclk_bufr) begin
    ovr_reg <= ovr_delayed;
  end

  wire [NBITS/2-1:0] d_rise, d_fall; // seperate rising/falling DDR words
  wire [NBITS-1:0] d_int; // Assembled NBIT-wide word
  
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE")
  ) data_iddr_inst [NBITS/2 - 1 : 0] (
    .C(dclk_bufr),
    .CE(1'b1),
    .D(d_delayed),
    .R(1'b0),
    .S(1'b0),
    .Q1(d_rise),
    .Q2(d_fall)
  );

  genvar i;
  generate
  for (i=0; i<NBITS/2; i=i+1) begin : bit_assemble
    assign d_int[2*i]   = FLIP_PN[i] ? ~d_fall[i] : d_fall[i];
    assign d_int[2*i+1] = FLIP_PN[i] ? ~d_rise[i] : d_rise[i];
  end
  endgenerate
  
  wire fifo_empty;
  reg [16-NBITS-1-1:0] paddingi = 0;
  wire [16-NBITS-1-1:0] paddingo;
  
  fifo_16x32 fifo_inst (
    .rst(rst),
    .wr_clk(dclk_bufr),
    .rd_clk(clk),
    .din({paddingi, ovr_reg, d_int}),
    .wr_en(enable),
    .rd_en(~fifo_empty),
    .dout({paddingo, ovr_out, d_out}),
    .full(),
    .empty(),
    .prog_empty(fifo_empty)
  );
  
  assign dclk_out = dclk_bufr;
endmodule
