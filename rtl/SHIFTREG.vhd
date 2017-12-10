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
-- Design Name: generic_shiftreg
-- Module Name: SHIFTREG
--
-- Description: This entity is a generic SHIFT REGISTER block
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

entity SHIFTREG is
generic (
    W       : integer := 8;
    N       : integer := 4
);
port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    EN      : in  std_logic;
    D       : in  std_logic_vector (W-1 downto 0);
    Q       : out std_logic_vector (W-1 downto 0)
);
end SHIFTREG;

architecture arch of SHIFTREG is

type array_t is array(0 to N-1) of std_logic_vector(W-1 downto 0);
signal sr : array_t := (others => (others => '0'));

begin

Q <= sr(N-1);

process
begin
    wait until rising_edge(CLK);

    if RST = '1' then
        sr <= (others => (others => '0'));
    else
        if En = '1' then
            for i in 1 to N-1 loop
                sr(i) <= sr(i-1);
            end loop;
            sr(0) <= D;
        else
            sr <= sr;
        end if;
    end if;

end process;

end arch;