library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
use work.son.all;

ENTITY DE10_LITE IS
	PORT (
		-- clocks
		ADC_CLK_10      :  IN      STD_LOGIC;
		MAX10_CLK1_50	 :  IN      STD_LOGIC;
		MAX10_CLK2_50   :  IN      STD_LOGIC;
		-- BP et Switchs
		KEY 				 : IN STD_LOGIC_VECTOR(1 downto 0);
		SW 				 : IN STD_LOGIC_VECTOR(9 downto 0);
		-- leds et afficheurs 
		LEDR				 : OUT STD_LOGIC_VECTOR(9 downto 0);
		HEX0				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX1				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX2				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX3				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX4				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX5				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		-- SDRAM
		DRAM_CLK        : OUT STD_LOGIC;
		DRAM_CKE        : OUT STD_LOGIC;
		DRAM_ADDR				 : OUT STD_LOGIC_VECTOR(12 downto 0);
		DRAM_BA				 : OUT STD_LOGIC_VECTOR(1 downto 0);
		DRAM_DQ				 : OUT STD_LOGIC_VECTOR(15 downto 0);
		DRAM_LDQM        : OUT STD_LOGIC;
		DRAM_UDQM        : OUT STD_LOGIC;
		DRAM_CS_N        : OUT STD_LOGIC;
		DRAM_WE_N        : OUT STD_LOGIC;
		DRAM_CAS_N        : OUT STD_LOGIC;
		DRAM_RAS_N        : OUT STD_LOGIC;
		-- VGA
		VGA_HS        : OUT STD_LOGIC;
		VGA_VS        : OUT STD_LOGIC;
		VGA_R				 : OUT STD_LOGIC_VECTOR(3 downto 0);
		VGA_G				 : OUT STD_LOGIC_VECTOR(3 downto 0);
		VGA_B				 : OUT STD_LOGIC_VECTOR(3 downto 0);
		-- I2C
		CLK_I2C_SCL        : OUT STD_LOGIC;
		CLK_I2C_SDA        : INOUT STD_LOGIC;
		GSENSOR_SCLK        : OUT STD_LOGIC;
		GSENSOR_SDO        : INOUT STD_LOGIC;
		GSENSOR_SDI        : IN STD_LOGIC;
		GSENSOR_INT			: OUT STD_LOGIC_VECTOR(2 downto 1);
		GSENSOR_CS_N        : OUT STD_LOGIC;
		-- GPIO
		GPIO			 : INOUT STD_LOGIC_VECTOR(35 downto 0);
		
		-- ARDUINO
		ARDUINO_IO			 : INOUT STD_LOGIC_VECTOR(15 downto 0);
		ARDUINO_RESET_N        : INOUT STD_LOGIC
		    
  );
END DE10_LITE;


ARCHITECTURE structurelle OF DE10_LITE IS 

-- composant généré par Qsys contenant l'interface avec l ADC et la pll
component adc_qsys is
		port (
			clk_clk                              : in  std_logic                     := 'X';             -- clk
			clock_bridge_sys_out_clk_clk         : out std_logic;                                        -- clk
			modular_adc_0_command_valid          : in  std_logic                     := 'X';             -- valid
			modular_adc_0_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			modular_adc_0_command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			modular_adc_0_command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			modular_adc_0_command_ready          : out std_logic;                                        -- ready
			modular_adc_0_response_valid         : out std_logic;                                        -- valid
			modular_adc_0_response_channel       : out std_logic_vector(4 downto 0);                     -- channel
			modular_adc_0_response_data          : out std_logic_vector(NbitCAN-1 downto 0);                    -- data
			modular_adc_0_response_startofpacket : out std_logic;                                        -- startofpacket
			modular_adc_0_response_endofpacket   : out std_logic;                                        -- endofpacket
			reset_reset_n                        : in  std_logic                     := 'X'              -- reset_n
		);
end component adc_qsys;

-- composant gérant l'affichage sur les afficheurs 7 segments
component affichage IS
	PORT (clk           :  IN      STD_LOGIC; -- clock à 50 Mhz
		response_data    :  IN std_logic_vector(NbitCAN-1 downto 0) ;  --valeur issue de l'ADC
		dataDAC          :  IN Std_Logic_Vector ( NbitCNA-1 downto 0); -- valeur envoyée vers le DAC
		response_channel :  IN std_logic_vector(4 downto 0) ; -- numéro de canal converti
		response_valid   :  IN std_logic ;
		BP0              :  IN      STD_LOGIC;   --active low reset sur BP0
	   HEX0				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX1				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX2				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX3				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX4				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX5				 : OUT STD_LOGIC_VECTOR(7 downto 0)
		
	 ); 
end component;

-- componsant coeur 
COMPONENT  numerique IS
	PORT (clk       :  IN      STD_LOGIC; -- clock a 25 MHZ
		measure_done      : IN std_logic ;  --indique si la conversion AD est finie
		start_trait       : out std_logic ;  --pour observation
		fin_trait         : out std_logic ;  --pour observation
		BP0,BP1,BP2,BP3               :  IN      STD_LOGIC;   --active low reset sur BP0
	   validson : OUT std_logic; -- pour maitriser quand on émet du son
		dataADC    :  IN Std_Logic_Vector(NbitCAN-1 downto 0); -- signal d'entrée converti
		dataDAC    :  OUT Std_Logic_Vector ( NbitCNA-1 downto 0) -- sortie à convertir 
	 ); 
END COMPONENT numerique;

-- componsant permettant la maitrise de la fréquence de sortie
COMPONENT freqsortie IS
	PORT (clk           :  IN      STD_LOGIC; -- clock à 50 Mhz
		validsortie      : IN std_logic ;  --indique si on souhaite émettre du son
		BP0              :  IN      STD_LOGIC;   --active low reset sur BP0
	   ena, Fs          : OUT std_logic -- pour maitrise de la frequence d'echantillonage DAC Fs dure une seule période, ena toute la trame I2C
		
	 ); 
END COMPONENT freqsortie;

-- composant gérant l'interface I2C avec le DAC
component DAC IS
  PORT(
    Tnum         :  IN      STD_LOGIC_VECTOR ( NbitCNA-1 downto 0); -- entrée à convertir
    clk       :  IN      STD_LOGIC;                    --system clock 50 Mhz
    reset_n   :  IN      STD_LOGIC;                    --active low reset
    ena       :  IN      STD_LOGIC;                    --latch in command
    sda       :  INOUT   STD_LOGIC;                    --serial data output of i2c bus
    scl       :  INOUT   STD_LOGIC);                   --serial clock output of i2c bus
END component DAC;
	
SIGNAL clock    :  std_logic  ; -- horloge C0 issue du bloc IP ADC à 25Mhz
SIGNAL channel : std_logic_vector(4 downto 0) ; -- numéro de canal à convertir
SIGNAL response_channel : std_logic_vector(4 downto 0) ; -- numéro de canal converti
SIGNAL commandeready : std_logic ;
SIGNAL response_valid : std_logic ;
SIGNAL response_data : std_logic_vector(NbitCAN-1 downto 0) ;
SIGNAL startofpacket : std_logic ;
SIGNAL endofpacket : std_logic ;
SIGNAL sdataDAC    :  Std_Logic_Vector ( NbitCNA-1 downto 0); -- signal a envoyer vers le DAC qui donnera le son
SIGNAL sena,svalidsortie,sfs : Std_logic; -- signauxour maitriser la  sortie du DAC
SIGNAL sstart_trait : Std_logic; -- signal connecté au coeur 
SIGNAL s_scl, s_sda : Std_logic; 


BEGIN	
	u0 : component adc_qsys
		port map (
			clk_clk                              => MAX10_CLK1_50,                              --                      clk.clk
			clock_bridge_sys_out_clk_clk         => clock,         -- clock_bridge_sys_out_clk.clk
			modular_adc_0_command_valid          => '1',          --    modular_adc_0_command.valid
			modular_adc_0_command_channel        => channel,        --                         .channel
			modular_adc_0_command_startofpacket  => '1',  --                         .startofpacket
			modular_adc_0_command_endofpacket    => '1',    --                         .endofpacket
			modular_adc_0_command_ready          => commandeready,          --                         .ready
			modular_adc_0_response_valid         => response_valid,         --   modular_adc_0_response.valid
			modular_adc_0_response_channel       => response_channel,       --                         .channel
			modular_adc_0_response_data          => response_data,          --                         .data
			modular_adc_0_response_startofpacket => startofpacket, --                         .startofpacket
			modular_adc_0_response_endofpacket   => endofpacket,   --                         .endofpacket
			reset_reset_n                        => '1'                         --                    reset.reset_n
		);
		
	process (	SW)
	 begin
	  channel <= SW(4 downto 0)  + 1 ; -- les entrées analogique du connecteur Arduino arrivent à partir du canal 1 (canal 0 non utilisé)
	 end process ; 
	 	

   coeur: component numerique 
	PORT  MAP (clk  => clock, -- horloge à 25 Mhz (c0 issu du bloc adc_qsys)
		measure_done  =>    response_valid,  --indique si la conversion AD est finie
		start_trait   =>  sstart_trait,    --pour observation
		fin_trait     => LEDR(0),     --pour observation
		BP0 => KEY(0),                --active low reset sur KEY0
		BP1 => SW(9),
		BP2 => SW(8),
		BP3 => SW(7),               
	   validson => svalidsortie,    -- pour maitrise de la sortie du son
		dataADC => response_data,    -- signal d'entrée converti par l'ADC
		dataDAC => sdataDAC          -- sortie à convertir par le DAC
	 ); 

		
   frequencesortie: component freqsortie port map
           (clk => MAX10_CLK1_50,
			   validsortie =>svalidsortie,
				BP0 => KEY(0),
				ena => sena,
				Fs => sfs
			   );

	interface_DAC: component DAC port map
                ( Tnum => sdataDAC,
					   clk => MAX10_CLK1_50,
						reset_n => KEY(0),
						ena =>  sena,
						sda => ARDUINO_IO(14),
						scl => ARDUINO_IO(15)
					) ;
	
   afficher: component affichage port map
					(clk => clock,
					 response_data => response_data,
					 dataDAC => sdataDAC,
					 response_channel => response_channel,
					 response_valid => response_valid,
					 BP0 => KEY(0),
					 HEX0=>HEX0,HEX1=>HEX1,HEX2=>HEX2,HEX3=>HEX3,HEX4=>HEX4,HEX5=>HEX5
					
					);	
	
-- pour visualisation éventuelle sur carte DIGILENT via le connecteur GPIO
	
	GPIO(0) <= ARDUINO_IO(15); -- sda du bus I2C
	GPIO(1) <= ARDUINO_IO(14); -- scl du bas I2C
	GPIO(2) <= response_valid;
	GPIO(3) <=  sena;
	GPIO(4) <=  clock;
	LEDR(9 downto 1) <= response_data(11 downto 3) ; -- affichage des 8 bits de poids fort de la tension d'entrée sur les leds	
	


		
END structurelle;		

