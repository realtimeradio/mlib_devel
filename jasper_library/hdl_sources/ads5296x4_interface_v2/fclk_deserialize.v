module fclk_deserialize (
    input lclk,
    input fclk,
    input iserdes_rst_in,
    input mmcm_rst_in,
    output [3:0] fclk4b,
    output iserdes_rst_out,
    output mmcm_rst_out
  );
  
  reg lclk_d4_rst = 1'b0;
  reg lclk_d4_rstR = 1'b0;
  reg fclkR;
  reg iserdes_rst_reg = 1'b0;
  wire start_of_frame = fclk & ~fclkR;

  assign iserdes_rst_out = iserdes_rst_reg;
  assign mmcm_rst_out = lclk_d4_rstR;

  always @(posedge lclk) begin
    fclkR <= fclk;
    lclk_d4_rstR <= lclk_d4_rst;
    if (mmcm_rst_in) begin
      lclk_d4_rst <= 1'b1;
    end else if (start_of_frame) begin
      lclk_d4_rst <= 1'b0;
    end
    if (iserdes_rst_in) begin
      iserdes_rst_reg <= 1'b1;
    end else if (start_of_frame) begin
      iserdes_rst_reg <= 1'b0;
    end
  end

  wire [7:0] fclk8b;
  ISERDESE3 #(
    .DATA_WIDTH(4),
    .SIM_DEVICE("ULTRASCALE")
  ) iserdes_fclk (
    .CLK(lclk),
    .CLK_B(~lclk),
    .CLKDIV(lclk_d4),
    .D(fclk),
    //.D(fclk),
    .Q(fclk8b),
    .RST(iserdes_rst_reg),
    .FIFO_RD_EN(1'b0),
    .FIFO_RD_CLK(1'b0),
    .FIFO_EMPTY(),
    .INTERNAL_DIVCLK()
  );
  assign fclk4b = fclk8b[3:0];
endmodule
