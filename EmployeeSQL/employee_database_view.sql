-- View: public.employee_database

-- DROP VIEW public.employee_database;

CREATE OR REPLACE VIEW public.employee_database
 AS
 SELECT dm.dept_no,
    d.dept_name,
    dm.emp_no,
    e.last_name,
    e.first_name,
    e.sex,
    s.salary
   FROM dept_manager dm
     JOIN employees e ON dm.emp_no = e.emp_no
     JOIN departments d ON dm.dept_no::text = d.dept_no::text
     JOIN salaries s ON e.emp_no = s.emp_no
  ORDER BY d.dept_name;

ALTER TABLE public.employee_database
    OWNER TO postgres;

