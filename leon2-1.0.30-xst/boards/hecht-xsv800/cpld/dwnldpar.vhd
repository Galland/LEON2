library ieee;
use ieee.std_logic_1164.all;

entity dwnldpar is
  port(
    -- parallel port data, control, and status pins
    ppc : in std_logic_vector(3 downto 0);

    -- serial port
    rxd    : in std_logic;
    txd    : out std_logic;
    cts    : in std_logic;
    rts    : out std_logic;
    
    -- Virtex FPGA pins
    v_tck   : out std_logic;            -- driver to Virtex JTAG clock
    v_cclk  : out std_logic;            -- driver to Virtex config clock
    v_progb : out std_logic;            -- driver to Virtex program pin
    v_done  : in  std_logic;            -- input from Virtex done pin
    v_d     : out std_logic;            -- drivers to Virtex data pins
    v_m     : out std_logic_vector(2 downto 0);  -- Virtex config mode pins

    v_rxd    : out std_logic;
    v_txd    : in std_logic;
    v_cts    : out std_logic;
    v_rts    : in std_logic;
    
    ceb    : out std_logic;             -- Flash chip-enable
    resetb : out std_logic;   -- reset for video input and Ethernet chips

    bar: out std_logic_vector(9 downto 5);	-- LED bargraph

    -- Ethernet configuration
    cfg: out std_logic_vector(1 downto 0);
    mf: out std_logic_vector(4 downto 0);
    fde: out std_logic;
    mddis: out std_logic;
    -- Ethernet status    
    ledsb: in std_logic;
    ledrb: in std_logic;
    ledtb: in std_logic;
    ledlb: in std_logic;
    ledcb: in std_logic
    );
end dwnldpar;

architecture dwnldpar_arch of dwnldpar is
  constant SLAVE_SERIAL_MODE : std_logic_vector(2 downto 0) := "111";
begin
  -- disable other chips on the XSV Board so they don't interfere
  -- during the configuration of the Virtex FPGA
  -- disable flash -- until config is done
  ceb    <= '1';-- when v_done = '0' else 'Z';
  -- disable the video input and Ethernet chips until config is done
  resetb <= '0' when v_done = '0' else '1';

  -- deactivate Virtex JTAG circuit
  v_tck  <= '0';                         
  -- connect Virtex configuration pins
  v_m     <= SLAVE_SERIAL_MODE;         -- set Virtex config mode pins
  v_progb <= ppc(0);  -- Virtex programming pulse comes from parallel port
  v_cclk  <= ppc(1);  -- Virtex config clock comes from parallel port
  -- config bitstream comes from parallel port control pin until 
  -- config is done and then gets 'Z'
  v_d  <= ppc(3) when v_done = '0' else 'Z';

  -- serial port route through
  v_rxd <= rxd;
  txd <= v_txd;
  v_cts <= cts;
  rts <= v_rts;
  
  -- control ethernet chip
  mddis <= '0';                    -- management over MDC and MDIO enabled
  fde <= '1';                      -- full duplex enable
  cfg(0) <= '0';                   -- 10MBit/s
  cfg(1) <= '0';                   -- advertise all
  mf(0) <= '1';                    -- Auto-negotiation enabled
  mf(1) <= '0';                    -- DTE
  mf(2) <= '0';                    -- 4Bit
  mf(3) <= '0';                    -- Scrambler enabled
  mf(4) <= '0';                    -- advertise all
  -- display status of ethernet PHY
  bar(9) <= not ledsb;            -- 100MBit/s
  bar(8) <= not ledrb;            -- receive
  bar(7) <= not ledtb;            -- transmit
  bar(6) <= not ledlb;            -- link
  bar(5) <= not ledcb;            -- collision

end dwnldpar_arch;

