DROP DATABASE IF EXISTS attendance;
CREATE DATABASE attendance;
USE attendance;

DROP TABLE IF EXISTS instprog;
CREATE TABLE instprog
(
 school_id INT NOT NULL,
 school_year INT NOT NULL,
 instprog_id INT NOT NULL,
 INDEX (school_id, school_year)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS enrollment;
CREATE TABLE enrollment
(
  instprog_id INT NOT NULL,
  student_id INT NOT NULL,
  enrollment_id INT NOT NULL,
  pin VARCHAR(30) NOT NULL,
  enrollment_flags VARCHAR(200),
  sp419 CHAR(1) NOT NULL,
  primary_enr CHAR(1) NOT NULL,
  disc_pt_tl INT NOT NULL,
  locker INT NOT NULL,
  homeroom INT NOT NULL,
  INDEX(student_id,pin)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS student;
CREATE TABLE student
(
  student_id INT NOT NULL,
  nfirst VARCHAR(30) NOT NULL,
  nmid VARCHAR(30) NOT NULL,
  nlast VARCHAR(50) NOT NULL,
  ssn VARCHAR(10) NOT NULL,
  current_photo LONGBLOB,
  guardian_photo LONGBLOB,
  med_waiver LONGBLOB,
  guardianship CHAR(1) NOT NULL,
  INDEX (student_id),
  INDEX (ssn)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance
(
  enrollment_id INT NOT NULL,
  attendance_start DATETIME NOT NULL,
  attendance_end DATETIME NOT NULL,
  attendance_code CHAR(3) NOT NULL,
  attendance_note LONGBLOB,
  INDEX (attendance_start, enrollment_id)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS enrsec;
CREATE TABLE enrsec
(
  enrollment_id INT NOT NULL,
  course_no INT NOT NULL,
  section_no INT NOT NULL
) ENGINE=MyISAM;

DROP TABLE IF EXISTS section;
CREATE TABLE section
(
  school_id INT NOT NULL,
  school_year INT NOT NULL,
  course_no INT NOT NULL,
  section_no INT NOT NULL,
  sec_title VARCHAR(50),
  room_no INT NOT NULL,
  gpasys_id INT NOT NULL,
  seats_max INT NOT NULL,
  period INT NOT NULL,
  dayplan_id INT NOT NULL,
  INDEX (section_no, course_no)
) ENGINE=MyISAM;

/*INSERT INTO instprog(school_id,school_year,instprog_id) VALUES(1,2007,1);
INSERT INTO section(school_id,school_year,course_no,section_no,room_no,gpasys_id,seats_max,period,dayplan_id) VALUES(TODO);
INSERT INTO student(student_id,nfirst,nmid,nlast,ssn,guardianship) VALUES(TODO);
INSERT INTO enrollment(instprog_id,student_id,enrollment_id,pin,enrollment_flags,p419,primary_enr,disc_pt_tl,locker,homeroom) VALUES(1,1,1,'F,P',TODO);
INSERT INTO enrsec(enrollment_id,course_no,section_no) VALUES(TODO);
INSERT INTO attendance(enrollment_id,attendance_start,attendance_end,attendance_code) VALUES(TODO,'2007-02-01',TODO);
*/
