# Load database "sakila"
USE sakila;

# 1a. Display the first and last names of all actors from the table "actor"
SELECT first_name AS 'First Name', last_name AS 'Last Name' FROM actor;

# 1b. Display the first and last name of each actor in a single column named "Actor Name" in upper case letters
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

# 2a. Display the ID number, first name, and last name of an actor whose first name is "Joe"
SELECT actor_id AS 'Actor ID', first_name AS 'First Name', last_name AS 'Last Name' FROM actor WHERE first_name = 'Joe';

# 2b. Find all actors whose last name contain the letter "GEN"
SELECT first_name AS 'First Name', last_name AS 'Last Name' FROM actor WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letter "LI" and display in the order of last name and first name
SELECT last_name as 'Last Name', first_name AS 'First Name' FROM actor WHERE INSTR(last_name, 'LI') > 0;

# 2d. Using "IN", display the "country_id" and "country" columns of Afghanistan, Bangladesh, and China
SELECT country_id AS 'Country ID', country AS 'Country' FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. Create a column in "actor" table named "description" and use the data type "BLOB"
ALTER TABLE actor
ADD COLUMN description BLOB;

# 3b. Delete the "description" column from "actor" table
ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name AS 'Last Name', COUNT(*) AS 'Count of Last Name' 
FROM actor
GROUP BY last_name;

# 4b. List the last names of actors and the number of actors with that last name, but only for names that are shared by at least two actors
SELECT last_name AS 'Last Name', COUNT(*) AS 'Count of Last Name' 
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

# 4c. Change the name of "GROUCHO WILLIAMS" to "HARPO WILLIAMS" in "actor" table
UPDATE actor
SET first_name = 'HARPO' WHERE (first_name = 'GROUCHO' AND last_name = 'WILLIAMS');
-- Check whether the change takes effect
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

# 4d. Reverse the change made in 4c
UPDATE actor
SET first_name = 'GROUCHO' WHERE (first_name = 'HARPO' AND last_name = 'WILLIAMS');

# 5a. Re-create "address" table
SHOW CREATE TABLE address;

# 6a. Use "JOIN" to display the first and last names, as well as the address, of each staff member
SELECT s.first_name AS 'First Name', s.last_name AS 'Last Name', a.address AS 'Address'
FROM staff s
JOIN address a ON s.address_id = a.address_id;

# 6b. Use "JOIN" to display the total amount rung up by each staff member in August of 2005
SELECT CONCAT(s.first_name, ' ', s.last_name) AS 'Staff Name', SUM(p.amount) AS 'Total Revenue'
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59' -- Alternatively: WHERE DATE(p.payment_date) BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY p.staff_id;

# 6c. List each film and the number of actors listed for that film
SELECT f.title AS 'Film Title', COUNT(fa.actor_id) AS 'Number of Actors'
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY fa.film_id;

# 6d. Display copies of film "Hunchback Impossible" in the inventory system
SELECT f.title AS 'Film Title', COUNT(i.film_id) AS 'Inventory Count'
FROM film f, inventory i
WHERE i.film_id IN
(
SELECT f.film_id
FROM film
WHERE f.title = 'Hunchback Impossible'
);

# 6e. List the total paid by each customer in alphabetical order by last name
SELECT c.first_name AS 'First Name', c.last_name AS 'Last Name', SUM(p.amount) AS 'Total Expenses'
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name;

# 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English
SELECT title AS 'Film Title'
FROM film
WHERE (title LIKE 'Q%' OR title LIKE 'K%')
AND language_id IN
(
SELECT language_id
FROM language
WHERE name = 'English'
);

# 7b. Use subqueries to display all actors who appear in the film "Alone Trip"
SELECT CONCAT(first_name, ' ', last_name) AS 'Actors Appearing in "Alone Trip"'
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
	(
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
    )
);

# 7c. Use "JOIN" to list the names and email addresses of all Canadian customers
SELECT CONCAT(cx.first_name, ' ', cx.last_name) AS 'Customer Name', cx.email AS 'Customer Email'
FROM customer cx
JOIN address a ON
cx.address_id = a.address_id
	JOIN city c ON
    a.city_id = c.city_id
		JOIN country cntry ON
        c.country_id = cntry.country_id
        WHERE cntry.country = 'Canada'
;

# 7d. Identify all movies categorized as "family" films
SELECT title AS 'Title of Family Film' 
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN 
	(
    SELECT category_id
    FROM category
    WHERE name = 'Family'
    )
);

# 7e. Display the most frequently rented movies in descending order
SELECT f.title AS 'Film Title', COUNT(i.inventory_id) AS "Rental Counts"
FROM film f, inventory i
WHERE f.film_id = i.film_id
GROUP BY i.film_id
ORDER BY COUNT(i.inventory_id) DESC;

# 7f. Display how much business, in dollars, each store brought in
SELECT sto.store_id AS 'Store ID', SUM(p.amount) AS 'Total Rental Revenue'
FROM store sto, staff sta, payment p -- Actually either "staff" or "store" table is sufficient in this specific case as there is only one staff documented in each store
WHERE sto.store_id = sta.store_id AND sta.staff_id = p.staff_id
GROUP BY p.staff_id;

# 7g. Display each store ID, city, and country
SELECT s.store_id AS 'Store ID', c.city AS 'City', cntry.country AS 'Country'
FROM store s, address a, city c, country cntry
WHERE s.address_id = a.address_id 
AND a.city_id = c.city_id 
AND c.country_id = cntry.country_id;

# 7h. List the top five genres in gross revenue in descending order
SELECT c.name AS 'Film Category', SUM(p.amount) AS 'Gross Revenue'
FROM payment p, rental r, inventory i, film_category fc, category c
WHERE p.rental_id = r.rental_id 
AND r.inventory_id = i.inventory_id 
AND i.film_id = fc.film_id
AND fc.category_id = c.category_id
GROUP BY i.film_id
ORDER BY SUM(p.amount) DESC
LIMIT 0,5;

# 8a. Create a view for the top five genres by gross revenue
CREATE VIEW top_five_genres AS
SELECT c.name AS 'Film Category', SUM(p.amount) AS "Gross Revenue"
FROM payment p, rental r, inventory i, film_category fc, category c
WHERE p.rental_id = r.rental_id 
AND r.inventory_id = i.inventory_id 
AND i.film_id = fc.film_id
AND fc.category_id = c.category_id
GROUP BY i.film_id
ORDER BY SUM(p.amount) DESC
LIMIT 0,5;

# 8b. Display the view of top five genres
SELECT * FROM top_five_genres;

# 8c. Delete the view of top five genres
DROP VIEW top_five_genres;

