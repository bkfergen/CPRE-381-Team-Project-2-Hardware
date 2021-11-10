library IEEE;
use IEEE.std_logic_1164.all;

entity extender is
  port(i_SignExtend : in std_logic;     -- 0 = zero extended, 1 = sign extended
       i_D          : in std_logic_vector(15 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(31 downto 0));   -- Data value output

end extender;

architecture structural of extender is

  component mux2t1 is

    port(i_S          : in std_logic;
         i_D0         : in std_logic;
         i_D1         : in std_logic;
         o_O          : out std_logic);

  end component;

  signal s_B : std_logic;

begin

  Mux: mux2t1
  port map(i_S =>i_SignExtend,
    i_D0 => '0',
    i_D1 => i_D(15),
    o_O => s_B);

  G_AssignLower: for i in 0 to 15 generate
    o_Q(i) <= i_D(i);
  end generate G_AssignLower;

  G_AssignUpper: for i in 16 to 31 generate
    o_Q(i) <= s_B;
  end generate G_AssignUpper;
  
end structural;