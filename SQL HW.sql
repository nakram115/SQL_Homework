SELECT * FROM sakila.actor;
use sakila;
SET SQL_SAFE_UPDATES = 0;

/*1a. Display the first and last names of all actors from the table `actor`*/

select first_name,last_name from sakila.actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.*/
Select upper(first_name), upper(last_name) as "Actor Name" from actor;


/** 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/

Select actor_id,first_name,last_name from sakila.actor
where first_name = 'Joe';

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
Select * from sakila.actor
where last_name like '%GEN%';

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, 
in that order*/
Select * from sakila.actor
where last_name like '%LI%'
ORDER BY last_name, first_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/
select COUNTRY_ID,COUNTRY FROM SAKILA.COUNTRY
WHERE COUNTRY IN ('Afghanistan','Bangladesh','China');

/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
Hint: you will need to specify the data type.*/
ALTER TABLE SAKILA.ACTOR
ADD COLUMN middle_name varchar(20) after first_name;

/* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to
 `blobs`*/
ALTER TABLE SAKILA.ACTOR 
MODIFY COLUMN middle_name BLOB;

/* 3c. Now delete the `middle_name` column.*/
ALTER TABLE SAKILA.ACTOR 
drop column middle_name;


/* 4a. List the last names of actors, as well as how many actors have that last name.*/
Select last_name, count(*) as Total from actor
Group by last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least 
two actors*/
Select last_name, count(*) as Total from actor
Group by last_name
having count(*) >2;

/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/
UPDATE actor 
SET first_name="Harpo"
WHERE first_name = "Groucho";

select * from sakila.actor
where first_name="Harpo";

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `
MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY 
ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor 
SET first_name="Groucho"
WHERE actor_id = 78 and 106;

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? */
create table if not exists sakila.address
(
UserID varchar(50),
Password varchar(50)
);


/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and 
`address`:*/
select first_name,last_name,address
from staff s 
join address a 
on s.address_id = a.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. */
select s.staff_id, sum(amount) as gross
from payment p 
join staff s 
on (p.staff_id = s.staff_id)
where year(payment_date) = '2005' and month(payment_date) = '08'
group by s.staff_id;

/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.*/
select f.title,count(fa.actor_id)
from film f
inner join film_actor fa 
on (f.film_id = fa.actor_id)
group by title order by title asc;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
select count(inventory_id )
 from inventory
 where film_id in 
(
	select film_id
    from film
    where title="Hunchback Impossible"
);
/*select count(inventory_id )
 from inventory I
 INNER JOIN FILM F ON I.FILM_ID = F.FILM_ID
where F.title="Hunchback Impossible"*/


/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers 
alphabetically by last name:*/ 
 select c.customer_id ,last_name,sum(amount) as total
 from customer c
 join payment p
 on (c.customer_id = p.customer_id)
 group by last_name;
 
 /* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
 films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
 of movies starting with the letters `K` and `Q` whose language is English.*/


select f.title
from language l
inner join film f 
on (l.language_id=f.language_id)
where f.title like 'Q%'  or F.TITLE like'K%'
and f.language_id in(1)

(
	select l.language_id
    from language l
    where l.name= "English"
);

/*Use subqueries to display all actors who appear in the film `Alone Trip`.*/

select actor.first_name,actor.last_name
from actor
where actor_id in
(
	select actor_id 
	from film_actor 
	where film_id=
(
		select film_id
		from film
		where film.title="Alone Trip")
);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.*/

select c.first_name, c.last_name,c.email
from  customer c
where c.address_id in
(
	select address_id
	from address a
	where a.city_id in
(		select city_id
		from city
		inner join country on country.country_id=city.country_id
		where country.country="Canada")
);

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films.*/

select f.title
from film f
where film_id in

(	select film_id
	from film_category fc
	where fc.category_id =
    
(		select category_id
		from category
		where name="Family"
)
);

/* 7e. Display the most frequently rented movies in descending order.*/
select f.title , count(r.inventory_id )
from rental r
inner join inventory i
on i.inventory_id= r.inventory_id
inner join film f on f.film_id = i.film_id
group by f.title
order by count(r.inventory_id ) desc

/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
  
select st.store_id, sum(p.amount) as total
from payment p
inner join staff s
on (p.staff_id = s.staff_id)
inner join store st
on st.store_id = s.store_id
GROUP BY st.store_id;
 
/*7g. Write a query to display for each store its store ID, city, and country.*/
  
select s.store_id,c.city,cy.country
from store s
INNER JOIN address a
on s.address_id=a.address_id
inner join city c
on a.city_id=c.city_id
inner join country cy
on cy.country_id=c.country_id;

/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: 
category, film_category, inventory, payment, and rental.)*/


SELECT X.NAME, X.GrossRevenue
 FROM 	(select c.name, sum(p.amount) as "GrossRevenue"
from category c
inner join film_category fc
on c.category_id=fc.category_id
inner join inventory i
on i.film_id=fc.film_id
inner join rental r
on i.inventory_id=r.inventory_id
inner join payment p
on r.customer_id=p.customer_id
group by (c.name)  
) X
order by x.GrossRevenue desc
limit 5;


/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a 
view.*/

Create View `view_top_5_genres` as 
SELECT X.NAME, X.GrossRevenue
 FROM 	(select c.name, sum(p.amount) as "GrossRevenue"
from category c
inner join film_category fc
on c.category_id=fc.category_id
inner join inventory i
on i.film_id=fc.film_id
inner join rental r
on i.inventory_id=r.inventory_id
inner join payment p
on r.customer_id=p.customer_id
group by (c.name)  
) X
order by x.GrossRevenue desc
limit 5;

  	
/* 8b. How would you display the view that you created in 8a?*/

SELECT * FROM top_5_genres;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/

DROP VIEW top_5_genres;
 