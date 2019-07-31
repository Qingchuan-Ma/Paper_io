----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/07/19 16:03:28
-- Design Name: 
-- Module Name: top_struct - Behavioral
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

entity top_struct is
    Port ( vga_r_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_g_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_b_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_hs_pin: out STD_LOGIC;
           vga_vs_pin: out STD_LOGIC;
           led_pin: out STD_LOGIC_VECTOR (15 DOWNTO 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ps2_clk : in STD_LOGIC;
           ps2_data : in STD_LOGIC;
           audio_pwm_o : out STD_LOGIC;
           audio_sd_o : out STD_LOGIC;
           btn_pin: in STD_LOGIC_VECTOR (4 DOWNTO 0)
           );
end top_struct;

architecture Behavioral of top_struct is
    component ps2 is
        Port ( clk : in STD_LOGIC;
               rst_n : in STD_LOGIC;
               ps2_clk : in STD_LOGIC;
               ps2_data : in STD_LOGIC;
               led_pin : out STD_LOGIC_VECTOR(7 DOWNTO 0);
               ps2_key : out STD_LOGIC_VECTOR(7 DOWNTO 0)
               );
    end component;
    --------------------------------------------------
    component music is
          Port (clk : in STD_LOGIC;
                rst_n : in STD_LOGIC;
                game_state : in STD_LOGIC_VECTOR (1 downto 0);
                btn_amp : in STD_LOGIC_VECTOR (7 downto 0);
                audio_pwm_o : out STD_LOGIC;
                audio_sd_o : out STD_LOGIC
           );
    end component;
    --------------------------------------------
    component clk_wiz_0 is
      Port ( 
        clk_out1 : out STD_LOGIC;
        resetn : in STD_LOGIC;
        clk_in1 : in STD_LOGIC
      );
    end component;
    -------------------------------------------
    component vga_timing is
    port(
        pclk: in std_logic;
        reset: in std_logic;
        hsync: out std_logic;
        vsync: out std_logic;
        valid: out std_logic;
        v_valid_out: out std_logic;
        h_cnt: out STD_LOGIC_VECTOR(9 downto 0);
        v_cnt: out STD_LOGIC_VECTOR(9 downto 0));
    end component;   
    -------------------------------------------
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
      );
    END COMPONENT;
    -------------------------------------------
    COMPONENT blk_mem_gen_1
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
    END COMPONENT;
    -------------------------------------------
    component display is
    Port ( 
           clk_25m : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           h_cnt : in STD_LOGIC_VECTOR (9 DOWNTO 0);
           v_cnt : in STD_LOGIC_VECTOR (9 DOWNTO 0);
           valid: in std_logic;
           dina : in STD_LOGIC_VECTOR (5 DOWNTO 0);
           dinb : in STD_LOGIC_VECTOR (0 DOWNTO 0);
           addra : out STD_LOGIC_VECTOR (17 DOWNTO 0);
           addrb : out STD_LOGIC_VECTOR (15 DOWNTO 0);
           vga_r_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_g_pin : out STD_LOGIC_VECTOR (3 downto 0);
           vga_b_pin : out STD_LOGIC_VECTOR (3 downto 0);
           game_state : in STD_LOGIC_VECTOR (1 downto 0);
           death_in : in STD_LOGIC_VECTOR (1 DOWNTO 0)
           );
    end component;
    ------------------------------------------
    component game_control is
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
    end component;
    ---------------------------------------------------------
    component game_state_ctrl is
    Port ( clk: in std_logic;
           rst_n: in std_logic;
           ps2_key : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           death_sig: in std_logic_vector(1 downto 0);
           game_state: out std_logic_vector(1 downto 0);
           game_reset: out std_logic
     );
    end component;
    -----------------------------------------------------------
    signal clk_25m : STD_LOGIC := '0';
    signal valid : STD_LOGIC := '0';
    signal ena : STD_LOGIC;
    signal h_cnt: STD_LOGIC_VECTOR(9 downto 0);
    signal v_cnt: STD_LOGIC_VECTOR(9 downto 0);
    signal addrb: std_logic_vector(17 downto 0);
    signal doutb: std_logic_vector(5 downto 0);
    signal addra: std_logic_vector(17 downto 0);
    signal addr_rom: std_logic_vector(15 downto 0);
    signal douta: std_logic_vector(5 downto 0);
    signal dout_rom : STD_LOGIC_VECTOR(0 downto 0);
    signal wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal ps2_key : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    
    
    signal dina: std_logic_vector(5 downto 0);
    signal v_valid: std_logic;
    signal game_state: std_logic_vector(1 downto 0);
    signal internal_state: std_logic_vector(2 downto 0);
    signal step_cnt: std_logic_vector(3 downto 0);
    signal death_out : std_logic_vector(1 downto 0);
    signal game_reset : std_logic; 
begin

    input: ps2 port map(
            clk => clk,
            rst_n => rst_n,
            ps2_clk => ps2_clk,
            ps2_data => ps2_data,
            led_pin => led_pin(7 downto 0),
            ps2_key => ps2_key
            );
            
    start: clk_wiz_0 port map
                        ( clk_out1 => clk_25m,
                          resetn => rst_n,
                          clk_in1 => clk
                          );
    
    mid: vga_timing port map
                        ( pclk => clk_25m,
                          reset => rst_n,
                          hsync => vga_hs_pin,
                          vsync => vga_vs_pin,
                          valid => valid,
                          v_valid_out => v_valid,
                          h_cnt => h_cnt,
                          v_cnt => v_cnt
                          );
                 
    read : blk_mem_gen_0
                      PORT MAP (
                        clka => clk,
                        ena => ena,
                        wea => wea,
                        dina => dina,
                        addra => addra,
                        douta => douta,
                        clkb => clk_25m,
                        enb => '1',
                        web => "0",
                        dinb => "000000",
                        addrb => addrb,
                        doutb => doutb
                      );
    
    last: display port map(
                        clk_25m => clk_25m,
                        rst_n => rst_n,
                        h_cnt => h_cnt,
                        v_cnt => v_cnt,
                        valid => valid,
                        dina => doutb,
                        dinb => dout_rom,
                        addra => addrb,
                        addrb => addr_rom,
                        vga_r_pin => vga_r_pin,
                        vga_g_pin => vga_g_pin,
                        vga_b_pin => vga_b_pin,
                        game_state => game_state,
                        death_in => death_out
                        );
                        
    play : music port map(
                        clk => clk,
                        rst_n => rst_n,
                        game_state=> game_state,
                        btn_amp => ps2_key,
                        audio_pwm_o => audio_pwm_o,
                        audio_sd_o => audio_sd_o
                        );
                        
    score : blk_mem_gen_1
                      PORT MAP (
                        clka => clk_25m,
                        ena => '1',
                        addra => addr_rom,
                        douta => dout_rom
                      );
                      
    u_game_control: game_control port map(
            clk => clk,
            rst_n => rst_n,
            v_valid => v_valid,
            btn_pin => btn_pin,
            ps2_key => ps2_key,
            read_data => douta,
            data_addr_out => addra,
            write_data_out => dina,
            wea_out => wea,
            en_ram_out => ena,
            game_state => game_state,
            game_reset => game_reset,
            death_out => death_out,
            
           internal_state_out => led_pin(15 downto 13)
           );
           
    u_game_state_ctrl: game_state_ctrl port map(
            clk => clk,
            rst_n => rst_n,
            ps2_key => ps2_key,
            death_sig => death_out,
            game_state => game_state,
            game_reset => game_reset
            );

     led_pin(9 downto 8) <= game_state;   
     led_pin(11 downto 10) <= death_out;
end Behavioral;