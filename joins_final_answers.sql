-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

SELECT film_title, 
	   release_year, 
	   worldwide_gross
FROM specs
LEFT JOIN revenue
USING(movie_id)
ORDER BY worldwide_gross

-- 2. What year has the highest average imdb rating?

SELECT release_year, 
	   ROUND(avg(imdb_rating), 2) AS average_rating
FROM specs
LEFT JOIN rating
USING(movie_id)
GROUP BY release_year
ORDER BY average_rating DESC

-- 3. What is the highest grossing G-rated movie? Which company distributed it?

SELECT film_title, 
       worldwide_gross, 
	   company_name
FROM specs
LEFT JOIN revenue
USING(movie_id)
LEFT JOIN distributors
ON specs.domestic_distributor_id = distributors.distributor_id
WHERE mpaa_rating = 'G'
ORDER BY worldwide_gross DESC

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies 
-- table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

SELECT company_name, 
       COUNT(movie_id)
FROM distributors
LEFT JOIN specs
ON specs.domestic_distributor_id = distributors.distributor_id
GROUP BY company_name

-- 5. Write a query that returns the five distributors with the highest average movie budget.

--Using LEFT JOIN and HAVING
SELECT company_name, 
       CAST(AVG(film_budget) as money) AS average_budget
FROM distributors
LEFT JOIN specs
ON distributors.distributor_id = specs.domestic_distributor_id
LEFT JOIN revenue
USING (movie_id)
GROUP BY company_name
HAVING CAST(AVG(film_budget) as money) IS NOT NULL
ORDER BY average_budget DESC
LIMIT 5

--With INNER JOIN
SELECT company_name, 
       AVG(film_budget) AS avg_budget
FROM distributors d
INNER JOIN specs s
ON d.distributor_id = s.domestic_distributor_id
INNER JOIN revenue r
ON s.movie_id = r.movie_id
GROUP BY company_name
ORDER BY avg_budget DESC
LIMIT 5

--Using LEFT JOIN and OFFSET
--This method only works for this specific set of data since we know there are two nulls. Not recommended, just fun
SELECT company_name, 
       CAST(AVG(film_budget) as money) AS average_budget
FROM distributors
LEFT JOIN specs
ON distributors.distributor_id = specs.domestic_distributor_id
LEFT JOIN revenue
USING (movie_id)
GROUP BY company_name
ORDER BY average_budget DESC
LIMIT 5
OFFSET 2

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

SELECT company_name, 
       headquarters, 
	   film_title, 
	   imdb_rating
FROM specs
LEFT JOIN rating
USING(movie_id)
LEFT JOIN distributors
ON specs.domestic_distributor_id = distributors.distributor_id
WHERE headquarters NOT LIKE '%CA%'
ORDER BY imdb_rating DESC


-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

--Using SELECT creatively
SELECT length_in_min > 120 AS two_hours, 
       AVG(imdb_rating)
FROM specs
LEFT JOIN rating
USING(movie_id)
GROUP BY two_hours

--Using a UNION
SELECT AVG(imdb_rating), 
       'greater' AS greater_or_less_than_two_hr
FROM rating
INNER JOIN specs
USING(movie_id)
WHERE length_in_min > 120
GROUP BY greater_or_less_than_two_hr
UNION
SELECT AVG(imdb_rating), 
       'less' AS greater_or_less_than_two_hr
FROM rating
INNER JOIN specs
USING(movie_id)
WHERE length_in_min < 120
GROUP BY greater_or_less_than_two_hr

--Run each of these and note the amount of time it took to run them. This is a very small dataset, so that difference might not seem like much, but on my computer, it took 0.4ms for the first, 0.6ms for the second. That's 50% more time for the second. 
