*&---------------------------------------------------------------------*
*& Data Dictionary Object: ZNEXGEN_EMPLOYEES
*& Object Type  : Transparent Table
*& Description  : Stores employee master and salary data for NexGen Corp
*& Created By   : [Your Name] | [Roll No] | Batch: [Batch]
*& Created On   : April 2026
*&---------------------------------------------------------------------*
*
* TABLE DEFINITION (Create in SE11 → Database Table)
*
* Table Name    : ZNEXGEN_EMPLOYEES
* Short Desc    : NexGen Employee Salary Master Table
* Delivery Class: A (Application Data)
* Data Browser  : Display/Maintenance Allowed
*
* ┌─────────────┬─────┬──────────────────┬────────┬───────────────────────┐
* │ Field Name  │ Key │ Data Type        │ Length │ Short Description      │
* ├─────────────┼─────┼──────────────────┼────────┼───────────────────────┤
* │ MANDT       │ YES │ CLNT (Client)    │ 3      │ Client                 │
* │ EMP_ID      │ YES │ CHAR             │ 10     │ Employee ID (EMP001)   │
* │ EMP_NAME    │     │ CHAR             │ 40     │ Employee Full Name      │
* │ DEPARTMENT  │     │ CHAR             │ 15     │ Department Code        │
* │ DESIGNATION │     │ CHAR             │ 30     │ Job Designation        │
* │ CITY        │     │ CHAR             │ 20     │ Work Location City     │
* │ JOIN_DATE   │     │ DATS (Date)      │ 8      │ Date of Joining        │
* │ EXPERIENCE  │     │ INT1 (Integer)   │ 3      │ Years of Experience    │
* │ BASIC_SAL   │     │ CURR (Currency)  │ 13,2   │ Basic Salary (INR)     │
* │ HRA         │     │ CURR (Currency)  │ 13,2   │ House Rent Allowance   │
* │ TA          │     │ CURR (Currency)  │ 13,2   │ Travel Allowance       │
* │ DEDUCTIONS  │     │ CURR (Currency)  │ 13,2   │ Total Deductions       │
* │ NET_SALARY  │     │ CURR (Currency)  │ 13,2   │ Net Monthly Salary     │
* │ PERF_RATING │     │ CHAR             │ 1      │ Perf Rating (1-5)      │
* │ STATUS      │     │ CHAR             │ 1      │ A=Active I=Inactive    │
* └─────────────┴─────┴──────────────────┴────────┴───────────────────────┘
*
* Foreign Keys:
*   MANDT → T000 (Client Table)
*   DEPARTMENT → ZNEXGEN_DEPT_T (Department Domain Table)
*
* Indexes:
*   Primary: MANDT + EMP_ID
*   Secondary Index ZNX01: DEPARTMENT + STATUS (for reporting performance)
*
*&---------------------------------------------------------------------*
*& Data Elements & Domains used
*&---------------------------------------------------------------------*
* Domain: ZNEXGEN_DEPT
*   Values: IT   = Information Technology
*           HR   = Human Resources
*           FIN  = Finance
*           OPS  = Operations
*           SALE = Sales & Marketing
*           MGMT = Management
*
* Domain: ZNEXGEN_RATING
*   Values: 1 = Poor
*           2 = Below Average
*           3 = Average
*           4 = Good
*           5 = Excellent
*
* Domain: ZNEXGEN_STATUS
*   Values: A = Active
*           I = Inactive / Resigned
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Sample Data Load Program: ZNEXGEN_LOAD_SAMPLE_DATA
*& Run in SE38 to populate demo records into ZNEXGEN_EMPLOYEES
*&---------------------------------------------------------------------*
REPORT znexgen_load_sample_data.

DATA: lt_emp TYPE STANDARD TABLE OF znexgen_employees,
      ls_emp TYPE znexgen_employees.

" Sample Employee Records — NexGen Corporation
ls_emp-mandt = sy-mandt.

" --- IT Department ---
ls_emp-emp_id = 'EMP001'. ls_emp-emp_name = 'Arjun Mehta'.
ls_emp-department = 'IT'. ls_emp-designation = 'Senior ABAP Developer'.
ls_emp-city = 'Pune'. ls_emp-join_date = '20190315'.
ls_emp-experience = 7. ls_emp-basic_sal = 75000.
ls_emp-hra = 18750. ls_emp-ta = 5000. ls_emp-deductions = 9500.
ls_emp-net_salary = 89250. ls_emp-perf_rating = '5'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP002'. ls_emp-emp_name = 'Priya Sharma'.
ls_emp-department = 'IT'. ls_emp-designation = 'SAP Basis Consultant'.
ls_emp-city = 'Mumbai'. ls_emp-join_date = '20210601'.
ls_emp-experience = 4. ls_emp-basic_sal = 55000.
ls_emp-hra = 13750. ls_emp-ta = 4000. ls_emp-deductions = 7200.
ls_emp-net_salary = 65550. ls_emp-perf_rating = '4'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP003'. ls_emp-emp_name = 'Rohan Desai'.
ls_emp-department = 'IT'. ls_emp-designation = 'Junior SAP Developer'.
ls_emp-city = 'Pune'. ls_emp-join_date = '20230801'.
ls_emp-experience = 2. ls_emp-basic_sal = 32000.
ls_emp-hra = 8000. ls_emp-ta = 2500. ls_emp-deductions = 4200.
ls_emp-net_salary = 38300. ls_emp-perf_rating = '3'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

" --- HR Department ---
ls_emp-emp_id = 'EMP004'. ls_emp-emp_name = 'Sunita Patil'.
ls_emp-department = 'HR'. ls_emp-designation = 'HR Manager'.
ls_emp-city = 'Nagpur'. ls_emp-join_date = '20170420'.
ls_emp-experience = 9. ls_emp-basic_sal = 68000.
ls_emp-hra = 17000. ls_emp-ta = 4500. ls_emp-deductions = 8800.
ls_emp-net_salary = 80700. ls_emp-perf_rating = '4'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP005'. ls_emp-emp_name = 'Vikram Joshi'.
ls_emp-department = 'HR'. ls_emp-designation = 'HR Executive'.
ls_emp-city = 'Pune'. ls_emp-join_date = '20220110'.
ls_emp-experience = 3. ls_emp-basic_sal = 28000.
ls_emp-hra = 7000. ls_emp-ta = 2000. ls_emp-deductions = 3500.
ls_emp-net_salary = 33500. ls_emp-perf_rating = '3'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

" --- Finance Department ---
ls_emp-emp_id = 'EMP006'. ls_emp-emp_name = 'Neha Kulkarni'.
ls_emp-department = 'FIN'. ls_emp-designation = 'Finance Controller'.
ls_emp-city = 'Mumbai'. ls_emp-join_date = '20160905'.
ls_emp-experience = 10. ls_emp-basic_sal = 95000.
ls_emp-hra = 23750. ls_emp-ta = 6000. ls_emp-deductions = 12000.
ls_emp-net_salary = 112750. ls_emp-perf_rating = '5'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP007'. ls_emp-emp_name = 'Amit Wagh'.
ls_emp-department = 'FIN'. ls_emp-designation = 'Accountant'.
ls_emp-city = 'Nagpur'. ls_emp-join_date = '20201115'.
ls_emp-experience = 5. ls_emp-basic_sal = 42000.
ls_emp-hra = 10500. ls_emp-ta = 3000. ls_emp-deductions = 5500.
ls_emp-net_salary = 50000. ls_emp-perf_rating = '4'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

" --- Operations Department ---
ls_emp-emp_id = 'EMP008'. ls_emp-emp_name = 'Kavita Rao'.
ls_emp-department = 'OPS'. ls_emp-designation = 'Operations Head'.
ls_emp-city = 'Hyderabad'. ls_emp-join_date = '20150301'.
ls_emp-experience = 11. ls_emp-basic_sal = 88000.
ls_emp-hra = 22000. ls_emp-ta = 6000. ls_emp-deductions = 11500.
ls_emp-net_salary = 104500. ls_emp-perf_rating = '5'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP009'. ls_emp-emp_name = 'Sanjay Nair'.
ls_emp-department = 'OPS'. ls_emp-designation = 'Logistics Coordinator'.
ls_emp-city = 'Chennai'. ls_emp-join_date = '20240101'.
ls_emp-experience = 1. ls_emp-basic_sal = 22000.
ls_emp-hra = 5500. ls_emp-ta = 1500. ls_emp-deductions = 2800.
ls_emp-net_salary = 26200. ls_emp-perf_rating = '2'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

ls_emp-emp_id = 'EMP010'. ls_emp-emp_name = 'Divya Menon'.
ls_emp-department = 'SALE'. ls_emp-designation = 'Sales Manager'.
ls_emp-city = 'Bangalore'. ls_emp-join_date = '20180720'.
ls_emp-experience = 8. ls_emp-basic_sal = 72000.
ls_emp-hra = 18000. ls_emp-ta = 7000. ls_emp-deductions = 9800.
ls_emp-net_salary = 87200. ls_emp-perf_rating = '5'. ls_emp-status = 'A'.
APPEND ls_emp TO lt_emp.

" Insert records into database table
INSERT znexgen_employees FROM TABLE lt_emp.
IF sy-subrc = 0.
  WRITE: / '✓ Sample data loaded successfully. Records:', sy-dbcnt.
  COMMIT WORK.
ELSE.
  WRITE: / '✗ Data load failed. Check table existence in SE11.'.
  ROLLBACK WORK.
ENDIF.
