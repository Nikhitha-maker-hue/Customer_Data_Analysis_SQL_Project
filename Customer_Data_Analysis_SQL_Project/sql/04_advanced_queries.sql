-- Advanced MySQL 8.0+ Queries

USE customer_analysis;

-- Customer RFM-style metrics
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        DATEDIFF('2026-01-01', MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(t.amount) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN transactions t ON o.order_id = t.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS recency_quartile,
    NTILE(4) OVER (ORDER BY frequency) AS frequency_quartile,
    NTILE(4) OVER (ORDER BY monetary) AS monetary_quartile
FROM customer_metrics;

-- Revenue contribution percentage by product
WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(t.amount) AS revenue
    FROM products p
    JOIN transactions t ON p.product_id = t.product_id
    JOIN orders o ON t.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM product_sales
ORDER BY revenue DESC;

-- Running monthly revenue
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
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM monthly
ORDER BY month;
