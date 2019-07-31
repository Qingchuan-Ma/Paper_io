----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/19 16:07:55
-- Design Name: 
-- Module Name: vga_timing - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_timing is
    port(
        pclk: in std_logic;
        reset: in std_logic;
        hsync: out std_logic;
        vsync: out std_logic;
        valid: out std_logic;
        v_valid_out: out std_logic;
        h_cnt: out STD_LOGIC_VECTOR(9 downto 0);
        v_cnt: out STD_LOGIC_VECTOR(9 downto 0));
end vga_timing;

architecture Behavioral of vga_timing is
   constant    h_frontporch : integer:= 96;
   constant    h_active : integer:= 144;
   constant    h_backporch : integer:= 784;
   constant    h_total : integer:= 800;
   
   constant    v_frontporch : integer:= 2;
   constant    v_active : integer:= 35;
   constant    v_backporch : integer:= 515;
   constant    v_total : integer:= 525;
   
	signal x_cnt, y_cnt: integer range 0 to 1023;
begin

    process(reset, pclk)
	   variable h_valid, v_valid: std_logic;
    begin
		if reset='0' then
			x_cnt <= 1;
			y_cnt <= 1;
		elsif pclk'event and pclk='1' then
			if (x_cnt = h_total) then
				x_cnt <= 1;
			else
				x_cnt <= x_cnt + 1;
			end if;
			if (y_cnt = v_total) and (x_cnt = h_total) then
				y_cnt <= 1;
			elsif (x_cnt = h_total) then
				y_cnt <= y_cnt + 1;			
			end if;
		
			if x_cnt > h_frontporch then
				hsync<='1';
			else
				hsync<='0';
			end if;
			if y_cnt > v_frontporch then
				vsync<='1';
			else
				vsync<='0';
			end if;
			if 	(x_cnt > h_active) and (x_cnt <= h_backporch)  then
				h_valid:='1';
			else
				h_valid:='0';
			end if;
			if 	(y_cnt > v_active) and (y_cnt <= v_backporch)  then
				v_valid:='1';
			else
				v_valid:='0';
			end if;			
			if h_valid='1' then
				h_cnt<=conv_std_logic_vector(x_cnt-h_active,10);
			else
				h_cnt<=(others=>'0');
			end if;
			if v_valid='1' then
				v_cnt<=conv_std_logic_vector(y_cnt-v_active,10);
			else
				v_cnt<=(others=>'0');
			end if;			
		    valid <= h_valid and v_valid;
		    v_valid_out <= v_valid;
		end if;				
	end process;

end Behavioral;
