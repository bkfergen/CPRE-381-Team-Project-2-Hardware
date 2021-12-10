library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mips_alu is
  generic(gCLK_HPER   : time := 20 ns);
end tb_mips_alu;

architecture behavior of tb_mips_alu is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

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

  -- Temporary signals to connect to the dff component.
  signal s_CLK : std_logic;
  signal s_Data1 : std_logic_vector(31 downto 0);
  signal s_Data2 : std_logic_vector(31 downto 0);
  signal s_Output : std_logic_vector(31 downto 0);
  signal s_C : std_logic_vector(14 downto 1);
  signal s_Overflow : std_logic;
  signal s_Zero : std_logic;
  signal s_Halt : std_logic;

begin

  DUT: mips_alu
  generic map(N => 32)
  port map(i_Data1 => s_Data1,          -- Data input 1
           i_Data2 => s_Data2,          -- Data input 2
           i_C => s_C,                  -- Control
           o_Overflow => s_Overflow,    -- Overflow (1 = ovf, 0 = no ovf)
           o_Halt => s_Halt,            -- Halt (1 = halt, 0 = no halt)
           o_Output => s_Output,        -- Data output
           o_Zero => s_Zero);           -- Zero (1 = branch, 0 = no branch)

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
    -- run 760
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000000000000000000";
    s_C <= "00000000000000";
    wait for cCLK_PER;

-- Test add (s_Output should be "...0010")
    s_Data1 <= "00000000000000000000000000000001";
    s_Data2 <= "00000000000000000000000000000001";
    s_C <= "00000000000001";
    wait for cCLK_PER;

-- Test sub (s_Output should be "...0000")
    s_Data1 <= "00000000000000000000000000000001";
    s_Data2 <= "00000000000000000000000000000001";
    s_C <= "00000000000011";
    wait for cCLK_PER;

-- Test or (s_Output should be "...1011")
    s_Data1 <= "00000000000000000000000000001001";
    s_Data2 <= "00000000000000000000000000000011";
    s_C <= "00000000000100";
    wait for cCLK_PER;

-- Test and (s_Output should be "...0001")
    s_Data1 <= "00000000000000000000000000001001";
    s_Data2 <= "00000000000000000000000000000011";
    s_C <= "00000000001000";
    wait for cCLK_PER;

-- Test nor (s_Output should be "1111...0100")
    s_Data1 <= "00000000000000000000000000001001";
    s_Data2 <= "00000000000000000000000000000011";
    s_C <= "00000000010000";
    wait for cCLK_PER;

-- Test xor (s_Output should be "...1010")
    s_Data1 <= "00000000000000000000000000001001";
    s_Data2 <= "00000000000000000000000000000011";
    s_C <= "00000000100000";
    wait for cCLK_PER;

-- Test repl.qb (s_Output should be "||10100011|| x 4")
    s_Data1 <= "00000000000000000000000000000000"; --Only uses imm (read into data 2)
    s_Data2 <= "00000000000000000000000010100011";
    s_C <= "00000001000000";
    wait for cCLK_PER;

-- Test ne (s_Zero should be "1")
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000000000010100011";
    s_C <= "00000000000000";
    wait for cCLK_PER;

-- Test equal (s_Zero should be "0")
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000000000010100011";
    s_C <= "00000010000000";
    wait for cCLK_PER;

-- Test equal (s_Zero should be "1")
    s_Data1 <= "00000000000000000000000000001111";
    s_Data2 <= "00000000000000000000000000001111";
    s_C <= "00000010000000";
    wait for cCLK_PER;

-- Test equal (s_Zero should be "0")
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000011001100110011";
    s_C <= "00000010000000";
    wait for cCLK_PER;

-- Test slt (s_Output should be "...0001")
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000000000010100011";
    s_C <= "00000100000000";
    wait for cCLK_PER;

-- Test slt (s_Output should be "...0000")
    s_Data1 <= "00000000000000000000000010100011";
    s_Data2 <= "00000000000000000000000000000000";
    s_C <= "00000100000000";
    wait for cCLK_PER;

-- Test slt (s_Output should be "...0000")
    s_Data1 <= "00000000000000000000000010100011";
    s_Data2 <= "00000000000000000000000010100011";
    s_C <= "00000100000000";
    wait for cCLK_PER;

-- Test sll (s_Output should be "...1100")
    s_Data1 <= "00000000000000000000000000000011";
    s_Data2 <= "00000000000000000000000010000000";
    s_C <= "00111000000000";
    wait for cCLK_PER;

-- Test srl (s_Output should be "0011...0001")
    s_Data1 <= "11000000000000000000000000000101";
    s_Data2 <= "00000000000000000000000010000000";
    s_C <= "00011000000000";
    wait for cCLK_PER;

-- Test sra (s_Output should be "1111...0001")
    s_Data1 <= "11000000000000000000000000000101";
    s_Data2 <= "00000000000000000000000010000000";
    s_C <= "00001000000000";
    wait for cCLK_PER;

-- Test halt (s_Halt should be '1')
    s_Data1 <= "00000000000000000000000000000000";
    s_Data2 <= "00000000000000000000000000000000";
    s_C <= "01000000000000";
    wait for cCLK_PER;

-- Test pass Data2 (s_Output should be "...1000")
    s_Data1 <= "00000000000000000000000000000001";
    s_Data2 <= "00000000000000000000000000001000";
    s_C <= "10000000000000";
    wait for cCLK_PER;

    wait;
  end process;
  
end behavior;