----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/25 13:23:54
-- Design Name: 
-- Module Name: music - Behavioral
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

entity music is
      Port (clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            game_state : in STD_LOGIC_VECTOR (1 downto 0);
            btn_amp : in STD_LOGIC_VECTOR (7 downto 0);
            audio_pwm_o : out STD_LOGIC;
            audio_sd_o : out STD_LOGIC
       );
end music;

architecture Behavioral of music is
    component play_music is
        Port ( clk : in STD_LOGIC;
               f_ctrl: in STD_LOGIC_VECTOR(4 downto 0);
               a_ctrl: in unsigned(9 downto 0);            --  + -
               audio_pwm_o : out STD_LOGIC;
               audio_sd_o : out STD_LOGIC
               );
    end component;
    --------------------------------------------
    component play_music_ctrl is
        port (
            clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            btn_amp : in STD_LOGIC_VECTOR (7 downto 0);
            state : in STD_LOGIC_VECTOR (1 downto 0);
            f_ctrl: out STD_LOGIC_VECTOR(4 downto 0);
            a_ctrl: out unsigned(9 downto 0)
            );
    end component; 
    ----------------------------------------------
    signal f_ctrl: STD_LOGIC_VECTOR(4 downto 0);
    signal a_ctrl: unsigned(9 downto 0);
begin
    
    play: play_music 
          PORT MAP (
            clk => clk,
            f_ctrl => f_ctrl,
            a_ctrl => a_ctrl,
            audio_pwm_o => audio_pwm_o,
            audio_sd_o => audio_sd_o
          );
    
    sel: play_music_ctrl
        port map (
            clk => clk,
            rst_n => rst_n,
            btn_amp => btn_amp,
            state => game_state,
            f_ctrl => f_ctrl,
            a_ctrl => a_ctrl
            );
            

end Behavioral;
