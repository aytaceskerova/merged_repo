-- ============================================
-- MERGED DATABASE SCHEMA AND QUERIES
-- Combined from task1.sql and task2.sql
-- ============================================

-- ============================================
-- PART 1: EMPLOYEES TABLE (from task1.sql)
-- ============================================

CREATE TABLE Employees (
EmployeeID INT PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Department VARCHAR(50) NOT NULL,
Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, Name, Department, Salary) VALUES
(101, 'Alice Johnson', 'Sales', 65000.00),
(102, 'Bob Williams', 'Sales', 68000.00),
(103, 'Charlie Brown', 'Sales', 72000.00),
(104, 'David Lee', 'Sales', 63000.00),
(105, 'Eve Davis', 'Sales', 70000.00),
(106, 'Frank White', 'Sales', 69000.00), -- 6th Sales employee
(201, 'Grace Hall', 'HR', 55000.00),
(202, 'Henry Scott', 'HR', 58000.00),
(203, 'Ivy Adams', 'HR', 60000.00), -- 3rd HR employee
(301, 'Jack King', 'Engineering', 90000.00),
(302, 'Kelly Green', 'Engineering', 92000.00),
(303, 'Liam Baker', 'Engineering', 88000.00),
(304, 'Mia Carter', 'Engineering', 95000.00),
(305, 'Noah Perez', 'Engineering', 89000.00); -- 5th Engineering employee

-- Query: Departments with more than 5 employees
SELECT 
    Department,
    COUNT(*) AS total_employees
FROM Employees
GROUP BY Department
HAVING COUNT(*) > 5
ORDER BY total_employees DESC;

-- ============================================
-- PART 2: CUSTOMERS AND ORDERS TABLES (from task2.sql)
-- ============================================

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
country VARCHAR(50)
);

CREATE TABLE orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
total_amount DECIMAL(10, 2),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers (customer_id, customer_name, country) VALUES
(101, 'Alice Johnson', 'USA'),
(102, 'Mark Lee', 'Canada'),
(103, 'Sofia Gomez', 'USA');

INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(1, 101, '2025-01-10', 250.00),
(2, 102, '2025-02-05', 180.00),
(3, 101, '2025-02-12', 75.00),
(4, 103, '2025-03-01', 300.00),
(5, 102, '2025-03-10', 120.00),
(6, 101, '2025-03-15', 400.00),
(7, 103, '2025-03-20', 200.00);

-- Query: Customer statistics with latest order information
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.country,
        MAX(o.order_date) AS latest_order_date,
        SUM(o.total_amount) AS total_spent,
        AVG(o.total_amount) AS avg_order_value,
        RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.country
),
latest_orders AS (
    SELECT 
        o.customer_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) AS rn
    FROM orders o
)
SELECT 
    cs.customer_name,
    cs.country,
    lo.order_date AS latest_order_date,
    lo.total_amount AS latest_order_amount,
    cs.total_spent,
    cs.avg_order_value,
    cs.spend_rank
FROM customer_stats cs
INNER JOIN latest_orders lo ON cs.customer_id = lo.customer_id AND lo.rn = 1
ORDER BY cs.spend_rank ASC;

