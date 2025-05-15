// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
// Date        : Thu Apr  4 18:00:14 2024
// Host        : panoseti running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode funcsim
//               /data/Wei/casper_tut/tutorials_devel/snap/mlib_devel/jasper_library/hdl_sources/skarab_infr/cross_clock_fifo_36x16/cross_clock_fifo_36x16_sim_netlist.v
// Design      : cross_clock_fifo_36x16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "cross_clock_fifo_36x16,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module cross_clock_fifo_36x16
   (wr_clk,
    wr_rst,
    rd_clk,
    rd_rst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input wr_clk;
  input wr_rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input rd_clk;
  input rd_rst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [35:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [35:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;

  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire rd_clk;
  wire rd_en;
  wire rd_rst;
  wire wr_clk;
  wire wr_en;
  wire wr_rst;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [3:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [3:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [3:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "4" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "36" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "36" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "kintexu" *) 
  (* C_FULL_FLAGS_RST_VAL = "1" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "2" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "2" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "512x72" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "512x72" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "13" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "12" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "4" *) 
  (* C_RD_DEPTH = "16" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "4" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "4" *) 
  (* C_WR_DEPTH = "16" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "4" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  cross_clock_fifo_36x16_fifo_generator_v13_2_5 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[3:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[3:0]),
        .rd_en(rd_en),
        .rd_rst(rd_rst),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(1'b0),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[3:0]),
        .wr_en(wr_en),
        .wr_rst(wr_rst),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "4" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module cross_clock_fifo_36x16_xpm_cdc_gray
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [3:0]src_in_bin;
  input dest_clk;
  output [3:0]dest_out_bin;

  wire [3:0]async_path;
  wire [2:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [3:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [3:0]\dest_graysync_ff[1] ;
  wire [3:0]dest_out_bin;
  wire [2:0]gray_enc;
  wire src_clk;
  wire [3:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(\dest_graysync_ff[1] [3]),
        .I3(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[3]),
        .Q(async_path[3]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "4" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module cross_clock_fifo_36x16_xpm_cdc_gray__2
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [3:0]src_in_bin;
  input dest_clk;
  output [3:0]dest_out_bin;

  wire [3:0]async_path;
  wire [2:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [3:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [3:0]\dest_graysync_ff[1] ;
  wire [3:0]dest_out_bin;
  wire [2:0]gray_enc;
  wire src_clk;
  wire [3:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(\dest_graysync_ff[1] [3]),
        .I3(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[3]),
        .Q(async_path[3]),
        .R(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2021.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
qsH+0xVeIy6Vv34SDZ9xCV3CDYw7f9WBctc/PzukbtVJ7nBFwS4nDrTimVYr75P82Ott++fhdYED
fiPmEFqDaO8Tznx/cWmCJ4ZP05v5Nj5W0U1qbHMG2yoFI9+F69cU0GpYqgA2+Y5Ti9b4hGQsWvcM
yhhfCa1edN3SBWRnFRs=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
0AA96L6mkfzFLHzENNUCWacibTZcR2GBTVeQ7nHqU0RuzjZ/ng1W7eKq+ZSRYUwvLBeooaP2bho0
NxvQ9fH6tLhvfxxixoFJAHQUJ5OaTp58EDbkbps4xeWeUIC4tRYbtMOftt6/ipETmIqpW5AEVAVu
Pzh+URS6hYqT+sTXy3NyftONmOfBwjSiBGXIrAQykvXzGznLomop8nG5Rk6KEp7QKBb1QBKuo5ac
WUlrcQeazYGT9e+IxkEj663HXlwpHt57hGMFvG5c/m/TUNM7U3+QkUGnraHB3eK8ef+BPQwB+UxT
tbqybLiI15Ji917Zu300vD0PyUgUO70Pz4T2Ag==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
AWC9efBEWc3npQy1sZO1mYozfHm7h0KkPmaqKLNMAT36grvYnSzknIaLx4K4PBujZpKAdpQtZCYB
dTLm1wLEUKzvkOmJvpvSO/uR3NgWcAq5irDiRtidu7wq62gmpi9GbXKlyUT9beGHMnziPxH7rSvf
DsP6DYpKjM7TW5JEHG8=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Xj/SRfNq7Y7WSKYhPYCR5X6TJyjjaAPRuL1Yj6HNY4MmXTrIMcZbvkC+xyUPfokbjwn5OivIXe35
iOTM+yfNznh10Mt3q3kvKMxpLFu5ajHxa+e7j7b2eMUllJnfkhY2bLRa28zEzkOEJpEcoq02s/gJ
LnQmArXs08Hp5vdCc48JR3MJv6k5lnmYCDe1uEFjk+XndNi6bsXOozI9UHqF6gJjxODBiHBnKYFF
G1x1um/giZLrVF30Aeosdaz7n8moxcneVeuCpdcIgpssOvD/MkxVFlIE12ho6Bwv07eAmaPHQCbM
xgEFDdBQ/vgQSn1a2MXp9XxZGWnD7Nlxa4gXRA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GJ7pQGVdwW35U4S1lEMXX63eg7rNbwCnU2jJSI6OReBcl7zsX9GbcmETg7x3c3jm6X8b6hjaEJp7
F1E4gb2f4q1dYBabm93wpGLk0IUZORcrndHagTupA0pWFUpCFQy8QbJEV/4s6RohK12m9hpmfLTW
qpsTByO9Ur+loN0x2Mz1nC9omizaaLcKNd67Ly7OVzCaWRu3pReKvC2C7BxItx5uJBLixpS85+9i
jVv3lg+fFSbGIXLzum8fbnF8li+UeIe1QFLuVGeRbptfEV93evj9SGczbbvWR+cgvMphX6jJRGP8
w4pxM671JEBBuWHdMwmQ7JbHdYEH2vVJWRlxuw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
O26ycpEDdE5uO4UM6C9j0VMvr7AUcEJkRnunnb7zYX+R2nq1myxxCCQd0noQHCLHgGHMf/1JHdKr
H4E0HKilo78fKRK3mmUSQGkahzuaM7eMqtIigzdN0vUylH29MMjcGfpY76S95Epmi/xHFmLhnEIQ
wZ+flyDZPb/KuyYisKxqiHTgfwLIER4r0h2VINcuNXDyXAyRPpebJjLIIzziHqJV0bVPTa3NNqmC
db33qaZmv2eNmHk5kBTaIUu4Nz/jnjJiDSPkQ7Jq8stRCwBJUu2tf8ht1XRx40Yp0fMB5QhlGtfc
LFIajKgDBa5TnZnCts5V7c3LfARnv3Du8jvRaA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MGoFTkgKNm+rPfjz/31xF84Dii2IDyHbzedd6JdhNZvPcYY0tSo/nWkpHrcKTCxxgGuK4FG1m93o
xZrxPhJF0mduRf5HstV1aYNozBP9m98oT57a9j/evly3pFehQF51IyxHpPOvge/lGhNJAf7p+d9e
DivxEF2uxaoya/4yh5GLdbgaeA75sJpoRU+YyOBuCIXBFMr1yLmZQmgEwlsj10tfV4Qb5utf7dNL
aMMJ9+/F219AARxNPIxYgnWNX9PTqS7IDDDWndxCHpPRuCFSGch/Ka/ajezkevYLndwrY/+tSerg
quCEXGpTnwO2dIbTn/RVOFc0x9BSNEYIh4H42g==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
aGAamGAsbCwS+Wkn8lIrdk4LHEqpaIdgKgYHoGKoL1cr6PyDA3oM+dk0chkNHz6QZeq1TC5Rm3Pt
85kufNeAkVWIRzG7TaRzEYjCT+dZhlyrQpPPZH5gJTkfGdgrnBU299dFjdgbugNFPsyWrCwRxxZt
qQb2zXcM0wE4Hsn1Uz8dLvnzoQ3AhXpdVEJnKLA/KaLML7LtxWE3a/VgmZ/a5qHpCCBHFockUlXw
eEXX+YwSH4Ek5WoyJ1m/lFbadJGmrukVGPZ17aALmkKru3KHulooQ5arzADKj6RzmnPQJC/cPfBk
omsg5FPh0/rpdiJqdwPGqHns9XqUlhul6ZybeNMuxrk8PQXhGLTbvOU/00ahh6AANbP4T9jh7Di7
OED5NGAk8blFgieTMFLd+YiSedcMgvU8vcHZ+PW+dulX2fFdMXtsCjY5YyjygP9Z1eaAmkuJUkG3
Wgnq3+5iQ/F1vRZwOt6UvqhWRMjs1rwPnXmFFcTba3424BUgBmWyHHXT

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZpNMrZYqJeLHXjZeb0d6EBaAKf8FC5LgIj0jJqt7SEzPKFECnsL19o47OBvYgLrxcLeAxdRb3fUK
ILYZbvBD7IQiG8UuHpkvnyEc3IpVIGh/Cdm14jHhu0XLkKU9T24y1ImHEat1IVVkMjWiCD+yF96Q
h+uGSLZNoYT3N9Sp5Pctg1ngeJ8imoiJlHV7bRr2ZQySZiqBAhjTj5t9SIAJ9Ou7Ea0GrqOAJ7Tu
zFcuj8hzoJZv50SaI8VW52N9lCo1utDigtsl95KaLf1Bb5Oh0zbrsVttGwDtACmQbxfvTQtrz2Yb
YXDEpn9milXQJBYP40DtVNVA+BonajGITKWyVg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 69664)
`pragma protect data_block
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
L3kLT8MG6x9d3A==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
