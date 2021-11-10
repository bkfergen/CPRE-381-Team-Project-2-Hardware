library IEEE;
use IEEE.std_logic_1164.all;

entity onescomp_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_D          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end onescomp_N;

architecture structural of onescomp_N is

  component invg is
    port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  G_NBit_ONESCOMP: for i in 0 to N-1 generate
    ONESCOMP_I: invg port map(
              i_A      => i_D(i),
              o_F      => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_ONESCOMP;
  
end structural;