DELIMITER $$
CREATE PROCEDURE `balances_job`()
BEGIN
SET autocommit=0;
START TRANSACTION;
################################################
## balances_job is the temp table where the server_api_job dumps its data. 
## balances_jobs is always recreated prior to the server_api_job dump.

## insert into balances_current and into balances_change_history
## all rows from balances_job that do not exist in balances_current
DROP TABLE IF EXISTS tmp_changed;
CREATE TABLE tmp_changed LIKE balances_job;
INSERT INTO tmp_changed (id_api, address, currency, balance, inserted_at)


SELECT id_api, address, currency, balance, inserted_at FROM balances_job
WHERE NOT EXISTS

(SELECT * FROM balances_current WHERE 
balances_current.id_api = balances_job.id_api
AND balances_current.address = balances_job.address
AND balances_current.currency = balances_job.currency
AND balances_current.balance = balances_job.balance);


INSERT INTO balances_change_history (id_api, address, currency, balance, inserted_at)
SELECT id_api, address, currency, balance, inserted_at FROM tmp_changed;
INSERT INTO balances_current (id_api, address, currency, balance, balance_changed_at)
SELECT id_api, address, currency, balance, inserted_at FROM tmp_changed;

################################################




## preserve only the most recent rows from balances_current
################################################

DROP TABLE IF EXISTS tmp_max;
CREATE TABLE tmp_max (
  `id_api` bigint NOT NULL,
  `address` varchar(45) NOT NULL,
  `currency` varchar(45) NOT NULL,
  `inserted_at` datetime NOT NULL);


INSERT INTO tmp_max (id_api, address, currency, inserted_at)

SELECT id_api, address, currency, MAX(balance_changed_at)
FROM balances_current
GROUP BY id_api, address, currency;




DELETE balances_current.* FROM balances_current
INNER JOIN tmp_max ON
balances_current.id_api = tmp_max.id_api AND
balances_current.address = tmp_max.address AND
balances_current.currency = tmp_max.currency

WHERE
balances_current.balance_changed_at < tmp_max.inserted_at

##to bypass mysql safe mode
AND balances_current.id > 0;
################################################








DROP TABLE tmp_changed;
DROP TABLE tmp_max;
COMMIT;
SET autocommit=1;
END$$
DELIMITER ;
