----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/25 13:16:15
-- Design Name: 
-- Module Name: play_music - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity play_music is
    Port ( clk : in STD_LOGIC;
           f_ctrl: in STD_LOGIC_vector(4 downto 0);
           a_ctrl: in unsigned(9 downto 0);
           audio_pwm_o : out STD_LOGIC;
           audio_sd_o : out STD_LOGIC
           );
end play_music;

architecture Behavioral of play_music is
    signal ms_cnt: integer range 0 to 400000;
    signal clk_ms: std_logic;
    signal f: integer range 0 to 400000;
begin

    
    f_control: process(f_ctrl)
    begin
        case f_ctrl is
            when "00000" =>
                f <= 382219;
                audio_sd_o <= '0';
            when "00001" =>
                f <= 382219;
                audio_sd_o <= '1';
            when "00010" =>
                f <= 340530;
                audio_sd_o <= '1';
            when "00011" =>
                f <= 303370;
                audio_sd_o <= '1';
            when "00100" =>
                f <= 286344;
                audio_sd_o <= '1';
            when "00101" =>
                f <= 255102;
                audio_sd_o <= '1';
            when "00110" =>
                f <= 227273;
                audio_sd_o <= '1';
            when "00111" =>
                f <= 202478;
                audio_sd_o <= '1';
            when "01000" =>
                f <= 191113;
                audio_sd_o <= '1';
            when "01001" =>
                f <= 170262;
                audio_sd_o <= '1';
            when "01010" =>
                f <= 151688;
                audio_sd_o <= '1';
            when "01011" =>
                f <= 143135;
                audio_sd_o <= '1';
            when "01100" =>
                f <= 127552;
                audio_sd_o <= '1';
            when "01101" =>
                f <= 113636;
                audio_sd_o <= '1';
            when "01110" =>
                f <= 101238;
                audio_sd_o <= '1';
            when "01111" =>
                f <= 95557;
                audio_sd_o <= '1';
            when "10000" =>
                f <= 85131;
                audio_sd_o <= '1';
            when "10001" =>
                f <= 75843;
                audio_sd_o <= '1';
            when "10010" =>
                f <= 71587;
                audio_sd_o <= '1';
            when "10011" =>
                f <= 63776;
                audio_sd_o <= '1';
            when "10100" =>
                f <= 56818;
                audio_sd_o <= '1';
            when "10101" =>
                f <= 50619;
                audio_sd_o <= '1';
            when others => 
                f <= 382219;
                audio_sd_o <= '0';
        end case;
    end process;
    

    pwm: process(clk)
    begin
        if clk'event and clk='1' then
            if ms_cnt = f then 
                clk_ms <= '1';
                ms_cnt <= 0;
            elsif ms_cnt = conv_integer(a_ctrl) then
                clk_ms <= '0';
                ms_cnt <= ms_cnt + 1;
            else
                clk_ms <= clk_ms;
                ms_cnt <= ms_cnt + 1;
            end if; 
        end if;
    end process pwm;  
    
    audio_pwm_o <= clk_ms;
    
    
end Behavioral;
