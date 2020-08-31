library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( X : in  STD_LOGIC_VECTOR(7 downto 0);
           Y : in  STD_LOGIC_VECTOR(7 downto 0);
           selALU : in  STD_LOGIC_VECTOR(2 downto 0);
           Nflag : out  STD_LOGIC;
           Zflag : out  STD_LOGIC;
           result : out  STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is

signal tmpResult : std_logic_vector(7 downto 0);

begin

	operations:	process(selALU,X,Y)
	begin
		-- Pre-assignments to prevent latches
		tmpResult <= (others => '0');
		--
		case selALU is
			-- ADD
			when "000" =>
				tmpResult <= std_logic_vector(signed(X) + signed(Y));
			-- AND 
			when "001" =>
				tmpResult <= X and Y;
			-- OR
			when "010" =>
				tmpResult <= X or Y;
			-- NOT
			when "011" =>
				tmpResult <= not(X);
			-- Y
			when "100" =>
				tmpResult <= Y;
			when "101" =>
				tmpResult <= std_logic_vector(signed(X) - signed(Y));
			when "110" =>
				tmpResult <= std_logic_vector(signed(X(3 downto 0)) * signed(Y(3 downto 0)));
			-- catch-all
			when others =>
				tmpResult <= "00001111";
		end case;
	end process operations;
	
	set_status_flags: process(selALU,X,Y,tmpResult)
	begin
		-- Pre-assignments to prevent latches
		Zflag <= '0';
		Nflag <= '0';
		--
		if (tmpResult = "00000000") then
			Zflag <= '1';
			Nflag <= '0';
		elsif (signed(tmpResult) < 0) then
			Zflag <= '0';
			Nflag <= '1';
		else
			Zflag <= '0';
			Nflag <= '0';
		end if;
	end process set_status_flags;

	result <= tmpResult;
	
end Behavioral;

