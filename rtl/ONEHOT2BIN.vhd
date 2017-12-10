----------------------------------------------------------------------------------
--                 ________  __       ___  _____        __
--                /_  __/ / / / ___  / _/ / ___/______ / /____
--                 / / / /_/ / / _ \/ _/ / /__/ __/ -_) __/ -_)
--                /_/  \____/  \___/_/   \___/_/  \__/\__/\__/
--
----------------------------------------------------------------------------------
--
-- Author(s):   ansotiropoulos
--
-- Design Name: generic_onehot2bin
-- Module Name: ONEHOT2BIN
--
-- Description: This entity is a generic ONEHOT2BIN block
--
-- Copyright:   (C) 2016 Microprocessor & Hardware Lab, TUC
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity ONEHOT2BIN is
generic (
    N   : natural := 4
);
port (
    D   : in  std_logic_vector (N-1 downto 0);
    Q   : out std_logic_vector ((natural(ceil(log2(real(N)))))-1 downto 0)
);
end ONEHOT2BIN;

architecture arch of ONEHOT2BIN is

constant logN : natural := (natural(ceil(log2(real(N)))));
signal bin : std_logic_vector (logN-1 downto 0) := (others => '0');

begin

Q <= bin;

process (D)
begin

    for i in D'range loop
        if D(i) = '1' then
            bin <= std_logic_vector(to_unsigned(i, logN));
        end if;
    end loop;

end process;

end arch;