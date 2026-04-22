----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 05:39:01 PM
-- Design Name: 
-- Module Name: datapath_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;


entity datapath_tb is
end datapath_tb;

architecture Behavioral of datapath_tb is

constant clk_period : time:= 10ns;

signal clk               : std_logic := '0';
signal rst               : std_logic := '0';
signal h_weight_in       : std_logic_vector(7 downto 0) := (others => '0');
signal o_weight_in       : std_logic_vector(7 downto 0) := (others => '0');
signal image_in          : std_logic_vector(7 downto 0) := (others => '0');
signal output_digit      : std_logic_vector(3 downto 0);

-- Control Signals
signal leak              : std_logic := '0';
signal spikegen_go       : std_logic := '0';
signal fifo_rd           : std_logic := '0';
signal init_w            : std_logic := '0';
signal init_img          : std_logic := '0';
-- RAM Write Enables
signal output_weights_we : std_logic := '0';
signal hidden_weights_we : std_logic := '0';
signal hidden_neurons_we : std_logic := '0';
signal output_neurons_we : std_logic := '0';
signal image_we          : std_logic := '0';

-- Counter Enables
signal en_chw           : std_logic := '0';
signal en_cow           : std_logic := '0';
signal en_pid           : std_logic := '0';
-- Digit Counter Enables
signal en_cd0            : std_logic := '0';
signal en_cd1            : std_logic := '0';
signal en_cd2            : std_logic := '0';
signal en_cd3            : std_logic := '0';
signal en_cd4            : std_logic := '0';
signal en_cd5            : std_logic := '0';
signal en_cd6            : std_logic := '0';
signal en_cd7            : std_logic := '0';
signal en_cd8            : std_logic := '0';
signal en_cd9            : std_logic := '0';

-- Output Flags
signal fifo_full         : std_logic;
signal fifo_empty        : std_logic;
signal neuron_spike      : std_logic;


--- Testbench specific controls --- 
signal init_done : std_logic  := '0';
signal img_done :  std_logic  := '0';  

begin
    
    dut: entity work.datapath
    port map(
        clk               => clk,
        rst               => rst,
        h_weight_in       => h_weight_in,
        o_weight_in       => o_weight_in,
        image_in          => image_in,
        output_digit      => output_digit,
        leak              => leak,
        spikegen_go       => spikegen_go,
        fifo_rd           => fifo_rd,     
        -- RAM Write Enables
        hidden_weights_we => hidden_weights_we,
        output_weights_we => output_weights_we,
        hidden_neurons_we => hidden_neurons_we,
        output_neurons_we => output_neurons_we,
        image_we          => image_we,
        init_w            => init_w,
        init_img          => init_img,
        -- Counter Enables
        en_chw => en_chw,
        en_cow => en_cow,
        en_pid => en_pid,
        -- Digit Counter Enables
        en_cd0            => en_cd0,
        en_cd1            => en_cd1,
        en_cd2            => en_cd2,
        en_cd3            => en_cd3,
        en_cd4            => en_cd4,
        en_cd5            => en_cd5,
        en_cd6            => en_cd6,
        en_cd7            => en_cd7,
        en_cd8            => en_cd8,
        en_cd9            => en_cd9, 
        -- Output Flags
        fifo_full         => fifo_full,
        fifo_empty        => fifo_empty,
        neuron_spike      => neuron_spike
    );
        
    clk <= not(clk) after clk_period/2;
    
    stim: process
    begin
        wait until rising_edge(clk);
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        init_w <= '1'; 
        wait until init_done = '1'; 
        init_img <= '1';
        en_pid<='1'; 
        wait until img_done = '1';
        spikegen_go <= '1';
        en_pid<='1';
        
    end process;
    
    spikegen_proc: process
    begin
        wait until spikegen_go = '1';
        en_pid <= '1';
        wait;
    end process;
    
    update_weights: process
    begin
        wait until spikegen_go = '1';
        if fifo_empty = '0' then
            fifo_rd <= '1'; 
        end if; 
    end process;
    
    read_h_weights: process
        file f_ptr          : text;
        variable v_line     : line;
        variable v_data_bit : std_logic_vector(7 downto 0);
        variable v_data_int : integer;
    begin
        wait until init_w = '1';
        file_open(f_ptr, "h_weights.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            wait until rising_edge(clk);
            hidden_weights_we <= '1';
            en_chw <= '1';
            h_weight_in <= std_logic_vector(to_signed(v_data_int, 8));
        end loop;
        
        wait until rising_edge(clk);
        init_done <= '1';
        en_chw <= '0';
        hidden_weights_we <= '0';
        file_close(f_ptr);
        wait;
    end process;

    read_o_weights: process
        file f_ptr          : text;
        variable v_line     : line;
        variable v_data_int : integer;
    begin
        wait until init_w = '1';
        file_open(f_ptr, "o_weights.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            
            wait until rising_edge(clk);
            output_weights_we <= '1';
            o_weight_in <= std_logic_vector(to_signed(v_data_int, 8));
        end loop;
        
        wait until rising_edge(clk);
        file_close(f_ptr);
        wait;
    end process;
    
    read_image_data: process
        file f_ptr          : text;
        variable v_line     : line;
        variable v_data_int : integer;
    begin
        wait until init_img = '1';
        
        file_open(f_ptr, "img_5.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            
            wait until rising_edge(clk);
            image_we   <= '1';
            image_in <= std_logic_vector(to_unsigned(v_data_int, 8));
        end loop;
        
        wait until rising_edge(clk);
        image_we   <= '0';
        image_in <= (others => '0');
        img_done <= '1';
        file_close(f_ptr);
        wait; 
    end process;

end Behavioral;
