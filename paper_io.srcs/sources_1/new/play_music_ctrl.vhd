----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/25 13:18:29
-- Design Name: 
-- Module Name: play_music_ctrl - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_Unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity play_music_ctrl is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           btn_amp : in STD_LOGIC_VECTOR (7 downto 0);
           state : in STD_LOGIC_VECTOR (1 downto 0);
           f_ctrl : out STD_LOGIC_VECTOR (4 downto 0);
           a_ctrl : out unsigned (9 downto 0)
           );
end play_music_ctrl;

architecture Behavioral of play_music_ctrl is
    COMPONENT blk_mem_gen_2
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
      );
    END COMPONENT;
    ---------------------------------------------
    signal ms_cnt: integer range 0 to 12500000;
    signal clk_ms: std_logic;
    signal ena: std_logic;
    signal addr: std_logic_vector(8 downto 0);
    signal douta : std_logic_vector(4 downto 0);
    signal a_ctrl_tmp : unsigned (9 downto 0);
begin


    f25hz: process(clk)                -- 0.04s flip   0.08s period 
    begin
        if clk'event and clk='1' then
            if ms_cnt = 4000000 then 
                clk_ms <= not clk_ms;
                ms_cnt <= 0;
            else
                ms_cnt <= ms_cnt + 1;
            end if; 
        end if;
    end process f25hz;  
    
    
    process(clk_ms, rst_n, btn_amp)
    begin
        if rst_n = '0' then
            a_ctrl_tmp <= conv_unsigned(100, 10);
        elsif clk_ms'event and clk_ms = '1' then
            if btn_amp = X"4e" then
                if a_ctrl_tmp > 0 then
                    a_ctrl_tmp <= a_ctrl_tmp - 10;
                else
                    a_ctrl_tmp <= a_ctrl_tmp;
                end if;
            elsif btn_amp = X"55" then
                if a_ctrl_tmp < 1000 then
                    a_ctrl_tmp <= a_ctrl_tmp + 10;
                else
                    a_ctrl_tmp <= a_ctrl_tmp;
                end if;
            end if;
            a_ctrl <= a_ctrl_tmp;
        end if;
        
    end process;
    
    process(state, rst_n, clk_ms)
        variable cnt1: std_logic_vector(8 downto 0);
        variable cnt2: std_logic_vector(8 downto 0);
        variable cnt3: std_logic_vector(8 downto 0);
    begin
        if rst_n = '0' then
            f_ctrl <= "00000";
            addr <= "000000000";
            cnt1 :=  conv_std_logic_vector(0, 9);
            cnt2 :=  conv_std_logic_vector(0, 9);
            cnt3 :=  conv_std_logic_vector(0, 9);
            ena <= '0';
        elsif clk_ms'event and clk_ms='1' then
            ena <= '1';
            if state = 1 then
                f_ctrl <= douta;
                if cnt1 = 290 then
                    cnt1 := conv_std_logic_vector(0, 9);
                else 
                    cnt1 := cnt1 + 1;
                end if;
                addr <= cnt1;
                cnt2 := conv_std_logic_vector(0, 9);
                cnt3 := conv_std_logic_vector(0, 9);
            elsif state = 3 then
                f_ctrl <= douta;
                if cnt2 = 335-290 then
                    cnt2 := conv_std_logic_vector(0, 9);
                else 
                    cnt2 := cnt2 + 1;
                end if;
                addr <= 290 + cnt2;
                cnt1 := conv_std_logic_vector(0, 9);
                cnt3 := conv_std_logic_vector(0, 9);
            elsif state = 0 then
                f_ctrl <= douta;
                if cnt3 = 409-335 then
                    cnt3 := conv_std_logic_vector(0, 9);
                else 
                    cnt3 := cnt3 + 1;
                end if;
                addr <= 335 + cnt3;
                cnt1 := conv_std_logic_vector(0, 9);
                cnt2 := conv_std_logic_vector(0, 9);
            else
                f_ctrl <= douta;
                addr <= conv_std_logic_vector(0, 9);
                cnt1 := cnt1;
            end if;
        end if;
    end process;
    
    
  get : blk_mem_gen_2
  PORT MAP (
    clka => clk_ms,
    ena => ena,
    addra => addr,
    douta => douta
  );
  
  

end Behavioral;
