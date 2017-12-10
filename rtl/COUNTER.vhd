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
-- Design Name: generic_counter
-- Module Name: COUNTER
--
-- Description: This entity is a generic COUNTER block
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
use ieee.std_logic_unsigned.all;

entity COUNTER is
generic (
    N       : integer := 4
);
port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    DRST    : in  std_logic_vector (N-1 downto 0);
    SET     : in  std_logic;
    DSET    : in  std_logic_vector (N-1 downto 0);
    EN      : in  std_logic;
    DOUT    : out std_logic_vector (N-1 downto 0)
);
end COUNTER;

architecture arch of COUNTER is

signal cnt  : std_logic_vector (N-1 downto 0) := (others => '0');


begin

DOUT <= cnt;

process
begin
    wait until rising_edge(CLK);

    if RST = '1' then
        cnt <= DRST;
    else
        if SET = '1' then
            cnt <= DSET;
        else
            if EN = '1' then
                cnt <= cnt + 1;
            else
                cnt <= cnt;
            end if;
        end if;
    end if;

end process;

end arch;