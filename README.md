# 🏢 NexGen Corp — Employee Salary Intelligence Report
### SAP ABAP Capstone Project | KIIT | April 2026

---

## 📌 Project Overview

This capstone project implements a **Custom ALV Grid Report** in SAP ABAP for a fictitious company called **NexGen Corporation**. The report provides a comprehensive employee salary intelligence dashboard with dynamic filtering, department-wise subtotals, color-coded salary bands, and Excel export functionality.

> **Student:** [Your Full Name]  
> **Roll No:** [Your Roll Number]  
> **Batch/Program:** [Your Batch/Program]  
> **Specialization:** SAP ABAP Backend Developer  

---

## 🎯 Problem Statement

NexGen Corporation employs staff across multiple departments (IT, HR, Finance, Operations, Sales). The HR and Finance teams currently rely on manual Excel sheets to track salary data, which leads to:
- Lack of real-time salary visibility across departments
- No centralized system for salary band analysis
- Time-consuming manual reporting processes
- No performance-to-salary correlation tracking

**Goal:** Build a robust SAP ABAP ALV report that fetches, processes, and displays employee salary data with intelligent filtering, color-coded analysis, and departmental subtotals.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | SAP ABAP (Advanced Business Application Programming) |
| UI Framework | SAP ALV Grid (`CL_GUI_ALV_GRID`) |
| Database | SAP Transparent Table (`ZNEXGEN_EMPLOYEES`) |
| Data Dictionary | SE11 — Table, Domain, Data Elements |
| Development Tool | SAP GUI / ABAP Workbench (SE38, SE11, SE80) |
| Version Control | GitHub |

---

## 📁 Repository Structure

```
nexgen-abap-salary-report/
│
├── src/
│   ├── ZNEXGEN_EMP_SALARY_RPT.abap     ← Main ALV Report Program
│   ├── ZNEXGEN_EMPLOYEES_DD.abap       ← Data Dictionary + Sample Data Loader
│   └── ZNEXGEN_LOAD_SAMPLE_DATA.abap   ← Sample data population program
│
├── docs/
│   ├── Project_Documentation.pdf       ← Full project report (submitted)
│   ├── Architecture_Diagram.png        ← System architecture diagram
│   └── Screenshots/                    ← SAP GUI screenshots
│       ├── 01_selection_screen.png
│       ├── 02_alv_output.png
│       ├── 03_department_subtotals.png
│       └── 04_color_coding.png
│
├── data/
│   └── sample_employees.csv            ← Sample dataset reference
│
└── README.md
```

---

## ⚙️ Features

### ✅ Core Features
- **Custom Transparent Table** `ZNEXGEN_EMPLOYEES` with 15 fields
- **Selection Screen** with filters for Employee ID, Department, City, Status, Salary Range, Performance Rating
- **ALV Grid Display** using `CL_GUI_ALV_GRID` with full field catalog
- **Department-wise Subtotals** with grand totals for all salary components
- **Color-Coded Salary Bands:**
  - 🔴 Red → Entry Level (₹0 – ₹30,000)
  - 🟠 Orange → Mid Level (₹30,001 – ₹60,000)
  - 🟢 Green → Senior Level (₹60,001 – ₹1,00,000)
  - 🔵 Blue → Executive Level (₹1,00,001+)
- **Display Modes:** All Employees / Top 25% Earners / Bottom 25% Earners
- **Double-Click Drill-Down** popup with employee detail
- **Excel Export** via `GUI_DOWNLOAD`
- **Input Validation** on selection screen

### 🔧 Technical Highlights
- Type-safe internal tables using `TYPES` declaration
- Modular FORM-based architecture (10 subroutines)
- Event handling via local class `LCL_EVENT_HANDLER`
- Sort with subtotals using `LVC_T_SORT`
- Cell-level color control using `LVC_T_SCOL`
- Message class `ZNEXGEN_MSG` for all error/info messages

---

## 🚀 How to Run

### Prerequisites
- SAP ECC 6.0 or SAP S/4HANA system access
- SAP GUI installed (version 7.50 or above)
- Development authorization in the system

### Step-by-Step Setup

**Step 1 — Create Data Dictionary Objects**
```
1. Open SE11 → Create Domain: ZNEXGEN_DEPT (values: IT, HR, FIN, OPS, SALE, MGMT)
2. Create Domain: ZNEXGEN_RATING (values: 1,2,3,4,5)
3. Create Transparent Table: ZNEXGEN_EMPLOYEES (refer ZNEXGEN_EMPLOYEES_DD.abap)
4. Activate all objects
```

**Step 2 — Load Sample Data**
```
1. Open SE38 → Create program ZNEXGEN_LOAD_SAMPLE_DATA
2. Copy code from ZNEXGEN_EMPLOYEES_DD.abap (data loader section)
3. Execute (F8) to insert 10 sample employee records
```

**Step 3 — Create Main Report**
```
1. Open SE38 → Create program ZNEXGEN_EMP_SALARY_RPT
2. Copy code from ZNEXGEN_EMP_SALARY_RPT.abap
3. Activate (Ctrl+F3)
4. Execute (F8)
```

**Step 4 — Run & Test**
```
1. Selection Screen appears → apply filters as needed
2. Execute → ALV Grid displays color-coded salary data
3. Click on department row → see subtotals
4. Double-click any employee row → detail popup appears
5. Use toolbar Export button to download as Excel
```

---

## 📊 Sample Output

### Selection Screen
| Field | Sample Input |
|-------|-------------|
| Employee ID | EMP001 to EMP010 |
| Department | IT or HR or FIN |
| City | Pune / Mumbai / Nagpur |
| Status | A (Active) |
| Min Salary | 30000 |
| Max Salary | 150000 |

### ALV Grid Output (Sample)
| Emp ID | Name | Dept | Designation | City | Net Salary | Rating |
|--------|------|------|------------|------|-----------|--------|
| EMP006 | Neha Kulkarni | FIN | Finance Controller | Mumbai | ₹1,12,750 | ⭐⭐⭐⭐⭐ |
| EMP001 | Arjun Mehta | IT | Sr. ABAP Developer | Pune | ₹89,250 | ⭐⭐⭐⭐⭐ |
| EMP010 | Divya Menon | SALE | Sales Manager | Bangalore | ₹87,200 | ⭐⭐⭐⭐⭐ |
| ... | ... | ... | ... | ... | ... | ... |
| **IT Total** | | | | | **₹1,93,100** | |
| **Grand Total** | | | | | **₹6,87,950** | |

---

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────┐
│                  SAP ABAP Workbench                  │
├──────────────┬──────────────────┬───────────────────┤
│  SE11        │     SE38         │     SE80          │
│  Data Dict.  │   ABAP Editor    │  Object Navigator │
│  ZNEXGEN_    │   ZNEXGEN_EMP_   │  Package:         │
│  EMPLOYEES   │   SALARY_RPT     │  ZNEXGEN_PKG      │
└──────┬───────┴────────┬─────────┴───────────────────┘
       │                │
       ▼                ▼
┌──────────────┐  ┌─────────────────────────────────┐
│  Database    │  │         ABAP Program             │
│  Layer       │  │  ┌───────────────────────────┐  │
│              │  │  │   Selection Screen         │  │
│  ZNEXGEN_    │◄─┤  │   (so_empid, so_dept...)  │  │
│  EMPLOYEES   │  │  ├───────────────────────────┤  │
│  (Table)     │  │  │   Data Fetch (SELECT)      │  │
│              │  │  ├───────────────────────────┤  │
└──────────────┘  │  │   Business Logic / Color   │  │
                  │  ├───────────────────────────┤  │
                  │  │   ALV Grid Display         │  │
                  │  │   (CL_GUI_ALV_GRID)        │  │
                  │  ├───────────────────────────┤  │
                  │  │   Event Handler            │  │
                  │  │   (LCL_EVENT_HANDLER)      │  │
                  │  └───────────────────────────┘  │
                  └─────────────────────────────────┘
```

---

## 🔮 Future Improvements

1. **SAP Fiori UI5 Frontend** — Replace SAP GUI with a web-based Fiori app for mobile access
2. **Email Notification** — Auto-send monthly salary reports via `SO_NEW_DOCUMENT_ATT_SEND_API1`
3. **PDF Payslip Generation** — Integrate SmartForms/Adobe Forms for individual payslip download
4. **Role-Based Authorization** — Use authority checks so employees only see their own data
5. **Salary Trend Chart** — Integrate SAP BusinessObjects or embedded analytics

---

## 📄 License

This project is created for academic purposes as part of the KIIT SAP ABAP Capstone (April 2026).

---

*Built with ❤️ using SAP ABAP | NexGen Corp Capstone Project*
