DELIMITER $$
CREATE PROCEDURE `get_dashboard_base`(IN time_before_in_hours INT)
BEGIN

## will produce temp tables 't_balances_before_x_balances_current' and 't_PNL_TV_info' and join them, 
## the join will create 'makeit.t_dashboard_base', to be used as base for related queries.


## 'makeit.t_dashboard_base' has the schema:

-- CREATE TABLE `t_dashboard_base` (
--   `id` bigint NOT NULL AUTO_INCREMENT,
--   `id_api` bigint,
--   `address` varchar(45),
--   `currency` varchar(45),
--   `balance_before` decimal(53,20) DEFAULT NULL,
--   `balance_current` decimal(53,20),
--   `trading_volume_total` decimal(65,20) DEFAULT NULL,
--   `trading_volume_before` decimal(65,20) DEFAULT NULL,
--   `trading_volume_current` decimal(65,20) DEFAULT NULL,
--   `PNL_total` decimal(65,20) DEFAULT NULL,
--   `PNL_before` decimal(65,20) DEFAULT NULL,
--   `PNL_current` decimal(65,20) DEFAULT NULL,
--   `trading_volume_usdt_total` decimal(65,20) DEFAULT NULL,
--   `trading_volume_usdt_before` decimal(65,20) DEFAULT NULL,
--   `trading_volume_usdt_current` decimal(65,20) DEFAULT NULL,
--   `PNL_usdt_total` decimal(65,20) DEFAULT NULL,
--   `PNL_usdt_before` decimal(65,20) DEFAULT NULL,
--   `PNL_usdt_current` decimal(65,20) DEFAULT NULL,
--   `exchange` varchar(45) DEFAULT NULL,
--   `customer_name` varchar(45) DEFAULT NULL,
--   UNIQUE KEY `id` (`id`)
-- )


DROP TEMPORARY TABLE IF EXISTS t_state_before;


CREATE TEMPORARY TABLE t_state_before
AS
(
SELECT id_api, address, currency, MAX(inserted_at) AS inserted_at FROM balances_change_history 
WHERE inserted_at <= date_add(UTC_TIMESTAMP(), interval time_before_in_hours hour)
GROUP BY id_api, address, currency



);

ALTER TABLE t_state_before ADD id bigint NOT NULL AUTO_INCREMENT UNIQUE FIRST;
ALTER TABLE t_state_before ADD balance decimal(53,20) NULL;



UPDATE t_state_before
INNER JOIN balances_change_history ON
t_state_before.id_api = balances_change_history.id_api AND
t_state_before.address = balances_change_history.address AND
t_state_before.currency = balances_change_history.currency AND
t_state_before.inserted_at = balances_change_history.inserted_at
SET t_state_before.balance = balances_change_history.balance
WHERE t_state_before.id > 0;


##SELECT * FROM t_state_before;


DROP TEMPORARY TABLE IF EXISTS t_state_before_x_state_current;
CREATE TEMPORARY TABLE t_state_before_x_state_current
AS
(
SELECT balances_current.id_api,
balances_current.address, balances_current.currency, 

CASE
WHEN t_state_before.balance IS NULL THEN 0
ELSE t_state_before.balance
END AS balance_before,

balances_current.balance AS balance_current

FROM balances_current LEFT JOIN t_state_before ON
t_state_before.id_api = balances_current.id_api AND
t_state_before.address = balances_current.address AND 
t_state_before.currency = balances_current.currency

);


DROP TEMPORARY TABLE IF EXISTS t_balances_before_x_balances_current;
ALTER TABLE t_state_before_x_state_current RENAME t_balances_before_x_balances_current;

##SELECT * FROM t_balances_before_x_balances_current;


######################### PNL and trading valume
DROP TEMPORARY TABLE IF EXISTS t_state_before;


	CREATE TEMPORARY TABLE t_state_before
	AS
	(

	SELECT id_api, address, currency, 
    SUM(variation) AS PNL, 
    SUM(abs(variation)) AS trading_volume,
    SUM(variation * price_in_usdt) AS PNL_usdt,
    SUM(abs(variation * price_in_usdt)) AS trading_volume_usdt
    FROM balances_change_history 
	WHERE inserted_at >= date_add(UTC_TIMESTAMP(), interval (time_before_in_hours * 2) hour) AND inserted_at < date_add(UTC_TIMESTAMP(), interval time_before_in_hours hour)
	GROUP BY id_api, address, currency



	);
	##SELECT * FROM t_state_before;

	DROP TEMPORARY TABLE IF EXISTS t_state_current;


	CREATE TEMPORARY TABLE t_state_current
	AS
	(

	SELECT id_api, address, currency, SUM(variation) AS PNL, 
    SUM(abs(variation)) AS trading_volume,
    SUM(variation * price_in_usdt) AS PNL_usdt,
    SUM(abs(variation * price_in_usdt)) AS trading_volume_usdt
    
    FROM balances_change_history 
	WHERE inserted_at >= date_add(UTC_TIMESTAMP(), interval time_before_in_hours hour)
	GROUP BY id_api, address, currency



	);

	DROP TEMPORARY TABLE IF EXISTS t_state_before_x_state_current;
	CREATE TEMPORARY TABLE t_state_before_x_state_current
	AS
	(
	SELECT t_state_current.id_api,
	t_state_current.address, t_state_current.currency,

	CASE
	WHEN t_state_before.PNL IS NULL THEN 0
	ELSE t_state_before.PNL
	END AS PNL_before,
	t_state_current.PNL AS PNL_current,


	CASE
	WHEN t_state_before.trading_volume IS NULL THEN 0
	ELSE t_state_before.trading_volume
	END AS trading_volume_before,
	t_state_current.trading_volume AS trading_volume_current,
    
    
    CASE
	WHEN t_state_before.PNL_usdt IS NULL THEN 0
	ELSE t_state_before.PNL_usdt
	END AS PNL_usdt_before,
	t_state_current.PNL_usdt AS PNL_usdt_current,


	CASE
	WHEN t_state_before.trading_volume_usdt IS NULL THEN 0
	ELSE t_state_before.trading_volume_usdt
	END AS trading_volume_usdt_before,
	t_state_current.trading_volume_usdt AS trading_volume_usdt_current





	FROM t_state_current LEFT JOIN t_state_before ON
	t_state_before.id_api = t_state_current.id_api AND
	t_state_before.address = t_state_current.address AND 
	t_state_before.currency = t_state_current.currency

	);




	##SELECT * FROM t_state_before_x_state_current;






	DROP TEMPORARY TABLE IF EXISTS t_Total_PNL_TV;
	CREATE TEMPORARY TABLE t_Total_PNL_TV
	AS
	(
	SELECT id_api, address, currency, SUM(variation) AS PNL_total, 
    SUM(abs(variation)) AS trading_volume_total,
    
    SUM(variation * price_in_usdt) AS PNL_usdt_total,
    SUM(abs(variation * price_in_usdt)) AS trading_volume_usdt_total
    
    
    FROM balances_change_history 
	GROUP BY id_api, address, currency



	);







	DROP TEMPORARY TABLE IF EXISTS t_PNL_TV_info;
	CREATE TEMPORARY TABLE t_PNL_TV_info
	AS
	(

	SELECT t_Total_PNL_TV.id_api,
	t_Total_PNL_TV.address,
	t_Total_PNL_TV.currency,




	CASE 
	WHEN t_Total_PNL_TV.trading_volume_total IS NULL THEN 0 
	ELSE t_Total_PNL_TV.trading_volume_total END AS trading_volume_total,

	CASE 
	WHEN t_state_before_x_state_current.trading_volume_before IS NULL THEN 0 
	ELSE t_state_before_x_state_current.trading_volume_before END AS trading_volume_before,

	CASE 
	WHEN t_state_before_x_state_current.trading_volume_current IS NULL THEN 0 
	ELSE t_state_before_x_state_current.trading_volume_current END AS trading_volume_current,

	CASE 
	WHEN t_Total_PNL_TV.PNL_total IS NULL THEN 0 
	ELSE t_Total_PNL_TV.PNL_total END AS PNL_total,

	CASE 
	WHEN t_state_before_x_state_current.PNL_before IS NULL THEN 0 
	ELSE t_state_before_x_state_current.PNL_before END AS PNL_before,

	CASE 
	WHEN t_state_before_x_state_current.PNL_current IS NULL THEN 0 
	ELSE t_state_before_x_state_current.PNL_current END AS PNL_current,
    
    CASE 
	WHEN t_Total_PNL_TV.PNL_usdt_total IS NULL THEN 0 
	ELSE t_Total_PNL_TV.PNL_usdt_total END AS PNL_usdt_total,
    
    CASE 
	WHEN t_state_before_x_state_current.PNL_usdt_before IS NULL THEN 0 
	ELSE t_state_before_x_state_current.PNL_usdt_before END AS PNL_usdt_before,

	CASE 
	WHEN t_state_before_x_state_current.PNL_usdt_current IS NULL THEN 0 
	ELSE t_state_before_x_state_current.PNL_usdt_current END AS PNL_usdt_current,
    
	CASE 
	WHEN t_Total_PNL_TV.trading_volume_usdt_total IS NULL THEN 0 
	ELSE t_Total_PNL_TV.trading_volume_usdt_total END AS trading_volume_usdt_total,

	CASE 
	WHEN t_state_before_x_state_current.trading_volume_usdt_before IS NULL THEN 0 
	ELSE t_state_before_x_state_current.trading_volume_usdt_before END AS trading_volume_usdt_before,

	CASE 
	WHEN t_state_before_x_state_current.trading_volume_usdt_current IS NULL THEN 0 
	ELSE t_state_before_x_state_current.trading_volume_usdt_current END AS trading_volume_usdt_current

	FROM t_Total_PNL_TV
	LEFT JOIN t_state_before_x_state_current ON 
	t_Total_PNL_TV.id_api = t_state_before_x_state_current.id_api
	AND t_Total_PNL_TV.address = t_state_before_x_state_current.address 
	AND t_Total_PNL_TV.currency = t_state_before_x_state_current.currency



	);



#join table 't_balances_before_x_balances_current' and 't_PNL_TV_info'

DROP TEMPORARY TABLE IF EXISTS t_dashboard_base;
CREATE TEMPORARY TABLE t_dashboard_base
	AS
	(
	

 SELECT t_balances_before_x_balances_current.id_api, 
 t_balances_before_x_balances_current.address,
  t_balances_before_x_balances_current.currency,
  t_balances_before_x_balances_current.balance_before,
    t_balances_before_x_balances_current.balance_current,
    t_PNL_TV_info.trading_volume_total,
    t_PNL_TV_info.trading_volume_before,
    t_PNL_TV_info.trading_volume_current,
    t_PNL_TV_info.PNL_total,
    t_PNL_TV_info.PNL_before,
    t_PNL_TV_info.PNL_current,
    
    t_PNL_TV_info.PNL_usdt_total,
    t_PNL_TV_info.PNL_usdt_before,
    t_PNL_TV_info.PNL_usdt_current,
    
    t_PNL_TV_info.trading_volume_usdt_total,
    t_PNL_TV_info.trading_volume_usdt_before,
    t_PNL_TV_info.trading_volume_usdt_current
    
    
    
    
    
 
 
 
 
 
 FROM t_PNL_TV_info LEFT JOIN t_balances_before_x_balances_current ON
 t_PNL_TV_info.id_api = t_balances_before_x_balances_current.id_api AND
 t_PNL_TV_info.address = t_balances_before_x_balances_current.address AND
 t_PNL_TV_info.currency = t_balances_before_x_balances_current.currency
	);




ALTER TABLE t_dashboard_base ADD id bigint NOT NULL AUTO_INCREMENT UNIQUE FIRST;
ALTER TABLE t_dashboard_base ADD exchange varchar(45) NULL;
ALTER TABLE t_dashboard_base ADD customer_name varchar(45) NULL;

UPDATE t_dashboard_base
INNER JOIN apis ON
t_dashboard_base.id_api = apis.id_api
SET t_dashboard_base.exchange = apis.exchange,
t_dashboard_base.customer_name = apis.customer_name
WHERE t_dashboard_base.id > 0;


DROP TEMPORARY TABLE IF EXISTS t_state_before;
DROP TEMPORARY TABLE IF EXISTS t_state_before_x_state_current;
DROP TEMPORARY TABLE IF EXISTS t_state_current;
DROP TEMPORARY TABLE IF EXISTS t_Total_PNL_TV;
DROP TEMPORARY TABLE IF EXISTS t_PNL_TV_info;
DROP TEMPORARY TABLE IF EXISTS t_balances_before_x_balances_current;





END$$
DELIMITER ;
