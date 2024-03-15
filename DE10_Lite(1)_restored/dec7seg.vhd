library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY dec7seg IS
	PORT (
	valeur : IN std_logic_vector(3 downto 0);
	HEX : out std_logic_vector(6 downto 0) 
	);
END dec7seg;

ARCHITECTURE comportementale OF dec7seg IS

BEGIN	

PROCESS (valeur) 
 BEGIN  
  CASE valeur IS        
	WHEN "0000" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '0';HEX(4) <= '0';HEX(5) <= '0';HEX(6) <= '1'; --0
	
	WHEN "0001" =>  HEX(0) <= '1';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '1';HEX(4) <= '1';HEX(5) <= '1';HEX(6) <= '1'; --1
	
	WHEN "0010" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '1';HEX(3) <= '0';HEX(4) <= '0';HEX(5) <= '1';HEX(6) <= '0'; --2
	
	WHEN "0011" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '0';HEX(4) <= '1';HEX(5) <= '1';HEX(6) <= '0'; --3
	
	WHEN "0100" =>  HEX(0) <= '1';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '1';HEX(4) <= '1';HEX(5) <= '0';HEX(6) <= '0'; --4
	
	WHEN "0101" =>  HEX(0) <= '0';HEX(1) <= '1';HEX(2) <= '0';HEX(3) <= '0';HEX(4) <= '1';HEX(5) <= '0';HEX(6) <= '0'; --5
	
	WHEN "0110" =>  HEX(0) <= '0';HEX(1) <= '1';HEX(2) <= '0';HEX(3) <= '0';HEX(4) <= '0';HEX(5) <= '0';HEX(6) <= '0'; --6
	
	WHEN "0111" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '1';HEX(4) <= '1';HEX(5) <= '1';HEX(6) <= '1'; --7
	
	WHEN "1000" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '0';HEX(4) <= '0';HEX(5) <= '0';HEX(6) <= '0'; --8
	
	WHEN "1001" =>  HEX(0) <= '0';HEX(1) <= '0';HEX(2) <= '0';HEX(3) <= '1';HEX(4) <= '1';HEX(5) <= '0';HEX(6) <= '0'; --9
	
	WHEN OTHERS =>  HEX(0) <= '1';HEX(1) <= '1';HEX(2) <= '1';HEX(3) <= '1';HEX(4) <= '1';HEX(5) <= '1';HEX(6) <= '1'; -- sinon
	
	
	END CASE;
END PROCESS ;

END comportementale;