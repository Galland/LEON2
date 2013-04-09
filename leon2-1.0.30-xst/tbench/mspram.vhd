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


-------------------------------------------------------------------------------
-- File name    : mspram.vhd
-- Title        : mspram
-- Author(s)    : Jiri Gaisler
-- Purpose      : Ram model for microsparc test suite
--
-------------------------------------------------------------------------------
-- Modification history :
-------------------------------------------------------------------------------
-- Version No : | Author | Mod. Date : | Changes made :
-------------------------------------------------------------------------------
-- v 1.0        |  JG    | 99-08-17    | first version
--.............................................................................
-------------------------------------------------------------------------------
-- Copyright ESA/ESTEC
-------------------------------------------------------------------------------
---------|---------|---------|---------|---------|---------|---------|--------|

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.conv_integer;

   use std.textio.all;
   use work.macro.all;
   use work.debug.all;


entity mspram is
      generic ( mspfile : string := "mspfile";	-- list of test files
                romfile : string := "rom.dat");	-- rom boot file
      port (  
	A : in std_logic_vector(15 downto 0);

        D : inout std_logic_vector(31 downto 0);

        romsel : in std_logic;
        romoen : in std_logic;
        ramsel : in std_logic;
        ramoen : in std_logic;
        write : in std_logic_vector(3 downto 0);
        rst : out std_logic;
        error : in std_logic
); end mspram;     


architecture behav of mspram is

  constant abits : integer := 16;

  subtype word is std_logic_vector(31 downto 0);

  type memarr is array(0 to ((2**Abits)-1)) of word;
  signal rstl : std_logic := 'X';
  signal ws : std_logic_vector(3 downto 0);
  signal ds : word;

  constant ahigh : integer := abits - 1;

  function to_xlhz(i : std_logic) return std_logic is
  begin
    case to_X01Z(i) is
    when 'Z' => return('Z');
    when '0' => return('L');
    when '1' => return('H');
    when others => return('X');
    end case;
  end;

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
function buskeep (signal v : in std_logic_vector) return std_logic_vector is
variable res : std_logic_vector(v'range);
begin
  for i in v'range loop res(i) := cvt_to_xlhz(v(i)); end loop;
  return(res);
end;

  function Vpar(vec : std_logic_vector) return std_logic is
  variable par : std_logic := '1';
  begin
    for i in vec'range loop --'
      par := par xor vec(i);
    end loop;
    return par;
  end;

  procedure CHAR2QUADBITS(C: character; RESULT: out bit_vector(3 downto 0);
            GOOD: out boolean; ISSUE_ERROR: in boolean) is
  begin
    case C is
    when '0' => RESULT :=  x"0"; GOOD := true;
    when '1' => RESULT :=  x"1"; GOOD := true;
    when '2' => RESULT :=  X"2"; GOOD := true;
    when '3' => RESULT :=  X"3"; GOOD := true;
    when '4' => RESULT :=  X"4"; GOOD := true;
    when '5' => RESULT :=  X"5"; GOOD := true;
    when '6' => RESULT :=  X"6"; GOOD := true;
    when '7' => RESULT :=  X"7"; GOOD := true;
    when '8' => RESULT :=  X"8"; GOOD := true;
    when '9' => RESULT :=  X"9"; GOOD := true;
    when 'A' => RESULT :=  X"A"; GOOD := true;
    when 'B' => RESULT :=  X"B"; GOOD := true;
    when 'C' => RESULT :=  X"C"; GOOD := true;
    when 'D' => RESULT :=  X"D"; GOOD := true;
    when 'E' => RESULT :=  X"E"; GOOD := true;
    when 'F' => RESULT :=  X"F"; GOOD := true;

    when 'a' => RESULT :=  X"A"; GOOD := true;
    when 'b' => RESULT :=  X"B"; GOOD := true;
    when 'c' => RESULT :=  X"C"; GOOD := true;
    when 'd' => RESULT :=  X"D"; GOOD := true;
    when 'e' => RESULT :=  X"E"; GOOD := true;
    when 'f' => RESULT :=  X"F"; GOOD := true;
    when others =>
      if ISSUE_ERROR then
        assert false report
	  "HREAD Error: Read a '" & C & "', expected a Hex character (0-F).";
      end if;
      GOOD := false;
    end case;
  end;

  procedure HREAD(L:inout line; VALUE:out bit_vector)  is
                variable OK: boolean;
                variable C:  character;
                constant NE: integer := VALUE'length/4;	--'
                variable BV: bit_vector(0 to VALUE'length-1);	--'
                variable S:  string(1 to NE-1);
  begin
    if VALUE'length mod 4 /= 0 then	--'
      assert false report
        "HREAD Error: Trying to read vector " &
        "with an odd (non multiple of 4) length";
      return;
    end if;
 
    while L'length > 0 loop                                    -- skip white space	--'
      read(L,C);
      exit when ((C /= ' ') and (C /= CR) and (C /= HT));
    end loop;
 
    CHAR2QUADBITS(C, BV(0 to 3), OK, false);
    if not OK then
      return;
    end if;
 
    read(L, S, OK);
--    if not OK then
--      assert false report "HREAD Error: Failed to read the STRING";
--      return;
--    end if;
 
    for I in 1 to NE-1 loop
      CHAR2QUADBITS(S(I), BV(4*I to 4*I+3), OK, false);
      if not OK then
        return;
      end if;
    end loop;
    VALUE := BV;
  end HREAD;

  procedure HREAD(L:inout line; VALUE:out std_ulogic_vector) is
    variable TMP: bit_vector(VALUE'length-1 downto 0);	--'
  begin
    HREAD(L, TMP);
    VALUE := TO_X01(TMP);
  end HREAD;

  procedure HREAD(L:inout line; VALUE:out std_logic_vector) is
    variable TMP: std_ulogic_vector(VALUE'length-1 downto 0);	--'
  begin
    HREAD(L, TMP);
    VALUE := std_logic_vector(TMP);
  end HREAD;

  function ishex(c:character) return boolean is
  variable tmp : bit_vector(3 downto 0);
  variable OK : boolean;
  begin
    CHAR2QUADBITS(C, tmp, OK, false);
    return OK;
  end ishex;
 

begin

  RAM : process(ws, ramsel,romsel,write,D,A,ramoen, romoen,rstl)
  variable memram, memrom : memarr;
  variable first : boolean := true;
  variable romloaded : boolean := false;
  variable ai : integer;
  variable L : line;
  variable LL : integer;
  variable s, x:  string(1 to 128);
  variable fail, ok : boolean;
  variable log_area, stop : integer := 65535;
  variable dint : word;
  variable wsv : std_logic_vector(3 downto 0);
  file testlist : text is in mspfile;

    procedure loadmem(mem: inout memarr; fn : string; alen : integer) is
    variable L1,L2 : line;
    variable LEN : integer := 0;
    variable ADR : std_logic_vector(31 downto 0);
    variable BUF : std_logic_vector(31 downto 0);
    variable CH : character;
    file TCF : text is in fn;
    begin
      L1:= new string'("");	--'
      readline(TCF,L1);
      ADR := (others => '0');
      while (L1'length /= 0) or not endfile(TCF) loop	--'
        if (L1'length /= 0) then	--'
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;
          if L1'length > 0 then	--'
            if not (L1'length=0)and ishex(L1(L1'left)) and ishex(L1(L1'left+1)) 	--'
	    then
              HREAD(L1,ADR(alen downto 0));	-- read address
	      len := conv_integer(adr(15 downto 2));
	      for i in 0 to 3 loop
                HREAD(L1,BUF);

                MEM(LEN+i) := BUF;

	      end loop;
            end if;
          end if;
        end if;
        if not endfile(TCF) then 
	  readline(TCF,L1); 
	else
	  exit;
	end if;
      end loop;
    end;

    
  begin

-- load prom at power-up

    if not romloaded  then
      loadmem(memrom, romfile, 15);
      print("*** Microsparc test suite ***");
      print("");
      rstl <= '0' after 500 ns; rst <= '0'; 
      romloaded := true;
      L:= new string'("");	--'
    end if;

-- check results and load next test

    if rstl = '0' then
      if not first then
        fail := false;
          if memram(log_area)(31 downto 0) /= "00000000000000000000000000000000" then
	      print( 
		tost(memram(log_area)(31 downto 17)) & " errors detected ");
	      print( "error code(s): " &
		tostf(memram(log_area)(15 downto 0)) & " : " &
		tostf(memram(log_area+1)(31 downto 16)) & " : " &
	        tostf(memram(log_area+1)(15 downto 0))); 
	      fail := true;
	  end if;
        if fail then 
 	  assert not fail report 
		tost(memram(log_area)(31 downto 17)) & 
		" errors in " & s severity failure ;
--	else
--	  print("test passed, log_area: " &tostring(memram(log_area)(31 downto 0)));
	end if;
      end if;
      first := false;
      ok := false;
      while (not ok) loop
        if (not endfile(testlist)) then
          readline(testlist,L); s := (others => nul);
	  LL := L'length;
	  std.textio.read(L, S(1 to L'length), ok);	--'
	  if ok then
	    if s(1) /= '#' then
	      print(s(1 to LL));
              loadmem(memram, s, 31); 
	    else ok := false;
	    end if;
	  end if;
        else
 	  assert false
	   report "*** test completed, halting simulation with failure ***"
	    severity failure ;
        end if;
      end loop;
      rstl <= '1';
      rst <= '1' after 500 ns;
    end if;
  
-- standard ram/rom memory

    if TO_X01(ramsel) = '0' then
      if not is_x(a) then ai := conv_integer(A(15 downto 2)); else ai := 0; end if;
      dint := memram(ai);
      if ai = 65528/4 then
	dint(31 downto 0) := std_logic_vector(conv_unsigned(log_area,32));

      elsif ai = 65532/4 then
	dint(31 downto 0) := std_logic_vector(conv_unsigned(stop,32));

      end if;
      if ai = stop then
	rstl <= '0' after 1000 ns;
	rst <= '0' after 1000 ns;
      end if;
    end if;
    ws(0) <= (not ramsel) and (not write(0));
    ws(1) <= (not ramsel) and (not write(1));
    ws(2) <= (not ramsel) and (not write(2));
    ws(3) <= (not ramsel) and (not write(3));
    ds <= to_X01(D);
    if ws(0)'event and (ws(0) = '1') then --'

      memram(ai)(31 downto 24) := DS(31 downto 24);

    end if;
    if ws(1)'event and (ws(1) = '1') then --'
	memram(ai)(23 downto 16) := DS(23 downto 16);
    end if;
    if ws(2)'event and (ws(2) = '1') then --'
	memram(ai)(15 downto 8) := DS(15 downto 8);
    end if;
    if ws(3)'event and (ws(3) = '1') then --'
      memram(ai)(7 downto 0) := DS(7 downto 0);
      if ai = 65528/4 then 
	log_area := conv_integer(DS(15 downto 2));
      elsif ai = 65532/4 then 
	stop := conv_integer(DS(15 downto 2));
      end if;
    end if;
    if TO_X01(romsel) = '0' then
      if not is_x(a) then ai := conv_integer(A(15 downto 2)); else ai := 0; end if;
      dint := memrom(ai);
    end if;

    if (romoen and ramoen) = '0' then
      D <= Dint;
    else
      D <= (others => 'Z');
    end if;
  end process;

  iuerr : process(error)
  begin
    assert error /= '0'
      report "*** IU in error mode, test failed! ***"
        severity failure ;
  end process;

  D <= buskeep(D);

end behav;
