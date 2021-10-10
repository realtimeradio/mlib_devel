
`timescale 1ns/100ps

module htg_ad9213_mmcm (
  input clk_in_p,
  input clk_in_n,
  output clk_out,
  output locked
);

  wire clk_in;
  wire clk_fb;
  wire clk_out_mmcm;

  IBUFDS ibuf_inst (
    .I(clk_in_p),
    .IB(clk_in_n),
    .O(clk_in)
  );

  MMCM_BASE #( 
   .BANDWIDTH          ("OPTIMIZED"), // Jitter programming ("HIGH","LOW","OPTIMIZED")
   .CLKFBOUT_MULT_F    (5), // Multiply value for all CLKOUT (5.0-64.0).
   .CLKFBOUT_PHASE     (0.0), 
   .CLKIN1_PERIOD      (5.0), // Clock is 200 MHz
   .CLKOUT0_DIVIDE_F   (4.0), // Divide amount for CLKOUT0 (1.000-128.000).
   .CLKOUT0_DUTY_CYCLE (0.5),
   .CLKOUT1_DUTY_CYCLE (0.5),
   .CLKOUT2_DUTY_CYCLE (0.5),
   .CLKOUT3_DUTY_CYCLE (0.5),
   .CLKOUT4_DUTY_CYCLE (0.5),
   .CLKOUT5_DUTY_CYCLE (0.5),
   .CLKOUT6_DUTY_CYCLE (0.5),
   .CLKOUT0_PHASE      (0.0),
   .CLOCK_HOLD         ("FALSE"),
   .DIVCLK_DIVIDE      (1), // Master division value (1-80)
   .REF_JITTER1        (0.0),
   .STARTUP_WAIT       ("FALSE")
  ) MMCM_BASE_inst (   
   .CLKIN1   (clk_in),
   .CLKFBIN  (clk_fb),
   .CLKFBOUT  (clk_fb),
   .CLKFBOUTB (),
   .CLKOUT0  (clk_out_mmcm),
   .CLKOUT0B (),
   .LOCKED   (locked),
   .PWRDWN   (1'b0),
   .RST      (1'b0)
  );

  BUFG clkout_buf (
    .I(clk_out_mmcm),
    .O(clk_out)
  );

endmodule
