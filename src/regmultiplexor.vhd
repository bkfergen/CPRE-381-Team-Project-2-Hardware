library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity regmultiplexor is

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

end regmultiplexor;

architecture mixed of regmultiplexor is

  component mipsdecoder is

    port(i_A          : in std_logic_vector(4 downto 0);
         o_F          : out std_logic_vector(31 downto 0));

  end component;

  signal s_S : std_logic_vector(31 downto 0);

begin

  decoder0: mipsdecoder port map(i_A => i_S,
                                 o_F => s_S);

  o_F <= i_R1 when s_S(1) = '1' else
         i_R2 when s_S(2) = '1' else
         i_R3 when s_S(3) = '1' else
         i_R4 when s_S(4) = '1' else
         i_R5 when s_S(5) = '1' else
         i_R6 when s_S(6) = '1' else
         i_R7 when s_S(7) = '1' else
         i_R8 when s_S(8) = '1' else
         i_R9 when s_S(9) = '1' else
         i_R10 when s_S(10) = '1' else
         i_R11 when s_S(11) = '1' else
         i_R12 when s_S(12) = '1' else
         i_R13 when s_S(13) = '1' else
         i_R14 when s_S(14) = '1' else
         i_R15 when s_S(15) = '1' else
         i_R16 when s_S(16) = '1' else
         i_R17 when s_S(17) = '1' else
         i_R18 when s_S(18) = '1' else
         i_R19 when s_S(19) = '1' else
         i_R20 when s_S(20) = '1' else
         i_R21 when s_S(21) = '1' else
         i_R22 when s_S(22) = '1' else
         i_R23 when s_S(23) = '1' else
         i_R24 when s_S(24) = '1' else
         i_R25 when s_S(25) = '1' else
         i_R26 when s_S(26) = '1' else
         i_R27 when s_S(27) = '1' else
         i_R28 when s_S(28) = '1' else
         i_R29 when s_S(29) = '1' else
         i_R30 when s_S(30) = '1' else
         i_R31 when s_S(31) = '1' else
         i_R0;

  
end mixed;