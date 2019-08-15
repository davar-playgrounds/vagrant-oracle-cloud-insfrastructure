DROP DATABASE IF EXISTS population;
CREATE DATABASE population;
USE population; 

DROP TABLE IF EXISTS City;
CREATE TABLE City
(
  instprog_id INT NOT NULL,
  ID INT NOT NULL,
  CountryCode VARCHAR(30) NOT NULL,
  Name VARCHAR(200) NOT NULL,
  District VARCHAR(200),
  Population INT NOT NULL
) ENGINE=MyISAM;