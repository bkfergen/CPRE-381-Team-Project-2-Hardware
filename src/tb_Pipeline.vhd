library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;  

entity tb_Pipeline is
	generic(gCLK_HPER   : time     := 50 ns);
end tb_Pipeline;

architecture mixed of tb_Pipeline is 


	constant cCLK_PER  : time := gCLK_HPER * 2;

	component IDEXPipeline is
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
	ALUcontrolin	:in std_logic_vector(14 downto 1);
	writeDatain	:in std_logic_vector(4 downto 0);
	rsAddrin	:in std_logic_vector(4 downto 0);
	rtAddrin	:in std_logic_vector(4 downto 0);
	Instin		:in std_logic_vector(31 downto 0);
	add4in		:in std_logic_vector(31 downto 0);
	pcAddrin	:in std_logic_vector(31 downto 0);
	data2regin	:in std_logic_vector(31 downto 0);
	writeDataout	:out std_logic_vector(4 downto 0);
	ALUcontrolout	:out std_logic_vector(14 downto 1);
	rsDataout	:out std_logic_vector(N-1 downto 0);	
	rtDataout	:out std_logic_vector(N-1 downto 0);
	Immedout	:out std_logic_vector(N-1 downto 0);
	jumpinstrout	:out std_logic_vector(25 downto 0);
	rsAddrout	:out std_logic_vector(4 downto 0);
	rtAddrout	:out std_logic_vector(4 downto 0);
	Instout		:out std_logic_vector(31 downto 0);
	add4out		:out std_logic_vector(31 downto 0);
	pcAddrout	:out std_logic_vector(31 downto 0);
	data2regout	:out std_logic_vector(31 downto 0);
	

	--Control I/O
	branchin	:in std_logic;
	memWrin		:in std_logic;
	regdstin	:in std_logic_vector(1 downto 0);
	memtoregin	:in std_logic;
	jumpin		:in std_logic_vector(1 downto 0);
	regwrin		:in std_logic;
	memtoregout	:out std_logic;
	branchout	:out std_logic;
	regdstout	:out std_logic_vector(1 downto 0);
	memWrout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0);
	regwrout	:out std_logic);
	--
	end component;

	component IFIDPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	add4Datain	:in std_logic_vector(N-1 downto 0);
	imemDatain	:in std_logic_vector(N-1 downto 0);
	pcAddrin	:in std_logic_vector(31 downto 0);
	add4Dataout	:out std_logic_vector(N-1 downto 0);
	imemDataout	:out std_logic_vector(N-1 downto 0);	
	pcAddrout	:out std_logic_vector(N-1 downto 0));
	end component;
	
	component EXMEMPipeline is
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
	end component;

	component MEMWBPipeline is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
  	clk		:in std_logic;
	reset		:in std_logic;
	flush		:in std_logic;
	stall		:in std_logic;
	
	memDatain	:in std_logic_vector(N-1 downto 0);
	ALUin		:in std_logic_vector(N-1 downto 0);
	writeDatain	:in std_logic_vector(4 downto 0);
	haltin		:in std_logic;
	instin		:in std_logic_vector(31 downto 0);
	writeDataout	:out std_logic_vector(4 downto 0); 
	ALUout		:out std_logic_vector(N-1 downto 0);	
	memDataout	:out std_logic_vector(N-1 downto 0);
	haltout		:out std_logic;
	instout		:out std_logic_vector(31 downto 0);


	--control I/O
	memtoregin	:in std_logic;
	regwrin		:in std_logic;
	memtoregout	:out std_logic;
	regwrout	:out std_logic);
	end component;


	--IF
  	

	--ID
  	signal s_Id_add4 : std_logic_vector(31 downto 0);
  	signal s_Id_Inst : std_logic_vector(31 downto 0);
  	signal s_Id_pcAddr : std_logic_vector(31 downto 0);
  	signal s_Id_RegWrAddr : std_logic_vector(4 downto 0);
  	signal s_Id_RegWr : std_logic;

	--EX
  	signal s_Ex_add4 : std_logic_vector(31 downto 0);
  	signal s_Ex_Branch : std_logic;
  	signal s_Ex_Jump : std_logic_vector(1 downto 0);
  	signal s_Ex_ExtendedImm : std_logic_vector(31 downto 0);
  	signal s_Ex_FirstData1 : std_logic_vector(31 downto 0);
  	signal s_Ex_Inst : std_logic_vector(31 downto 0);
  	signal s_Ex_RegWrAddr : std_logic_vector(4 downto 0);
  	signal s_Ex_ALU_Op : std_logic_vector(14 downto 1);
  	signal s_Ex_FirstData2 : std_logic_vector(31 downto 0);
  	signal s_Ex_Inst_Jump : std_logic_vector(25 downto 0);
  	signal s_Ex_Rs : std_logic_vector(4 downto 0);
  	signal s_Ex_Rt : std_logic_vector(4 downto 0);
  	signal s_Ex_pcAddr : std_logic_vector(31 downto 0);
  	signal s_Ex_Data2reg : std_logic_vector(31 downto 0);
  	signal s_Ex_MemReg : std_logic;
  	signal s_Ex_RegDst : std_logic_vector(1 downto 0);
  	signal s_Ex_DMemWr : std_logic;
  	signal s_Ex_Halt : std_logic;
  	signal s_Ex_RegWr : std_logic;

	--MEM
  	signal s_Mem_Output : std_logic_vector(31 downto 0);
  	signal s_Mem_Data2Reg : std_logic_vector(31 downto 0);
  	signal s_Mem_RegWrAddr : std_logic_vector(4 downto 0);
  	signal s_Mem_MemReg : std_logic;
  	signal s_Mem_DMemWr : std_logic;
  	signal s_Mem_Halt : std_logic;
  	signal s_Mem_Inst : std_logic_vector(31 downto 0);
  	signal s_Mem_RegWr : std_logic;

	--WB
  	signal s_Wb_RegWr : std_logic;
  	signal s_Wb_RegWrAddr : std_logic_vector(4 downto 0);
  	signal s_Wb_Output : std_logic_vector(31 downto 0);
  	signal s_Wb_DMemOut : std_logic_vector(31 downto 0);
  	signal s_Wb_MemReg : std_logic;
  	signal s_Wb_Inst : std_logic_vector(31 downto 0);



	signal flush_ID_EX, stall_ID_EX,iRST, iCLK, flush_EX_MEM, stall_EX_MEM,flush_MEM_WB,stall_MEM_WB,s_Halt,flush_IF_ID,stall_IF_ID : std_logic;

begin 


	IFID_Pipeline: IFIDPipeline
	   generic map(N => 32)
	   port map(
	   clk => iCLK, 
	   reset => iRST,
           flush => flush_IF_ID,
           stall => stall_IF_ID,
           add4Datain => x"00000040",
           imemDatain => x"FFFFFFFF",
           pcAddrin => x"00000400",
           add4Dataout => s_Id_add4,
           imemDataout => s_Id_Inst,
           pcAddrout => s_Id_pcAddr);

	IDEX_Pipeline: IDEXPipeline
	generic map(N => 32)
  	port map(clk => iCLK,
           reset => iRST,
           flush => flush_ID_EX,
           stall => stall_ID_EX,
           jumpinstrin => s_Id_Inst(25 downto 0),
           rsDatain => x"0000F0F0",
           rtDatain => x"F0F00000",
           Immedin => x"5050FFFF",
           ALUcontrolin => b"01001100010101",
           writeDatain => b"01100",
           rsAddrin => b"11001",
           rtAddrin => s_Id_Inst(20 downto 16),
           Instin => s_Id_Inst,
           add4in => s_Id_add4,
           pcAddrin => s_Id_pcAddr,
           data2regin => x"FF000FF0",
           regwrin => '1',
           writeDataOut => s_Ex_RegWrAddr,
           ALUcontrolout => s_Ex_ALU_Op,
           rsDataout => s_Ex_FirstData1,
           rtDataout => s_Ex_FirstData2,
           Immedout => s_Ex_ExtendedImm,
           jumpinstrout => s_Ex_Inst_Jump,
           rsAddrout => s_Ex_Rs,
           rtAddrout => s_Ex_Rt,
           Instout => s_Ex_Inst,
           add4out => s_Ex_add4,
           pcAddrout => s_Ex_pcAddr,
           data2regout => s_Ex_Data2reg,
           branchin => '1',
           memWrin => '1',
           regdstin => b"11",
           memtoregin => '1',
           jumpin => b"11",
           memtoregout => s_Ex_MemReg,
           branchout => s_Ex_Branch,
           regdstout => s_Ex_RegDst,
           memWrout => s_Ex_DMemWr,
           jumpout => s_Ex_Jump,
           regwrout => s_Ex_RegWr);

	EXMEM_Pipeline: EXMEMPipeline
	generic map(N => 32)
  	port map(clk => iCLK,
           reset => iRST,
           flush => flush_EX_MEM,
           stall => stall_EX_MEM,
           writeDatain => s_Ex_RegWrAddr,
           ALUOutputin => x"0000FF00",
           data2regin => s_Ex_Data2reg,
           haltin => '1',
           instin => x"FFFF00FF",
           writeDataout => s_Mem_RegWrAddr,
           ALUOutputout => s_Mem_Output,
           data2regout => s_Mem_Data2reg,
           haltout => s_Mem_Halt,
           instout => s_Mem_Inst,
           memWrin => s_Ex_DMemWr,
           memtoregin => s_Ex_MemReg,
           regwrin => s_Ex_RegWr,
           memtoregout => s_Mem_MemReg,
           memWrout => s_Mem_DMemWr,
           regwrout => s_Mem_RegWr);

	MEMWB_Pipeline: MEMWBPipeline
	generic map(N => 32)
  	port map(clk => iCLK,
           reset => iRST,
           flush => flush_MEM_WB,
           stall => stall_MEM_WB,
           memDatain => x"00FF00FF",
           ALUin => s_Mem_Output,
           writeDatain => s_Mem_RegWrAddr,
           haltin => s_Mem_Halt,
           instin => s_Mem_Inst,
           writeDataout => s_Wb_RegWrAddr,
           haltout => s_Halt,
           ALUout => s_Wb_Output,
           memDataout => s_Wb_DMemOut,
           instout => s_Wb_Inst,
           memtoregin => s_Mem_MemReg,
           regwrin => s_Mem_RegWr,
           memtoregout => s_Wb_MemReg,
           regwrout => s_Wb_RegWr);

	P_CLK: process
  	begin
   	 iCLK <= '0';
    	wait for gCLK_HPER;
    	iCLK <= '1';
    	wait for gCLK_HPER;
  	end process;


TEST: process 
 begin
	iRST <= '1';
	wait for gCLK_HPER;
	iRST <= '0';
	wait for gCLK_HPER;
	flush_IF_ID <= '1';
	flush_ID_EX <= '1';
	flush_EX_MEM <= '1';
	flush_MEM_WB <= '1';
	wait for gCLK_HPER;

	flush_IF_ID <= '0';
	flush_ID_EX <= '0';
	flush_EX_MEM <= '0';
	flush_MEM_WB <= '0';
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	stall_IF_ID <= '0';
	stall_ID_EX <= '0';
	stall_EX_MEM <= '0';
	stall_MEM_WB <= '0';
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	stall_IF_ID <= '1';
	stall_ID_EX <= '1';
	stall_EX_MEM <= '1';
	stall_MEM_WB <= '1';
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	wait for gCLK_HPER;
	wait for gCLK_HPER;

	flush_IF_ID <= '1';
	flush_ID_EX <= '1';
	flush_EX_MEM <= '1';
	flush_MEM_WB <= '1';
	wait for gCLK_HPER;

	flush_IF_ID <= '0';
	flush_ID_EX <= '0';
	flush_EX_MEM <= '0';
	flush_MEM_WB <= '0';
	wait for gCLK_HPER;

   end process;

end mixed;
