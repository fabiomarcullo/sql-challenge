# SQL-challenge
## Background
It’s been two weeks since you were hired as a new data engineer at Pewlett Hackard (a fictional company). Your first major task is to do a research project about people whom the company employed during the 1980s and 1990s. All that remains of the employee database from that period are six CSV files.

For this project, you’ll design the tables to hold the data from the CSV files, import the CSV files into a SQL database, and then answer questions about the data. That is, you’ll perform data modeling, data engineering, and data analysis, respectively.

## Objectives
This research project consists of designing the tables that will hold the CSV data, import the CSVs into a SQL database, and answer a series of questions about the data. The tasks will consist of:

    1. Data Modeling
    2. Data Engineering
    3. Data Analysis

## Data Modeling
Inspect the CSV files, and then sketch an Entity Relationship Diagram of the tables. To create the sketch, feel free to use a tool like QuickDBD

![.](../EmployeeSQL/Diagram/diagrama.png)

## Data Engineering
1 - Use the provided information to create a table schema for each of the six CSV files. Be sure to do the following:

	- Remember to specify the data types, primary keys, foreign keys, and other constraints.

	- For the primary keys, verify that the column is unique. Otherwise, create a composite keyLinks to an external site., which takes two primary keys to uniquely identify a row.

	- Be sure to create the tables in the correct order to handle the foreign keys.

2 - Import each CSV file into its corresponding SQL table.

#PostgreSQL

CREATE TABLE "departments" (
    "dept_no" varchar(4)   NOT NULL,
    "dept_name" varchar(255)   NOT NULL,
    CONSTRAINT "pk_departments" PRIMARY KEY (
        "dept_no"
     )
);

CREATE TABLE "dept_emp" (
    "emp_no" INTEGER   NOT NULL,
    "dept_no" varchar(4)   NOT NULL
);

CREATE TABLE "dept_manager" (
    "dept_no" varchar(4)   NOT NULL,
    "emp_no" INTEGER   NOT NULL
);

CREATE TABLE "employees" (
    "emp_no" INTEGER   NOT NULL,
    "emp_title_id" varchar(5)   NOT NULL,
    "birth_date" DATE   NOT NULL,
    "first_name" varchar(255)   NOT NULL,
    "last_name" varchar(255)   NOT NULL,
    "sex" varchar(1)   NOT NULL,
    "hire_date" DATE   NOT NULL,
    CONSTRAINT "pk_employees" PRIMARY KEY (
        "emp_no"
     )
);

CREATE TABLE "salaries" (
    "emp_no" INTEGER   NOT NULL,
    "salary" FLOAT   NOT NULL
);

CREATE TABLE "titles" (
    "title_id" varchar(5)   NOT NULL,
    "title" varchar(255)   NOT NULL,
    CONSTRAINT "pk_titles" PRIMARY KEY (
        "title_id"
     )
);

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

ALTER TABLE "dept_manager" ADD CONSTRAINT "fk_dept_manager_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

ALTER TABLE "dept_manager" ADD CONSTRAINT "fk_dept_manager_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "employees" ADD CONSTRAINT "fk_employees_emp_title_id" FOREIGN KEY("emp_title_id")
REFERENCES "titles" ("title_id");

ALTER TABLE "salaries" ADD CONSTRAINT "fk_salaries_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");
```

## Data Analysis
1. List the employee number, last name, first name, sex, and salary of each employee.

#PostgreSQL

SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no;

2. List the first name, last name, and hire date for the employees who were hired in 1986.

#PostgreSQL

SELECT first_name, last_name, hire_date 
FROM employees
WHERE hire_date BETWEEN '1986-1-1' and '1986-12-31'
ORDER BY hire_date ASC;

3. List the manager of each department along with their department number, department name, employee number, last name, and first name.

#PostgreSQL

SELECT dm.dept_no, d.dept_name, dm.emp_no, e.last_name, e.first_name 
FROM dept_manager dm
JOIN employees e
ON dm.emp_no = e.emp_no
JOIN departments d
ON dm.dept_no = d.dept_no
ORDER BY d.dept_name ASC;

4. List the department number for each employee along with that employee’s employee number, last name, first name, and department name.

#PostgreSQL

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
ORDER BY d.dept_name ASC;

5. List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B.

#PostgreSQL

SELECT first_name, last_name, sex
FROM employees 
WHERE first_name = 'Hercules' AND last_name LIKE 'B%'
ORDER BY last_name ASC;

6. List each employee in the Sales department, including their employee number, last name, and first name.

#PostgreSQL

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
WHERE d.dept_name = 'Sales';

7. List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name.

#PostgreSQL

SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
WHERE d.dept_name = 'Sales' OR d.dept_name = 'Development'
ORDER BY d.dept_name ASC;

8. List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name).

#PostgreSQL

SELECT last_name, count(emp_no) as num_employees_with_same_last_name
FROM employees
GROUP BY last_name
ORDER BY num_employees_with_same_last_name DESC;

## Create and employee_database view to be used on Python
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

#Bonus

# dependencies and set up
from sqlalchemy import create_engine
import pandas as pd
from matplotlib import pyplot as plt


# establish connection string
engine = create_engine('postgresql://postgres:password@localhost/EmployeeSQL')

# Select employee_database view to create all graphics
employee = "SELECT * FROM employee_database"

# Select departments to create all graphics
departments = "SELECT * FROM departments"

#create all df

departmentsdf = pd.read_sql(departments, con=engine)
employeedf = pd.read_sql(employee, con=engine)

# histogram of Salary Ranges by employee Sex

# Create a figure with two subplots side by side
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6), sharey=True)

# Plot the histogram for male employees
male_salaries = employeedf[employeedf['sex'] == 'M']['salary']
ax1.hist(male_salaries, bins=20, color='blue', alpha=0.7)
ax1.set_xlabel('Annual Salary')
ax1.set_ylabel('Number of Employees')
ax1.set_title('Salary Ranges for Male Employees')


# Plot the histogram for female employees
female_salaries = employeedf[employeedf['sex'] == 'F']['salary']
ax2.hist(female_salaries, bins=20, color='pink', alpha=0.7)
ax2.set_xlabel('Annual Salary')
ax2.set_ylabel('Number of Employees')
ax2.set_title('Salary Ranges for Female Employees')

plt.suptitle('Salary Ranges by Sex')
plt.savefig('images/histogram_salaries.png')
plt.show()

![Employees](EmployeeSQL/images/histogram_salaries.png)

## Plot Average Salary by Sex and Department

# List of all department names
departments = employeedf["dept_name"].unique()

# Loop through each department and create a plot
for department in departments:
    # Subset the data for the current department
    department_data = employeedf[employeedf["dept_name"] == department]
    
    # Calculate the average salary for each sex
    sex_salary = department_data.groupby("sex")["salary"].mean().reset_index()
    
    # Create the bar chart
    plt.figure(figsize=(6, 4))
    plt.bar(sex_salary["sex"], sex_salary["salary"], color=["navy", "darkmagenta"])
    
    # Add axis labels and title
    plt.xlabel("Sex")
    plt.ylabel("Average Salary")
    plt.title(f"Average Salary by Sex in the {department} Department")
    
    # Save and show the plot
    plt.savefig(f"images/avg_salary_{department}.png")
    plt.show()

![Employees](EmployeeSQL/images/avg_salary_Customer Service.png)
![Employees](EmployeeSQL/images/avg_salary_Development.png)
![Employees](EmployeeSQL/images/avg_salary_Finance.png)
![Employees](EmployeeSQL/images/avg_salary_Human Resources.png)
![Employees](EmployeeSQL/images/avg_salary_Marketing.png)
![Employees](EmployeeSQL/images/avg_salary_Production.png)
![Employees](EmployeeSQL/images/avg_salary_Quality Management.png)
![Employees](EmployeeSQL/images/avg_salary_Research.png)
![Employees](EmployeeSQL/images/avg_salary_Sales.png)

