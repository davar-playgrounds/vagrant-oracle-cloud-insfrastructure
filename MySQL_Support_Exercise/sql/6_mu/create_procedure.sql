CREATE PROCEDURE mu_fetch( muser_group INT, mdata VARCHAR(30) )
BEGIN
 DECLARE mdata VARCHAR(30);
 DECLARE done INT;
 DECLARE psql VARCHAR(200);
 DECLARE cr CURSOR FOR SELECT muser_data WHERE muser_group = muser_group;
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 0;
 BEGIN
 IF mdata <> '' THEN
  SET psql= CONCAT('SELECT * FROM mu_', mdata);
  PREPARE stmt FROM psql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
 ELSE
  OPEN cr;
  REPEAT
   FETCH cr INTO mdata;
   IF NOT done THEN
    SET psql= CONCAT('SELECT * FROM mu_', mdata);
    PREPARE stmt FROM psql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
   END IF
  UNTIL done END REPEAT;
 END IF
 CLOSE cr;
 END
END
