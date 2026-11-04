-------------------------------------------------------------------------------
-- cdc_bus_handshake
--
-- Coherent clock domain crossing for a multi-bit bus which may change on every
-- source clock cycle (e.g. a counter or status word read by software).
--
-- A toggle request/acknowledge loop runs continuously. The source side
-- snapshots IP_BUS into a hold register and toggles a request; the hold
-- register is then left untouched until the destination has acknowledged.
-- The destination side synchronises the request and pulses OP_BUS_WE for one
-- IP_DST_CLK cycle when it arrives. The destination register (external to
-- this entity) must load OP_BUS only when OP_BUS_WE is high.
--
-- When OP_BUS_WE is high, OP_BUS has been stable for at least two IP_DST_CLK
-- cycles and will remain stable for at least two IP_SRC_CLK cycles after the
-- capturing edge, so every captured word is a value IP_BUS actually held.
-- Works for any ratio of source and destination clock frequency. The loop is
-- self-recovering from any state, so no reset is required.
--
-- OP_BUS_WE is deliberately combinational. Registering it would delay the
-- capture by one IP_DST_CLK cycle past the acknowledge, allowing a fast source
-- to reload the hold register before it is captured.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity cdc_bus_handshake is
    generic (
        G_BUS_WIDTH : integer := 32
    );
    port (
        IP_SRC_CLK : in  std_logic;
        IP_BUS     : in  std_logic_vector(G_BUS_WIDTH-1 downto 0);
        IP_DST_CLK : in  std_logic;
        OP_BUS     : out std_logic_vector(G_BUS_WIDTH-1 downto 0);
        OP_BUS_WE  : out std_logic
    );
end cdc_bus_handshake;

architecture cdc_bus_handshake of cdc_bus_handshake is

    -- Source domain
    signal sBus     : std_logic_vector(G_BUS_WIDTH-1 downto 0) := (others => '0');
    signal sReq     : std_logic := '0';
    signal sAckMeta : std_logic := '0';
    signal sAckSync : std_logic := '0';

    -- Destination domain
    signal sReqMeta : std_logic := '0';
    signal sReqSync : std_logic := '0';
    signal sAck     : std_logic := '0';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sAckMeta : signal is "TRUE";
    attribute ASYNC_REG of sAckSync : signal is "TRUE";
    attribute ASYNC_REG of sReqMeta : signal is "TRUE";
    attribute ASYNC_REG of sReqSync : signal is "TRUE";

begin

    pSource : process (IP_SRC_CLK)
    begin
        if rising_edge(IP_SRC_CLK) then
            sAckMeta <= sAck;
            sAckSync <= sAckMeta;
            if sAckSync = sReq then
                sBus <= IP_BUS;
                sReq <= not sReq;
            end if;
        end if;
    end process pSource;

    pDestination : process (IP_DST_CLK)
    begin
        if rising_edge(IP_DST_CLK) then
            sReqMeta <= sReq;
            sReqSync <= sReqMeta;
            sAck     <= sReqSync;
        end if;
    end process pDestination;

    OP_BUS    <= sBus;
    OP_BUS_WE <= sReqSync xor sAck;

end cdc_bus_handshake;
