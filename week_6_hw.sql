/*1.Show all customers whose last names start with T. Order them by first name from A-Z.
I took last name column from customer table and filtered last name starts with 'T' using where clause. sorted first name 
alphabetically*/

select last_name
from customer
where last_name like 'T%'
order by first_name;

/*2.Show all rentals returned from 5/28/2005 to 6/1/2005
-- I have selected all columns from rental table using select * and printed the columns for return date between '5/28/2005' and
'6/1/2005'*/

select *
from rental
where return_date
BETWEEN '5/28/2005' and '6/1/2005';


/*3.How would you determine which movies are rented the most?
Movies which has more number of entries in the rental records are considered to be most rented movies. Tables I joined here is
rental--> inventory--> film. Inner joined rental and inventory tables using inventory_id, joined inventory and film tables using film_id.
Aliased count of rental_id as movies_count. I have grouped by title and ordered by movies count column in descending order so that the 
max count will appear in top. My output appears with two columns(title, movies_count)*/

SELECT title, count(rental_id) as movies_count
FROM rental 
inner join inventory 
using(inventory_id)
inner join film 
using(film_id)
group by title
order by movies_count desc;

/*4.Show how much each customer spent on movies (for all time).Order them from least to most.
Tables joined for this query is customer--> payment
Started the query by concatinating first and last name and aliased as customer_full_name. calculated sum of amount and named as 
total_spent and these are tho two columns appears in my output. Using customer_id i did inner join for customer,payment tables.
Printed the total spent money in ascending order.*/

select CONCAT(first_name , ' ' , last_name)as customer_full_name,sum(amount) as total_spent
from customer
inner join payment
using(customer_id)
group by customer_full_name
order by total_spent ;

-- I have added '$' symbol in the total spent column for the above query and now my total spent column has '$' symbol in it.
select customer_name, '$'||total_spent from
(select CONCAT(first_name , ' ' , last_name)as customer_name,sum(amount) as total_spent
from customer
full join payment
using(customer_id)
group by customer_name
order by total_spent)a ;

--5.Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count 
--as a more descriptive name. Order the results from most to least.
/* Tables joined for this query is actor and film_actor table using actor_id, film_actor and film table using film_id
Started the query by concatinating first and last name and aliased as actor_full_name. Calculated count of film_id and named as 
no_of_movies.I have filtered the films which were released in 2006 year in where clause. I did group by using actor_full_name. 
Ordered the no_of_movies column from most to least. */

SELECT CONCAT(first_name , ' ' , last_name)as actor_full_name,count(film_id) as no_of_movies
from actor
inner join film_actor
using(actor_id)
inner join film 
using(film_id)
where release_year = 2006
group by actor_full_name
order by no_of_movies desc;

--6.Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to 
--understand how this works http://postgresguide.com/performance/explain.html 

/* Explain Plan for question 4
explain plan briefly tells us how much the cost of execution fpr each line of query, actual run time, number of rows calculated,
how much memory used for each operation.I used explain analyze keyword to read the query plan.*/

select CONCAT(first_name , ' ' , last_name)as customer_name,sum(amount) as total_spent
from customer
--starting cost is 0.00 and 14.99 for Seq Scan on customer and number of rows calculated here is 599 run time for this is 0.028 to 0.372
--Memory Usage: 39kB
full join payment
--Seq Scan on payment cost=253.96 and rows=14596,actual run time is 0.019..1.464, Hash Full Join cost=22.48..351.51 rows=14596,
--actual run time is 0.529..12.592, Memory Usage: 297kB
using(customer_id) --Hash Condition:payment.customer_id = customer.customer_id)
--Group Key: concat(customer.first_name, ' ', customer.last_name),
--HashAggregate cost=424.49..433.47, rows=599, actual run time=18.630..18.934 
group by customer_name
--Sort Key: (sum(payment.amount)),Sort Method: quicksort  Memory: 71kB
order by total_spent ;
--Sort cost=461.11..462.60 rows=599,actual time=19.299..19.326 
--Planning Time: 0.336 ms and Total query runtime: 192 msec. */


/* Explain Plan for question 5 */

SELECT CONCAT(first_name , ' ' , last_name)as actor_full_name,count(film_id) as no_of_movies
--Seq Scan on film cost=0.00..66.50, rows=1000,actual time=0.013..0.296. Filter: ((release_year)::integer = 2006), Memory Usage: 44kB
from actor
--Seq Scan on actor cost=0.00..4.00,rows=200,actual time=0.014..0.043. Hash(cost=66.50..66.50 rows=1000)(actual time=0.442..0.443)
inner join film_actor
--Seq Scan on film_actor cost=0.00..84.62,rows=5462,actual time=0.017..0.537 and rows=5462. Hash(cost=4.00..4.00 rows=200) 
--actual time=0.087..0.087,Memory Usage: 18kB
using(actor_id)
-- Hash Cond: (film_actor.actor_id = actor.actor_id)
inner join film 
-- Hash Join (cost=85.50..212.81 rows=5462) (actual time=0.637..6.529 rows=5462 ) Memory Usage: 64kB
using(film_id)
-- Hash Cond: (film_actor.film_id = film.film_id)
where release_year = 2006
--Group Key: concat(actor.first_name, ' ', actor.last_name)
--HashAggregate (cost=240.12..241.72 rows=128 ) actual time=8.609..8.651 
group by actor_full_name
--Sort (cost=246.20..246.52 rows=128) actual time=8.715..8.727, 
--Sort Method: quicksort  Memory: 40kB
order by no_of_movies desc;
--Sort Key: (count(film.film_id)) DESC, Planning Time: 0.683 ms, Total query runtime: 111 msec.


--7.What is the average rental rate per genre?
/*I have selected category name column from category table and named as genre_name. By using aggregate function avg() I have calculated 
average rental_rate and aliased as avg_rental_rate. I did join category and film_category tables using category_id and joined film_category, 
film tables using film_id. Grouped by genre_name. */
select c.name as genre_name,round(avg(rental_rate),2) as avg_rental_rate
from category as c
join film_category
using(category_id)
join film
using(film_id)
group by 1;

--8.How many films were returned late? Early? On time?
--Method 1
/* To calculate which films are returned late,on time, early we have to find the difference between return_date and rental_date, and then
compare it with rental_duration. If both are equals, than dvds returned on time. If rental_duration is greater than the difference. then 
returned early. If rental_duration is less than the difference then it returned late. We cannot find the difference between two dates, 
since it is with timestamp. I have used the date_part syntax and compared with 'day'. Tables I used here are rental-->inventory-->film
I have created 'late','Ontime','Early columns by using select statements. Joined the tables using keywords. Using where clause I have checked
the comparisons.count(*) helps us to count the dvds. I used union all to join these three conditions and printed in single table with two columns.
*/
--Late,
select 'Late',count(*)
from rental as r
join inventory as i 
using(inventory_id)
join film as f
using(film_id)
where rental_duration > date_part('day',r.return_date -r.rental_date)
union all
--On Time
select 'On Time',count(*)
from rental as r
join inventory as i 
using(inventory_id)
join film as f
using(film_id)
where rental_duration = date_part('day',r.return_date -r.rental_date)
union all
--Early
select 'Early',count(*)
from rental as r
join inventory as i 
using(inventory_id)
join film as f
using(film_id)
where rental_duration < date_part('day',r.return_date -r.rental_date)
or (rental_duration < date_part('day',r.return_date -r.rental_date) is null)


--Method 2
/* I did the same part by using subquery method just to reduce the query length.  */
select return_description, count(*) from (
	select film_id, 
	case when rental_duration > date_part('day',r.return_date -r.rental_date) then 'Late'
	 	 when rental_duration = date_part('day',r.return_date -r.rental_date) then 'On Time'
		 else 'Early' END as return_description
from rental as r
join inventory as i 
using(inventory_id)
join film as f
using(film_id)
) a
group by a.return_description;

--9.What categories are the most rented and what are their total sales?
/* I have selected name from category table and named as category_name. Counted the category_id and gave alias as category_rental_count.
Calculated sum of amount and named as total_sales. I have joined category and film_category tables using category_id,film_category and
inventory tables using film_id, inventory and rental using inventory_id, rental and payment tables using rental_id. Grouped by 
category_name and ordered category_rental_count in descending order. It seems like sports genre are the most rented ones. */

select c.name as category_name, count(*) as category_rental_count,sum(amount) as total_sales
from category as c
join film_category 
using(category_id)
join inventory
using(film_id)
join rental
using(inventory_id)
join payment
using(rental_id)
group by category_name
order by category_rental_count desc;



--10.Create a view for 8 and a view for 9. Be sure to name them appropriately. 
/* Views can join and simplify multiple tables into a single virtual table. I have created a view for question 8 and named 
as dvd_return_summary. Now I can see that table by using select * from dvd_return_summary. Usually we can select columns from the tables
which is in our schemas. Actually this dvd_summary_table is not one of our tables from database. But still we can view. This is the 
advantage of creating view. 
Without creating view we are not able to see any columns or even that summary table. Because it is not in the schema.*/


-- Creating view for question 8

create view dvd_return_summary as 
select return_description, count(*) from (
	select film_id, 
	case when rental_duration > date_part('day',r.return_date -r.rental_date) then 'Late'
	 	 when rental_duration = date_part('day',r.return_date -r.rental_date) then 'On Time'
		 else 'Early' END as return_description
from rental as r
join inventory as i 
using(inventory_id)
join film as f
using(film_id)
) a
group by a.return_description;

select * from dvd_return_summary

-- Creating view for question 9

/* I have created a view for question 9 and named as most_rented_category. Now I can see that table by using select * from 
most_rented_category. We can select any specific columns if we want to view.  */

create view most_rented_category as
select c.name as category_name, count(*) as category_rental_count,sum(amount) as total_sales
from category as c
join film_category 
using(category_id)
join inventory
using(film_id)
join rental
using(inventory_id)
join payment
using(rental_id)
group by category_name
order by category_rental_count desc;

select * from most_rented_category

--Bonus:11.Write a query that shows how many films were rented each month. Group them by category and month.

/* I have extracted month from rental_date to calculate the number of films rented in every month. I have joined film and inventory 
table using film_id columns, inventory and rental tables using inventory_id columns. Counted the film_id and named the column as film_count.
Grouped by month and ordered the month column in ascending order.*/

select date_part('month',rental_date) as month, count(film_id) as film_count
from film
join inventory
using(film_id)
join rental
using(inventory_id)
group by month
order by month;
