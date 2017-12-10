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
-- Design Name: deserializer_1toN
-- Module Name: tb_deser
--
-- Description: Testbench for generic DESER
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
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_deser is
end tb_deser;

architecture behavior of tb_deser is

component DESER
generic (
    W       : integer := 32;
    N       : integer := 2;
    R       : integer := 4;
    S       : integer := 16;
    T       : integer := 2;
    M       : integer := 1
);
port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    PUSH    : in  std_logic;
    D       : in  std_logic_vector (31 downto 0);
    Q       : out std_logic_vector (63 downto 0);
    VLD     : out std_logic
);
end component;

procedure printf_slv (dat : in std_logic_vector (31 downto 0); file f: text) is
    variable my_line : line;
begin
    write(my_line, CONV_INTEGER(dat));
    write(my_line, string'(" -   ("));
    write(my_line, now);
    write(my_line, string'(")"));
    writeline(f, my_line);
end procedure printf_slv;

constant CLK_period : time := 10 ns;

signal CLK      : std_logic := '0';
signal RST      : std_logic := '0';
signal PUSH     : std_logic := '0';
signal D        : std_logic_vector (31 downto 0) := (others => '0');
signal Q        : std_logic_vector (63 downto 0) := (others => '0');
signal VLD      : std_logic := '0';

signal data_in  : std_logic_vector(31 downto 0) := x"00000000";
signal ii       : std_logic_vector(4 downto 0) := "00000";
signal kk       : std_logic_vector(3 downto 0) := "0000";

file file_d0    : text open WRITE_MODE is "out/test_d0.out";
file file_d1    : text open WRITE_MODE is "out/test_d1.out";

BEGIN


U: DESER
generic map (
    W       => 32,
    N       => 2,
    R       => 4,
    S       => 16,
    T       => 2,
    M       => 1
)
port map (
    CLK     => CLK,
    RST     => RST,
    PUSH    => PUSH,
    D       => D,
    Q       => Q,
    VLD     => VLD
);


CLKP :process
begin
    CLK <= '0';
    wait for CLK_period/2;
    CLK <= '1';
    wait for CLK_period/2;
end process;

TRACE: process
begin
    wait until rising_edge(CLK);
    if VLD = '1' then
        printf_slv(Q(63 downto 32), file_d1);
        printf_slv(Q(31 downto 0), file_d0);
    end if;
end process;


SIMUL: process
begin

wait until rising_edge(CLK);


RST     <= '0';
PUSH    <= '0';
data_in <= x"00000000";
ii      <= "00000";
kk      <= "0000";
D       <= data_in;
wait for CLK_period*4;

RST <= '1';
wait for CLK_period*8;

RST <= '0';
wait for CLK_period*4;


for J in 1 to 500 loop
    for I in 1 to 32 loop
        for K in 1 to 21 loop
            if K=1 and I=1 and J=1 then
                data_in <= data_in + 1;
                kk      <= kk;
                PUSH    <= '0';
                D       <= data_in;
            elsif K=6 or K=18 or K=19 or K=20 or K=21 then
                data_in <= data_in;
                kk      <= kk;
                PUSH    <= '0';
                D       <= data_in;
            else
                data_in <= data_in + 1;
                kk      <= kk + 1;
                PUSH    <= '1';
                D       <= data_in;
            end if;
            wait for CLK_period;
        end loop;
            ii  <= ii + 1;
    end loop;
end loop;

wait;
end process;

end;
