module white_rabbit_quabo (
  input clk_20m_vcxo_i,
  input clk_125m_gtx_n_i,
  input clk_125m_gtx_p_i,
  output plldac_sclk_o,
  output plldac_din_o,
  output pll25dac_cs_n_o,
  output pll20dac_cs_n_o,
  output sfp_txp_o,
  output sfp_txn_o,
  input sfp_rxp_i,
  input sfp_rxn_i,
  input sfp_mod_def0_i,
  inout sfp_mod_def1_b,
  inout sfp_mod_def2_b,
  output sfp_rate_select_o,
  input sfp_tx_fault_i,
  output sfp_tx_disable_o,
  input sfp_los_i,
  inout onewire_b,
  input uart_rxd_i,
  output uart_txd_o,
  output spi_sclk_o,
  output spi_ncs_o,
  output spi_mosi_o,
  input spi_miso_i,
  input reset_i,
  input clk_ext_10m,
  output pps_o,
  output clk_sys_o,
  // Counters
  output pps_counter_o,
  output clk_counter_o
  );
  
  wrc_board_quabo_Light_ip quabo_wrc_inst (
    .clk_20m_vcxo_i(clk_20m_vcxo_i),        // input wire clk_20m_vcxo_i
    .clk_125m_gtx_n_i(clk_125m_gtx_n_i),    // input wire clk_125m_gtx_n_i
    .clk_125m_gtx_p_i(clk_125m_gtx_p_i),    // input wire clk_125m_gtx_p_i
    .plldac_sclk_o(plldac_sclk_o),          // output wire plldac_sclk_o
    .plldac_din_o(plldac_din_o),            // output wire plldac_din_o
    .pll25dac_cs_n_o(pll25dac_cs_n_o),      // output wire pll25dac_cs_n_o
    .pll20dac_cs_n_o(pll20dac_cs_n_o),      // output wire pll20dac_cs_n_o
    .sfp_txp_o(sfp_txp_o),                  // output wire sfp_txp_o
    .sfp_txn_o(sfp_txn_o),                  // output wire sfp_txn_o
    .sfp_rxp_i(sfp_rxp_i),                  // input wire sfp_rxp_i
    .sfp_rxn_i(sfp_rxn_i),                  // input wire sfp_rxn_i
    .sfp_mod_def0_i(sfp_mod_def0_i),        // input wire sfp_mod_def0_i
    .sfp_mod_def1_b(sfp_mod_def1_b),        // inout wire sfp_mod_def1_b
    .sfp_mod_def2_b(sfp_mod_def2_b),        // inout wire sfp_mod_def2_b
    .sfp_rate_select_o(sfp_rate_select_o),  // output wire sfp_rate_select_o
    .sfp_tx_fault_i(sfp_tx_fault_i),        // input wire sfp_tx_fault_i
    .sfp_tx_disable_o(sfp_tx_disable_o),    // output wire sfp_tx_disable_o
    .sfp_los_i(sfp_los_i),                  // input wire sfp_los_i
    .onewire_b(onewire_b),                  // inout wire onewire_b
    .uart_rxd_i(uart_rxd_i),                // input wire uart_rxd_i
    .uart_txd_o(uart_txd_o),                // output wire uart_txd_o
    .spi_sclk_o(spi_sclk_o),                // output wire spi_sclk_o
    .spi_ncs_o(spi_ncs_o),                  // output wire spi_ncs_o
    .spi_mosi_o(spi_mosi_o),                // output wire spi_mosi_o
    .spi_miso_i(spi_miso_i),                // input wire spi_miso_i
    .reset_i(reset_i),                      // input wire reset_i
    .clk_ext_10m(clk_ext_10m),              // input wire clk_ext_10m
    .pps_o(pps_o),                          // output wire pps_o
    .clk_sys_o(clk_sys_o)                   // output wire clk_sys_o
  );
  
  reg [31:0] pps_counter_reg;
  reg [31:0] clk_counter_reg;
  assign pps_counter_o = pps_counter_reg;
  assign clk_counter_o = clk_counter_reg;
 
  always @(posedge clk_sys_o) begin
    if (pps_o) begin
      pps_counter_reg <= pps_counter_reg + 1'b1;
    end
    clk_counter_reg <= clk_counter_reg + 1'b1;
  end
endmodule
