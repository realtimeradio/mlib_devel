// ***************************************************************************
// This code is modified from that originally made available
// by Analog Devices, Inc, at
// https://github.com/analogdevicesinc/hdl/blob/master/projects/ad9081_fmca_ebz/zcu102/system_top.v
//
// As per the terms of the original license, it is used here
// under the GNU GPL v2 license, which can be found online
// at https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
// ***************************************************************************

`timescale 1ns/100ps

module adi_jesd_top  #(
  parameter TX_JESD_L = 8,
  parameter TX_NUM_LINKS = 1,
  parameter RX_JESD_L = 8,
  parameter RX_NUM_LINKS = 1,
  parameter SHARED_DEVCLK = 0,
  parameter JESD_MODE = "64B66B"
) (
  // External IO
  //output [ 7:0] gpio_bd_o,
  // FMC HPC IOs
  input  [1:0]  agc0,
  input  [1:0]  agc1,
  input  [1:0]  agc2,
  input  [1:0]  agc3,
  //input         clkin6_n,
  //input         clkin6_p,
  //input         clkin10_n,
  //input         clkin10_p,
  input         fpga_refclk_in_n,
  input         fpga_refclk_in_p,
  input  [RX_JESD_L*RX_NUM_LINKS-1:0]  rx_data_n,
  input  [RX_JESD_L*RX_NUM_LINKS-1:0]  rx_data_p,
  output [TX_JESD_L*TX_NUM_LINKS-1:0]  tx_data_n,
  output [TX_JESD_L*TX_NUM_LINKS-1:0]  tx_data_p,
  inout  [10:0] gpio,
  inout         hmc_gpio1,
  output        hmc_sync,
  input  [1:0]  irqb,
  output        rstb,
  output [1:0]  rxen,
  output        spi0_csb,
  input         spi0_miso,
  output        spi0_mosi,
  output        spi0_sclk,
  output        spi1_csb,
  output        spi1_sclk,
  inout         spi1_sdio,
  input         sysref2_n,
  input         sysref2_p,
  output [1:0]  txen,
  // User IO
  output [511:0] dout,
  output dout_overflow,
  output dout_vld,
  output dout_sync,
  output adc_clk_out,
  output dsp_clk_out,
  // Internal IO
  output clk300,
  output axil_aclk,
  output axil_aclk90,
  output axil_aclk180,
  output axil_aclk270,
  output axil_areset_n,

  output [31:0] m_axil_araddr,
  output [2:0] m_axil_arprot,
  input m_axil_arready,
  output m_axil_arvalid,
  output [31:0] m_axil_awaddr,
  output [2:0] m_axil_awprot,
  input m_axil_awready,
  output m_axil_awvalid,
  output m_axil_bready,
  input [1:0] m_axil_bresp,
  input m_axil_bvalid,
  input [31:0] m_axil_rdata,
  output m_axil_rready,
  input [1:0]m_axil_rresp,
  input m_axil_rvalid,
  output [31:0] m_axil_wdata,
  input m_axil_wready,
  output [3:0] m_axil_wstrb,
  output m_axil_wvalid,

  output CYC_O,
  output STB_O,
  output WE_O,
  output [3:0] SEL_O,
  output [31:0] ADR_O,
  output [31:0] DAT_O,
  input  [31:0] DAT_I,
  input ACK_I,
  output RST_O
);
  // JH: Overridden signals
  wire [12:0] gpio_bd_i = 13'b0;
  
  // internal signals

  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o;
  wire    [94:0]  gpio_t;
  wire    [ 2:0]  spi0_csn;

  wire    [ 2:0]  spi1_csn;
  wire            spi1_mosi;
  wire            spi1_miso;

  wire            ref_clk;
  wire            sysref;
  wire            link_clk;
  assign          adc_clk_out = link_clk;

  wire    [7:0]   rx_data_p_loc;
  wire    [7:0]   rx_data_n_loc;
  wire    [7:0]   tx_data_p_loc;
  wire    [7:0]   tx_data_n_loc;

  //wire            clkin6;
  //wire            clkin10;
  //wire            tx_device_clk;
  //wire            rx_device_clk_internal;
  //wire            rx_device_clk;

  assign iic_rstn = 1'b1;

  // instantiations

  IBUFDS_GTE4 i_ibufds_ref_clk (
    .CEB (1'd0),
    .I (fpga_refclk_in_p),
    .IB (fpga_refclk_in_n),
    .O (ref_clk),
    .ODIV2 ());

  IBUFDS i_ibufds_sysref (
    .I (sysref2_p),
    .IB (sysref2_n),
    .O (sysref));

  //IBUFDS i_ibufds_tx_device_clk (
  //  .I (clkin6_p),
  //  .IB (clkin6_n),
  //  .O (clkin6));

  //IBUFDS i_ibufds_rx_device_clk (
  //  .I (clkin10_p),
  //  .IB (clkin10_n),
  //  .O (clkin10));

  //BUFG i_tx_device_clk (
  //  .I (clkin6),
  //  .O (tx_device_clk));

  //BUFG i_rx_device_clk (
  //  .I (clkin10),
  //  .O (rx_device_clk_internal));

  //assign rx_device_clk = SHARED_DEVCLK ? tx_device_clk : rx_device_clk_internal;

  // spi

  assign spi0_csb = spi0_csn[0];
  assign spi1_csb = spi1_csn[0];

  ad_3w_spi #(
    .NUM_OF_SLAVES(1)
  ) i_spi (
    .spi_csn (spi1_csn[0]),
    .spi_clk (spi1_sclk),
    .spi_mosi (spi1_mosi),
    .spi_miso (spi1_miso),
    .spi_sdio (spi1_sdio),
    .spi_dir ());

  // gpios

  ad_iobuf #(
    .DATA_WIDTH(12)
  ) i_iobuf (
    .dio_t (gpio_t[43:32]),
    .dio_i (gpio_o[43:32]),
    .dio_o (gpio_i[43:32]),
    .dio_p ({hmc_gpio1,       // 43
             gpio[10:0]}));   // 42-32

  assign gpio_i[44] = agc0[0];
  assign gpio_i[45] = agc0[1];
  assign gpio_i[46] = agc1[0];
  assign gpio_i[47] = agc1[1];
  assign gpio_i[48] = agc2[0];
  assign gpio_i[49] = agc2[1];
  assign gpio_i[50] = agc3[0];
  assign gpio_i[51] = agc3[1];
  assign gpio_i[52] = irqb[0];
  assign gpio_i[53] = irqb[1];

  assign hmc_sync = gpio_o[54];
  assign rstb     = gpio_o[55];
  assign rxen[0]  = gpio_o[56];
  assign rxen[1]  = gpio_o[57];
  assign txen[0]  = gpio_o[58];
  assign txen[1]  = gpio_o[59];

  /* Board GPIOS. Buttons, LEDs, etc... */
  assign gpio_i[20: 8] = gpio_bd_i;
  
  // JH
  //assign gpio_bd_o = gpio_o[7:0];
  //assign gpio_bd_o[7] = 1'b1;
  //assign gpio_bd_o[6] = 1'b0;
  //assign gpio_bd_o[5] = hmc_sync;
  //assign gpio_bd_o[4] = rstb;
  //assign gpio_bd_o[3] = rxen[0];
  //assign gpio_bd_o[2] = rxen[1];
  //assign gpio_bd_o[1] = txen[0];
  //assign gpio_bd_o[0] = txen[1];

  // Unused GPIOs
  assign gpio_i[59:54] = gpio_o[59:54];
  assign gpio_i[94:64] = gpio_o[94:64];
  assign gpio_i[31:21] = gpio_o[31:21];
  assign gpio_i[7:0] = gpio_o[7:0];

  wire [511:0] adc_dout;
  wire adc_dout_vld;
  wire adc_dout_sync;

  iwave_zu11_bd_wrapper i_system_wrapper (
    // User clocks / reset
    .clk300mhz(clk300),
    .axi_aclk   (axil_aclk   ),
    .axi_aclk90 (axil_aclk90 ),
    .axi_aclk180(axil_aclk180),
    .axi_aclk270(axil_aclk270),
    .axi_areset_n(axil_areset_n),
    // AXI Lite
    .m_axil_araddr (m_axil_araddr ),
    .m_axil_arprot (m_axil_arprot ),
    .m_axil_arready(m_axil_arready),
    .m_axil_arvalid(m_axil_arvalid),
    .m_axil_awaddr (m_axil_awaddr ),
    .m_axil_awprot (m_axil_awprot ),
    .m_axil_awready(m_axil_awready),
    .m_axil_awvalid(m_axil_awvalid),
    .m_axil_bready (m_axil_bready ),
    .m_axil_bresp  (m_axil_bresp  ),
    .m_axil_bvalid (m_axil_bvalid ),
    .m_axil_rdata  (m_axil_rdata  ),
    .m_axil_rready (m_axil_rready ),
    .m_axil_rresp  (m_axil_rresp  ),
    .m_axil_rvalid (m_axil_rvalid ),
    .m_axil_wdata  (m_axil_wdata  ),
    .m_axil_wready (m_axil_wready ),
    .m_axil_wstrb  (m_axil_wstrb  ),
    .m_axil_wvalid (m_axil_wvalid ),
    // Wishbone
    .CYC_O(CYC_O),
    .STB_O(STB_O),
    .WE_O (WE_O ),
    .SEL_O(SEL_O),
    .ADR_O(ADR_O),
    .DAT_O(DAT_O),
    .DAT_I(DAT_I),
    .ACK_I(ACK_I),
    .RST_O(RST_O),
    // Hardware Control
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .spi0_csn (spi0_csn),
    .spi0_miso (spi0_miso),
    .spi0_mosi (spi0_mosi),
    .spi0_sclk (spi0_sclk),
    .spi1_csn (spi1_csn),
    .spi1_miso (spi1_miso),
    .spi1_mosi (spi1_mosi),
    .spi1_sclk (spi1_sclk),
    // FMC HPC
    .rx_data_0_n (rx_data_n_loc[0]),
    .rx_data_0_p (rx_data_p_loc[0]),
    .rx_data_1_n (rx_data_n_loc[1]),
    .rx_data_1_p (rx_data_p_loc[1]),
    .rx_data_2_n (rx_data_n_loc[2]),
    .rx_data_2_p (rx_data_p_loc[2]),
    .rx_data_3_n (rx_data_n_loc[3]),
    .rx_data_3_p (rx_data_p_loc[3]),
    .rx_data_4_n (rx_data_n_loc[4]),
    .rx_data_4_p (rx_data_p_loc[4]),
    .rx_data_5_n (rx_data_n_loc[5]),
    .rx_data_5_p (rx_data_p_loc[5]),
    .rx_data_6_n (rx_data_n_loc[6]),
    .rx_data_6_p (rx_data_p_loc[6]),
    .rx_data_7_n (rx_data_n_loc[7]),
    .rx_data_7_p (rx_data_p_loc[7]),
    .tx_data_0_n (tx_data_n_loc[0]),
    .tx_data_0_p (tx_data_p_loc[0]),
    .tx_data_1_n (tx_data_n_loc[1]),
    .tx_data_1_p (tx_data_p_loc[1]),
    .tx_data_2_n (tx_data_n_loc[2]),
    .tx_data_2_p (tx_data_p_loc[2]),
    .tx_data_3_n (tx_data_n_loc[3]),
    .tx_data_3_p (tx_data_p_loc[3]),
    .tx_data_4_n (tx_data_n_loc[4]),
    .tx_data_4_p (tx_data_p_loc[4]),
    .tx_data_5_n (tx_data_n_loc[5]),
    .tx_data_5_p (tx_data_p_loc[5]),
    .tx_data_6_n (tx_data_n_loc[6]),
    .tx_data_6_p (tx_data_p_loc[6]),
    .tx_data_7_n (tx_data_n_loc[7]),
    .tx_data_7_p (tx_data_p_loc[7]),
    .ref_clk_q0 (ref_clk),
    .ref_clk_q1 (ref_clk),
    .rx_device_clk (link_clk),//rx_device_clk),
    .tx_device_clk (link_clk),//tx_device_clk),
    .rx_sync_0 (),
    .tx_sync_0 (1'b0), // not used in 204C
    .rx_sysref_0 (sysref),
    .link_clk_out(link_clk),
    .tx_sysref_0 (sysref),
    // User outputs
    .dout(adc_dout),
    .dout_overflow(),
    .dout_vld(adc_dout_vld),
    .dout_sync(adc_dout_sync)
    );

  wire dsp_clk;
  wire clk_fb;
  wire dsp_clk_locked;
  MMCME3_BASE #(
   .BANDWIDTH("OPTIMIZED"),    // Jitter programming (HIGH, LOW, OPTIMIZED)
   .CLKFBOUT_MULT_F(4.0),      // Multiply value for all CLKOUT (2.000-64.000)
   .CLKFBOUT_PHASE(0.0),       // Phase offset in degrees of CLKFB (-360.000-360.000)
   .CLKIN1_PERIOD(3.0),        // Input clock period in ns units, ps resolution (i.e., 33.333 is 30 MHz).
   .CLKOUT0_DIVIDE_F(3.0),     // Divide amount for CLKOUT0 (1.000-128.000)
   // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
   .CLKOUT0_DUTY_CYCLE(0.5),
   // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
   .CLKOUT0_PHASE(0.0),
   // CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
   .CLKOUT1_DIVIDE(1),
   .DIVCLK_DIVIDE(1),          // Master division value (1-106)
   // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
   .IS_CLKFBIN_INVERTED(1'b0), // Optional inversion for CLKFBIN
   .IS_CLKIN1_INVERTED(1'b0),  // Optional inversion for CLKIN1
   .IS_PWRDWN_INVERTED(1'b0),  // Optional inversion for PWRDWN
   .IS_RST_INVERTED(1'b0),     // Optional inversion for RST
   .REF_JITTER1(0.0),          // Reference input jitter in UI (0.000-0.999)
   .STARTUP_WAIT("FALSE")      // Delays DONE until MMCM is locked (FALSE, TRUE)
  ) MMCME3_BASE_inst (
   // Clock Outputs outputs: User configurable clock outputs
   .CLKOUT0(dsp_clk_out),     // 1-bit output: CLKOUT0
   // Feedback outputs: Clock feedback ports
   .CLKFBOUT(clk_fb),   // 1-bit output: Feedback clock
   // Status Ports outputs: MMCM status ports
   .LOCKED(dsp_clk_locked),       // 1-bit output: LOCK
   // Clock Inputs inputs: Clock input
   .CLKIN1(adc_clk_out),       // 1-bit input: Clock
   // Control Ports inputs: MMCM control ports
   .PWRDWN(1'b0),       // 1-bit input: Power-down
   .RST(1'b0),             // 1-bit input: Reset
   // Feedback inputs: Clock feedback ports
   .CLKFBIN(clk_fb)      // 1-bit input: Feedback clock
  );

  wire fifo_empty;
  wire [511+1:0] fifo_dout;
  data_fifo data_fifo_inst (
    .wr_clk(adc_clk_out),
    .din({adc_dout_sync, adc_dout}),
    .wr_en(adc_dout_vld),
    .rd_clk(dsp_clk_out),
    .empty(fifo_empty),
    .rd_en(~fifo_empty),
    .dout(fifo_dout),
    .valid(dout_vld),
    .rst(~dsp_clk_locked)
  );
  assign dout[511:0] = fifo_dout[511:0];
  assign dout_sync = fifo_dout[512];


  assign rx_data_p_loc[RX_JESD_L*RX_NUM_LINKS-1:0] = rx_data_p[RX_JESD_L*RX_NUM_LINKS-1:0];
  assign rx_data_n_loc[RX_JESD_L*RX_NUM_LINKS-1:0] = rx_data_n[RX_JESD_L*RX_NUM_LINKS-1:0];

  assign tx_data_p[TX_JESD_L*TX_NUM_LINKS-1:0] = tx_data_p_loc[TX_JESD_L*TX_NUM_LINKS-1:0];
  assign tx_data_n[TX_JESD_L*TX_NUM_LINKS-1:0] = tx_data_n_loc[TX_JESD_L*TX_NUM_LINKS-1:0];

endmodule

