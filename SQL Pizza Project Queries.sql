
/*
SQL Case study project
*/

-- let's  import the csv files
-- Now understand each table (all columns)
select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

/*
Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.

*/


-- Retrieve the total number of orders placed.
SELECT count(distinct order_id) as Total_Orders
FROM pizza_case_study.orders

-- Calculate the total revenue generated from pizza sales.

-- to see the details
SELECT *
FROM pizza_case_study.order_detailss as o
inner join pizza_case_study.pizzas as p
on o.pizza_id = p.pizza_id

-- to get the answer
SELECT Round(sum((o.quantity * p.price))) as Total_Revenue
FROM pizza_case_study.order_detailss as o
inner join pizza_case_study.pizzas as p 
on o.pizza_id = p.pizza_id


-- Identify the highest-priced pizza.
-- using Limit functions
SELECT pt.namess as 'name', max(p.price) as Highest_price_pizza  
FROM pizza_case_study.pizzas as p
inner join pizza_case_study.pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.namess
order by Highest_price_pizza desc
limit 1


-- Identify the most common pizza size ordered.

SELECT p.size, count(distinct o.order_id) as Total_Ordered, sum(o.quantity) as Total_Quantity
FROM pizza_case_study.pizzas as p
join pizza_case_study.order_detailss as o
on p.pizza_id = o.pizza_id
group by size
order by Total_Ordered desc 


-- List the top 5 most ordered pizza types along with their quantities.

select pt.namess, count(od.order_id) as Total_ordered, sum(od.quantity) as total_quantity
from pizza_case_study.order_detailss as od
inner join pizza_case_study.pizzas as p on od.pizza_id = p.pizza_id
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.namess
order by total_ordered desc 
limit 5



-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.namess, sum(od.quantity) as total_quantity
from pizza_case_study.order_detailss as od
inner join pizza_case_study.pizzas as p on od.pizza_id = p.pizza_id
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.namess
order by total_quantity desc


-- Determine the distribution of orders by hour of the day.

SELECT HOUR(STR_TO_DATE(time, '%H:%i:%s')) AS hour, count(od.order_id) as total_ordered
FROM pizza_case_study.orders as o
inner join pizza_case_study.order_detailss as od
on o.order_id = od.order_details_id 
group by HOUR(STR_TO_DATE(time, '%H:%i:%s'))
order by total_ordered desc

-- find the category-wise distribution of pizzas

SELECT category, count(distinct pizza_type_id) as total_pizzas
FROM pizza_case_study.pizza_types 
group by category

-- Calculate the average number of pizzas ordered per day.

select floor(avg(total_ordered))as avg_order_per_day from (SELECT o.date as 'dates', sum(od.quantity)as total_ordered
FROM pizza_case_study.orders as o
inner join pizza_case_study.order_detailss as od
on o.order_id = od.order_id
group by o.date) as j

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.namess, round(sum(p.price * od.quantity),2) as total_revenue
FROM pizza_case_study.pizzas as p
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
inner join pizza_case_study.order_detailss as od on od.pizza_id = p.pizza_id
group by pt.namess
order by total_revenue desc limit 3

-- try doing it using window functions also


-- with top_3 as (SELECT pt.namess as namess, round(sum(p.price * od.quantity),2) as total_revenue, 
-- dense_rank() over(order by round(sum(p.price * od.quantity),2) desc) as rnk
-- FROM pizza_case_study.pizzas as p
-- inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
-- inner join pizza_case_study.order_detailss as od on od.pizza_id = p.pizza_id
-- group by pt.namess)

-- select namess, total_revenue
-- from top_3
-- where rnk <= 3


-- Calculate the percentage contribution of each pizza type to total revenues

with cte as (SELECT pt.category, round(sum(p.price * od.quantity),2) as cte_revenue
FROM pizza_case_study.pizzas as p
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
inner join pizza_case_study.order_detailss as od on od.pizza_id = p.pizza_id
group by pt.category),

cte_1 as (SELECT round(sum(p.price * od.quantity),2) as cte1_revenue
FROM pizza_case_study.pizzas as p
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
inner join pizza_case_study.order_detailss as od on od.pizza_id = p.pizza_id)

select category, concat(round((cte_revenue / cte1_revenue) * 100,2),'%') as percentage
from cte,cte_1
order by percentage

-- Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)
with cte as (SELECT o.date as 'dates', round(sum(od.quantity * p.price),2) as total_revenue
FROM pizza_case_study.orders as o
inner join pizza_case_study.order_detailss as od on o.order_id = od.order_id
inner join pizza_case_study.pizzas as p on od.pizza_id = p.pizza_id
group by dates)

select *, round(sum(total_revenue) over(order by dates rows between unbounded preceding and current row),2) as cum_sum
from cte


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (SELECT pt.category,pt.namess , round(sum(p.price * od.quantity),2) as revenue
FROM pizza_case_study.pizzas as p
inner join pizza_case_study.pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
inner join pizza_case_study.order_detailss as od on od.pizza_id = p.pizza_id
group by pt.category, pt.namess
order by pt.category),

top_3 as (select category, namess, revenue,
dense_rank() over(partition by category order by revenue desc) as rnk
from cte)

select category, namess, revenue
from top_3
where rnk <= 3
