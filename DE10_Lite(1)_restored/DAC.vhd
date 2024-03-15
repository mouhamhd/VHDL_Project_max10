--------------------------------------------------------------------------------
--
--   FileName:         i2c_master.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 32-bit Version 11.1 Build 173 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 11/1/2012 Scott Larson
--     Initial Public Release
--   Version 2.0 06/20/2014 Scott Larson
--     Added ability to interface with different slaves in the same transaction
--     Corrected ack_error bug where ack_error went 'Z' instead of '1' on error
--     Corrected timing of when ack_error signal clears
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
library work;
use work.ALL;
use work.son.all;


ENTITY DAC IS

  PORT(
    Tnum         :  IN      STD_LOGIC_VECTOR ( NbitCNA-1 downto 0); -- entrée à convertir
    clk       :  IN      STD_LOGIC;                    --system clock
    reset_n   :  IN      STD_LOGIC;                    --active low reset
    ena       :  IN      STD_LOGIC;                    --latch in command
    sda       :  INOUT   STD_LOGIC;                    --serial data output of i2c bus
    scl       :  INOUT   STD_LOGIC);                   --serial clock output of i2c bus
END DAC;

ARCHITECTURE logic OF DAC IS
  CONSTANT divider  :  INTEGER := (input_clk/bus_clk)/4; --number of clocks in 1/4 cycle of scl
  TYPE machine IS(ready, start, command, slv_ack1, wr1, slv_ack2, wr2, slv_ack3,  stop, attente_fin_ena); --needed states
  SIGNAL  state     :  machine;                          --state machine
  SIGNAL  data_clk  :  STD_LOGIC;                        --clock edges for sda
  SIGNAL  scl_clk   :  STD_LOGIC;                        --constantly running internal scl
  SIGNAL  scl_ena   :  STD_LOGIC := '0';                 --enables internal scl to output
  SIGNAL  sda_int   :  STD_LOGIC := '1';                 --internal sda
  SIGNAL  sda_ena_n :  STD_LOGIC;                        --enables internal sda to output
  SIGNAL  addr_rw   :  STD_LOGIC_VECTOR(7 DOWNTO 0) :="11000000" ;     --latched in address and read/write
  SIGNAL  data_tx   :  STD_LOGIC_VECTOR(15 DOWNTO 0) :="0000011111111111";     --latched in data to write to slave
  SIGNAL  bit_cnt   :  INTEGER RANGE 0 TO 7 := 7;        --tracks bit number in transaction
  SIGNAL  stretch   :  STD_LOGIC := '0';                 --identifies if slave is stretching scl
  -- type TAB1 is array(0 to 31) of std_logic_vector(11 downto 0); --tableau contenant 32 cases 
                                                          --chaque case econtient un vecteur de taille 16 bits 
  signal A           : std_logic_vector(11 downto 0);    -- valeur échantillonée 
  SIGNAL  i         :  INTEGER RANGE 0 TO 32 := 0;   --pour parcourir le tableau A
  SIGNAL  j         :  INTEGER RANGE 0 TO 18 := 0;   --permet de passer à la valeur suivante dans le tableau
  
BEGIN
   	
  --generate the timing for the bus clock (scl_clk) and the data clock (data_clk)
  PROCESS(clk, reset_n)
    VARIABLE count  :  INTEGER RANGE 0 TO divider*4;  --timing for clock generation
  BEGIN
    IF(reset_n = '0') THEN                --reset asserted
      stretch <= '0';
      count := 0;
    ELSIF(clk'EVENT AND clk = '1') THEN
      IF(count = divider*4-1) THEN        --end of timing cycle
        count := 0;                       --reset timer
      ELSIF(stretch = '0') THEN           --clock stretching from slave not detected
        count := count + 1;               --continue clock generation timing
      END IF;
      CASE count IS
        WHEN 0 TO divider-1 =>            --first 1/4 cycle of clocking
          scl_clk <= '0';
          data_clk <= '0';
        WHEN divider TO divider*2-1 =>    --second 1/4 cycle of clocking
          scl_clk <= '0';
          data_clk <= '1';
        WHEN divider*2 TO divider*3-1 =>  --third 1/4 cycle of clocking
          scl_clk <= '1';                 --release scl
          IF(scl = '0') THEN              --detect if slave is stretching clock
            stretch <= '0'; -- 1 changé
          ELSE
            stretch <= '0';
          END IF;
          data_clk <= '1';
        WHEN OTHERS =>                    --last 1/4 cycle of clocking
          scl_clk <= '1';
          data_clk <= '0';
      END CASE;
    END IF;
  END PROCESS;

--   PROCESS (clk,reset_n)
--	  BEGIN
--	    IF(reset_n = '0') THEN   data_tx (15 downto 0) <= (others => '0'); 
--		  ELSIF (clk'EVENT AND clk = '1') THEN
--          	data_tx (15 downto 12) <= (others => '0'); -- synchronisation de la donnée à transmettre
--     	      data_tx(11 downto 0)   <= Tnum;	 
--		END IF;		
--		  
--		  
--	  END PROCESS;


  --state machine and writing to sda during scl low (data_clk rising edge)
  PROCESS(data_clk, reset_n)
  BEGIN
    IF(reset_n = '0') THEN                 --reset asserted
      state <= ready;                      --return to initial state
      scl_ena <= '0';                      --sets scl high impedance
      sda_int <= '1';                      --sets sda high impedance
      bit_cnt <= 7;                        --restarts data bit counter
		data_tx (15 downto 12) <= (others => '0');
		data_tx(11 downto 0)   <= Tnum;
		i<=0;
		j<=0;
    ELSIF(data_clk'EVENT AND data_clk = '1') THEN
       
		data_tx (15 downto 12) <= (others => '0'); -- preparation de la donnée à transmettre
     	data_tx(11 downto 0)   <= Tnum;
			
      CASE state IS
        WHEN ready =>                      --idle state
          IF(ena = '1') THEN               --transaction requested
            addr_rw <= "11000000";          --collect requested slave address and command
            state <= start;                --go to start bit
          ELSE                             --remain idle
            state <= ready;                --remain idle
          END IF;
        WHEN start =>                      --start bit of transaction
          scl_ena <= '1';                  --enable scl output
          sda_int <= addr_rw(bit_cnt);     --set first address bit to bus
          
			 state <= command;                --go to command
        WHEN command =>                    --address and command byte of transaction
          IF(bit_cnt = 0) THEN             --command transmit finished
            sda_int <= '1';                --release sda for slave acknowledge
            bit_cnt <= 7;                  --reset bit counter for "byte" states
            state <= slv_ack1;             --go to slave acknowledge (command)
          ELSE                             --next clock cycle of command state
            bit_cnt <= bit_cnt - 1;        --keep track of transaction bits
            sda_int <= addr_rw(bit_cnt-1); --write address/command bit to bus
            state <= command;              --continue with command
          END IF;
        WHEN slv_ack1 =>                   --slave acknowledge bit (command)
		      j <= 0;
            sda_int <= data_tx(bit_cnt+8);   --write first bit of data
            state <= wr1;                   --go to write byte
        WHEN wr1 =>                         --write byte of transaction
          IF(bit_cnt = 0) THEN             --write byte transmit finished
            sda_int <= '1';                --release sda for slave acknowledge
            bit_cnt <= 7;                  --reset bit counter for "byte" states
            state <= slv_ack2;             --go to slave acknowledge (write)
          ELSE                             --next clock cycle of write state
            bit_cnt <= bit_cnt - 1;        --keep track of transaction bits
            sda_int <= data_tx(bit_cnt+8-1); --write next bit to bus
            state <= wr1;                   --continue writing
          END IF;
        WHEN slv_ack2 =>                   --slave acknowledge bit (write)
          IF(ena = '1') THEN               --continue transaction
            addr_rw <= "11000000";          --collect requested slave address and command
            IF(addr_rw = "11000000") THEN   --continue transaction with another write
              sda_int <= data_tx(bit_cnt); --write first bit of data
              state <= wr2;                 --go to write byte
            ELSE                           --continue transaction with a read or new slave
              state <= start;              --go to repeated start
            END IF;
          ELSE                             --complete transaction
            scl_ena <= '0';                --disable scl
            state <= stop;                 --go to stop bit
          END IF;
		  WHEN wr2 =>                         --write byte of transaction
          IF(bit_cnt = 0) THEN             --write byte transmit finished
            sda_int <= '1';                --release sda for slave acknowledge
            bit_cnt <= 7;                  --reset bit counter for "byte" states
            state <= slv_ack3;             --go to slave acknowledge (write)
          ELSE                             --next clock cycle of write state
            bit_cnt <= bit_cnt - 1;        --keep track of transaction bits
            sda_int <= data_tx(bit_cnt-1); --write next bit to bus
            state <= wr2;                   --continue writing
          END IF;
        WHEN slv_ack3 =>                   --slave acknowledge bit (write)
--          IF(ena = '1') THEN               --continue transaction
--            addr_rw <= "11000000";          --collect requested slave address and command
--            IF(addr_rw = "11000000") THEN   --continue transaction with another write
--              sda_int <= data_tx(bit_cnt); --write first bit of data
--              state <= wr1;                 --go to write byte
--            ELSE                           --continue transaction with a read or new slave
--              state <= start;              --go to repeated start
--            END IF;
--          ELSE                             --complete transaction
            scl_ena <= '0';                --disable scl
            state <= stop;                 --go to stop bit
          -- END IF;
        WHEN stop =>                       --stop bit of transaction
          state <= ready ;   
			-- state <= attente_fin_ena;                  --go to idle state
		  WHEN attente_fin_ena =>
		    sda_int <= '1';                  -- pour éviter des pics sur data_clk 
		  IF (ena='1' ) then state <= attente_fin_ena; -- synchro avec ADC via ena = mesure_done de l ADC
			              else state <= ready ;
			end IF;
			 
		  -- state <= ready ;
		  
      END CASE;    
    END IF;

    
  END PROCESS;  

  --set sda output
  WITH state SELECT
    sda_ena_n <=   data_clk WHEN start,  --generate start condition
              NOT data_clk WHEN stop,    --generate stop condition
              sda_int WHEN OTHERS;       --set to internal sda signal    
      
  --set scl and sda outputs
  scl <= '0' WHEN (scl_ena = '1' AND scl_clk = '0') ELSE 'Z';
  sda <= '0' WHEN sda_ena_n = '0' ELSE 'Z';
  
  
  
END logic;
