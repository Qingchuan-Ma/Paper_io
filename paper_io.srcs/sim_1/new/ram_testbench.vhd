----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/19 17:00:58
-- Design Name: 
-- Module Name: ram_testbench - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_testbench is
--  Port ( );
end ram_testbench;

architecture Behavioral of ram_testbench is
    signal clk: std_logic := '0';
    signal ena: std_logic := '0';
    signal addra: std_logic_vector (17 downto 0);
    signal dina: STD_LOGIC_VECTOR (2 downto 0);
    signal douta: STD_LOGIC_VECTOR (2 downto 0);
    signal wea: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal enb: std_logic := '0';
    signal addrb: std_logic_vector (17 downto 0);
    signal dinb: STD_LOGIC_VECTOR (2 downto 0);
    signal doutb: STD_LOGIC_VECTOR (2 downto 0);
    signal web: STD_LOGIC_VECTOR(0 DOWNTO 0);
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
      );
    END COMPONENT;
begin

U1: blk_mem_gen_0 
        port map(
            clka => clk,
            ena => '0',
            wea => "0",
            dina => "000",
            addra => addra,
            douta => douta,
            clkb => clk,
            enb => enb,
            web => web,
            dinb => "000",
            addrb => addrb,
            doutb => doutb
        );
       
    clk <= not clk after 10 ns;
    
    test : process
    begin              
        enb <= '0';
        web <= "0";
        dinb <= "000";
        addrb <= conv_std_logic_vector(112876,18);
    wait for 40 ns;
        enb <= '1';
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
        web <= "1";
        dinb <= "001";
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        enb <= '0';
        web <= "0";
        dinb <= "000";
        addrb <= conv_std_logic_vector(112876,18);
    wait for 40 ns;
        enb <= '1';
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
    wait for 40 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait for 20 ns;
        addrb <= addrb + 1;
    wait; 
    end process test;  

end Behavioral;
