library IEEE;
use IEEE.std_logic_1164.all;

entity IFIDPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	add4Datain	:in std_logic_vector(N-1 downto 0);
	imemDatain	:in std_logic_vector(N-1 downto 0);
	add4Dataout	:out std_logic_vector(N-1 downto 0);
	imemDataout	:out std_logic_vector(N-1 downto 0));	
end IFIDPipeline;

architecture structural of IFIDPipeline is
	component nreg
	   port(
		i_CLK        : in std_logic;     -- Clock input
        	i_RST        : in std_logic;     -- Reset input
        	i_WE         : in std_logic;     -- Write enable input
        	i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       		o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	end component;

signal storeAdd4Data, storeImemData	:std_logic_vector(N-1 downto 0);
signal s_write	:std_logic;


begin
	s_write <= NOT stall;
	
	storeAdd4Data <= add4Datain when flush = '0' else
		      	 x"00000000";
	storeImemData <= imemDatain when flush = '0' else
		     	 x"00000000";

	add4data: nreg port map(clk,reset,s_write,storeAdd4Data,add4Dataout);
	imemdata: nreg port map(clk,reset,s_write,storeImemData,imemDataout);



  
  
end structural;