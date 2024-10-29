-- Netflix Database

CREATE TABLE Netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(50),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);


SELECT * FROM netflix;

-- Business Problems

--1. Count the number of Movies vs TV Shows


SELECT 
	type, 
	COUNT(*) as Total_Content
FROM netflix
GROUP BY type



--2. Find the most common rating for Movies and TV Shows 


SELECT 
	type, 
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as T1
WHERE ranking = 1



--3. List all movies realeased in a specific year (e.g. 2014)


SELECT
	title,
	release_year
FROM netflix
WHERE type='Movie' and release_year=2014



--4. Find the top 5 countries with the most content on Netflix


SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5



--5. Identify the logest movie

SELECT * 
FROM 
(
	SELECT DISTINCT title as movie,
    split_part(duration,' ',1):: numeric as duration 
    FROM netflix
    WHERE type ='Movie') as subquery
    WHERE duration = 
	( 
		SELECT MAX(split_part(duration,' ',1):: numeric ) 
		FROM netflix)



--6. Find content added in the last 5 years


SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 Years'



--7. Find all the Movies/TV Shows directed by 'Rajiv Chilaka'


SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'



--8. Find all TV Shows with more than 5 seasons


SELECT *
FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5



--9. Count the number of content items in each genre


SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) as total_content,
	ARRAY_AGG(title) AS titles
FROM netflix
GROUP BY genre



--10. Find each year and the average numbers of content released by India on Netflix.
-- Return top 5 year with highest avg content release!


SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*),
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric *100
	,2) AS avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY 3 DESC



--11. List all Movies that are Documentaries


SELECT type, title, listed_in
FROM netflix
WHERE type='Movie' AND listed_in ILIKE '%Documentaries%'



--12. Find all content wihtout director


Select * 
FROM netflix
WHERE director IS NULL



--13. Find how many movies actor 'Salman Khan' appeared in last 10 years.


SELECT title, type, casts, date_added 
FROM netflix
WHERE release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	AND casts ILIKE '%Salman Khan%'



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India


SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



--15. Categorize the content based on the presence of the keyword 'kill' and 'violence' in the 
--    description field label. Label content contianing keywords as 'Bad' and all other content
--	  as 'Good'. Count how many items fall into each category.


WITH new_table
AS
(
SELECT 
*, 
	CASE 
	WHEN 
		description ILIKE '%kill%' or 
		description ILIKE '%violance%' THEN 'Bad_Content'
		ELSE 'Good_Content'
 	END category
FROM netflix
)
SELECT
	category, 
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1

