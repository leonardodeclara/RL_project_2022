library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0)
           );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start: in STD_LOGIC;
        conv_rst : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR (7 downto 0);
        i_addr : in STD_LOGIC_VECTOR (15 downto 0);
        wr_addr : in STD_LOGIC_VECTOR (15 downto 0);
        o_address : out STD_LOGIC_VECTOR (15 downto 0);
        o_data : out STD_LOGIC_VECTOR (7 downto 0);
        r1_load : in STD_LOGIC;
        r2_load : in STD_LOGIC;
        r3_load : in STD_LOGIC;
        r4_load : in STD_LOGIC;
        r5_load : in STD_LOGIC;
        r1_sel : in STD_LOGIC;
        o_r2_sel : in STD_LOGIC_VECTOR (2 downto 0);
        r4_sel : in STD_LOGIC;
        r5_sel : in STD_LOGIC;
        d_sel : in STD_LOGIC;
        mem_sel : in STD_LOGIC;
        o_end : out STD_LOGIC);
end component;
signal conv_rst : STD_LOGIC;
signal i_addr : STD_LOGIC_VECTOR (15 downto 0);
signal wr_addr : STD_LOGIC_VECTOR (15 downto 0);
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal r3_load : STD_LOGIC;
signal r4_load : STD_LOGIC;
signal r5_load : STD_LOGIC;
signal r1_sel : STD_LOGIC;
signal o_r2_sel : STD_LOGIC_VECTOR(2 downto 0);
signal r4_sel : STD_LOGIC;
signal r5_sel : STD_LOGIC;
signal d_sel : STD_LOGIC;
signal mem_sel : STD_LOGIC;
signal o_end : STD_LOGIC;
type C is (C0,C1,C2,C3);
signal conv_cur_state, conv_next_state : C;

type S is (IDLE,START,WAIT_WORDS_NUM,WAIT_WORD,SET_WORD,CONV_1,CONV_2, CONV_3, CONV_4,CONV_5_WR_1, CONV_6, CONV_7, CONV_8, CONV_1_WR_2, END_WR, DONE, END_COD);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
        i_clk,
        i_rst,
        i_start,
        conv_rst,
        i_data,
        i_addr,
        wr_addr,
        o_address,
        o_data,
        r1_load,
        r2_load,
        r3_load,
        r4_load,
        r5_load,
        r1_sel,
        o_r2_sel,
        r4_sel,
        r5_sel,
        d_sel,
        mem_sel,
        o_end
    );

    fsm_state: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= IDLE;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

    delta: process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when IDLE =>
                if i_start = '1' then
                    next_state <= START;
                elsif i_start = '0' then
                    next_state <= IDLE;
                end if;
            when START =>
                next_state <= WAIT_WORDS_NUM;
            when WAIT_WORDS_NUM =>
                next_state <= WAIT_WORD;
            when WAIT_WORD =>
                next_state <= SET_WORD;
            when SET_WORD =>
                if o_end='0' then
                    next_state <= CONV_1;
                else 
                    next_state <= DONE;
                end if;
            when CONV_1 =>
                next_state <= CONV_2;
            when CONV_2 =>
                next_state <= CONV_3;
            when CONV_3 =>
                next_state <= CONV_4;
            when CONV_4 =>
                next_state <= CONV_5_WR_1;
            when CONV_5_WR_1 =>
                next_state <= CONV_6;
            when CONV_6 =>
                next_state <= CONV_7;
            when CONV_7 =>
                next_state <= CONV_8;
            when CONV_8 =>
                if o_end='0' then
                    next_state <= CONV_1_WR_2;
                else 
                    next_state <= END_WR;
                end if;
            when CONV_1_WR_2 =>
                next_state <= CONV_2;
            when END_WR =>
                next_state <= DONE;
            when DONE =>
                if i_start = '1' then
                    next_state <= DONE;
                elsif i_start = '0' then
                    next_state <= END_COD;
                end if;
            when END_COD =>
                next_state <= IDLE;
        end case;
    end process;


    state_signals: process(cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r5_load <= '0';
        r1_sel <= '0';
        o_r2_sel <= "000";
        r4_sel <= '0';
        r5_sel <= '0';
        d_sel <= '0';
        mem_sel <= '0';
        conv_rst <= '0'; 
        wr_addr <= "0000001111101000";
        i_addr <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';  
        case cur_state is
            when IDLE =>
            when START =>
                i_addr <= "0000000000000000";
                wr_addr <= "0000001111101000";
                r4_sel <= '0';
                r4_load <= '1';
                r5_sel <= '0';
                r5_load <= '1';
                conv_rst <= '1';
            when WAIT_WORDS_NUM =>
                mem_sel <= '0';
                o_en <= '1';
                o_we <= '0';
                r4_sel <= '1';
                r4_load <= '1';
                conv_rst <= '0';
            when WAIT_WORD =>
                mem_sel <= '0';
                o_en <= '1';
                o_we <= '0';
                r1_load <= '1';
                r1_sel <= '0';
            when SET_WORD =>
                r2_load <= '1';
                r4_sel <= '1';
                r4_load <= '1';
            when CONV_1 =>
                o_r2_sel <= "111";
                d_sel <= '0';
                r3_load <= '1';
            when CONV_2 =>
                o_r2_sel <= "110";
                d_sel <= '1';
                r3_load <= '1';
            when CONV_3 =>
                o_r2_sel <= "101";
                d_sel <= '1';
                r3_load <= '1';
            when CONV_4 =>
                o_r2_sel <= "100";
                d_sel <= '1';
                r3_load <= '1';
            when CONV_5_WR_1 =>
                o_r2_sel <= "011";
                d_sel <= '0';
                r3_load <= '1';
                o_we <= '1';
                o_en <= '1';
                mem_sel <= '1';
                r5_sel <= '1';
                r5_load <= '1';
            when CONV_6 =>
                o_r2_sel <= "010";
                d_sel <= '1';
                r3_load <= '1';
            when CONV_7 =>
                o_r2_sel <= "001";
                d_sel <= '1';
                r3_load <= '1';
                o_we <= '0';
                o_en <= '1';
                mem_sel <= '0';
                r4_sel <= '1';
                r4_load <= '1';
                r1_sel <= '1';
                r1_load <= '1';
            when CONV_8 =>
                o_r2_sel <= "000";
                r3_load <= '1';
                d_sel <= '1';
                r2_load <= '1';
            when CONV_1_WR_2 =>
                o_r2_sel <= "111";
                r3_load <= '1';
                d_sel <= '0';
                o_we <= '1';
                o_en <= '1';
                mem_sel <= '1';
                r5_sel <= '1';
                r5_load <= '1';
            when END_WR =>
                o_we <= '1';
                o_en <= '1';
                mem_sel <= '1';
            when DONE =>
                o_done <= '1';
            when END_COD =>
                o_done <= '0';
        end case;
    end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           conv_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           i_addr : in STD_LOGIC_VECTOR (15 downto 0);
           wr_addr : in STD_LOGIC_VECTOR (15 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r4_load : in STD_LOGIC;
           r5_load : in STD_LOGIC;
           r1_sel : in STD_LOGIC;
           o_r2_sel : in STD_LOGIC_VECTOR (2 downto 0);
           r4_sel : in STD_LOGIC;
           r5_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           mem_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal mux_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal sub_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal i_conv : STD_LOGIC;
signal o_conv : STD_LOGIC_VECTOR(1 downto 0);
signal sum_conv:  STD_LOGIC_VECTOR(7 downto 0);
signal o_sll : STD_LOGIC_VECTOR(7 downto 0);
signal mux_sum_conv : STD_LOGIC_VECTOR(7 downto 0);
signal mux_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal sum_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal mux_reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal sum_reg5 : STD_LOGIC_VECTOR (15 downto 0);
type C is (C0,C1,C2,C3);
signal conv_cur_state, conv_next_state : C;

begin

    with r1_sel select 
        mux_reg1 <= i_data when '0',
                    sub_reg1 when '1',
        		    "XXXXXXXX" when others;

    r1: process(i_clk, i_rst, i_start)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= mux_reg1;
            end if;
        end if;
    end process;
    
    sub_reg1 <= o_reg1 - "00000001";
    
    o_end <= '1' when (o_reg1 = "00000000") else '0';
    
    r2: process(i_clk, i_rst, i_start)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
    with o_r2_sel select
        i_conv <= o_reg2(0) when "000",
                  o_reg2(1) when "001",
                  o_reg2(2) when "010",
                  o_reg2(3) when "011",
                  o_reg2(4) when "100",
                  o_reg2(5) when "101",
                  o_reg2(6) when "110",
                  o_reg2(7) when "111",
                  'X' when others;


    conv_state: process(i_clk, conv_rst)
    begin
        if(conv_rst = '1') then
            conv_cur_state <= C0;
        elsif i_clk'event and i_clk = '1' then
            conv_cur_state <= conv_next_state;
        end if;
    end process;

    conv_lambda: process (conv_cur_state, i_conv)
    begin
        conv_next_state <= conv_cur_state;
        case conv_cur_state is
            when C0 =>
                if i_conv = '1' then
                    conv_next_state <= C2;
                    o_conv <= "11";
                elsif i_conv = '0' then
                    conv_next_state <= C0;
                    o_conv <= "00";
                end if;
            when C1 =>
                if i_conv = '1' then
                    conv_next_state <= C2;
                    o_conv <= "00";
                elsif i_conv = '0' then
                    conv_next_state <= C0;
                    o_conv <= "11";
                end if;
            when C2 =>
                if i_conv = '1' then
                    conv_next_state <= C3;
                    o_conv <= "10";
                elsif i_conv = '0' then
                    conv_next_state <= C1;
                    o_conv <= "01";
                end if;
            when C3 =>
                if i_conv = '1' then
                    conv_next_state <= C3;
                    o_conv <= "01";
                elsif i_conv = '0' then
                    conv_next_state <= C1;
                    o_conv <= "10";
                end if;
        end case;
    end process;

    sum_conv <= ("000000" & o_conv)+ mux_sum_conv;
    
    with d_sel select
        mux_sum_conv <= "00000000" when '0',
                        o_sll when '1',
                        "XXXXXXXX" when others;
    
    
    r3: process(i_clk, i_rst)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= sum_conv;
            end if;
        end if;
    end process;

    o_data <= o_reg3;
    o_sll <= o_reg3(5 downto 0) & "00" ;
    
    with r4_sel select
        mux_reg4 <= i_addr when '0',
                    sum_reg4 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

    r4: process(i_clk, i_rst)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg4 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r4_load = '1') then
                o_reg4 <= mux_reg4;
            end if;
        end if;
    end process;

    sum_reg4 <= o_reg4 + "0000000000000001";

    with r5_sel select
        mux_reg5 <= wr_addr when '0',
                    sum_reg5 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

    r5: process(i_clk, i_rst)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg5 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r5_load = '1') then
                o_reg5 <= mux_reg5;
            end if;
        end if;
    end process;

    sum_reg5 <= o_reg5 + "0000000000000001";

    with mem_sel select
        o_address <= o_reg4 when '0',
                    o_reg5 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

end Behavioral;