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
-- Design Name: generic_mux
-- Module Name: MUX
--
-- Description: This entity is a generic MUX block
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


entity SMUX is
generic (
    N       : natural := 8;
    M       : natural := 4
);
port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    EN      : in  std_logic;
    D       : in  std_logic_vector ((M*N)-1 downto 0);
    SEL     : in  std_logic_vector(integer(ceil(log2(real(M))))-1 downto 0);
    Q       : out std_logic_vector (N-1 downto 0)
);
end SMUX;

architecture arch of SMUX is

type array_t is array (natural range 0 to M-1) of std_logic_vector(Q'range);

signal sel_val : array_t;
signal mux_out : std_logic_vector (N-1 downto 0) := (others => '0');

begin


MUX: for i in sel_val'range generate
    sel_val(i) <= D(Q'LEFT+(i*N) downto i*N);
end generate;


DFF: process
begin
    wait until rising_edge(Clk);

    if RST = '1' then
        mux_out <= (others => '0');
    else
        if EN = '1' then
            mux_out <= sel_val(to_integer(unsigned(SEL)));
        else
            mux_out <= mux_out;
        end if;
    end if;

end process;

Q <= mux_out;

end arch;