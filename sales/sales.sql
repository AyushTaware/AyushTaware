-- parctice quetions on sales database

use sales;
select * from sales;
-- 1)Write a query to find the total sales amount made by each customer.

select c.first_name,c.last_name,sum(s.total_amount) as total_sales
from customers c join sales s on c.customer_id = s.customer_id
group by s.customer_id;

-- 2)Find how many products are available in each product category.

select category,sum(stock_quantity) as stock_avl
from products
group by category;

-- 3)Display customer names and their total purchase amounts, but only for those who spent more than ₹50,000.

select c.first_name,c.last_name,sum(s.total_amount) as t_purchase
from customers c join sales s on c.customer_id = s.customer_id
group by s.customer_id
having t_purchase>50000;

-- 4)Find the product name that generated the highest total sales amount (quantity × unit_price).

select p.product_id,p.product_name,sum(s.quantity*s.unit_price) as total_sales
from products p join sales_items s on p.product_id=s.product_id
group by p.product_name,p.product_id;

-- 5)Identify sales where customers made payments in more than one transaction.

select c.customer_id,c.first_name,c.last_name,count(p.payment_id) as payment_count
from customers c join sales s on c.customer_id = s.customer_id join payments p on s.sale_id = p.sale_id
group by c.customer_id
having payment_count>1;select*from payments;

-- 6) Show each customer with the list of product names they purchased

select c.customer_id,c.first_name,c.last_name,GROUP_CONCAT(DISTINCT p.product_name ORDER BY p.product_name) AS products_purchased
from customers c join sales s on c.customer_id=s.customer_id join sales_items si on si.sale_id = s.sale_id
join products p on p.product_id = si.product_id
group by c.customer_id;

-- 7)Calculate the total sales amount per month.

select sum(total_amount) as total_amt,date_format(sale_date,'%y-%m') as sale_month
from sales
group by date_format(sale_date,'%y-%m')
order by sale_month;

-- 8) List customers who purchased more than one distinct product in their orders.

select c.customer_id,c.first_name,c.last_name,count(distinct si.product_id) as no_of_dist_products
from sales s join customers c on c.customer_id = s.customer_id join sales_items si on si.sale_id=si.sale_id
group by c.customer_id
having no_of_dist_products>1;

-- 9) Find sales where the total payments received are less than the total_amount in sales.

select s.sale_id,c.first_name,c.last_name,s.total_amount,coalesce(sum(p.amount),0) as total_paid
from customers c join sales s on c.customer_id = s.customer_id left join payments p on p.sale_id = s.sale_id
group by c.customer_id,s.sale_id,s.total_amount,c.first_name,c.last_name
having coalesce(total_paid,0)<s.total_amount;

-- 10) Show each customer with their average sale value.

select c.customer_id,concat(first_name,'',last_name) as customer_name,avg(s.total_amount) as avg_sale
from customers c join sales s on c.customer_id = s.customer_id
group by c.customer_id;

-- find duplicate products

SELECT product_name, category, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_name, category
HAVING COUNT(*) > 1;