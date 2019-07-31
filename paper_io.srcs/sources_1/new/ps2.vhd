----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/26 14:44:19
-- Design Name: 
-- Module Name: ps2 - Behavioral
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

entity ps2 is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ps2_clk : in STD_LOGIC;
           ps2_data : in STD_LOGIC;
           led_pin : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           ps2_key : out STD_LOGIC_VECTOR(7 DOWNTO 0)
           );
end ps2;

architecture Behavioral of ps2 is
    signal ps2_clk0,ps2_clk1,ps2_clk2: std_logic;
    signal ps2_state: std_logic;
    signal ps2_loose_n : STD_LOGIC;
    signal ps2_clk_neg : std_logic;
    signal cnt: std_logic_vector(3 downto 0);
    signal cnt_ena : std_logic;
    signal data_temp: std_logic_vector(7 downto 0);
    signal error_cnt : integer range 0 to 5000000;
begin
    
    detect: process(clk, rst_n, ps2_clk)
    begin
        if rst_n = '0' then
            ps2_clk0 <= '0';
            ps2_clk1 <= '0';
            ps2_clk2 <= '0';
        elsif clk'event and clk = '1' then
            ps2_clk0 <= ps2_clk;
            ps2_clk1 <= ps2_clk0;
            ps2_clk2 <= ps2_clk1;
        end if;
    end process detect;

    ps2_clk_neg <= not ps2_clk1 and ps2_clk2;
    
    
    
    receive: process(clk, rst_n, ps2_clk_neg, ps2_data)
    begin
        if rst_n = '0' then
            cnt <= "0000";
            data_temp <= "00000000";
        elsif clk'event and clk = '1' then
            if ps2_clk_neg = '1' then
                error_cnt <= 0;
                if cnt = 0 then
                    cnt <= cnt + 1;
                elsif cnt = 1 then
                    cnt <= cnt + 1;
                    data_temp(0) <= ps2_data;
                elsif cnt = 2 then
                    cnt <= cnt + 1;
                    data_temp(1) <= ps2_data;
                elsif cnt = 3 then
                    cnt <= cnt + 1;
                    data_temp(2) <= ps2_data;
                elsif cnt = 4 then
                    cnt <= cnt + 1;
                    data_temp(3) <= ps2_data;
                elsif cnt = 5 then
                    cnt <= cnt + 1;
                    data_temp(4) <= ps2_data;
                elsif cnt = 6 then
                    cnt <= cnt + 1;
                    data_temp(5) <= ps2_data;
                elsif cnt = 7 then
                    cnt <= cnt + 1;
                    data_temp(6) <= ps2_data;
                elsif cnt = 8 then
                    cnt <= cnt + 1;
                    data_temp(7) <= ps2_data;
                elsif cnt = 9 then
                    cnt <= cnt +1;
                else
                    cnt <= "0000";
                end if;
            else
                error_cnt <= error_cnt + 1;
            end if;
            if error_cnt = 5000000 then
                data_temp <= "00000000";
                cnt <= "0000";
            end if;
        end if;
    end process receive;
    
    show: process(clk, rst_n, data_temp, cnt)
    begin
        if rst_n = '0' then
            ps2_loose_n <= '0';
        elsif clk'event and clk = '1' then
            if error_cnt = 5000000 then
                led_pin <= "00000000";
                ps2_key <= "00000000";
                ps2_loose_n <= '0';
            end if;
            if cnt = 10 then
                if data_temp = X"f0" then 
                    ps2_loose_n <= '1';
                else
                    if ps2_loose_n = '1' then 
                        ps2_loose_n <= '0';
                    else
                        led_pin <= data_temp;
                        ps2_key <= data_temp;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
 
    