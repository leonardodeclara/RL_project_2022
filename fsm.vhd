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

-- qui devo inserire tutti gli stati e cose varie della fsm -- 
type S is (IDLE,START,WAIT_WORDS_NUM,WAIT_WORD,SET_WORD,CONV_1,CONV_2, CONV_3, CONV_4,CONV_5_WR_1, CONV_6, CONV_7, CONV_8, CONV_1_WR_2, END_WR, DONE, END_COD);
signal cur_state, next_state : S;

-- fine di tutte le cose della fsm --

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

    -- process per il reset della fsm
    fsm_state: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= IDLE;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

    -- process per la funzione stato prossimo
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

    -- process per l'aggiornamento dei segnali
    state_signals: process(cur_state)
    begin
        -- se non è qui l'errore portare fuori dal case e cancellare init
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
                --r1_sel <= '1'; in teoria faccio già questa cosa in CONV_7
                --r1_load <= '1';
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

-- 
-- in teoria qui dovrei mettere tutto il codice del datapath, librerie incluse 
--
end Behavioral;
