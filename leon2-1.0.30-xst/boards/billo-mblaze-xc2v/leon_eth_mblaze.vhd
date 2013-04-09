----------------------------------------------------------------------------------------------------------------------------
-- LEON2 Wrapper to the Xilinx Microblaze & Multimedia board
--
-- Description: LEON2 Wrapper to the mblaze board. Only four banks of srams are used by leon2, one is kept unused for other
--              applications. Leon top entity is not used (leon.vhd, leon_eth.vhd), as long as mblaze board needs a different 
--              pad instatiation scheme due to the fact of having  separate sram data/control/address lines.
--
-- Comments to Eduardo Billo - eduardo.billo@ic.unicamp.br
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.target.all;
use work.config.all;
use work.iface.all;
use work.tech_map.all;
-- pragma translate_off
use work.debug.all;
-- pragma translate_on

entity leon_eth_mblaze is
  port (
    -- SRAM Memory
    ram_address0 : out std_logic_vector(18 downto 0);
    ram_address1 : out std_logic_vector(18 downto 0);
    ram_address2 : out std_logic_vector(18 downto 0);
    ram_address3 : out std_logic_vector(18 downto 0);
    ram_data0    : inout std_logic_vector(31 downto 0);
    ram_data1    : inout std_logic_vector(31 downto 0);
    ram_data2    : inout std_logic_vector(31 downto 0);
    ram_data3    : inout std_logic_vector(31 downto 0);
    ram_cen   	 : out std_logic_vector(3 downto 0);
    ram_oen    	 : out std_logic_vector(3 downto 0);
    ram_wen      : out std_logic_vector(3 downto 0);
    ram_wena   	 : out std_logic_vector(3 downto 0);
    ram_wenb   	 : out std_logic_vector(3 downto 0);
    ram_wenc   	 : out std_logic_vector(3 downto 0);
    ram_wend   	 : out std_logic_vector(3 downto 0);
    ram_clk      : out std_logic_vector(3 downto 0);
    ram_clken    : out std_logic_vector(3 downto 0);
    ram_burst    : out std_logic_vector(3 downto 0);

    -- RS232 
    rxd      	 : inout std_logic;
    txd     	 : inout std_logic;
    
    -- DSU	
    dsuen   	 : in    std_logic;
    dsutx   	 : out   std_logic;
    dsurx   	 : in    std_logic;
    dsubre   	 : in    std_logic;
    dsuact 	 : out   std_logic;

    -- Ethernet	
    emdio   	 : inout std_logic;
    etx_clk 	 : in    std_logic;
    erx_clk 	 : in    std_logic;
    erxd    	 : in    std_logic_vector(3 downto 0);
    erx_dv  	 : in    std_logic;
    erx_er  	 : in    std_logic;
    erx_col  	 : in    std_logic;
    erx_crs 	 : in    std_logic;
    etxd    	 : out   std_logic_vector(3 downto 0);
    etx_en    	 : out   std_logic;
    etx_er  	 : out   std_logic;
    emdc    	 : out   std_logic;
    enetslew     : out   std_logic_vector(1 downto 0);
    enetpause    : out   std_logic;

    -- Clock Generator
    master_clk_p       : in std_logic; -- 27 Mhz clk
    mem_clk_fbout_p    : out std_logic;
    mem_clk_fbin_p     : in std_logic;
    extend_dcm_reset_p : in std_logic;
    startup_p          : out std_logic;

    -- Processor error
    errorn    	 : out std_logic
  );
end;

architecture rtl of leon_eth_mblaze is
  component mcore
    port (
      resetn   : in  std_logic;
      clk      : in  clk_type;
      clkn     : in  clk_type;
      pciclk   : in  clk_type;
      memi     : in  memory_in_type;
      memo     : out memory_out_type;
      ioi      : in  io_in_type;
      ioo      : out io_out_type;
      pcii     : in  pci_in_type;
      pcio     : out pci_out_type;
      dsi      : in  dsuif_in_type;
      dso      : out dsuif_out_type;
      sdo      : out sdram_out_type;
      ethi     : in  eth_in_type;
      etho     : out eth_out_type;
      cgo      : in  clkgen_out_type;
      test     : in    std_logic);
  end component;

  -- specific clock generator
  component mblaze_clkgen 
    port (
      master_clock_p      : in std_logic;
      extend_dcm_reset_p  : in std_logic;
      mem_clk_fbin_p      : in std_logic; 
      mem_clk_fbout_p     : out std_logic;
      memory_bank0_clk_p  : out std_logic;
      memory_bank1_clk_p  : out std_logic;
      memory_bank2_clk_p  : out std_logic;
      memory_bank3_clk_p  : out std_logic;
      system_clk_p        : out  std_logic;
      system_clk_n        : out  std_logic;
      startup_p           : out std_logic);
  end component;
 
signal vcc, gnd, resetno 	       : std_logic;
signal system_clk, system_clkn, pciclk : clk_type;
signal memi     		       : memory_in_type;
signal memo     		       : memory_out_type;
signal ioi      		       : io_in_type;
signal ioo      		       : io_out_type;
signal pcii     		       : pci_in_type;
signal pcio     		       : pci_out_type;
signal dsi      		       : dsuif_in_type;
signal dso      		       : dsuif_out_type;
signal sdo      		       : sdram_out_type;
signal ethi     		       : eth_in_type;
signal etho     		       : eth_out_type;
signal cgo      		       : clkgen_out_type;
signal brdyn    		       : std_logic;
signal bexcn    		       : std_logic;
signal test    			       : std_logic;
signal data0_int                       : std_logic_vector(31 downto 0); 
signal data1_int                       : std_logic_vector(31 downto 0); 
signal data2_int                       : std_logic_vector(31 downto 0); 
signal data3_int                       : std_logic_vector(31 downto 0); 
signal address  		       : std_logic_vector(27 downto 0);
signal ramsn    		       : std_logic_vector(4 downto 0);
signal ramoen   		       : std_logic_vector(4 downto 0);
signal rwen     		       : std_logic_vector(3 downto 0);
signal sram_wen   		       : std_logic;
signal pio      		       : std_logic_vector(15 downto 0);
signal startup    		       : std_logic;

begin  
  gnd <= '0'; vcc <= '1';
  -- Startup to the rest of the board
  startup_p <= startup;
  
  reset_pad   : smpad port map (startup, resetno);       -- reset (generated by mblaze clock generator)
  error_pad   : outpad generic map (2) port map (ioo.errorn, errorn); -- cpu error mode

  cgo.pcilock <= vcc;
  cgo.clklock <= startup; 

  ----------------------------------------------------
  -- Main processor core
  ----------------------------------------------------
  mcore0  : mcore
  port map (
    resetn => resetno, clk => system_clk, clkn => system_clkn, pciclk => pciclk,
    memi => memi, memo => memo, ioi => ioi, ioo => ioo,
    pcii => pcii, pcio => pcio, dsi => dsi, dso => dso, sdo => sdo,
    ethi => ethi, etho => etho, cgo => cgo, test => test);

  ----------------------------------------------------
  -- SRAM MEMORY
  -- :: In the microblaze board, data/control/address lines individual for each bank
  ----------------------------------------------------
  d_pads_bank0: for i in 0 to 31 generate                   -- data bus bank0
    d_pad_bank0 : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), data0_int(i), ram_data0(i));
  end generate;

  d_pads_bank1: for i in 0 to 31 generate                   -- data bus bank1
    d_pad_bank1 : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), data1_int(i), ram_data1(i));
  end generate;

  d_pads_bank2: for i in 0 to 31 generate                   -- data bus bank2
    d_pad_bank2 : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), data2_int(i), ram_data2(i));
  end generate;

  d_pads_bank3: for i in 0 to 31 generate                   -- data bus bank3
    d_pad_bank3 : iopad generic map (3) port map (memo.data(i), memo.bdrive((31-i)/8), data3_int(i), ram_data3(i));
  end generate;

  memidata : process (data0_int, data1_int, data2_int, data3_int, memo.ramsn)
  begin
    memi.data <= (others => '0');
    if (memo.ramsn(0) = '0') then
      memi.data <= data0_int;
    elsif (memo.ramsn(1) = '0') then
      memi.data <= data1_int;
    elsif (memo.ramsn(2) = '0') then
      memi.data <= data2_int;
    elsif (memo.ramsn(3) = '0') then
      memi.data <= data3_int;
    end if;
  end process;

  a_pads_bank0: for i in 0 to 27 generate                   -- memory address
    a_pad : outpad generic map (3) port map (memo.address(i), address(i));
  end generate;

  rwen_pads : for i in 0 to 3 generate                        -- ram write strobe
    rwen_pad : iopad generic map (2) port map (memo.wrn(i), gnd, memi.wrn(i), rwen(i));
  end generate;
  
  ramsn_pads : for i in 0 to 4 generate               -- ram oen/rasn
    ramsn_pad : outpad generic map (2) port map (memo.ramsn(i), ramsn(i));
  end generate;

  ramoen_pads : for i in 0 to 4 generate              -- ram chip select
    ramoen_pad : outpad generic map (2) port map (memo.ramoen(i), ramoen(i));
  end generate;
  
  brdyn_pad   : inpad port map (brdyn, memi.brdyn);     -- bus ready
  bexcn_pad   : inpad port map (bexcn, memi.bexcn);     -- bus exception

  ram_address0 <= address(20 downto 2);
  ram_address1 <= address(20 downto 2);
  ram_address2 <= address(20 downto 2);
  ram_address3 <= address(20 downto 2);
  
  ram_cen(0) <= ramsn(0);
  ram_cen(1) <= ramsn(1);
  ram_cen(2) <= ramsn(2);
  ram_cen(3) <= ramsn(3);
  ram_oen(0) <= ramoen(0);
  ram_oen(1) <= ramoen(1);
  ram_oen(2) <= ramoen(2);
  ram_oen(3) <= ramoen(3);
 
  sram_wen <= rwen(0) and rwen(1) and rwen(2) and rwen(3);
  
  ram_wena(0) <= rwen(0);
  ram_wenb(0) <= rwen(1);
  ram_wenc(0) <= rwen(2);
  ram_wend(0) <= rwen(3);
  ram_wen(0) <= sram_wen or ramsn(0);

  ram_wena(1) <= rwen(0);
  ram_wenb(1) <= rwen(1);
  ram_wenc(1) <= rwen(2);
  ram_wend(1) <= rwen(3);
  ram_wen(1) <= sram_wen or ramsn(1);

  ram_wena(2) <= rwen(0);
  ram_wenb(2) <= rwen(1);
  ram_wenc(2) <= rwen(2);
  ram_wend(2) <= rwen(3);
  ram_wen(2) <= sram_wen or ramsn(2);

  ram_wena(3) <= rwen(0);
  ram_wenb(3) <= rwen(1);
  ram_wenc(3) <= rwen(2);
  ram_wend(3) <= rwen(3);
  ram_wen(3) <= sram_wen or ramsn(3);
  
  -- ram_burst not enabled
  ram_burst <= "0000";

  -- Sram clocks enabled
  ram_clken <= "0000";

  -- waitstates not needed
  brdyn <= '1';
  bexcn <= '1';
  
  ----------------------------------------------------
  -- PIO
  ----------------------------------------------------
  pio_pads : for i in 0 to 15 generate                -- parallel I/O port
    pio_pad : smiopad generic map (2) port map (ioo.piol(i), ioo.piodir(i), ioi.piol(i), pio(i));
  end generate;

  -- uart1
  rxd <= pio(14);
  txd <= pio(15);

  ----------------------------------------------------
  -- DSU 
  ----------------------------------------------------
  ds : if DEBUG_UNIT generate
    dsuen_pad   : inpad port map (dsuen, dsi.dsui.dsuen);     -- DSU enable
    dsutx_pad   : outpad generic map (1) port map (dso.dcomo.dsutx, dsutx);
    dsurx_pad   : inpad port map (dsurx, dsi.dcomi.dsurx);    -- DSU receive data
    dsubre_pad  : inpad port map (dsubre, dsi.dsui.dsubre);   -- DSU break
    dsuact_pad  : outpad generic map (1) port map (dso.dsuo.dsuact, dsuact);
  end generate;

  ----------------------------------------------------
  -- Ethernet 
  ----------------------------------------------------
  eth_pads : if ETHEN generate
    emdio_pad : iopad generic map (2) port map (etho.mdio_o, etho.mdio_oe, ethi.mdio_i, emdio);
    etx_clk_pad   : inpad port map (etx_clk, ethi.tx_clk);
    erx_clk_pad   : inpad port map (erx_clk, ethi.rx_clk);
    erxd_pads: for i in 0 to 3 generate                       -- data bus
      erxd_pad   : inpad port map (erxd(i), ethi.rxd(i));
    end generate;
    erx_dv_pad   : inpad port map (erx_dv, ethi.rx_dv);
    erx_er_pad   : inpad port map (erx_er, ethi.rx_er);
    erx_col_pad   : inpad port map (erx_col, ethi.rx_col);
    erx_crs_pad   : inpad port map (erx_crs, ethi.rx_crs);
    etxd_pads: for i in 0 to 3 generate                       -- data bus
      etxd_pad   : outpad generic map (1) port map (etho.txd(i), etxd(i));
    end generate;
    etx_en_pad   : outpad generic map (1) port map (etho.tx_en, etx_en);
    etx_er_pad   : outpad generic map (1) port map (etho.tx_er, etx_er);
    emdc_pad   : outpad generic map (1) port map (etho.mdc, emdc);
    enetslew <= "11";
    enetpause <= '0';
  end generate;
  
  ----------------------------------------------------
  -- Clock Generation 
  ----------------------------------------------------
  clockgen0: mblaze_clkgen  
    port map (
      master_clock_p      => master_clk_p,
      extend_dcm_reset_p  => extend_dcm_reset_p,
      mem_clk_fbin_p      => mem_clk_fbin_p,
      mem_clk_fbout_p     => mem_clk_fbout_p,
      memory_bank0_clk_p  => ram_clk(0),
      memory_bank1_clk_p  => ram_clk(1),
      memory_bank2_clk_p  => ram_clk(2),
      memory_bank3_clk_p  => ram_clk(3),
      system_clk_p        => system_clk,
      system_clk_n        => system_clkn,
      startup_p           => startup);
end rtl;
