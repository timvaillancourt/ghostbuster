CREATE DATABASE IF NOT EXISTS `test`;
USE `test`;

CREATE TABLE `testtable` (
  id bigint AUTO_INCREMENT,
  created_at datetime DEFAULT CURRENT_TIMESTAMP,
  firstname varchar(128) NOT NULL,
  lastname varchar(128) NOT NULL,
  message varchar(128) NOT NULL,
  PRIMARY KEY(`id`),
  KEY `first_lastname_idx` (`firstname`,`lastname`)
) ENGINE=InnoDB;
