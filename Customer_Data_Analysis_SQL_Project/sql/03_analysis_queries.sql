-- Customer Data Analysis Queries
USE customer_analysis;

-- 1. Basic table counts
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_transactions FROM transactions;

-- 2. Total revenue from completed orders
SELECT
    ROUND(SUM(t.amount), 2) AS total_revenue
FROM transactions t
JOIN orders o ON t.order_id = o.order_id
WHERE o.order_status = 'Completed';

-- 3. Average order value
SELECT
    ROUND(SUM(order_total) / COUNT(*), 2) AS average_order_value
FROM (
    SELECT o.order_id, SUM(t.amount) AS order_total
    FROM orders o
    JOIN transactions t ON o.order_id = t.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
) x;

-- 4. Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(t.amount), 2) AS revenue
FROM orders o
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- 5. Revenue by customer segment
SELECT
    c.customer_segment,
    ROUND(SUM(t.amount), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;

-- 6. Top 10 customers by revenue
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(t.amount), 2) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC
LIMIT 10;

-- 7. Top products by revenue
SELECT
    p.product_name,
    p.category,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.amount), 2) AS revenue
FROM products p
JOIN transactions t ON p.product_id = t.product_id
JOIN orders o ON t.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC;

-- 8. Product category performance
SELECT
    p.category,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.amount), 2) AS revenue
FROM products p
JOIN transactions t ON p.product_id = t.product_id
JOIN orders o ON t.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- 9. Regional/customer-state performance
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(t.amount), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.state
ORDER BY revenue DESC;

-- 10. Sales channel performance
SELECT
    o.sales_channel,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(t.amount), 2) AS revenue
FROM orders o
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.sales_channel
ORDER BY revenue DESC;

-- 11. Repeat customers
SELECT
    customer_id,
    COUNT(*) AS completed_orders
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY completed_orders DESC;

-- 12. Customers with no orders
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 13. Cancellation rate
SELECT
    ROUND(
        100 * SUM(order_status = 'Cancelled') / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM orders;

-- 14. Average transaction value by channel
SELECT
    o.sales_channel,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value
FROM orders o
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.sales_channel;

-- 15. Customers above average spending
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(t.amount) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN transactions t ON o.order_id = t.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_spend
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_spend)
ORDER BY total_spend DESC;

-- 16. Rank customers by total spending
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(t.amount) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN transactions t ON o.order_id = t.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spend, 2) AS total_spend,
    DENSE_RANK() OVER (ORDER BY total_spend DESC) AS spending_rank
FROM customer_spend
ORDER BY spending_rank;

-- 17. Monthly revenue with month-over-month change
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(t.amount) AS revenue
    FROM orders o
    JOIN transactions t ON o.order_id = t.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    ) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 18. Best product in each category
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(t.amount) AS revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(t.amount) DESC
        ) AS category_rank
    FROM products p
    JOIN transactions t ON p.product_id = t.product_id
    JOIN orders o ON t.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue
FROM product_revenue
WHERE category_rank = 1
ORDER BY category;

-- 19. Customer lifetime-style summary
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS latest_order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(t.amount), 2) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN transactions t ON o.order_id = t.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC;

-- 20. Customers who purchased electronics
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN transactions t ON o.order_id = t.order_id
JOIN products p ON t.product_id = p.product_id
WHERE o.order_status = 'Completed'
  AND p.category = 'Electronics';
