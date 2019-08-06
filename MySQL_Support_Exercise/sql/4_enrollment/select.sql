SELECT
 student.nfirst,
 student.nlast,
 inprog.syear,
 enrollment.pin,
 section.title,
 section.course
 FROM
 student,
 enrollment,
 inprog
 LEFT JOIN clsenr ON
  clsenr.enr_id= enrollment.enr_id
 LEFT JOIN section ON
  section.sec_id= clsenr.sec_id
 WHERE
  enrollment.std_id = student.std_id
  AND enrollment.inprog_id = inprog.inprog_id
  AND inprog.syear= 2007
  AND inprog.sch_id= 1473
