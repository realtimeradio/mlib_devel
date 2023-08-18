// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.3.1 (lin64) Build 1056140 Thu Oct 30 16:30:39 MDT 2014
// Date        : Fri Feb 19 10:12:17 2021
// Host        : hwdev-xbs running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /media/data/Francois/VivadoProjects/FRM123701U1R4/Vivado/IP/adcrx_async_fifo/adcrx_async_fifo_stub.v
// Design      : adcrx_async_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.3.1" *)
module adcrx_async_fifo(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty, prog_empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[191:0],wr_en,rd_en,dout[191:0],full,empty,prog_empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [191:0]din;
  input wr_en;
  input rd_en;
  output [191:0]dout;
  output full;
  output empty;
  output prog_empty;
endmodule
