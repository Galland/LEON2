-------------------------------------------------------------------------------
--
-- ROM core VHDL template. See the macro description included
-- behind this frame.
--
-- Copyright (C) 2000 Rudolf Matousek <matousek@utia.cas.cz>
--
-- Modified by Jiri Gaisler <jgais@ws.estec.esa.nl> for LEON boot prom.
--
-- This code may be used under the terms of Version 2 of the GPL,
-- read the file COPYING for details.
--
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity gen_bprom is
    port(
      clk : in std_logic;
      csn : in std_logic;
      addr : in std_logic_vector (29 downto 0);
      data : out std_logic_vector (31 downto 0)
      );
end;

architecture rtl of gen_bprom is
  signal raddr : std_logic_vector($a downto 0);
  signal d : std_logic_vector(31 downto 0);
  attribute syn_romstyle : string;
  attribute syn_romstyle of d : signal is "select_rom";
  
begin

  p : process(raddr)
  begin
    case raddr is
$i
    when others => d <= (others => '-');
    end case;
  end process;

  r : process (clk)
  begin
    if rising_edge(clk) then
      if csn = '0' then raddr <= addr($a downto 0); end if;
    end if;
  end process;

  data <= d;
end rtl;
