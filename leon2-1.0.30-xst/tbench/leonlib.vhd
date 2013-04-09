-----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
-----------------------------------------------------------------------------
-- Entity: 	leonlib
-- File:	leonlib.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	package containing LEON 
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.iface.all;

package leonlib is

component leon
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 7 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk divider output
    sa       : out std_logic_vector(14 downto 0); 	-- optional sdram address
    sd       : inout std_logic_vector(63 downto 0); 	-- optional sdram data

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;
    test     : in    std_logic
  );
end component; 

component leon_pci
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 7 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk divider output
    sa       : out std_logic_vector(14 downto 0); 	-- optional sdram address
    sd       : inout std_logic_vector(63 downto 0); 	-- optional sdram data

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;
    test     : in    std_logic;

    pci_rst_in_n   : in std_logic;		-- PCI bus
    pci_clk_in 	   : in std_logic;
    pci_gnt_in_n   : in std_logic;
    pci_idsel_in   : in std_logic;  -- ignored in host bridge core
    pci_lock_n     : inout std_logic;  -- Phoenix core: input only
    pci_ad 	   : inout std_logic_vector(31 downto 0);
    pci_cbe_n 	   : inout std_logic_vector(3 downto 0);
    pci_frame_n    : inout std_logic;
    pci_irdy_n 	   : inout std_logic;
    pci_trdy_n 	   : inout std_logic;
    pci_devsel_n   : inout std_logic;
    pci_stop_n 	   : inout std_logic;
    pci_perr_n 	   : inout std_logic;
    pci_par 	   : inout std_logic;    
    pci_req_n 	   : inout std_logic;  -- tristate pad but never read
    pci_serr_n     : inout std_logic;  -- open drain output
    pci_host   	   : in std_logic;
    pci_66	   : in std_logic;

    pci_arb_req_n  : in  std_logic_vector(0 to 3);
    pci_arb_gnt_n  : out std_logic_vector(0 to 3);

    power_state    : out std_logic_vector(1 downto 0);
    pme_enable     : out std_logic;
    pme_clear      : out std_logic;
    pme_status     : in  std_logic

  );
end component; 

component leon_eth
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 7 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk output
    sa       : out std_logic_vector(14 downto 0); 	-- optional sdram address
    sd       : inout std_logic_vector(63 downto 0); 	-- optional sdram data

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;

-- ethernet
    emdio     : inout std_logic;
    etx_clk : in std_logic;
    erx_clk : in std_logic;
    erxd    : in std_logic_vector(3 downto 0);   
    erx_dv  : in std_logic; 
    erx_er  : in std_logic; 
    erx_col : in std_logic;
    erx_crs : in std_logic;

    etxd : out std_logic_vector(3 downto 0);   
    etx_en : out std_logic; 
    etx_er : out std_logic; 
    emdc : out std_logic;    

    emddis : out std_logic;    
    epwrdwn : out std_logic;
    ereset : out std_logic;
    esleep : out std_logic;
    epause : out std_logic;

    test     : in    std_logic
  );
end component;

component leon_eth_pci
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    rwen     : inout std_logic_vector(3 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    read     : out   std_logic;
    writen   : inout std_logic;

    brdyn    : in    std_logic;
    bexcn    : in    std_logic;

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 7 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk output
    sa       : out std_logic_vector(14 downto 0); 	-- optional sdram address
    sd       : inout std_logic_vector(63 downto 0); 	-- optional sdram data

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsubre   : in    std_logic;
    dsuact   : out   std_logic;

    test     : in    std_logic;

    pci_rst_in_n   : in std_logic;		-- PCI bus
    pci_clk_in 	   : in std_logic;
    pci_gnt_in_n   : in std_logic;
    pci_idsel_in   : in std_logic;  -- ignored in host bridge core
    pci_lock_n     : inout std_logic;  -- Phoenix core: input only
    pci_ad 	   : inout std_logic_vector(31 downto 0);
    pci_cbe_n 	   : inout std_logic_vector(3 downto 0);
    pci_frame_n    : inout std_logic;
    pci_irdy_n 	   : inout std_logic;
    pci_trdy_n 	   : inout std_logic;
    pci_devsel_n   : inout std_logic;
    pci_stop_n 	   : inout std_logic;
    pci_perr_n 	   : inout std_logic;
    pci_par 	   : inout std_logic;    
    pci_req_n 	   : inout std_logic;  -- tristate pad but never read
    pci_serr_n     : inout std_logic;  -- open drain output
    pci_host   	   : in std_logic;
    pci_66	   : in std_logic;

    pci_arb_req_n  : in  std_logic_vector(0 to 3);
    pci_arb_gnt_n  : out std_logic_vector(0 to 3);

    power_state    : out std_logic_vector(1 downto 0);
    pme_enable     : out std_logic;
    pme_clear      : out std_logic;
    pme_status     : in  std_logic;

-- ethernet
    emdio     : inout std_logic;
    etx_clk : in std_logic;
    erx_clk : in std_logic;
    erxd    : in std_logic_vector(3 downto 0);   
    erx_dv  : in std_logic; 
    erx_er  : in std_logic; 
    erx_col : in std_logic;
    erx_crs : in std_logic;

    etxd : out std_logic_vector(3 downto 0);   
    etx_en : out std_logic; 
    etx_er : out std_logic; 
    emdc : out std_logic;    

    emddis : out std_logic;    
    epwrdwn : out std_logic;
    ereset : out std_logic;
    esleep : out std_logic;
    epause : out std_logic
  );
end component;

end; 



