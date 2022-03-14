module ads41_top #(
    parameter NBITS=12,
    parameter PLLMULT=4,
    parameter CLKPERIOD=4.00
 )(
    // ADC CONTROL INTERFACE
    // Control signals from user logic
    // (on clkout domain)
    input user_rst,
    input user_sync,
    input user_enable,
    output pll_locked,
    // IDELAY controls
    input idelay_clk,
    input [31:0] idelay_val,
    input [31:0] idelay_ctrl,

    // ADC DATA INTERFACE
    // Line clock
    input dclk_p,
    input dclk_n,
    // Overrange from each ADC
    input ovr,
    // Parallel data from ADC
    input [NBITS/2-1:0] d_p,
    input [NBITS/2-1:0] d_n,
    // Clock out to user
    output clkout,
    // Overrange to user logic
    output ovrout,
    // Data to user logic
    output [NBITS-1:0] dout
  );

  // Buffer the differential inputs
  wire daclk, dbclk, adc_clk;
  wire syncout;
  
  // Pull user reset onto one of the local domains
  (* async_reg = "true" *) reg rst_daclk_unstable;
  (* async_reg = "true" *) reg rst_daclk_stable;
  (* async_reg = "true" *) reg fifo_we_daclk_unstable;
  (* async_reg = "true" *) reg fifo_we_daclk_stable;
  always @(posedge daclk) begin
    rst_daclk_unstable <= user_rst;
    rst_daclk_stable <= rst_daclk_unstable;
    fifo_we_daclk_unstable <= pll_locked;
    fifo_we_daclk_stable <= fifo_we_daclk_unstable;
  end
  reg rst_daclk, rst_dbclk;
  reg fifo_we_daclk, fifo_we_dbclk;
  always @(posedge daclk) begin
    rst_daclk <= rst_daclk_stable;
    fifo_we_daclk <= fifo_we_daclk_stable;
  end
  always @(posedge dbclk) begin
    rst_dbclk <= rst_daclk_stable;
    fifo_we_dbclk <= fifo_we_daclk_stable;
  end
  

  ads41_single #(
    .NBITS(NBITS),
    .USE_SYNC(1'b1),
    .IDELAY_VALUE(8)
  ) ads41_a_inst (
    .rst(rst_daclk),
    .clk(adc_clk),
    .idelay_clk(idelay_clk),
    .idelay_val(idelay_val),
    .idelay_ctrl(idelay_ctrl[15:0]),
    .enable(fifo_we_daclk),
    .dclk_out(daclk),
    .dclk_p(daclk_p),
    .dclk_n(daclk_n),
    .ovr_p(ovra_p),
    .ovr_n(ovra_n),
    .syncout_p(syncout_p),
    .syncout_n(syncout_n),
    .d_p(da_p),
    .d_n(da_n),
    .ovr_0(ovra_0),
    .ovr_1(ovra_1),
    .syncout_0(sync_out_0),
    .syncout_1(sync_out_1),
    .d_0(da_0),
    .d_1(da_1)
  );
  
  ads41_single #(
    .NBITS(NBITS),
    .USE_SYNC(1'b0),
    .IDELAY_VALUE(11)
  ) ads41_b_inst (
    .rst(rst_dbclk),
    .clk(adc_clk),
    .idelay_clk(idelay_clk),
    .idelay_val(idelay_val),
    .idelay_ctrl(idelay_ctrl[31:16]),
    .enable(fifo_we_dbclk),
    .dclk_out(dbclk),
    .dclk_p(dbclk_p),
    .dclk_n(dbclk_n),
    .syncout_p(1'b0),
    .syncout_n(1'b0),
    .ovr_p(ovrb_p),
    .ovr_n(ovrb_n),
    .d_p(db_p),
    .d_n(db_n),
    .ovr_0(ovrb_0),
    .ovr_1(ovrb_1),
    .syncout_0(),
    .syncout_1(),
    .d_0(db_0),
    .d_1(db_1)
  );
  

  // Put the clock in a clock net and (TODO) generate other clock phases
  wire adc_clk_mmcm;
  wire pll_feedback_clk;
  //wire pll_feedback_clk_buf;
  PLLE2_BASE#(
    .BANDWIDTH("OPTIMIZED"),
    .DIVCLK_DIVIDE(1),
    .CLKOUT0_DIVIDE(PLLMULT),
    .CLKFBOUT_MULT(PLLMULT),
    .CLKIN1_PERIOD(CLKPERIOD)
  ) mmcm_inst (
    .CLKIN1(daclk),
    .RST(rst_daclk),
    .PWRDWN(1'b0),
    .CLKFBIN(pll_feedback_clk),
    .CLKFBOUT(pll_feedback_clk),
    .CLKOUT0(adc_clk_mmcm),
    .LOCKED(pll_locked)
  );

  BUFG adcclk_buf_inst (
    .I(adc_clk_mmcm),
    .O(adc_clk)
  );
  
  assign clkout = adc_clk;

endmodule
