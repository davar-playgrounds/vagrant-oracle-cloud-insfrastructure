EXPLAIN SELECT
 ID,
 CountryCode,
 Name,
 District,
 Population
 FROM
  City
 WHERE
  (CountryCode, Population) IN (
   SELECT
   CountryCode, MAX(Population) AS Population
   FROM City
   GROUP BY CountryCode
  );
