USE makeit;
##DROP TABLE IF EXISTS apis;
DROP TABLE IF EXISTS balances_job;
DROP TABLE IF EXISTS balances_current;
DROP TABLE IF EXISTS balances_change_history;


##CREATE TABLE `apis` (
 ## `id_api` bigint NOT NULL AUTO_INCREMENT,
##  `customer_name` varchar(45) DEFAULT NULL,
##  `exchange` varchar(45) DEFAULT NULL,
 ## `api_key` varchar(45) DEFAULT NULL,
##  `api_secret` varchar(100) DEFAULT NULL,
##  `api_passphrase` varchar(45) DEFAULT NULL,
##  PRIMARY KEY (`id_api`)
##);

CREATE TABLE `balances_job` (
  `id_api` bigint NOT NULL,
  `address` varchar(45) NOT NULL,
  `currency` varchar(45) NOT NULL,
  `balance` decimal(53,20) NOT NULL,
  `inserted_at` datetime NOT NULL,
  PRIMARY KEY (`id_api`,`address`,`currency`)
);

CREATE TABLE `balances_current` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `id_api` bigint NOT NULL,
  `address` varchar(45) NOT NULL,
  `currency` varchar(45) NOT NULL,
  `balance` decimal(53,20) NOT NULL,
  `balance_changed_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
);



CREATE TABLE `balances_change_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `id_api` bigint NOT NULL,
  `address` varchar(45) NOT NULL,
  `currency` varchar(45) NOT NULL,
  `balance` decimal(53,20) NOT NULL,
  `inserted_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
);