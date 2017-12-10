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
-- Module Name: DESER
--
-- Description: This entity is a generic DESER block
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

library work;
use work.packo.all;

entity DESER is
generic (
    W           : integer := 32;    -- Data Width
    N           : integer := 2;     -- Number of Outpouts
    R           : integer := 4;     -- Reorder lever (N*R=NPIPES)
    S           : integer := 16;    -- Size
    T           : integer := 2;     -- Throuput => (1/T)
    M           : integer := 1      -- DENOM    => (1/M)
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    PUSH        : in  std_logic;
    D           : in  std_logic_vector (W-1 downto 0);
    Q           : out std_logic_vector ((W*N)-1 downto 0);
    VLD         : out std_logic
);
end DESER;

architecture arch of DESER is

constant NP             : integer := (integer((R*N)));
constant DEPTH          : integer := (integer((NP/T)*(S*2)));
constant c_log_2_NP     : integer := (integer(ceil(log2(real(NP)))));
constant c_log_2_NP_N   : integer := (integer(ceil(log2(real(NP/N)))));
constant c_log_2_S      : integer := (integer(ceil(log2(real(S)))));
constant c_log_2_NP_N_T : integer := (integer(ceil(log2(real((NP*T)/N)))));
constant c_log_2_M      : integer := (integer(ceil(log2(real(M)))));
constant c_log_2_T      : integer := (integer(ceil(log2(real(T)))));
constant c_log2_o_t     : integer := (integer(ceil(log2(real((NP/N)*T)))));
constant c_log2_s       : integer := (integer(ceil(log2(real((NP/N)/M)))));
constant c_NP           : integer := (integer(real(NP)));
constant c_NP_N         : integer := (integer(real(NP/N)));
constant c_NP_N_T       : integer := (integer(real((NP*T)/N)));

constant c_one_NP       : std_logic_vector (NP-1 downto 0) := (others => '1');
constant c_one_log2_NP_N: std_logic_vector (c_log_2_NP_N-1 downto 0) := (others => '1');

signal demux_data_i     : std_logic_vector (W-1 downto 0) := (others => '0');
signal demux_wen_i      : std_logic_vector (0 downto 0) := (others => '0');
signal demux_ren_i      : std_logic_vector (0 downto 0) := (others => '0');

signal demux_data_o     : std_logic_vector ((W*NP)-1 downto 0) := (others => '0');
signal demux_wen_o      : std_logic_vector ((NP)-1 downto 0) := (others => '0');
signal demux_ren_o      : std_logic_vector ((NP/N)-1 downto 0) := (others => '0');

signal demux_wen_sel    : std_logic_vector (c_log_2_NP-1 downto 0)  := (others => '0');
signal demux_ren_sel    : std_logic_vector (c_log_2_NP_N-1 downto 0)  := (others => '0');

signal mux_data_i       : std_logic_vector ((W*NP)-1 downto 0) := (others => '0');
signal mux_data_o       : std_logic_vector ((W*N)-1 downto 0) := (others => '0');

type array_mux_sel_t is array (natural range 0 to N-1) of std_logic_vector(c_log_2_NP_N-1 downto 0);
signal mux_sel_i        : array_mux_sel_t;

type array_mux_reni_t is array (natural range 0 to N-1) of std_logic_vector(c_NP_N-1 downto 0);
signal mux_ren_i        : array_mux_reni_t;

signal fifo_data_i      : std_logic_vector ((W*NP)-1 downto 0) := (others => '0');
signal fifo_wen_i       : std_logic_vector ((NP)-1 downto 0) := (others => '0');
signal fifo_ren_i       : std_logic_vector ((NP)-1 downto 0) := (others => '0');
signal fifo_data_o      : std_logic_vector ((W*NP)-1 downto 0) := (others => '0');
signal fifo_vld_o       : std_logic_vector ((NP)-1 downto 0) := (others => '0');
signal fifo_prog_o      : std_logic_vector ((NP)-1 downto 0) := (others => '0');

signal cnt              : std_logic_vector (W-1 downto 0) := (others => '0');
signal rd_en            : std_logic_vector (0 downto 0) := (others => '0');
signal run_time         : std_logic_vector (0 downto 0) := (others => '0');
signal valid            : std_logic_vector (0 downto 0) := (others => '0');


begin

-- hook up outputs
Q   <= mux_data_o;
VLD <= valid(0);


-- hook up inputs
demux_data_i    <= D;
demux_wen_i(0)  <= PUSH;
demux_ren_i     <= fifo_prog_o(fifo_prog_o'LEFT downto fifo_prog_o'LEFT) and demux_wen_i and (not rd_en) and run_time;


rd_en   <= cnt((c_log2_o_t-c_log_2_M-1) downto (c_log2_o_t-c_log_2_M-1)) or cnt((c_log2_s) downto (c_log2_s));

demux_wen_sel    <= cnt((c_log_2_NP+c_log_2_S)-1 downto c_log_2_S);


MSEL: VCONCAT
generic map (
    DW      => W,
    QW      => c_log_2_NP_N,
    T       => c_log_2_M,
    OFF     => c_log_2_T
)
port map (
    DIN     => cnt,
    DOUT    => demux_ren_sel
);

process
begin
    wait until rising_edge(CLK);

    if RST = '1' then
        run_time <= "0";
    else
        if cnt(c_log_2_NP_N-1 downto 0) = c_one_log2_NP_N then
            if fifo_prog_o = c_one_NP then
                run_time <= "1";
            else
                run_time <= "0";
            end if;
        else
            run_time <= run_time;
        end if;
    end if;

end process;


DEMUX_DATA: SDEMUX
generic map (
    N       => W,
    M       => NP
)
port map (
    CLK     => CLK,
    RST     => RST,
    EN      => '1',
    D       => demux_data_i,
    SEL     => demux_wen_sel,
    Q       => demux_data_o
);

DEMUX_WEN: SDEMUX
generic map (
    N       => 1,
    M       => NP
)
port map (
    CLK     => CLK,
    RST     => RST,
    EN      => '1',
    D       => demux_wen_i,
    SEL     => demux_wen_sel,
    Q       => demux_wen_o
);

DEMUX_REN: SDEMUX
generic map (
    N       => 1,
    M       => c_NP_N
)
port map (
    CLK     => CLK,
    RST     => RST,
    EN      => '1',
    D       => demux_ren_i,
    SEL     => demux_ren_sel,
    Q       => demux_ren_o
);


fifo_data_i <= demux_data_o;
fifo_wen_i  <= demux_wen_o;

FIFO: for i in 0 to NP-1 generate

    fifo_ren_i(i) <= demux_ren_o(to_integer(unsigned(std_logic_vector(to_unsigned(i,c_log_2_NP_N)))));

    FIFOi: SFIFO
    generic map (
        WIDTH       => W,
        DEPTH       => DEPTH,
        PFULL_A     => 62,
        PFULL_N     => 4,
        PEMPTY_A    => 1,
        PEMPTY_N    => 0,
        VALIDEN     => 1,
        DCOUNTEN    => 0,
        RAM_STYLE   => "distributed"
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PUSH        => fifo_wen_i(i),
        POP         => fifo_ren_i(i),
        D           => fifo_data_i(D'LEFT+(i*W) downto i*W),
        Q           => fifo_data_o(D'LEFT+(i*W) downto i*W),
        DATACNT     => open,
        FULL        => open,
        EMPTY       => open,
        PROG_FULL   => fifo_prog_o(i),
        PROG_EMPTY  => open,
        VALID       => fifo_vld_o(i)
    );

end generate;

mux_data_i <= fifo_data_o;

MUX: for i in 0 to N-1 generate

    ONEHOT_DEC: ONEHOT2BIN
    generic map (
        N   => c_NP_N
    )
    port map (
        D => fifo_vld_o((c_NP_N-1)+(i*c_NP_N) downto i*c_NP_N),
        Q => mux_sel_i(i)
    );

    MUX_DATA: SMUX
    generic map (
        N       => W,
        M       => c_NP_N
    )
    port map (
        CLK     => CLK,
        RST     => RST,
        EN      => '1',
        D       => mux_data_i( ((W*c_NP_N)-1)+(i*W*c_NP_N) downto i*W*c_NP_N),
        SEL     => mux_sel_i(i),
        Q       => mux_data_o( ((W)-1)+(i*W) downto i*W)
    );

end generate;

CNTER: COUNTER
generic map (
    N       => W
)
port map (
    CLK     => CLK,
    RST     => RST,
    DRST    => x"FFFFFFFF",
    SET     => '0',
    DSET    => x"00000000",
    EN      => PUSH,
    DOUT    => cnt
);

BVLD: SHIFTREG
generic map (
    W       => 1,
    N       => 3
)
PORT MAP (
    CLK     => CLK,
    RST     => '0',
    EN      => '1',
    D       => demux_ren_i,
    Q       => valid
);

end arch;