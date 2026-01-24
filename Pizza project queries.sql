create database pizza_db;

use pizza_db;

-- let's import  the csv file
-- Now understand each table (all columns)
select * from order_details; -- order_details_id  order_id  pizza_id  quantity

select * from pizza_types;  -- pizza_type_id  name	category  ingredients

select * from orders;  -- order_id	date  time

select * from pizzas; -- pizza_id  pizza_type_id  size   price

-- Basic:
-- Retrieve the total number of orders placed.
-- Calculate the total revenue generated from pizza sales.
-- Identify the highest-priced pizza.
-- Identify the most common pizza size ordered.
-- List the top 5 most ordered pizza types along with their quantities.


-- Intermediate:
-- Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
-- Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).
-- Find the category-wise distribution of pizzas (to understand customer behaviour).
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)

-- Retrieve the total number of orders placed.
select count(distinct order_id) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.
select cast(sum(o.quantity * p.price) as decimal(10,2)) as total_revenue 
from order_details o join pizzas p
on o.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.

select pt.name as pizza_name,  cast(p.price as decimal(10,2))as price from pizzas p 
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
order by price desc
limit 1 ;

-- Identify the most common pizza size ordered.
select p.size,count(distinct o.order_id) as no_of_orders ,sum(o.quantity) as total_quantity from order_details o
join pizzas p 
on o.pizza_id = p.pizza_id
group by p.size;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name,sum(o.quantity) as 'Total Ordered' from order_details o
join pizzas p 
on o.pizza_id = p.pizza_id 
join pizza_types pt on p.pizza_type_id =pt.pizza_type_id
group by pt.name
order by 2 desc
limit 5;

-- Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).

select pt.category, sum(o.quantity) as 'Total quantity' from
order_details o join pizzas p
on o.pizza_id = p.pizza_id 
join pizza_types pt on p.pizza_type_id =pt.pizza_type_id
group by pt.category ;

-- Determine the distribution of orders by hour of the day at (which time the orders are maximum for inventory management and resource allocation).
select hour(time) as 'Hours of the day',count(distinct order_id) as 'No of order' 
from orders 
group by 1
order by 2 desc;

-- Find the category-wise distribution of pizzas (to understand customer behaviour).
select category ,count(distinct pizza_type_id) as 'No of Pizza'
from pizza_types
group by 1
order by 2;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
with cte as
(select o.date as 'Date',sum(od.quantity) as Total_pizza_ordered_that_day
from order_details od join orders o
on od.order_id = o.order_id
group by 1)
select round(avg(Total_pizza_ordered_that_day),2) as average_per_day
from cte;

-- Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)
select pt.name,sum(o.quantity * p.price) as total_revenue 
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id 
group by 1
order by 2 desc 
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)
select pt.category ,concat(cast((sum(o.quantity * p.price)/
(select sum(o.quantity * p.price)
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id)
)*100 as decimal(10,2)),'%') as 'Revenue Contribution from pizza'
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id
group by 1;

-- revenue contribution from pizza

select pt.name ,concat(cast((sum(o.quantity * p.price)/
(select sum(o.quantity * p.price)
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id)
)*100 as decimal(10,2)),'%') as 'Revenue Contribution from pizza'
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id
group by 1
order by 2 desc;

-- Analyze the cumulative revenue generated over time.
with cte as
(select o.date , cast(sum(od.quantity * p.price) as decimal(10,2)) as Revenue
from order_details od join orders o 
on od.order_id = o.order_id join pizzas p on p.pizza_id = od.pizza_id
group by 1)

select date,Revenue,sum(Revenue) over(order by date) as 'cumulative revenue' 
from cte
group by 1,2;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)
with cte as
(select pt.category ,pt.name,cast(sum(o.quantity * p.price) as decimal(10,2)) as Revenue
from order_details o join pizzas p
on o.pizza_id = p.pizza_id join pizza_types pt 
on p.pizza_type_id =pt.pizza_type_id
group by 1,2)
,cte1 as
( select category,name,revenue,
rank() over(partition by category order by revenue) as rnk
from cte)

select category,name,revenue 
from cte1 
where rnk in (1,2,3)
group by 1,2,3;





