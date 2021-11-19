library IEEE;
use IEEE.std_logic_1164.all;

entity HazardAvoidanceUnit is

  port(i_IfIdInstruction : in std_logic_vector(31 downto 0);
       i_IdExInstruction : in std_logic_vector(31 downto 0);
       i_MemToReg : in std_logic;
       o_IfIdFlush : out std_logic;
       o_PCWrite : out std_logic);

end HazardAvoidanceUnit;

architecture structural of HazardAvoidanceUnit is



begin

  
  
end structural;