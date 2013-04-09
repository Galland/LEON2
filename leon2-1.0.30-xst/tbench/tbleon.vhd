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
-- File:        debug.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Various test bench configurations
------------------------------------------------------------------------------  
-- Version control:
-- 11-09-1998:  : First implemetation
-- 26-09-1999:  : Release 1.0
------------------------------------------------------------------------------  


-- 32-bit prom, 32-bit ram, 0ws

configuration tb_mmu_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 1,
	ramfile => "tsource/mmram.dat"
      );
    end for;
  end for;
end tb_mmu_disas;

-- 32-bit prom, 32-bit ram, 0ws

configuration tb_mmu of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 0,
	ramfile => "tsource/mmram.dat"
      );
    end for;
  end for;
end tb_mmu;

-- 32-bit prom, 32-bit ram, 0ws

configuration tb_full of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 0,
	ramfile => "tsource/fram.dat"
      );
    end for;
  end for;
end tb_full;

-- 32-bit prom, 32-bit ram, 0ws

configuration tb_func32 of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 0
      );
    end for;
  end for;
end tb_func32;

-- 32-bit prom, 32-bit ram, 32-bit sdram, 0ws

configuration tb_func_sdram of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
	romfile => "tsource/romsd.dat",
 	DISASS => 0,
	romdepth => 14
      );
    end for;
  end for;
end tb_func_sdram;

-- 32-bit prom, 32-bit ram, 0ws,

configuration tb_mem of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
 	DISASS => 0,
	ramfile => "tsource/mram.dat"
      );
    end for;
  end for;
end tb_mem;

-- 16-bit boot-prom, 16-bit ram, 0 ws

configuration tb_func16 of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg1 => "8 kbyte 16-bit rom, 0-ws",
        msg2 => "1x256 kbyte 16-bit ram, 0-ws",
 	DISASS => 0,
        romwidth => 16,
	romdepth => 14,
        ramwidth => 16,
        rambanks => 5,
	ramdepth => 18
      );
    end for;
  end for;
end tb_func16;

-- 8-bit boot-prom, 8-bit ram, 2 ws

configuration tb_func8 of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg1 => "8 kbyte 8-bit rom, 2-ws",
        msg2 => "1x256 kbyte 8-bit ram, 2-ws",
 	DISASS => 0,
        romwidth => 8,
	romdepth => 13,
	romtacc  => 35,
        ramwidth => 8,
	ramdepth => 18,
	ramtacc  => 35
      );
    end for;
  end for;
end tb_func8;

-- 32-bit prom, 32-bit ram, 0ws

configuration tb_full_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 1,
	ramfile => "tsource/fram.dat"
      );
    end for;
  end for;
end tb_full_disas;

-- 32-bit prom, 32-bit ram, 0ws

configuration tb_func32_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 1
      );
    end for;
  end for;
end tb_func32_disas;

-- 32-bit prom, 32-bit ram, 32-bit sdram, 0ws

configuration tb_func_sdram_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
	romfile => "tsource/romsd.dat",
 	DISASS => 1,
 	clkperiod => 25,
	romdepth => 14
      );
    end for;
  end for;
end tb_func_sdram_disas;

-- 32-bit prom, 32-bit ram, 0ws,

configuration tb_mem_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
 	DISASS => 1,
	ramfile => "tsource/mram.dat"
      );
    end for;
  end for;
end tb_mem_disas;

-- 16-bit boot-prom, 16-bit ram, 0 ws

configuration tb_func16_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg1 => "8 kbyte 16-bit rom, 0-ws",
        msg2 => "1x256 kbyte 16-bit ram, 0-ws",
 	DISASS => 1,
        romwidth => 16,
	romdepth => 14,
        ramwidth => 16,
	ramdepth => 18
      );
    end for;
  end for;
end tb_func16_disas;

-- 8-bit boot-prom, 8-bit ram, 2 ws

configuration tb_func8_disas of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav) generic map ( 
        msg1 => "8 kbyte 8-bit rom, 2-ws",
        msg2 => "1x256 kbyte 8-bit ram, 2-ws",
 	DISASS => 1,
        romwidth => 8,
	romdepth => 13,
	romtacc  => 35,
        ramwidth => 8,
	ramdepth => 18,
	ramtacc  => 35
      );
    end for;
  end for;
end tb_func8_disas;



