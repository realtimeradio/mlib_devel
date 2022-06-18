module ads41_top #(
    parameter NBITS=12,
    parameter PLLMULT=4,
    parameter CLKPERIOD=4.00,
    parameter INC_PLL=1'b0,
    parameter FLIP_PN=16'b0
 )(
    // ADC CONTROL INTERFACE
    // Control signals from user logic
    // (on rd_clk domain)
    input rd_clk,
    input rd_clk_locked,
    input user_rst,
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
    output clk_out,
    // Overrange to user logic
    output ovr_out,
    // Data to user logic
    output [NBITS-1:0] d_out
  );

  wire localclk;
  
  // Pull user reset onto one of the local domains
  (* async_reg = "true" *) reg rst_localclk_unstable;
  (* async_reg = "true" *) reg rst_localclk_stable;
  (* async_reg = "true" *) reg fifo_we_localclk_unstable;
  (* async_reg = "true" *) reg fifo_we_localclk_stable;
  wire rst_localclk = rst_localclk_stable;
  wire fifo_we_localclk = fifo_we_localclk_stable;
  always @(posedge localclk) begin
    rst_localclk_unstable <= user_rst;
    rst_localclk_stable <= rst_localclk_unstable;
    fifo_we_localclk_unstable <= rd_clk_locked;
    fifo_we_localclk_stable <= fifo_we_localclk_unstable;
  end

  ads41_single #(
    .NBITS(NBITS),
    .IDELAY_VALUE(11),
    .FLIP_PN(FLIP_PN)
  ) ads41_inst (
    .rst(rst_localclk),
    .clk(rd_clk),
    .idelay_clk(idelay_clk),
    .idelay_val(idelay_val),
    .idelay_ctrl(idelay_ctrl[15:0]),
    .enable(fifo_we_localclk),
    .dclk_out(localclk),
    .dclk_p(dclk_p),
    .dclk_n(dclk_n),
    .ovr(ovr),
    .d_p(d_p),
    .d_n(d_n),
    .ovr_out(ovr_out),
    .d_out(d_out)
  );
  
  generate
  if (INC_PLL) begin : genpll
    // Put the clock in a clock net and (TODO if necessary) generate other clock phases
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
      .CLKIN1(localclk),
      .RST(rst_localclk),
      .PWRDWN(1'b0),
      .CLKFBIN(pll_feedback_clk),
      .CLKFBOUT(pll_feedback_clk),
      .CLKOUT0(adc_clk_mmcm),
      .LOCKED(pll_locked)
    );

    BUFG adcclk_buf_inst (
      .I(adc_clk_mmcm),
      .O(clk_out)
    );
  end else begin
    assign clk_out = 1'b0;
  end
  endgenerate

endmodule
