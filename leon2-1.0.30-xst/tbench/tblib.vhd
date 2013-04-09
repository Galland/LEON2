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
-- Package:     debug
-- File:        debug.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Package with component declaration of tbgen.
------------------------------------------------------------------------------  
-- Version control:
-- 11-09-1998:  : First implemetation
-- 26-09-1999:  : Release 1.0
------------------------------------------------------------------------------  

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.iface.all; 

package tblib is

component tbgen
end component; 

end tblib;
