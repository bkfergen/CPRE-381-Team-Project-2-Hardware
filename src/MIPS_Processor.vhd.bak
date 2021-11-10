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
	     ReadAddr        : out std_logic_vector(N-1 downto 0));
   end component;

  component andg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
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

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  BranchAndZero: andg2
    port map(i_A => s_Branch,
             i_B => s_Zero,
             o_F => s_BranchAndZero);

  FetchLogic: fetch 
    port map(
			En 		=> '1',
			Jump_en 	=> s_Jump,
			Branch_en	=> s_BranchAndZero,
			imm		=> s_ExtendedImm,
                        set_pc          => s_FirstData1,
			Instruction 	=> s_Inst,
			iCLK		=> iCLK,
			iRST		=> iRST,
			ReadAddr 	=> s_NextInstAddr);

  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);

  s_DMemAddr <= s_Output;
  s_DMemData <= s_Data2Reg;
  
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

  MIPS_Proc_WriteAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(0),
           i_D0 => s_Inst(20 downto 16),
           i_D1 => s_Inst(15 downto 11),
           o_O => s_RegInstWrAddr);

  MIPS_Proc_JalWriteAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(1),
           i_D0 => s_RegInstWrAddr,
           i_D1 => "11111", -- Return register
           o_O => s_RegWrAddr);

  MIPS_Proc_JrReadAddress: mux2t1_N
  generic map(N => 5)
  port map(i_S => s_RegDst(1),
           i_D0 => s_Inst(25 downto 21),
           i_D1 => "11111", -- Return register
           o_O => s_RegARdAddr);

  MIPS_RegisterFile: registerfile
  port map(i_CLK => iCLK,
    i_RST => iRST,
    i_WE => s_RegWr,
    i_D => s_RegWrData,
    i_ReadA => s_RegARdAddr,
    i_ReadB => s_Inst(20 downto 16),
    i_Write => s_RegWrAddr,
    o_A => s_FirstData1,
    o_B => s_Data2Reg);

  MIPS_Control: control
   port map(
    opcode => s_Inst(31 downto 26),
    Funct  => s_Inst(5 downto 0),
    ALUSrc => s_ALUSrc,
    RegDst => s_RegDst,
    MemReg => s_MemReg,
    RegWr  => s_RegWr,
    MemRd  => s_MemRd, -- seems to be always the same as MemReg so potentially unnecessary?
    MemWr  => s_DMemWr,
    Branch => s_Branch,
    Jump   => s_Jump,
    sign   => s_sign,
    ALU_Op => s_ALU_Op);

  MIPS_Proc_Data2: mux2t1_N
  generic map(N => N)
  port map(i_S => s_ALUSrc,
           i_D0 => s_Data2Reg,
           i_D1 => s_ExtendedImm,
           o_O => s_FirstData2);

  MIPS_Proc_Data2JAL: mux2t1_N
  generic map(N => N)
  port map(i_S => s_RegDst(1),
           i_D0 => s_FirstData2,
           i_D1 => "00000000000000000000000000000100",
           o_O => s_Data2);

  MIPS_Proc_Data1JAL: mux2t1_N
  generic map(N => N)
  port map(i_S => s_RegDst(1),
           i_D0 => s_FirstData1,
           i_D1 => s_IMemAddr(31 downto 0),
           o_O => s_Data1);

  MIPS_Extender: extender
  port map(i_SignExtend => s_sign,
    i_D => s_Inst(15 downto 0),
    o_Q => s_ExtendedImm);

  MIPS_Proc_ALU: mips_alu
  generic map(N => 32)
  port map(i_Data1 => s_Data1,          -- Data input 1
           i_Data2 => s_Data2,          -- Data input 2
           i_C => s_ALU_Op,             -- Control
           o_Overflow => s_Ovfl,        -- Overflow (1 = ovf, 0 = no ovf)
           o_Halt => s_Halt,            -- Halt (1 = halt, 0 = no halt)
           o_Output => s_Output,        -- Data output
           o_Zero => s_Zero);           -- Zero (1 = branch, 0 = no branch)

  oALUOut <= s_Output;

  MIPS_Proc_MemToReg: mux2t1_N
  generic map(N => N)
  port map(i_S => s_MemReg,
           i_D0 => s_Output,
           i_D1 => s_DMemOut,
           o_O => s_RegWrData);

end structure;

