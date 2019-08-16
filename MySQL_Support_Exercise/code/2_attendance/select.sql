EXPLAIN SELECT
 i.school_year,
 s.nfirst,
 s.nlast,
 e.pin,
 e.enrollment_flags,
 a.attendance_start,
 a.attendance_end,
 sc.course_no,
 sc.section_no
FROM
 enrollment e
 INNER JOIN student s ON
  e.student_id=s.student_id
 INNER JOIN instprog i ON
  e.instprog_id=i.instprog_id
 INNER JOIN attendance a ON
  e.enrollment_id=a.enrollment_id
 INNER JOIN enrsec es ON
  e.enrollment_id=es.enrollment_id
 INNER JOIN section sc ON
  es.course_no=sc.course_no
  AND es.section_no=sc.section_no
  AND sc.school_year=i.school_year
 AND sc.school_id=i.school_id
WHERE
 i.school_year = 2007
 AND a.attendance_start >= '2007-02-01'
 AND FIND_IN_SET('F', e.enrollment_flags) != 0
 AND i.school_id IN (2,47,119,122);
