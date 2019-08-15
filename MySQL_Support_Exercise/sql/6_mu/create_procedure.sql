DROP DATABASE IF EXISTS mu;
CREATE DATABASE mu;
USE mu;

DROP TABLE IF EXISTS musers;
CREATE TABLE musers
(
 muser_id INT NOT NULL AUTO_INCREMENT,
 muser_name VARCHAR(30) NOT NULL,
 muser_data VARCHAR(30) NOT NULL,
 muser_group INT NOT NULL,
 PRIMARY KEY (muser_id),
 INDEX (muser_name)
) ENGINE=MyISAM;
INSERT INTO musers (muser_name, muser_data, muser_group) VALUES ('City Track', '0001', 1), ('Person Track', '0002', 2), ('Vehicle Track', '0003', 2);

DROP TABLE IF EXISTS mu_0001;
CREATE TABLE mu_0001
(
 city_id INT NOT NULL AUTO_INCREMENT,
 city_name VARCHAR(30),
 city_state CHAR(2),
 city_primary_code INT,
 PRIMARY KEY (city_id),
 INDEX (city_state),
 INDEX (city_primary_code)
) ENGINE=MyISAM;
INSERT INTO mu_0001 (city_name, city_state, city_primary_code) VALUES ('Clarksville', 'TN', 37040), ('Cupertino', 'CA', 94025), ('Long Island City', 'NY', 11101);

DROP TABLE IF EXISTS mu_0002;
CREATE TABLE mu_0002
(
 person_id INT NOT NULL AUTO_INCREMENT,
 person_name VARCHAR(100),
 person_salary DECIMAL(8,2),
 person_jobdesc TEXT,
 PRIMARY  KEY (person_id),
 INDEX (person_name)
) ENGINE=MyISAM;
INSERT INTO mu_0002 (person_name, person_salary, person_jobdesc) VALUES ('Bud Meiers', 14000.00, 'Gardener'), ('Zank Frappa', 250000.00, 'Sitar Tuner'), ('Frank N. Stein', 35000.00, 'Greeter');

DROP TABLE IF EXISTS mu_0003;
CREATE TABLE mu_0003
(
 vehicle_id INT NOT NULL AUTO_INCREMENT,
 vehicle_type INT NOT NULL,
 vehicle_color INT NOT NULL,
 vehicle_year INT NOT NULL,
 vehicle_price DECIMAL(8,2),
 PRIMARY KEY (vehicle_id),
 INDEX (vehicle_type),
 INDEX (vehicle_year),
 INDEX (vehicle_color)
) ENGINE=MyISAM;
INSERT INTO mu_0003 (vehicle_type, vehicle_color, vehicle_year, vehicle_price) VALUES (1, 2, 1979, 1000.00), (1, 1, 1984, 250.00), (3,18,2006,35749.00);

-- mu_fetch( in_muser_group INT, mdata VARCHAR(30) )
-- If mdata is provided, return results for the mu_ table with that suffix
-- Otherwise, retrieve muser_data from musers for all users that
-- belong to the specified muser_group.

DELIMITER $$
DROP PROCEDURE IF EXISTS mu_fetch$$
	CREATE PROCEDURE mu_fetch( in_muser_group INT, mdata VARCHAR(30) )
	BEGIN
    	DECLARE done INT DEFAULT 0;
    	DECLARE psql VARCHAR(200);
    	DECLARE cr CURSOR FOR 
        	SELECT muser_data FROM musers 
        		WHERE muser_group = in_muser_group;
        DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
    	    IF mdata <> '' THEN
        	    SET @psql= CONCAT('SELECT * FROM mu_', mdata);
        	    PREPARE stmt FROM @psql;
        	    EXECUTE stmt;
        	    DEALLOCATE PREPARE stmt;
    	    ELSE
        	    OPEN cr;
        	    REPEAT
            	    FETCH cr INTO mdata;
            	    IF NOT done THEN
                	SET @psql= CONCAT('SELECT muser_data FROM musers WHERE muser_group = ', mdata);
                	PREPARE stmt FROM @psql;
                	EXECUTE stmt;
                	DEALLOCATE PREPARE stmt;
            	    END IF;
        	    UNTIL done
        	    END REPEAT;
        	    CLOSE cr;
    	    END IF;
    END$$
	