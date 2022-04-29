DELIMITER $$
CREATE PROCEDURE `drop_and_create_table_dashboard_base_24h`()
BEGIN

DROP TABLE IF EXISTS dashboard_base_24h;
CREATE TABLE `dashboard_base_24h` (
  `id` bigint NOT NULL,
  `id_api` bigint DEFAULT NULL,
  `address` varchar(45) DEFAULT NULL,
  `currency` varchar(45) DEFAULT NULL,
  `balance_before` decimal(53,20) DEFAULT NULL,
  `balance_current` decimal(53,20) DEFAULT NULL,
  `trading_volume_total` decimal(53,20) DEFAULT NULL,
  `trading_volume_before` decimal(53,20) DEFAULT NULL,
  `trading_volume_current` decimal(53,20) DEFAULT NULL,
  `PNL_total` decimal(53,20) DEFAULT NULL,
  `PNL_before` decimal(53,20) DEFAULT NULL,
  `PNL_current` decimal(53,20) DEFAULT NULL,
  `PNL_usdt_total` decimal(53,20) DEFAULT NULL,
  `PNL_usdt_before` decimal(53,20) DEFAULT NULL,
  `PNL_usdt_current` decimal(53,20) DEFAULT NULL,
  `trading_volume_usdt_total` decimal(53,20) DEFAULT NULL,
  `trading_volume_usdt_before` decimal(53,20) DEFAULT NULL,
  `trading_volume_usdt_current` decimal(53,20) DEFAULT NULL,
  `exchange` varchar(45) DEFAULT NULL,
  `customer_name` varchar(45) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
);

-- this will produce t_dashboard_base
CALL get_dashboard_base(-24);


INSERT INTO dashboard_base_24h
(id, id_api, address, currency, balance_before, balance_current, 
trading_volume_total, trading_volume_before, trading_volume_current, 
PNL_total, PNL_before, PNL_current, PNL_usdt_total,PNL_usdt_before, 
PNL_usdt_current, trading_volume_usdt_total, trading_volume_usdt_before, 
trading_volume_usdt_current, exchange, customer_name)

SELECT 
id, id_api, address, currency, balance_before, balance_current, 
trading_volume_total, trading_volume_before, trading_volume_current, 
PNL_total, PNL_before, PNL_current, PNL_usdt_total,PNL_usdt_before, 
PNL_usdt_current, trading_volume_usdt_total, trading_volume_usdt_before, 
trading_volume_usdt_current, exchange, customer_name


FROM t_dashboard_base;




END$$
DELIMITER ;
