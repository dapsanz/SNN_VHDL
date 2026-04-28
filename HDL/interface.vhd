----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 10:55:57 PM
-- Design Name: 
-- Module Name: interface - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity interface is
  Port ( 
         clk             : in std_logic;
         rst             : in std_logic;
         
         -- External Control Inputs
         start_inference : in std_logic;
         start_init_w    : in std_logic;
         pixel_valid     : in std_logic;
         
         -- External Data Inputs
         h_weight_in     : in std_logic_vector(7 downto 0);
         o_weight_in     : in std_logic_vector(7 downto 0);
         image_in        : in std_logic_vector(7 downto 0);
         
         inference_done  : out std_logic;
         
         -- Outputs
         output          : out std_logic_vector(19 downto 0)
   );
end interface;

architecture Behavioral of interface is

    attribute dont_touch : string;
    attribute dont_touch of u_controller : label is "true";
    attribute dont_touch of u_datapath   : label is "true";

    -- Control Signals
    signal leak    : std_logic;
    signal init_w  : std_logic;
    signal init_n  : std_logic;
    signal stg     : std_logic;
    signal fifo_rd : std_logic;
    signal out_en  : std_logic;

    -- RAM WE
    signal hw_we   : std_logic;
    signal hn_we   : std_logic;
    signal ow_we   : std_logic;
    signal on_we   : std_logic;
    signal img_we  : std_logic;

    -- Counter Enables
    signal pid_en  : std_logic;
    signal hw_en   : std_logic;
    signal ow_en   : std_logic;
    signal hn_en   : std_logic;
    signal on_en   : std_logic;
    signal step_en : std_logic;

    -- Counter Resets
    signal rst_pid : std_logic;
    signal rst_hw  : std_logic;
    signal rst_ow  : std_logic;
    signal rst_hn  : std_logic;
    signal rst_on  : std_logic;

    -- Output Flags / Datapath Feedback
    signal fifo_full  : std_logic;
    signal fifo_empty : std_logic;
    signal spike      : std_logic;
    signal eq_pid     : std_logic;
    signal eq_hw      : std_logic;
    signal eq_ow      : std_logic;
    signal eq_hn      : std_logic;
    signal eq_on      : std_logic;
    signal last_step  : std_logic;
    
    -- Controller Status Flags
--    signal inference_done  : std_logic;
    signal init_w_done     : std_logic;
    
    signal output_signal   : std_logic_vector(39 downto 0); 

begin

    output <= output_signal(19 downto 0);
    u_controller: entity work.controller
    port map(
        clk             => clk,
        rst             => rst,
        
        start_inference => start_inference,
        start_init_w    => start_init_w,
        pixel_valid     => pixel_valid,
        
        fifo_full       => fifo_full,
        fifo_empty      => fifo_empty,
        spike           => spike,
        eq_pid          => eq_pid,
        eq_hw           => eq_hw,
        eq_ow           => eq_ow,
        eq_hn           => eq_hn,
        eq_on           => eq_on,
        last_step       => last_step,
        
        inference_done  => inference_done,
        init_w_done     => init_w_done,
        
        rst_pid         => rst_pid,
        rst_hn          => rst_hn,
        rst_on          => rst_on,
        rst_hw          => rst_hw,
        rst_ow          => rst_ow,
        
        leak            => leak,
        init_n          => init_n,
        init_w          => init_w,
        stg             => stg,
        fifo_rd         => fifo_rd,
        out_en          => out_en,
        
        hw_we           => hw_we,
        ow_we           => ow_we,
        hn_we           => hn_we,
        on_we           => on_we,
        img_we          => img_we,
        
        pid_en          => pid_en,
        hw_en           => hw_en,
        ow_en           => ow_en,
        hn_en           => hn_en,
        on_en           => on_en,
        step_en         => step_en
    );

    u_datapath: entity work.datapath
    port map(
        clk             => clk,
        rst             => rst,
        
        o_weight_in     => o_weight_in,
        h_weight_in     => h_weight_in,
        image_in        => image_in,
        output          => output_signal,
        
        leak            => leak,
        init_w          => init_w,
        init_n          => init_n,
        stg             => stg,
        fifo_rd         => fifo_rd,
        
        hw_we           => hw_we,
        hn_we           => hn_we,
        ow_we           => ow_we,
        on_we           => on_we,
        img_we          => img_we,
        
        pid_en          => pid_en,
        hw_en           => hw_en,
        ow_en           => ow_en,
        hn_en           => hn_en,
        on_en           => on_en,
        step_en         => step_en,
        
        rst_pid         => rst_pid,
        rst_hw          => rst_hw,
        rst_ow          => rst_ow,
        rst_hn          => rst_hn,
        rst_on          => rst_on,
        out_en          => out_en,
        
        fifo_full       => fifo_full,
        fifo_empty      => fifo_empty,
        spike           => spike,
        eq_on           => eq_on,
        eq_hn           => eq_hn,
        eq_hw           => eq_hw,
        eq_ow           => eq_ow,
        eq_pid          => eq_pid,
        last_step       => last_step
    );

end Behavioral;