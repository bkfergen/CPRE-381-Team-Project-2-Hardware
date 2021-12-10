library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity registerfile is

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input (Currently resets all registers)
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(31 downto 0);     -- Data value input
       i_ReadA      : in std_logic_vector(4 downto 0);      -- Register Select Read A (RS)
       i_ReadB      : in std_logic_vector(4 downto 0);      -- Register Select Read B (RT)
       i_Write      : in std_logic_vector(4 downto 0);      -- Register Select Write (RD)
       o_A          : out std_logic_vector(31 downto 0);   -- Data value output A (RS)
       o_B          : out std_logic_vector(31 downto 0));   -- Data value output B (RT)

end registerfile;

architecture dataflow of registerfile is

  component nreg
    generic(N         : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

  component mipsdecoder

    port(i_A          : in std_logic_vector(4 downto 0);
         o_F          : out std_logic_vector(31 downto 0));

  end component;

  component regmultiplexor

  port(i_S          : in std_logic_vector(4 downto 0); -- Select Line
       i_R0         : in std_logic_vector(31 downto 0); -- Register Input
       i_R1         : in std_logic_vector(31 downto 0); -- Register Input
       i_R2         : in std_logic_vector(31 downto 0); -- Register Input
       i_R3         : in std_logic_vector(31 downto 0); -- Register Input
       i_R4         : in std_logic_vector(31 downto 0); -- Register Input
       i_R5         : in std_logic_vector(31 downto 0); -- Register Input
       i_R6         : in std_logic_vector(31 downto 0); -- Register Input
       i_R7         : in std_logic_vector(31 downto 0); -- Register Input
       i_R8         : in std_logic_vector(31 downto 0); -- Register Input
       i_R9         : in std_logic_vector(31 downto 0); -- Register Input
       i_R10        : in std_logic_vector(31 downto 0); -- Register Input
       i_R11        : in std_logic_vector(31 downto 0); -- Register Input
       i_R12        : in std_logic_vector(31 downto 0); -- Register Input
       i_R13        : in std_logic_vector(31 downto 0); -- Register Input
       i_R14        : in std_logic_vector(31 downto 0); -- Register Input
       i_R15        : in std_logic_vector(31 downto 0); -- Register Input
       i_R16        : in std_logic_vector(31 downto 0); -- Register Input
       i_R17        : in std_logic_vector(31 downto 0); -- Register Input
       i_R18        : in std_logic_vector(31 downto 0); -- Register Input
       i_R19        : in std_logic_vector(31 downto 0); -- Register Input
       i_R20        : in std_logic_vector(31 downto 0); -- Register Input
       i_R21        : in std_logic_vector(31 downto 0); -- Register Input
       i_R22        : in std_logic_vector(31 downto 0); -- Register Input
       i_R23        : in std_logic_vector(31 downto 0); -- Register Input
       i_R24        : in std_logic_vector(31 downto 0); -- Register Input
       i_R25        : in std_logic_vector(31 downto 0); -- Register Input
       i_R26        : in std_logic_vector(31 downto 0); -- Register Input
       i_R27        : in std_logic_vector(31 downto 0); -- Register Input
       i_R28        : in std_logic_vector(31 downto 0); -- Register Input
       i_R29        : in std_logic_vector(31 downto 0); -- Register Input
       i_R30        : in std_logic_vector(31 downto 0); -- Register Input
       i_R31        : in std_logic_vector(31 downto 0); -- Register Input
       o_F          : out std_logic_vector(31 downto 0)); -- Output

  end component;

  signal s_S : std_logic_vector(31 downto 0);
  signal s_SWE : std_logic_vector(31 downto 0);
  signal s_RST: std_logic_vector(31 downto 0);

  type   ro_t is array(0 to 31) of std_logic_vector(31 downto 0); 
  signal s_O : ro_t;

  signal o_A_pre : std_logic_vector(31 downto 0);
  signal o_B_pre : std_logic_vector(31 downto 0);

begin

  decode: mipsdecoder
  port map(i_A => i_Write,
           o_F => s_S);

  s_SWE <= "00000000000000000000000000000000" when i_WE = '0' else
         s_S;

  R0: nreg
  generic map(N  => 32)
  port map(i_CLK => i_CLK, 
           i_RST => i_RST,
           i_WE  => '0',
           i_D   => "00000000000000000000000000000000",
           o_Q   => s_O(0));

  G_32Bit_Reg: for i in 1 to 31 generate
    REGISTER_I: nreg
    generic map(N  => 32)
    port map(i_CLK => i_CLK, 
             i_RST => i_RST,
             i_WE  => s_SWE(i),
             i_D   => i_D,
             o_Q   => s_O(i));
   end generate G_32Bit_REG;

  regmuxA: regmultiplexor
  port map(i_S => i_ReadA,
           i_R0 => s_O(0),
           i_R1 => s_O(1),
           i_R2 => s_O(2),
           i_R3 => s_O(3),
           i_R4 => s_O(4),
           i_R5 => s_O(5),
           i_R6 => s_O(6),
           i_R7 => s_O(7),
           i_R8 => s_O(8),
           i_R9 => s_O(9),
           i_R10 => s_O(10),
           i_R11 => s_O(11),
           i_R12 => s_O(12),
           i_R13 => s_O(13),
           i_R14 => s_O(14),
           i_R15 => s_O(15),
           i_R16 => s_O(16),
           i_R17 => s_O(17),
           i_R18 => s_O(18),
           i_R19 => s_O(19),
           i_R20 => s_O(20),
           i_R21 => s_O(21),
           i_R22 => s_O(22),
           i_R23 => s_O(23),
           i_R24 => s_O(24),
           i_R25 => s_O(25),
           i_R26 => s_O(26),
           i_R27 => s_O(27),
           i_R28 => s_O(28),
           i_R29 => s_O(29),
           i_R30 => s_O(30),
           i_R31 => s_O(31),
           o_F => o_A_pre);

  o_A <= i_D when i_ReadA = i_Write else
         o_A_pre;

  regmuxB: regmultiplexor
  port map(i_S => i_ReadB,
           i_R0 => s_O(0),
           i_R1 => s_O(1),
           i_R2 => s_O(2),
           i_R3 => s_O(3),
           i_R4 => s_O(4),
           i_R5 => s_O(5),
           i_R6 => s_O(6),
           i_R7 => s_O(7),
           i_R8 => s_O(8),
           i_R9 => s_O(9),
           i_R10 => s_O(10),
           i_R11 => s_O(11),
           i_R12 => s_O(12),
           i_R13 => s_O(13),
           i_R14 => s_O(14),
           i_R15 => s_O(15),
           i_R16 => s_O(16),
           i_R17 => s_O(17),
           i_R18 => s_O(18),
           i_R19 => s_O(19),
           i_R20 => s_O(20),
           i_R21 => s_O(21),
           i_R22 => s_O(22),
           i_R23 => s_O(23),
           i_R24 => s_O(24),
           i_R25 => s_O(25),
           i_R26 => s_O(26),
           i_R27 => s_O(27),
           i_R28 => s_O(28),
           i_R29 => s_O(29),
           i_R30 => s_O(30),
           i_R31 => s_O(31),
           o_F => o_B_pre);

  o_B <= i_D when i_ReadB = i_Write else
         o_B_pre;
  
end dataflow;