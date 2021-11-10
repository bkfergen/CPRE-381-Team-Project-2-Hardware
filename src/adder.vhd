library IEEE;
use IEEE.std_logic_1164.all;

entity adder is

  port(i_C          : in std_logic;
       i_I1         : in std_logic;
       i_I2         : in std_logic;
       o_S          : out std_logic;
       o_C          : out std_logic);

end adder;

architecture structure of adder is

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

	signal s_CN : std_logic;
	signal s_I1N : std_logic;
	signal s_I2N : std_logic;

	signal s_S11 : std_logic;
	signal s_S12 : std_logic;
	signal s_S13 : std_logic;
	signal s_S14 : std_logic;
	signal s_S21 : std_logic;
	signal s_S22 : std_logic;
	signal s_S23 : std_logic;
	signal s_S24 : std_logic;
	signal s_SO1 : std_logic;
	signal s_SO2 : std_logic;

	signal s_C11 : std_logic;
	signal s_C12 : std_logic;
	signal s_C13 : std_logic;
	signal s_C14 : std_logic;
	signal s_C21 : std_logic;
	signal s_C22 : std_logic;
	signal s_C23 : std_logic;
	signal s_C24 : std_logic;
	signal s_CO1 : std_logic;
	signal s_CO2 : std_logic;

begin
-- Provide inverted wires for Sum and Cout
	g_Invg0 : invg
	port MAP(i_A => i_C,
		 o_F => s_CN);

	g_Invg1 : invg
	port MAP(i_A => i_I1,
		 o_F => s_I1N);

	g_Invg2 : invg
	port MAP(i_A => i_I2,
		 o_F => s_I2N);
----------------------------------------- SUM
-- L1 and gates for Sum
	g_AndS11: andg2
	port MAP(i_A => i_I1,
       	         i_B => s_I2N,
       	         o_F => s_S11);
	g_AndS12: andg2
	port MAP(i_A => s_I1N,
       	         i_B => s_I2N,
       	         o_F => s_S12);
	g_AndS13: andg2
	port MAP(i_A => s_I1N,
       	         i_B => i_I2,
       	         o_F => s_S13);
	g_AndS14: andg2
	port MAP(i_A => i_I1,
       	         i_B => i_I2,
       	         o_F => s_S14);
-- L2 and gates for Sum
	g_AndS21: andg2
	port MAP(i_A => s_S11,
       	         i_B => s_CN,
       	         o_F => s_S21);
	g_AndS22: andg2
	port MAP(i_A => s_S12,
       	         i_B => i_C,
       	         o_F => s_S22);
	g_AndS23: andg2
	port MAP(i_A => s_S13,
       	         i_B => s_CN,
       	         o_F => s_S23);
	g_AndS24: andg2
	port MAP(i_A => s_S14,
       	         i_B => i_C,
       	         o_F => s_S24);
-- L1 or gates for Sum
	g_OrS11: org2
	port MAP(i_A => s_S21,
       	         i_B => s_S22,
       	         o_F => s_SO1);
	g_OrS12: org2
	port MAP(i_A => s_S23,
       	         i_B => s_S24,
       	         o_F => s_SO2);
-- L2 or gates for Sum
	g_OrS21: org2
	port MAP(i_A => s_SO1,
       	         i_B => s_SO2,
       	         o_F => o_S);
----------------------------------------- COUT
-- L1 and gates for Cout
	g_AndC11: andg2
	port MAP(i_A => s_I1N,
       	         i_B => i_I2,
       	         o_F => s_C11);
	g_AndC12: andg2
	port MAP(i_A => i_I1,
       	         i_B => s_I2N,
       	         o_F => s_C12);
	g_AndC13: andg2
	port MAP(i_A => i_I1,
       	         i_B => i_I2,
       	         o_F => s_C13);
	g_AndC14: andg2
	port MAP(i_A => i_I1,
       	         i_B => i_I2,
       	         o_F => s_C14);
-- L2 and gates for Cout
	g_AndC21: andg2
	port MAP(i_A => s_C11,
       	         i_B => i_C,
       	         o_F => s_C21);
	g_AndC22: andg2
	port MAP(i_A => s_C12,
       	         i_B => i_C,
       	         o_F => s_C22);
	g_AndC23: andg2
	port MAP(i_A => s_C13,
       	         i_B => s_CN,
       	         o_F => s_C23);
	g_AndC24: andg2
	port MAP(i_A => s_C14,
       	         i_B => i_C,
       	         o_F => s_C24);
-- L1 or gates for Cout
	g_OrC11: org2
	port MAP(i_A => s_C21,
       	         i_B => s_C22,
       	         o_F => s_CO1);
	g_OrC12: org2
	port MAP(i_A => s_C23,
       	         i_B => s_C24,
       	         o_F => s_CO2);
-- L2 or gates for Cout
	g_OrC21: org2
	port MAP(i_A => s_CO1,
       	         i_B => s_CO2,
       	         o_F => o_C);

end structure;