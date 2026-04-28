----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 12:14:05 AM
-- Design Name: 
-- Module Name: datapath - Behavioral
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

entity datapath is
     Port (
            ------  Formal Ports   ------
            clk : in std_logic;
            rst : in std_logic;
            o_weight_in : in std_logic_vector(7 downto 0);
            h_weight_in : in std_logic_vector(7 downto 0);
            image_in : in std_logic_vector(7 downto 0);
            output: out std_logic_vector(39 downto 0);         
            ------ Control Signals ------
            leak     : in std_logic;            
            init_w   : in std_logic;
            init_n   : in std_logic;
            stg      : in std_logic;
            fifo_rd  : in std_logic;  
            --- RAM WE ---
            hw_we  : in std_logic; 
            hn_we  : in std_logic;
            ow_we  : in std_logic; 
            on_we  : in std_logic;
            img_we : in std_logic;      
            --- Counter Enables ---
            pid_en  : in std_logic;
            hw_en   : in std_logic;
            ow_en   : in std_logic;
            hn_en   : in std_logic;
            on_en   : in std_logic;
            step_en : in std_logic;
            --- Counter Resets ---
            rst_pid : in std_logic;
            rst_hw  : in std_logic;
            rst_ow  : in std_logic;
            rst_hn  : in std_logic;
            rst_on  : in std_logic;
            --- Digit Counter En ---     
            out_en  : in std_logic;
            ------ Output Flags ------ 
            fifo_full : out std_logic;
            fifo_empty: out std_logic;
            spike     : out std_logic;   
            --- Counter Flags ---   
            eq_on     : out std_logic; 
            eq_hn     : out std_logic; 
            eq_hw     : out std_logic; 
            eq_ow     : out std_logic;      
            eq_pid    : out std_logic; 
            last_step : out std_logic 
      );
end datapath;

architecture Behavioral of datapath is

    -- Internal Counter Signals (Matching u_ instances)
    signal pid_cntr  : std_logic_vector(9 downto 0);  
    signal hw_cntr   : std_logic_vector(16 downto 0); 
    signal ow_cntr   : std_logic_vector(10 downto 0); 
    signal hn_cntr   : std_logic_vector(6 downto 0);  
    signal on_cntr   : std_logic_vector(3 downto 0);  
    signal step_cntr : std_logic_vector(3 downto 0);  

    -- Internal Resets (OR'd with global rst)
    signal pid_rst_int : std_logic;
    signal hw_rst_int  : std_logic;
    signal ow_rst_int  : std_logic;
    signal hn_rst_int  : std_logic;
    signal on_rst_int  : std_logic;

    -- Address and Data Signals for RAMs
    signal h_weight_addr : std_logic_vector(16 downto 0);
    signal o_weight_addr : std_logic_vector(10 downto 0);
    signal h_weight      : std_logic_vector(7 downto 0);
    signal o_weight      : std_logic_vector(7 downto 0);
    
    signal v_n     : std_logic_vector(15 downto 0); -- Hidden neurons out
    signal v_n_out : std_logic_vector(15 downto 0); -- Output neurons out
    signal v_new   : std_logic_vector(15 downto 0);
    signal neuron_write_data : std_logic_vector(15 downto 0);
    
    -- Muxed signals for Neuron
    signal weight_muxed : std_logic_vector(7 downto 0);
    signal v_n_muxed    : std_logic_vector(15 downto 0);
    signal neuron_spike : std_logic;

    -- FIFO
    signal fifo_out : std_logic_vector(9 downto 0);

    -- Image and Random Gen
    signal pixel_val   : std_logic_vector(7 downto 0);
    signal random_val  : std_logic_vector(7 downto 0);
    signal pixel_spike : std_logic;
    signal fifo_we     : std_logic;

    --- Digit Counters ---
    signal counter_d0 : std_logic_vector(3 downto 0);
    signal counter_d1 : std_logic_vector(3 downto 0);
    signal counter_d2 : std_logic_vector(3 downto 0);
    signal counter_d3 : std_logic_vector(3 downto 0);
    signal counter_d4 : std_logic_vector(3 downto 0);
    signal counter_d5 : std_logic_vector(3 downto 0);
    signal counter_d6 : std_logic_vector(3 downto 0);
    signal counter_d7 : std_logic_vector(3 downto 0);
    signal counter_d8 : std_logic_vector(3 downto 0);
    signal counter_d9 : std_logic_vector(3 downto 0);

    -- Decoder Signals
    signal dec_en : std_logic;
    signal dec_y  : std_logic_vector(15 downto 0);


begin

    -- Reset OR Logic
    pid_rst_int <= rst or rst_pid;
    hw_rst_int  <= rst or rst_hw;
    ow_rst_int  <= rst or rst_ow;
    hn_rst_int  <= rst or rst_hn;
    on_rst_int  <= rst or rst_on;

    -- Stage Multiplexers
    weight_muxed <= o_weight when stg = '1' else h_weight;
    v_n_muxed    <= v_n_out  when stg = '1' else v_n;
    
    -- Mux for Neuron RAM Initialization
    neuron_write_data <= (others => '0') when init_n = '1' else v_new;
    
    -- RAM Address Multiplexers (Initialization vs Inference)
    h_weight_addr <= hw_cntr when init_w = '1' else (fifo_out & hn_cntr);
    o_weight_addr <= ow_cntr when init_w = '1' else std_logic_vector(resize(unsigned(hn_cntr) * 10 + unsigned(on_cntr), 11));

    -- Output Flags Mapping
    spike <= neuron_spike;
    
    -- Concatenating the 10 digit counters to the 40-bit output
    output <= counter_d9 & counter_d8 & counter_d7 & counter_d6 & counter_d5 & 
              counter_d4 & counter_d3 & counter_d2 & counter_d1 & counter_d0;

    -- Random Spike Generation & FIFO Write
    pixel_spike <= '1' when unsigned(pixel_val) > unsigned(random_val) else '0';
    
    -- AND gate before the FIFO write port in the schematic
    fifo_we <= pixel_spike and (not stg); 

    -- Decoder Enable Logic
    dec_en <= out_en and neuron_spike;

    --------------------------------------------------------------------------------
    -- Equality Comparators for Counters
    --------------------------------------------------------------------------------
    eq_pid    <= '1' when pid_cntr  = std_logic_vector(to_unsigned(783, 10)) else '0';
    eq_hw     <= '1' when hw_cntr   = std_logic_vector(to_unsigned(100351, 17)) else '0';
    eq_ow     <= '1' when ow_cntr   = std_logic_vector(to_unsigned(1279, 11)) else '0';
    eq_hn     <= '1' when hn_cntr   = std_logic_vector(to_unsigned(127, 7)) else '0';
    eq_on     <= '1' when on_cntr   = std_logic_vector(to_unsigned(9, 4)) else '0';
    last_step <= '1' when step_cntr = std_logic_vector(to_unsigned(15, 4)) else '0'; 

    --------------------------------------------------------------------------------
    -- Control Counters
    --------------------------------------------------------------------------------
    u_pid_cntr: entity work.counter
        generic map( w => 10 )
        port map( clk => clk, rst => pid_rst_int, en => pid_en, Q => pid_cntr );

    u_hw_cntr: entity work.counter
        generic map( w => 17 )
        port map( clk => clk, rst => hw_rst_int, en => hw_en, Q => hw_cntr );

    u_ow_cntr: entity work.counter
        generic map( w => 11 )
        port map( clk => clk, rst => ow_rst_int, en => ow_en, Q => ow_cntr );

    u_hn_cntr: entity work.counter
        generic map( w => 7 )
        port map( clk => clk, rst => hn_rst_int, en => hn_en, Q => hn_cntr );

    u_on_cntr: entity work.counter
        generic map( w => 4 )
        port map( clk => clk, rst => on_rst_int, en => on_en, Q => on_cntr );

    u_step_cntr: entity work.counter
        generic map( w => 4 ) 
        port map( clk => clk, rst => rst, en => step_en, Q => step_cntr );

    --------------------------------------------------------------------------------
    -- RAM Instantiations
    --------------------------------------------------------------------------------
    u_h_weights: entity work.BRAM
        generic map( k => 17, w => 8 )
        port map(
            clk  => clk,
            we   => hw_we,
            addr => h_weight_addr,
            din  => h_weight_in,
            dout => h_weight
        );

    u_o_weights: entity work.BRAM
        generic map( k => 11, w => 8 )
        port map(
            clk  => clk,
            we   => ow_we,
            addr => o_weight_addr,
            din  => o_weight_in,
            dout => o_weight
        );
        
    u_hidden_neurons: entity work.BRAM
        generic map( k => 7, w => 16 )
        port map(
            clk  => clk,
            we   => hn_we,
            addr => hn_cntr,
            din  => neuron_write_data,
            dout => v_n
        );

    u_o_neurons: entity work.BRAM
        generic map( k => 4, w => 16 )
        port map(
            clk  => clk,
            we   => on_we,
            addr => on_cntr,
            din  => neuron_write_data,
            dout => v_n_out
        );
        
    u_image: entity work.BRAM
        generic map( k => 10, w => 8 )
        port map(
            clk  => clk,
            we   => img_we,
            addr => pid_cntr,
            din  => image_in,
            dout => pixel_val
        );
        
    --------------------------------------------------------------------------------
    -- Core Components
    --------------------------------------------------------------------------------
    u_neuron: entity work.neuron
        port map(
            I_in  => weight_muxed,
            V_in  => v_n_muxed,
            leak  => leak,
            spike => neuron_spike,
            V_out => v_new
        );

    u_fifo: entity work.FIFO
        port map(
            clk   => clk,
            rst   => rst,
            din   => pid_cntr,
            read  => fifo_rd,
            write => fifo_we,
            dout  => fifo_out,
            full  => fifo_full,
            empty => fifo_empty
        );

    u_randgen: entity work.randgen
        port map( clk => clk, rst => rst, random_val => random_val );

    u_decoder: entity work.decoder
        port map( a => on_cntr, en => dec_en, y => dec_y );

    --------------------------------------------------------------------------------
    -- Digit Counters
    --------------------------------------------------------------------------------
    u_counter_d0: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(0), Q => counter_d0 );
    u_counter_d1: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(1), Q => counter_d1 );
    u_counter_d2: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(2), Q => counter_d2 );
    u_counter_d3: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(3), Q => counter_d3 );
    u_counter_d4: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(4), Q => counter_d4 );
    u_counter_d5: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(5), Q => counter_d5 ); 
    u_counter_d6: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(6), Q => counter_d6 );
    u_counter_d7: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(7), Q => counter_d7 );
    u_counter_d8: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(8), Q => counter_d8 );
    u_counter_d9: entity work.counter
        generic map( w => 4 ) port map( clk => clk, rst => rst, en => dec_y(9), Q => counter_d9 );
 
end Behavioral;