library IEEE;
use IEEE.std_logic_1164.all;

entity EXMEMPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	
	jumpinstrin	:in std_logic_vector(25 downto 0);
	ALUin		:in std_logic_vector(N-1 downto 0);
	writeDatain	:in std_logic_vector(4 downto 0); 
	setPCin		:in std_logic_vector(N-1 downto 0);
	setPCout	:out std_logic_vector(N-1 downto 0);
	writeDataout	:out std_logic_vector(4 downto 0);
	jumpinstrout	:out std_logic_vector(25 downto 0);
	ALUout		:out std_logic_vector(N-1 downto 0);
	
	--control I/O
	memWrin		:in std_logic;
	memtoregin	:in std_logic;
	zeroin		:in std_logic;
	branchin	:in std_logic;
	jumpin		:in std_logic_vector(1 downto 0);
	branchout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0);
	zeroout		:out std_logic;
	memtoregout	:out std_logic;	
	memWrout	:out std_logic);
end EXMEMPipeline;

architecture structural of EXMEMPipeline is
	component nreg
	   port(
		i_CLK        : in std_logic;     -- Clock input
        	i_RST        : in std_logic;     -- Reset input
        	i_WE         : in std_logic;     -- Write enable input
        	i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       		o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	end component;
     
	component dffg
	   port(
		i_CLK        : in std_logic;     -- Clock input
        	i_RST        : in std_logic;     -- Reset input
        	i_WE         : in std_logic;     -- Write enable input
        	i_D          : in std_logic;     -- Data value input
        	o_Q          : out std_logic);   -- Data value output
	end component;

signal storeALUData,storesetPCdata	:std_logic_vector(N-1 downto 0);
signal storejumpdata	:std_logic_vector(1 downto 0);
signal storejumpinstrdata :std_logic_vector(25 downto 0);
signal storewriteData	  :std_logic_vector(4 downto 0);
signal s_write,ALUsrcData, memWrData, writeregData, storezerodata, storebranchdata, storememtoregData   :std_logic;


begin
	s_write <= NOT stall;
	


	storeALUData <= ALUin when flush = '0' else
			x"00000000";
	memWrData <= memWrin when flush = '0' else
		     	'0';
	storememtoregData <= memtoregin when flush = '0' else
		     	'0';
	storezerodata <= zeroin when flush = '0' else
			'0';
	storebranchdata <= branchin when flush = '0' else
			'0';
	storejumpdata	<= jumpin when flush = '0' else
			"00";
	storejumpinstrdata <= jumpinstrin when flush = '0' else
			"00000000000000000000000000";
	storewriteData	<= writeDatain when flush = '0' else
			"00000";
	storesetPCdata	<= setPCin when flush = '0' else
			x"00000000";
	


	ALUdata: nreg port map(clk,reset,s_write,storeALUData,ALUout);
	setPCdata: nreg port map(clk,reset,s_write,storesetPCdata,setPCout);

	G_NBit_dffg_1: for i in 0 to 1 generate
	jumpdata: dffg
		port map(clk,reset,s_write, storejumpdata(i), jumpout(i));
	end generate G_NBit_dffg_1;

	G_NBit_dffg_2: for i in 0 to 25 generate
	jumpinstrdata: dffg
		port map(clk,reset,s_write, storejumpinstrdata(i), jumpinstrout(i));
	end generate G_NBit_dffg_2;

	G_NBit_dffg_4: for i in 0 to 4 generate
	writeData: dffg
		port map(clk,reset,s_write, storewriteData(i), writeDataout(i));
	end generate G_NBit_dffg_4;

	zerodata: dffg port map(clk,reset,s_write,storezerodata,zeroout);
	branchdata: dffg port map(clk,reset,s_write,storebranchdata,branchout);
	memWrdatareg: dffg port map(clk,reset,s_write,memWrData,memwrout);
  	memtoregdata: dffg port map(clk,reset,s_write,storememtoregData,memtoregout);
  
end structural;