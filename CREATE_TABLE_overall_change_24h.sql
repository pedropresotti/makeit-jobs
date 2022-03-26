USE makeit;

DROP TEMPORARY TABLE IF EXISTS MAX_inserted_before_24h;
CREATE TEMPORARY TABLE MAX_inserted_before_24h
AS
(

SELECT id_api, address, currency, MAX(inserted_at) AS inserted_at FROM balances_change_history 
WHERE inserted_at <= date_add(UTC_TIMESTAMP(), interval -24 hour)
GROUP BY id_api, address, currency
);



DROP TEMPORARY TABLE IF EXISTS balances_before_24h;
CREATE TEMPORARY TABLE balances_before_24h
AS
(

SELECT balances_change_history.* FROM balances_change_history
INNER JOIN MAX_inserted_before_24h ON
balances_change_history.id_api = MAX_inserted_before_24h.id_api AND
balances_change_history.address = MAX_inserted_before_24h.address AND
balances_change_history.currency = MAX_inserted_before_24h.currency AND
balances_change_history.inserted_at = MAX_inserted_before_24h.inserted_at
);

DROP TEMPORARY TABLE IF EXISTS balances_before_24h_x_balances_current;
CREATE TEMPORARY TABLE balances_before_24h_x_balances_current
AS
(
SELECT balances_current.id_api,
balances_current.address, balances_current.currency, 

CASE
WHEN balances_before_24h.balance IS NULL THEN 0
ELSE balances_before_24h.balance
END AS balance_before_24h,

balances_current.balance AS balance_current

FROM balances_current LEFT JOIN balances_before_24h ON
balances_before_24h.id_api = balances_current.id_api AND
balances_before_24h.address = balances_current.address AND 
balances_before_24h.currency = balances_current.currency

);

DROP TEMPORARY TABLE IF EXISTS overall_before_24h_x_overall_current;
CREATE TEMPORARY TABLE overall_before_24h_x_overall_current
AS
(
SELECT currency, SUM(balance_before_24h) AS overall_before_24h, SUM(balance_current) AS overall_current 
FROM balances_before_24h_x_balances_current GROUP BY currency

);



DROP TABLE IF EXISTS overall_change_24h;
CREATE TABLE `overall_change_24h` (
  `currency` varchar(45) NOT NULL,
  `overall_before_24h` decimal(53,20) NOT NULL,
  `overall_current` decimal(53,20) NOT NULL,
  `change_24h` decimal(53,20) NULL
);

INSERT INTO overall_change_24h (currency, overall_before_24h, overall_current, change_24h)

SELECT currency, overall_before_24h, overall_current, 

CASE
WHEN (overall_before_24h = 0 AND overall_current > 0) THEN 100
WHEN (overall_before_24h = 0 AND overall_current = 0) THEN 0
ELSE (overall_current/overall_before_24h - 1) * 100 
END AS overall_change_24h 

FROM overall_before_24h_x_overall_current;