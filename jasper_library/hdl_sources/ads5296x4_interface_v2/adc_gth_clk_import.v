module adc_gth_clk_import (input adc_clk_p,
                           input adc_clk_n,
                           output fimrware_clk);

  IBUFDS_GTE4 #(
     .REFCLK_EN_TX_PATH(1'b0),   // Refer to Transceiver User Guide.
     .REFCLK_HROW_CK_SEL(2'b00), // Refer to Transceiver User Guide.
     .REFCLK_ICNTL_RX(2'b00)     // Refer to Transceiver User Guide.
  )
  IBUFDS_GTE4_inst (
     .O(fimrware_clk),         // 1-bit output: Refer to Transceiver User Guide.
     .ODIV2(), // 1-bit output: Refer to Transceiver User Guide.
     .CEB(1'b0),     // 1-bit input: Refer to Transceiver User Guide.
     .I(adc_clk_p),         // 1-bit input: Refer to Transceiver User Guide.
     .IB(adc_clk_n)        // 1-bit input: Refer to Transceiver User Guide.
  );

endmodule
