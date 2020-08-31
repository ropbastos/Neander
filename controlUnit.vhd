library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controlUnit is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           Nflag : in  STD_LOGIC;
           Zflag : in  STD_LOGIC;
           opCode : in  STD_LOGIC_VECTOR (3 downto 0);
           loadPC : out  STD_LOGIC;
           incPC : out  STD_LOGIC;
           remMuxSel : out  STD_LOGIC;
           remLoad : out  STD_LOGIC;
           readCtrl : out  STD_LOGIC;
           writeCtrl : out  STD_LOGIC_VECTOR(0 downto 0);
           rdmLoad : out  STD_LOGIC;
           accLoad : out  STD_LOGIC;
           selALU : out  STD_LOGIC_VECTOR(2 downto 0);
           nzLoad : out  STD_LOGIC;
           riLoad : out  STD_LOGIC);
end controlUnit;

architecture Behavioral of controlUnit is

type state_type is (t0,t1,memWait,t2,t3,t4,memWait1,t5,t6,t7,memWait2,hltState);
signal presentState, nextState : state_type;

-- Mneumonics for the different opcodes
constant NOP  : std_logic_vector := "0000";
constant STA  : std_logic_vector := "0001";
constant LDA  : std_logic_vector:= "0010";
constant ADD  : std_logic_vector := "0011";
constant SUB : std_logic_vector := "1011";
constant MUL : std_logic_vector := "0111";
constant opOR   : std_logic_vector := "0100";
constant opAND  : std_logic_vector := "0101";
constant opNOT  : std_logic_vector := "0110";
constant JMP  : std_logic_vector := "1000";
constant JN   : std_logic_vector := "1001";
constant JZ   : std_logic_vector := "1010";
constant HLT  : std_logic_vector := "1111";

begin

-- FSM
    sync_process: process(clk,rst)
    begin
        if (rst = '1') then
            presentState <= t0;
        elsif (rising_edge(clk)) then
            presentState <= nextState;
        end if;
    end process sync_process;
            
    comb_process: process(presentState,opCode,Nflag,Zflag)
    begin
        -- Pre-assignments to prevent latches
        loadPC <= '0';
        incPC <= '0';
        remMuxSel <= '0';
        remLoad <= '0';
        readCtrl <= '0';
        writeCtrl <= (others => '0');
        rdmLoad <= '0';
        accLoad <= '0';
        selALU <= (others => '0');
        nzLoad <= '0';
        riLoad <= '0';
        --
        case presentState is
            when t0 =>
                remMuxSel <= '0';
                remLoad <= '1';
                nextState <= t1;
            when t1 =>
                readCtrl <= '1';
                rdmLoad <= '1';
                incPC <= '1';
                nextState <= memWait;
            when memWait =>
                readCtrl <= '1';
                rdmLoad <= '1';
                incPC <= '0';
                nextState <= t2;
            when t2 =>
                riLoad <= '1';
                nextState <= t3;
            when t3 =>
                if (opCode = STA or opCode = LDA or opCode = ADD or opCode = SUB
                    or opCode = opOR or opCode = opAND or opCode = JMP or opCode = MUL)
                then
                    remMuxSel <= '0';
                    remLoad <= '1';
                    nextState <= t4;
                elsif (opCode = opNOT) then
                    selALU <= "011";
                    accLoad <= '1';
                    nzLoad <= '1';
                    nextState <= t0;
                elsif (opCode = JN) then
                    if (Nflag = '1') then
                        remMuxSel <= '0';
                        remLoad <= '1';
                        nextState <= t4;
                    elsif (Nflag = '0') then
                        incPC <= '1';
                        nextState <= t0;
                    end if;
                elsif (opCode = JZ) then
                    if (Zflag = '1') then
                        remMuxSel <= '0';
                        remLoad <= '1';
                        nextState <= t4;
                    elsif (Zflag = '0') then
                        incPC <= '1';
                        nextState <= t0;
                    end if;
                elsif (opCode = NOP) then
                    nextState <= t0;
                elsif (opCode = HLT) then
                    nextState <= hltState;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when t4 =>
                if (opCode = STA or opCode = LDA or opCode = ADD or opCode = SUB 
                     or opCode = opOR or opCode = opAND or opCode = MUL)
                then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    incPC <= '1';
                    nextState <= memWait1;
                elsif (opCode = opNOT) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = JMP) then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    nextState <= memWait1;
                elsif (opCode = JN) then
                    if (Nflag = '1') then
                        readCtrl <= '1';
                        rdmLoad <= '1';
                        nextState <= memWait1;
                    elsif (Nflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = JZ) then
                    if (Zflag = '1') then
                        readCtrl <= '1';
                        rdmLoad <= '1';
                        nextState <= memWait1;
                    elsif (Zflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = NOP) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = HLT) then
                    nextState <= hltState;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when memWait1 =>
                if (opCode = STA or opCode = LDA or opCode = ADD or opCode = MUL 
                     or opCode = opOR or opCode = opAND or opCode = SUB)
                then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    incPC <= '0';
                    nextState <= t5;
                elsif (opCode = opNOT) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = JMP) then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    nextState <= t5;
                elsif (opCode = JN) then
                    if (Nflag = '1') then
                        readCtrl <= '1';
                        rdmLoad <= '1';
                        nextState <= t5;
                    elsif (Nflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = JZ) then
                    if (Zflag = '1') then
                        readCtrl <= '1';
                        rdmLoad <= '1';
                        nextState <= t5;
                    elsif (Zflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = NOP) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = HLT) then
                    nextState <= hltState;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when t5 =>
                if (opCode = STA or opCode = LDA or opCode = ADD or opCode = MUL
                     or opCode = opOR or opCode = opAND or opCode = SUB)
                then
                    remMuxSel <= '1';
                    remLoad <= '1';
                    nextState <= t6;
                elsif (opCode = opNOT) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = JMP) then
                    loadPC <= '1';
                    nextState <= t0;
                elsif (opCode = JN) then
                    if (Nflag = '1') then
                        loadPC <= '1';
                        nextState <= t0;
                    elsif (Nflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = JZ) then
                    if (Zflag = '1') then
                        loadPC <= '1';
                        nextState <= t0;
                    elsif (Zflag = '0') then
                        -- Shouldn't be reached
                        nextState <= hltState;
                    end if;
                elsif (opCode = NOP) then
                    -- Shouldn't be reached
                    nextState <= hltState;
                elsif (opCode = HLT) then
                    nextState <= hltState;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when t6 =>
                if (opCode = LDA or opCode = ADD or opCode = opOR 
                     or opCode = opAND or opCode = SUB or opCode = MUL)
                then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    nextState <= memWait2;
                elsif (opCode = STA) then
                    rdmLoad <= '1';
                    nextState <= t7;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when memWait2 =>
                if (opCode = LDA or opCode = ADD or opCode = opOR 
                     or opCode = opAND or opCode = SUB or opCode = MUL)
                then
                    readCtrl <= '1';
                    rdmLoad <= '1';
                    nextState <= t7;
                elsif (opCode = STA) then
                    rdmLoad <= '1';
                    nextState <= t7;
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when t7 =>
                if (opCode = STA) then
                    writeCtrl <= (others => '1');
                    nextState <= t0;
                elsif (opCode = LDA) then
                    selALU <= "100";
                    accLoad <= '1';
                    nzLoad <= '1';
                    nextState <= t0;
                elsif (opCode = ADD) then 
                    selALU <= "000";
                    accLoad <= '1';
                    nzLoad <= '1';
                    nextState <= t0;
					 elsif (opCode = SUB) then
						  selALU <= "101";
						  accLoad <= '1';
						  nzLoad <= '1';
						  nextState <= t0;
					 elsif (opCode = MUL) then
						  selALU <= "110";
						  accLoad <= '1';
						  nzLoad <= '1';
						  nextState <= t0;
                elsif (opCode = opOR) then
                    selALU <= "010";
                    accLoad <= '1';
                    nzLoad <= '1';
                    nextState <= t0;
                elsif (opCode = opAND) then
                    selALU <= "001";
                    accLoad <= '1';
                    nzLoad <= '1';
                    nextState <= t0;                    
                else
                    -- Should only reach in case or errors
                    -- If so, aborts
                    nextState <= hltState;
                end if;
            when hltState =>
                incPC <= '0';
                nextState <= hltState;
            when others =>
                nextState <= t0;
        end case;
    end process comb_process;
        

end Behavioral;



