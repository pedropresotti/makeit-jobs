DELIMITER $$
CREATE PROCEDURE `drop_and_create_table_balances_job`()
BEGIN

DROP TABLE IF EXISTS balances_job;
CREATE TABLE `balances_job` (
  `id_api` bigint NOT NULL,
  `address` varchar(45) NOT NULL,
  `currency` varchar(45) NOT NULL,
  `balance` decimal(53,20) NOT NULL,
  `inserted_at` datetime NOT NULL,
  PRIMARY KEY (`id_api`,`address`,`currency`)
);

END$$
DELIMITER ;
