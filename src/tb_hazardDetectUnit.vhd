library IEEE;
use IEEE.std_logic_1164.all;

entity tb_hazardDetectUnit is
  generic(gCLK_HPER   : time := 20 ns);
end tb_hazardDetectUnit;

architecture behavior of tb_hazardDetectUnit is

  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

  component hazardDetectUnit is
      generic(N: integer := 32);
	port(
		IF_ID_Instruction 	: in std_logic_vector(N-1 downto 0);

-- not sure whether can directly get the register rt ad rs 
		--ID_EX_RegisterRt 	: in std_logic_vector(N-1 downto 0);
		--ID_EX_RegisterRs 	: in std_logic_vector(N-1 downto 0);

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


  signal s_IF_ID_Instruction 		: std_logic_vector(31 downto 0);
  signal s_ID_EX_jump			: std_logic;
  signal s_ID_EX_branch			: std_logic;
  signal s_ID_EX_MemRead		: std_logic;
  signal s_ID_EX_Instruction 		: std_logic_vector(31 downto 0);

  signal s_EX_MEM_Instruction		: std_logic_vector(31 downto 0);
  signal s_EX_MEM_branch	 	: std_logic;
  signal s_EX_MEM_jump 			: std_logic;
  signal s_EX_MEM_MemRead 	 	: std_logic;

  signal s_MEM_WB_Instruction		: std_logic_vector(31 downto 0);
  signal s_MEM_WB_branch	 	: std_logic;
  signal s_MEM_WB_jump 			: std_logic;
  signal s_MEM_WB_MemRead 	 	: std_logic;

  signal s_CtrlMux			: std_logic;
  signal s_IF_ID_Flush			: std_logic;
  signal s_PC_WrEn 			: std_logic;
  signal s_CLK				: std_logic;

begin
Hazard: hazardDetectUnit
	port map( 
		IF_ID_Instruction	=> s_IF_ID_Instruction,

		ID_EX_jump		=> s_ID_EX_jump,
		ID_EX_branch		=> s_ID_EX_branch,
		ID_EX_MemRead		=> s_ID_EX_MemRead,
		ID_EX_Instruction	=> s_ID_EX_Instruction,

		EX_MEM_Instruction  	=> s_EX_MEM_Instruction,
		EX_MEM_branch 		=> s_EX_MEM_branch,
		EX_MEM_jump		=> s_EX_MEM_jump,
		EX_MEM_MemRead		=> s_EX_MEM_MemRead,

		MEM_WB_Instruction	=> s_MEM_WB_Instruction,
		MEM_WB_branch		=> s_MEM_WB_branch,
		MEM_WB_jump		=> s_MEM_WB_jump,
		MEM_WB_MemRead		=> s_MEM_WB_MemRead,

		CtrlMux			=> s_CtrlMux,
		IF_ID_Flush		=> s_IF_ID_Flush,
		PC_WrEn 		=> s_PC_WrEn
);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;


  -- Testbench process  
  P_TB: process
  begin
--test1: Data hazard 
-- lw v1, $a0(0)

-- addu v0, v0, v1 
-- 0b 100011 00100 00011 00....00
-- 0x 8C83
-- 0b 000000 00010 00011 00000 100001
	s_IF_ID_Instruction  <= X"00431021";
	s_ID_EX_Instruction  <= X"8C830000";
	s_ID_EX_MemRead      <= '1';
	s_ID_EX_branch	     <= '0';
	s_ID_EX_jump 	     <= '0';
 wait for gCLK_HPER;

--test2: Control hazard 
-- beq v0, v1, 0x1001
-- 0b 000100 00010 00011 0001 0000 0000 0001 
-- addu v0, v0, v1
-- 0b 000000 00010 00011 00000 100001
	s_IF_ID_Instruction  <= X"00431021";
	s_ID_EX_Instruction  <= b"00010000010000110001000000000001";
	s_ID_EX_MemRead      <= '1';
	s_ID_EX_branch	     <= '1';
	s_ID_EX_jump 	     <= '0';
 wait for gCLK_HPER;
--test3: Control hazard 
-- at ID/EX stage
-- jump 0x00001001 
-- 0b 000100 00 0000 0000 0001 0000 0000 0001 
-- addu v0, v0, v1
-- 0b 000010 00010 00011 00000 100001
	s_IF_ID_Instruction  <= X"00431021";
	s_ID_EX_Instruction  <= b"00010000000000000001000000000001";
	s_ID_EX_MemRead      <= '1';
	s_ID_EX_branch	     <= '0';
	s_ID_EX_jump 	     <= '1';

   wait;
  end process;
  
end behavior;



