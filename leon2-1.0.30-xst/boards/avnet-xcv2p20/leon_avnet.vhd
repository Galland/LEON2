



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	leon_avnet
-- File:	leon_avnet.vhd
-- Author:	Michele Portolan - TIMA Laboratory
-- Description:	Leon wrapping for implementation in Avnet Xilinx V2P Development Kit
-- Enabled Features: DSU on serial port 1
--		   Output on serial port 2 (connector JP6)
--		   Full 32-bit SRAM access : 2038Kbytes
-- To do:		   SDRAM support
--		   Ethernet Access
--Last Modified: 7 October 2004
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon.all;
use work.target.all;
use work.config.all;
use work.iface.all;
use work.tech_map.all;

entity leon_avnet is
  port (
    resetn   : in    std_logic; 			-- system signals
    clk      : in    std_logic;
    pllref   : in    std_logic;
    plllock  : out   std_logic;

    errorn   : out   std_logic;
    address  : out   std_logic_vector(27 downto 0); 	-- memory bus

    data     : inout std_logic_vector(31 downto 0);

    ramsn    : out   std_logic_vector(4 downto 0);
    romsn    : out   std_logic_vector(1 downto 0);
    iosn     : out   std_logic;
    oen      : out   std_logic;
    rwen     : inout   std_logic_vector(3 downto 0);
    ramoen   : out   std_logic_vector(4 downto 0);
    read     : out   std_logic;
    writen   : inout std_logic; 		

-- sdram i/f
    sdcke    : out std_logic_vector ( 1 downto 0);  -- clk en
    sdcsn    : out std_logic_vector ( 1 downto 0);  -- chip sel
    sdwen    : out std_logic;                       -- write en
    sdrasn   : out std_logic;                       -- row addr stb
    sdcasn   : out std_logic;                       -- col addr stb
    sddqm    : out std_logic_vector ( 3 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk output

    pio      : inout std_logic_vector(15 downto 0); 	-- I/O port

    wdogn    : out   std_logic;				-- watchdog output

--    dsuen    : in    std_logic;
    dsutx    : out   std_logic;
    dsurx    : in    std_logic;
    dsuact   : out   std_logic;
    test     : in    std_logic;

--Bridge-related Signals
	gpio_cs_n: out std_logic;
	flash_cs_n : out std_logic

  );
end;

architecture rtl of leon_avnet is

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
    sddqm    : out std_logic_vector ( 3 downto 0);  -- data i/o mask
    sdclk    : out std_logic;                       -- sdram clk output
    sa       : out std_logic_vector(14 downto 0); 	-- optional sdram address
    sd       : inout std_logic_vector(31 downto 0); 	-- optional sdram data

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


signal int_oen   : std_logic;
signal int_ramsn   : std_logic_vector(4 downto 0);
signal int_sddqm    : std_logic_vector ( 3 downto 0); 
signal int_sdcsn    :    std_logic_vector ( 1 downto 0);  
signal sa  : std_logic_vector(14 downto 0);
signal sd  : std_logic_vector(31 downto 0);

begin


-- Leon core
  leon0  : leon
  port map (
    resetn =>resetn,--leon_reset, 
    clk => clk, pllref =>pllref,--loop_sdclk, 
    plllock =>plllock,errorn =>errorn,
    address =>address , data =>data,
    ramsn =>int_ramsn,ramoen =>ramoen,rwen =>rwen,
    romsn =>romsn,iosn =>iosn,oen=>oen,read =>read,writen=>writen,
    brdyn =>'0', bexcn =>'1',
    sdcke =>sdcke,sdcsn =>int_sdcsn, 
    sdwen =>sdwen, sdrasn =>sdrasn, sdcasn =>sdcasn,
    sddqm =>int_sddqm, sdclk =>sdclk, 
    sa=>sa, sd=>sd,
    pio =>pio,wdogn =>wdogn, 
    dsuen =>'1',--dsuen, 
    dsutx =>dsutx, dsurx=>dsurx ,
    dsubre=>resetn,--leon_reset,--dsubre, 
    dsuact=>dsuact,test =>test
    );



--Bridge-related Signals
gpio_cs_n <= '1';
flash_cs_n <= '1';
 

sdcsn <="11";--int_sdcsn;

bs: process(int_sdcsn(0), int_ramsn(0),int_sddqm)
       begin
         if (int_sdcsn(0)='0') then
         	sddqm<=int_sddqm;
         else
             sddqm<="0000"; --"1100" = 16 bits ram, "0000" = 32 bits ram
         end if;
       end process;

ramsn <= int_ramsn;


end ;
