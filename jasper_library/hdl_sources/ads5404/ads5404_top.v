module ads5404_top #(
    parameter NBITS=12
 )(
    // ADC CONTROL INTERFACE
    // Control signals from user logic
    // (on clkout domain)
    input user_rst,
    input user_sync,
    input user_enable,
    output pll_locked,
    // Control signals to ADC chip
    output sync_p,
    output sync_n,
    output sreset,
    output enable,

    // ADC DATA INTERFACE
    // Line clocks from ADC
    // Each ADC has an independent output clock, but we use only one
    // (disable the other via software for power savings)
    input daclk_p,
    input daclk_n,
    // Sync from ADC
    input syncout_p,
    input syncout_n,
    // Overrange from each ADC
    input ovra_p,
    input ovra_n,
    input ovrb_p,
    input ovrb_n,
    // Parallel data from ADC
    input [NBITS-1:0] da_p;
    input [NBITS-1:0] da_n;
    input [NBITS-1:0] db_p;
    input [NBITS-1:0] db_n;
    // Clock out to user
    output clkout;
    // Sync to user logic
    output syncout_0;
    output syncout_1;
    // Overrange to user logic
    output ovra_0;
    output ovra_1;
    output ovrb_0;
    output ovrb_1;
    // Data to user logic
    output [NBITS-1:0] da_0;
    output [NBITS-1:0] da_1;
    output [NBITS-1:0] db_0;
    output [NBITS-1:0] db_1
  );

  // Control signals
  assign sreset = ~user_rst; // ADC reset is active low
  assign enable = user_enable;
  OBUFDS obuf_sync_inst (
    .I(user_sync),
    .O(sync_p),
    .OB(sync_n)
  );
  

  // Buffer the differential inputs
  wire daclk, ovra, ovrb, syncout;
  wire [NBITS-1:0] da;
  wire [NBITS-1:0] dp;

  IBUFDS ibuf_inst [4 + 2*NBITS - 1:0] (
    .I ({daclk_p, ovra_p, ovrb_p, syncout_p, da_p, db_p),
    .IB({daclk_n, ovra_n, ovrb_n, syncout_n, da_n, db_n),
    .O({daclk, ovra, ovrb, syncout, da, db)
  );

  // Put the clock in a clock net and (TODO) generate other clock phases
  wire adc_clk;
  assign clkout = adc_clk;
  wire adc_clk_mmcm;
  wire pll_feedback_clk;
  PLLE2_BASE#(
    .BANDWIDTH("OPTIMIZED"),
    .DIVCLK_DIVIDE(2),
    .CLKFBOUT_MULT(2),
    .CLKIN1_PERIOD(2.000)
  ) mmcm_inst (
    .CLKIN1(daclk),
    .RST(user_rst),
    .PWRDWN(1'b0),
    .CLKFBIN(pll_feedback_clk),
    .CLKFBOUT(pll_feedback_clk),
    .CLKOUT0(adc_clk_mmcm),
    .LOCKED(pll_locked)
  );

  BUFG clk_buf_inst (
    .I(adc_clk_mmcm),
    .O(adc_clk)
  );


  // De-interleave the DDR streams
  wire ovra_0, ovrb_0, syncout_0;
  wire [NBITS-1:0] da_0;
  wire [NBITS-1:0] dp_0;
  wire ovra_1, ovrb_1, syncout_1;
  wire [NBITS-1:0] da_1;
  wire [NBITS-1:0] dp_1;

  IDDRE1 #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
  ) data_iddr_inst [3 + 2*NBITS - 1 : 0] (
    .C(adc_clk),
    .CB(~adc_clk),
    .D({ovra, ovrb, syncout, da, db}),
    .R(user_rst),
    .Q1({ovra_0, ovrb_0, syncout_0, da_0, db_0}),
    .Q2({ovra_1, ovrb_1, syncout_1, da_1, db_1})
  );

endmodule
