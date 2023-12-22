CREATE DATABASE IF NOT EXISTS `test`;
USE `test`;

CREATE TABLE `testtable` (
  id bigint AUTO_INCREMENT,
  created_at datetime DEFAULT CURRENT_TIMESTAMP,
  message varchar(128),
  PRIMARY KEY('id')
) ENGINE=InnoDB;
