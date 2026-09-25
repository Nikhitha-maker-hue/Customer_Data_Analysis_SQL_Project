# Customer Data Analysis Using SQL

## Project Overview
A portfolio-ready SQL project that explores customer, order, product and transaction data using MySQL.

The project demonstrates:
- SELECT, WHERE, GROUP BY and HAVING
- INNER JOIN and LEFT JOIN
- Aggregations and business KPIs
- CTEs
- Window functions
- Ranking
- Month-over-month analysis
- Customer segmentation
- RFM-style customer analysis
- Revenue contribution
- Customer lifetime-style summaries

## Tools
- SQL
- MySQL 8.0+
- Data Analysis
- CSV

## Dataset
Synthetic portfolio dataset:
- 500 customers
- 2,400 orders
- 3,409 transaction lines
- 12 products

## Folder Structure

```text
Customer_Data_Analysis_SQL_Project/
│
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   └── transactions.csv
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_load_data.sql
│   ├── 03_analysis_queries.sql
│   └── 04_advanced_queries.sql
│
├── docs/
│   └── project_notes.md
│
├── output/
│   └── expected_metrics.csv
│
├── README.md
└── requirements.txt
```

## Database Design

### customers
Stores customer demographic and segmentation information.

### products
Stores product names, categories and unit prices.

### orders
Stores order-level information such as customer, date, channel and status.

### transactions
Stores individual product lines belonging to an order.

Relationship:

customers 1 --- many orders

orders 1 --- many transactions

products 1 --- many transactions

## How to Run

### Step 1
Install MySQL 8.0+ and MySQL Workbench.

### Step 2
Open:

`sql/01_schema.sql`

Run it to create the database and tables.

### Step 3
Import the CSV files using:

`sql/02_load_data.sql`

You may need to enable `LOCAL INFILE` or import the CSVs through MySQL Workbench's table import wizard.

### Step 4
Run:

`sql/03_analysis_queries.sql`

for the main business analysis.

### Step 5
Run:

`sql/04_advanced_queries.sql`

for CTEs, window functions, RFM-style metrics and revenue contribution.

## Business Questions Answered
1. What is total revenue?
2. What is the average order value?
3. Which customers spend the most?
4. Which products generate the most revenue?
5. Which categories perform best?
6. Which customer segments contribute the most revenue?
7. Which states generate the most revenue?
8. Which sales channel performs best?
9. What is the cancellation rate?
10. Which customers are repeat buyers?
11. What is monthly revenue and month-over-month growth?
12. Which product is the best performer within each category?
13. What percentage of revenue does each product contribute?
14. Which customers have above-average spending?

## Resume Description

**Customer Data Analysis Using SQL | SQL, MySQL, Data Analysis**

Used MySQL to analyze customer, order, product and transaction data. Wrote complex SQL queries using joins, aggregations, CTEs and window functions to calculate business KPIs, identify high-value customers, analyze product and regional performance, and uncover useful transaction patterns.

## Interview Talking Points
- Explain the relational schema.
- Explain why transactions are separated from orders.
- Demonstrate INNER JOIN vs LEFT JOIN.
- Explain GROUP BY and HAVING.
- Explain CTEs and window functions.
- Explain customer ranking.
- Explain month-over-month revenue growth.
- Explain how you would optimize indexes for large transaction tables.
