library IEEE;
use IEEE.std_logic_1164.all;



entity hazardDetectUnit is
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
	  
end hazardDetectUnit;

architecture mixed of hazardDetectUnit is
  signal s_IF_ID_Opcode		: std_logic_vector(5 downto 0);    -- Opcode for IF_ID.Instruction
  signal s_IF_ID_Fuct		: std_logic_vector(5 downto 0);    -- Function code for IF_ID.Instruction
  signal s_ID_EX_Opcode		: std_logic_vector(5 downto 0);    -- Opcode for ID_EX.Instruction
  signal s_ID_EX_Fuct		: std_logic_vector(5 downto 0);    -- Function code for ID_EX.Instruction
  signal s_IF_ID_Rt 		: std_logic_vector(4 downto 0);
  signal s_IF_ID_Rs 		: std_logic_vector(4 downto 0); 
  signal s_ID_EX_Rt 		: std_logic_vector(4 downto 0); 
  signal s_ID_EX_Rs 		: std_logic_vector(4 downto 0); 
  signal s_EX_MEM_Rt 		: std_logic_vector(4 downto 0); 
  signal s_EX_MEM_Rs 		: std_logic_vector(4 downto 0); 
  signal s_EX_MEM_Opcode	: std_logic_vector(5 downto 0);

  signal s_MEM_WB_Rt 		: std_logic_vector(4 downto 0); 
  signal s_MEM_WB_Rs 		: std_logic_vector(4 downto 0); 
  signal s_MEM_WB_Opcode	: std_logic_vector(5 downto 0);

begin

--control hazard 
  s_IF_ID_Opcode  <= IF_ID_Instruction(31 downto 26);
  s_IF_ID_Fuct	  <= IF_ID_Instruction(5 downto 0);

  s_ID_EX_Opcode  <= ID_EX_Instruction(31 downto 26);
  s_ID_EX_Fuct	  <= ID_EX_Instruction(5 downto 0);

--data hazard
--lw 
--if the next instruction is R format, need to check whether its rs or rt using the rt of lw instruction 
--if the next instruction is I format, need to check whether its rs using the rt of lw instruction 
  s_IF_ID_Rt 	  <= IF_ID_Instruction(20 downto 16);
  s_IF_ID_Rs	  <= IF_ID_Instruction(25 downto 21);

  s_ID_EX_Rt	  <= ID_EX_Instruction(20 downto 16);
  s_ID_EX_Rs	  <= ID_EX_Instruction(25 downto 21);

--lw instruction at IF/ID, next instruction at EX/MEM
--second flush 
  s_EX_MEM_Opcode <= EX_MEM_Instruction(31 downto 26);
  s_EX_MEM_Rt	  <= EX_MEM_Instruction(20 downto 16);
  s_EX_MEM_Rs	  <= EX_MEM_Instruction(25 downto 21);

--lw instruction at IF/ID, next instruction at MEM/WB 
--third flush 
  s_MEM_WB_Opcode <= MEM_WB_Instruction(31 downto 26);
  s_MEM_WB_Rt	  <= MEM_WB_Instruction(20 downto 16);
  s_MEM_WB_Rs	  <= MEM_WB_Instruction(25 downto 21);

process(s_IF_ID_Opcode, s_IF_ID_Fuct, s_ID_EX_Opcode, s_ID_EX_Fuct, 
	s_IF_ID_Rt, s_IF_ID_Rs, s_ID_EX_Rt, s_ID_EX_Rs,
	s_EX_MEM_Opcode , EX_MEM_MemRead, s_EX_MEM_Rt, EX_MEM_jump, EX_MEM_branch,
	s_MEM_WB_Opcode , MEM_WB_MemRead, s_MEM_WB_Rt, MEM_WB_jump, MEM_WB_branch)

  begin
  IF_ID_Flush	<= 	'0';
  PC_WrEn 	<=	'1';
  CtrlMux		<= 	'1';
  if s_IF_ID_Opcode = "000000" and s_IF_ID_Fuct = "001000" then  -- R-format, jr instruction
  	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'0';
	CtrlMux		<= 	'1';
  elsif s_IF_ID_Opcode = "000100" then  --beq
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'0';
	CtrlMux		<= 	'1';

  elsif s_IF_ID_Opcode = "000101" then  --bne
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'0';
	CtrlMux		<= 	'1';

  elsif s_IF_ID_Opcode = "000010" then  --jump 
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'0';
	CtrlMux		<= 	'1';

  elsif s_IF_ID_Opcode = "000011" then  --jump and link 
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'0';
	CtrlMux		<= 	'1';
-- ID/EX stage
  elsif s_ID_EX_Opcode = "000000" and s_ID_EX_Fuct = "001000" and ID_EX_jump ='1' then  -- R-format, jr instruction
  	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';
  elsif s_ID_EX_Opcode = "000100" then  --beq
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';

  elsif s_ID_EX_Opcode = "000101" then  --bne
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';

  elsif s_ID_EX_Opcode = "000010" then  --jump 
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';

  elsif s_ID_EX_Opcode = "000011" then  --jump and link 
	IF_ID_Flush	<= 	'1';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';
-- data hazard
  elsif s_ID_EX_Opcode = "100011" and ID_EX_MemRead = '1' then 
	if s_IF_ID_Opcode = "000000" then  	--if the next instruction is R format, need to check whether its rs or rt using the rt of lw instruction 
		if s_IF_ID_Rt = s_ID_EX_Rt or s_ID_EX_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'0';
			CtrlMux		<= 	'1';
		end if;
	elsif ID_EX_jump = '0' and ID_EX_branch = '0' then 	--if the next instruction is I format, need to check whether its rs using the rt of lw instruction 
		if s_ID_EX_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'0';
			CtrlMux		<= 	'1';
		end if;
	end if;
--second flush data hazard 
  elsif s_EX_MEM_Opcode = "100011" and EX_MEM_MemRead = '1' then 
	if s_IF_ID_Opcode = "000000" then  	--if the next instruction is R format, need to check whether its rs or rt using the rt of lw instruction 
		if s_IF_ID_Rt = s_EX_MEM_Rt or s_EX_MEM_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'0';
			CtrlMux		<= 	'0';
		end if;
	elsif EX_MEM_jump = '0' and EX_MEM_branch = '0' then 	--if the next instruction is I format, need to check whether its rs using the rt of lw instruction 
		if s_EX_MEM_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'0';
			CtrlMux		<= 	'0';
		end if;
	end if;
--third flush
  elsif s_MEM_WB_Opcode = "100011" and MEM_WB_MemRead = '1' then 
	if s_IF_ID_Opcode = "000000" then  	--if the next instruction is R format, need to check whether its rs or rt using the rt of lw instruction 
		if s_IF_ID_Rt = s_MEM_WB_Rt or s_MEM_WB_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'1';
			CtrlMux		<= 	'1';
		end if;
	elsif MEM_WB_jump = '0' and MEM_WB_branch = '0' then 	--if the next instruction is I format, need to check whether its rs using the rt of lw instruction 
		if s_MEM_WB_Rt = s_IF_ID_Rs then
			IF_ID_Flush	<= 	'1';
			PC_WrEn 	<=	'1';
			CtrlMux		<= 	'1';
		end if;
	end if;
  else 
	IF_ID_Flush	<= 	'0';
	PC_WrEn 	<=	'1';
	CtrlMux		<= 	'1';

  end if;
end process;

end mixed;
        
