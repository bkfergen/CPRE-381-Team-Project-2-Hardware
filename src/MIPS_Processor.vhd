-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  component mips_alu is
  generic(N       : integer := 32);
  port(i_Data1    : in std_logic_vector(N-1 downto 0);    -- Data input 1
       i_Data2    : in std_logic_vector(N-1 downto 0);    -- Data input 2
       i_C        : in std_logic_vector(14 downto 1);
         -- Control(1) - (1 = add/sub to output)
         -- Control(2) - (0 = add, 1 = sub)
         -- Control(3) - (1 = or to output)
         -- Control(4) - (1 = and to output)
         -- Control(5) - (1 = nor to output)
         -- Control(6) - (1 = xor to output)
         -- Control(7) - (1 = reql.qb to output)
         -- Control(8) - (1 = equal to zero, 0 = ne to zero)
         -- Control(9) - (1 = slt to output)
         -- Control(10) - (1 = barrelshifter to output)
         -- Control(11) - (0 = signed shift (if right), 1 = unsigned)
         -- Control(12) - (0 = right shift, 1 = left)
         -- Control(13) - (1 = activate halt code)
         -- Control(14) - (1 = Data2 to output. (All 0's = Data1 to output))
       o_Overflow : out std_logic;                        -- Overflow (1 = ovf, 0 = no ovf)
       o_Halt     : out std_logic;                        -- Halt (1 = halt, 0 = no halt)
       o_Output   : out std_logic_vector(N-1 downto 0);   -- Data output
       o_Zero     : out std_logic);                       -- Zero (1 = branch, 0 = no branch)
  end component;

  component control is 
  port(
    opcode	: in std_logic_vector(5 downto 0);
    Funct	: in std_logic_vector(5 downto 0);
    ALUSrc	: out std_logic;
    RegDst	: out std_logic_vector(1 downto 0);
    MemReg	: out std_logic;
    RegWr	: out std_logic;	
    MemRd	: out std_logic;
    MemWr	: out std_logic;
    Branch	: out std_logic;
    Jump	: out std_logic_vector(1 downto 0);
    sign	: out std_logic;
    ALU_Op  : out std_logic_vector(14 downto 1));
  end component;

  component registerfile is
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input (Currently resets all registers)
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(31 downto 0);     -- Data value input
         i_ReadA      : in std_logic_vector(4 downto 0);      -- Register Select Read A (RS)
         i_ReadB      : in std_logic_vector(4 downto 0);      -- Register Select Read B (RT)
         i_Write      : in std_logic_vector(4 downto 0);      -- Register Select Write (RD)
         o_A          : out std_logic_vector(31 downto 0);   -- Data value output A (RS)
         o_B          : out std_logic_vector(31 downto 0));   -- Data value output B (RT)
  end component;

  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component extender is
    port(i_SignExtend : in std_logic;     -- 0 = zero extended, 1 = sign extended
         i_D          : in std_logic_vector(15 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(31 downto 0));   -- Data value output
  end component;

  component Fetch is 
    port(    En		     : in std_logic;
	     Jump_en         : in std_logic_vector(1 downto 0);
	     Branch_en       : in std_logic;
	     imm 	     : in std_logic_vector(N-1 downto 0);
             set_pc          : in std_logic_vector(N-1 downto 0);
	     Instruction     : in std_logic_vector(N-1 downto 0);
	     iCLK            : in std_logic;
       	     iRST            : in std_logic;
             IdEx_add4in     : in std_logic_vector(N-1 downto 0);
             IfId_add4out    : out std_logic_vector(N-1 downto 0);
	     ReadAddr        : out std_logic_vector(N-1 downto 0));
   end component;

  component andg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
    end component;

  component IFIDPipeline is
   generic(N : integer := 32);
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

  component IDEXPipeline is
    generic(N : integer := 32);
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
	alusrcin	:in std_logic;
	memtoregout	:out std_logic;
	branchout	:out std_logic;
	regdstout	:out std_logic_vector(1 downto 0);
	memWrout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0);
	alusrcout	:out std_logic;
	regwrout	:out std_logic);
	--
  end component;

  component EXMEMPipeline is
   generic(N : integer := 32);
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
	branchin	:in std_logic;
	jumpin		:in std_logic_vector(1 downto 0);
	memtoregout	:out std_logic;	
	memWrout	:out std_logic;
	branchout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0);
	regwrout	:out std_logic);
  end component;

  component MEMWBPipeline is
   generic(N : integer := 32);
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
	branchin	:in std_logic;
	jumpin		:in std_logic_vector(1 downto 0);
	memtoregout	:out std_logic;
	branchout	:out std_logic;
	jumpout		:out std_logic_vector(1 downto 0);
	regwrout	:out std_logic);
  end component;

  component forwardingunit is
    port(i_memwb_register_rd : in std_logic_vector(4 downto 0);
         i_exmem_register_rd : in std_logic_vector(4 downto 0);
         i_memwb_reg_write : in std_logic;
         i_exmem_reg_write : in std_logic;
         i_idex_register_rs : in std_logic_vector(4 downto 0);
         i_idex_register_rt : in std_logic_vector(4 downto 0);
         o_forward_a : out std_logic_vector(1 downto 0);
         o_forward_b : out std_logic_vector(1 downto 0));

  end component;

  component hazardDetectUnit is
  generic(N: integer := 32);
	  port(
		IF_ID_Instruction 	: in std_logic_vector(N-1 downto 0);

-- not sure whether can directly get the register rt ad rs 
	--	ID_EX_RegisterRt 	: in std_logic_vector(N-1 downto 0);
	--	ID_EX_RegisterRs 	: in std_logic_vector(N-1 downto 0);

		ID_EX_jump 		: in std_logic;
		ID_EX_branch		: in std_logic;
		ID_EX_MemRead		: in std_logic;
		ID_EX_Instruction 	: in std_logic_vector(N-1 downto 0);   

   
		EX_MEM_Instruction 	: in std_logic_vector(N-1 downto 0); 
		EX_MEM_branch		: in std_logic;
		EX_MEM_jump		: in std_logic;
		EX_MEM_MemRead		: in std_logic;
  

		MEM_WB_Instruction	: in std_logic_vector(N-1 downto 0);
		MEM_WB_branch		: in std_logic;
		MEM_WB_jump		: in std_logic;
		MEM_WB_MemRead		: in std_logic;

		CtrlMux		: out std_logic;
		IF_ID_Flush	: out std_logic;
		PC_WrEn 	: out std_logic);
	  
  end component;

  signal s_ReadB : std_logic_vector(4 downto 0);
  signal s_Data1 : std_logic_vector(N-1 downto 0);
  signal s_Data2 : std_logic_vector(N-1 downto 0);
  signal s_RegARdAddr : std_logic_vector(4 downto 0);
  signal s_Data2Reg : std_logic_vector(N-1 downto 0);
  signal s_ExtendedImm : std_logic_vector(N-1 downto 0);

  signal s_ALUSrc : std_logic;
  signal s_MemRd : std_logic;
  signal s_Branch : std_logic;
  signal s_Jump : std_logic_vector(1 downto 0);
  signal s_RegDst : std_logic_vector(1 downto 0);
  signal s_sign : std_logic;
  signal s_ALU_Op : std_logic_vector(14 downto 1);

  signal s_Zero : std_logic;
  signal s_Output : std_logic_vector(N-1 downto 0);

  signal s_MemReg : std_logic;

  signal s_RegInstWrAddr : std_logic_vector(4 downto 0);
  signal s_FirstData1 : std_logic_vector(31 downto 0);
  signal s_FirstData2 : std_logic_vector(31 downto 0);
  signal s_BranchAndZero : std_logic;

  signal s_PC_En : std_logic;
  signal s_CtrlMux : std_logic;
  signal s_IfId_Flush : std_logic;

--IF
  signal s_If_add4 : std_logic_vector(31 downto 0);
  signal s_If_Inst : std_logic_vector(31 downto 0);

--ID
  signal s_Id_add4 : std_logic_vector(31 downto 0);
  signal s_Id_Inst : std_logic_vector(31 downto 0);
  signal s_Id_pcAddr : std_logic_vector(31 downto 0);
  signal s_Id_RegWrAddr : std_logic_vector(4 downto 0);
  signal s_Id_RegWr : std_logic;
  signal s_Id_DMemWr : std_logic;

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
  signal s_Forward_A : std_logic_vector(1 downto 0);
  signal s_Forward_B : std_logic_vector(1 downto 0);
  signal s_Forward_A_Lower_Result : std_logic_vector(31 downto 0);
  signal s_Forward_A_Upper_Result : std_logic_vector(31 downto 0);
  signal s_Forward_B_Lower_Result : std_logic_vector(31 downto 0);
  signal s_Forward_B_Upper_Result : std_logic_vector(31 downto 0);
  signal s_Data2_Pre : std_logic_vector(31 downto 0);
  signal s_Ex_ALUSrc : std_logic;

--MEM
  signal s_Mem_Output : std_logic_vector(31 downto 0);
  signal s_Mem_Data2Reg : std_logic_vector(31 downto 0);
  signal s_Mem_RegWrAddr : std_logic_vector(4 downto 0);
  signal s_Mem_MemReg : std_logic;
  signal s_Mem_DMemWr : std_logic;
  signal s_Mem_Halt : std_logic;
  signal s_Mem_Inst : std_logic_vector(31 downto 0);
  signal s_Mem_RegWr : std_logic;
  signal s_Mem_Branch : std_logic;
  signal s_Mem_Jump : std_logic_vector(1 downto 0);

--WB
  signal s_Wb_RegWr : std_logic;
  signal s_Wb_RegWrAddr : std_logic_vector(4 downto 0);
  signal s_Wb_Output : std_logic_vector(31 downto 0);
  signal s_Wb_DMemOut : std_logic_vector(31 downto 0);
  signal s_Wb_MemReg : std_logic;
  signal s_Wb_Inst : std_logic_vector(31 downto 0);
  signal s_Wb_Branch : std_logic;
  signal s_Wb_Jump : std_logic_vector(1 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  BranchAndZero: andg2
    port map(i_A => s_Ex_Branch,
             i_B => s_Zero,
             o_F => s_BranchAndZero);

  FetchLogic: fetch 
    port map(
			En 		=> s_PC_En,
			Jump_en 	=> s_Ex_Jump,
			Branch_en	=> s_BranchAndZero,
			imm		=> s_Ex_ExtendedImm,
                        set_pc          => s_Ex_FirstData1,
			Instruction 	=> s_Ex_Inst,
			iCLK		=> iCLK,
			iRST		=> iRST,
                        IdEx_add4in     => s_Ex_add4,
                        IfId_add4out    => s_If_add4,
			ReadAddr 	=> s_NextInstAddr);

  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_If_Inst);

  s_DMemAddr <= s_Mem_Output;
  s_DMemData <= s_Mem_Data2Reg;
  s_DMemWr <= s_Mem_DMemWr;
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

  MIPS_IF_ID_Pipeline_Register: IFIDPipeline
  generic map(N => 32)
  port map(clk => iCLK,
           reset => iRST,
           flush => s_IfId_Flush, --FLUSH
           stall => '0', --STALL (Change later)
           add4Datain => s_If_add4,
           imemDatain => s_If_Inst,
           pcAddrin => s_IMemAddr(31 downto 0),
           add4Dataout => s_Id_add4,
           imemDataout => s_Id_Inst,
           pcAddrout => s_Id_pcAddr);
  

  MIPS_Proc_WriteAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(0),
           i_D0 => s_Id_Inst(20 downto 16),
           i_D1 => s_Id_Inst(15 downto 11),
           o_O => s_RegInstWrAddr);

  MIPS_Proc_JalWriteAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(1),
           i_D0 => s_RegInstWrAddr,
           i_D1 => "11111", -- Return register
           o_O => s_Id_RegWrAddr);

  MIPS_Proc_JrReadAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(1),
           i_D0 => s_Id_Inst(25 downto 21),
           i_D1 => "11111", -- Return register
           o_O => s_RegARdAddr);

  s_RegWrAddr <= s_Wb_RegWrAddr;
  s_RegWr <= s_Wb_RegWr;

  MIPS_RegisterFile: registerfile
  port map(i_CLK => iCLK,
    i_RST => iRST,
    i_WE => s_RegWr,
    i_D => s_RegWrData,
    i_ReadA => s_RegARdAddr,
    i_ReadB => s_Id_Inst(20 downto 16),
    i_Write => s_RegWrAddr,
    o_A => s_FirstData1,
    o_B => s_Data2Reg);

  MIPS_Control: control
   port map(
    opcode => s_Id_Inst(31 downto 26),
    Funct  => s_Id_Inst(5 downto 0),
    ALUSrc => s_ALUSrc,
    RegDst => s_RegDst,
    MemReg => s_MemReg,
    RegWr  => s_Id_RegWr,
    MemRd  => s_MemRd, -- seems to be always the same as MemReg so potentially unnecessary?
    MemWr  => s_Id_DMemWr,
    Branch => s_Branch,
    Jump   => s_Jump,
    sign   => s_sign,
    ALU_Op => s_ALU_Op);

  MIPS_Hazard_Detect_Unit: hazardDetectUnit
  generic map(N => 32)
  port map(IF_ID_Instruction => s_Id_Inst,
           ID_EX_jump =>s_Ex_Jump(0),
           ID_EX_branch => s_Ex_Branch,
           ID_EX_MemRead => s_Ex_MemReg,
           ID_EX_Instruction => s_Ex_Inst,
           EX_MEM_Instruction => s_Mem_Inst,
           EX_MEM_branch => s_Mem_Branch,
           EX_MEM_jump => s_Mem_Jump(0),
           EX_MEM_MemRead => s_Mem_MemReg,
           MEM_WB_Instruction => s_Wb_Inst,
           MEM_WB_branch => s_Wb_Branch,
           MEM_WB_jump => s_Wb_Jump(0),
           MEM_WB_MemRead => s_Wb_MemReg,
           CtrlMux => s_CtrlMux,
           IF_ID_Flush => s_IfId_Flush,
           PC_WrEn => s_PC_En);

  MIPS_ID_EX_Pipeline_Register: IDEXPipeline
  generic map(N => 32)
  port map(clk => iCLK,
           reset => iRST,
           flush => '0', -- Change Later
           stall => s_CtrlMux, -- Stall
           jumpinstrin => s_Id_Inst(25 downto 0),
           rsDatain => s_FirstData1,
           rtDatain => s_FirstData2,
           Immedin => s_ExtendedImm,
           ALUcontrolin => s_ALU_Op,
           writeDatain => s_Id_RegWrAddr,
           rsAddrin => s_RegARdAddr,
           rtAddrin => s_Id_Inst(20 downto 16),
           Instin => s_Id_Inst,
           add4in => s_Id_add4,
           pcAddrin => s_Id_pcAddr,
           data2regin => s_Data2reg,
           regwrin => s_Id_RegWr,
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
           branchin => s_Branch,
           memWrin => s_Id_DMemWr,
           regdstin => s_RegDst,
           memtoregin => s_MemReg,
           jumpin => s_Jump,
           alusrcin => s_ALUSrc,
           memtoregout => s_Ex_MemReg,
           branchout => s_Ex_Branch,
           regdstout => s_Ex_RegDst,
           memWrout => s_Ex_DMemWr,
           jumpout => s_Ex_Jump,
           alusrcout => s_Ex_ALUSrc,
           regwrout => s_Ex_RegWr);

  MIPS_Proc_Forwarding_Unit: forwardingunit
  port map(i_memwb_register_rd => s_Wb_RegWrAddr,
           i_exmem_register_rd => s_Mem_RegWrAddr,
           i_memwb_reg_write => s_Wb_RegWr,
           i_exmem_reg_write => s_Mem_RegWr,
           i_idex_register_rs => s_Ex_Rs,
           i_idex_register_rt => s_Ex_Rt,
           o_forward_a => s_Forward_A,
           o_forward_b => s_Forward_B);

  MIPS_Proc_Forward_A_Lower: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Forward_A(0),
           i_D0 => s_Ex_FirstData1,
           i_D1 => s_RegWrData,
           o_O => s_Forward_A_Lower_Result);

  MIPS_Proc_Forward_A_Upper: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Forward_A(1),
           i_D0 => s_Forward_A_Lower_Result,
           i_D1 => s_Mem_Output,
           o_O => s_Forward_A_Upper_Result);

  MIPS_Proc_Forward_B_Lower: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Forward_B(0),
           i_D0 => s_Ex_FirstData2,
           i_D1 => s_RegWrData,
           o_O => s_Forward_B_Lower_Result);

  MIPS_Proc_Forward_B_Upper: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Forward_B(1),
           i_D0 => s_Forward_B_Lower_Result,
           i_D1 => s_Mem_Output,
           o_O => s_Forward_B_Upper_Result);

  MIPS_Proc_Data2_Pre: mux2t1_N
  generic map(N => N)
  port map(i_S => s_ALUSrc,
           i_D0 => s_Data2Reg,
           i_D1 => s_ExtendedImm,
           o_O => s_FirstData2);

  MIPS_Proc_Data2: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Ex_ALUSrc,
           i_D0 => s_Data2_Pre,
           i_D1 => s_Ex_ExtendedImm,
           o_O => s_Data2);

  MIPS_Proc_Data2JAL: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Ex_RegDst(1),
           i_D0 => s_Forward_B_Upper_Result,
           i_D1 => "00000000000000000000000000000100",
           o_O => s_Data2_Pre);

  MIPS_Proc_Data1JAL: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Ex_RegDst(1),
           i_D0 => s_Forward_A_Upper_Result,
           i_D1 => s_Ex_pcAddr,
           o_O => s_Data1);

  MIPS_Extender: extender
  port map(i_SignExtend => s_sign,
    i_D => s_Id_Inst(15 downto 0),
    o_Q => s_ExtendedImm);

  MIPS_Proc_ALU: mips_alu
  generic map(N => 32)
  port map(i_Data1 => s_Data1,          -- Data input 1
           i_Data2 => s_Data2,          -- Data input 2
           i_C => s_Ex_ALU_Op,             -- Control
           o_Overflow => s_Ovfl,        -- Overflow (1 = ovf, 0 = no ovf)
           o_Halt => s_Ex_Halt,         -- Halt (1 = halt, 0 = no halt)
           o_Output => s_Output,        -- Data output
           o_Zero => s_Zero);           -- Zero (1 = branch, 0 = no branch)

  oALUOut <= s_Wb_Output;

  MIPS_EX_MEM_Pipeline_Register: EXMEMPipeline
  generic map(N => 32)
  port map(clk => iCLK,
           reset => iRST,
           flush => '0', -- Change Later
           stall => '0', -- Change Later
           writeDatain => s_Ex_RegWrAddr,
           ALUOutputin => s_Output,
           data2regin => s_Ex_Data2reg,
           haltin => s_Ex_Halt,
           instin => s_Ex_Inst,
           writeDataout => s_Mem_RegWrAddr,
           ALUOutputout => s_Mem_Output,
           data2regout => s_Mem_Data2reg,
           haltout => s_Mem_Halt,
           instout => s_Mem_Inst,
           memWrin => s_Ex_DMemWr,
           memtoregin => s_Ex_MemReg,
           regwrin => s_Ex_RegWr,
           branchin => s_Ex_Branch,
           jumpin => s_Ex_Jump,
           memtoregout => s_Mem_MemReg,
           memWrout => s_Mem_DMemWr,
           regwrout => s_Mem_RegWr,
           branchout => s_Mem_Branch,
           jumpout => s_Mem_Jump);

  MIPS_MEM_WB_Pipeline_Register: MEMWBPipeline
  generic map(N => 32)
  port map(clk => iCLK,
           reset => iRST,
           flush => '0', -- Change Later
           stall => '0', -- Change Later
           memDatain => s_DMemOut,
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
           branchin => s_Mem_Branch,
           jumpin => s_Mem_Jump,
           memtoregout => s_Wb_MemReg,
           regwrout => s_Wb_RegWr,
           branchout => s_Wb_Branch,
           jumpout => s_Wb_Jump);

  MIPS_Proc_MemToReg: mux2t1_N
  generic map(N => N)
  port map(i_S => s_Wb_MemReg,
           i_D0 => s_Wb_Output,
           i_D1 => s_Wb_DMemOut,
           o_O => s_RegWrData);

  s_Inst <= s_Wb_Inst;

end structure;

