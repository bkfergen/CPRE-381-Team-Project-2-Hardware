library IEEE;
use IEEE.std_logic_1164.all;

entity slt_N is

  generic(N         : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0)); -- 0 = a not less than b, 1 = a less than b

end slt_N;

architecture structural of slt_N is

-- a    b     b-a
-- 1  < 2     1
-- 2  > 1     -1
-- 1  = 1     0
-- -1 > -2    -1
-- -2 < -1    1
-- 1  > -1    -2
-- -1 < 1     2

  component addsub_N is
    generic(N         : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_C          : in std_logic;
         i_I1         : in std_logic_vector(N-1 downto 0);
         i_I2         : in std_logic_vector(N-1 downto 0);
         o_S          : out std_logic_vector(N-1 downto 0);
         o_C          : out std_logic);
  end component;

  component mux2t1 is
    port(i_S          : in std_logic;
         i_D0         : in std_logic;
         i_D1         : in std_logic;
         o_O          : out std_logic);
  end component;

  component xorg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component invg is
    port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;

  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component notequal_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic);
  end component;

  component andg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  signal s_S : std_logic_vector(N-1 downto 0);
  signal s_C : std_logic;
  signal s_Sn : std_logic;
  signal s_Equal : std_logic; -- 1 = ne, 0 = equal (not less than)
  signal s_Adder_Equal_Result : std_logic;
  signal s_Use_Adder : std_logic; -- 0 = use adder, 1 = use sign bit
  signal s_Select_Result : std_logic; -- 1 = less than, 0 = not less than

begin

  SLT_Xor: xorg2
  port map(i_A => i_A(N-1),
           i_B => i_B(N-1),
           o_F => s_Use_Adder);

  SLT_Adder: addsub_N -- b-a
  generic map(N => N)
  port map(i_C => '1', -- sub
           i_I1 => i_B,
           i_I2 => i_A,
           o_S => s_S,
           o_C => s_C);

  SLT_Adder_Sign_Inv: invg
  port map(i_A => s_S(N-1),
           o_F => s_Sn);

  SLT_Not_Equal: notequal_N
  port map(i_A => s_S,
           i_B => "00000000000000000000000000000000",
           o_F => s_Equal);

  SLT_And: andg2
  port map(i_A => s_Sn,
           i_B => s_Equal,
           o_F => s_Adder_Equal_Result);

  SLT_Select_Result_Mux: mux2t1
  port map(i_S => s_Use_Adder,
           i_D0 => s_Adder_Equal_Result,
           i_D1 => i_B(N-1),
           o_O => s_Select_Result);

  SLT_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Select_Result,
           i_D0 => "00000000000000000000000000000000",
           i_D1 => "00000000000000000000000000000001",
           o_O => o_F);

end structural;