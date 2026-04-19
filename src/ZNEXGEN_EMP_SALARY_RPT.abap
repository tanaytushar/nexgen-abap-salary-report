*&---------------------------------------------------------------------*
*& Program     : ZNEXGEN_EMP_SALARY_RPT
*& Title       : Employee Salary Intelligence Report - NexGen Corp
*& Description : Custom ALV Grid Report displaying employee salary
*&               data with department-wise analysis, color coding,
*&               subtotals, and dynamic filtering via selection screen.
*& Author      : [Your Name] | Roll No: [Your Roll No] | Batch: [Batch]
*& Created On  : April 2026
*& SAP Version : SAP ECC 6.0 / S/4HANA
*&---------------------------------------------------------------------*

REPORT znexgen_emp_salary_rpt
  NO STANDARD PAGE HEADING
  LINE-SIZE 255
  MESSAGE-ID znexgen_msg.

*&---------------------------------------------------------------------*
*& Type Pools
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.   "ALV type pool

*&---------------------------------------------------------------------*
*& Custom Data Dictionary Table: ZNEXGEN_EMPLOYEES
*& (Defined separately in SE11 - structure shown here for reference)
*&---------------------------------------------------------------------*
* Field         | Key | Data Element       | Description
* MANDT         | Yes | MANDT              | Client
* EMP_ID        | Yes | ZNEXGEN_EMP_ID     | Employee ID (e.g., EMP001)
* EMP_NAME      |     | ZNEXGEN_EMP_NAME   | Employee Full Name
* DEPARTMENT    |     | ZNEXGEN_DEPT       | Department (IT/HR/FIN/OPS)
* DESIGNATION   |     | ZNEXGEN_DESIG      | Job Designation
* CITY          |     | ZNEXGEN_CITY       | Work Location City
* JOIN_DATE     |     | DATS               | Date of Joining
* EXPERIENCE    |     | ZNEXGEN_EXP        | Years of Experience
* BASIC_SAL     |     | ZNEXGEN_BASIC      | Basic Salary (INR)
* HRA           |     | ZNEXGEN_HRA        | House Rent Allowance
* TA            |     | ZNEXGEN_TA         | Travel Allowance
* DEDUCTIONS    |     | ZNEXGEN_DED        | Total Deductions
* NET_SALARY    |     | ZNEXGEN_NETSAL     | Net Monthly Salary
* PERF_RATING   |     | ZNEXGEN_RATING     | Performance Rating (1-5)
* STATUS        |     | ZNEXGEN_STATUS     | Active/Inactive

*&---------------------------------------------------------------------*
*& Internal Table & Work Area Definitions
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_employee,
         emp_id      TYPE c LENGTH 10,
         emp_name    TYPE c LENGTH 40,
         department  TYPE c LENGTH 15,
         designation TYPE c LENGTH 30,
         city        TYPE c LENGTH 20,
         join_date   TYPE d,
         experience  TYPE i,
         basic_sal   TYPE p DECIMALS 2,
         hra         TYPE p DECIMALS 2,
         ta          TYPE p DECIMALS 2,
         deductions  TYPE p DECIMALS 2,
         net_salary  TYPE p DECIMALS 2,
         perf_rating TYPE c LENGTH 1,
         status      TYPE c LENGTH 1,
         rowcolor    TYPE lvc_t_scol,    "ALV color column
       END OF ty_employee.

TYPES: BEGIN OF ty_output,
         emp_id      TYPE c LENGTH 10,
         emp_name    TYPE c LENGTH 40,
         department  TYPE c LENGTH 15,
         designation TYPE c LENGTH 30,
         city        TYPE c LENGTH 20,
         join_date   TYPE d,
         experience  TYPE i,
         basic_sal   TYPE p DECIMALS 2,
         hra         TYPE p DECIMALS 2,
         ta          TYPE p DECIMALS 2,
         deductions  TYPE p DECIMALS 2,
         net_salary  TYPE p DECIMALS 2,
         perf_rating TYPE c LENGTH 1,
         status      TYPE c LENGTH 1,
         celltab     TYPE lvc_t_scol,
       END OF ty_output.

DATA: gt_employee  TYPE STANDARD TABLE OF ty_employee,
      gs_employee  TYPE ty_employee,
      gt_output    TYPE STANDARD TABLE OF ty_output,
      gs_output    TYPE ty_output.

*&---------------------------------------------------------------------*
*& ALV Related Data Declarations
*&---------------------------------------------------------------------*
DATA: go_alv_grid    TYPE REF TO cl_gui_alv_grid,
      go_container   TYPE REF TO cl_gui_custom_container,
      gs_layout      TYPE lvc_s_layo,
      gt_fieldcat    TYPE lvc_t_fcat,
      gs_fieldcat    TYPE lvc_s_fcat,
      gt_sort        TYPE lvc_t_sort,
      gs_sort        TYPE lvc_s_sort,
      gt_filter      TYPE lvc_t_filt,
      gs_variant     TYPE disvariant,
      gv_repid       TYPE sy-repid.

*&---------------------------------------------------------------------*
*& Selection Screen Definition
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS: so_empid  FOR gs_employee-emp_id
                             MATCHCODE OBJECT znexgen_emp_sh,
                  so_dept   FOR gs_employee-department,
                  so_city   FOR gs_employee-city,
                  so_stat   FOR gs_employee-status DEFAULT 'A'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
  PARAMETERS: p_minsal TYPE p DECIMALS 2 DEFAULT 0,
              p_maxsal TYPE p DECIMALS 2 DEFAULT 9999999,
              p_rating TYPE c LENGTH 1.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
  PARAMETERS: rb_all  RADIOBUTTON GROUP rg1 DEFAULT 'X',
              rb_hi   RADIOBUTTON GROUP rg1,
              rb_low  RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b3.

*&---------------------------------------------------------------------*
*& Initialization
*&---------------------------------------------------------------------*
INITIALIZATION.
  text-001 = 'Employee Filter Criteria'.
  text-002 = 'Salary Range Selection'.
  text-003 = 'Display Mode'.
  gv_repid = sy-repid.

*&---------------------------------------------------------------------*
*& At Selection Screen - Input Validation
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM validate_input.

*&---------------------------------------------------------------------*
*& Start of Selection
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_employee_data.
  PERFORM apply_business_logic.
  PERFORM prepare_output_table.

END-OF-SELECTION.
  PERFORM display_alv_report.

*&---------------------------------------------------------------------*
*& FORM: validate_input
*& Validates selection screen parameters before data fetch
*&---------------------------------------------------------------------*
FORM validate_input.
  IF p_minsal > p_maxsal.
    MESSAGE e001(znexgen_msg) WITH 'Minimum salary cannot exceed maximum salary'.
  ENDIF.
  IF p_minsal < 0 OR p_maxsal < 0.
    MESSAGE e002(znexgen_msg) WITH 'Salary values cannot be negative'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: fetch_employee_data
*& Fetches data from ZNEXGEN_EMPLOYEES table using SELECT
*&---------------------------------------------------------------------*
FORM fetch_employee_data.
  REFRESH gt_employee.

  SELECT emp_id
         emp_name
         department
         designation
         city
         join_date
         experience
         basic_sal
         hra
         ta
         deductions
         net_salary
         perf_rating
         status
    INTO CORRESPONDING FIELDS OF TABLE gt_employee
    FROM znexgen_employees
   WHERE emp_id    IN so_empid
     AND department IN so_dept
     AND city       IN so_city
     AND status     IN so_stat
     AND net_salary BETWEEN p_minsal AND p_maxsal.

  IF sy-subrc <> 0.
    MESSAGE i003(znexgen_msg) WITH 'No records found for the given criteria'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  " Further filter by performance rating if entered
  IF p_rating IS NOT INITIAL.
    DELETE gt_employee WHERE perf_rating <> p_rating.
  ENDIF.

  " Handle display mode filter
  IF rb_hi = 'X'.
    " Show only high earners (top 25% by net salary)
    SORT gt_employee BY net_salary DESCENDING.
    DATA(lv_count) = lines( gt_employee ).
    DATA(lv_top)   = lv_count / 4.
    IF lv_top >= 1.
      DELETE gt_employee FROM lv_top + 1.
    ENDIF.
  ELSEIF rb_low = 'X'.
    " Show only low earners (bottom 25% by net salary)
    SORT gt_employee BY net_salary ASCENDING.
    lv_count = lines( gt_employee ).
    lv_top   = lv_count / 4.
    IF lv_top >= 1.
      DELETE gt_employee FROM lv_top + 1.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: apply_business_logic
*& Applies color coding based on salary bands and performance
*&---------------------------------------------------------------------*
FORM apply_business_logic.
  DATA: ls_color TYPE lvc_s_scol.

  LOOP AT gt_employee INTO gs_employee.
    CLEAR ls_color.

    " Color logic based on net salary bands
    " C1=Grey C3=Yellow C4=Blue C5=Green C6=Red C7=Orange
    CASE gs_employee-net_salary.
      WHEN 0 TO 30000.
        ls_color-color-col = '6'.    "Red  - entry level
        ls_color-color-int = '0'.
        ls_color-color-inv = '0'.
      WHEN 30001 TO 60000.
        ls_color-color-col = '7'.    "Orange - mid level
        ls_color-color-int = '0'.
        ls_color-color-inv = '0'.
      WHEN 60001 TO 100000.
        ls_color-color-col = '5'.    "Green - senior level
        ls_color-color-int = '0'.
        ls_color-color-inv = '0'.
      WHEN OTHERS.
        ls_color-color-col = '4'.    "Blue - executive level
        ls_color-color-int = '1'.
        ls_color-color-inv = '0'.
    ENDCASE.

    " Append color to row color table
    APPEND ls_color TO gs_employee-rowcolor.
    MODIFY gt_employee FROM gs_employee.
    CLEAR gs_employee.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: prepare_output_table
*& Maps internal table to output structure for ALV display
*&---------------------------------------------------------------------*
FORM prepare_output_table.
  REFRESH gt_output.

  LOOP AT gt_employee INTO gs_employee.
    CLEAR gs_output.
    MOVE-CORRESPONDING gs_employee TO gs_output.
    gs_output-celltab = gs_employee-rowcolor.
    APPEND gs_output TO gt_output.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: display_alv_report
*& Builds ALV field catalog, layout, sort, and renders grid
*&---------------------------------------------------------------------*
FORM display_alv_report.

  " Step 1: Build field catalog
  PERFORM build_field_catalog.

  " Step 2: Set ALV layout
  PERFORM set_alv_layout.

  " Step 3: Define sort criteria
  PERFORM define_sort_criteria.

  " Step 4: Create container and render ALV
  PERFORM render_alv_grid.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: build_field_catalog
*& Defines each column of the ALV grid with labels and properties
*&---------------------------------------------------------------------*
FORM build_field_catalog.
  REFRESH gt_fieldcat.

  DEFINE add_field.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname  = &1.
    gs_fieldcat-coltext    = &2.
    gs_fieldcat-seltext    = &2.
    gs_fieldcat-outputlen  = &3.
    gs_fieldcat-just       = &4.
    gs_fieldcat-do_sum     = &5.
    gs_fieldcat-no_zero    = &6.
    APPEND gs_fieldcat TO gt_fieldcat.
  END-OF-DEFINITION.

  "          FieldName      Column Label              Len  Just Sum  NoZero
  add_field 'EMP_ID'       'Employee ID'              10   'L'  ''   'X'.
  add_field 'EMP_NAME'     'Employee Name'            30   'L'  ''   ''.
  add_field 'DEPARTMENT'   'Department'               15   'C'  ''   ''.
  add_field 'DESIGNATION'  'Designation'              25   'L'  ''   ''.
  add_field 'CITY'         'Work Location'            15   'C'  ''   ''.
  add_field 'JOIN_DATE'    'Joining Date'             10   'C'  ''   ''.
  add_field 'EXPERIENCE'   'Exp (Yrs)'                 8   'R'  ''   'X'.
  add_field 'BASIC_SAL'    'Basic Salary'             13   'R'  'X'  'X'.
  add_field 'HRA'          'HRA'                      12   'R'  'X'  'X'.
  add_field 'TA'           'Travel Allow.'            12   'R'  'X'  'X'.
  add_field 'DEDUCTIONS'   'Deductions'               12   'R'  'X'  'X'.
  add_field 'NET_SALARY'   'Net Salary'               14   'R'  'X'  'X'.
  add_field 'PERF_RATING'  'Rating'                    6   'C'  ''   ''.
  add_field 'STATUS'       'Status'                    8   'C'  ''   ''.

  " Enable cell color column
  LOOP AT gt_fieldcat INTO gs_fieldcat
    WHERE fieldname = 'NET_SALARY'.
    gs_fieldcat-emphasize = 'C510'.
    MODIFY gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: set_alv_layout
*& Configures overall ALV grid appearance and behavior
*&---------------------------------------------------------------------*
FORM set_alv_layout.
  CLEAR gs_layout.
  gs_layout-zebra         = 'X'.    "Alternating row colors
  gs_layout-cwidth_opt    = 'X'.    "Auto column width
  gs_layout-col_opt       = 'X'.    "Column optimization
  gs_layout-ctab_fname    = 'CELLTAB'. "Cell color field
  gs_layout-info_fname    = ''.
  gs_layout-totals_text   = 'Department Total'.
  gs_layout-grand_totals  = 'X'.
  gs_layout-no_toolbar    = ''.     "Show toolbar
  gs_layout-sel_mode      = 'A'.    "Multiple row selection
  gs_layout-edit          = ''.     "Read-only mode

  " Display variant for saving layouts
  gs_variant-report       = gv_repid.
  gs_variant-username     = sy-uname.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: define_sort_criteria
*& Sorts ALV data by department then net salary descending
*&---------------------------------------------------------------------*
FORM define_sort_criteria.
  REFRESH gt_sort.
  CLEAR gs_sort.

  " Primary sort: Department (ascending) with subtotals
  gs_sort-fieldname = 'DEPARTMENT'.
  gs_sort-up        = 'X'.
  gs_sort-subtot    = 'X'.    "Show subtotals per department
  gs_sort-group     = '*'.
  APPEND gs_sort TO gt_sort.
  CLEAR gs_sort.

  " Secondary sort: Net Salary (descending)
  gs_sort-fieldname = 'NET_SALARY'.
  gs_sort-down      = 'X'.
  gs_sort-subtot    = ''.
  APPEND gs_sort TO gt_sort.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM: render_alv_grid
*& Creates ALV container and renders the grid with all settings
*&---------------------------------------------------------------------*
FORM render_alv_grid.
  DATA: lv_title TYPE lvc_title.
  lv_title = 'NexGen Corp — Employee Salary Intelligence Report'.

  " Create screen container (requires Module Pool screen 9001)
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'SALV_CONTAINER'.

  " Instantiate ALV grid object
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

  " Render ALV with all parameters
  CALL METHOD go_alv_grid->set_table_for_first_display
    EXPORTING
      i_structure_name              = 'ZNEXGEN_EMP_OUTPUT'
      is_variant                    = gs_variant
      i_save                        = 'A'
      i_default                     = 'X'
      is_layout                     = gs_layout
      it_toolbar_excluding          = VALUE #( )
    CHANGING
      it_outtab                     = gt_output
      it_fieldcatalog               = gt_fieldcat
      it_sort                       = gt_sort
      it_filter                     = gt_filter
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE e004(znexgen_msg) WITH 'ALV Grid rendering failed. Check container setup.'.
  ENDIF.

  " Register event handler for double-click drill-down
  SET HANDLER lcl_event_handler=>on_double_click FOR go_alv_grid.

  CALL SCREEN 9001.    "Custom screen with GUI container

ENDFORM.

*&---------------------------------------------------------------------*
*& LOCAL CLASS: Event Handler for ALV Double-Click
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    DATA: ls_output TYPE ty_output.
    READ TABLE gt_output INTO ls_output INDEX e_row-index.
    IF sy-subrc = 0.
      " Display detailed employee info popup
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel    = 'Employee Detail'
          textline1 = |ID: { ls_output-emp_id } | Name: { ls_output-emp_name }|
          textline2 = |Dept: { ls_output-department } | Net Salary: { ls_output-net_salary }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& MODULE: Status GUI (called from Screen 9001 PBO)
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'ZNEXGEN_STATUS'.
  SET TITLEBAR  'ZNEXGEN_TITLE'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE: User Command (called from Screen 9001 PAI)
*&---------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM fetch_employee_data.
      PERFORM apply_business_logic.
      PERFORM prepare_output_table.
      CALL METHOD go_alv_grid->refresh_table_display.
    WHEN 'EXPORT'.
      PERFORM export_to_spreadsheet.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& FORM: export_to_spreadsheet
*& Downloads ALV data to local Excel file
*&---------------------------------------------------------------------*
FORM export_to_spreadsheet.
  DATA: lt_data    TYPE truxs_t_text_data.

  CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
    EXPORTING
      i_tabname              = 'GT_OUTPUT'
    TABLES
      i_tab_sap_data         = gt_output
      i_tab_converted_data   = lt_data
    EXCEPTIONS
      conversion_failed      = 1
      OTHERS                 = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = 'C:\NEXGEN_SALARY_REPORT.xls'
        filetype                = 'DAT'
      TABLES
        data_tab                = lt_data
      EXCEPTIONS
        file_write_error        = 1
        OTHERS                  = 2.

    IF sy-subrc = 0.
      MESSAGE s005(znexgen_msg) WITH 'File exported successfully to C:\NEXGEN_SALARY_REPORT.xls'.
    ENDIF.
  ENDIF.
ENDFORM.
