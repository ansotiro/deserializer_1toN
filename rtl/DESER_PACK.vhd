-- Package
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;


-- Declare packo
package packo is

component SMUX
generic (
    N           : natural := 32;
    M           : natural := 4
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    EN          : in  std_logic;
    D           : in  std_logic_vector ((M*N)-1 downto 0);
    SEL         : in  std_logic_vector(integer(ceil(log2(real(M))))-1 downto 0);
    Q           : out std_logic_vector (N-1 downto 0)
);
end component;

component AMUX
generic (
    N           : natural := 8;
    M           : natural := 4
);
port (
    D           : in  std_logic_vector ((M*N)-1 downto 0);
    SEL         : in  std_logic_vector(integer(ceil(log2(real(M))))-1 downto 0);
    Q           : out std_logic_vector (N-1 downto 0)
);
end component;

component SDEMUX
generic (
    N           : natural := 32;
    M           : natural := 4
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    EN          : in  std_logic;
    D           : in  std_logic_vector (N-1 downto 0);
    SEL         : in  std_logic_vector(integer(ceil(log2(real(M))))-1 downto 0);
    Q           : out std_logic_vector ((M*N)-1 downto 0)
);
end component;

component COUNTER
generic (
    N           : integer := 4
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    DRST        : in  std_logic_vector (N-1 downto 0);
    SET         : in  std_logic;
    DSET        : in  std_logic_vector (N-1 downto 0);
    EN          : in  std_logic;
    DOUT        : out std_logic_vector (N-1 downto 0)
);
end component;

component VCONCAT
generic (
    DW          : natural := 32;
    QW          : natural := 3;
    T           : natural := 2;
    OFF         : natural := 1
);
port (
    DIN         : in  std_logic_vector (DW-1 downto 0);
    DOUT        : out std_logic_vector (QW-1 downto 0)
);
end component;


component SFIFO
generic (
    WIDTH       : natural := 32;
    DEPTH       : natural := 128;
    PFULL_A     : natural := 65;
    PFULL_N     : natural := 4;
    PEMPTY_A    : natural := 5;
    PEMPTY_N    : natural := 12;
    VALIDEN     : natural := 1;
    DCOUNTEN    : natural := 1;
    RAM_STYLE   : string  := "distributed"
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    PUSH        : in  std_logic;
    POP         : in  std_logic;
    D           : in  std_logic_vector (WIDTH-1 downto 0);
    Q           : out std_logic_vector (WIDTH-1 downto 0);
    DATACNT     : out std_logic_vector (natural(ceil(log2(real(DEPTH))))-1 downto 0);
    FULL        : out std_logic;
    EMPTY       : out std_logic;
    PROG_FULL   : out std_logic;
    PROG_EMPTY  : out std_logic;
    VALID       : out std_logic
);
end component;


component SHIFTREG
generic (
    W           : integer := 8;
    N           : integer := 4
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    EN          : in  std_logic;
    D           : in  std_logic_vector (W-1 downto 0);
    Q           : out std_logic_vector (W-1 downto 0)
);
end component;


component ONEHOT2BIN
generic (
    N           : natural := 4
);
port (
    D           : in  std_logic_vector (N-1 downto 0);
    Q           : out std_logic_vector ((natural(ceil(log2(real(N)))))-1 downto 0)
);
end component;

end packo;

