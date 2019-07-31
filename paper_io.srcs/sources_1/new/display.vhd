----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/19 16:05:22
-- Design Name: 
-- Module Name: display - Behavioral
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
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port ( clk_25m: in STD_LOGIC;
           rst_n : in STD_LOGIC;
           h_cnt : in STD_LOGIC_VECTOR (9 DOWNTO 0);
           v_cnt : in STD_LOGIC_VECTOR (9 DOWNTO 0);
           valid : in STD_LOGIC;
           dina : in STD_LOGIC_VECTOR (5 DOWNTO 0);
           dinb : in STD_LOGIC_VECTOR (0 DOWNTO 0);
           addra : out STD_LOGIC_VECTOR (17 DOWNTO 0);
           addrb : out STD_LOGIC_VECTOR (15 DOWNTO 0);
           vga_r_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_g_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_b_pin : out STD_LOGIC_VECTOR (3 downto 0);
           game_state: in STD_LOGIC_VECTOR (1 DOWNTO 0);
           death_in: in STD_LOGIC_VECTOR(1 DOWNTO 0)
           --winner: in STD_LOGIC;
           );
end display;

architecture Behavioral of display is
--------------------------------------------------------
    --procedure number_decoder(
    --    signal number:)
    --is
    --begin
    --
    --end procedure;
--------------------------------------------------------
begin
    process(rst_n, clk_25m)
        variable cnt_ram: std_logic_vector(17 downto 0);
        variable cnt_rom: std_logic_vector(15 downto 0);
        variable cnt_rom1: std_logic_vector(15 downto 0);
        variable cnt_rom2: std_logic_vector(15 downto 0);
        variable cnt_rom3: std_logic_vector(15 downto 0);
        variable cnt_rom4: std_logic_vector(15 downto 0);
        variable cnt_h1: std_logic_vector(15 downto 0);
        variable cnt_h2: std_logic_vector(15 downto 0);
        variable cnt_t1: std_logic_vector(15 downto 0);
        variable cnt_t2: std_logic_vector(15 downto 0);
        variable cnt_o1: std_logic_vector(15 downto 0);
        variable cnt_o2: std_logic_vector(15 downto 0);
        variable tmp1, tmp2 : integer range 0 to 1023;
        variable one1, ten1, hundred1: std_logic_vector(3 downto 0);
        variable one2, ten2, hundred2: std_logic_vector(3 downto 0);
        variable cnt_player1 : unsigned(17 downto 0);
        variable cnt_player2 : unsigned(17 downto 0);
        variable win_num: std_logic_vector(15 downto 0);
        variable lose_num: std_logic_vector(15 downto 0);
    begin 
        if rst_n = '0' then
            cnt_ram := conv_std_logic_vector(0, 18);
            cnt_rom := conv_std_logic_vector(0, 16);
            cnt_h1 := conv_std_logic_vector(0, 16);
            cnt_h2 := conv_std_logic_vector(0, 16);
            cnt_t1 := conv_std_logic_vector(0, 16);
            cnt_t2 := conv_std_logic_vector(0, 16);
            cnt_o1 := conv_std_logic_vector(0, 16);
            cnt_o2 := conv_std_logic_vector(0, 16);
            cnt_player1 := conv_unsigned(0, 18);
            cnt_player2 := conv_unsigned(0, 18);
            win_num := conv_std_logic_vector(0, 16);
            lose_num := conv_std_logic_vector(0, 16);
        elsif clk_25m'event and clk_25m = '1' then
-------------------------------------------------------------------------------------------------------------------
            if h_cnt <= 480 and v_cnt <= 480 and h_cnt >= 1 and v_cnt >= 1 then    --- left side
--                if dina = 0 then
--                    vga_r_pin <= "1101";
--                    vga_g_pin <= "1111";
--                    vga_b_pin <= "1111";
--                elsif dina = 16 then
--                    cnt_player1 := cnt_player1 + 1; 
--                    vga_r_pin <= "0000";
--                    vga_g_pin <= "0000";
--                    vga_b_pin <= "1111";
--                elsif dina = 24 then
--                    cnt_player2 := cnt_player2 + 1;
--                    vga_r_pin <= "1111";
--                    vga_g_pin <= "0000";
--                    vga_b_pin <= "0000";
--                elsif dina = 5 then
--                    vga_r_pin <= "0000";
--                    vga_g_pin <= "1000";
--                    vga_b_pin <= "1111";
--                elsif dina = 7 then
--                    vga_r_pin <= "1111";
--                    vga_g_pin <= "1000";
--                    vga_b_pin <= "0000";
--                end if;
--                cnt_ram := conv_std_logic_vector(conv_integer(h_cnt)/16 + (conv_integer(v_cnt)/16 - 1)*30 - 1 , 10); 
                if dina(4) = '1' then            -- count number
                    case dina(3) is
                        when '0' => 
                            cnt_player1 := cnt_player1 + 1;
                        when '1' =>
                            cnt_player2 := cnt_player2 + 1;
                    end case;
                else
                    cnt_player1 := cnt_player1;
                    cnt_player2 := cnt_player2;
                end if;
                    
                if dina(4 downto 0) = 0 then                                      -- blank
                    vga_r_pin <= "1101";
                    vga_g_pin <= "1111";
                    vga_b_pin <= "1111";

                elsif dina(4) = '1' and dina(2) = '0' then            -- base without paper   2
                    case dina(3) is
                        when '0' => 
                            vga_r_pin <= "0000";
                            vga_g_pin <= "0000";
                            vga_b_pin <= "1111";
                        when '1' =>
                            vga_r_pin <= "1111";
                            vga_g_pin <= "0000";
                            vga_b_pin <= "0000";
                    end case;
                    
                elsif dina(4) = '1' and dina(2) = '1' and dina(0) = '0' then            -- base1 with paper 1
                    if dina(3) = dina(1) then
                        case dina(1) is
                            when '0' => 
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "1111";
                            when '1' =>
                                vga_r_pin <= "1111";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                        end case;
                    else
                        case dina(1) is
                            when '0' => 
                                vga_r_pin <= X"6";
                                vga_g_pin <= X"0";
                                vga_b_pin <= X"F";
                            when '1' =>
                                vga_r_pin <= X"A";
                                vga_g_pin <= X"0";
                                vga_b_pin <= X"F";
                        end case;
                    end if;
                    
                elsif dina(4) = '1' and dina(2) = '1' and dina(0) = '1' then            -- base1 with head 1
                    if dina(3) = dina(1) then
                        case dina(1) is
                            when '0' => 
                                vga_r_pin <= "0000";
                                vga_g_pin <= "1000";
                                vga_b_pin <= "1111";
                            when '1' =>
                                vga_r_pin <= "1111";
                                vga_g_pin <= "1000";
                                vga_b_pin <= "0000";
                        end case;
                    else
                        case dina(1) is
                            when '0' => 
                                vga_r_pin <= X"6";
                                vga_g_pin <= X"0";
                                vga_b_pin <= X"A";
                            when '1' =>
                                vga_r_pin <= X"A";
                                vga_g_pin <= X"0";
                                vga_b_pin <= X"A";
                        end case;
                    end if;
                    
                elsif dina(4) = '0' and dina(2) = '1' and dina(0) = '0' then            -- strip 4
                    case dina(1) is
                        when '0' => 
                            vga_r_pin <= "0000";
                            vga_g_pin <= "1100";
                            vga_b_pin <= "1111";
                        when '1' =>
                            vga_r_pin <= "1111";
                            vga_g_pin <= "1100";
                            vga_b_pin <= "0000";
                    end case;
                    
                elsif dina(2) = '1' and dina(0) = '1' then            -- head 6
                    case dina(1) is
                        when '0' => 
                            vga_r_pin <= "0000";
                            vga_g_pin <= "1000";
                            vga_b_pin <= "1111";
                        when '1' =>
                            vga_r_pin <= "1111";
                            vga_g_pin <= "1000";
                            vga_b_pin <= "0000";
                    end case;
                end if;

                if h_cnt = 480 and v_cnt = 480 then
                    cnt_ram := conv_std_logic_vector(0,18);                
                else
                    cnt_ram := cnt_ram + 1; 
                end if;
                
                
                
                if cnt_ram = 230399 then
                    tmp1 := conv_integer(cnt_player1(17 downto 8));
                    one1 := conv_std_logic_vector(tmp1 rem 10, 4);
                    ten1 := conv_std_logic_vector(tmp1/10 rem 10, 4);
                    hundred1 := conv_std_logic_vector(tmp1/100 rem 10, 4);
                    tmp2 := conv_integer(cnt_player2(17 downto 8));
                    one2 := conv_std_logic_vector(tmp2 rem 10, 4);
                    ten2 := conv_std_logic_vector(tmp2/10 rem 10, 4);
                    hundred2 := conv_std_logic_vector(tmp2/100 rem 10, 4);
                    cnt_player1 := conv_unsigned(0, 18);
                    cnt_player2 := conv_unsigned(0, 18);
                else
                    tmp1 := tmp1;
                    one1 := one1;
                    ten1 := ten1;
                    hundred1 := hundred1;
                    tmp2 := tmp2;
                    one2 := one2;
                    ten2 := ten2;
                    hundred2 := hundred2;
                end if;
                
-------------------------------------------------------------------------------------------------------------------                
            elsif h_cnt <= 640 and v_cnt <= 480 and h_cnt >= 481 and v_cnt >= 1 then             --- right side
                if h_cnt <= 640 and v_cnt <= 160 and h_cnt >= 481 and v_cnt >= 1 then  -- logo show corner
                    if h_cnt <= 640 and v_cnt <= 96 and h_cnt >= 481 and v_cnt >= 65 then   -- logo 
                        if dinb = "0" then
                            vga_r_pin <= "1000";
                            vga_g_pin <= "1000";
                            vga_b_pin <= "1000";
                        else
                            vga_r_pin <= "0000";
                            vga_g_pin <= "0000";
                            vga_b_pin <= "0000";
                        end if;
                        if h_cnt = 640 and v_cnt = 96 then
                            cnt_rom := conv_std_logic_vector(0,16);
                        else
                            cnt_rom := cnt_rom + 1; 
                        end if;
                        addrb <= cnt_rom;
                    else                                                               -- except logo
                        vga_r_pin <= "1000";
                        vga_g_pin <= "1000";
                        vga_b_pin <= "1000";
                    end if;
-------------------------------------------------------------------------------------------------------------------                    
                elsif h_cnt <= 640 and v_cnt <= 240 and h_cnt >= 481 and v_cnt >= 161 then    --  state show corner
                    case game_state is
                        when "00" =>      
                            if h_cnt <= 600 and v_cnt <= 216 and h_cnt >= 521 and v_cnt >= 185 then   --  start
                                if dinb = "0" then
                                    vga_r_pin <= "0000";
                                    vga_g_pin <= "0000";
                                    vga_b_pin <= "0000";
                                else
                                    vga_r_pin <= "1111";
                                    vga_g_pin <= "1111";
                                    vga_b_pin <= "1111";
                                end if;
                                if h_cnt = 600 and v_cnt = 216 then
                                    cnt_rom := conv_std_logic_vector(0,16);
                                else
                                    cnt_rom := cnt_rom + 1; 
                                end if;
                                addrb <= cnt_rom + 20480;
                            else 
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            
                        when "01" =>
                            if h_cnt <= 600 and v_cnt <= 216 and h_cnt >= 521 and v_cnt >= 185 then   --  pause
                                if dinb = "0" then
                                    vga_r_pin <= "0000";
                                    vga_g_pin <= "0000";
                                    vga_b_pin <= "0000";
                                else
                                    vga_r_pin <= "1111";
                                    vga_g_pin <= "1111";
                                    vga_b_pin <= "1111";
                                end if;
                                if h_cnt = 600 and v_cnt = 216 then
                                    cnt_rom := conv_std_logic_vector(0,16);
                                else
                                    cnt_rom := cnt_rom + 1; 
                                end if;
                                addrb <= cnt_rom + 23040;
                            else 
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            
                        when "10" =>
                            if h_cnt <= 640 and v_cnt <= 216 and h_cnt >= 481 and v_cnt >= 185 then   --  continue
                                if dinb = "0" then
                                    vga_r_pin <= "0000";
                                    vga_g_pin <= "0000";
                                    vga_b_pin <= "0000";
                                else
                                    vga_r_pin <= "1111";
                                    vga_g_pin <= "1111";
                                    vga_b_pin <= "1111";
                                end if;
                                if h_cnt = 640 and v_cnt = 216 then
                                    cnt_rom := conv_std_logic_vector(0,16);
                                else
                                    cnt_rom := cnt_rom + 1; 
                                end if;
                                addrb <= cnt_rom + 25600;
                            else 
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            
                        when "11" =>
                            if death_in = "10" then
                                win_num := conv_std_logic_vector(16384, 16);
                                lose_num := conv_std_logic_vector(15872, 16);
                            elsif death_in = "01" then
                                win_num := conv_std_logic_vector(15872, 16);
                                lose_num := conv_std_logic_vector(16384, 16);
                            elsif death_in = "11" then
                                if tmp1 > tmp2 then
                                    win_num := conv_std_logic_vector(15872, 16);
                                    lose_num := conv_std_logic_vector(16384, 16);
                                elsif tmp2 > tmp1 then
                                    win_num := conv_std_logic_vector(16384, 16);
                                    lose_num := conv_std_logic_vector(15872, 16);
                                elsif tmp2 = tmp1 then
                                    win_num := conv_std_logic_vector(15872, 16);
                                    lose_num := conv_std_logic_vector(15872, 16);
                                end if;
                            end if;
                            if h_cnt <= 640 and v_cnt <= 216 and h_cnt >= 481 and v_cnt >= 185 then   --  game over
                                if h_cnt >= 480 + 20 and h_cnt <= 509 + 20 then
                                    if dinb = "0" then
                                        vga_r_pin <= "0000";
                                        vga_g_pin <= "0000";
                                        vga_b_pin <= "0000";
                                    else
                                        vga_r_pin <= "1111";
                                        vga_g_pin <= "1111";
                                        vga_b_pin <= "1111";
                                    end if;
                                    if h_cnt = 509 + 20 and v_cnt = 216 then
                                        cnt_rom1 := conv_std_logic_vector(0,16);
                                    else
                                        cnt_rom1 := cnt_rom1 + 1; 
                                    end if;
                                    addrb <= cnt_rom1 + 30720;
                                elsif h_cnt >= 510 + 20 and h_cnt <= 525 + 20 then
                                    if dinb = "0" then
                                        vga_r_pin <= "0000";
                                        vga_g_pin <= "0000";
                                        vga_b_pin <= "0000";
                                    else
                                        vga_r_pin <= "1111";
                                        vga_g_pin <= "1111";
                                        vga_b_pin <= "1111";
                                    end if;
                                    if h_cnt = 525 + 20 and v_cnt = 216 then
                                        cnt_rom2 := conv_std_logic_vector(0,16);
                                    else
                                        cnt_rom2 := cnt_rom2 + 1; 
                                    end if;
                                    addrb <= cnt_rom2 + win_num;
                                elsif h_cnt >= 530 + 40 and h_cnt <= 559 + 40 then
                                    if dinb = "0" then
                                        vga_r_pin <= "0000";
                                        vga_g_pin <= "0000";
                                        vga_b_pin <= "0000";
                                    else
                                        vga_r_pin <= "1111";
                                        vga_g_pin <= "1111";
                                        vga_b_pin <= "1111";
                                    end if;
                                    if h_cnt = 559 + 40 and v_cnt = 216 then
                                        cnt_rom3 := conv_std_logic_vector(0,16);
                                    else
                                        cnt_rom3 := cnt_rom3 + 1; 
                                    end if;
                                    addrb <= cnt_rom3 + 31680;
                                elsif h_cnt >= 560 + 40 and h_cnt <= 575 + 40 then
                                    if dinb = "0" then
                                        vga_r_pin <= "0000";
                                        vga_g_pin <= "0000";
                                        vga_b_pin <= "0000";
                                    else
                                        vga_r_pin <= "1111";
                                        vga_g_pin <= "1111";
                                        vga_b_pin <= "1111";
                                    end if;
                                    if h_cnt = 575 + 40 and v_cnt = 216 then
                                        cnt_rom4 := conv_std_logic_vector(0,16);
                                    else
                                        cnt_rom4 := cnt_rom4 + 1; 
                                    end if;
                                    addrb <= cnt_rom4 + lose_num;
                                else
                                    vga_r_pin <= "0000";
                                    vga_g_pin <= "0000";
                                    vga_b_pin <= "0000";
                                end if;
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                        when others => null;
                    end case;



-------------------------------------------------------------------------------------------------------------------                    
                elsif h_cnt <= 640 and v_cnt <= 306 and h_cnt >= 481 and v_cnt >= 275 then    --  player 1
                    if dinb = "0" then
                        vga_r_pin <= "0000";
                        vga_g_pin <= X"b";
                        vga_b_pin <= "0000";
                    else
                        vga_r_pin <= "0000";
                        vga_g_pin <= "0000";
                        vga_b_pin <= "0000";
                    end if;
                    if h_cnt = 640 and v_cnt = 306 then
                        cnt_rom := conv_std_logic_vector(0,16);
                    else
                        cnt_rom := cnt_rom + 1; 
                    end if;
                    addrb <= cnt_rom + 5120;
                    
-------------------------------------------------------------------------------------------------------------------                
                elsif h_cnt <= 592 and v_cnt <= 338 and h_cnt >= 577 and v_cnt >= 307 then     -- hundred 1
                    case hundred1 is
                        when "0000" =>                                         --- hundred1 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(15360,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0001" =>                                        --- hundred1 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(15872,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0010" =>                                        --- hundred1 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(16384,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0011" =>                                        --- hundred1 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(16896,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0100" =>                                        --- hundred1 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(17408,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0101" =>                                        --- hundred1 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(17920,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0110" =>                                        --- hundred1 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(18432,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "0111" =>                                        --- hundred1 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(18944,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "1000" =>                                        --- hundred1 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(19456,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when "1001" =>                                        --- hundred1 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 307 + 31 then
                                cnt_h1 := conv_std_logic_vector(19968,16);
                            else
                                cnt_h1 := cnt_h1 + 1; 
                            end if;
                        when others => null;
                    end case;
                    addrb <= cnt_h1;
                    
                elsif h_cnt <= 608 and v_cnt <= 338 and h_cnt >= 593 and v_cnt >= 307 then     -- ten 1
                    case ten1 is
                        when "0000" =>                                         --- ten1 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(15360,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0001" =>                                        --- ten1 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(15872,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0010" =>                                        --- ten1 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(16384,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0011" =>                                        --- ten1 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(16896,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0100" =>                                        --- ten1 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(17408,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0101" =>                                        --- ten1 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(17920,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0110" =>                                        --- ten1 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(18432,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "0111" =>                                        --- ten1 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(18944,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "1000" =>                                        --- ten1 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(19456,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when "1001" =>                                        --- ten1 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 307 + 31 then
                                cnt_t1 := conv_std_logic_vector(19968,16);
                            else
                                cnt_t1 := cnt_t1 + 1; 
                            end if;
                        when others => null;
                    end case;           
                    addrb <= cnt_t1;
                
                elsif h_cnt <= 624 and v_cnt <= 338 and h_cnt >= 609 and v_cnt >= 307 then     -- one 1
                    case one1 is
                        when "0000" =>                                         --- one1 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(15360,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0001" =>                                        --- one1 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(15872,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0010" =>                                        --- one1 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 and v_cnt = 307 then
                                cnt_o1 := conv_std_logic_vector(16384,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0011" =>                                        --- one1 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(16896,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0100" =>                                        --- one1 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(17408,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0101" =>                                        --- one1 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(17920,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0110" =>                                        --- one1 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(18432,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "0111" =>                                        --- one1 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(18944,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "1000" =>                                        --- one1 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(19456,16);
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when "1001" =>                                        --- one1 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609+15 and v_cnt = 307+31 then
                                cnt_o1 := conv_std_logic_vector(19968,16); --- 19968
                            else
                                cnt_o1 := cnt_o1 + 1; 
                            end if;
                        when others => null;
                    end case;
                    addrb <= cnt_o1;

                
                elsif h_cnt <= 640 and v_cnt <= 406 and h_cnt >= 481 and v_cnt >= 375 then    --  player 2
                    if dinb = "0" then
                        vga_r_pin <= "0000";
                        vga_g_pin <= X"b";
                        vga_b_pin <= "0000";
                    else
                        vga_r_pin <= "0000";
                        vga_g_pin <= "0000";
                        vga_b_pin <= "0000";
                    end if;
                    if h_cnt = 640 and v_cnt = 406 then
                        cnt_rom := conv_std_logic_vector(0, 16);
                    else
                        cnt_rom := cnt_rom + 1; 
                    end if;
                    addrb <= cnt_rom + 10240;
                    
                elsif h_cnt <= 592 and v_cnt <= 438 and h_cnt >= 577 and v_cnt >= 407 then     -- hundred 2
                    case hundred2 is
                        when "0000" =>                                         --- hundred2 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(15360,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0001" =>                                        --- hundred2 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(15872,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0010" =>                                        --- hundred2 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(16384,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0011" =>                                        --- hundred2 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(16896,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0100" =>                                        --- hundred2 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(17408,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0101" =>                                        --- hundred2 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(17920,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0110" =>                                        --- hundred2 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(18432,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "0111" =>                                        --- hundred2 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(18944,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "1000" =>                                        --- hundred2 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(19456,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when "1001" =>                                        --- hundred2 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 577 + 15 and v_cnt = 407 + 31 then
                                cnt_h2 := conv_std_logic_vector(19968,16);
                            else
                                cnt_h2 := cnt_h2 + 1; 
                            end if;
                        when others => null;
                    end case;
                    addrb <= cnt_h2;
                    
                elsif h_cnt <= 608 and v_cnt <= 438 and h_cnt >= 593 and v_cnt >= 407 then     -- ten 2
                    case ten2 is
                        when "0000" =>                                         --- ten2 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(15360,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0001" =>                                        --- ten2 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(15872,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0010" =>                                        --- ten2 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(16384,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0011" =>                                        --- ten2 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(16896,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0100" =>                                        --- ten2 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(17408,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0101" =>                                        --- ten2 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(17920,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0110" =>                                        --- ten2 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(18432,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "0111" =>                                        --- ten2 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(18944,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "1000" =>                                        --- ten2 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(19456,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when "1001" =>                                        --- ten2 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 593 + 15 and v_cnt = 407 + 31 then
                                cnt_t2 := conv_std_logic_vector(19968,16);
                            else
                                cnt_t2 := cnt_t2 + 1; 
                            end if;
                        when others => null;
                    end case;           
                    addrb <= cnt_t2;
                
                elsif h_cnt <= 624 and v_cnt <= 438 and h_cnt >= 609 and v_cnt >= 407 then     -- one 2
                    case one2 is
                        when "0000" =>                                         --- one2 0
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(15360,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0001" =>                                        --- one2 1
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(15872,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0010" =>                                        --- one2 2
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(16384,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0011" =>                                        --- one2 3
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(16896,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0100" =>                                        --- one2 4
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(17408,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0101" =>                                        --- one2 5
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(17920,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0110" =>                                        --- one2 6
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(18432,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "0111" =>                                        --- one2 7
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(18944,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "1000" =>                                        --- one2 8
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(19456,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when "1001" =>                                        --- one2 9
                            if dinb = "0" then
                                vga_r_pin <= "0000";
                                vga_g_pin <= X"b";
                                vga_b_pin <= "0000";
                            else
                                vga_r_pin <= "0000";
                                vga_g_pin <= "0000";
                                vga_b_pin <= "0000";
                            end if;
                            if h_cnt = 609 + 15 and v_cnt = 407 + 31 then
                                cnt_o2 := conv_std_logic_vector(19968,16);
                            else
                                cnt_o2 := cnt_o2 + 1; 
                            end if;
                        when others => null;
                    end case;
                    addrb <= cnt_o2;
                    
                else
                    vga_r_pin <= "0000";
                    vga_g_pin <= X"b";
                    vga_b_pin <= "0000";
                end if;
                
            else                                                                        ---- no valid
                vga_r_pin <= "0000";
                vga_g_pin <= "0000";
                vga_b_pin <= "0000";
            end if;
            addra <= cnt_ram;
        end if;
    end process;
end Behavioral;
