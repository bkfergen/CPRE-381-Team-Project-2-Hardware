library IEEE;
use IEEE.std_logic_1164.all;

entity IDEXPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	
	
	jumpinstrin	:in std_logic_vector(25 downto 0);
	rsDatain	:in std_logic_vector(N-1 downto 0);
	rtDatain	:in std_logic_vector(N-1 downto 0);
	Immedin		:in std_logic_vector(N-1 downto 0);
	ALUcontrolin	:in std_logic_vector(14 downto 0);
	writeDatain	:in std_logic_vector(4 downto 0);
	rsAddrin	:in std_logic_vector(4 downto 0);
	rtAddrin	:in std_logic_vector(4 downto 0);
	Instin		:in std_logic_vector(31 downto 0);
	add4in		:in std_logic_vector(31 downto 0);
	pcAddrin	:in std_logic_vector(31 downto 0);
	writeDataout	:out std_logic_vector(4 downto 0);
	ALUcontrolout	:out std_logic_vector(14 downto 0);
	rsDataout	:out std_logic_vector(N-1 downto 0);	
	rtDataout	:out std_logic_vector(N-1 downto 0);
	Immedout	:out std_logic_vector(N-1 downto 0);
	jumpinstrout	:out std_logic_vector(25 downto 0);
	rsAddrout	:out std_logic_vector(4 downto 0);
	rtAddrout	:out std_logic_vector(4 downto 0);
	Instout		:out std_logic_vector(31 downto 0);
	add4out		:out std_logic_vector(31 downto 0);
	pcAddrout	:out std_logic_vector(31 downto 0);
	

	--Control I/O
	branchin	:in std_logic;
	memWrin		:in std_logic;
	regdstin	:in std_logic;
	memtoregin	:in std_logic;
	jumpin		:in std_logic_vector(1 downto 0);
	memtoregout	:out std_logic;
	branchout	:out std_logic;
	regdstout	:out std_logic;
	memWrout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0));
	--
end IDEXPipeline;

architecture structural of IDEXPipeline is
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

signal storeAdd4Data, storersData, storertData, storeimmedData, storepcAddr, storeInstData	:std_logic_vector(N-1 downto 0);
signal ALUcontrolData		:std_logic_vector(14 downto 0);
signal shamtData		:std_logic_vector(4 downto 0);
signal storejumpinstrdata	:std_logic_vector(25 downto 0);
signal storejumpdata		:std_logic_vector(1 downto 0);
signal storewritedata		:std_logic_vector(4 downto 0);
signal s_write, memWrData,memtoregData, regdstData, writeregData, memreadData, storebranchdata	:std_logic;


begin
	s_write <= NOT stall;
	
	
	storersData <= rsDatain when flush = '0' else
		     	 x"00000000";
	storertData <= rtDatain when flush = '0' else
		     	 x"00000000";
	storeimmedData <= immedin when flush = '0' else
		     	 x"00000000";
	ALUcontrolData <= ALUcontrolin when flush = '0' else
		     	 "000000000000000";
	storejumpinstrdata <= jumpinstrin when flush = '0' else
		     	 "00000000000000000000000000";
	memWrData <= memWrin when flush = '0' else
		     	'0';
	regdstData <= regdstin when flush = '0' else
		     	'0';
	storebranchdata <= branchin when flush = '0' else
			'0';
	memtoregData	<= memtoregin when flush = '0' else
			'0';

	storejumpdata	<= jumpin when flush = '0' else
			"00";
	storewritedata	<= writeDatain when flush = '0' else
			"00000";

	storeAdd4Data <= add4in when flush = '0' else
		      	 x"00000000";
	storeInstData <= Instin when flush = '0' else
		     	 x"00000000";
	storepcAddr <= pcAddrin when flush = '0' else
		     	 x"00000000";
	
	rsdata: nreg port map(clk,reset,s_write,storersData,rsDataout);
	rtdata: nreg port map(clk,reset,s_write,storertData,rtDataout);
	immeddata: nreg port map(clk,reset,s_write,storeimmedData,immedout);

	G_NBit_dffg: for i in 0 to 14 generate
	ALUcontroldatareg: dffg
	port map(clk,reset,s_write,ALUcontrolData(i),ALUcontrolout(i));
	end generate G_NBit_dffg;

	G_NBit_dffg_2: for i in 0 to 25 generate
	jumpinstrdata: dffg
			port map(clk,reset,s_write, storejumpinstrdata(i), jumpinstrout(i));
	end generate G_NBit_dffg_2;
	
	G_NBit_dffg_3: for i in 0 to 1 generate
	jumpdata: dffg
			port map(clk,reset,s_write, storejumpdata(i), jumpout(i));
	end generate G_NBit_dffg_3;

	G_NBit_dffg_4: for i in 0 to 4 generate
	writedata: dffg
			port map(clk,reset,s_write, storewritedata(i), writeDataout(i));
	end generate G_NBit_dffg_4;
	
	memtoreg: dffg port map(clk,reset,s_write,memtoregData,memtoregout);
	memWrdatareg: dffg port map(clk,reset,s_write,memWrData,memwrout);
	regdstdatareg: dffg port map(clk,reset,s_write,regdstData,regdstout);
	branchdata: dffg port map(clk,reset,s_write,storebranchdata,branchout);

	add4data: nreg port map(clk,reset,s_write,storeAdd4Data,add4out);
	instdata: nreg port map(clk,reset,s_write,storeInstData,Instout);
	pcAddrdata: nreg port map(clk,reset,s_write,storepcAddr,pcAddrout);


  
  
end structural;