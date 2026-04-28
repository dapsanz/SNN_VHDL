----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 05:59:22 PM
-- Design Name: 
-- Module Name: interface_tb - Behavioral
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

entity interface_tb is
end interface_tb;

architecture Behavioral of interface_tb is

    constant clk_period : time:= 10ns;

    signal clk               : std_logic := '0';
    signal rst               : std_logic := '0';
    
    -- External Control Inputs
    signal start_inference   : std_logic := '0';
    signal start_init_w      : std_logic := '0';
    signal pixel_valid       : std_logic := '0';
    
    -- External Data Inputs
    signal h_weight_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal o_weight_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal image_in          : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Outputs
    signal output            : std_logic_vector(39 downto 0);

    --- Testbench specific controls --- 
    signal init_w_done_tb    : std_logic := '0';
    signal img_done_tb       : std_logic := '0';  

begin
    
    dut: entity work.interface
    port map(
        clk             => clk,
        rst             => rst,
        start_inference => start_inference,
        start_init_w    => start_init_w,
        pixel_valid     => pixel_valid,
        h_weight_in     => h_weight_in,
        o_weight_in     => o_weight_in,
        image_in        => image_in,
        output          => output
    );
        
    clk <= not(clk) after clk_period/2;
    
    stim: process
    begin
        wait until rising_edge(clk);
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        
        -- 1. Initialize Weights
        wait for clk_period*2;
        start_init_w <= '1'; 
        wait until rising_edge(clk);
        start_init_w <= '0'; -- Controller latches this, so just pulse it
        
        wait until init_w_done_tb = '1'; 
        
        -- 2. Start Inference (Automatically handles Init_N and Init_Image in parallel)
        wait for clk_period*5;
        start_inference <= '1';
        wait until rising_edge(clk);
        start_inference <= '0'; -- Pulse it
        
        -- Wait for image to finish streaming in
        wait until img_done_tb = '1';
        
        -- 3. Inference automatically runs now via the controller FSM
        wait;
    end process;
    
    read_h_weights: process
        file f_ptr          : text;
        variable v_line     : line;
        variable v_data_int : integer;
    begin
        wait until start_init_w = '1';
        file_open(f_ptr, "h_weights.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            wait until rising_edge(clk);
            h_weight_in <= std_logic_vector(to_signed(v_data_int, 8));
        end loop;
        
        wait until rising_edge(clk);
        init_w_done_tb <= '1';
        file_close(f_ptr);
        wait;
    end process;

    read_o_weights: process
        file f_ptr          : text;
        variable v_line     : line;
        variable v_data_int : integer;
    begin
        wait until start_init_w = '1';
        file_open(f_ptr, "o_weights.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            wait until rising_edge(clk);
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
        wait until start_inference = '1';
        
        file_open(f_ptr, "img_5.txt", read_mode);
        
        while not endfile(f_ptr) loop
            readline(f_ptr, v_line);
            read(v_line, v_data_int); 
            
            wait until rising_edge(clk);
            pixel_valid <= '1';
            image_in <= std_logic_vector(to_unsigned(v_data_int, 8));
        end loop;
        
        wait until rising_edge(clk);
        pixel_valid <= '0';
        image_in <= (others => '0');
        img_done_tb <= '1';
        file_close(f_ptr);
        wait; 
    end process;

end Behavioral;