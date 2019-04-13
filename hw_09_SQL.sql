# Load database "sakila"
USE sakila;

# 1a. Display the first and last names of all actors from the table "actor"
SELECT first_name AS 'First Name', last_name AS 'Last Name' FROM actor;

# 1b. Display the first and last name of each actor in a single column named "Actor Name" in upper case letters
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

# 2a. Display the ID number, first name, and last name of an actor whose first name is "Joe"
SELECT actor_id AS 'Actor ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE first_name = 'Joe';

# 2b. Find all actors whose last name contain the letter "GEN"
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letter "LI" and order the rows by last name and first name
SELECT first_name as 'First Name', last_name AS 'Last Name'
FROM actor
WHERE INSTR(last_name, 'LI') > 0
ORDER BY last_name, first_name;

# 2d. Using "IN", display the "country_id" and "country" columns of Afghanistan, Bangladesh, and China
SELECT country_id AS 'Country ID', country AS 'Country' 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. Create a column in "actor" table named "description" and use the data type "BLOB"
ALTER TABLE actor
ADD COLUMN description BLOB;
-- Check column names in "actor" table
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'actor';

# 3b. Delete the "description" column from "actor" table
ALTER TABLE actor
DROP COLUMN description;
-- Go back to 3a. to check column names in "actor" table

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
SET first_name = 'HARPO'
WHERE (first_name = 'GROUCHO' AND last_name = 'WILLIAMS');
-- Check whether the change takes effect
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

# 4d. Reverse the change made in 4c
UPDATE actor
SET first_name = 'GROUCHO'
WHERE (first_name = 'HARPO' AND last_name = 'WILLIAMS');
-- Go back to 4a. to check whether the change has been reversed

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
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59' 
-- Alternatively: WHERE DATE(p.payment_date) BETWEEN '2005-08-01' AND '2005-08-31'
-- Or: WHERE p.payment_date LIKE '2005-08-%'
GROUP BY p.staff_id;

# 6c. List each film and the number of actors listed for that film
SELECT f.title AS 'Film Title', COUNT(fa.actor_id) AS 'Number of Actors'
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY fa.film_id;

# 6d. Display copies of film "Hunchback Impossible" in the inventory system
SELECT f.title AS 'Film Title', COUNT(i.film_id) AS 'Copies in Inventory System'
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE';

# 6e. List the total paid by each customer in alphabetical order by last name
SELECT c.first_name AS 'First Name', c.last_name AS 'Last Name', SUM(p.amount) AS 'Total Amount Paid'
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
SELECT CONCAT(a.first_name, ' ', a.last_name) AS 'Actors Appearing in "Alone Trip"'
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id IN
(
SELECT f.film_id
FROM film f
WHERE f.title = 'Alone Trip'
);

# 7c. Use "JOIN" to list the names and email addresses of all Canadian customers
-- Solution 1: Use cascades of "JOIN"s
SELECT CONCAT(cx.first_name, ' ', cx.last_name) AS 'Customer Name', cx.email AS 'Customer Email'
FROM customer cx
JOIN address a ON cx.address_id = a.address_id
	JOIN city c ON a.city_id = c.city_id
		JOIN country cntry ON c.country_id = cntry.country_id
        WHERE cntry.country = 'Canada'
;
-- Solution 2: Use subqueries
SELECT CONCAT(cx.first_name, ' ', cx.last_name) AS 'Customer Name', cx.email AS 'Customer Email'
FROM customer cx
JOIN address a ON cx.address_id = a.address_id
WHERE a.city_id IN
(
SELECT c.city_id
FROM city c
JOIN country cntry ON c.country_id = cntry.country_id
WHERE cntry.country = 'Canada'
);

# 7d. Identify all movies categorized as "family" films
SELECT f.film_id AS 'Film ID', f.title AS 'Title of "Family" Film'
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
	JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Family'
;

# 7e. Display the most frequently rented movies in descending order
SELECT f.film_id AS 'Film ID', f.title AS 'Film Title', COUNT(r.inventory_id) AS "Rental Counts"
FROM film f
JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

# 7f. Display how much business, in dollars, each store brought in
SELECT s.store_id AS 'Store ID', SUM(p.amount) AS 'Total Rental Revenue'
FROM store s
JOIN payment p ON s.manager_staff_id = p.staff_id
GROUP BY p.staff_id;

# 7g. Display each store ID, city, and country
SELECT s.store_id AS 'Store ID', c.city AS 'City', cntry.country AS 'Country'
FROM store s
JOIN address a ON s.address_id = a.address_id
	JOIN city c ON a.city_id = c.city_id
		JOIN country cntry ON c.country_id = cntry.country_id
;

# 7h. List the top five genres in gross revenue in descending order
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Gross Revenue'
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film_category fc ON i.film_id = fc.film_id
			JOIN category c ON fc.category_id = c.category_id
GROUP BY i.film_id
ORDER BY SUM(p.amount) DESC
LIMIT 5;

# 8a. Create a view for the top five genres by gross revenue
CREATE VIEW top_five_genres AS
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Gross Revenue'
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film_category fc Otop_five_genresN i.film_id = fc.film_id
			JOIN category c ON fc.category_id = c.category_id
GROUP BY i.film_id
ORDER BY SUM(p.amount) DESC
LIMIT 5;

# 8b. Display the view of top five genres
SELECT * FROM top_five_genres;

# 8c. Delete the view of top five genres
DROP VIEW top_five_genres;