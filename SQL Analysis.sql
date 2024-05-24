-- 1. Total Orders
SELECT COUNT(order_id) AS total_orders
FROM orders

-- 2. Total Revenue
SELECT SUM(price * quantity) AS total_revenue
FROM order_details AS o
JOIN pizzas AS p
ON o.pizza_id = p.pizza_id

-- 3. Total Quantity
SELECT SUM(quantity) AS total_quanity
FROM order_details

-- 4. Average Order Value (AOV)
SELECT round(SUM(price*quantity)/Count(order_id),2) as avg_order_value
FROM order_details AS od
JOIN pizzas AS p
ON p.pizza_id = p.pizza_id

-- 5. Average Number of Pizzas Ordered per Day
WITH cte AS
(SELECT date, SUM(quantity) AS total_quantity
FROM orders AS o
JOIN order_details AS od
ON o.order_id= od.order_id
GROUP BY date)
SELECT round(AVG(total_quantity),0) AS avg_no_of_pizzas_per_day
FROM cte

-- 6. Total Orders per Hour
SELECT EXTRACT(Hour from time) AS hour_of_the_day, COUNT(order_id) as total_orders
FROM orders
GROUP BY Extract(Hour from time)
ORDER BY 1

-- 7. Daily Trend for Total Orders
SELECT to_char(date, 'Day') AS day, COUNT(order_id) AS total_orders
FROM orders
GROUP BY to_char(date, 'Day')
ORDER BY total_orders

-- 8 Monthly Trend for Total Orders
SELECT to_char(date, 'Month') AS month, COUNT(order_id) AS total_orders
FROM orders
GROUP BY to_char(date, 'Month')
ORDER BY total_orders

-- 9. Highest Priced Pizza
SELECT p.pizza_id, p.pizza_type_id AS pizza_type, pt.name, p.size, p.price
FROM pizzas AS p
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1

-- 10. Highest Priced Pizza By Size
With cte AS
(SELECT *,
row_number() OVER(PARTITION BY size ORDER BY price DESC) AS rw
FROM (SELECT p.pizza_id, p.pizza_type_id AS pizza_type, pt.name, p.size, SUM(p.price) AS price
FROM pizzas AS p
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4 DESC))
SELECT pizza_id, pizza_type, name, size, price
FROM cte
WHERE rw = '1'
	
-- 11. Most Commonly Ordered Pizza Size
SELECT size as pizza_size, COUNT(order_id) AS total_orders
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY size
ORDER BY total_orders DESC
LIMIT 1

-- 12. Category-wise Distribution of Pizzas
SELECT category, COUNT(pizza_type_id) as total_pizza_type
FROM pizza_types
GROUP BY category
HAVING category is NOT null

-- 13. Percentage of Revenue by Pizza Type
SELECT pizza_type_id AS pizza_type,
concat(round((SUM(price * quantity)/(SELECT SUM(price*quantity) AS total_revenue
FROM pizzas AS p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id)) * 100,2), '%') AS revenue
FROM pizzas p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id
GROUP BY pizza_type_id
ORDER BY revenue DESC

-- 14. Percentage of Revenue by Pizza Size
SELECT size AS pizza_size,
concat(round((SUM(price * quantity)/(SELECT SUM(price*quantity) AS total_revenue
FROM pizzas AS p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id)) * 100,2), '%') AS revenue
FROM pizzas p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY revenue DESC

-- 15. Top 5 Most Ordered Pizza Types By Quantity
SELECT pizza_type_id, SUM(quantity) AS quantity
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY pizza_type_id
ORDER BY quantity DESC
LIMIT 5

-- 16. Total Pizzas Sold By Category
SELECT category, SUM(quantity) AS total_quantity
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category

-- 17. Top 5 Pizza Types by Revenue
SELECT pizza_type_id, SUM(price * quantity) AS revenue
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY pizza_type_id
ORDER BY revenue DESC
LIMIT 5

-- 18. Bottom 5 Pizza Type by Revenue
SELECT pizza_type_id, SUM(price * quantity) AS revenue
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY pizza_type_id
ORDER BY revenue ASC
LIMIT 5

-- 19. Top 5 Pizza Type by Revenue for each Category
with cte as
(select *,
row_number() over(partition by category order by revenue desc)
from (Select p.pizza_type_id, category, sum(price* quantity) as revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by p.pizza_type_id, category))
Select category, pizza_type_id as pizza_type, revenue
from cte
where row_number <= '3'

-- 20. Cumulative Revenue Generated Overtime
WITH cte AS
(SELECT date, SUM(price * quantity) AS revenue
FROM orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
GROUP BY date)
SELECT *,
SUM(revenue) OVER(ORDER BY date) AS cum_revenue
FROM cte

