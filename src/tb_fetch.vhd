library IEEE;
use IEEE.std_logic_1164.all;

entity tb_fetch is
  generic(gCLK_HPER   : time := 20 ns);
end tb_fetch;

architecture behavior of tb_fetch is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

  component Fetch is
	generic(N: integer:= 32);
	port(En		     : in std_logic;
	     Jump_en         : in std_logic_vector(1 downto 0);
	     Branch_en       : in std_logic;
             set_pc          : in std_logic_vector(N-1 downto 0);
	     imm 	     : in std_logic_vector(N-1 downto 0);
	     Instruction     : in std_logic_vector(N-1 downto 0);
	     iCLK            : in std_logic;
       	     iRST            : in std_logic;
	     ReadAddr        : out std_logic_vector(N-1 downto 0));
  end component;


  signal s_En 		: std_logic;
  signal s_Jump_en	: std_logic_vector(1 downto 0);
  signal s_Branch_en	: std_logic;
  signal s_CLK		: std_logic;
  signal s_set_pc	: std_logic_vector(31 downto 0);
  signal s_imm		: std_logic_vector(31 downto 0);
  signal s_Instruction 	: std_logic_vector(31 downto 0);
  signal s_iRST 	: std_logic;
  signal s_ReadAddr  	: std_logic_vector(31 downto 0);

begin
Fetctlogic: Fetch
	port map( 
		En	 	=> s_En,
		Jump_en   	=> s_Jump_en,
		Branch_en	=> s_Branch_en,
		imm		=> s_imm,
		set_pc		=> s_set_pc,
		Instruction	=> s_Instruction,
		iCLK  		=> s_CLK,
		iRST 		=> s_iRST,
		ReadAddr	=> s_ReadAddr);

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
	s_iRST 		<= '1';
 wait for gCLK_HPER;
	s_iRST 		<= '0';

--test case1: addu v0, v0, v1 -- 0x400000
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00431021";
    wait for cCLK_PER;

-- test jal and jr
--test case: jal 0x004000018	-- 0x400004
	s_En 		<= '1';
	s_Jump_en	<= b"01";
	s_Branch_en	<= '0';
	s_set_pc	<= x"00400004";
	s_imm		<= x"00000001";
	s_Instruction	<= x"10100006";
    wait for cCLK_PER;
--test case: jr ra
	s_En 		<= '1';
	s_Jump_en	<= b"11";
	s_Branch_en	<= '0';
	s_set_pc	<= x"00400008"; -- should be the address get from  the register 31
	s_imm		<= x"00000001";
	s_Instruction	<= x"03E00008";
    wait for cCLK_PER;
----------------------------------------------------------------
--test the jump and PC + 4 is correct

--test case1: addu v0, v0, v1 -- 0x400000
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00431021";
    wait for cCLK_PER;
--test case2: lw v0, 0(v0)	-- 0x400004
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"8c420000";

    wait for cCLK_PER;
--test case3: addiu $v1, sp, 8 -- 0x400008
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"27a30008";
    wait for cCLK_PER;
--test case4: j 0x400018	-- 0x40000c
	s_En 		<= '1';
	s_Jump_en	<= b"01";
	s_Branch_en	<= '0';
	s_imm		<= x"00000001";
	s_Instruction	<= x"10100006";
    wait for cCLK_PER;
--test case5: addu $t0, $s1, $s2 -- 0x400010
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= b"00000010001100100100000000100001";
wait for cCLK_PER;
wait for cCLK_PER;
wait;
----------------------------------------------------------
--test the branch and PC + 4 is correct
--test case1: addu $t0, $s1, $s2 -- 0x400000
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= b"00000010001100100100000000100001";
    wait for cCLK_PER;
--test case2: beq $v0, zero, 0x40001c -- 0x400004
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '1';
	s_imm		<= x"00000005";
	s_Instruction	<= x"10400005";
    wait for cCLK_PER;
--test case3: addiu $v1, sp, 8 -- 0x400008
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"27a30008";
    wait for cCLK_PER;

--test case4: j 0x400020	-- 0x40000c
	s_En 		<= '1';
	s_Jump_en	<= b"01";
	s_Branch_en	<= '0';
	s_imm		<= x"00000001";
	s_Instruction	<= x"10000004";
    wait for cCLK_PER;
--test case5: sll $v0, a0, 2  -- 0x400010
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00041080";
    wait for cCLK_PER;

--test case6: addu v0, v0, v1 -- 0x400014
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00431021";
    wait for cCLK_PER;
--test case7: lw v0, 0(v0)	-- 0x400018
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"8c420000";

    wait for cCLK_PER;
--test case8: addu v0, zero, zero-- 0x40001c
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00001021";
    wait for cCLK_PER;

--test case9: addu v0, zero, v0	-- 0x400020
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"00001021";
    wait for cCLK_PER;

----------------------------------------------------
--test case10: lw v0, 0(v0)	-- 0x400024
	s_En 		<= '1';
	s_Jump_en	<= b"00";
	s_Branch_en	<= '0';
	s_imm		<= x"00000000";
	s_Instruction	<= x"8c420000";
    wait for cCLK_PER;
    wait;

--test case10: jr ra 			-- 0x400020
	s_En 		<= '1';
	s_Jump_en	<= b"11";
	s_Branch_en	<= '0';
	s_imm		<= x"00000008";
	s_Instruction	<= x"03e00008";	

   wait;
  end process;
  
end behavior;