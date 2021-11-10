library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is

  port(i_S          : in std_logic;
       i_D0         : in std_logic;
       i_D1         : in std_logic;
       o_O          : out std_logic);

end mux2t1;

architecture structure of mux2t1 is

  component invg
    port(i_A           : in std_logic;
         o_F           : out std_logic);
  end component;

  component andg2
    port(i_A           : in std_logic;
	 i_B           : in std_logic;
         o_F           : out std_logic);
  end component;

  component org2
    port(i_A           : in std_logic;
	 i_B           : in std_logic;
         o_F           : out std_logic);
  end component;

	signal s_Sn : std_logic;
	signal s_D0 : std_logic;
	signal s_D1 : std_logic;

begin

	g_Invg : invg
	port MAP(i_A => i_S,
		 o_F => s_Sn);
--
	g_And0: andg2
	port MAP(i_A => s_Sn,
       	         i_B => i_D0,
       	         o_F => s_D0);

	g_And1: andg2
	port MAP(i_A => i_S,
       	         i_B => i_D1,
       	         o_F => s_D1);
--
	g_Or: org2
	port MAP(i_A => s_D0,
       	         i_B => s_D1,
       	         o_F => o_O);
  
end structure;