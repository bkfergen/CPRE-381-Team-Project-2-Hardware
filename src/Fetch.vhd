library IEEE;
use IEEE.std_logic_1164.all;

entity Fetch is 
	generic(N: integer:= 32);
	port(En		     : in std_logic;
	     Jump_en         : in std_logic_vector(1 downto 0);
	     Branch_en       : in std_logic;
	     imm 	     : in std_logic_vector(N-1 downto 0);
             set_pc          : in std_logic_vector(N-1 downto 0);
	     Instruction     : in std_logic_vector(N-1 downto 0);
	     iCLK            : in std_logic;
       	     iRST            : in std_logic;
	     ReadAddr        : out std_logic_vector(N-1 downto 0));
end Fetch;

	
architecture structural of Fetch is

  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component addsub_N is 
  	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
 	 port(i_C          : in std_logic;
     	      i_I1         : in std_logic_vector(N-1 downto 0);
      	      i_I2         : in std_logic_vector(N-1 downto 0);
      	      o_S          : out std_logic_vector(N-1 downto 0);
      	      o_C          : out std_logic);
  end component;

  component PC is 
   generic(N: integer := 32);
   port(i_CLK        : in std_logic;  
        i_RST        : in std_logic;
        i_WE         : in std_logic;    
        i_D          : in std_logic_vector(N-1 downto 0);   
        o_Q          : out std_logic_vector(N-1 downto 0));   
   end component;

signal s_PC : std_logic_vector(31 downto 0); -- initial PC is 0x00400000
signal s_addOut: std_logic_vector(31 downto 0);
signal s_addCarryOut: std_logic;
signal s_jump_temp : std_logic_vector(25 downto 0);
signal s_jumpAddr: std_logic_vector(31 downto 0);
signal s_branch_temp : std_logic_vector(31 downto 0);
signal s_brranchAddr: std_logic_vector(31 downto 0);
signal s_addOut_Branch: std_logic_vector(31 downto 0);
signal s_addCarryOut_Branch: std_logic;
signal s_Outmux_Branch: std_logic_vector(31 downto 0);
signal s_Outmux_Jump: std_logic_vector(31 downto 0);
signal s_Outmux_JumpReturn : std_logic_vector(31 downto 0);

begin 


  PC_register : PC
    generic map(N => 32)
    port map(i_CLK => iCLK,
	     i_RST => iRST,
	     i_WE => En,
	     i_D => s_Outmux_JumpReturn,
	     o_Q => s_PC);

    PC_add4 : addsub_N
    generic map(N => 32)
    port map(
		i_C	=>'0',
		i_I1	=> s_PC,
		i_I2 	=> x"00000004",
		o_S  	=> s_addOut,
		o_C 	=> s_addCarryOut);

 s_branch_temp <= imm;
 s_brranchAddr <= imm(29 downto 0) & '0' & '0';

    addPC_BranchAddr : addsub_N
    generic map(N => 32)
    port map(
		i_C	=>'0',
		i_I1	=> s_addOut,
		i_I2 	=> s_brranchAddr,
		o_S  	=> s_addOut_Branch,
		o_C 	=> s_addCarryOut_Branch);

    mux_Branch : mux2t1_N 
    port map(
		i_S 	=> Branch_en,
		i_D0	=> s_addOut,
		i_D1	=> s_addOut_Branch,
		o_O 	=> s_Outmux_Branch);

 s_jump_temp(25 downto 0) <= Instruction(25 downto 0);
 s_jumpAddr (31 downto 0) <= s_addOut(31 downto 28) & Instruction(25 downto 0) & '0' & '0';

    mux_Jump : mux2t1_N 
    port map(
		i_S 	=> Jump_en(0),
		i_D0	=> s_Outmux_Branch,
		i_D1	=> s_jumpAddr,
		o_O 	=> s_Outmux_Jump);

    mux_JumpReturn : mux2t1_N 
    port map(
		i_S 	=> Jump_en(1),
		i_D0	=> s_Outmux_Jump,
		i_D1	=> set_pc,
		o_O 	=> s_Outmux_JumpReturn);

ReadAddr <= s_PC;

end structural;

	
