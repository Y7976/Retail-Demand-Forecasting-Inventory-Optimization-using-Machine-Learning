----- Creating train table ----------
CREATE TABLE train (
    id BIGINT,
    date DATE,
    store_nbr INT,
    item_nbr INT,
    unit_sales NUMERIC(12,2),
    onpromotion BOOLEAN
);

----- Creating test table ------------
CREATE TABLE test (
    id BIGINT,
    date DATE,
    store_nbr INT,
    item_nbr INT,
    onpromotion BOOLEAN
);

---- Creating Store Table ------------
CREATE TABLE stores (
    store_nbr INT,
    city VARCHAR(100),
    state VARCHAR(100),
    type CHAR(1),
    cluster INT
);

----- Creating Items Table ------------
CREATE TABLE items (
    item_nbr INT,
    family VARCHAR(100),
    class INT,
    perishable INT
);

----- Creating Transaction Table --------
CREATE TABLE transactions (
    date DATE,
    store_nbr INT,
    transactions INT
);

----- Creating Oil Table -----------
CREATE TABLE oil (
    date DATE,
    dcoilwtico NUMERIC(10,4)
);
----- Creating Holidays Table -------
CREATE TABLE holidays_events (
    date DATE,
    type VARCHAR(50),
    locale VARCHAR(50),
    locale_name VARCHAR(100),
    description VARCHAR(200),
    transferred BOOLEAN
);

------ ------- Data Cleaning -----------
SELECT COUNT(*)
FROM train;

SELECT *
FROM train
LIMIT 10;


---  1. Check Data Types 
SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='train';

--- 2. Check Missing Values
SELECT
COUNT(*) AS total_rows,
COUNT(*) FILTER (WHERE date IS NULL) AS missing_date,
COUNT(*) FILTER (WHERE store_nbr IS NULL) AS missing_store,
COUNT(*) FILTER (WHERE item_nbr IS NULL) AS missing_item,
COUNT(*) FILTER (WHERE unit_sales IS NULL) AS missing_sales,
COUNT(*) FILTER (WHERE onpromotion IS NULL) AS missing_promotion
FROM train;

---- 3. Check Duplicate Records 
SELECT
date,
store_nbr,
item_nbr,
COUNT(*)
FROM train
GROUP BY
date,
store_nbr,
item_nbr
HAVING COUNT(*)>1;

---- 4. Check Negative Sales
SELECT *
FROM train
WHERE unit_sales<0;

---- 5. Check Invalid  Dates
SELECT
MIN(date),
MAX(date)
FROM train;

---- 6. Distinct Values
SELECT DISTINCT onpromotion
FROM train;

---- 7. Distribution
SELECT
COUNT(*),
onpromotion
FROM train
GROUP BY onpromotion;

---- 8. Create Clean Table
CREATE TABLE train_clean AS
SELECT *
FROM train;

---- 9. Remove Exact Duplicates
DELETE FROM train_clean a
USING train_clean b
WHERE
a.ctid < b.ctid
AND a.date=b.date
AND a.store_nbr=b.store_nbr
AND a.item_nbr=b.item_nbr;

---- 10. Handle Missing Promotion
UPDATE train_clean
SET onpromotion=False
WHERE onpromotion IS NULL;

---- 11. Handle Missing Sales
-- Check for missing value
SELECT COUNT(*)
FROM train_clean
WHERE unit_sales IS NULL;

-- handle if missing values
DELETE
FROM train_clean
WHERE unit_sales IS NULL;

---- 12. Remove Negative Sales
DELETE
FROM train_clean
WHERE unit_sales<0;

---- 13. Check Missing Store
SELECT *
FROM train_clean
WHERE store_nbr IS NULL;

--- usually delete
DELETE
FROM train_clean
WHERE store_nbr IS NULL;

---- 14. Check Missing Product
DELETE
FROM train_clean
WHERE item_nbr IS NULL;

---- 15. Verify Missing Values Again
SELECT
COUNT(*) FILTER (WHERE date IS NULL),
COUNT(*) FILTER (WHERE store_nbr IS NULL),
COUNT(*) FILTER (WHERE item_nbr IS NULL),
COUNT(*) FILTER (WHERE unit_sales IS NULL),
COUNT(*) FILTER (WHERE onpromotion IS NULL)
FROM train_clean;

---- 16. Add Primary Key (if appropriate)

-- If  (date, store_nbr, item_nbr) is unique after cleaning:
ALTER TABLE train_clean
ADD PRIMARY KEY
(date,store_nbr,item_nbr);

---- 17. Create Indexes
CREATE INDEX idx_store
ON train_clean(store_nbr);
CREATE INDEX idx_item
ON train_clean(item_nbr);
CREATE INDEX idx_date
ON train_clean(date);

---- 18. Final Validation
SELECT COUNT(*)
FROM train_clean;

----------- 1. Executive Business KPI`s ------------

-- 1. What are the total sales, average daily sales, and total transactions?
SELECT
    SUM(unit_sales) AS total_sales,
    ROUND(AVG(unit_sales), 2) AS average_daily_sales,
    COUNT(*) AS total_transactions
FROM train;

-- 2. Which stores contribute the highest sales? (Pareto 80/20)
SELECT
    store_nbr,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY store_nbr
ORDER BY total_sales DESC;

-- 3. Which product families contribute the highest sales?
SELECT
    i.family,
    SUM(t.unit_sales) AS total_sales
FROM train as t
JOIN items as i
ON t.item_nbr = i.item_nbr
GROUP BY i.family
ORDER BY total_sales DESC;

-- 4. Month-over-Month (MoM) Sales Growth Trend
WITH monthly_sales AS
(
SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY DATE_TRUNC('month', date)
)
SELECT
    month,
    total_sales,
    LAG(total_sales) OVER(ORDER BY month) AS previous_month_sales,
    ROUND(
    (
    (total_sales - LAG(total_sales) OVER(ORDER BY month))
    /
    LAG(total_sales) OVER(ORDER BY month)
    ) * 100,2
    ) AS mom_growth_percent
FROM monthly_sales;

-- 5. Executive Dashboard KPIs
SELECT
SUM(unit_sales) AS total_sales,
COUNT(*) AS total_transactions,
ROUND(AVG(unit_sales),2) AS average_sales,
COUNT(DISTINCT store_nbr) AS total_stores,
COUNT(DISTINCT item_nbr) AS total_products
FROM train;

----------- Sales Performance ------------

-- 6. Daily Sales Trend
SELECT
    date,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY date
ORDER BY date;

-- 7. Weekly Sales Trend
SELECT
    DATE_TRUNC('week', date) AS week_start,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY week_start
ORDER BY week_start;

-- 8. Monthly Sales Trend
SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY month
ORDER BY month;

-- 9. Yearly Sales Trend
SELECT
    DATE_TRUNC('year', date) AS year,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY year
ORDER BY year;

-- 10. Top 10 Selling Products
SELECT
    item_nbr,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY item_nbr
ORDER BY total_sales DESC
LIMIT 10;

-- 11. Bottom 10 Selling Products
SELECT
    item_nbr,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY item_nbr
HAVING SUM(unit_sales) > 0
ORDER BY total_sales ASC
LIMIT 10;

-- 12. Top Performing Product Families
SELECT
    i.family,
    SUM(t.unit_sales) AS total_sales
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
GROUP BY i.family
ORDER BY total_sales DESC;

-- 13. Sales Contribution by Product Family
SELECT
    i.family,
    SUM(t.unit_sales) AS total_sales,
    ROUND(
        SUM(t.unit_sales) * 100.0 /
        SUM(SUM(t.unit_sales)) OVER (),
        2
    ) AS sales_contribution_percentage
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
GROUP BY i.family
ORDER BY total_sales DESC;

--- IMP Sales in Last 90 Days
SELECT
    SUM(unit_sales) AS total_sales_last_90_days
FROM train
WHERE date >= (
    SELECT MAX(date) - INTERVAL '89 days'
    FROM train
);

--- IMP Products Not Sold in the Last 90 Days
SELECT
    i.item_nbr,
    i.family
FROM items i
WHERE i.item_nbr NOT IN (
    SELECT DISTINCT item_nbr
    FROM train
    WHERE date >= (
        SELECT MAX(date) - INTERVAL '89 days'
        FROM train
    )
    AND unit_sales > 0
)
ORDER BY i.item_nbr;

--------- Store Performance ----------

-- 14. Rank Stores by Total Sales
SELECT
    store_nbr,
    SUM(unit_sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(unit_sales) DESC) AS store_rank
FROM train
GROUP BY store_nbr
ORDER BY store_rank;

-- 15. Rank Stores by Average Daily Sales
SELECT
    store_nbr,
    ROUND(AVG(unit_sales),2) AS avg_daily_sales,
    RANK() OVER (ORDER BY AVG(unit_sales) DESC) AS store_rank
FROM train
GROUP BY store_nbr
ORDER BY store_rank;

-- 16. Compare Sales Across Cities
SELECT
    s.city,
    ROUND(SUM(t.unit_sales),2) AS total_sales
FROM train t
JOIN stores s
ON t.store_nbr = s.store_nbr
GROUP BY s.city
ORDER BY total_sales DESC;

-- 17. Compare Sales Across States
SELECT
    s.state,
    ROUND(SUM(t.unit_sales),2) AS total_sales
FROM train t
JOIN stores s
ON t.store_nbr = s.store_nbr
GROUP BY s.state
ORDER BY total_sales DESC;

-- 18. Compare Performance by Store Type
SELECT
    s.type,
    ROUND(SUM(t.unit_sales),2) AS total_sales
FROM train t
JOIN stores s
ON t.store_nbr = s.store_nbr
GROUP BY s.type
ORDER BY total_sales DESC;

-- 19. Compare Performance by Store Cluster
SELECT
    s.cluster,
    ROUND(SUM(t.unit_sales),2) AS total_sales
FROM train t
JOIN stores s
ON t.store_nbr = s.store_nbr
GROUP BY s.cluster
ORDER BY total_sales DESC;

-- 20. Identify Stores with Consistent Sales Growth

-- Month-wise sales of each store.
SELECT
    store_nbr,
    DATE_TRUNC('month', date) AS month,
    ROUND(SUM(unit_sales),2) AS monthly_sales
FROM train
GROUP BY store_nbr, month
ORDER BY store_nbr, month;

-- 21. Identify Stores with Declining Sales Trends(Agar monthly_sales < previous_month_sales ho, to us month me sales decline hui hai.)
WITH monthly_sales AS
(
SELECT
    store_nbr,
    DATE_TRUNC('month', date) AS month,
    SUM(unit_sales) AS monthly_sales
FROM train
GROUP BY store_nbr, month
)

SELECT
    store_nbr,
    month,
    monthly_sales,
    LAG(monthly_sales)
        OVER(PARTITION BY store_nbr ORDER BY month) AS previous_month_sales
FROM monthly_sales
ORDER BY store_nbr, month;

--- IMP Stores Showing Actual Growth %
WITH monthly_sales AS
(
SELECT
    store_nbr,
    DATE_TRUNC('month', date) AS month,
    SUM(unit_sales) AS monthly_sales
FROM train
GROUP BY store_nbr, month
)

SELECT
    store_nbr,
    month,
    monthly_sales,
    LAG(monthly_sales)
        OVER(PARTITION BY store_nbr ORDER BY month) AS previous_month_sales,

ROUND(
((monthly_sales -
LAG(monthly_sales)
OVER(PARTITION BY store_nbr ORDER BY month))
/
LAG(monthly_sales)
OVER(PARTITION BY store_nbr ORDER BY month)
)*100,2) AS growth_percent

FROM monthly_sales
ORDER BY store_nbr, month;

-------------  Customer Traffic ---------------

-- 22. Which stores receive the highest customer traffic?
SELECT
    store_nbr,
    SUM(transactions) AS total_transactions
FROM transactions
GROUP BY store_nbr
ORDER BY total_transactions DESC;

-- 23. Average daily transactions per store
SELECT
    store_nbr,
    ROUND(AVG(transactions),2) AS avg_daily_transactions
FROM transactions
GROUP BY store_nbr
ORDER BY avg_daily_transactions DESC;

-- 24. Relationship between transactions and sales
SELECT
    t.store_nbr,
    SUM(t.transactions) AS total_transactions,
    SUM(tr.unit_sales) AS total_sales
FROM transactions t
JOIN train tr
    ON t.store_nbr = tr.store_nbr
   AND t.date = tr.date
GROUP BY t.store_nbr
ORDER BY total_transactions DESC;

-- 25. Stores with high traffic but low sales
WITH store_summary AS (
    SELECT
        t.store_nbr,
        SUM(t.transactions) AS total_transactions,
        SUM(tr.unit_sales) AS total_sales
    FROM transactions t
    JOIN train tr
      ON t.store_nbr = tr.store_nbr
     AND t.date = tr.date
    GROUP BY t.store_nbr
)

SELECT *
FROM store_summary
WHERE total_transactions > (SELECT AVG(total_transactions) FROM store_summary)
  AND total_sales < (SELECT AVG(total_sales) FROM store_summary)
ORDER BY total_transactions DESC;

--26. Stores with low traffic but high sales
WITH store_summary AS (
    SELECT
        t.store_nbr,
        SUM(t.transactions) AS total_transactions,
        SUM(tr.unit_sales) AS total_sales
    FROM transactions t
    JOIN train tr
      ON t.store_nbr = tr.store_nbr
     AND t.date = tr.date
    GROUP BY t.store_nbr
)

SELECT *
FROM store_summary
WHERE total_transactions < (SELECT AVG(total_transactions) FROM store_summary)
  AND total_sales > (SELECT AVG(total_sales) FROM store_summary)
ORDER BY total_sales DESC;

-- 27. Peak shopping days
SELECT
    TO_CHAR(date, 'Day') AS day_name,
    SUM(transactions) AS total_transactions
FROM transactions
GROUP BY TO_CHAR(date, 'Day')
ORDER BY total_transactions DESC;

----------- Product Analytics -------------------

-- 28. Top-selling Product Families
SELECT
    i.family,
    ROUND(SUM(t.unit_sales), 2) AS total_units_sold
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
GROUP BY i.family
ORDER BY total_units_sold DESC;

-- 29. Top-selling Perishable Products
SELECT
    t.item_nbr,
    i.family,
    ROUND(SUM(t.unit_sales), 2) AS total_units_sold
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
WHERE i.perishable = 1
GROUP BY t.item_nbr, i.family
ORDER BY total_units_sold DESC
LIMIT 10;

-- 30. Top-selling Non-Perishable Products
SELECT
    t.item_nbr,
    i.family,
    ROUND(SUM(t.unit_sales), 2) AS total_units_sold
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
WHERE i.perishable = 0
GROUP BY t.item_nbr, i.family
ORDER BY total_units_sold DESC
LIMIT 10;

-- 31. Fast-moving Products
SELECT
    item_nbr,
    ROUND(SUM(unit_sales), 2) AS total_units_sold
FROM train
GROUP BY item_nbr
ORDER BY total_units_sold DESC
LIMIT 10;

-- 32. Slow-moving Products
SELECT
    item_nbr,
    ROUND(SUM(unit_sales), 2) AS total_units_sold
FROM train
GROUP BY item_nbr
HAVING SUM(unit_sales) > 0
ORDER BY total_units_sold ASC
LIMIT 10;

-- 33. High-demand Products
SELECT
    item_nbr,
    ROUND(AVG(unit_sales), 2) AS avg_daily_sales
FROM train
GROUP BY item_nbr
HAVING AVG(unit_sales) >
(
    SELECT AVG(unit_sales)
    FROM train
)
ORDER BY avg_daily_sales DESC;

-- 34. Low-demand Products
SELECT
    item_nbr,
    ROUND(AVG(unit_sales), 2) AS avg_daily_sales
FROM train
GROUP BY item_nbr
HAVING AVG(unit_sales) <
(
    SELECT AVG(unit_sales)
    FROM train
)
ORDER BY avg_daily_sales ASC;

-- 35. Product Demand by Weekday
SELECT
    TO_CHAR(date, 'Day') AS weekday,
    ROUND(SUM(unit_sales), 2) AS total_units_sold
FROM train
GROUP BY weekday
ORDER BY total_units_sold DESC;

---------- Promotion Analytics ----------------

-- 36. Do promotions increase sales?
SELECT
    onpromotion,
    ROUND(AVG(unit_sales),2) AS avg_sales,
    SUM(unit_sales) AS total_sales
FROM train
GROUP BY onpromotion;

-- 37. Which products respond best to promotions ?
SELECT
    item_nbr,
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_avg_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_avg_sales,
    ROUND(
        AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END) -
        AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2
    ) AS sales_lift
FROM train
GROUP BY item_nbr
HAVING COUNT(*) > 10
ORDER BY sales_lift DESC NULLS LAST
LIMIT 10;

-- 38. Which stores benefit most from promotions?
SELECT
    store_nbr,
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_sales,
    ROUND(
        AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END) -
        AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2
    ) AS sales_lift
FROM train
GROUP BY store_nbr
ORDER BY sales_lift DESC NULLS LAST;

-- 39. Which product families respond best?
SELECT
    i.family,
    ROUND(AVG(CASE WHEN t.onpromotion = TRUE THEN t.unit_sales END),2) AS promo_sales,
    ROUND(AVG(CASE WHEN t.onpromotion = FALSE THEN t.unit_sales END),2) AS non_promo_sales,
    ROUND(
        AVG(CASE WHEN t.onpromotion = TRUE THEN t.unit_sales END) -
        AVG(CASE WHEN t.onpromotion = FALSE THEN t.unit_sales END),2
    ) AS sales_lift
FROM train t
JOIN items i
ON t.item_nbr = i.item_nbr
GROUP BY i.family
ORDER BY sales_lift DESC NULLS LAST;

-- 40. Weekend vs Weekday promotion effectiveness
SELECT
    CASE
        WHEN EXTRACT(DOW FROM date) IN (0,6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_sales
FROM train
GROUP BY day_type;

-- 41. Monthly promotion impact
SELECT
    TO_CHAR(date,'Mon') AS month,
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_sales
FROM train
GROUP BY month, EXTRACT(MONTH FROM date)
ORDER BY EXTRACT(MONTH FROM date);

-- 42. Products that perform well without promotions
SELECT
    item_nbr,
    ROUND(AVG(unit_sales),2) AS avg_sales_without_promotion
FROM train
WHERE onpromotion = FALSE
GROUP BY item_nbr
ORDER BY avg_sales_without_promotion DESC
LIMIT 10;

--- Which products perform poorly even after promotions?
SELECT
item_nbr,
ROUND(AVG(unit_sales),2) AS promo_avg_sales
FROM train
WHERE onpromotion=TRUE
GROUP BY item_nbr
ORDER BY promo_avg_sales
LIMIT 10;

-- Overall Sales Lift %
-- Sales Lift %= (Non-Promo Avg SalesPromo Avg Sales) − (Non-Promo Avg Sales​)  * 100 / non promo avg_sales

SELECT
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_avg_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_avg_sales,
    ROUND(
        (
            AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END) -
            AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END)
        )
        /
        NULLIF(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),0)
        * 100,
        2
    ) AS sales_lift_percentage
FROM train;

-- Product-wise Sales Lift %
SELECT
    item_nbr,
    ROUND(AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END),2) AS promo_avg_sales,
    ROUND(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),2) AS non_promo_avg_sales,
    ROUND(
        (
            AVG(CASE WHEN onpromotion = TRUE THEN unit_sales END) -
            AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END)
        )
        /
        NULLIF(AVG(CASE WHEN onpromotion = FALSE THEN unit_sales END),0)
        * 100,
        2
    ) AS sales_lift_percentage
FROM train
GROUP BY item_nbr
HAVING COUNT(*) > 10
ORDER BY sales_lift_percentage DESC NULLS LAST
LIMIT 10;

------------ Holiday Analysis -----------------

-- 42. Holiday vs Non-Holiday Average Daily Sales
WITH sales_summary AS
(
SELECT
    t.date,
    CASE
        WHEN h.date IS NOT NULL THEN 'Holiday'
        ELSE 'Non-Holiday'
    END AS day_type,
    SUM(t.unit_sales) AS daily_sales
FROM train t
LEFT JOIN holidays_events h
ON t.date = h.date
AND h.transferred = FALSE
GROUP BY
    t.date,
    day_type
)
SELECT
    day_type,
	ROUND(AVG(daily_sales),2) AS avg_daily_sales
FROM sales_summary
GROUP BY day_type;

-- 43. Holiday Sales Growth Percentage (Industry Standard)
WITH sales_summary AS
(
SELECT
    t.date,
    CASE
        WHEN h.date IS NOT NULL THEN 'Holiday'
        ELSE 'Non-Holiday'
    END AS day_type,
    SUM(t.unit_sales) AS daily_sales
FROM train t
LEFT JOIN holidays_events h
ON t.date = h.date
AND h.transferred = FALSE
GROUP BY
    t.date,
    day_type
),

avg_sales AS
(
SELECT
    day_type,
    AVG(daily_sales) AS avg_sales
FROM sales_summary
GROUP BY day_type
)

SELECT
ROUND(
(
MAX(CASE WHEN day_type='Holiday' THEN avg_sales END)
-
MAX(CASE WHEN day_type='Non-Holiday' THEN avg_sales END)
)
/
MAX(CASE WHEN day_type='Non-Holiday' THEN avg_sales END)
*100
,2)
AS holiday_sales_growth_percentage
FROM avg_sales;

-- 45. Which Holidays Generate the Highest Sales?
SELECT
    h.description AS holiday_name,
    ROUND(SUM(t.unit_sales),2) AS total_sales
FROM train as t
JOIN holidays_events as h
ON t.date = h.date

WHERE h.transferred = FALSE
GROUP BY h.description
ORDER BY total_sales DESC;

-- 46. Holiday Impact by Product Family
SELECT
    i.family,

    ROUND(SUM(
        CASE
            WHEN h.date IS NOT NULL THEN t.unit_sales
            ELSE 0
        END
    ),2) AS holiday_sales

FROM train t

JOIN items i
ON t.item_nbr = i.item_nbr

LEFT JOIN holidays_events h
ON t.date = h.date
AND h.transferred = FALSE

GROUP BY i.family
ORDER BY holiday_sales DESC;

-- 47. Holiday Impact by Store
SELECT
    s.store_nbr,
    s.city,

    ROUND(SUM(t.unit_sales),2) AS holiday_sales

FROM train t
JOIN stores s
ON t.store_nbr = s.store_nbr

JOIN holidays_events h
ON t.date = h.date

WHERE h.transferred = FALSE

GROUP BY
    s.store_nbr,
    s.city

ORDER BY holiday_sales DESC;

------------- Inventory Optimization ---------------

-- 47. Which products show steadily increasing demand?
WITH monthly_sales AS (
SELECT
item_nbr,
DATE_TRUNC('month', date) AS month,
SUM(unit_sales) AS total_sales
FROM train
GROUP BY item_nbr, month
)

SELECT
item_nbr,
month,
total_sales,
LAG(total_sales) OVER(PARTITION BY item_nbr ORDER BY month) AS previous_month_sales
FROM monthly_sales
ORDER BY item_nbr, month;

-- 48. Which products have highly volatile demand?
SELECT
item_nbr,
ROUND(STDDEV(unit_sales),2) AS demand_variation
FROM train
GROUP BY item_nbr
ORDER BY demand_variation DESC;

-- 49. Which products should receive more inventory next month?
WITH monthly_sales AS (
    SELECT
        item_nbr,
        DATE_TRUNC('month', date) AS month,
        SUM(unit_sales) AS monthly_sales
    FROM train
    GROUP BY item_nbr, DATE_TRUNC('month', date)
),

recent_sales AS (
    SELECT
        item_nbr,
        AVG(monthly_sales) AS avg_recent_sales
    FROM monthly_sales
    GROUP BY item_nbr
)

SELECT
    item_nbr,
    ROUND(avg_recent_sales,2) AS avg_monthly_sales
FROM recent_sales
WHERE avg_recent_sales >
(
    SELECT AVG(avg_recent_sales)
    FROM recent_sales
)
ORDER BY avg_monthly_sales DESC;

-- 50. Which stores face the highest stockout risk?
SELECT
store_nbr,
SUM(unit_sales) AS total_sales
FROM train
GROUP BY store_nbr
ORDER BY total_sales DESC;

-- 51. Which product families require safety stock before holidays?
SELECT
i.family,
SUM(t.unit_sales) holiday_sales
FROM train t
JOIN holidays_events h
ON t.date=h.date
JOIN items i
ON t.item_nbr=i.item_nbr
GROUP BY i.family
ORDER BY holiday_sales DESC;

-- 52. Which products are overstocked based on declining demand?
WITH monthly_sales AS
(
SELECT
item_nbr,
DATE_TRUNC('month',date)as month,
SUM(unit_sales) sales
FROM train
GROUP BY item_nbr,month
)

SELECT
item_nbr,
month,
sales,

LAG(sales)
OVER(PARTITION BY item_nbr ORDER BY month)
AS previous_month,

sales-
LAG(sales)
OVER(PARTITION BY item_nbr ORDER BY month)
AS sales_change

FROM monthly_sales;

-- 53. Which products should be reordered first?
WITH monthly_sales AS
(
SELECT
item_nbr,
DATE_TRUNC('month',date) month,
SUM(unit_sales) sales
FROM train
GROUP BY item_nbr,month
),

trend AS
(
SELECT
*,
sales-
LAG(sales)
OVER(PARTITION BY item_nbr ORDER BY month)
AS growth
FROM monthly_sales
)

SELECT
item_nbr,
SUM(sales) total_sales,
AVG(growth) avg_growth
FROM trend
GROUP BY item_nbr
ORDER BY avg_growth DESC,total_sales DESC
LIMIT 20;

-- 54. Which stores require inventory redistribution?
SELECT
store_nbr,
SUM(unit_sales) AS total_sales
FROM train
GROUP BY store_nbr
ORDER BY total_sales;

-- 55. ABC Inventory Analysis
WITH product_sales AS (
SELECT
item_nbr,
SUM(unit_sales) AS sales
FROM train
GROUP BY item_nbr
),
ranked AS(
SELECT *,
SUM(sales) OVER(ORDER BY sales DESC) AS running_sales,
SUM(sales) OVER() AS total_sales
FROM product_sales
)
SELECT
item_nbr,
sales,
ROUND((running_sales/total_sales)*100,2) AS cumulative_percentage,
CASE
WHEN running_sales/total_sales<=0.80 THEN 'A'
WHEN running_sales/total_sales<=0.95 THEN 'B'
ELSE 'C'
END AS category
FROM ranked
ORDER BY sales DESC;

-- 56. XYZ Demand Variability Analysis
SELECT
item_nbr,
ROUND(STDDEV(unit_sales),2) AS demand_std,
CASE
WHEN STDDEV(unit_sales)<=5 THEN 'X'
WHEN STDDEV(unit_sales)<=20 THEN 'Y'
ELSE 'Z'
END AS xyz_category
FROM train
GROUP BY item_nbr
ORDER BY demand_std;

---------------- Forecasting Readiness -------------

-- 58. Create Rolling 7-Day Average Demand for Each Product
SELECT
    item_nbr,
    date,
    unit_sales,
    ROUND(
        AVG(unit_sales) OVER (
            PARTITION BY item_nbr
            ORDER BY date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7_day_avg
FROM train
ORDER BY item_nbr, date;

-- 59. Identify Products with Seasonal Demand
SELECT
    item_nbr,
    EXTRACT(MONTH FROM date) AS month,
    ROUND(AVG(unit_sales),2) AS avg_monthly_sales
FROM train
GROUP BY item_nbr, month
ORDER BY item_nbr, month;

-- 60. Build Demand Forecasting Dataset Using SQL
SELECT
    t.date,
    t.store_nbr,
    t.item_nbr,
    t.unit_sales,

    LAG(t.unit_sales,1) OVER(
        PARTITION BY t.item_nbr
        ORDER BY t.date
    ) AS previous_day_sales,

    ROUND(
        AVG(t.unit_sales) OVER(
            PARTITION BY t.item_nbr
            ORDER BY t.date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7_day_avg,
    t.onpromotion,
    CASE
        WHEN h.type IS NOT NULL THEN 1
        ELSE 0
    END AS holiday_flag
FROM train t
LEFT JOIN holidays_events h
ON t.date = h.date
ORDER BY t.item_nbr, t.date;