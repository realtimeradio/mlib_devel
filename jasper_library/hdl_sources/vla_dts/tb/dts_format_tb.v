`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2022 02:40:01 PM
// Design Name: 
// Module Name: dts_format_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dts_format_tb (

    );
  localparam MUX_FACTOR_BITS = 2;  
  localparam N_INPUTS = 3;//12; 
  localparam INPUT_DWIDTH = 160;
  localparam OUTPUT_DWIDTH = 128;
  localparam POST_MUX_OUTPUT_DWIDTH = (OUTPUT_DWIDTH >> MUX_FACTOR_BITS);
    
  localparam CLK_PERIOD = 5.0;
  
  reg shift_rst;
  reg [N_INPUTS*4-1:0] mux_control;
  reg is_three_bit;
  wire [((N_INPUTS*OUTPUT_DWIDTH) >> MUX_FACTOR_BITS) - 1 : 0] dout;
  
  reg [N_INPUTS*OUTPUT_DWIDTH-1:0] def_frame_out = 0;
  reg [N_INPUTS-1:0] def_locked_out;
  reg [N_INPUTS-1:0] def_one_sec_out;
  reg [N_INPUTS-1:0] def_ten_sec_out;
  reg [N_INPUTS-1:0] def_index_out;
  reg [N_INPUTS-1:0] def_sync_out;
  
  initial begin
    def_sync_out = 0;
    def_index_out = 0;
    def_ten_sec_out = 0;
    def_one_sec_out = 0;
    def_locked_out = 1;
    is_three_bit = 1'b0;
    mux_control = {4'd11, 4'd10, 4'd9, 4'd8, 4'd7, 4'd6, 4'd5, 4'd3, 4'd2, 4'd1, 4'b0};
    shift_rst = 0;
    # (4*(1<<MUX_FACTOR_BITS)*CLK_PERIOD);
    shift_rst = 1;
    # (4*(1<<MUX_FACTOR_BITS)*CLK_PERIOD);
    shift_rst = 0;
  end
  
  reg clk;
  always begin
     clk = 1'b1;
     # ((1<<MUX_FACTOR_BITS)*CLK_PERIOD/2);
     clk = 1'b0;
     # ((1<<MUX_FACTOR_BITS)*CLK_PERIOD/2);
  end
  
  reg clkout;
  always begin
     clkout = 1'b1;
     # (CLK_PERIOD/2);
     clkout = 1'b0;
     # (CLK_PERIOD/2); 
  end
  
  genvar i;
  always@(posedge clk) begin
    if (shift_rst) begin
     def_frame_out[1*8-1:0*8]   <=8'd1; 
     def_frame_out[2*8-1:1*8]   <=8'd3; 
     def_frame_out[3*8-1:2*8]   <=8'd5; 
     def_frame_out[4*8-1:3*8]   <=8'd7; 
     def_frame_out[5*8-1:4*8]   <=8'd9; 
     def_frame_out[6*8-1:5*8]   <=8'd11;
     def_frame_out[7*8-1:6*8]   <=8'd13;
     def_frame_out[8*8-1:7*8]   <=8'd15;
     def_frame_out[9*8-1:8*8]   <=8'd17;
     def_frame_out[10*8-1:9*8]  <=8'd19;
     def_frame_out[11*8-1:10*8] <=8'd21;
     def_frame_out[12*8-1:11*8] <=8'd23;
     def_frame_out[13*8-1:12*8] <=8'd25;
     def_frame_out[14*8-1:13*8] <=8'd27;
     def_frame_out[15*8-1:14*8] <=8'd29;
     def_frame_out[16*8-1:15*8] <=8'd31;
                                    
     def_frame_out[33*8-1:32*8] <=  8'd0; 
     def_frame_out[34*8-1:33*8] <=  8'd2; 
     def_frame_out[35*8-1:34*8] <=  8'd4; 
     def_frame_out[36*8-1:35*8] <=  8'd6; 
     def_frame_out[37*8-1:36*8] <=  8'd8; 
     def_frame_out[38*8-1:37*8] <=  8'd10;
     def_frame_out[39*8-1:38*8] <=  8'd12;
     def_frame_out[40*8-1:39*8] <=  8'd14;
     def_frame_out[41*8-1:40*8] <=  8'd16;
     def_frame_out[42*8-1:41*8] <=  8'd18;
     def_frame_out[43*8-1:42*8] <=  8'd20;
     def_frame_out[44*8-1:43*8] <=  8'd22;
     def_frame_out[45*8-1:44*8] <=  8'd24;
     def_frame_out[46*8-1:45*8] <=  8'd26;
     def_frame_out[47*8-1:46*8] <=  8'd28;
     def_frame_out[48*8-1:47*8] <=  8'd30;
    end else begin
      def_frame_out[1*8-1:0*8] <= def_frame_out[1*8-1:0*8] + 8'd32;
      def_frame_out[2*8-1:1*8] <= def_frame_out[2*8-1:1*8] + 8'd32;
      def_frame_out[3*8-1:2*8] <= def_frame_out[3*8-1:2*8] + 8'd32;
      def_frame_out[4*8-1:3*8] <= def_frame_out[4*8-1:3*8] + 8'd32;
      def_frame_out[5*8-1:4*8] <= def_frame_out[5*8-1:4*8] + 8'd32;
      def_frame_out[6*8-1:5*8] <= def_frame_out[6*8-1:5*8] + 8'd32;
      def_frame_out[7*8-1:6*8] <= def_frame_out[7*8-1:6*8] + 8'd32;
      def_frame_out[8*8-1:7*8] <= def_frame_out[8*8-1:7*8] + 8'd32;
      def_frame_out[9*8-1:8*8] <= def_frame_out[9*8-1:8*8] + 8'd32;
      def_frame_out[10*8-1:9*8] <= def_frame_out[10*8-1:9*8] + 8'd32;
      def_frame_out[11*8-1:10*8] <= def_frame_out[11*8-1:10*8] + 8'd32;
      def_frame_out[12*8-1:11*8] <= def_frame_out[12*8-1:11*8] + 8'd32;
      def_frame_out[13*8-1:12*8] <= def_frame_out[13*8-1:12*8] + 8'd32;
      def_frame_out[14*8-1:13*8] <= def_frame_out[14*8-1:13*8] + 8'd32;
      def_frame_out[15*8-1:14*8] <= def_frame_out[15*8-1:14*8] + 8'd32;
      def_frame_out[16*8-1:15*8] <= def_frame_out[16*8-1:15*8] + 8'd32;
      
      def_frame_out[33*8-1:32*8] <= def_frame_out[33*8-1:32*8] + 8'd32;
      def_frame_out[34*8-1:33*8] <= def_frame_out[34*8-1:33*8] + 8'd32;
      def_frame_out[35*8-1:34*8] <= def_frame_out[35*8-1:34*8] + 8'd32;
      def_frame_out[36*8-1:35*8] <= def_frame_out[36*8-1:35*8] + 8'd32;
      def_frame_out[37*8-1:36*8] <= def_frame_out[37*8-1:36*8] + 8'd32;
      def_frame_out[38*8-1:37*8] <= def_frame_out[38*8-1:37*8] + 8'd32;
      def_frame_out[39*8-1:38*8] <= def_frame_out[39*8-1:38*8] + 8'd32;
      def_frame_out[40*8-1:39*8] <= def_frame_out[40*8-1:39*8] + 8'd32;
      def_frame_out[41*8-1:40*8] <= def_frame_out[41*8-1:40*8] + 8'd32;
      def_frame_out[42*8-1:41*8] <= def_frame_out[42*8-1:41*8] + 8'd32;
      def_frame_out[43*8-1:42*8] <= def_frame_out[43*8-1:42*8] + 8'd32;
      def_frame_out[44*8-1:43*8] <= def_frame_out[44*8-1:43*8] + 8'd32;
      def_frame_out[45*8-1:44*8] <= def_frame_out[45*8-1:44*8] + 8'd32;
      def_frame_out[46*8-1:45*8] <= def_frame_out[46*8-1:45*8] + 8'd32;
      def_frame_out[47*8-1:46*8] <= def_frame_out[47*8-1:46*8] + 8'd32;
      def_frame_out[48*8-1:47*8] <= def_frame_out[48*8-1:47*8] + 8'd32;
    end
  end
  
  
  
  wire gt_clkout = clk;

  wire [N_INPUTS*OUTPUT_DWIDTH-1:0] reorder_frame_out;
  wire [N_INPUTS-1:0] reorder_one_sec_out;
  wire [N_INPUTS-1:0] reorder_ten_sec_out;
  wire [N_INPUTS-1:0] reorder_index_out;
  wire [N_INPUTS-1:0] reorder_sync_out;
  wire [N_INPUTS-1:0] reorder_locked_out;




  dts_reorder #(
    .N_INPUTS(N_INPUTS),
    .INPUT_WIDTH(OUTPUT_DWIDTH),
    .SELECT_WIDTH(4)
  ) dts_reorder_inst[N_INPUTS-1:0] (
    .clk(gt_clkout),
    .sel(mux_control[N_INPUTS*4-1:0]),
    .din(def_frame_out),
    .din_locked(def_locked_out),
    .din_one_sec(def_one_sec_out),
    .din_ten_sec(def_ten_sec_out),
    .din_index(def_index_out),
    .din_sync(def_sync_out),
    .dout(reorder_frame_out),
    .dout_locked(reorder_locked_out),
    .dout_one_sec(reorder_one_sec_out),
    .dout_ten_sec(reorder_ten_sec_out),
    .dout_index(reorder_index_out),
    .dout_sync(reorder_sync_out)
  );


  wire [N_INPUTS*POST_MUX_OUTPUT_DWIDTH-1:0] offsetter_dout;

  (* async_reg = "true" *) reg shift_rst_unstable;
  (* async_reg = "true" *) reg shift_rst_stable;

  always @(posedge clkout) begin
    shift_rst_unstable <= shift_rst;
    shift_rst_stable <= shift_rst_unstable;
  end


  wire [N_INPUTS-1:0] one_sec;
  wire [N_INPUTS-1:0] ten_sec;
  wire [N_INPUTS-1:0] index;
  wire [N_INPUTS-1:0] sync;

  wire [N_INPUTS-1:0] fifo_overflow;
  wire [N_INPUTS-1:0] fifo_underflow;

  dts_offsetter #(
     .MUX_FACTOR_BITS(MUX_FACTOR_BITS)
  ) dts_offseter_inst[N_INPUTS-1:0] (
    .clk_in(gt_clkout),
    .clk_out(clkout),
    .rst(shift_rst_stable),
    .din(reorder_frame_out),
    .din_one_sec(reorder_one_sec_out),
    .din_ten_sec(reorder_ten_sec_out),
    .din_index(reorder_index_out),
    .din_sync(reorder_sync_out),
    .advance(1'b0),
    .delay(1'b0),
    .almost_full(),
    .almost_empty(),
    .overflow(fifo_overflow),
    .underflow(fifo_underflow),
    .dout(offsetter_dout),
    .dout_one_sec(one_sec),
    .dout_ten_sec(ten_sec),
    .dout_index(index),
    .dout_sync(sync)
  );

  dts_build_samples #(
    .INPUT_WIDTH(POST_MUX_OUTPUT_DWIDTH)
  ) dts_build_samples_inst[(N_INPUTS/3)-1:0] (
    .is_three_bit(is_three_bit),
    .din(offsetter_dout),
    .dout(dout)
  );


endmodule
