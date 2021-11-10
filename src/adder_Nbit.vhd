library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_C          : in std_logic;
       i_I1         : in std_logic_vector(N-1 downto 0);
       i_I2         : in std_logic_vector(N-1 downto 0);
       o_S          : out std_logic_vector(N-1 downto 0);
       o_C          : out std_logic);

end adder_N;

architecture structural of adder_N is

  component adder is
    port(i_C        : in std_logic;
       i_I1         : in std_logic;
       i_I2         : in std_logic;
       o_S          : out std_logic;
       o_C          : out std_logic);
  end component;

  signal s_C : std_logic_vector(N downto 0); -- Carries

begin

  s_C(0) <= i_C;

  -- Instantiate N adder instances.
  G_NBit_ADDER: for i in 0 to N-1 generate
    ADDERI: adder port map(
              i_C      => s_C(i),
              i_I1     => i_I1(i),
              i_I2     => i_I2(i),
              o_S      => o_S(i),
              o_C      => s_C(i + 1));
  end generate G_NBit_ADDER;

  o_C <= s_C(N);
  
end structural;