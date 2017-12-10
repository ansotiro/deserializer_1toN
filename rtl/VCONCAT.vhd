----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    21:58:56 12/08/2017
-- Design Name:
-- Module Name:    VCONCAT - arch
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;


entity VCONCAT is
generic (
    DW      : natural := 32;
    QW      : natural := 3;
    T       : natural := 2;
    OFF     : natural := 1
);
port (
    DIN     : in  std_logic_vector (DW-1 downto 0);
    DOUT    : out std_logic_vector (QW-1 downto 0)
);
end VCONCAT;

architecture arch of VCONCAT is

signal data_out : std_logic_vector (QW-1 downto 0) := (others => '0');

begin

DOUT <= data_out;

GEN: for i in 0 to QW-1 generate

    A: if (T < (QW-i)) generate
        data_out(i) <= DIN(i);
    end generate;

    B: if (T >= (QW-i)) generate
        data_out(i) <= DIN(i+OFF);
    end generate;

end generate;

end arch;