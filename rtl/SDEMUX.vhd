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
-- Design Name: generic_demux
-- Module Name: DEMUX
--
-- Description: This entity is a generic DEMUX block
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


entity SDEMUX is
generic (
    N       : natural := 8;
    M       : natural := 4
);
port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    EN      : in  std_logic;
    D       : in  std_logic_vector (N-1 downto 0);
    SEL     : in  std_logic_vector(integer(ceil(log2(real(M))))-1 downto 0);
    Q       : out std_logic_vector ((M*N)-1 downto 0)
);
end SDEMUX;


architecture arch of SDEMUX is

type array_t is array (natural range 0 to M-1) of std_logic_vector(D'range);

signal sel_val : array_t;
signal demux_t : std_logic_vector ((M*N)-1 downto 0) := (others => '0');
signal demux_out : std_logic_vector ((M*N)-1 downto 0) := (others => '0');

begin


DEMUX: for i in sel_val'range generate
    demux_t(D'LEFT+(i*N) downto i*N) <= D when to_integer(unsigned(SEL))=i else (others => '0');
end generate;

DFF: process
begin
    wait until rising_edge(Clk);

    if RST = '1' then
        demux_out <= (others => '0');
    else
        if EN = '1' then
            demux_out <= demux_t;
        else
            demux_out <= demux_out;
        end if;
    end if;

end process;

Q <= demux_out;

end arch;

