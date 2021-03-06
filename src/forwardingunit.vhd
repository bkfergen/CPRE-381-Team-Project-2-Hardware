library IEEE;
use IEEE.std_logic_1164.all;

entity forwardingunit is
  port(i_memwb_register_rd : in std_logic_vector(4 downto 0);
       i_exmem_register_rd : in std_logic_vector(4 downto 0);
       i_memwb_reg_write : in std_logic;
       i_exmem_reg_write : in std_logic;
       i_idex_register_rs : in std_logic_vector(4 downto 0);
       i_idex_register_rt : in std_logic_vector(4 downto 0);
       o_forward_a : out std_logic_vector(1 downto 0);
       o_forward_b : out std_logic_vector(1 downto 0));

end forwardingunit;

architecture dataflow of forwardingunit is
begin

  o_forward_a <= "10" when (i_exmem_reg_write = '1') and (i_exmem_register_rd = i_idex_register_rs) and (i_exmem_register_rd /= "00000") else
                 "01" when (i_memwb_reg_write = '1') and (i_memwb_register_rd = i_idex_register_rs) and (i_memwb_register_rd /= "00000") else
                 "00";

  o_forward_b <= "10" when (i_exmem_reg_write = '1') and (i_exmem_register_rd = i_idex_register_rt) and (i_exmem_register_rd /= "00000") else
                 "01" when (i_memwb_reg_write = '1') and (i_memwb_register_rd = i_idex_register_rt) and (i_memwb_register_rd /= "00000") else
                 "00";
  
end dataflow;