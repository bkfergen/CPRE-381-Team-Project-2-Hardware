library IEEE;
use IEEE.std_logic_1164.all;

entity tb_forwardingunit is
  generic(gCLK_HPER   : time := 20 ns);
end tb_forwardingunit;

architecture behavior of tb_forwardingunit is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

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

  -- Temporary signals to connect to the dff component.
  signal s_CLK : std_logic;
  signal s_memwb_register_rd : std_logic_vector(4 downto 0);
  signal s_exmem_register_rd : std_logic_vector(4 downto 0);
  signal s_idex_register_rs : std_logic_vector(4 downto 0);
  signal s_idex_register_rt : std_logic_vector(4 downto 0);
  signal s_memwb_reg_write : std_logic;
  signal s_exmem_reg_write : std_logic;
  signal s_forward_a : std_logic_vector(1 downto 0);
  signal s_forward_b : std_logic_vector(1 downto 0);

begin

  DUT: forwardingunit
  port map(i_memwb_register_rd => s_memwb_register_rd,
           i_exmem_register_rd => s_exmem_register_rd,
           i_memwb_reg_write => s_memwb_reg_write,
           i_exmem_reg_write => s_exmem_reg_write,
           i_idex_register_rs => s_idex_register_rs,
           i_idex_register_rt => s_idex_register_rt,
           o_forward_a => s_forward_a,
           o_forward_b => s_forward_b);

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
    -- run 280

-- Test zero registers, forward_a = 0b00, forward_b = 0b00
    s_memwb_register_rd <= "00000";
    s_exmem_register_rd <= "00000";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '1';
    s_idex_register_rs <= "00000";
    s_idex_register_rt <= "00000";
    wait for cCLK_PER;

-- Test reg_write = zero, forward_a = 0b00, forward_b = 0b00
    s_memwb_register_rd <= "00001";
    s_exmem_register_rd <= "00001";
    s_memwb_reg_write <= '0';
    s_exmem_reg_write <= '0';
    s_idex_register_rs <= "00001";
    s_idex_register_rt <= "00001";
    wait for cCLK_PER;

-- Test choose ex over mem, forward_a = 0b10, forward_b = 0b10
    s_memwb_register_rd <= "00001";
    s_exmem_register_rd <= "00001";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '1';
    s_idex_register_rs <= "00001";
    s_idex_register_rt <= "00001";
    wait for cCLK_PER;

-- Test choose mem for b only, forward_a = 0b00, forward_b = 0b01
    s_memwb_register_rd <= "00011";
    s_exmem_register_rd <= "00100";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '1';
    s_idex_register_rs <= "00001";
    s_idex_register_rt <= "00011";
    wait for cCLK_PER;

-- Test, forward_a = 0b01, forward_b = 0b10
    s_memwb_register_rd <= "00010";
    s_exmem_register_rd <= "00110";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '1';
    s_idex_register_rs <= "00010";
    s_idex_register_rt <= "00110";
    wait for cCLK_PER;

-- Test, forward_a = 0b01, forward_b = 0b00
    s_memwb_register_rd <= "00010";
    s_exmem_register_rd <= "01010";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '0';
    s_idex_register_rs <= "00010";
    s_idex_register_rt <= "01010";
    wait for cCLK_PER;

-- Test, forward_a = 0b10, forward_b = 0b00
    s_memwb_register_rd <= "00010";
    s_exmem_register_rd <= "00010";
    s_memwb_reg_write <= '1';
    s_exmem_reg_write <= '1';
    s_idex_register_rs <= "00010";
    s_idex_register_rt <= "11010";
    wait for cCLK_PER;

    wait;
  end process;
  
end behavior;