DELIMITER $$
CREATE PROCEDURE `update_variations`()
main: BEGIN
DECLARE i bigint DEFAULT 0;
DECLARE j bigint DEFAULT 0;
DECLARE w bigint DEFAULT 0;

DECLARE v_id_row_next bigint;
DECLARE v_id_api bigint;
DECLARE v_address varchar(45);
DECLARE v_currency varchar(45);

DECLARE row_count_all_distinct bigint DEFAULT 0;
DECLARE row_count_dist bigint DEFAULT 0;


DECLARE v_balance_row_current decimal(53,20);
DECLARE v_balance_row_next decimal(53,20);


DECLARE v_id_row_first decimal(53,20);
DECLARE v_variation_row_first decimal(53,20);

DECLARE v_variation_row_next decimal(53,20);


DROP TEMPORARY TABLE IF EXISTS all_distinct;

CREATE TEMPORARY TABLE all_distinct AS 
(SELECT DISTINCT id_api, address, currency FROM balances_change_history WHERE variation IS NULL);

SELECT COUNT(*) FROM all_distinct INTO row_count_all_distinct;
IF row_count_all_distinct = 0 THEN
    LEAVE main;
END IF;

SET i = 0;


WHILE i < row_count_all_distinct DO 
    
	SELECT id_api, address, currency FROM all_distinct LIMIT i, 1 
		INTO v_id_api, v_address, v_currency;

	
	DROP TEMPORARY TABLE IF EXISTS dist;
	CREATE TEMPORARY TABLE dist AS 
	(SELECT * FROM balances_change_history WHERE 
		id_api = v_id_api AND address = v_address AND currency = v_currency ORDER BY inserted_at);
	
	SELECT COUNT(*) FROM dist INTO row_count_dist;
	
    SET j = 0;
    SET w = 0;
    SET v_id_row_next = -1;
    SET v_balance_row_current = NULL;
    SET v_balance_row_next = NULL;
	SET v_variation_row_first = NULL;
    
    SELECT id, variation FROM dist LIMIT 0, 1 
		INTO v_id_row_first, v_variation_row_first;
    
    
    UPDATE balances_change_history SET variation = 0
		WHERE id = v_id_row_first AND v_variation_row_first IS NULL;
    
	aa: WHILE j < row_count_dist DO 
		
      
		SET w = j + 1;
        IF w = row_count_dist THEN
            LEAVE aa;
		END IF;
        
        
        SELECT id, balance, variation FROM dist LIMIT w, 1 
			INTO v_id_row_next, v_balance_row_next, v_variation_row_next;
            
		
        
		IF v_variation_row_next IS NULL THEN

			SELECT balance FROM dist LIMIT j, 1 INTO v_balance_row_current;

			UPDATE balances_change_history SET variation = v_balance_row_next - v_balance_row_current
				WHERE id = v_id_row_next;
        
        END IF;
        
        
		
        

		SET j = j + 1;
	END WHILE;

	SET i = i + 1;
END WHILE;
END$$
DELIMITER ;
