library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity game_control is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           v_valid : in STD_LOGIC;
           btn_pin : in STD_LOGIC_VECTOR(4 downto 0);
           ps2_key : in STD_LOGIC_VECTOR(7 downto 0);
           read_data : in STD_LOGIC_VECTOR (5 downto 0);
           data_addr_out : out STD_LOGIC_VECTOR (17 downto 0);
           write_data_out : out STD_LOGIC_VECTOR (5 downto 0);
           wea_out : out STD_LOGIC_VECTOR (0 downto 0);
           en_ram_out: out std_logic;
           game_state : in STD_LOGIC_VECTOR (1 downto 0);
           game_reset : in STD_LOGIC;
           death_out : out STD_LOGIC_VECTOR (1 downto 0);
           internal_state_out : out STD_LOGIC_VECTOR (2 downto 0)
           );
end game_control;

architecture Behavioral of game_control is

    COMPONENT blk_mem_gen_3
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
      );
    END COMPONENT;
    
    signal stack_en: std_logic;
    signal stack_we: STD_LOGIC_VECTOR(0 downto 0);
    signal stack_addr: STD_LOGIC_VECTOR(9 downto 0);
    signal stack_write_data: STD_LOGIC_VECTOR(9 downto 0);
    signal stack_read_data: STD_LOGIC_VECTOR(9 downto 0);

    signal stack_size: integer range 0 to 1023;

    signal dfs_x: integer range 0 to 31;
    signal dfs_y: integer range 0 to 31;

    signal cur_x: integer range 0 to 31;
    signal cur_y: integer range 0 to 31;

    signal dfs_state: STD_LOGIC_VECTOR(3 downto 0);
    signal dfs_direction: STD_LOGIC_VECTOR(1 downto 0);


    signal internal_state: std_logic_vector(2 downto 0);
    signal last_v_valid: std_logic;
    

    signal head_1_x: integer range 0 to 31;
    signal head_1_y: integer range 0 to 31;
    signal head_2_x: integer range 0 to 31;
    signal head_2_y: integer range 0 to 31;
    
    signal back_1: std_logic_vector(1 downto 0);
    signal back_2: std_logic_vector(1 downto 0);
    
    signal left_1: integer range 0 to 31;
    signal right_1: integer range 0 to 31;
    signal up_1: integer range 0 to 31;
    signal down_1: integer range 0 to 31;
    
    signal left_2: integer range 0 to 31;
    signal right_2: integer range 0 to 31;
    signal up_2: integer range 0 to 31;
    signal down_2: integer range 0 to 31;
    
    signal rst_RAM_x: integer range 0 to 511;
    signal rst_RAM_y: integer range 0 to 511;
    
    signal move_cnt: integer range 0 to 15;
    signal step_cnt: integer range 0 to 15;
    

    signal data_addr : STD_LOGIC_VECTOR (17 downto 0);
    
    
    signal state_1: std_logic_vector(1 downto 0);
    signal state_2: std_logic_vector(1 downto 0);
    signal last_state_1: std_logic_vector(1 downto 0);
    signal last_state_2: std_logic_vector(1 downto 0);
    
    signal move_state: std_logic_vector(3 downto 0);
    
    signal death_state: std_logic_vector(3 downto 0);
    
    signal death: std_logic_vector(1 downto 0);
    
    signal fill_state: std_logic_vector(2 downto 0);
    signal fill_x: integer range 0 to 31;
    signal fill_y: integer range 0 to 31;
    signal fill_cnt_x: integer range 0 to 15;
    signal fill_cnt_y: integer range 0 to 15;
    signal fill_read_write_state: std_logic_vector(2 downto 0);
    signal get_data: std_logic_vector(5 downto 0);


begin
                        
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            internal_state <= "000";
        elsif clk'event and clk = '1' then
            if ps2_key = X"08" then
                internal_state <= "000";
            end if;
            if internal_state = "000" then
                death <= "00";
                death_state <= "0000";
                if rst_RAM_x < 480 and rst_RAM_y <480 then
                    data_addr <= conv_std_logic_vector(rst_RAM_x+rst_RAM_y*480, 18);
                    wea_out <= "1";
                    en_ram_out <= '1';
                    if rst_RAM_x >= 80+16 and rst_RAM_x < 80+32 and rst_RAM_y >= 240+16 and rst_RAM_y < 240+32 then
                        write_data_out <= "010101";
                    elsif rst_RAM_x >= 80 and rst_RAM_x < 80+48 and rst_RAM_y >= 240 and rst_RAM_y < 240+48 then 
                        write_data_out <= "010000";
                    elsif rst_RAM_x >= 22*16+16 and rst_RAM_x < 22*16+32 and rst_RAM_y >= 240+16 and rst_RAM_y < 240+32 then
                        write_data_out <= "011111";
                    elsif rst_RAM_x >= 22*16 and rst_RAM_x < 22*16+48 and rst_RAM_y >= 240 and rst_RAM_y < 240+48 then 
                        write_data_out <= "011000";
                    else
                        write_data_out <= "000000";
                    end if;
                    
                    if rst_RAM_x < 479 then
                        rst_RAM_x <= rst_RAM_x + 1;
                    else
                        rst_RAM_x <= 0;
                        rst_RAM_y <= rst_RAM_y + 1;
                    end if;
                else
                    wea_out <= "0";
                    rst_RAM_x <= 0;
                    rst_RAM_y <= 0;
                    internal_state <= "001";
                    en_ram_out <= '0';
                    
                    en_ram_out <= '0';
                    state_1 <= "11";
                    last_state_1 <= "11";
        
                    state_2 <= "11";
                    last_state_2 <= "11";
                    
                    head_1_x <= 6;
                    head_1_y <= 16;
                    
                    head_2_x <= 23;
                    head_2_y <= 16;
                    
                    move_cnt <= 0; 
                    step_cnt <= 0; 
                    move_state <= "0000";
                    
                    death <= "00";
                    death_state <= "0000";
                    death_out <= "00";
                    
                    back_1 <= "00";
                    back_2 <= "00";
                    
                    left_1 <= 5;
                    right_1 <= 7;
                    up_1 <= 15;
                    down_1 <= 17;
                    
                    left_2 <= 22;
                    right_2 <= 24;
                    up_2 <= 15;
                    down_2 <= 17;
                    
                    fill_state <= "000";
                    fill_x <= 0;
                    fill_y <= 0;
                    fill_cnt_x <= 0;
                    fill_cnt_y <= 0;
                    
                    fill_read_write_state <= "000";
                    get_data <= "000000";
                    
                    stack_en <= '0';
                    stack_we <= "1";
                    stack_addr <= (others => '0');
                    stack_write_data <= (others => '0');

                end if;
            else
                if death /= "00" and death_state = "0000" then
                    death_out <= death;
                end if;
            end if;
            
            last_v_valid <= v_valid;
            case game_state is
                when "00" =>
                when "01" =>
                    case internal_state is
                        when "000" => 
                        when "001" => 
                            if v_valid = '0' and last_v_valid = '1' then
                                internal_state <= "010";
                            end if;
                        when "010" => 
                            if state_1 = last_state_1 then
                                case state_1 is
                                    when "00" => if ps2_key = X"23" then state_1 <= "01"; elsif ps2_key = X"1C" then state_1 <= "10"; else state_1 <= state_1; end if;
                                    when "11" => if ps2_key = X"23" then state_1 <= "01"; elsif ps2_key = X"1C" then state_1 <= "10"; else state_1 <= state_1; end if;
                                    when "10" => if ps2_key = X"1D" then state_1 <= "11"; elsif ps2_key = X"1B" then state_1 <= "00"; else state_1 <= state_1; end if;
                                    when "01" => if ps2_key = X"1D" then state_1 <= "11"; elsif ps2_key = X"1B" then state_1 <= "00"; else state_1 <= state_1; end if;
                                    when others => state_1 <= "00";
                                end case;
                            end if;
                            if state_2 = last_state_2 then
                                case state_2 is
                                    when "00" => if ps2_key = X"6a" then state_2 <= "01"; elsif ps2_key = X"61" then state_2 <= "10"; else state_2 <= state_2; end if;
                                    when "11" => if ps2_key = X"6a" then state_2 <= "01"; elsif ps2_key = X"61" then state_2 <= "10"; else state_2 <= state_2; end if;
                                    when "10" => if ps2_key = X"63" then state_2 <= "11"; elsif ps2_key = X"60" then state_2 <= "00"; else state_2 <= state_2; end if;
                                    when "01" => if ps2_key = X"63" then state_2 <= "11"; elsif ps2_key = X"60" then state_2 <= "00"; else state_2 <= state_2; end if;
                                    when others => state_2 <= "00";
                                end case;
                            end if;
                            internal_state <= "011";
                            death <= "00";
                        when "011" => 
                            if step_cnt = 0 then
                                en_ram_out <= '1';
                                wea_out <= "0";
                                
                                case death_state is
                                    when "0000" => death_state <= "0001";
                                        wea_out <= "0";
                                        case last_state_1 is 
                                            when "00" => data_addr <= conv_std_logic_vector(head_1_x*16+(head_1_y*16+16)*480, 18);
                                            when "01" => data_addr <= conv_std_logic_vector(head_1_x*16+16+(head_1_y*16)*480, 18);
                                            when "10" => data_addr <= conv_std_logic_vector(head_1_x*16-1+(head_1_y*16)*480, 18);
                                            when "11" => data_addr <= conv_std_logic_vector(head_1_x*16+(head_1_y*16-1)*480, 18);
                                        end case;
                                    when "0001" => 
                                        case last_state_1 is 
                                            when "00" => if head_1_y = 29 then death <= "10"; death_state <= "1000"; else death_state <= "0010"; end if;
                                            when "01" => if head_1_x = 29 then death <= "10"; death_state <= "1000"; else death_state <= "0010"; end if;
                                            when "10" => if head_1_x =  0 then death <= "10"; death_state <= "1000"; else death_state <= "0010"; end if;
                                            when "11" => if head_1_y =  0 then death <= "10"; death_state <= "1000"; else death_state <= "0010"; end if;
                                        end case;
                                    when "0010" => death_state <= "0011";
                                    when "0011" => death_state <= "0100";
                                    when "0100" => death_state <= "0101";
                                        if read_data(2 downto 0) = "111" then
                                            death <= "01";
                                        elsif read_data(2 downto 1) /= read_data(4 downto 3) then 
                                            if read_data(2 downto 1) = "10" then
                                                death <= "10";  --? 01
                                            elsif read_data(2 downto 1) = "11" then
                                                death <= "01";  --? 10
                                            else
                                                death <= "00";
                                            end if;
                                        else
                                            death <= "00";
                                        end if;
                                    when "0101" => death_state <= "0110";
                                    when "0110" => death_state <= "0111";
                                    when "0111" => death_state <= "1000";
                                    when "1000" => death_state <= "1001";
                                        wea_out <= "0";
                                        case last_state_2 is 
                                            when "00" => data_addr <= conv_std_logic_vector(head_2_x*16+(head_2_y*16+16)*480, 18);
                                            when "01" => data_addr <= conv_std_logic_vector(head_2_x*16+16+(head_2_y*16)*480, 18);
                                            when "10" => data_addr <= conv_std_logic_vector(head_2_x*16-1+(head_2_y*16)*480, 18);
                                            when "11" => data_addr <= conv_std_logic_vector(head_2_x*16+(head_2_y*16-1)*480, 18);
                                            when others =>
                                        end case;
                                    when "1001" => death_state <= "1010";
                                        case last_state_2 is 
                                            when "00" => if head_2_y = 29 then death(0) <= '1'; death_state <= "1111"; else death_state <= "1010"; end if;
                                            when "01" => if head_2_x = 29 then death(0) <= '1'; death_state <= "1111"; else death_state <= "1010"; end if;
                                            when "10" => if head_2_x =  0 then death(0) <= '1'; death_state <= "1111"; else death_state <= "1010"; end if;
                                            when "11" => if head_2_y =  0 then death(0) <= '1'; death_state <= "1111"; else death_state <= "1010"; end if;
                                        end case;
                                    when "1010" => death_state <= "1011";
                                    when "1011" => death_state <= "1100";
                                    when "1100" => death_state <= "1101";
                                        if read_data(2 downto 0) = "101" then
                                            death <= "1" & death(0);
                                        elsif read_data(2 downto 1) /= read_data(4 downto 3) then 
                                            if read_data(2 downto 1) = "10" then
                                                death <= "1" & death(0);
                                            elsif read_data(2 downto 1) = "11" then
                                                death <= death(1) & "1";
                                            end if;
                                        end if;
                                    when "1101" => death_state <= "1110";
                                    when "1110" => death_state <= "1111";
                                    when "1111" => death_state <= "0000";
                                        internal_state <= "100";
                                    when others =>
                                end case;
                            else
                                internal_state <= "100";
                            end if;
                        when "100" => 
                            en_ram_out <= '1';
                            
                            case move_state is
                                when "0000" => move_state <= "0001";
                                    wea_out <= "0";
                                    case last_state_1 is 
                                        when "00" => data_addr <= conv_std_logic_vector(head_1_x*16+move_cnt+(head_1_y*16+step_cnt+16)*480, 18);
                                        when "01" => data_addr <= conv_std_logic_vector(head_1_x*16+step_cnt+16+(head_1_y*16+move_cnt)*480, 18);
                                        when "10" => data_addr <= conv_std_logic_vector(head_1_x*16-step_cnt-1+(head_1_y*16+move_cnt)*480, 18);
                                        when "11" => data_addr <= conv_std_logic_vector(head_1_x*16+move_cnt+(head_1_y*16-step_cnt-1)*480, 18);
                                        when others =>
                                    end case;
                                when "0001" => move_state <= "0010";
                                when "0010" => move_state <= "0011";
                                when "0011" => move_state <= "0100";
                                when "0100" => move_state <= "0101";
                                    wea_out <= "1";
                                    write_data_out <= read_data(5 downto 3) & "101";
                                    if read_data(4 downto 3) = "10" then
                                        back_1(0) <= '1';
                                    else
                                        back_1(0) <= '0';
                                    end if;
                                when "0101" => move_state <= "0110";
                                when "0110" => move_state <= "0111";
                                when "0111" => move_state <= "1000";
                                when "1000" => move_state <= "1001";
                                    wea_out <= "0";
                                    case last_state_1 is 
                                        when "00" => data_addr <= conv_std_logic_vector(head_1_x*16+move_cnt+(head_1_y*16+step_cnt)*480, 18);
                                        when "01" => data_addr <= conv_std_logic_vector(head_1_x*16+step_cnt+(head_1_y*16+move_cnt)*480, 18);
                                        when "10" => data_addr <= conv_std_logic_vector(head_1_x*16-step_cnt+15+(head_1_y*16+move_cnt)*480, 18);
                                        when "11" => data_addr <= conv_std_logic_vector(head_1_x*16+move_cnt+(head_1_y*16-step_cnt+15)*480, 18);
                                        when others =>
                                    end case;
                                when "1001" => move_state <= "1010";
                                when "1010" => move_state <= "1011";
                                when "1011" => move_state <= "1100";
                                when "1100" => move_state <= "1101";
                                    wea_out <= "1";
                                    write_data_out <= read_data(5 downto 3) & "100";
                                    if read_data(4 downto 3) /= "10" then
                                        back_1(1) <= '1';
                                    else
                                        back_1(1) <= '0';
                                    end if;
                                when "1101" => move_state <= "1110";
                                when "1110" => move_state <= "1111";
                                when "1111" => move_state <= "0000";
                                
                                    if move_cnt < 15 then
                                        move_cnt <= move_cnt + 1;
                                    else
                                        move_cnt <= 0;
                                        internal_state <= "101";
                                        if step_cnt = 15 then
                                            last_state_1 <= state_1;
                                            case last_state_1 is 
                                                when "00" =>
                                                    head_1_x <= head_1_x;
                                                    head_1_y <= head_1_y + 1;
                                                    if head_1_y + 1 > down_1 then
                                                        down_1 <= head_1_y + 1;
                                                    end if;
                                                when "01" =>
                                                    head_1_x <= head_1_x + 1;
                                                    head_1_y <= head_1_y;
                                                    if head_1_x + 1 > right_1 then
                                                        right_1 <= head_1_x + 1;
                                                    end if;
                                                when "10" =>
                                                    head_1_x <= head_1_x - 1;
                                                    head_1_y <= head_1_y;
                                                    if head_1_x - 1 < left_1 then
                                                        left_1 <= head_1_x - 1;
                                                    end if;
                                                when "11" =>
                                                    head_1_x <= head_1_x;
                                                    head_1_y <= head_1_y - 1;
                                                    if head_1_y - 1 < up_1 then
                                                        up_1 <= head_1_y - 1;
                                                    end if;
                                                when others =>
                                            end case;
                                        end if;
                                    end if;
                                when others =>
                            end case;
                        when "101" => 
                            en_ram_out <= '1';
                            
                            case move_state is
                                when "0000" => move_state <= "0001";
                                    wea_out <= "0";
                                    case last_state_2 is 
                                        when "00" => data_addr <= conv_std_logic_vector(head_2_x*16+move_cnt+(head_2_y*16+step_cnt+16)*480, 18);
                                        when "01" => data_addr <= conv_std_logic_vector(head_2_x*16+step_cnt+16+(head_2_y*16+move_cnt)*480, 18);
                                        when "10" => data_addr <= conv_std_logic_vector(head_2_x*16-step_cnt-1+(head_2_y*16+move_cnt)*480, 18);
                                        when "11" => data_addr <= conv_std_logic_vector(head_2_x*16+move_cnt+(head_2_y*16-step_cnt-1)*480, 18);
                                        when others =>
                                    end case;
                                when "0001" => move_state <= "0010";
                                when "0010" => move_state <= "0011";
                                when "0011" => move_state <= "0100";
                                when "0100" => move_state <= "0101";
                                    wea_out <= "1";
                                    write_data_out <= read_data(5 downto 3) & "111";
                                    if read_data(4 downto 3) = "11" then
                                        back_2(0) <= '1';
                                    else
                                        back_2(0) <= '0';
                                    end if;
                                when "0101" => move_state <= "0110";
                                when "0110" => move_state <= "0111";
                                when "0111" => move_state <= "1000";
                                when "1000" => move_state <= "1001";
                                    wea_out <= "0";
                                    case last_state_2 is 
                                        when "00" => data_addr <= conv_std_logic_vector(head_2_x*16+move_cnt+(head_2_y*16+step_cnt)*480, 18);
                                        when "01" => data_addr <= conv_std_logic_vector(head_2_x*16+step_cnt+(head_2_y*16+move_cnt)*480, 18);
                                        when "10" => data_addr <= conv_std_logic_vector(head_2_x*16-step_cnt+15+(head_2_y*16+move_cnt)*480, 18);
                                        when "11" => data_addr <= conv_std_logic_vector(head_2_x*16+move_cnt+(head_2_y*16-step_cnt+15)*480, 18);
                                        when others =>
                                    end case;
                                when "1001" => move_state <= "1010";
                                when "1010" => move_state <= "1011";
                                when "1011" => move_state <= "1100";
                                when "1100" => move_state <= "1101";
                                    wea_out <= "1";
                                    write_data_out <= read_data(5 downto 3) & "110";
                                    if read_data(4 downto 3) /= "11" then
                                        back_2(1) <= '1';
                                    else
                                        back_2(1) <= '0';
                                    end if;
                                when "1101" => move_state <= "1110";
                                when "1110" => move_state <= "1111";
                                when "1111" => move_state <= "0000";
                           
                                    if move_cnt < 15 then
                                        move_cnt <= move_cnt + 1;
                                    else
                                        move_cnt <= 0;
                                        internal_state <= "110";
                                        if step_cnt < 15 then
                                            step_cnt <= step_cnt + 1;
                                        else
                                            last_state_2 <= state_2;
                                            step_cnt <= 0;
                                            case last_state_2 is 
                                                when "00" =>
                                                    head_2_x <= head_2_x;
                                                    head_2_y <= head_2_y + 1;
                                                    if head_2_y + 1 > down_2 then
                                                        down_2 <= head_2_y + 1;
                                                    end if;
                                                when "01" =>
                                                    head_2_x <= head_2_x + 1;
                                                    head_2_y <= head_2_y;
                                                    if head_2_x + 1 > right_2 then
                                                        right_2 <= head_2_x + 1;
                                                    end if;
                                                when "10" =>
                                                    head_2_x <= head_2_x - 1;
                                                    head_2_y <= head_2_y;
                                                    if head_2_x - 1 < left_2 then
                                                        left_2 <= head_2_x - 1;
                                                    end if;
                                                when "11" =>
                                                    head_2_x <= head_2_x;
                                                    head_2_y <= head_2_y - 1;
                                                    if head_2_y - 1 < up_2 then
                                                        up_2 <= head_2_y - 1;
                                                    end if;
                                                when others =>
                                            end case;
                                        end if;
                                    end if;
                                when others =>
                            end case;
                        when "110" => 
                            if step_cnt = 0 and back_1 = "11" then
                                case fill_state is
                                    when "000" => -- prepare for fill band 1
                                        fill_state <= "001";
                                        fill_x <= left_1;
                                        fill_y <= up_1;
                                        fill_cnt_x <= 0;
                                        fill_cnt_y <= 0;
                                        fill_read_write_state <= "000";
                                    when "001" => -- fill band 1
                                        case fill_read_write_state is
                                            when "000" => fill_read_write_state <= "001";
                                                en_ram_out <= '1';
                                                wea_out <= "0";
                                                data_addr <= conv_std_logic_vector(fill_x*16+(fill_y*16)*480, 18);
                                            when "001" => fill_read_write_state <= "010";
                                            when "010" => fill_read_write_state <= "011";
                                            when "011" => fill_read_write_state <= "100";
                                                get_data <= read_data;
                                            when "100" => fill_read_write_state <= "101";
                                                if get_data(4 downto 3) /= "10" and get_data(2 downto 0) = "100" then
                                                    en_ram_out <= '1';
                                                    wea_out <= "1";
                                                    write_data_out <= "010000";
                                                    data_addr <= conv_std_logic_vector(fill_x*16+fill_cnt_x+(fill_y*16+fill_cnt_y)*480, 18);
                                                end if;
                                            when "101" => fill_read_write_state <= "110";
                                            when "110" => fill_read_write_state <= "111";
                                            when "111" => 
                                                if get_data(4 downto 3) /= "10" and get_data(2 downto 0) = "100" then
                                                    if fill_cnt_x < 15 then
                                                        fill_cnt_x <= fill_cnt_x + 1;
                                                        fill_read_write_state <= "100";
                                                    else
                                                        fill_cnt_x <= 0;
                                                        if fill_cnt_y < 15 then
                                                            fill_cnt_y <= fill_cnt_y + 1;
                                                            fill_read_write_state <= "100";
                                                        else
                                                            fill_cnt_y <= 0;
                                                            fill_read_write_state <= "000";
                                                            if fill_x < right_1 then
                                                                fill_x <= fill_x + 1;
                                                            else
                                                                fill_x <= left_1;
                                                                if fill_y < down_1 then
                                                                    fill_y <= fill_y + 1;
                                                                else
                                                                    fill_state <= "010";
                                                                end if;
                                                            end if;
                                                        end if;
                                                    end if;
                                                else
                                                    if fill_x < right_1 then
                                                        fill_x <= fill_x + 1;
                                                    else
                                                        fill_x <= left_1;
                                                        if fill_y < down_1 then
                                                            fill_y <= fill_y + 1;
                                                        else
                                                            fill_state <= "010";
                                                        end if;
                                                    end if;
                                                    fill_read_write_state <= "000";
                                                end if;
                                        end case;
                                    when "010" => -- prepare for row dfs
                                        fill_state <= "011";
                                        stack_en <= '1';
                                        stack_we <= "0";
                                        stack_size <= 0;
                                        dfs_state <= "0000";
                                        dfs_x <= left_1;
                                        dfs_y <= up_1;
                                        dfs_direction <= "00";
                                        fill_read_write_state <= "000";
                                    when "011" => -- row dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_1 + 1 and dfs_x = left_1 then -- prepare for col dfs
                                                    fill_state <= "100";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_1;
                                                    dfs_y <= up_1 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "1" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_x < right_1 then
                                                                dfs_x <= dfs_x + 1;
                                                            else
                                                                dfs_x <= left_1;
                                                                if dfs_y = up_1 then
                                                                    dfs_y <= down_1;
                                                                else
                                                                    dfs_y <= up_1 + 1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "100" => -- col dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_1 and dfs_x = left_1 then -- prepare for all dfs
                                                    fill_state <= "101";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_1 + 1;
                                                    dfs_y <= up_1 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "1" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_y < down_1 - 1 then
                                                                dfs_y <= dfs_y + 1;
                                                            else
                                                                if dfs_x = left_1 then
                                                                    dfs_x <= right_1;
                                                                    dfs_y <= up_1 + 1;
                                                                else
                                                                    dfs_x <= left_1;
                                                                    dfs_y <= up_1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "101" => -- all dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_1 and dfs_x = left_1 then -- prepare for withdraw
                                                    fill_state <= "110";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_1;
                                                    dfs_y <= up_1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                            if read_data(5) = '0' and read_data(4 downto 3) /= "10" then
                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                if get_data(4 downto 3) = "11" and get_data(2 downto 0) /= "111" then
                                                                    write_data_out <= "010000";
                                                                else
                                                                    write_data_out <= "010" & get_data(2 downto 0);
                                                                end if;
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+fill_cnt_x+(dfs_y*16+fill_cnt_y)*480, 18);
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => 
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                if fill_cnt_x < 15 then
                                                                    fill_cnt_x <= fill_cnt_x + 1;
                                                                    fill_read_write_state <= "100";
                                                                else
                                                                    fill_cnt_x <= 0;
                                                                    if fill_cnt_y < 15 then
                                                                        fill_cnt_y <= fill_cnt_y + 1;
                                                                        fill_read_write_state <= "100";
                                                                    else
                                                                        fill_cnt_y <= 0;
                                                                        fill_read_write_state <= "000";
                                                                        if dfs_x < right_1 - 1 then
                                                                            dfs_x <= dfs_x + 1;
                                                                        else
                                                                            if dfs_y < down_1 - 1 then
                                                                                dfs_y <= dfs_y + 1;
                                                                                dfs_x <= left_1 + 1;
                                                                            else
                                                                                dfs_y <= up_1;
                                                                                dfs_x <= left_1;
                                                                            end if;
                                                                        end if;
                                                                    end if;
                                                                end if;
                                                                if fill_cnt_x = 15 and fill_cnt_y = 15 then
                                                                    dfs_state <= "0001";
                                                                end if;
                                                            else
                                                                if dfs_x < right_1 - 1 then
                                                                    dfs_x <= dfs_x + 1;
                                                                else
                                                                    if dfs_y < down_1 - 1 then
                                                                        dfs_y <= dfs_y + 1;
                                                                        dfs_x <= left_1 + 1;
                                                                    else
                                                                        dfs_y <= up_1;
                                                                        dfs_x <= left_1;
                                                                    end if;
                                                                end if;
                                                                dfs_state <= "0000";
                                                                fill_read_write_state <= "000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "10" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "11" and get_data(2 downto 0) /= "111" then
                                                                            write_data_out <= "010000";
                                                                        else
                                                                            write_data_out <= "010" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+fill_cnt_x+((cur_y+1)*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "01";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "01";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "10" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "11" and get_data(2 downto 0) /= "111" then
                                                                            write_data_out <= "010000";
                                                                        else
                                                                            write_data_out <= "010" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+fill_cnt_x+(cur_y*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "10";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "10";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "10" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "11" and get_data(2 downto 0) /= "111" then
                                                                            write_data_out <= "010000";
                                                                        else
                                                                            write_data_out <= "010" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+fill_cnt_x+(cur_y*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "11";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "11";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "10" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "11" and get_data(2 downto 0) /= "111" then
                                                                            write_data_out <= "010000";
                                                                        else
                                                                            write_data_out <= "010" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+fill_cnt_x+((cur_y-1)*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "10" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "00";
                                                                                dfs_state <= "0001";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "00";
                                                                        dfs_state <= "0001";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "110" => -- withdraw row
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_1 + 1 and dfs_x = left_1 then -- prepare for col withdraw
                                                    fill_state <= "111";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_1;
                                                    dfs_y <= up_1 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '1' then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "0" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_x < right_1 then
                                                                dfs_x <= dfs_x + 1;
                                                            else
                                                                dfs_x <= left_1;
                                                                if dfs_y = up_1 then
                                                                    dfs_y <= down_1;
                                                                else
                                                                    dfs_y <= up_1 + 1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '1' then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "111" => -- withdraw col
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_1 and dfs_x = left_1 then
                                                    fill_state <= "000";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_1;
                                                    dfs_y <= up_1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                    internal_state <= "111";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '1' then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "0" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_y < down_1 - 1 then
                                                                dfs_y <= dfs_y + 1;
                                                            else
                                                                if dfs_x = left_1 then
                                                                    dfs_x <= right_1;
                                                                    dfs_y <= up_1 + 1;
                                                                else
                                                                    dfs_x <= left_1;
                                                                    dfs_y <= up_1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '1' then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_1 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                end case;
                            else
                                internal_state <= "111";
                                fill_state <= "000";
                            end if;
                        when "111" => 
                            if step_cnt = 0 and back_2 = "11" then
                                case fill_state is
                                    when "000" => -- prepare for fill band 1
                                        fill_state <= "001";
                                        fill_x <= left_2;
                                        fill_y <= up_2;
                                        fill_cnt_x <= 0;
                                        fill_cnt_y <= 0;
                                        fill_read_write_state <= "000";
                                    when "001" => -- fill band 2
                                        case fill_read_write_state is
                                            when "000" => fill_read_write_state <= "001";
                                                en_ram_out <= '1';
                                                wea_out <= "0";
                                                data_addr <= conv_std_logic_vector(fill_x*16+(fill_y*16)*480, 18);
                                            when "001" => fill_read_write_state <= "010";
                                            when "010" => fill_read_write_state <= "011";
                                            when "011" => fill_read_write_state <= "100";
                                                get_data <= read_data;
                                            when "100" => fill_read_write_state <= "101";
                                                if get_data(4 downto 3) /= "11" and get_data(2 downto 0) = "110" then
                                                    en_ram_out <= '1';
                                                    wea_out <= "1";
                                                    write_data_out <= "011000";
                                                    data_addr <= conv_std_logic_vector(fill_x*16+fill_cnt_x+(fill_y*16+fill_cnt_y)*480, 18);
                                                end if;
                                            when "101" => fill_read_write_state <= "110";
                                            when "110" => fill_read_write_state <= "111";
                                            when "111" => 
                                                if get_data(4 downto 3) /= "11" and get_data(2 downto 0) = "110" then
                                                    if fill_cnt_x < 15 then
                                                        fill_cnt_x <= fill_cnt_x + 1;
                                                        fill_read_write_state <= "100";
                                                    else
                                                        fill_cnt_x <= 0;
                                                        if fill_cnt_y < 15 then
                                                            fill_cnt_y <= fill_cnt_y + 1;
                                                            fill_read_write_state <= "100";
                                                        else
                                                            fill_cnt_y <= 0;
                                                            fill_read_write_state <= "000";
                                                            if fill_x < right_2 then
                                                                fill_x <= fill_x + 1;
                                                            else
                                                                fill_x <= left_2;
                                                                if fill_y < down_2 then
                                                                    fill_y <= fill_y + 1;
                                                                else
                                                                    fill_state <= "010";
                                                                end if;
                                                            end if;
                                                        end if;
                                                    end if;
                                                else
                                                    if fill_x < right_2 then
                                                        fill_x <= fill_x + 1;
                                                    else
                                                        fill_x <= left_2;
                                                        if fill_y < down_2 then
                                                            fill_y <= fill_y + 1;
                                                        else
                                                            fill_state <= "010";
                                                        end if;
                                                    end if;
                                                    fill_read_write_state <= "000";
                                                end if;
                                        end case;
                                    when "010" => -- prepare for row dfs
                                        fill_state <= "011";
                                        stack_en <= '1';
                                        stack_we <= "0";
                                        stack_size <= 0;
                                        dfs_state <= "0000";
                                        dfs_x <= left_2;
                                        dfs_y <= up_2;
                                        dfs_direction <= "00";
                                        fill_read_write_state <= "000";
                                    when "011" => -- row dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_2 + 1 and dfs_x = left_2 then -- prepare for col dfs
                                                    fill_state <= "100";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_2;
                                                    dfs_y <= up_2 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "1" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_x < right_2 then
                                                                dfs_x <= dfs_x + 1;
                                                            else
                                                                dfs_x <= left_2;
                                                                if dfs_y = up_2 then
                                                                    dfs_y <= down_2;
                                                                else
                                                                    dfs_y <= up_2 + 1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "100" => -- col dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_2 and dfs_x = left_2 then -- prepare for all dfs
                                                    fill_state <= "101";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_2 + 1;
                                                    dfs_y <= up_2 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "1" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_y < down_2 - 1 then
                                                                dfs_y <= dfs_y + 1;
                                                            else
                                                                if dfs_x = left_2 then
                                                                    dfs_x <= right_2;
                                                                    dfs_y <= up_2 + 1;
                                                                else
                                                                    dfs_x <= left_2;
                                                                    dfs_y <= up_2;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "1" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "101" => -- all dfs
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_2 and dfs_x = left_2 then -- prepare for withdraw
                                                    fill_state <= "110";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_2;
                                                    dfs_y <= up_2;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                            if read_data(5) = '0' and read_data(4 downto 3) /= "11" then
                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                if get_data(4 downto 3) = "10" and get_data(2 downto 0) /= "101" then
                                                                    write_data_out <= "011000";
                                                                else
                                                                    write_data_out <= "011" & get_data(2 downto 0);
                                                                end if;
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+fill_cnt_x+(dfs_y*16+fill_cnt_y)*480, 18);
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => 
                                                            if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                if fill_cnt_x < 15 then
                                                                    fill_cnt_x <= fill_cnt_x + 1;
                                                                    fill_read_write_state <= "100";
                                                                else
                                                                    fill_cnt_x <= 0;
                                                                    if fill_cnt_y < 15 then
                                                                        fill_cnt_y <= fill_cnt_y + 1;
                                                                        fill_read_write_state <= "100";
                                                                    else
                                                                        fill_cnt_y <= 0;
                                                                        fill_read_write_state <= "000";
                                                                        if dfs_x < right_2 - 1 then
                                                                            dfs_x <= dfs_x + 1;
                                                                        else
                                                                            if dfs_y < down_2 - 1 then
                                                                                dfs_y <= dfs_y + 1;
                                                                                dfs_x <= left_2 + 1;
                                                                            else
                                                                                dfs_y <= up_2;
                                                                                dfs_x <= left_2;
                                                                            end if;
                                                                        end if;
                                                                    end if;
                                                                end if;
                                                                if fill_cnt_x = 15 and fill_cnt_y = 15 then
                                                                    dfs_state <= "0001";
                                                                end if;
                                                            else
                                                                if dfs_x < right_2 - 1 then
                                                                    dfs_x <= dfs_x + 1;
                                                                else
                                                                    if dfs_y < down_2 - 1 then
                                                                        dfs_y <= dfs_y + 1;
                                                                        dfs_x <= left_2 + 1;
                                                                    else
                                                                        dfs_y <= up_2;
                                                                        dfs_x <= left_2;
                                                                    end if;
                                                                end if;
                                                                dfs_state <= "0000";
                                                                fill_read_write_state <= "000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "11" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "10" and get_data(2 downto 0) /= "101" then
                                                                            write_data_out <= "011000";
                                                                        else
                                                                            write_data_out <= "011" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+fill_cnt_x+((cur_y+1)*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "01";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "01";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "11" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "10" and get_data(2 downto 0) /= "101" then
                                                                            write_data_out <= "011000";
                                                                        else
                                                                            write_data_out <= "011" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+fill_cnt_x+(cur_y*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "10";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "10";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "11" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "10" and get_data(2 downto 0) /= "101" then
                                                                            write_data_out <= "011000";
                                                                        else
                                                                            write_data_out <= "011" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+fill_cnt_x+(cur_y*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "11";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "11";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                    if read_data(5) = '0' and read_data(4 downto 3) /= "11" then
                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        if get_data(4 downto 3) = "10" and get_data(2 downto 0) /= "101" then
                                                                            write_data_out <= "011000";
                                                                        else
                                                                            write_data_out <= "011" & get_data(2 downto 0);
                                                                        end if;
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+fill_cnt_x+((cur_y-1)*16+fill_cnt_y)*480, 18);
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" =>
                                                                    if get_data(5) = '0' and get_data(4 downto 3) /= "11" then
                                                                        if fill_cnt_x < 15 then
                                                                            fill_cnt_x <= fill_cnt_x + 1;
                                                                            fill_read_write_state <= "100";
                                                                        else
                                                                            fill_cnt_x <= 0;
                                                                            if fill_cnt_y < 15 then
                                                                                fill_cnt_y <= fill_cnt_y + 1;
                                                                                fill_read_write_state <= "100";
                                                                            else
                                                                                fill_cnt_y <= 0;
                                                                                fill_read_write_state <= "000";
                                                                                dfs_direction <= "00";
                                                                                dfs_state <= "0001";
                                                                            end if;
                                                                        end if;
                                                                    else
                                                                        fill_read_write_state <= "000";
                                                                        dfs_direction <= "00";
                                                                        dfs_state <= "0001";
                                                                    end if;
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "110" => -- withdraw row
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_2 + 1 and dfs_x = left_2 then -- prepare for col withdraw
                                                    fill_state <= "111";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_2;
                                                    dfs_y <= up_2 + 1;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '1'then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "0" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_x < right_2 then
                                                                dfs_x <= dfs_x + 1;
                                                            else
                                                                dfs_x <= left_2;
                                                                if dfs_y = up_2 then
                                                                    dfs_y <= down_2;
                                                                else
                                                                    dfs_y <= up_2 + 1;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '1'then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                    when "111" => -- withdraw col
                                        case dfs_state is
                                            when "0000" => -- first push
                                                if dfs_y = up_2 and dfs_x = left_2 then
                                                    fill_state <= "000";
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_size <= 0;
                                                    dfs_state <= "0000";
                                                    dfs_x <= left_2;
                                                    dfs_y <= up_2;
                                                    dfs_direction <= "00";
                                                    fill_read_write_state <= "000";
                                                    fill_cnt_x <= 0;
                                                    fill_cnt_y <= 0;
                                                    internal_state <= "001";
                                                else
                                                    case fill_read_write_state is 
                                                        when "000" => fill_read_write_state <= "001";
                                                            en_ram_out <= '1';
                                                            wea_out <= "0";
                                                            data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);
                                                        when "001" => fill_read_write_state <= "010";
                                                        when "010" => fill_read_write_state <= "011";
                                                        when "011" => fill_read_write_state <= "100";
                                                            get_data <= read_data;
                                                        when "100" => fill_read_write_state <= "101";
                                                            if get_data(5) = '1' then
                                                                en_ram_out <= '1';
                                                                wea_out <= "1";
                                                                write_data_out <= "0" & get_data(4 downto 0);
                                                                data_addr <= conv_std_logic_vector(dfs_x*16+(dfs_y*16)*480, 18);

                                                                stack_en <= '1';
                                                                stack_we <= "1";
                                                                stack_write_data <= conv_std_logic_vector(dfs_x, 5) & conv_std_logic_vector(dfs_y, 5);
                                                                stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                stack_size <= stack_size + 1;
                                                            end if;
                                                        when "101" => fill_read_write_state <= "110";
                                                        when "110" => fill_read_write_state <= "111";
                                                        when "111" => fill_read_write_state <= "000";
                                                            if dfs_y < down_2 - 1 then
                                                                dfs_y <= dfs_y + 1;
                                                            else
                                                                if dfs_x = left_2 then
                                                                    dfs_x <= right_2;
                                                                    dfs_y <= up_2 + 1;
                                                                else
                                                                    dfs_x <= left_2;
                                                                    dfs_y <= up_2;
                                                                end if;
                                                            end if;
                                                            if get_data(5) = '1' then
                                                                dfs_state <= "0001";
                                                            else
                                                                dfs_state <= "0000";
                                                            end if;
                                                    end case;
                                                end if;

                                            when "0001" => -- pop
                                                if stack_size = 0 then
                                                    dfs_state <= "0110";
                                                else
                                                    stack_en <= '1';
                                                    stack_we <= "0";
                                                    stack_addr <= conv_std_logic_vector(stack_size-1, 10);
                                                    stack_size <= stack_size - 1;
                                                    dfs_state <= "0010";
                                                end if;
                                            when "0010" => dfs_state <= "0011";
                                            when "0011" => dfs_state <= "0100";
                                            when "0100" => dfs_state <= "0101"; -- get pop data
                                                cur_x <= conv_integer(unsigned(stack_read_data(9 downto 5)));
                                                cur_y <= conv_integer(unsigned(stack_read_data(4 downto 0)));
                                            when "0101" => -- push 
                                                case dfs_direction is
                                                    when "00" =>
                                                        if cur_y + 1 <= down_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y+1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y+1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "01";
                                                            end case;
                                                        else
                                                            dfs_direction <= "01";
                                                        end if;
                                                    when "01" =>
                                                        if cur_x + 1 <= right_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x+1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x+1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "10";
                                                            end case;
                                                        else
                                                            dfs_direction <= "10";
                                                        end if;
                                                    when "10" =>
                                                        if cur_x - 1 >= left_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector((cur_x-1)*16+(cur_y*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x-1, 5) & conv_std_logic_vector(cur_y, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "11";
                                                            end case;
                                                        else
                                                            dfs_direction <= "11";
                                                        end if;
                                                    when "11" =>
                                                        if cur_y - 1 >= up_2 then
                                                            case fill_read_write_state is
                                                                when "000" => fill_read_write_state <= "001";
                                                                    en_ram_out <= '1';
                                                                    wea_out <= "0";
                                                                    data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);
                                                                when "001" => fill_read_write_state <= "010";
                                                                when "010" => fill_read_write_state <= "011";
                                                                when "011" => fill_read_write_state <= "100";
                                                                    get_data <= read_data;
                                                                when "100" => fill_read_write_state <= "101";
                                                                    if get_data(5) = '1' then
                                                                        en_ram_out <= '1';
                                                                        wea_out <= "1";
                                                                        write_data_out <= "0" & get_data(4 downto 0);
                                                                        data_addr <= conv_std_logic_vector(cur_x*16+((cur_y-1)*16)*480, 18);

                                                                        stack_en <= '1';
                                                                        stack_we <= "1";
                                                                        stack_write_data <= conv_std_logic_vector(cur_x, 5) & conv_std_logic_vector(cur_y-1, 5);
                                                                        stack_addr <= conv_std_logic_vector(stack_size, 10);
                                                                        stack_size <= stack_size + 1;
                                                                    end if;
                                                                when "101" => fill_read_write_state <= "110";
                                                                when "110" => fill_read_write_state <= "111";
                                                                when "111" => fill_read_write_state <= "000";
                                                                    dfs_direction <= "00";
                                                                    dfs_state <= "0001";
                                                            end case;
                                                        else
                                                            dfs_direction <= "00";
                                                            dfs_state <= "0001";
                                                        end if;
                                                end case;
                                            when "0110" => dfs_state <= "0111";
                                            when "0111" => dfs_state <= "0000";

                                            when "1000" => dfs_state <= "1001";
                                            when "1001" => dfs_state <= "1010";
                                            when "1010" => dfs_state <= "1011";
                                            when "1011" => dfs_state <= "1100";
                                            when "1100" => dfs_state <= "1101";
                                            when "1101" => dfs_state <= "1110";
                                            when "1110" => dfs_state <= "1111";
                                            when "1111" => dfs_state <= "0000";
                                            when others =>
                                        end case;
                                end case;
                            else
                                internal_state <= "001";
                                fill_state <= "000";
                            end if;
                        when others =>
                    end case;
                when "10" => 
                when "11" =>
                when others =>
            end case;
            
        end if;
    end process;

    data_addr_out <= data_addr;
    internal_state_out <= internal_state;
    u_stack : blk_mem_gen_3
      PORT MAP (
        clka => clk,
        ena => stack_en,
        wea => stack_we,
        addra => stack_addr,
        dina => stack_write_data,
        douta => stack_read_data
      );
end Behavioral;