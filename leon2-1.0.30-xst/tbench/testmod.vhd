



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
-- Entity:      testmod
-- File:        testmod.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: This module is connected to the I/O area and generates
--		debug messages and bus exceptions for the test bench.
------------------------------------------------------------------------------  

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.Std_Logic_unsigned.conv_integer;
use STD.TEXTIO.all;
use work.debug.all;

entity testmod is
  port (
	clk   	: in   	 std_logic;
	dsurx 	: in   	 std_logic;
	dsutx  	: out    std_logic;
	error	: in   	 std_logic;
	iosn 	: in   	 std_logic;
	oen  	: in   	 std_logic;
	read 	: in   	 std_logic;
	writen	: in   	 std_logic;
	brdyn  	: out    std_logic;
	bexcn  	: out    std_logic;
	address : in     std_logic_vector(7 downto 0);
	data	: inout  std_logic_vector(31 downto 0);
	ioport  : out     std_logic_vector(15 downto 0)
	);
	
end;


architecture behav of testmod is

constant LRESP : boolean := FALSE;
--constant TXPERIOD : time := 1000000000/115200 * 1 ns;
constant TXPERIOD : time := 160 * 1 ns;
subtype restype is string(1 to 6);
type resarr is array (0 to 2) of restype;
constant res : resarr := ("      ", "OK    ", "FAILED");
signal ioporti  : std_logic_vector(15 downto 0);
    
subtype msgtype is string(1 to 40);
type msgarr is array (0 to 23) of msgtype;
constant msg : msgarr := (
    "*** Starting LEON system test ***       ", -- 0
    "Cache controllers                       ", -- 1
    "Register file                           ", -- 2
    "Multiplier (SMUL/UMUL/MULSCC)           ", -- 3
    "Divider (SDIV/UDIV)                     ", -- 4
    "Watchpoint registers                    ", -- 5
    "Cache snooping                          ", -- 6
    "Floating-point unit                     ", -- 7
    "PCI interface                           ", -- 8
    "Initializing cache ram                  ", -- 9
    "Interrupt controller                    ", -- 10
    "Timers, watchdog and power-down         ", -- 11
    "UARTs                                   ", -- 12
    "Parallel I/O port                       ", -- 13
    "EDAC operation                          ", -- 14
    "Sending packet on VCA0                  ", -- 15
    "Regfile dpram cells                     ", -- 16
    "Cache ram cells                         ", -- 17
    "Memory interface test                   ", -- 18
    "Test completed OK, halting with failure ", -- 19
    "Memory write protection                 ", -- 20
    "Trace buffer                            ", -- 21
    "Debug support unit                      ", -- 22
    "Memory management unit                  "  -- 23
);


begin


  rep : process
  variable aint : natural;
  variable dint : natural;
  variable ioval,ioout : std_logic_vector(15 downto 0);
  variable datal : std_logic_vector(31 downto 0) := (others => '0');
  variable iodir : std_logic_vector(15 downto 0) := (others => '0');
  begin

    for i in ioport'range loop	--'
      if iodir(i) = '1' then ioout(i) := ioval(i); else ioout(i) := 'Z'; end if;
    end loop;
    ioporti <= ioout;
    brdyn <= '1' after 5 ns; bexcn <= '1' after 5 ns;
    data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" after 5 ns;

    wait until  ((iosn or (writen and oen)) = '0');
    wait for 10 ns;
    aint := conv_integer(address);
    if not is_x(data) then dint := conv_integer(data(31 downto 24)); end if;
    if aint < 64 then
      if dint = 0 then
        print (string(msg(aint)));
        if aint = 19 then
	  assert false report "TEST COMPLETED OK, ending with FAILURE" 
	    severity failure ;
        end if;
      else
        print (string(msg(aint)) & "ERROR(" & tost(std_logic_vector(conv_unsigned(dint, 8))) & ")");
        assert false report "TEST ABORTED DUE TO FAILURE" severity failure ;
      end if;
      brdyn  <= '0' after 10 ns;
    else
      brdyn  <= '0' after 10 ns;
      case aint is 
      when 64 => if read = '0' then iodir(7 downto 0) := data(31 downto 24); end if;
      when 65 => if read = '0' then iodir(15 downto 8) := data(31 downto 24); end if;
      when 66 => if read = '0' then ioval(7 downto 0) := data(31 downto 24); end if;
      when 67 => if read = '0' then ioval(15 downto 8) := data(31 downto 24); end if;
      when 72 => bexcn <= '0';
      when 76 => bexcn <= '0';
      when 80 => bexcn <= '0';
      when 92 => bexcn <= '0';
      when 94 => bexcn <= '0';
      when 96|97|98|99 => datal := "00000001001000110100010101100111";
      when others => null;
      end case;
    end if;
    if read = '1' then data <= datal; end if;
    wait until (iosn = '1');

  end process;

  ioport <= ioporti;

  errmode : process(error)
  begin
    if now > 100 ns then
      assert  to_x01(error) = '1' report "processor in error mode!" 
	  severity failure ;
    end if;
  end process;


  dsucom : process
    procedure rxc(signal rxd : in std_logic; d: out std_logic_vector) is
    variable rxdata : std_logic_vector(7 downto 0);
    begin
      wait until rxd = '0'; wait for TXPERIOD/2;
      for i in 0 to 7 loop 
	wait for TXPERIOD; 
	rxdata(i):= rxd; 
      end loop;
      wait for TXPERIOD ; 
      d := rxdata;
    end;
    procedure rxi(signal rxd : in std_logic; d: out std_logic_vector) is
    variable rxdata : std_logic_vector(31 downto 0);
    variable resp : std_logic_vector(7 downto 0);
    begin
      for i in 3 downto 0 loop 
	rxc(rxd, rxdata((i*8 +7) downto i*8)); 
      end loop; 
      d := rxdata;
      if LRESP then
        rxc(rxd, resp); print("RESP   : 0x" & tosth(resp));
      end if;
    end;
    procedure txc(signal txd : out std_logic; td : integer) is
    variable txdata : std_logic_vector(10 downto 0);
    begin
      txdata := "11" & std_logic_vector(conv_unsigned(td, 8)) & '0';
      for i in 0 to 10 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
    end;
    procedure txa(signal txd : out std_logic; td1, td2, td3, td4 : integer) is
    variable txdata : std_logic_vector(43 downto 0);
    begin
      txdata := "11" & std_logic_vector(conv_unsigned(td4, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td3, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td2, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td1, 8)) & '0';
      for i in 0 to 43 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
    end;
    procedure txi(signal rxd : in std_logic; signal txd : out std_logic; td1, td2, td3, td4 : integer) is
    variable txdata : std_logic_vector(43 downto 0);
    begin
      txdata := "11" & std_logic_vector(conv_unsigned(td4, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td3, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td2, 8)) & '0'
              & "11" & std_logic_vector(conv_unsigned(td1, 8)) & '0';
      for i in 0 to 43 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
      if LRESP then
        rxc(rxd, txdata(7 downto 0)); print("RESP   : 0x" & tosth(txdata(7 downto 0)));
      end if;
    end;
    procedure rxr(signal rxd : in std_logic) is
    variable rxdata : std_logic_vector(7 downto 0);
    begin
      if LRESP then
        rxc(dsurx, rxdata); print("RESP   : 0x" & tosth(rxdata));
      end if;
    end;

    procedure tst1(signal dsurx : in std_logic; signal dsutx : out std_logic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    begin
    wait for 5000 ns;
    txc(dsutx, 16#55#);		-- sync uart
    print("DSU registers");
    txc(dsutx, 16#c1#);		-- stop processor and set DSU regs
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    if LRESP then txi(dsurx, dsutx, 16#00#, 16#06#, 16#07#, 16#f1#);
    else txi(dsurx, dsutx, 16#00#, 16#00#, 16#04#, 16#f1#); end if;
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#ff#);

    print("continue");
    txc(dsutx, 16#c0#);		-- single step
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#04#, 16#71#);

    print("single step");
    txc(dsutx, 16#c0#);		-- single step
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#01#, 16#04#, 16#70#);

    txc(dsutx, 16#c3#);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#10#);
    txi(dsurx, dsutx, 16#90#, 16#00#, 16#00#, 16#1C#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#ff#);
    txi(dsurx, dsutx, 16#40#, 16#02#, 16#00#, 16#0c#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#fe#);
    txc(dsutx, 16#82#);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    rxi(dsurx, w32); print("DSUC   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBI    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("EVCNT  : 0x" & tosth(w32));
    txc(dsutx, 16#83#);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#10#);
    rxi(dsurx, w32); print("BA1    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("BM1    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("BA2    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("BM2    : 0x" & tosth(w32));
    txc(dsutx, 16#87#);
    txa(dsutx, 16#90#, 16#01#, 16#03#, 16#f0#);
    rxi(dsurx, w32); print("TBUF0   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF1   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF2   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF3   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF4   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF5   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF6   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF7   : 0x" & tosth(w32));
    txc(dsutx, 16#87#);
    txa(dsutx, 16#90#, 16#01#, 16#07#, 16#f0#);
    rxi(dsurx, w32); print("TBUF0   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF1   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF2   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF3   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF4   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF5   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF6   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF7   : 0x" & tosth(w32));
    txc(dsutx, 16#c7#);
    txa(dsutx, 16#90#, 16#01#, 16#03#, 16#f0#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#11#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#22#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#33#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#44#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#22#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#44#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#88#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#ff#, 16#00#, 16#00#, 16#00#);
    txc(dsutx, 16#c7#);
    txa(dsutx, 16#90#, 16#01#, 16#07#, 16#f0#);
    txi(dsurx, dsutx, 16#10#, 16#00#, 16#00#, 16#11#);
    txi(dsurx, dsutx, 16#02#, 16#00#, 16#22#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#30#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#44#, 16#04#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#50#, 16#22#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#46#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#88#, 16#00#, 16#70#);
    txi(dsurx, dsutx, 16#ff#, 16#00#, 16#00#, 16#08#);
    txc(dsutx, 16#87#);
    txa(dsutx, 16#90#, 16#01#, 16#03#, 16#f0#);
    rxi(dsurx, w32); print("TBUF0   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF1   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF2   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF3   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF4   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF5   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF6   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF7   : 0x" & tosth(w32));
    txc(dsutx, 16#87#);
    txa(dsutx, 16#90#, 16#01#, 16#07#, 16#f0#);
    rxi(dsurx, w32); print("TBUF0   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF1   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF2   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF3   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF4   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF5   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF6   : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBUF7   : 0x" & tosth(w32));

    print("PC/NPC");
    txc(dsutx, 16#c1#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#10#);
    txi(dsurx, dsutx, 16#40#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#40#, 16#00#, 16#00#, 16#04#);
    txc(dsutx, 16#81#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#10#);
    rxi(dsurx, w32); print("PC     : 0x" & tosth(w32));
    rxi(dsurx, w32); print("NPC    : 0x" & tosth(w32));

    print("Special purpose registers");
    txc(dsutx, 16#c3#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#c0#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#40#, 16#00#, 16#00#, 16#00#);
    txc(dsutx, 16#83#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#00#);
    rxi(dsurx, w32); print("Y      : 0x" & tosth(w32));
    rxi(dsurx, w32); print("PSR    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("WIM    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("TBR    : 0x" & tosth(w32));
    txc(dsutx, 16#c7#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#60#);
    txi(dsurx, dsutx, 16#04#, 16#00#, 16#10#, 16#00#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#fc#);
    txi(dsurx, dsutx, 16#04#, 16#00#, 16#10#, 16#c0#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#f0#);
    txi(dsurx, dsutx, 16#04#, 16#00#, 16#20#, 16#c0#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#c0#);
    txi(dsurx, dsutx, 16#04#, 16#00#, 16#30#, 16#00#);
    txi(dsurx, dsutx, 16#ff#, 16#ff#, 16#ff#, 16#00#);
    txc(dsutx, 16#87#);	
    txa(dsutx, 16#90#, 16#08#, 16#00#, 16#60#);
    for i in 0 to 7 loop
      rxi(dsurx, w32); print("ASR " & 
	tost(std_logic_vector(conv_unsigned(i+24,8))) & "  : 0x" & tosth(w32));
    end loop;

    print("IU registers");
    txc(dsutx, 16#c3#);	
    txa(dsutx, 16#90#, 16#02#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#10#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#32#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#54#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#76#, 16#00#, 16#00#, 16#00#);
    txc(dsutx, 16#c3#);	
    txa(dsutx, 16#90#, 16#02#, 16#02#, 16#00#);
    txi(dsurx, dsutx, 16#10#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#20#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#30#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#40#);
    txc(dsutx, 16#83#);
    txa(dsutx, 16#90#, 16#02#, 16#00#, 16#00#);
    rxi(dsurx, w32); print("%R0    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R1    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R2    : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R3    : 0x" & tosth(w32));
    txc(dsutx, 16#83#);
    txa(dsutx, 16#90#, 16#02#, 16#02#, 16#00#);
    rxi(dsurx, w32); print("%R128  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R129  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R130  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("%R131  : 0x" & tosth(w32));

    print("Memory configuration register 2");
    txc(dsutx, 16#c0#);		-- write memcfg1/2
    txa(dsutx, 16#80#, 16#00#, 16#00#, 16#04#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#08#, 16#20#);
    txc(dsutx, 16#80#);		-- MCFG2
    txa(dsutx, 16#80#, 16#00#, 16#00#, 16#04#);
    rxi(dsurx, w32); print("MCFG2  : 0x" & tosth(w32));

    print("Cache control register");
    txc(dsutx, 16#c0#);		-- write cache control reg
    txa(dsutx, 16#80#, 16#00#, 16#00#, 16#14#);
    txi(dsurx, dsutx, 16#00#, 16#01#, 16#00#, 16#cf#);
    txc(dsutx, 16#80#);		-- CACHECFG
    txa(dsutx, 16#80#, 16#00#, 16#00#, 16#14#);
    rxi(dsurx, w32); print("CCTRL  : 0x" & tosth(w32));

    print("Data cache tags");
    txc(dsutx, 16#c0#);
    txa(dsutx, 16#90#, 16#18#, 16#00#, 16#20#);
    txi(dsurx, dsutx, 16#41#, 16#00#, 16#70#, 16#00#);
    txc(dsutx, 16#80#);	
    txa(dsutx, 16#90#, 16#18#, 16#00#, 16#20#);
    rxi(dsurx, w32); print("DTAGS  : 0x" & tosth(w32));

    print("Data cache data");
    txc(dsutx, 16#c0#);	
    txa(dsutx, 16#90#, 16#1c#, 16#00#, 16#20#);
    txi(dsurx, dsutx, 16#41#, 16#01#, 16#C0#, 16#00#);
    txc(dsutx, 16#80#);
    txa(dsutx, 16#90#, 16#1c#, 16#00#, 16#20#);
    rxi(dsurx, w32); print("DDATA  : 0x" & tosth(w32));

    print("Instruction cache tags");
    txc(dsutx, 16#c0#);	
    txa(dsutx, 16#90#, 16#10#, 16#00#, 16#20#);
    txi(dsurx, dsutx, 16#42#, 16#00#, 16#10#, 16#00#);
    txc(dsutx, 16#80#);		-- read icache tag
    txa(dsutx, 16#90#, 16#10#, 16#00#, 16#20#);
    rxi(dsurx, w32); print("ITAGS  : 0x" & tosth(w32));

    print("Instruction cache data");
    txc(dsutx, 16#c0#);	
    txa(dsutx, 16#90#, 16#14#, 16#00#, 16#30#);
    txi(dsurx, dsutx, 16#42#, 16#00#, 16#30#, 16#00#);
    txc(dsutx, 16#80#);		-- read icache data
    txa(dsutx, 16#90#, 16#14#, 16#00#, 16#30#);
    rxi(dsurx, w32); print("IDATA  : 0x" & tosth(w32));

    txc(dsutx, 16#c3#);		-- write memory
    txa(dsutx, 16#40#, 16#02#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#01#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#02#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#00#, 16#00#, 16#00#);

    txc(dsutx, 16#83#);		-- read memory
    txa(dsutx, 16#40#, 16#02#, 16#00#, 16#00#);
    rxi(dsurx, w32); print("MEM0  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("MEM1  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("MEM2  : 0x" & tosth(w32));
    rxi(dsurx, w32); print("MEM3  : 0x" & tosth(w32));
    end;

    procedure tst2(signal dsurx : in std_logic; signal dsutx : out std_logic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    begin
    wait for 4000 ns;
    txc(dsutx, 16#55#);		-- sync uart
    print("DSU registers");
    txc(dsutx, 16#c1#);		-- stop processor and set DSU regs
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    if LRESP then txi(dsurx, dsutx, 16#00#, 16#06#, 16#05#, 16#71#);
    else txi(dsurx, dsutx, 16#00#, 16#00#, 16#55#, 16#79#); end if;
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#ff#, 16#fc#);
    loop
    wait;
    txc(dsutx, 16#c0#);		-- stop processor and set DSU regs
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#01#, 16#55#, 16#79#);
    end loop;
    wait;
    end ;

    procedure tst3(signal dsurx : in std_logic; signal dsutx : out std_logic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    begin
    wait for 5000 ns;
    txc(dsutx, 16#55#);		-- sync uart
    wait for 25000 ns;
    print("DSU registers");

    loop
    txc(dsutx, 16#c0#);		-- stop processor and set DSU regs
    txa(dsutx, 16#60#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#f3#);
    txc(dsutx, 16#80#);
    txa(dsutx, 16#60#, 16#00#, 16#00#, 16#00#);
    rxi(dsurx, w32); print("DSU   : 0x" & tosth(w32));
    end loop;

    txc(dsutx, 16#c1#);		-- stop processor and set DSU regs
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    if LRESP then txi(dsurx, dsutx, 16#00#, 16#06#, 16#07#, 16#f1#);
    else txi(dsurx, dsutx, 16#00#, 16#00#, 16#04#, 16#f1#); end if;
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#ff#);

    print("continue");
    txc(dsutx, 16#c0#);		-- continue
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#00#, 16#00#, 16#04#, 16#71#);

    loop 
      print("read status");
      txc(dsutx, 16#80#);
      txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#);
      rxi(dsurx, w32); print("DSU   : 0x" & tosth(w32));
    end loop;
    end;

    procedure tst4(signal dsurx : in std_logic; signal dsutx : out std_logic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    begin
    wait for 5000 ns;
    txc(dsutx, 16#55#);		-- sync uart
    wait for 25000 ns;
    print("DSU registers");

    loop
    txc(dsutx, 16#c0#);		-- 
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#f3#);
    txc(dsutx, 16#c0#);		-- 
    txa(dsutx, 16#40#, 16#00#, 16#04#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#f3#);
    txc(dsutx, 16#c0#);		-- 
    txa(dsutx, 16#40#, 16#00#, 16#08#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#f3#);
    txc(dsutx, 16#c0#);		-- 
    txa(dsutx, 16#40#, 16#00#, 16#0c#, 16#00#);
    txi(dsurx, dsutx, 16#03#, 16#ff#, 16#ff#, 16#f3#);
    end loop;
    end;

  begin
    dsutx <= '1';
--    tst1(dsurx, dsutx);
--    tst2(dsurx, dsutx);
--    tst3(dsurx, dsutx);
--    tst4(dsurx, dsutx);
    wait;

  end process;

end;


