/* ================================
   E-COMMERCE DATABASE ANALYSIS
   =================================
   Author: Ahmad Amine
   Description:
   This script analyzes an e-commerce database (customers, products, purchases)
   to uncover insights about income segmentation, product performance,
   purchase behavior, and high-income customer preferences.
================================ */

/* 1. Count rows in each table
   Purpose: Validate data import by checking total row counts */
-- Results:
-- customers: 50
-- products: 1,604
-- purchases: 497
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'purchases', COUNT(*) FROM purchases;

/* 2. Check null values in customers (income field)
   Purpose: Ensure data quality by confirming no missing income values */
-- Result: 0 null values
SELECT COUNT(*) AS null_income_count
FROM customers
WHERE hh_income IS NULL;

/* 3. Explore all distinct income values
   Purpose: Understand the income range for segmentation */
-- Result: Numeric income values only (no categories like Low/Medium/High)
SELECT DISTINCT hh_income
FROM customers
ORDER BY hh_income;

/* 4. Income distribution of customers
   Purpose: Segment customers into income groups for better targeting */
-- Results:
-- Medium Income: 33
-- High Income: 17
SELECT 
    CASE 
        WHEN hh_income < 60000 THEN 'Low Income'
        WHEN hh_income BETWEEN 60000 AND 90000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS income_group,
    COUNT(*) AS customer_count
FROM customers
GROUP BY income_group
ORDER BY customer_count DESC;

/* 5. Average spend per customer
   Purpose: Identify the highest-spending customers */
-- Insight: Useful for loyalty programs or targeted campaigns
SELECT c.cust_id, SUM(p.subtotal) AS total_spent
FROM customers c
JOIN purchases p ON c.cust_id = p.cust_id
GROUP BY c.cust_id
ORDER BY total_spent DESC;

/* 6. Top 10 product categories by revenue
   Purpose: Identify the most profitable categories */
-- Results (Top 3):
-- Pantry Essentials: $2,058.55
-- Supplements: $1,083.45
-- Dairy & Eggs: $801.77
SELECT pr.category, SUM(p.subtotal) AS total_revenue
FROM purchases p
JOIN products pr ON p.prod_id = pr.product_id
GROUP BY pr.category
ORDER BY total_revenue DESC
LIMIT 10;

/* 7. Average nutritional score by product category
   Purpose: Compare health value across categories */
-- Result:
-- Highest: Produce (6.37), Beverages (4.83), Pantry Essentials (3.62)
SELECT pr.category, AVG(pr.nutritional_score) AS avg_score
FROM products pr
GROUP BY pr.category
ORDER BY avg_score DESC;

/* 8. Average basket size (items per purchase)
   Purpose: Understand typical purchase volume */
-- Result: 2.33 items per purchase
SELECT AVG(quantity) AS avg_basket_size
FROM purchases;

/* 9. Daily revenue trend
   Purpose: Identify sales patterns and seasonality */
-- Insight: Revenue trend can inform promotional timing
SELECT DATE(shopping_date) AS day, SUM(subtotal) AS revenue
FROM purchases
GROUP BY day
ORDER BY day;

/* 10. Full customer purchase breakdown by category
    Purpose: Understand how income groups allocate spending by category */
SELECT c.cust_id,
       CASE 
            WHEN c.hh_income < 60000 THEN 'Low Income'
            WHEN c.hh_income BETWEEN 60000 AND 90000 THEN 'Medium Income'
            ELSE 'High Income'
       END AS income_group,
       pr.category,
       SUM(p.subtotal) AS total_spent
FROM purchases p
JOIN customers c ON p.cust_id = c.cust_id
JOIN products pr ON p.prod_id = pr.product_id
GROUP BY c.cust_id, income_group, pr.category
ORDER BY total_spent DESC;

/* 11. Top 5 products for high-income households (income > 90k)
    Purpose: Identify premium products for targeted marketing */
-- Results:
-- 1. Organic Lemon Balm Alcohol Free: $223.70
-- 2. Sport Protein Peanut Butter Tub: $194.97
-- 3. Lacto Complete Dairy Digestion: $161.94
-- 4. Beef Tenderloin Steak Filet Mignon: $135.96
-- 5. Cookout Classic Plant-Based Burger Patties: $88.94
SELECT pr.product_name, SUM(p.subtotal) AS total_sales
FROM purchases p
JOIN customers c ON p.cust_id = c.cust_id
JOIN products pr ON p.prod_id = pr.product_id
WHERE c.hh_income > 90000
GROUP BY pr.product_name
ORDER BY total_sales DESC
LIMIT 5;
