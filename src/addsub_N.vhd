library IEEE;
use IEEE.std_logic_1164.all;

entity addsub_N is
  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_C          : in std_logic;
       i_I1         : in std_logic_vector(N-1 downto 0);
       i_I2         : in std_logic_vector(N-1 downto 0);
       o_S          : out std_logic_vector(N-1 downto 0);
       o_C          : out std_logic);

end addsub_N;

architecture structural of addsub_N is

  component adder is
    port(i_C        : in std_logic;
       i_I1         : in std_logic;
       i_I2         : in std_logic;
       o_S          : out std_logic;
       o_C          : out std_logic);
  end component;

  component onescomp_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_D          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_C : std_logic_vector(N downto 0); -- Carries
  signal s_I2N : std_logic_vector(N-1 downto 0); -- Inverted
  signal s_I2 : std_logic_vector(N-1 downto 0); -- Mux result

begin

  -- Set first carry with control bit
  s_C(0) <= i_C;

  -- Set inverse for mux input
  OnesComp: onescomp_N
  generic map(N          => N)
  port map(
              i_D      => i_I2,
              o_O      => s_I2N);

  -- Mux to determine adder's second input
  Mux: mux2t1_N
  generic map(N          => N)
  port map(
              i_S      => i_C,      -- All instances share the same select input.
              i_D0     => i_I2,  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_D1     => s_I2N,  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_O      => s_I2);  -- ith instance's data output hooked up to ith data output.

  -- Instantiate N adder instances.
  G_NBit_ADDER: for i in 0 to N-1 generate
    ADDERI: adder port map(
              i_C      => s_C(i),
              i_I1     => i_I1(i),
              i_I2     => s_I2(i),
              o_S      => o_S(i),
              o_C      => s_C(i + 1));
  end generate G_NBit_ADDER;

  o_C <= s_C(N);
  
end structural;