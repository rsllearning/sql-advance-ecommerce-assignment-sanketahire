-- ========================================================
-- Assignment: SQL (Advanced) - Online Shopping Platform
-- Author: Sanket Ahire
-- Organization: Raja Software Labs
-- Target RDBMS: MySQL 8.x
-- File: ecommerce_advanced_management.sql
-- ========================================================

-- Ensure clean, reproducible environment (Idempotent Execution)
DROP DATABASE IF EXISTS ecommerce_platform_db;
CREATE DATABASE ecommerce_platform_db;
USE ecommerce_platform_db;

-- ========================================================
-- Database Schema Definition (DDL)
-- ========================================================

-- Table 1: Customers
CREATE TABLE Customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE
);

-- Table 2: Products
-- Note: created_date is included to support temporal queries and Task 20 performance tuning
CREATE TABLE Products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(50)    NOT NULL,
    price        DECIMAL(10,2)  NOT NULL,
    created_date DATE           NOT NULL
);

-- Table 3: Orders
CREATE TABLE Orders (
    order_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT  NOT NULL,
    product_id  INT  NOT NULL,
    quantity    INT  NOT NULL CHECK (quantity > 0),
    order_date  DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ========================================================
-- Sample Seed Data (DML)
-- ========================================================

-- Seed Customers (12 Customers; Customers 11 & 12 intentionally have 0 orders to validate Task 3 LEFT JOIN)
INSERT INTO Customers (customer_id, customer_name, city, email) VALUES
(1, 'Aarav Patel', 'Mumbai', 'aarav.patel@example.com'),
(2, 'Priya Sharma', 'Delhi', 'priya.sharma@example.com'),
(3, 'Rohan Iyer', 'Bengaluru', 'rohan.iyer@example.com'),
(4, 'Sneha Kulkarni', 'Pune', 'sneha.kulkarni@example.com'),
(5, 'Vikram Malhotra', 'Mumbai', 'vikram.malhotra@example.com'),
(6, 'Ananya Roy', 'Kolkata', 'ananya.roy@example.com'),
(7, 'Rajesh Verma', 'Hyderabad', 'rajesh.verma@example.com'),
(8, 'Meera Nair', 'Chennai', 'meera.nair@example.com'),
(9, 'Aditya Joshi', 'Pune', 'aditya.joshi@example.com'),
(10, 'Neha Gupta', 'Delhi', 'neha.gupta@example.com'),
(11, 'Siddharth Rao', 'Bengaluru', 'siddharth.rao@example.com'),
(12, 'Pooja Desai', 'Ahmedabad', 'pooja.desai@example.com');

-- Seed Products (12 Products across 4 distinct categories; varied price tiers below and above ₹1,000)
INSERT INTO Products (product_id, product_name, category, price, created_date) VALUES
(1, 'Wireless Mouse', 'Electronics', 799.00, '2024-01-15'),
(2, 'Mechanical Keyboard', 'Electronics', 2499.00, '2024-02-10'),
(3, 'Noise-Cancelling Headphones', 'Electronics', 7999.00, '2024-03-05'),
(4, 'Gaming Laptop', 'Electronics', 64999.00, '2024-04-12'),
(5, 'Cotton T-Shirt', 'Fashion', 499.00, '2024-01-20'),
(6, 'Slim Fit Denim Jeans', 'Fashion', 1899.00, '2024-02-18'),
(7, 'Leather Jacket', 'Fashion', 4999.00, '2024-03-25'),
(8, 'Stainless Steel Electric Kettle', 'Home Appliances', 1299.00, '2024-01-28'),
(9, 'Microwave Oven', 'Home Appliances', 6499.00, '2024-03-15'),
(10, 'Air Purifier', 'Home Appliances', 4999.00, '2024-04-02'),
(11, 'SQL Performance Handbook', 'Books', 650.00, '2024-02-05'),
(12, 'System Design Architecture', 'Books', 1200.00, '2024-03-30');

-- Seed Orders (22 Orders distributed across active customers and product catalog)
INSERT INTO Orders (order_id, customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, 2, '2024-02-01'),
(2, 1, 2, 1, '2024-02-15'),
(3, 2, 3, 1, '2024-02-20'),
(4, 2, 5, 3, '2024-03-01'),
(5, 3, 4, 1, '2024-03-05'),
(6, 3, 1, 1, '2024-03-10'),
(7, 4, 6, 2, '2024-03-12'),
(8, 4, 8, 1, '2024-03-18'),
(9, 5, 7, 1, '2024-03-22'),
(10, 5, 9, 1, '2024-03-28'),
(11, 6, 11, 2, '2024-04-02'),
(12, 6, 12, 1, '2024-04-05'),
(13, 7, 2, 2, '2024-04-08'),
(14, 7, 5, 1, '2024-04-12'),
(15, 8, 10, 1, '2024-04-15'),
(16, 8, 3, 1, '2024-04-18'),
(17, 9, 6, 1, '2024-04-20'),
(18, 9, 11, 1, '2024-04-25'),
(19, 10, 8, 2, '2024-04-28'),
(20, 10, 1, 1, '2024-05-02'),
(21, 2, 2, 1, '2024-05-05'),
(22, 4, 3, 1, '2024-05-10');

-- Seed Data Verification Query
SELECT 
    (SELECT COUNT(*) FROM Customers) AS total_customers,
    (SELECT COUNT(*) FROM Products)  AS total_products,
    (SELECT COUNT(*) FROM Orders)    AS total_orders;
/*
Expected Output:
+-----------------+----------------+--------------+
| total_customers | total_products | total_orders |
+-----------------+----------------+--------------+
|              12 |             12 |           22 |
+-----------------+----------------+--------------+
1 row in set
*/


-- ========================================================
-- Section 1: Advanced Joins
-- ========================================================

-- Task 1: Display each customer along with the products they ordered.
SELECT 
    c.customer_id,
    c.customer_name,
    p.product_name,
    p.category,
    o.quantity,
    o.order_date
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Products p ON o.product_id = p.product_id
ORDER BY c.customer_id, o.order_id;
/*
Expected Output:
+-------------+-----------------+---------------------------------+-----------------+----------+------------+
| customer_id | customer_name   | product_name                    | category        | quantity | order_date |
+-------------+-----------------+---------------------------------+-----------------+----------+------------+
|           1 | Aarav Patel     | Wireless Mouse                  | Electronics     |        2 | 2024-02-01 |
|           1 | Aarav Patel     | Mechanical Keyboard             | Electronics     |        1 | 2024-02-15 |
|           2 | Priya Sharma    | Noise-Cancelling Headphones     | Electronics     |        1 | 2024-02-20 |
|           2 | Priya Sharma    | Cotton T-Shirt                  | Fashion         |        3 | 2024-03-01 |
|           2 | Priya Sharma    | Mechanical Keyboard             | Electronics     |        1 | 2024-05-05 |
|           3 | Rohan Iyer      | Gaming Laptop                   | Electronics     |        1 | 2024-03-05 |
|           3 | Rohan Iyer      | Wireless Mouse                  | Electronics     |        1 | 2024-03-10 |
|           4 | Sneha Kulkarni  | Slim Fit Denim Jeans            | Fashion         |        2 | 2024-03-12 |
|           4 | Sneha Kulkarni  | Stainless Steel Electric Kettle | Home Appliances |        1 | 2024-03-18 |
|           4 | Sneha Kulkarni  | Noise-Cancelling Headphones     | Electronics     |        1 | 2024-05-10 |
|           5 | Vikram Malhotra | Leather Jacket                  | Fashion         |        1 | 2024-03-22 |
|           5 | Vikram Malhotra | Microwave Oven                  | Home Appliances |        1 | 2024-03-28 |
|           6 | Ananya Roy      | SQL Performance Handbook        | Books           |        2 | 2024-04-02 |
|           6 | Ananya Roy      | System Design Architecture      | Books           |        1 | 2024-04-05 |
|           7 | Rajesh Verma    | Mechanical Keyboard             | Electronics     |        2 | 2024-04-08 |
|           7 | Rajesh Verma    | Cotton T-Shirt                  | Fashion         |        1 | 2024-04-12 |
|           8 | Meera Nair      | Air Purifier                    | Home Appliances |        1 | 2024-04-15 |
|           8 | Meera Nair      | Noise-Cancelling Headphones     | Electronics     |        1 | 2024-04-18 |
|           9 | Aditya Joshi    | Slim Fit Denim Jeans            | Fashion         |        1 | 2024-04-20 |
|           9 | Aditya Joshi    | SQL Performance Handbook        | Books           |        1 | 2024-04-25 |
|          10 | Neha Gupta      | Stainless Steel Electric Kettle | Home Appliances |        2 | 2024-04-28 |
|          10 | Neha Gupta      | Wireless Mouse                  | Electronics     |        1 | 2024-05-02 |
+-------------+-----------------+---------------------------------+-----------------+----------+------------+
22 rows in set
*/

-- Task 2: Display all possible combinations of customers and products using a CROSS JOIN.
SELECT 
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM Customers c
CROSS JOIN Products p
ORDER BY c.customer_id, p.product_id;
/*
Expected Output: (144 rows total = 12 customers x 12 products; displaying first 10 rows)
+-------------+---------------+------------+-----------------------------+-----------------+----------+
| customer_id | customer_name | product_id | product_name                | category        | price    |
+-------------+---------------+------------+-----------------------------+-----------------+----------+
|           1 | Aarav Patel   |          1 | Wireless Mouse              | Electronics     |   799.00 |
|           1 | Aarav Patel   |          2 | Mechanical Keyboard         | Electronics     |  2499.00 |
|           1 | Aarav Patel   |          3 | Noise-Cancelling Headphones | Electronics     |  7999.00 |
|           1 | Aarav Patel   |          4 | Gaming Laptop               | Electronics     | 64999.00 |
|           1 | Aarav Patel   |          5 | Cotton T-Shirt              | Fashion         |   499.00 |
|           1 | Aarav Patel   |          6 | Slim Fit Denim Jeans        | Fashion         |  1899.00 |
|           1 | Aarav Patel   |          7 | Leather Jacket              | Fashion         |  4999.00 |
|           1 | Aarav Patel   |          8 | Stainless Steel Elec Kettle | Home Appliances |  1299.00 |
|           1 | Aarav Patel   |          9 | Microwave Oven              | Home Appliances |  6499.00 |
|           1 | Aarav Patel   |         10 | Air Purifier                | Home Appliances |  4999.00 |
+-------------+---------------+------------+-----------------------------+-----------------+----------+
...
144 rows in set
*/

-- Task 3: Display all customers and their orders, including customers who have not placed any orders.
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    p.product_name,
    o.quantity,
    o.order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Products p ON o.product_id = p.product_id
ORDER BY c.customer_id, o.order_id;
/*
Expected Output:
+-------------+-----------------+-----------+----------+---------------------------------+----------+------------+
| customer_id | customer_name   | city      | order_id | product_name                    | quantity | order_date |
+-------------+-----------------+-----------+----------+---------------------------------+----------+------------+
|           1 | Aarav Patel     | Mumbai    |        1 | Wireless Mouse                  |        2 | 2024-02-01 |
|           1 | Aarav Patel     | Mumbai    |        2 | Mechanical Keyboard             |        1 | 2024-02-15 |
|           2 | Priya Sharma    | Delhi     |        3 | Noise-Cancelling Headphones     |        1 | 2024-02-20 |
|           2 | Priya Sharma    | Delhi     |        4 | Cotton T-Shirt                  |        3 | 2024-03-01 |
|           2 | Priya Sharma    | Delhi     |       21 | Mechanical Keyboard             |        1 | 2024-05-05 |
|           3 | Rohan Iyer      | Bengaluru |        5 | Gaming Laptop                   |        1 | 2024-03-05 |
|           3 | Rohan Iyer      | Bengaluru |        6 | Wireless Mouse                  |        1 | 2024-03-10 |
|           4 | Sneha Kulkarni  | Pune      |        7 | Slim Fit Denim Jeans            |        2 | 2024-03-12 |
|           4 | Sneha Kulkarni  | Pune      |        8 | Stainless Steel Electric Kettle |        1 | 2024-03-18 |
|           4 | Sneha Kulkarni  | Pune      |       22 | Noise-Cancelling Headphones     |        1 | 2024-05-10 |
|           5 | Vikram Malhotra | Mumbai    |        9 | Leather Jacket                  |        1 | 2024-03-22 |
|           5 | Vikram Malhotra | Mumbai    |       10 | Microwave Oven                  |        1 | 2024-03-28 |
|           6 | Ananya Roy      | Kolkata   |       11 | SQL Performance Handbook        |        2 | 2024-04-02 |
|           6 | Ananya Roy      | Kolkata   |       12 | System Design Architecture      |        1 | 2024-04-05 |
|           7 | Rajesh Verma    | Hyderabad |       13 | Mechanical Keyboard             |        2 | 2024-04-08 |
|           7 | Rajesh Verma    | Hyderabad |       14 | Cotton T-Shirt                  |        1 | 2024-04-12 |
|           8 | Meera Nair      | Chennai   |       15 | Air Purifier                    |        1 | 2024-04-15 |
|           8 | Meera Nair      | Chennai   |       16 | Noise-Cancelling Headphones     |        1 | 2024-04-18 |
|           9 | Aditya Joshi    | Pune      |       17 | Slim Fit Denim Jeans            |        1 | 2024-04-20 |
|           9 | Aditya Joshi    | Pune      |       18 | SQL Performance Handbook        |        1 | 2024-04-25 |
|          10 | Neha Gupta      | Delhi     |       19 | Stainless Steel Electric Kettle |        2 | 2024-04-28 |
|          10 | Neha Gupta      | Delhi     |       20 | Wireless Mouse                  |        1 | 2024-05-02 |
|          11 | Siddharth Rao   | Bengaluru |     NULL | NULL                            |     NULL | NULL       |
|          12 | Pooja Desai     | Ahmedabad |     NULL | NULL                            |     NULL | NULL       |
+-------------+-----------------+-----------+----------+---------------------------------+----------+------------+
24 rows in set
*/


-- ========================================================
-- Section 2: Subqueries
-- ========================================================

-- Task 4: Find products priced above the average product price.
SELECT 
    product_id, 
    product_name, 
    category, 
    price
FROM Products
WHERE price > (SELECT AVG(price) FROM Products)
ORDER BY price DESC;
/*
Expected Output: (Overall average price across catalog is ₹8,195.00)
+------------+---------------+-------------+----------+
| product_id | product_name  | category    | price    |
+------------+---------------+-------------+----------+
|          4 | Gaming Laptop | Electronics | 64999.00 |
+------------+---------------+-------------+----------+
1 row in set
*/

-- Task 5: Display customers whose total purchase amount is greater than the average customer purchase amount.
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(p.price * o.quantity) AS total_purchase_amount
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
HAVING total_purchase_amount > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(p2.price * o2.quantity) AS customer_total
        FROM Orders o2
        INNER JOIN Products p2 ON o2.product_id = p2.product_id
        GROUP BY o2.customer_id
    ) AS customer_spend_summary
)
ORDER BY total_purchase_amount DESC;
/*
Expected Output: (Average spend across active ordering customers is ₹13,342.50)
+-------------+---------------+-----------------------+
| customer_id | customer_name | total_purchase_amount |
+-------------+---------------+-----------------------+
|           3 | Rohan Iyer    |              65798.00 |
+-------------+---------------+-----------------------+
1 row in set
*/

-- Task 6: Find the highest-priced product in each category using a correlated subquery.
SELECT 
    p1.product_id,
    p1.product_name,
    p1.category,
    p1.price
FROM Products p1
WHERE p1.price = (
    SELECT MAX(p2.price)
    FROM Products p2
    WHERE p2.category = p1.category
)
ORDER BY p1.category;
/*
Expected Output:
+------------+----------------------------+-----------------+----------+
| product_id | product_name               | category        | price    |
+------------+----------------------------+-----------------+----------+
|         12 | System Design Architecture | Books           |  1200.00 |
|          4 | Gaming Laptop              | Electronics     | 64999.00 |
|          7 | Leather Jacket             | Fashion         |  4999.00 |
|          9 | Microwave Oven             | Home Appliances |  6499.00 |
+------------+----------------------------+-----------------+----------+
4 rows in set
*/


-- ========================================================
-- Section 3: Set Operations
-- ========================================================

-- Task 7: Combine products from two different categories using UNION.
SELECT 
    product_id, 
    product_name, 
    category, 
    price
FROM Products
WHERE category = 'Electronics'
UNION
SELECT 
    product_id, 
    product_name, 
    category, 
    price
FROM Products
WHERE category = 'Fashion'
ORDER BY category, price;
/*
Expected Output:
+------------+-----------------------------+-------------+----------+
| product_id | product_name                | category    | price    |
+------------+-----------------------------+-------------+----------+
|          1 | Wireless Mouse              | Electronics |   799.00 |
|          2 | Mechanical Keyboard         | Electronics |  2499.00 |
|          3 | Noise-Cancelling Headphones | Electronics |  7999.00 |
|          4 | Gaming Laptop               | Electronics | 64999.00 |
|          5 | Cotton T-Shirt              | Fashion     |   499.00 |
|          6 | Slim Fit Denim Jeans        | Fashion     |  1899.00 |
|          7 | Leather Jacket              | Fashion     |  4999.00 |
+------------+-----------------------------+-------------+----------+
7 rows in set
*/

-- Task 8: Write MySQL alternatives for INTERSECT and EXCEPT using INNER JOIN and LEFT JOIN.

-- 8A: INTERSECT Alternative using INNER JOIN
-- Finding products common to both sets: Category is 'Electronics' AND Price > ₹2,000
SELECT DISTINCT 
    p1.product_id, 
    p1.product_name, 
    p1.category, 
    p1.price
FROM Products p1
INNER JOIN Products p2 
    ON p1.product_id = p2.product_id
WHERE p1.category = 'Electronics'
  AND p2.price > 2000
ORDER BY p1.price;
/*
Expected Output:
+------------+-----------------------------+-------------+----------+
| product_id | product_name                | category    | price    |
+------------+-----------------------------+-------------+----------+
|          2 | Mechanical Keyboard         | Electronics |  2499.00 |
|          3 | Noise-Cancelling Headphones | Electronics |  7999.00 |
|          4 | Gaming Laptop               | Electronics | 64999.00 |
+------------+-----------------------------+-------------+----------+
3 rows in set
*/

-- 8B: EXCEPT Alternative using LEFT JOIN ... WHERE right IS NULL
-- Finding products present in 'Electronics' EXCEPT those with Price > ₹2,000 (i.e., Electronics <= ₹2,000)
SELECT DISTINCT 
    p1.product_id, 
    p1.product_name, 
    p1.category, 
    p1.price
FROM Products p1
LEFT JOIN Products p2 
    ON p1.product_id = p2.product_id
   AND p2.price > 2000
WHERE p1.category = 'Electronics'
  AND p2.product_id IS NULL
ORDER BY p1.price;
/*
Expected Output:
+------------+----------------+-------------+--------+
| product_id | product_name   | category    | price  |
+------------+----------------+-------------+--------+
|          1 | Wireless Mouse | Electronics | 799.00 |
+------------+----------------+-------------+--------+
1 row in set
*/
