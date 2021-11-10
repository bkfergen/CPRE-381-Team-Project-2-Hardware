---------------------------------------------------------------------------
-- Nicklas Cahill
-- Iowa State University
---------------------------------------------------------------------------


-- fulladder.vhd
---------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 8/27/21
---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity BarrelShifter is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  	port(i_in   : in std_logic_vector(31 downto 0);	
	i_logical   : in std_logic;			-- determines whether the shift is a logical or arithmetic shift
	i_Sleft	    : in std_logic;			-- determines whether the shift is a left or right shift
	i_Shamount  : in std_logic_vector(4 downto 0);	-- 5 bit long vector determining how much to shift by
	o_out	    : out std_logic_vector(31 downto 0));

end BarrelShifter;

architecture mixed of BarrelShifter is

   component mux2t1
	port(i_S       : in std_logic;
	i_D0	       : in std_logic;
	i_D1	       : in std_logic;
	o_O	       : out std_logic);
   end component;

   component mux32bit2t1
	port(i_0	: in std_logic_vector(31 downto 0);
     i_1	: in std_logic_vector(31 downto 0);
     i_S	: in std_logic;
     o_F	: out std_logic_vector(31 downto 0));
   end component;

signal s_lmux1, s_lmux2, s_lmux3, s_lmux4, s_lmux5	:std_logic_vector(31 downto 0); --signals for left shifting muxes
signal s_rmux1, s_rmux2, s_rmux3, s_rmux4, s_rmux5	:std_logic_vector(31 downto 0); --signals for right shifting muxes
signal s_logicalAndShiftDirection			:std_logic_vector(1 downto 0);  
signal s_signedorno 					:std_logic;			--used to determine if the input is signed or not
begin
	s_logicalAndShiftDirection(0) <= i_in(31);
	s_logicalAndShiftDirection(1) <= i_logical;

	s_signedorno <= '1' when s_logicalAndShiftDirection = "01" else --logic for determining if the input is signed or not
			'0';
	
  leftShift_NBit_MUXby1: for i in 0 to 31 generate --First Left shift muxes that shifts by 1
	Padding: if i=0 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(0),
		i_D0 =>  i_in(i),
		i_D1 =>  '0',
		o_O  =>  s_lmux1(i));
	end generate Padding;

	MoveBits: if i>0 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(0), 
		i_D0 => i_in(i),
		i_D1 => i_in(i-1), 
		o_O  => s_lmux1(i)); 
	end generate MoveBits; 
  end generate leftShift_NBit_MUXby1;

  leftShift_NBit_MUXby2: for i in 0 to 31 generate --Second Left shift muxes that shifts by 2
	Padding: if i<2 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(1),
		i_D0 =>  s_lmux1(i),
		i_D1 =>  '0',
		o_O  =>  s_lmux2(i));
	end generate Padding;

	MoveBits: if i>1 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(1), 
		i_D0 => s_lmux1(i),
		i_D1 => s_lmux1(i-2), 
		o_O  => s_lmux2(i)); 
	end generate MoveBits; 
  end generate leftShift_NBit_MUXby2;
  
  leftShift_NBit_MUXby4: for i in 0 to 31 generate --Third Left shift muxes that shifts by 4
	Padding: if i<4 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(2),
		i_D0 =>  s_lmux2(i),
		i_D1 =>  '0',
		o_O  =>  s_lmux3(i));
	end generate Padding;

	MoveBits: if i>3 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(2), 
		i_D0 => s_lmux2(i),
		i_D1 => s_lmux2(i-4),
		o_O  => s_lmux3(i)); 
	end generate MoveBits; 
  end generate leftShift_NBit_MUXby4;

  leftShift_NBit_MUXby8: for i in 0 to 31 generate --Fourth Left shift muxes that shifts by 8
	Padding: if i<8 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(3),
		i_D0 =>  s_lmux3(i),
		i_D1 =>  '0',
		o_O  =>  s_lmux4(i));
	end generate Padding;

	MoveBits: if i>7 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(3), 
		i_D0 => s_lmux3(i),
		i_D1 => s_lmux3(i-8), 
		o_O  => s_lmux4(i)); 
	end generate MoveBits; 
  end generate leftShift_NBit_MUXby8;

  leftShift_NBit_MUXby16: for i in 0 to 31 generate --Fifth Left shift muxes that shifts by 16
	Padding: if i<16 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(4),
		i_D0 =>  s_lmux4(i),
		i_D1 =>  '0',
		o_O  =>  s_lmux5(i));
	end generate Padding;

	MoveBits: if i>15 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(4), 
		i_D0 => s_lmux4(i),
		i_D1 => s_lmux4(i-16), 
		o_O  => s_lmux5(i)); 
	end generate MoveBits; 
  end generate leftShift_NBit_MUXby16;

  RightShift_NBit_MUXby1: for i in 31 downto 0 generate --First Right shift muxes that shifts by 1
	Padding: if i=31 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(0),
		i_D0 =>  i_in(i),
		i_D1 =>  s_signedorno,
		o_O  =>  s_rmux1(i));
	end generate Padding;

	MoveBits: if i<31 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(0), 
		i_D0 => i_in(i),
		i_D1 => i_in(i+1), 
		o_O  => s_rmux1(i)); 
	end generate MoveBits; 
  end generate RightShift_NBit_MUXby1;

  RightShift_NBit_MUXby2: for i in 31 downto 0 generate --Second Right shift muxes that shifts by 2
	Padding: if i>29 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(1),
		i_D0 =>  s_rmux1(i),
		i_D1 =>  s_signedorno,
		o_O  =>  s_rmux2(i));
	end generate Padding;

	MoveBits: if i<30 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(1), 
		i_D0 => s_rmux1(i),
		i_D1 => s_rmux1(i+2), 
		o_O  => s_rmux2(i)); 
	end generate MoveBits; 
  end generate RightShift_NBit_MUXby2;
  
  RightShift_NBit_MUXby4: for i in 31 downto 0 generate --Third Right shift muxes that shifts by 4
	Padding: if i>27 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(2),
		i_D0 =>  s_rmux2(i),
		i_D1 =>  s_signedorno,
		o_O  =>  s_rmux3(i));
	end generate Padding;

	MoveBits: if i<28 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(2), 
		i_D0 => s_rmux2(i),
		i_D1 => s_rmux2(i+4),
		o_O  => s_rmux3(i)); 
	end generate MoveBits; 
  end generate RightShift_NBit_MUXby4;

  RightShift_NBit_MUXby8: for i in 31 downto 0 generate --Fourth Right shift muxes that shifts by 8
	Padding: if i>23 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(3),
		i_D0 =>  s_rmux3(i),
		i_D1 =>  s_signedorno,
		o_O  =>  s_rmux4(i));
	end generate Padding;

	MoveBits: if i<24 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(3), 
		i_D0 => s_rmux3(i),
		i_D1 => s_rmux3(i+8), 
		o_O  => s_rmux4(i)); 
	end generate MoveBits; 
  end generate RightShift_NBit_MUXby8;

  RightShift_NBit_MUXby16: for i in 31 downto 0 generate --Fifth Right shift muxes that shifts by 16
	Padding: if i>15 generate
	   MUX1: mux2t1 port map(
		i_S  =>  i_Shamount(4),
		i_D0 =>  s_rmux4(i),
		i_D1 =>  s_signedorno,
		o_O  =>  s_rmux5(i));
	end generate Padding;

	MoveBits: if i<16 generate
	   MUX2: mux2t1 port map(
		i_S  => i_Shamount(4), 
		i_D0 => s_rmux4(i),
		i_D1 => s_rmux4(i+16), 
		o_O  => s_rmux5(i)); 
	end generate MoveBits; 
  end generate RightShift_NBit_MUXby16;
		
  RightOrLeftShift: mux32bit2t1				-- 32bit mux that chooses the Left or Right shifting muxes
	port map(s_rmux5, s_lmux5,i_Sleft,o_out);
  
end mixed;



















