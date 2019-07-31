----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/26 21:46:45
-- Design Name: 
-- Module Name: game_state_ctrl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_state_ctrl is
    Port ( clk: in std_logic;
           rst_n: in std_logic;
           ps2_key : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           death_sig: in std_logic_vector(1 downto 0);
           game_state: out std_logic_vector(1 downto 0);
           game_reset : out std_logic
     );
end game_state_ctrl;

architecture Behavioral of game_state_ctrl is
    signal state: std_logic_vector(1 downto 0);
    signal reset1: std_logic;
    signal reset2: std_logic;
begin
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= "00";
            reset1 <= '0';
            reset2 <= '0';
        elsif clk'event and clk = '1' then
            case state is
                when "00" =>
                    if reset1 = '1' then
                        reset2 <= not reset2;
                    end if;
                    
                    if reset2 = '1' then
                        reset1 <= '0';
                    else
                        reset1 <= '1';
                    end if;
                    
                    if ps2_key = X"5A" then 
                        state <= "01"; 
                    elsif ps2_key = X"08" then
                        reset1 <= '1';
                        state <= "00";
                    else
                        state <= state;
                    end if;
                    
                when "01" => 
                    if reset1 = '1' then
                        reset2 <= not reset2;
                    end if;
                    
                    if reset2 = '1' then
                        reset1 <= '0';
                    else
                        reset1 <= '1';
                    end if;
                    
                    if ps2_key = X"08" then
                        reset1 <= '1';
                        state <= "00"; 
                    elsif death_sig > 0 then
                        state <= "11"; 
                    elsif ps2_key = X"29" then
                        state <= "10";
                    else
                        state <= state;
                    end if;
                    
                when "10" =>
                
                    if reset1 = '1' then
                        reset2 <= not reset2;
                    end if;
                    
                    if reset2 = '1' then
                        reset1 <= '0';
                    else
                        reset1 <= '1';
                    end if;
                    
                    if ps2_key = X"5A" then 
                        state <= "01";
                    elsif ps2_key = X"08" then
                        reset1 <= '1';
                        state <= "00";
                    else
                        state <= state;
                    end if;
                    
                when "11" =>
                    if reset1 = '1' then
                        reset2 <= not reset2;
                    end if;
                    
                    if reset2 = '1' then
                        reset1 <= '0';
                    else
                        reset1 <= '1';
                    end if;
                    
--                    if ps2_key = X"5A" then
--                        reset1 <= '1';
--                        state <= "01";
--                    els
                    if ps2_key = X"08" then
                        reset1 <= '1';
                        state <= "00";
                    else
                        state <= state;
                    end if;
                    
                when others => null;
            end case;
        end if;
    end process;
    
    game_reset <= reset1;
    game_state <= state;
end Behavioral;


--  up     01100011  63
--  down   01100000  60
--  right  01101010  6a
--  left   01100001  61