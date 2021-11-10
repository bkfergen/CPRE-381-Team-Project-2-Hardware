library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity mips_alu is

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

end mips_alu;

architecture structural of mips_alu is

  component addsub_N is
    generic(N         : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_C          : in std_logic;
         i_I1         : in std_logic_vector(N-1 downto 0);
         i_I2         : in std_logic_vector(N-1 downto 0);
         o_S          : out std_logic_vector(N-1 downto 0);
         o_C          : out std_logic);
  end component;

  component or_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));
  end component;

  component and_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component onescomp_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_D          : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component xor_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));
  end component;

  component replqb_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));
  end component;

  component notequal_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic);
  end component;

  component invg is
    port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;

  component mux2t1 is
    port(i_S          : in std_logic;
         i_D0         : in std_logic;
         i_D1         : in std_logic;
         o_O          : out std_logic);
  end component;

  component slt_N is
    generic(N         : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0)); -- 0 = a not less than b, 1 = a less than b
  end component;

  component BarrelShifter is
    generic(N        : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_in        : in std_logic_vector(31 downto 0);
         i_logical   : in std_logic;
         i_Sleft     : in std_logic;
         i_Shamount  : in std_logic_vector(4 downto 0);
         o_out       : out std_logic_vector(31 downto 0));
  end component;

  -- ALU Operation Outputs
  signal s_Output1 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output2 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output3 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output4 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output5 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output6 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output7 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output8 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_Output9 : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Adder_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Or_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_And_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Nor_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Xor_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Replqb_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_Slt_Output : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_ALU_BarrelShifter_Output : std_logic_vector(N-1 downto 0) := (others => '0');

  -- ALU Zero Results
  signal s_Zero1 : std_logic;
  signal s_ALU_Bne_Zero : std_logic;
  signal s_ALU_Beq_Zero : std_logic;

begin

  -- OPERATIONS
  ALU_Adder: addsub_N
  generic map(N => N)
  port map(i_C => i_C(2),
           i_I1 => i_Data1,
           i_I2 => i_Data2,
           o_S => s_ALU_Adder_Output,
           o_C => o_Overflow);

  ALU_Or: or_N
  port map(i_A => i_Data1,
           i_B => i_Data2,
           o_F => s_ALU_Or_Output);

  ALU_And: and_N
  port map(i_A => i_Data1,
           i_B => i_Data2,
           o_F => s_ALU_And_Output);

  ALU_Nor: onescomp_N
  generic map(N => N)
  port map(i_D => s_ALU_Or_Output,
           o_O => s_ALU_Nor_Output);

  ALU_Xor: xor_N
  port map(i_A => i_Data1,
           i_B => i_Data2,
           o_F => s_ALU_Xor_Output);

  ALU_Replqb: replqb_N
  generic map(N => N)
  port map(i_A => i_Data2,
           o_F => s_ALU_Replqb_Output);

  ALU_Slt: slt_N
  port map(i_A => i_Data1,
           i_B => i_Data2,
           o_F => s_ALU_Slt_Output);

  ALU_BarrelShifter: BarrelShifter
    generic map(N => N)
    port map(i_in => i_Data1,
         i_logical => i_C(11),
         i_Sleft => i_C(12),
         i_Shamount => i_Data2(10 downto 6), -- bits 10-6 of what would otherwise be immediate
         o_out => s_ALU_BarrelShifter_Output);

  -- DETERMINE OUTPUT
  ALU_Adder_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(1),
           i_D0 => i_Data1,
           i_D1 => s_ALU_Adder_Output,
           o_O => s_Output1);

  ALU_Or_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(3),
           i_D0 => s_Output1,
           i_D1 => s_ALU_Or_Output,
           o_O => s_Output2);

  ALU_And_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(4),
           i_D0 => s_Output2,
           i_D1 => s_ALU_And_Output,
           o_O => s_Output3);

  ALU_Nor_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(5),
           i_D0 => s_Output3,
           i_D1 => s_ALU_Nor_Output,
           o_O => s_Output4);

  ALU_Xor_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(6),
           i_D0 => s_Output4,
           i_D1 => s_ALU_Xor_Output,
           o_O => s_Output5);

  ALU_Replqb_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(7),
           i_D0 => s_Output5,
           i_D1 => s_ALU_Replqb_Output,
           o_O => s_Output6);

  ALU_Slt_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(9),
           i_D0 => s_Output6,
           i_D1 => s_ALU_Slt_Output,
           o_O => s_Output7);

  ALU_BarrelShifter_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(10),
           i_D0 => s_Output7,
           i_D1 => s_ALU_BarrelShifter_Output,
           o_O => s_Output8);

  ALU_Data2_Output_Mux: mux2t1_N
  generic map(N => N)
  port map(i_S => i_C(14),
           i_D0 => s_Output8,
           i_D1 => i_Data2,
           o_O => s_Output9);

  o_Output <= s_Output9;

  -------------------------------------------

  -- ZERO
  ALU_Notequal: notequal_N
  port map(i_A => i_Data1,
           i_B => i_Data2,
           o_F => s_ALU_Bne_Zero);

  ALU_Equal: invg
  port map(i_A => s_ALU_Bne_Zero,
           o_F => s_ALU_Beq_Zero);

  -- DETERMINE ZERO
  ALU_Equal_Zero_Mux: mux2t1
  port map(i_S => i_C(8),
           i_D0 => s_ALU_Bne_Zero,
           i_D1 => s_ALU_Beq_Zero,
           o_O => s_Zero1);

  o_Zero <= s_Zero1;

  -------------------------------------------

  o_Halt <= i_C(13);

end structural;