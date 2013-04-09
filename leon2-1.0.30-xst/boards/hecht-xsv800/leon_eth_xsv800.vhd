library IEEE;
use IEEE.std_logic_1164.all;
use work.target.all;
use work.config.all;
use work.iface.all;
use work.tech_map.all;
-- pragma translate_off
use work.debug.all;
-- pragma translate_on

entity leon_eth_xsv800 is

  port (
    resetn : in  std_logic;
    clk    : in  std_logic;
    error  : out std_logic;

    address1 : out   std_logic_vector(18 downto 0);
    data1    : inout std_logic_vector(15 downto 0);
    address2 : out   std_logic_vector(18 downto 0);
    data2    : inout std_logic_vector(15 downto 0);

    ramsn1  : out std_logic;
    ramoen1 : out std_logic;
    ramsn2  : out std_logic;
    ramoen2 : out std_logic;

    rwen1 : inout std_logic;
    rwen2 : inout std_logic;

    rxd1 : inout std_logic;
    txd1 : inout std_logic;
--    rts1 : inout std_logic;
--    cts1 : inout std_logic;
    

    
    dsuen   : in    std_logic;
    dsutx   : out   std_logic;
    dsurx   : in    std_logic;
    dsubre  : in    std_logic;
    dsuact  : out   std_logic;

    emdio   : inout std_logic;
    etx_clk : in    std_logic;
    erx_clk : in    std_logic;
    erxd    : in    std_logic_vector(3 downto 0);
    erx_dv  : in    std_logic;
    erx_er  : in    std_logic;
    erx_col : in    std_logic;
    erx_crs : in    std_logic;
    etxd    : out   std_logic_vector(3 downto 0);
    etx_en  : out   std_logic;
    etx_er  : out   std_logic;
    emdc    : out   std_logic
    
);

end leon_eth_xsv800;

architecture wrap of leon_eth_xsv800 is

  component leon_eth
    port (
      resetn  : in    std_logic;
      clk     : in    std_logic;
      pllref  : in    std_logic;
      plllock : out   std_logic;
      errorn  : out   std_logic;
      address : out   std_logic_vector(27 downto 0);
      data    : inout std_logic_vector(31 downto 0);
      ramsn   : out   std_logic_vector(4 downto 0);
      ramoen  : out   std_logic_vector(4 downto 0);
      rwen    : inout std_logic_vector(3 downto 0);
      romsn   : out   std_logic_vector(1 downto 0);
      iosn    : out   std_logic;
      oen     : out   std_logic;
      read    : out   std_logic;
      writen  : inout std_logic;
      brdyn   : in    std_logic;
      bexcn   : in    std_logic;
      sdcke   : out   std_logic_vector (1 downto 0);
      sdcsn   : out   std_logic_vector (1 downto 0);
      sdwen   : out   std_logic;
      sdrasn  : out   std_logic;
      sdcasn  : out   std_logic;
      sddqm   : out   std_logic_vector (3 downto 0);
      sdclk   : out   std_logic;
      pio     : inout std_logic_vector(15 downto 0);
      wdogn   : out   std_logic;
      dsuen   : in    std_logic;
      dsutx   : out   std_logic;
      dsurx   : in    std_logic;
      dsubre  : in    std_logic;
      dsuact  : out   std_logic;
      emdio   : inout std_logic;
      etx_clk : in    std_logic;
      erx_clk : in    std_logic;
      erxd    : in    std_logic_vector(3 downto 0);
      erx_dv  : in    std_logic;
      erx_er  : in    std_logic;
      erx_col : in    std_logic;
      erx_crs : in    std_logic;
      etxd    : out   std_logic_vector(3 downto 0);
      etx_en  : out   std_logic;
      etx_er  : out   std_logic;
      emdc    : out   std_logic;
      emddis  : out   std_logic;
      epwrdwn : out   std_logic;
      ereset  : out   std_logic;
      esleep  : out   std_logic;
      epause  : out   std_logic;
      test    : in    std_logic); 
  end component;

  signal pllref : std_logic;
  signal errorn : std_logic;
  signal address  : std_logic_vector(27 downto 0);
  signal data     : std_logic_vector(31 downto 0);
  signal ramsn    : std_logic_vector(4 downto 0);
  signal ramoen   : std_logic_vector(4 downto 0);
  signal rwen     : std_logic_vector(3 downto 0);
  signal romsn    : std_logic_vector(1 downto 0);
  signal iosn     : std_logic;
  signal oen      : std_logic;
  signal read     : std_logic;
  signal writen   : std_logic;
  signal brdyn    : std_logic;
  signal bexcn    : std_logic;
  signal pio      : std_logic_vector(15 downto 0);
  signal wdogn    : std_logic;
  signal test     : std_logic;
--  signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
  signal emddis  : std_logic;
  signal epwrdwn : std_logic;
  signal ereset  : std_logic;
  signal esleep  : std_logic;
  signal epause  : std_logic;
  
begin  -- wrap

  leon_eth_1: leon_eth
    port map (
      resetn  => resetn,
      clk     => clk,
      pllref  => pllref,
      plllock => open,
      errorn  => errorn,
      address => address,
      data    => data,
      ramsn   => ramsn,
      ramoen  => ramoen,
      rwen    => rwen,
      romsn   => romsn,
      iosn    => iosn,
      oen     => oen,
      read    => read,
      writen  => writen,
      brdyn   => brdyn,
      bexcn   => bexcn,
      sdcke   => open,
      sdcsn   => open,
      sdwen   => open,
      sdrasn  => open,
      sdcasn  => open,
      sddqm   => open,
      sdclk   => open,
      pio     => pio,
      wdogn   => wdogn,
      dsuen   => dsuen,
      dsutx   => dsutx,
      dsurx   => dsurx,
      dsubre  => dsubre,
      dsuact  => dsuact,
      emdio   => emdio,
      etx_clk => etx_clk,
      erx_clk => erx_clk,
      erxd    => erxd,
      erx_dv  => erx_dv,
      erx_er  => erx_er,
      erx_col => erx_col,
      erx_crs => erx_crs,
      etxd    => etxd,
      etx_en  => etx_en,
      etx_er  => etx_er,
      emdc    => emdc,
      emddis  => emddis,
      epwrdwn => epwrdwn,
      ereset  => ereset,
      esleep  => esleep,
      epause  => epause,
      test    => test);  

  pllref <= '0';

  error <= '1' when errorn = '0' else 'Z';

  address1 <= address(20 downto 2);
  address2 <= address(20 downto 2);
  data1    <= data(15 downto 0);
  data2    <= data(31 downto 16);
  ramsn1   <= ramsn(0);
  ramsn2   <= ramsn(0);
  ramoen1  <= ramoen(0);
  ramoen2  <= ramoen(0);
  rwen1    <= rwen(0);
  rwen2    <= rwen(0);

  brdyn <= '1';
  bexcn <= '1';

  rxd1 <= pio(14);
  txd1 <= pio(15);
--  rts1 <= pio(13);
--  cts1 <= pio(12);
--  dsurx <= dsurx;
--  dsutx <= dsutx;
--  dsuen <= dsuen;
--  dsubre <= dsubre;
--  dsuact <= dsuact;
  
end wrap;
