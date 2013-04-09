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
-- Entity:      tb_msp
-- File:        tb_msp.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Test bench to run the microsparc test suite.
------------------------------------------------------------------------------  
-- Version control:
-- 10-09-1999:  : First implemetation
-- 26-09-1999:  : Release 1.0
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use work.iface.all;
use work.leonlib.all;

entity tb_msp is
end; 

architecture behav of tb_msp is

component mspram
  generic ( mspfile : string := "mspfile";	-- list of test files
            romfile : string := "rom.dat");	-- rom boot file
  port (  
    A 	   : in std_logic_vector(15 downto 0);

    D 	   : inout std_logic_vector(31 downto 0);

    romsel : in std_logic;
    romoen : in std_logic;
    ramsel : in std_logic;
    ramoen : in std_logic;
    write  : in std_logic_vector(3 downto 0);
    rst    : out std_logic;
    error  : in std_logic
  );
end component; 

TYPE logic_xlhz_table IS ARRAY (std_logic'LOW TO std_logic'HIGH) OF std_logic;

CONSTANT cvt_to_xlhz : logic_xlhz_table := (
                         'Z',  -- 'U'
                         'Z',  -- 'X'
                         'L',  -- '0'
                         'H',  -- '1'
                         'Z',  -- 'Z'
                         'Z',  -- 'W'
                         'Z',  -- 'L'
                         'Z',  -- 'H'
                         'Z'   -- '-'
                        );

signal clk : std_logic := '1';
signal Rst    : std_logic;			-- Reset
constant romfile : string := "us2test/bootmsp.rom";
constant mspfile : string := "us2test/mspfiles";

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);
signal sa       : std_logic_vector(14 downto 0);
signal sd       : std_logic_vector(63 downto 0);

signal ramsn    : std_logic_vector(4 downto 0);
signal ramoen   : std_logic_vector(4 downto 0);
signal wrn      : std_logic_vector(3 downto 0);
signal romsn    : std_logic_vector(1 downto 0);
signal iosn     : std_logic;
signal oen      : std_logic;
signal read     : std_logic;
signal write    : std_logic;
signal brdyn    : std_logic := '0';
signal bexcn    : std_logic := '1';
signal error    : std_logic;
signal wdog     : std_logic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
signal test     : std_logic := '0';

signal pio	: std_logic_vector(15 downto 0);
signal GND : std_logic := '0';
signal VCC : std_logic := '1';
signal NC : std_logic := 'Z';
signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
signal sdwen    : std_logic;                       -- write en
signal sdrasn   : std_logic;                       -- row addr stb
signal sdcasn   : std_logic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 7 downto 0);  -- data i/o mask
signal sdclk: std_logic;       
signal plllock: std_logic;       

function buskeep (signal v : in std_logic_vector) return std_logic_vector is
variable res : std_logic_vector(v'range);
begin
  for i in v'range loop res(i) := cvt_to_xlhz(v(i)); end loop;
  return(res);
end;

begin

  clk <= not clk after 10 ns;

  pio(1 downto 0) <= "11";	-- 32-bit data bus
  pio(2) <= '1';		-- EDAC enable
  wdog <= 'H';
  dsuen <= '0'; dsurx <= '1'; dsubre <= '0';
  error <= 'H';


  p0 : leon port map (
            rst, clk, sdclk, plllock, 

	    error, address, data, 

	    ramsn, ramoen, wrn, romsn, iosn, oen, read, write, brdyn, 
	    bexcn, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk, sa, sd, 
	    pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, test);

  mspram0 : mspram 
    generic map (mspfile => mspfile, romfile => romfile)
    port map ( 
	A   => address(15 downto 0), 

	D(31 downto 0)   => data(31 downto 0),
 	romsel => romsn(0),
	romoen => oen,
	ramsel => ramsn(0),
	ramoen => ramoen(0),
	write => wrn,
	rst => rst,
	error => error
    );

  data <= buskeep(data) after 5 ns;
end ;

