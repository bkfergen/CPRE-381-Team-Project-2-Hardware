-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux32bit2t1 is

  port(i_0	: in std_logic_vector(31 downto 0);
     i_1	: in std_logic_vector(31 downto 0);
     i_S	: in std_logic;
     o_F	: out std_logic_vector(31 downto 0));

end mux32bit2t1;

architecture dataflow of mux32bit2t1 is
 
begin
with i_S select
o_F <= i_0 when '0',
       i_1 when '1',
       (others => '0') when others;

  
  
end dataflow;
