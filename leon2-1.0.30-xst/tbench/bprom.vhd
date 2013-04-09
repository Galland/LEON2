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
-- Entity: 	bprom
-- File:	bprom.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	A behaviour architecture of a boot prom used to simulate
--		the boot prom option.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

architecture behav of virtex_prom256 is
component iram
      generic (index : integer := 0;		-- Byte lane (0 - 3)
	       Abits: Positive := 10;		-- Default 10 address bits (1 Kbyte)
	       echk : integer := 0;		-- Generate EDAC checksum
	       tacc : integer := 10;		-- access time (ns)
	       fname : string := "ram.dat");	-- File to read from
      port (  
	A : in std_logic_vector;
        D : inout std_logic_vector(7 downto 0);
        CE1 : in std_logic;
        WE : in std_logic;
        OE : in std_logic

); end component;

signal gnd : std_logic := '0';
signal vcc : std_logic := '1';
signal address : std_logic_vector(7 downto 0);
signal data : std_logic_vector(31 downto 0);
begin

  x : process(clk)
  begin
    if rising_edge(clk) then
      address <= addr;
    end if;
  end process;

    romarr : for i in 0 to 3 generate
      rom0 : iram 
	generic map (index => i, abits => 8, echk => 0, tacc => 10,
		     fname => "tsource/bprom.dat")
        port map (A => address(7 downto 0), 
		  D => data((31 - i*8) downto (24-i*8)), CE1 => gnd,
		  WE => VCC, OE => gnd);
    end generate;

    do <= data;
end;

