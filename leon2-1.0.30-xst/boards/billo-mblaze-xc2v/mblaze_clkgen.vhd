----------------------------------------------------------------------------------------------------------------------------
-- CLOCK GENERATION
--
-- Description: This module generates both the clock to the LEON2 processor and the SRAM memory banks. The tech_virtex2  
--              clockgen macro was not used because this board needs the generation of 4 clks/pads (one for each SRAM bank).
--              So, to avoid changing the leon2 internals, this clock wrapper is used. 
-- 
-- Comments to Eduardo Billo - eduardo.billo@ic.unicamp.br
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_UNSIGNED.all;
use work.config.all;

entity mblaze_clkgen is
port (
  master_clock_p      : in std_logic;
  extend_dcm_reset_p  : in std_logic;
  mem_clk_fbin_p      : in std_logic; 
  mem_clk_fbout_p     : out std_logic;
  memory_bank0_clk_p  : out std_logic;
  memory_bank1_clk_p  : out std_logic;
  memory_bank2_clk_p  : out std_logic;
  memory_bank3_clk_p  : out std_logic;
  system_clk_p        : out std_logic;
  system_clk_n        : out std_logic;
  startup_p           : out std_logic
);
end;

architecture rtl of mblaze_clkgen is

signal master_clock         :  std_logic;
signal system_clk           :  std_logic;
signal system_clkn          :  std_logic;
signal main_clk0            :  std_logic;
signal fb_main_dcm          :  std_logic;
signal fb_memory_dcm        :  std_logic;
signal extend_dcm_reset     :  std_logic;
signal memory_clk           :  std_logic;
signal memory_clk0          :  std_logic;
signal dcm_reset            :  std_logic;
signal terminal_count       :  std_logic;
signal enable_reset_counter :  std_logic;
signal main_locked          :  std_logic;
signal memory_locked        :  std_logic;
signal dcm_reset_counter    :  std_logic_vector(15 downto 0);
signal mem_clk_fbin         :  std_logic;
signal mem_clk_fbout        :  std_logic;


component IBUFG port (I : in std_logic; O : out std_logic); end component;
component IBUF  port (I : in std_logic; O : out std_logic); end component;
component BUFG  port (I : in std_logic; O : out std_logic); end component;
component OBUF_F_12 port (I : in std_logic; O : out std_logic); end component;

component DCM 
generic (
  CLKIN_PERIOD : real := 37.037;
  CLKFX_DIVIDE : integer := 1;
  CLKFX_MULTIPLY : integer := 1);
port (
   CLKFB    : in std_logic;
   CLKIN    : in std_logic;
   DSSEN    : in std_logic;
   PSCLK    : in std_logic;
   PSEN     : in std_logic;
   PSINCDEC : in std_logic;
   RST      : in std_logic;
   CLK0     : out std_logic;
   CLK90    : out std_logic;
   CLK180   : out std_logic;
   CLK270   : out std_logic;
   CLK2X    : out std_logic;
   CLK2X180 : out std_logic;
   CLKDV    : out std_logic;
   CLKFX    : out std_logic;
   CLKFX180 : out std_logic;
   LOCKED   : out std_logic;
   PSDONE   : out std_logic;
   STATUS   : out std_logic_vector(7 downto 0));
end component;


begin

  dcm_reset            <= not dcm_reset_counter(15);
  enable_reset_counter <= not terminal_count AND extend_dcm_reset; 
  startup_p            <=  main_locked ; -- dll is locked allow emac and other to come out of reset

  master_clock_inst  : IBUFG port map ( I => master_clock_p, O => master_clock);
  fb_main_dcm_inst   : BUFG port map (I => main_clk0, O => fb_main_dcm);
  fb_memory_dcm_inst : BUFG port map (I => memory_clk0, O => fb_memory_dcm);
  system_clk_inst    : BUFG port map (I => system_clk, O => system_clk_p);
  system_clkn_inst   : BUFG port map (I => system_clkn, O => system_clk_n);
  dcm_reset_inst     : IBUF port map (I => extend_dcm_reset_p, O => extend_dcm_reset);

  memory_bank0_clk_inst : OBUF_F_12 port map (I => memory_clk, O => memory_bank0_clk_p);
  memory_bank1_clk_inst : OBUF_F_12 port map (I => memory_clk, O => memory_bank1_clk_p);
  memory_bank2_clk_inst : OBUF_F_12 port map (I => memory_clk, O => memory_bank2_clk_p);
  memory_bank3_clk_inst : OBUF_F_12 port map (I => memory_clk, O => memory_bank3_clk_p);

  mem_clk_fbin_inst : IBUFG port map (I => mem_clk_fbin_p, O => mem_clk_fbin);
  mem_clk_fbout_int : OBUF_F_12 port map (I => memory_clk0, O => mem_clk_fbout_p);


  dcm_reset_counter_inst : process (master_clock)
  begin
    if(master_clock='1' and master_clock'event) then
      if(enable_reset_counter = '1') then
        dcm_reset_counter <=  dcm_reset_counter + 1;
      end if;
    end if;
  end process;

  decode_term_count : process (dcm_reset_counter)
  begin
    if(dcm_reset_counter = "1111111111111111") then
      terminal_count <= '1';
    else
      terminal_count <= '0';
    end if;
  end process;

  main_dcm : DCM
  generic map (CLKFX_MULTIPLY => PLL_CLK_MUL, CLKFX_DIVIDE => PLL_CLK_DIV)
  port map (
    CLKFB      => fb_main_dcm,
    CLKIN      => master_clock,
    DSSEN      => '0',
    PSCLK      => '0',
    PSEN       => '0',
    PSINCDEC   => '0',
    RST        => dcm_reset,
    CLK0       => main_clk0,
    CLKFX      => system_clk,
    CLKFX180   => system_clkn,
    LOCKED     => main_locked
  );

  memory_dcm : DCM
  generic map (CLKFX_MULTIPLY => 4, CLKFX_DIVIDE => 1)
  port map (
    CLKFB      => mem_clk_fbin,
    CLKIN      => master_clock,
    DSSEN      => '0',
    PSCLK      => '0',
    PSEN       => '0',
    PSINCDEC   => '0',
    RST        => dcm_reset,
    CLK0       => memory_clk0,
    CLKFX      => memory_clk,
    LOCKED     => memory_locked
  );
end rtl;

