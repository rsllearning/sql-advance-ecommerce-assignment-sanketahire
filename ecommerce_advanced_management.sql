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
