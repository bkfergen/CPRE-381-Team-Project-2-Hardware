library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity mipsdecoder is

  port(i_A          : in std_logic_vector(4 downto 0);
       o_F          : out std_logic_vector(31 downto 0));

end mipsdecoder;

architecture dataflow of mipsdecoder is
begin

  o_F <= (to_integer(unsigned(i_A)) => '1',
          others                    => '0');
  
end dataflow;