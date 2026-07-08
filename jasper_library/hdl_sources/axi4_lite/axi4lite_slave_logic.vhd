-------------------------------------------------------------------------------
-- Title      : AXI4-lite base slave interface
-- Project    : SKA
-------------------------------------------------------------------------------
-- File       : axi4lite_slave_logic.vhd
-- Author     : Riccardo Chiello <riccardo.chiello@gmail.com>
-- Last modified by : $Author: comore $
-- Company    : Oxford University
-- Created    : 2015-02-12
-- Last update: 2015-02-12
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Basic AXI4-lite slave interface logic
--
-- Generates all the handshake logic for a basic AXI4-lite slave.
--
-- Produces as output a simple memory mapped interface, with a ready/ack
-- simple protocol. The protocol can eb furter similified by tying the ack
-- signals to '1' (transactions always immediately acknowledged).
--
-- Further logic is required for register selection or more complex protocols,
-- but this is independent from the AXI4 layer
--
-- While a response is draining (read_wait/write_wait) one look-ahead AR and
-- one look-ahead AW handshake can complete; the accepted address is parked
-- and served as soon as the current response is delivered, so back-to-back
-- register reads sustain one read every two clock cycles.
--
-------------------------------------------------------------------------------
--
-- Signals:
--
-- axi4lite_aclk, axi4lite_aresetn: IN STD_LOGIC   AXI4 clock and reset signals
-- axi4lite_mosi
-- axi4lite_miso  Bus from master. MOSI = master out, slave in
--
-- ipb_mosi Simple bus with address, data and write/read strobes
-- ipb_miso Return bus to master. Read data bus, and acknowledges
--
-------------------------------------------------------------------------------
-- Copyright (c) 2015
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- $Log: $
-------------------------------------------------------------------------------
--
-- libraries
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.axi4lite_pkg.all;

entity axi4lite_slave_logic is
   port(
      axi4lite_aclk     : in std_logic;
      axi4lite_aresetn  : in std_logic;
      axi4lite_mosi     : in t_axi4lite_mosi;
      axi4lite_miso     : out t_axi4lite_miso;

      ipb_mosi          : out t_ipb_mosi;
      ipb_miso          : in t_ipb_miso
   );
end entity;

architecture axi4lite_slave_logic_a of axi4lite_slave_logic is

   type fsm_enum is (idle,reading,read_wait,writing,write_wait);
   signal fsm: fsm_enum;
   signal ipb_mosi_int : t_ipb_mosi;
   signal arready_i : std_logic;
   signal awready_i : std_logic;
   signal rvalid_i  : std_logic;
   signal wready_i  : std_logic;
   signal bvalid_i  : std_logic;
   signal ar_pending : std_logic;
   signal aw_pending : std_logic;
   signal ar_addr_saved : std_logic_vector(c_axi4lite_addr_w - 1 downto 0);
   signal aw_addr_saved : std_logic_vector(c_axi4lite_addr_w - 1 downto 0);

begin

   process(axi4lite_aclk,axi4lite_aresetn)
      variable v_ar_take : std_logic;
      variable v_aw_take : std_logic;
      variable v_ar_addr : std_logic_vector(c_axi4lite_addr_w - 1 downto 0);
      variable v_aw_addr : std_logic_vector(c_axi4lite_addr_w - 1 downto 0);
   begin
      if rising_edge(axi4lite_aclk) then

         -- registered write-data pipeline: ipb consumers sample wdat only in
         -- cycles where wreq is high, and wreq is wvalid delayed by the same
         -- one cycle, so data and request stay aligned
         ipb_mosi_int.wdat <= axi4lite_mosi.wdata;

         -- look-ahead capture: in the wait states one AR and/or one AW
         -- handshake can complete while the current response drains;
         -- park whatever is accepted and close the window
         v_ar_take := ar_pending;
         v_ar_addr := ar_addr_saved;
         v_aw_take := aw_pending;
         v_aw_addr := aw_addr_saved;
         if fsm = read_wait or fsm = write_wait then
            if arready_i = '1' and axi4lite_mosi.arvalid = '1' then
               v_ar_take := '1';
               v_ar_addr := axi4lite_mosi.araddr;
               ar_pending    <= '1';
               ar_addr_saved <= axi4lite_mosi.araddr;
            end if;
            if awready_i = '1' and axi4lite_mosi.awvalid = '1' then
               v_aw_take := '1';
               v_aw_addr := axi4lite_mosi.awaddr;
               aw_pending    <= '1';
               aw_addr_saved <= axi4lite_mosi.awaddr;
            end if;
            if (arready_i = '1' and axi4lite_mosi.arvalid = '1') or
               (awready_i = '1' and axi4lite_mosi.awvalid = '1') then
               arready_i <= '0';
               awready_i <= '0';
            end if;
         end if;

         case fsm is
            when idle =>
               arready_i <= '1';
               awready_i <= '1';
               if arready_i = '1' and axi4lite_mosi.arvalid = '1' then
                  -- read accepted; a simultaneous write is parked
                  if awready_i = '1' and axi4lite_mosi.awvalid = '1' then
                     aw_pending    <= '1';
                     aw_addr_saved <= axi4lite_mosi.awaddr;
                  end if;
                  arready_i <= '0';
                  awready_i <= '0';
                  ipb_mosi_int.addr <= axi4lite_mosi.araddr;
                  ipb_mosi_int.rreq <= '1';
                  fsm <= reading;
               elsif awready_i = '1' and axi4lite_mosi.awvalid = '1' then
                  arready_i <= '0';
                  awready_i <= '0';
                  ipb_mosi_int.addr <= axi4lite_mosi.awaddr;
                  fsm <= writing;
               end if;
            when reading =>
               if ipb_miso.rack = '1' then
                  rvalid_i <= '1';
                  axi4lite_miso.rdata <= ipb_miso.rdat;
                  ipb_mosi_int.rreq <= '0';
                  -- open the look-ahead window unless something is parked
                  if ar_pending = '0' and aw_pending = '0' then
                     arready_i <= '1';
                     awready_i <= '1';
                  end if;
                  fsm <= read_wait;
               end if;
            when read_wait =>
               if axi4lite_mosi.rready = '1' and rvalid_i = '1' then
                  rvalid_i <= '0';
                  axi4lite_miso.rdata <= (others=>'0');
                  -- chain straight into a parked transaction, reads first
                  if v_ar_take = '1' then
                     ar_pending        <= '0';
                     ipb_mosi_int.addr <= v_ar_addr;
                     ipb_mosi_int.rreq <= '1';
                     fsm               <= reading;
                  elsif v_aw_take = '1' then
                     aw_pending        <= '0';
                     ipb_mosi_int.addr <= v_aw_addr;
                     fsm               <= writing;
                  else
                     arready_i <= '1';
                     awready_i <= '1';
                     fsm       <= idle;
                  end if;
               end if;
            when writing =>
               ipb_mosi_int.wreq <= axi4lite_mosi.wvalid;
               if ipb_miso.wack = '1' and ipb_mosi_int.wreq = '1' then
                  ipb_mosi_int.wreq <= '0';
                  bvalid_i <= '1';
                  wready_i <= '1';
                  if ar_pending = '0' and aw_pending = '0' then
                     arready_i <= '1';
                     awready_i <= '1';
                  end if;
                  fsm <= write_wait;
               end if;
            when write_wait =>
               -- the W handshake completes here (data was already consumed
               -- via ipb); drop wready so a second beat is never accepted
               if wready_i = '1' and axi4lite_mosi.wvalid = '1' then
                  wready_i <= '0';
               end if;
               if axi4lite_mosi.bready = '1' and bvalid_i = '1' then
                  bvalid_i <= '0';
                  wready_i <= '0';
                  if v_ar_take = '1' then
                     ar_pending        <= '0';
                     ipb_mosi_int.addr <= v_ar_addr;
                     ipb_mosi_int.rreq <= '1';
                     fsm               <= reading;
                  elsif v_aw_take = '1' then
                     aw_pending        <= '0';
                     ipb_mosi_int.addr <= v_aw_addr;
                     fsm               <= writing;
                  else
                     arready_i <= '1';
                     awready_i <= '1';
                     fsm       <= idle;
                  end if;
               end if;
         end case;

      end if;
      if axi4lite_aresetn = '0' then
         arready_i <= '0';
         awready_i <= '0';
         rvalid_i <= '0';
         wready_i <= '0';
         bvalid_i <= '0';
         axi4lite_miso.rdata <= (others=>'0');
         ipb_mosi_int.rreq <= '0';
         ipb_mosi_int.wreq <= '0';
         ar_pending <= '0';
         aw_pending <= '0';
         ar_addr_saved <= (others => '0');
         aw_addr_saved <= (others => '0');
         fsm <= idle;
      end if;
   end process;

   axi4lite_miso.arready <= arready_i;
   axi4lite_miso.awready <= awready_i;
   axi4lite_miso.rvalid  <= rvalid_i;
   axi4lite_miso.wready  <= wready_i;
   axi4lite_miso.bvalid  <= bvalid_i;

   ipb_mosi <= ipb_mosi_int;

   axi4lite_miso.rresp <= c_axi4lite_resp_okay;
   axi4lite_miso.bresp <= c_axi4lite_resp_okay;

end architecture;
