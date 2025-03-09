create database pizza_store

use pizza_store


-- Retrieve the total number of orders placed.

select count(distinct order_id) as Total_Orders from orders


--Calculate the total revenue generated from pizza sales.
               
select  round(sum(od.quantity * p.price ),2) as Total_Revenue
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id


--Identify the highest-priced pizza.

select top 1 pt.name , p.price 
from pizza_types pt 
join pizzas p on pt.pizza_type_id =  p.pizza_type_id
order by p.price desc


--Identify the most common pizza size ordered.

select p.size, count(o.order_details_id)
from pizzas p 
join order_details o 
on p.pizza_id = o.pizza_id
group by p.size
order by count(o.order_details_id) desc
 

--List the top 5 most ordered pizza type along their quantities.

select Top 5 pt.name, sum(od.quantity) as Quntity
from pizza_types pt join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id 
group by pt.name
order by sum(od.quantity) desc


/* Join the necessary table to find the
total quantity of each pizza category ordered.*/

select pt.category , sum(od.quantity)
from pizza_types pt 
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on p.pizza_id=od.pizza_id
group by pt.category
order by sum(od.quantity) desc


--Determine the distribution of orders by hour of the day.

select DATEPART(HOUR, time) AS hour, 
COUNT(order_id) AS order_count
from orders
group by DATEPART(HOUR, time)
order by DATEPART(HOUR, time) asc


-- Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name)
from pizza_types
group by category


/* Group the orders by date and calculate the averge number 
of pizzas ordered per day. */

select avg(quantity) as avg_pizza_ordered_perday
from 
(select o.date , sum(od.quantity) as quantity
from orders o 
join order_details od 
on o.order_id = od.order_id
group by o.date) as t 


--Determine top 3 most ordered pizza type based on revenue

select Top 3 pt.name , sum( od.quantity * p.price) as revenue
from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc


--Calculate the percentage contribution of each pizza type to total revenue.


select pt.category ,

round(sum(od.quantity * p.price)*100 / 

	(select  round(sum(od.quantity * p.price ),2) as Total_Revenue
	from order_details od 
	join pizzas p on od.pizza_id = p.pizza_id),2) as Percentage

from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.category


--Analyze the cumulative revenue generated over time. 

select	s.date, 
		sum(revenue) over (order by s.date ) as cum_revenue

from (

select o.date , round(sum(od.quantity * p.price),2 ) as revenue
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join orders o on o.order_id = od.order_id
group by o.date 
) as s 


/* Determine the top 3 most ordered pizza types 
based on revenue for each pizza category */

select category , name, revenue ,rn 
from 
(
select category , name , revenue, 
rank() over(partition by category order by revenue desc) as rn
from 
(
select pt.category, pt.name , 
sum((od.quantity) * p.price) as revenue
from pizza_types pt 
join pizzas p 
	on pt.pizza_type_id = p.pizza_type_id
join order_details od 
	on p.pizza_id = od.pizza_id
group by pt.category, pt.name 
) as a 
) as b 

where rn < 4

