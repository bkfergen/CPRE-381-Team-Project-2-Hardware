library IEEE;
use IEEE.std_logic_1164.all;

entity EXMEMPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	
	writeDatain	:in std_logic_vector(4 downto 0); 
	ALUOutputin	:in std_logic_vector(31 downto 0);
	data2regin	:in std_logic_vector(31 downto 0);
	haltin		:in std_logic;
	instin		:in std_logic_vector(31 downto 0);
	writeDataout	:out std_logic_vector(4 downto 0);
	ALUOutputout	:out std_logic_vector(31 downto 0);
	data2regout	:out std_logic_vector(31 downto 0);
	haltout		:out std_logic;
	instout		:out std_logic_vector(31 downto 0);
	
	--control I/O
	memWrin		:in std_logic;
	memtoregin	:in std_logic;
	regwrin		:in std_logic;
	memtoregout	:out std_logic;	
	memWrout	:out std_logic;
	regwrout	:out std_logic);
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

signal storejumpdata	:std_logic_vector(1 downto 0);
signal storewriteData	  :std_logic_vector(4 downto 0);
signal storeALUOutput, storedata2reg, storeInst	:std_logic_vector(31 downto 0);
signal s_write,ALUsrcData, memWrData, writeregData, storezerodata, storebranchdata, storememtoregData, haltData, storeRegWr   :std_logic;


begin
	s_write <= NOT stall;
	


	memWrData <= memWrin when flush = '0' else
		     	'0';
	haltData <= haltin when flush = '0' else
		     	'0';
	storememtoregData <= memtoregin when flush = '0' else
		     	'0';
	storewriteData	<= writeDatain when flush = '0' else
			"00000";
	storeALUOutput <= ALUOutputin when flush = '0' else
		     	 x"00000000";
	storeInst <= instin when flush = '0' else
		     	 x"00000000";
	storedata2reg <= data2regin when flush = '0' else
		     	 x"00000000";
	storeRegWr <= regwrin when flush = '0' else
		     	'0';


	ALUOutputreg: nreg port map(clk,reset,s_write,storeALUOutput,ALUOutputout);

	G_NBit_dffg_4: for i in 0 to 4 generate
	writeData: dffg
		port map(clk,reset,s_write, storewriteData(i), writeDataout(i));
	end generate G_NBit_dffg_4;

	memWrdatareg: dffg port map(clk,reset,s_write,memWrData,memwrout);
  	memtoregdata: dffg port map(clk,reset,s_write,storememtoregData,memtoregout);
	haltdatareg: dffg port map(clk,reset,s_write,haltData,haltout);
	data2regdata: nreg port map(clk,reset,s_write,storedata2reg,data2regout);
	storeInstData: nreg port map(clk,reset,s_write,storeInst,instout);
	regwrdata: dffg port map(clk,reset,s_write,storeRegWr,regwrout);
  
end structural;