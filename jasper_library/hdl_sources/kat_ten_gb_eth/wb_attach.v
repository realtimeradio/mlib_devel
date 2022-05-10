`timescale 1ns/1ps
module wb_attach #(
    parameter FABRIC_MAC      = 48'hffff_ffff_ffff,
    parameter FABRIC_IP       = 32'hffff_ffff,
    parameter FABRIC_PORT     = 16'hffff,
    parameter FABRIC_GATEWAY  = 8'd0,
    parameter FABRIC_ENABLE   = 0,
    parameter MC_RECV_IP      = 32'h00000000,
    parameter MC_RECV_IP_MASK = 32'h00000000,
    parameter PREEMPHASIS     = 4'b0100,
    parameter POSTEMPHASIS    = 5'b00000,
    parameter DIFFCTRL        = 4'b1010,
    parameter RXEQMIX         = 3'b111,
    parameter CPU_TX_ENABLE   = 1'b0,
    parameter CPU_RX_ENABLE   = 1'b0
  )(
    //OPB attachment
    //input         wb_clk_i,
    //input         wb_rst_i,
    //input   [3:0] wb_sel_i,
    //input  [31:0] wb_adr_i,
    //input  [31:0] wb_dat_i,
    //output [31:0] wb_dat_o,
    //output        wb_ack_o,

    input         wb_clk_i,
    input         wb_rst_i,
    output [31:0] wb_dat_o,
    output        wb_err_o,
    output        wb_ack_o,
    input  [31:0] wb_adr_i,
    input  [3:0]  wb_sel_i,
    input  [31:0] wb_dat_i,
    input         wb_we_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    //tx_buffer bits
    output  [7:0] cpu_tx_buffer_addr,
    input  [63:0] cpu_tx_buffer_rd_data,
    output [63:0] cpu_tx_buffer_wr_data,
    output        cpu_tx_buffer_wr_en,
    output  [7:0] cpu_tx_size,
    output        cpu_tx_ready,
    input         cpu_tx_done,
    //rx_buffer bits
    output  [7:0] cpu_rx_buffer_addr,
    input  [63:0] cpu_rx_buffer_rd_data,
    input   [7:0] cpu_rx_size,
    output        cpu_rx_ack,
    //ARP Cache
    output  [7:0] arp_cache_addr,
    input  [47:0] arp_cache_rd_data,
    output [47:0] arp_cache_wr_data,
    output        arp_cache_wr_en,
    //local registers
    output        local_enable,
    output [47:0] local_mac,
    output [31:0] local_ip,
    output [15:0] local_port,
    //output [15:0] local_port_mask, // TODO support port mask
    output  [7:0] local_gateway,
    output [31:0] local_mc_recv_ip,
    output [31:0] local_mc_recv_ip_mask,
    output        soft_reset,
    input         soft_reset_ack,
    //xaui status
    input   [7:0] xaui_status,
    //xaui config

    //MGT/GTP PMA Config
    output  [2:0] mgt_rxeqmix,
    output  [3:0] mgt_txpreemphasis,
    output  [4:0] mgt_txpostemphasis,
    output  [3:0] mgt_txdiffctrl
  );

  /**************** Hard coded core parameters ************/
  localparam CORE_REV     = 8'd1;
  localparam CORE_TYPE    = 8'd2; // 10GbE core
  localparam TX_WORD_SIZE = 16'd8;
  localparam RX_WORD_SIZE = 16'd8;
  localparam TX_MAX_SIZE  = 16'd2048;
  localparam RX_MAX_SIZE  = 16'd2048;
  /************* OPB Address Decoding *************/

  wire opb_sel = wb_stb_i;

 // wire [31:0] local_addr = wb_adr_i;
  wire [31:0] local_addr = {16'b0,wb_adr_i[15:0]};
  localparam REGISTERS_OFFSET = 32'h0000;
  localparam REGISTERS_HIGH   = 32'h0FFF;
  localparam ARP_CACHE_OFFSET = 32'h1000;
  localparam ARP_CACHE_HIGH   = 32'h3FFF;
  localparam TX_BUFFER_OFFSET = 32'h4000;
  localparam TX_BUFFER_HIGH   = 32'h7FFF;
  localparam RX_BUFFER_OFFSET = 32'h8000;
  localparam RX_BUFFER_HIGH   = 32'hBFFF;

  reg opb_ack;
  wire opb_trans = wb_cyc_i && wb_stb_i && !opb_ack;

  wire reg_sel   = opb_trans && (local_addr >= REGISTERS_OFFSET) && (local_addr <= REGISTERS_HIGH);
  wire rxbuf_sel = opb_trans && (local_addr >= RX_BUFFER_OFFSET) && (local_addr <= RX_BUFFER_HIGH);
  wire txbuf_sel = opb_trans && (local_addr >= TX_BUFFER_OFFSET) && (local_addr <= TX_BUFFER_HIGH);
  wire arp_sel   = opb_trans && (local_addr >= ARP_CACHE_OFFSET) && (local_addr <= ARP_CACHE_HIGH);

  wire [31:0] reg_addr   = local_addr - REGISTERS_OFFSET;
  wire [31:0] rxbuf_addr = local_addr - RX_BUFFER_OFFSET;
  wire [31:0] txbuf_addr = local_addr - TX_BUFFER_OFFSET;
  wire [31:0] arp_addr   = local_addr - ARP_CACHE_OFFSET;

  /************** Registers ****************/
  
 // localparam REG_VALID_PORTS     = 4'd8; // soft_reset, local_enable, local_port, set to phy control_0
 // localparam REG_XAUI_STATUS     = 4'd9; // cpu tx/rx enable put in REG_CORE_TYPE. xaui_status put in PHY_STATUS
 // localparam REG_PHY_CONFIG      = 4'd10; // set to phy_control_1

  localparam REG_CORE_TYPE       = 8'd0;
  localparam REG_TX_RX_MAX_BUF   = 8'd1;
  localparam REG_WORD_LENGTHS    = 8'd2;
  localparam REG_MAC_ADDR_1      = 8'd3;
  localparam REG_MAC_ADDR_0      = 8'd4;
  localparam REG_IP_ADDR         = 8'd5;
  localparam REG_GATEWAY_ADDR    = 8'd6;
  localparam REG_NETMASK         = 8'd7;
  localparam REG_MC_RECV_IP      = 8'd8;
  localparam REG_MC_RECV_IP_MASK = 8'd9;
  localparam REG_TX_RX_BUF       = 8'd10;
  localparam REG_PROMIS_EN       = 8'd11;
  localparam REG_PMASK_PORT      = 8'd12;
  localparam REG_PHY_STATUS_1    = 8'd13;
  localparam REG_PHY_STATUS_0    = 8'd14;
  localparam REG_PHY_CONTROL_1   = 8'd15;
  localparam REG_PHY_CONTROL_0   = 8'd16;
  localparam REG_ARP_SIZE        = 8'd17;

 

  reg [47:0] local_mac_reg;
  reg [31:0] local_ip_reg;
  reg [31:0] local_gateway_reg = 0;
  reg [15:0] local_port_mask_reg;
  reg [15:0] local_port_reg;
  reg        local_enable_reg;
  reg [31:0] local_mc_recv_ip_reg;
  reg [31:0] local_mc_recv_ip_mask_reg;
  reg  [2:0] mgt_rxeqmix_reg;
  reg  [3:0] mgt_txpreemphasis_reg;
  reg  [4:0] mgt_txpostemphasis_reg;
  reg  [3:0] mgt_txdiffctrl_reg;
  reg        soft_reset_reg;

  assign local_mac         = local_mac_reg;
  assign local_ip          = local_ip_reg;
  assign local_gateway     = local_gateway_reg;
  assign local_port        = local_port_reg;
  //assign local_port_mask   = local_port_mask_reg;
  assign local_enable      = local_enable_reg;
  assign mgt_rxeqmix       = mgt_rxeqmix_reg;
  assign mgt_txpreemphasis = mgt_txpreemphasis_reg;
  assign mgt_txpostemphasis = mgt_txpostemphasis_reg;
  assign mgt_txdiffctrl    = mgt_txdiffctrl_reg;
  assign soft_reset        = soft_reset_reg;
  assign local_mc_recv_ip  = local_mc_recv_ip_reg;
  assign local_mc_recv_ip_mask  = local_mc_recv_ip_mask_reg;
  
  assign wb_err_o = 1'b0;


  reg use_arp_data, use_tx_data, use_rx_data;

  reg [7:0] opb_data_src;

  /* RX/TX Buffer Control regs */

  reg [7:0] cpu_tx_size_reg;
  reg       cpu_tx_ready_reg;
  reg       cpu_rx_ack_reg;
  assign cpu_tx_size  = cpu_tx_size_reg;
  assign cpu_tx_ready = cpu_tx_ready_reg;
  assign cpu_rx_ack   = cpu_rx_ack_reg;

  reg opb_wait;
  reg write_arp;
  reg tx_write;
  always @(posedge wb_clk_i) begin
    //strobes
    opb_ack          <= 1'b0;
    use_arp_data     <= 1'b0;
    use_tx_data      <= 1'b0;
    use_rx_data      <= 1'b0;
    write_arp        <= 1'b0;
    tx_write         <= 1'b0;

    /* When the 10ge wrapper has sent the packet we tell the user by clearing 
       the size register */
    if (cpu_tx_done) begin
      cpu_tx_size_reg  <= 8'd0;
      cpu_tx_ready_reg <= 1'b0;
    end

    /* The size will be set to zero when the double buffer is swapped */
    if (cpu_tx_size == 8'd0) begin
      cpu_rx_ack_reg  <= 1'b0;
    end

    if (wb_rst_i) begin
      opb_data_src      <= 8'b0;

      local_mac_reg     <= FABRIC_MAC;
      local_ip_reg      <= FABRIC_IP;
      local_gateway_reg <= FABRIC_GATEWAY;
      local_port_reg    <= FABRIC_PORT;
      local_enable_reg  <= FABRIC_ENABLE;
      local_mc_recv_ip_reg      <= MC_RECV_IP;
      local_mc_recv_ip_mask_reg <= MC_RECV_IP_MASK;

      cpu_tx_size_reg   <= 8'd0;

      cpu_rx_ack_reg  <= 1'b0;

      /* TODO: add decode PREEMPHASIS/SWING feature */
      mgt_rxeqmix_reg       <= RXEQMIX;
//      mgt_rxeqpole_reg      <= 4'b0000;
      mgt_txpreemphasis_reg <= PREEMPHASIS;
      mgt_txpostemphasis_reg <= POSTEMPHASIS;
      mgt_txdiffctrl_reg    <= DIFFCTRL;

      opb_wait <= 1'b0;

      soft_reset_reg <= 1'b0;

    end else if (opb_wait) begin
      opb_wait <= 1'b0;
      opb_ack  <= 1'b1;
    end else begin

      if (soft_reset_ack) begin
        soft_reset_reg <= 1'b0;
      end

      if (opb_trans)
        opb_ack <= 1'b1;

      // ARP Cache
      if (arp_sel) begin 
        if (wb_we_i) begin
          opb_ack  <= 1'b0;
          opb_wait <= 1'b1;
          write_arp <= 1'b1;
        end else begin
          use_arp_data <= 1'b1;
        end
      end

      // RX Buffer 
      if (rxbuf_sel) begin
        if (wb_we_i) begin
        end else begin
          use_rx_data <= 1'b1;
        end
      end

      // TX Buffer 
      if (txbuf_sel) begin
        if (wb_we_i) begin
          opb_ack  <= 1'b0;
          opb_wait <= 1'b1;
          tx_write <= 1'b1;
        end else begin
          use_tx_data <= 1'b1;
        end
      end

      // registers
      if (reg_sel) begin
        opb_data_src <= reg_addr[9:2];
        if (wb_we_i) begin
          case (reg_addr[9:2])
            REG_CORE_TYPE: begin
            end
            REG_TX_RX_MAX_BUF: begin
            end
            REG_WORD_LENGTHS: begin
            end
            REG_MAC_ADDR_1: begin
              if (wb_sel_i[0])
                local_mac_reg[39:32] <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_mac_reg[47:40] <= wb_dat_i[15:8];
            end
            REG_MAC_ADDR_0: begin
              if (wb_sel_i[0])
                local_mac_reg[7:0]   <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_mac_reg[15:8]  <= wb_dat_i[15:8];
              if (wb_sel_i[2])
                local_mac_reg[23:16] <= wb_dat_i[23:16];
              if (wb_sel_i[3])
                local_mac_reg[31:24] <= wb_dat_i[31:24];
            end
            REG_IP_ADDR: begin
              if (wb_sel_i[0])
                local_ip_reg[7:0]   <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_ip_reg[15:8]  <= wb_dat_i[15:8];
              if (wb_sel_i[2])
                local_ip_reg[23:16] <= wb_dat_i[23:16];
              if (wb_sel_i[3])
                local_ip_reg[31:24] <= wb_dat_i[31:24];
            end
            REG_GATEWAY_ADDR: begin
              // This core only writes the first bytes of the gateway
              if (wb_sel_i[0])
                local_gateway_reg[7:0] <= wb_dat_i[7:0];
            end
            REG_MC_RECV_IP: begin
              if (wb_sel_i[0])
                local_mc_recv_ip_reg[7:0]   <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_mc_recv_ip_reg[15:8]  <= wb_dat_i[15:8];
              if (wb_sel_i[2])
                local_mc_recv_ip_reg[23:16] <= wb_dat_i[23:16];
              if (wb_sel_i[3])
                local_mc_recv_ip_reg[31:24] <= wb_dat_i[31:24];
            end
            REG_MC_RECV_IP_MASK: begin
              if (wb_sel_i[0])
                local_mc_recv_ip_mask_reg[7:0]   <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_mc_recv_ip_mask_reg[15:8]  <= wb_dat_i[15:8];
              if (wb_sel_i[2])
                local_mc_recv_ip_mask_reg[23:16] <= wb_dat_i[23:16];
              if (wb_sel_i[3])
                local_mc_recv_ip_mask_reg[31:24] <= wb_dat_i[31:24];
            end
            REG_TX_RX_BUF: begin
              if (wb_sel_i[0] && wb_dat_i[7:0] == 8'b0) begin
                cpu_rx_ack_reg <= 1'b1;
              end
              if (wb_sel_i[2]) begin
                cpu_tx_size_reg  <= wb_dat_i[23:16];
                cpu_tx_ready_reg <= 1'b1;
              end
            end
            REG_PROMIS_EN: begin
              if (wb_sel_i[0])
                local_enable_reg     <= wb_dat_i[0];
              if (wb_sel_i[2] && wb_dat_i[16])
                soft_reset_reg       <= 1'b1;
            end
            REG_PMASK_PORT: begin
              if (wb_sel_i[0])
                local_port_reg[7:0] <= wb_dat_i[7:0];
              if (wb_sel_i[1])
                local_port_reg[15:8] <= wb_dat_i[15:8];
              // TODO Support core mask
              //if (wb_sel_i[2])
              //  local_port_mask_reg[7:0] <= wb_dat_i[23:16];
              //if (wb_sel_i[3])
              //  local_port_mask_reg[15:8] <= wb_dat_i[31:24];
            end
            REG_PHY_STATUS_0: begin
            end
            REG_PHY_STATUS_1: begin
            end
            REG_PHY_CONTROL_0: begin
            end
            REG_PHY_CONTROL_1: begin
              if (wb_sel_i[0])
                mgt_rxeqmix_reg       <= wb_dat_i[2:0];
              if (wb_sel_i[1])
                mgt_txpostemphasis_reg <= wb_dat_i[12:8];
              if (wb_sel_i[2])
                mgt_txpreemphasis_reg <= wb_dat_i[19:16];
              if (wb_sel_i[3])
                mgt_txdiffctrl_reg    <= wb_dat_i[27:24];
            end
            REG_ARP_SIZE: begin
            end
            default: begin
            end
          endcase
        end
      end
    end
  end

  /********* Handle memory interfaces ***********/

  reg arp_cache_we, tx_buffer_we;

  reg [63:0] write_data; //write data for all three buffers

  always @(posedge wb_clk_i) begin
    //strobes
    arp_cache_we <= 1'b0;
    tx_buffer_we <= 1'b0;

    if (wb_rst_i) begin
    end else begin
      //populate write_data according to wishbone transaction info & contents
      //of memory
      if (write_arp) begin
        arp_cache_we <= 1'b1;

        write_data[ 7: 0] <= arp_addr[2] == 1'b1 ? wb_dat_i[ 7: 0] : arp_cache_rd_data[ 7: 0]; 
        write_data[15: 8] <= arp_addr[2] == 1'b1 ? wb_dat_i[15: 8] : arp_cache_rd_data[15: 8]; 
        write_data[23:16] <= arp_addr[2] == 1'b1 ? wb_dat_i[23:16] : arp_cache_rd_data[23:16]; 
        write_data[31:24] <= arp_addr[2] == 1'b1 ? wb_dat_i[31:24] : arp_cache_rd_data[31:24]; 
        write_data[39:32] <= arp_addr[2] == 1'b0 ? wb_dat_i[ 7: 0] : arp_cache_rd_data[39:32]; 
        write_data[47:40] <= arp_addr[2] == 1'b0 ? wb_dat_i[15: 8] : arp_cache_rd_data[47:40]; 
      end
      if (tx_write) begin
        tx_buffer_we <= 1'b1;

        write_data[7:0]   <= txbuf_addr[2] == 1'b1 & wb_sel_i[0] ? wb_dat_i[ 7: 0] : cpu_tx_buffer_rd_data[ 7: 0];
        write_data[15:8]  <= txbuf_addr[2] == 1'b1 & wb_sel_i[1] ? wb_dat_i[15: 8] : cpu_tx_buffer_rd_data[15: 8];
        write_data[23:16] <= txbuf_addr[2] == 1'b1 & wb_sel_i[2] ? wb_dat_i[23:16] : cpu_tx_buffer_rd_data[23:16]; 
        write_data[31:24] <= txbuf_addr[2] == 1'b1 & wb_sel_i[3] ? wb_dat_i[31:24] : cpu_tx_buffer_rd_data[31:24]; 
        write_data[39:32] <= txbuf_addr[2] == 1'b0 & wb_sel_i[0] ? wb_dat_i[ 7: 0] : cpu_tx_buffer_rd_data[39:32]; 
        write_data[47:40] <= txbuf_addr[2] == 1'b0 & wb_sel_i[1] ? wb_dat_i[15: 8] : cpu_tx_buffer_rd_data[47:40]; 
        write_data[55:48] <= txbuf_addr[2] == 1'b0 & wb_sel_i[2] ? wb_dat_i[23:16] : cpu_tx_buffer_rd_data[55:48]; 
        write_data[63:56] <= txbuf_addr[2] == 1'b0 & wb_sel_i[3] ? wb_dat_i[31:24] : cpu_tx_buffer_rd_data[63:56]; 
      end
    end
  end

  // memory assignments
  assign arp_cache_addr        =   arp_addr[10:3];
  assign arp_cache_wr_data     = write_data[47:0];
  assign arp_cache_wr_en       = arp_cache_we;

  assign cpu_tx_buffer_addr    = txbuf_addr[10:3];
  assign cpu_tx_buffer_wr_data = write_data;
  assign cpu_tx_buffer_wr_en   = tx_buffer_we;

  assign cpu_rx_buffer_addr    = rxbuf_addr[10:3];

  // select what data to put on the bus
  wire [31:0] arp_data_int =   arp_addr[2] == 1'b1 ? arp_cache_rd_data[31:0] : {16'b0, arp_cache_rd_data[47:32]};
  wire [31:0] tx_data_int  = txbuf_addr[2] == 1'b1 ? cpu_tx_buffer_rd_data[31:0] : cpu_tx_buffer_rd_data[63:32];
  wire [31:0] rx_data_int  = rxbuf_addr[2] == 1'b1 ? cpu_rx_buffer_rd_data[31:0] : cpu_rx_buffer_rd_data[63:32];

  wire [31:0] opb_data_int = opb_data_src == REG_CORE_TYPE ? {7'b0, |CPU_TX_ENABLE, 7'b0, |CPU_RX_ENABLE, CORE_REV, CORE_TYPE} :
                             opb_data_src == REG_TX_RX_MAX_BUF ? {TX_MAX_SIZE, RX_MAX_SIZE} :
                             opb_data_src == REG_WORD_LENGTHS ? {TX_WORD_SIZE, RX_WORD_SIZE} :
                             opb_data_src == REG_MAC_ADDR_1   ? {16'b0,local_mac_reg[47:32]} :
                             opb_data_src == REG_MAC_ADDR_0   ? {local_mac_reg[31:0]} :
                             opb_data_src == REG_IP_ADDR      ? {local_ip_reg[31:0]} :
                             opb_data_src == REG_GATEWAY_ADDR ? local_gateway_reg :
                             opb_data_src == REG_NETMASK ? 32'hffffff00 :
                             opb_data_src == REG_MC_RECV_IP   ? {local_mc_recv_ip_reg[31:0]} :
                             opb_data_src == REG_MC_RECV_IP_MASK ? {local_mc_recv_ip_mask_reg[31:0]} :
                             opb_data_src == REG_TX_RX_BUF ? {8'b0, cpu_tx_size_reg, 8'b0, cpu_rx_ack_reg ? 8'b0 : cpu_rx_size} :
                             opb_data_src == REG_PROMIS_EN ? {8'b0, 7'b0, soft_reset_reg, 8'b0, 7'b0, local_enable_reg} :
                             opb_data_src == REG_PMASK_PORT ? {local_port_mask_reg, local_port_reg} :
                             opb_data_src == REG_PHY_STATUS_1 ? {32'b0} :
                             opb_data_src == REG_PHY_STATUS_0 ? {24'b0,xaui_status} :
                             opb_data_src == REG_PHY_CONTROL_1 ? {4'b0, mgt_txdiffctrl_reg,
                                                                  4'b0, mgt_txpreemphasis_reg,
                                                                  3'b0, mgt_txpostemphasis_reg,
                                                                  4'b0, 1'b0, mgt_rxeqmix_reg} :
                             opb_data_src == REG_PHY_CONTROL_0 ? {32'b0} :
                             opb_data_src == REG_ARP_SIZE ? {32'b0} : 32'b0;


  wire [31:0] wb_dat_o_int;
  assign wb_dat_o_int = use_arp_data ? arp_data_int :
                        use_tx_data  ? tx_data_int  :
                        use_rx_data  ? rx_data_int  :
                        opb_data_int;

  assign wb_dat_o = wb_ack_o ? wb_dat_o_int : 32'b0;

  assign wb_ack_o = opb_ack;
  assign wb_err_o = 1'b0;

endmodule
