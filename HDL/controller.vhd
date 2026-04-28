----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 10:42:08 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
    Port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        
        start_inference : in  std_logic;
        start_init_w    : in  std_logic;
        pixel_valid     : in  std_logic;
        
        fifo_full       : in  std_logic;
        fifo_empty      : in  std_logic;
        spike           : in  std_logic;
        eq_pid          : in  std_logic;
        eq_hw           : in  std_logic;
        eq_ow           : in  std_logic;
        eq_hn           : in  std_logic;
        eq_on           : in  std_logic;
        last_step       : in  std_logic;
        
        inference_done  : out std_logic;
        init_w_done     : out std_logic;
        
        rst_pid         : out std_logic;
        rst_hn          : out std_logic;
        rst_on          : out std_logic;
        rst_hw          : out std_logic;
        rst_ow          : out std_logic;
        
        leak            : out std_logic;
        init_n          : out std_logic;
        init_w          : out std_logic;
        stg             : out std_logic;
        fifo_rd         : out std_logic;
        out_en          : out std_logic;
        
        hw_we           : out std_logic;
        ow_we           : out std_logic;
        hn_we           : out std_logic;
        on_we           : out std_logic;
        img_we          : out std_logic;
        
        pid_en          : out std_logic;
        hw_en           : out std_logic;
        ow_en           : out std_logic;
        hn_en           : out std_logic;
        on_en           : out std_logic;
        step_en         : out std_logic
    );
end controller;

architecture Behavioral of controller is

    type state_type is (
        IDLE,
        INIT_WEIGHTS,
        INIT_PARALLEL,
        TIMESTEP_START,
        SCAN_PIXELS_READ,
        SCAN_PIXELS_EVAL,
        PROCESS_FIFO_POP,
        PROCESS_FIFO_ACCUM_READ,
        PROCESS_FIFO_ACCUM_WRITE,
        HIDDEN_EVAL_READ,
        HIDDEN_EVAL_WRITE,
        OUT_ACCUM_READ,
        OUT_ACCUM_WRITE,
        OUT_EVAL_READ,
        OUT_EVAL_WRITE,
        CHECK_TIMESTEP,
        DONE
    );
    
    signal current_state, next_state : state_type;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, start_inference, start_init_w, pixel_valid, fifo_full, fifo_empty, spike, eq_pid, eq_hw, eq_ow, eq_hn, eq_on, last_step)
    begin
        inference_done <= '0';
        init_w_done    <= '0';
        rst_pid        <= '0';
        rst_hn         <= '0';
        rst_on         <= '0';
        rst_hw         <= '0';
        rst_ow         <= '0';
        leak           <= '0';
        init_n         <= '0';
        init_w         <= '0';
        stg            <= '0';
        fifo_rd        <= '0';
        out_en         <= '0';
        hw_we          <= '0';
        ow_we          <= '0';
        hn_we          <= '0';
        on_we          <= '0';
        img_we         <= '0';
        pid_en         <= '0';
        hw_en          <= '0';
        ow_en          <= '0';
        hn_en          <= '0';
        on_en          <= '0';
        step_en        <= '0';

        next_state <= current_state;

        case current_state is
        
            when IDLE =>
                inference_done <= '1';
                init_w_done <= '1';
                
                if start_init_w = '1' then
                    init_w_done <= '0';
                    rst_hw <= '1';
                    rst_ow <= '1';
                    next_state <= INIT_WEIGHTS;
                elsif start_inference = '1' then
                    inference_done <= '0';
                    rst_pid <= '1';
                    rst_hn <= '1';
                    rst_on <= '1';
                    next_state <= INIT_PARALLEL;
                end if;

            when INIT_WEIGHTS =>
                init_w <= '1';
                
                if eq_ow = '0' then
                    ow_we <= '1';
                    ow_en <= '1';
                end if;
                
                if eq_hw = '0' then
                    hw_we <= '1';
                    hw_en <= '1';
                end if;
                
                if eq_ow = '1' and eq_hw = '1' then
                    rst_hw <= '1';
                    rst_ow <= '1';
                    next_state <= IDLE;
                end if;

            when INIT_PARALLEL =>
                init_n <= '1';
                
                if eq_on = '0' then
                    on_we <= '1';
                    on_en <= '1';
                end if;
                
                if eq_hn = '0' then
                    hn_we <= '1';
                    hn_en <= '1';
                end if;
                
                if eq_pid = '0' and pixel_valid = '1' then
                    img_we <= '1';
                    pid_en <= '1';
                end if;

                if eq_on = '1' and eq_hn = '1' and eq_pid = '1' then
                    rst_pid <= '1';
                    rst_hn <= '1';
                    rst_on <= '1';
                    next_state <= TIMESTEP_START;
                end if;

            when TIMESTEP_START =>
                rst_pid <= '1';
                rst_hn <= '1';
                rst_on <= '1';
                stg <= '0';
                leak <= '0';
                next_state <= SCAN_PIXELS_READ;

            when SCAN_PIXELS_READ =>
                stg <= '0';
                next_state <= SCAN_PIXELS_EVAL;

            when SCAN_PIXELS_EVAL =>
                stg <= '0';
                if eq_pid = '1' then
                    next_state <= PROCESS_FIFO_POP;
                elsif fifo_full = '0' then
                    pid_en <= '1';
                    next_state <= SCAN_PIXELS_READ;
                else
                    next_state <= PROCESS_FIFO_POP;
                end if;

            when PROCESS_FIFO_POP =>
                stg <= '0';
                if fifo_empty = '0' then
                    fifo_rd <= '1';
                    rst_hn <= '1';
                    next_state <= PROCESS_FIFO_ACCUM_READ;
                elsif eq_pid = '1' then
                    rst_hn <= '1';
                    next_state <= HIDDEN_EVAL_READ;
                else
                    next_state <= SCAN_PIXELS_READ;
                end if;

            when PROCESS_FIFO_ACCUM_READ =>
                stg <= '0';
                next_state <= PROCESS_FIFO_ACCUM_WRITE;

            when PROCESS_FIFO_ACCUM_WRITE =>
                stg <= '0';
                hn_we <= '1';
                if eq_hn = '1' then
                    next_state <= PROCESS_FIFO_POP;
                else
                    hn_en <= '1';
                    next_state <= PROCESS_FIFO_ACCUM_READ;
                end if;

            when HIDDEN_EVAL_READ =>
                stg <= '0';
                next_state <= HIDDEN_EVAL_WRITE;

            when HIDDEN_EVAL_WRITE =>
                stg <= '0';
                leak <= '1';
                hn_we <= '1';
                
                if spike = '1' then
                    rst_on <= '1';
                    next_state <= OUT_ACCUM_READ;
                elsif eq_hn = '1' then
                    rst_hn <= '1';
                    rst_on <= '1';
                    next_state <= OUT_EVAL_READ;
                else
                    hn_en <= '1';
                    next_state <= HIDDEN_EVAL_READ;
                end if;

            when OUT_ACCUM_READ =>
                stg <= '1';
                next_state <= OUT_ACCUM_WRITE;

            when OUT_ACCUM_WRITE =>
                stg <= '1';
                on_we <= '1';
                
                if eq_on = '1' then
                    if eq_hn = '1' then
                        rst_hn <= '1';
                        rst_on <= '1';
                        next_state <= OUT_EVAL_READ;
                    else
                        hn_en <= '1';
                        next_state <= HIDDEN_EVAL_READ;
                    end if;
                else
                    on_en <= '1';
                    next_state <= OUT_ACCUM_READ;
                end if;

            when OUT_EVAL_READ =>
                stg <= '1';
                next_state <= OUT_EVAL_WRITE;

            when OUT_EVAL_WRITE =>
                stg <= '1';
                leak <= '1';
                on_we <= '1';
                
                if spike = '1' then
                    out_en <= '1';
                end if;
                
                if eq_on = '1' then
                    rst_on <= '1';
                    next_state <= CHECK_TIMESTEP;
                else
                    on_en <= '1';
                    next_state <= OUT_EVAL_READ;
                end if;

            when CHECK_TIMESTEP =>
                step_en <= '1';
                if last_step = '1' then
                    next_state <= DONE;
                else
                    next_state <= TIMESTEP_START;
                end if;

            when DONE =>
                inference_done <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
                
        end case;
    end process;

end Behavioral;
