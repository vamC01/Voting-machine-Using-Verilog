LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY lcd_controller IS
    PORT (
        Clk50Mhz, reset : IN STD_LOGIC;
        LCD_DATA        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  my_output       : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Add this
        total_votes     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Add this
        LCD_RW, LCD_EN, LCD_RS : OUT STD_LOGIC;
        LCD_ON, LCD_BLON : OUT STD_LOGIC
    );
END lcd_controller;

ARCHITECTURE FSMD OF lcd_controller IS

    TYPE state_type IS (s1, s2, s3, s4, s10, s11, s12, s13, s20, s21, s22, s23, s24);
    SIGNAL state : state_type;

    CONSTANT max  : INTEGER := 50000;
    CONSTANT half : INTEGER := max/2;
    SIGNAL clockticks : INTEGER RANGE 0 TO max;
    SIGNAL clock : STD_LOGIC;
	 --SIGNAL my_output : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 2 bits, values 00, 01, 10
	-- SIGNAL total_votes : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Dynamic value to be displayed on LCD (example: 42)
	 

    SUBTYPE ascii IS STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE charArray IS array(1 to 16) OF ascii;
    TYPE initArray IS array(1 to 7) OF ascii;

    -- LCD initialization sequence codes
    CONSTANT initcode : initArray := (x"38", x"38", x"38", x"38", x"06", x"0F", x"01");

    -- Welcome messages
    CONSTANT line2 : charArray := (x"20", x"20", x"54", x"6F", x"20", x"45", x"53", x"44", x"4C", x"20", x"4C", x"61", x"62", x"20", x"20", x"20");

    SIGNAL count : INTEGER;
	 

BEGIN

    LCD_ON   <= '1';
    LCD_BLON <= '1';

    lcd_control: PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            count <= 1;
            state <= s1;
        ELSIF (clock'EVENT AND clock = '1') THEN
            CASE state IS

                -- LCD initialization
                WHEN s1 =>
                    LCD_DATA <= initcode(count);
                    LCD_EN   <= '1';
                    LCD_RS   <= '0';
                    LCD_RW   <= '0';
                    state    <= s2;

                WHEN s2 =>
                    LCD_EN <= '0';
                    count  <= count + 1;
                    IF count + 1 <= 7 THEN
                        state <= s1;
                    ELSE
                        state <= s10;
                    END IF;

                -- Move cursor to first line
                WHEN s10 =>
                    LCD_DATA <= x"80"; -- address 0x80 (start of first line)
                    LCD_EN   <= '1';
                    LCD_RS   <= '0';
                    LCD_RW   <= '0';
                    state    <= s11;

                WHEN s11 =>
                    LCD_EN <= '0';
                    count  <= 1;
                    state  <= s12;

                -- Write first line: dynamic content
                WHEN s12 =>
                    CASE count IS
                        WHEN 1 =>
                            LCD_DATA <= x"57"; -- 'W'
                        WHEN 2 =>
                            LCD_DATA <= x"49"; -- 'i'
                        WHEN 3 =>
                            LCD_DATA <= x"4E"; -- 'n'
                        WHEN 4 =>
                            LCD_DATA <= x"4E"; -- 'n'
                        WHEN 5 =>
                            LCD_DATA <= x"45"; -- 'e'
								WHEN 6 =>
                            LCD_DATA <= x"52"; -- 'r'
								WHEN 7 =>
                            LCD_DATA <= x"3A"; -- ':'
								WHEN 8 =>
                            CASE my_output IS
									 WHEN "00" =>
										LCD_DATA <= x"41"; -- 'A'
									 WHEN "01" =>
										LCD_DATA <= x"42"; -- 'B'
									 WHEN "10" =>
										LCD_DATA <= x"43"; -- 'C'
									WHEN "11" =>
										LCD_DATA <= x"54"; -- 'Tie'
									 WHEN OTHERS =>
										LCD_DATA <= x"20"; -- ' '
									END  CASE;
                        

                        WHEN OTHERS =>
                            LCD_DATA <= x"20"; -- space for rest
                    END CASE;

                    LCD_EN <= '1';
                    LCD_RS <= '1';
                    LCD_RW <= '0';
                    state  <= s13;

                WHEN s13 =>
                    LCD_EN <= '0';
                    count  <= count + 1;
                    IF count + 1 <= 16 THEN
                        state <= s12;
                    ELSE
                        state <= s20;
                    END IF;

                -- Move cursor to second line
                WHEN s20 =>
                    LCD_DATA <= x"BF"; -- address 0xBF (start of second line)
                    LCD_EN   <= '1';
                    LCD_RS   <= '0';
                    LCD_RW   <= '0';
                    state    <= s21;

                WHEN s21 =>
                    LCD_EN <= '0';
                    count  <= 1;
                    state  <= s22;

                -- Write second line (static "To ESDL Lab")
                WHEN s22 =>
    CASE count IS
        WHEN 1 => LCD_DATA <= x"54"; -- T
        WHEN 2 => LCD_DATA <= x"6F"; -- o
        WHEN 3 => LCD_DATA <= x"74"; -- t
        WHEN 4 => LCD_DATA <= x"61"; -- a
        WHEN 5 => LCD_DATA <= x"6C"; -- l
        WHEN 6 => LCD_DATA <= x"3A"; -- :
        WHEN 7 => LCD_DATA <= x"20"; -- space
        WHEN 8 => -- Tens digit of total_votes
            -- Convert total_votes to integer, divide by 10, then convert back to ASCII
            LCD_DATA <= x"30" + (to_integer(unsigned(total_votes)) / 10);
        WHEN 9 => -- Ones digit of total_votes
            -- Convert total_votes to integer, take mod 10, then convert back to ASCII
            LCD_DATA <= x"30" + (to_integer(unsigned(total_votes)) mod 10);
        WHEN OTHERS => LCD_DATA <= x"20"; -- space
    END CASE;
    LCD_EN <= '1';
    LCD_RS <= '1';  -- Data mode
    LCD_RW <= '0';  -- Write mode
    state <= s23;

                WHEN s23 =>
                    LCD_EN <= '0';
                    count  <= count + 1;
                    IF count + 1 <= 16 THEN
                        state <= s22;
                    ELSE
                        state <= s24;
                    END IF;

                WHEN s24 =>
                    state <= s24; -- hold

                WHEN OTHERS =>
                    state <= s24;

            END CASE;
        END IF;
    END PROCESS;

    ClockDivide: PROCESS
    BEGIN
        WAIT UNTIL Clk50Mhz'EVENT and Clk50Mhz = '1';
        IF clockticks < max THEN
            clockticks <= clockticks + 1;
        ELSE
            clockticks <= 0;
        END IF;

        IF clockticks < half THEN
            clock <= '0';
        ELSE
            clock <= '1';
        END IF;
    END PROCESS;

END FSMD;
