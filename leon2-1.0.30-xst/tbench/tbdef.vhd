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
-- Entity:      tbdef
-- File:        tbdef.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Default generic test bench
------------------------------------------------------------------------------  
-- Version control:
-- 17-09-1998:  : First implemetation
-- 26-09-1999:  : Release 1.0
------------------------------------------------------------------------------  

use work.tblib.all;

-- standard testbench

entity tbleon is end;
architecture behav of tbleon is begin tb : tbgen; end;
                                                                 

-- default config: 32-bit prom, 32-bit ram, EDAC, 0ws

configuration tbdef of tbleon is
  for behav 
    for all: 
      tbgen use entity work.tbgen(behav);
    end for;
  end for;
end tbdef;

