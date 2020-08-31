library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg8bits is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (7 downto 0);
           Q : out  STD_LOGIC_VECTOR (7 downto 0));
end reg8bits;

architecture Behavioral of reg8bits is

begin

	process(clk,rst)
	begin
		if (rst = '1') then
			Q <= (others => '0');
		elsif (rising_edge(clk)) then
			if (en = '1') then
				Q <= D;
			end if;
		end if;
	end process;

end Behavioral;

