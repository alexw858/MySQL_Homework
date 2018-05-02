use sakila;

#1A Display the first and last names of all actors from the table `actor`
select first_name, last_name from actor;

#1B Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`
alter table actor
add column `Actor Name` varchar(50);
update actor set `Actor Name` = concat(first_name, ' ', last_name);

#2A You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one 
#query would you use to obtain this information?
select * from actor
where first_name = "Joe";

#2B Find all actors whose last name contain the letters `GEN`:
select * from actor
where last_name like "%gen%";

#2C Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select * from actor
where last_name like "%li%"
order by last_name, first_name;

#2D Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country
where country in ("Afghanistan", "Bangladesh", "China");

#3A Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify 
#the data type
alter table actor
add column `Middle Name` varchar(50)
after first_name;

#3B You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to 
#`blob`
alter table actor
modify `Middle Name` blob;

#3C Now delete the `middle_name` column
alter table actor
drop `Middle Name`;
select * from actor;

#4A List the last names of actors, as well as how many actors have that last name
select last_name,
count(*) as ct from actor group by last_name
order by ct desc;

#4B List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,
count(*) as ct from actor group by last_name
having count(last_name) >=2
order by ct desc;

#4C Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second 
#cousin's husband's yoga teacher. Write a query to fix the record.
update actor
	set first_name = 'HARPO', `Actor Name` = 'HARPO WILLIAMS'
    where `Actor Name` = 'GROUCHO WILLIAMS';
select * from actor
where first_name = 'HARPO';

#4D if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`
update actor
	set first_name = 'GROUCHO', `Actor Name` = 'GROUCHO WILLIAMS'
    where first_name = 'HARPO';
#There is apparently more than one harpo, so changing harpo to groucho where the first name is harpo changes multiple rows
select * from actor
where first_name = 'GROUCHO';

#5A You cannot locate the schema of the `address` table. Which query would you use to re-create it?
select * from sakila.address;
#SHOW CREATE TABLE tbl_name
show create table sakila.address;

#6A Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
select * from staff;
select * from address;
select staff.first_name, staff.last_name, address.address_id, address.address
from address
inner join staff on
staff.address_id = address.address_id;

#6B Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment` (create_views)
select * from staff;
select * from payment;
select staff.staff_id, sum(amount) as Gross
from payment join staff on
(staff.staff_id = payment.staff_id)
group by staff.staff_id;

#6C List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join
#using subquery:
select * from film_actor;
select * from film;
select film.title, myalias.num_actors
from film,
	(select film_id, count(*) as num_actors
    from film_actor
    group by film_id) as myalias
where film.film_id = myalias.film_id;
#using inner join:
select film.title, count(*) as num_actors
from film_actor
join film on (film_actor.film_id = film.film_id)
group by film.film_id;

#6D How many copies of the film `Hunchback Impossible` exist in the inventory system?
select * from inventory;
select * from film where title = "Hunchback Impossible";
#This line works: (need to check for correctness)
select count(*)
from inventory, film 
where inventory.film_id = film.film_id 
and film.title = "Hunchback Impossible";

select count(*)
from inventory
JOIN film ON inventory.film_id = film.film_id  
WHERE film.title = "Hunchback Impossible";

#6E Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers 
#alphabetically by last name
select * from payment;
select * from customer;
select payment.customer_id, sum(amount) as total_paid
from customer
join payment on (customer.customer_id = payment.customer_id)
group by customer_id;

#7A Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English
select * from film;
select * from language;
select * from film 
where title like 'K%' or title like 'Q%';
select * from film where language_id in
	(select language_id from language 
    where name = "English") 
and title like 'K%' or title like 'Q%';

#7B Use subqueries to display all actors who appear in the film `Alone Trip`
select * from actor;
select * from film_actor;
select * from film where title = "ALONE TRIP";
select `Actor Name` from actor where actor_id in
	(select actor_id from film_actor where film_id in
		(select film_id from film where title = "ALONE TRIP"));

#7C You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian 
#customers. Use joins to retrieve this information
select * from customer;
select * from address;
select * from city;
select * from country;
select first_name, last_name, email from customer
	inner join address 
	on customer.address_id = address.address_id
		inner join city
		on address.address_id
			inner join country
			on city.city_id where country = "Canada";

#7D Identify all movies categorized as famiy films
select * from film;
select * from film_category;
select * from category;
select title from film where film_id in
	(select film_id from film_category where category_id in
		(select category_id from category where name = "Family"));
        
#7E Display the most frequently rented movies in descending order
select * from rental;
select * from inventory;
select * from film;
select film.title, count(*) as num_rentals
from film join inventory 
on (inventory.film_id = film.film_id)
	join rental 
    on (inventory.inventory_id = rental.inventory_id)
    group by film.film_id order by num_rentals desc;

#7F Write a query to display how much business, in dollars, each store brought in
select * from payment;
select * from store;
select * from staff;
select store.store_id, sum(amount) as Gross
from payment join store
on payment.staff_id = store.manager_staff_id
group by store_id;

#7G Write a query to display for each store its store ID, city, and country
select * from store;
select * from address;
select * from city;
select * from country;
select store_id, city, country from store
join address on store.address_id = address.address_id
	join city on address.city_id = city.city_id
		join country on city.country_id = country.country_id;
        
#7H List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, 
#film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from rental;
select * from payment;
select name, sum(amount) as Gross from category
join film_category on category.category_id = film_category.category_id
	join inventory on film_category.film_id = inventory.film_id
		join rental on inventory.inventory_id = rental.inventory_id
			join payment on payment.rental_id = rental.rental_id
            group by name order by Gross desc limit 5;

#8A Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view
create view top_5_genres as
select name, sum(amount) as Gross from category
join film_category on category.category_id = film_category.category_id
	join inventory on film_category.film_id = inventory.film_id
		join rental on inventory.inventory_id = rental.inventory_id
			join payment on payment.rental_id = rental.rental_id
            group by name order by Gross desc limit 5;
            
#8B How would you display the view that you created in 8a?
select * from top_5_genres;

#8C You find that you no longer need the view `top_five_genres`. Write a query to delete it
drop view top_5_genres;