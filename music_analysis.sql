
-- Q 1. Who is the most senior employee based on job title?

WITH SENIOR_EMPLOYEE AS (
			SELECT FIRST_NAME,LAST_NAME,LEVELS,
			RANK() OVER(ORDER BY LEVELS DESC) AS RANKING
			FROM EMPLOYEE)

SELECT FIRST_NAME,LAST_NAME,LEVELS
FROM SENIOR_EMPLOYEE
WHERE RANKING <=1
ORDER BY LEVELS DESC

-- Q2 Which countries have the most invoices?

SELECT BILLING_COUNTRY,COUNT(*) AS ORDER_COUNT
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY ORDER_COUNT DESC


--Q 3. What are top 3 values for total invoices?


SELECT TOTAL
FROM INVOICE 
ORDER BY TOTAL DESC
OFFSET 0 ROWS
FETCH FIRST 3 ROWS ONLY


-- Q4. Which city has the best customers? We would like to throw a promotional music festival in the city that made the most money. Write a query
-- that returns one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals.

SELECT sum(TOTAL) AS BEST_CITY,billing_city
FROM INVOICE 
GROUP BY billing_city,total
ORDER BY TOTAL DESC
OFFSET 0 ROWS
FETCH FIRST 1 ROW ONLY


-- Q5. Who is the best customer? The customer who has spent the most money till date will be declared as the best customer. Write a query that
-- returns the person who has spent the most money. 


SELECT c.customer_id,c.first_name,c.last_name,SUM(i.total) as TOTAL
FROM CUSTOMER c
join INVOICE i on
c.customer_id = i.customer_id 
group by c.customer_id,c.first_name,c.last_name
order by TOTAL DESC
offset 0 rows
fetch first 1 row only


--Q6. Find the unit price for each track and sort the tracks based on price from highest to lowest. Return the time taken,song name,song composer

SELECT milliseconds,name,composer
FROM TRACK 
WHERE COMPOSER IS NOT NULL
ORDER BY milliseconds DESC



--Q7.  Find the first and last names of the employees and their respective reporting managers 

select e.first_name,e.last_name,e1.reports_to
from employee e
join employee e1 on e1.reports_to = e.employee_id


--Q 8. Write a query to find the age of all the employees 

select FIRST_NAME,LAST_NAME,BIRTHDATE,
DATEDIFF(yy,birthdate,GETDATE()) + (CASE WHEN DATEPART(MONTH,GETDATE()) - DATEPART(MONTH,BIRTHDATE) < 0 THEN -1 ELSE 0 END) AS AGE 
FROM employee


--Q9. Find the country in which each employee resides in and if the employee resides outside USA, grant them visa else mention that they are a US resident.


Select first_name,last_name,levels,(
		case when country = 'USA' then 'US Resident' 
		else 'Grant Visa' end) as Visa_status
from employee



-- Q. FIND ALL THE CUSTOMERS WHOSE NAME BEGINS WITH VOWELS

SELECT DISTINCT FIRST_NAME,last_name
FROM CUSTOMER
WHERE LEFT(first_name,1) IN ('A','E','I','O','U')


--Q. WE HAVE A HEADOFFICE FOR EMPLOYEES IN CALGARY AND WANT TO KNOW WHICH EMPLOYEES CAN MAKE IT TO THE OFFICE. WRITE A QUERY TO RETURN ALL 
-- THOSE EMPLOYEES WHO LIVE IN CALGARY SO THAT WE CAN CALL THEM TO OFFICE. RETURN THE FULL NAME OF THESE EMPLOYEES.

SELECT CONCAT(FIRST_NAME,' ', LAST_NAME) AS FULLNAME,TITLE,LEVELS,EMAIL,BIRTHDATE,HIRE_DATE,
(CASE WHEN CITY = 'CALGARY' THEN 'EMPLOYEE CAN VISIT THE OFFICE'
ELSE 'EMPLOYEE CANNOT SHOW UP' END) AS 'STATUS'
FROM EMPLOYEE



--Q1. Write a query to return the email,first name,last name,& Genre of all Rock music listeners. 
--Return the list with alphabetically sorted emails in A.


select distinct c.email,c.first_name,c.last_name 
from customer c join invoice i on 
c.customer_id = i.customer_id join invoice_line i2 on
i.invoice_id = i2.invoice_id
where track_id in (
					select track_id 
					from track 
					join genre on track.genre_id = genre.genre_id
					where genre.name like 'Rock' )
order by c.email asc


--Q 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name 
-- and total track count of the top 10 rock bands. 


select a2.artist_id,a2.name , count(a2.artist_id) as count_of_songs
from track t
join album a1 on a1.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
join artist a2 on a2.artist_id = a1.artist_id
where g.name like 'Rock'
group by a2.artist_id,a2.name 
order by count_of_songs desc  
offset 0 rows
fetch first 10 rows only




--Q3. Return the track names that have a song length of longer than the average song length. Return the name and milliseconds for each track.
-- Order the song length with the longest songs listed first. 

select milliseconds as time_of_song,name
from track 
where milliseconds > (select avg(milliseconds) from track )
order by milliseconds desc



--Q4. Find the billing address along with the states for all customers and also return their permanent addresses and contact number. 

SELECT DISTINCT (C.first_name),C.last_name,C.address ,C.city,
		C.country,C.phone,I.billing_address
FROM INVOICE I
JOIN CUSTOMER C ON C.customer_id = I.customer_id
ORDER BY C.first_name ASC




--Q4. Write a query to find the countries from where the different type of genre listeners come from. Return the Country,name of the fan and
-- their favourite genre.

SELECT DISTINCT(C.first_name),C.last_name,C.country,G.name AS TYPES_OF_GENRE
FROM customer C
JOIN invoice I1 ON C.customer_id = I1.customer_id
JOIN invoice_line I2 ON I1.invoice_id = I2.invoice_id
JOIN TRACK T ON I2.track_id = T.track_id
JOIN GENRE G ON T.genre_id = G.genre_id


-- Q5. Write a query to find the total invoice cost for each playlist name. Return the playlist name,total invoice cost.

SELECT DISTINCT P2.NAME,(I2.unit_price*I2.quantity) AS TOTAL_COST
FROM INVOICE_LINE I2
JOIN invoice I1 ON I2.invoice_id = I1.invoice_id
JOIN playlist_track P1 ON I2.track_id = P1.track_id
JOIN playlist P2 ON P1.playlist_id = P2.playlist_id




-- Q6. Find the time duration for each playlist and output the time as well as the name of the TRACK & THE playlist. 

SELECT DISTINCT P2.NAME,T.milliseconds,T.name
FROM PLAYLIST_TRACK P1 
JOIN TRACK T ON P1.track_id = T.track_id
JOIN playlist P2 ON P1.playlist_id = P2.playlist_id




--Q7. Write a query to find the media type of all the playlists in the library. Return the track name,playlist and media type for each track.
-- Output should be in alphabetic order of the track names. 

SELECT distinct T.NAME AS Track_Name, P.NAME AS Playlist_Name , M.NAME AS Media_Type_Name
FROM TRACK T
JOIN playlist_track P1 ON T.track_id = P1.track_id
JOIN PLAYLIST AS P ON P1.playlist_id = P.playlist_id
JOIN media_type AS M ON T.media_type_id = M.media_type_id
ORDER BY T.NAME ASC
 



--Q8. Find the total invoice order for all CUSTOMERS. Return the emp first & last name and invoice total.

SELECT C.first_name,C.last_name,I.total 
FROM CUSTOMER C 
JOIN INVOICE I ON C.customer_id = I.customer_id
GROUP BY C.first_name,C.last_name,I.total


--Q9. Find the customers who haven't yet placed an order. 


SELECT c.first_name,c.last_name,i.invoice_id
FROM customer c 
join invoice i on c.customer_id = i.customer_id
where i.invoice_id IS NULL

-- So all customers have placed orders. 
 


-- Q. FIND THE 3RD INVOICE ID OF EACH COUNTRY. RETURN THE BILLING ADDRESS,CITY,STATE,COUNTRY ,TOTAL AND POSTAL CODE. 

WITH THIRD_INVOICE AS (
SELECT billing_address,billing_city,billing_country,billing_state,billing_postal_code,total,
DENSE_RANK() OVER(PARTITION BY BILLING_COUNTRY ORDER BY INVOICE_DATE) AS RANK_OF_INVOICE
FROM invoice)

SELECT billing_address,billing_city,billing_country,billing_state,billing_postal_code
FROM THIRD_INVOICE
WHERE RANK_OF_INVOICE = 3




--Q. FIND THE PERCENTAGE OF CUSTOMERS WHO ARE FROM THE UNITED STATES. RETURN THE PERCENTAGE OF PEOPLE IN THE USA. ROUND THE 
-- VALUE TO 1 DECIMAL. 


WITH US_CUSTOMERS AS (
	SELECT COUNT(COUNTRY) AS CUSTOMER_COUNT
	FROM customer
	WHERE COUNTRY = 'USA'
	GROUP BY FIRST_NAME,COUNTRY)

SELECT ROUND(100.0 * CUSTOMER_COUNT/(SELECT COUNT(*) FROM CUSTOMER),1) AS PERCENTAGE_COUNT
FROM US_CUSTOMERS


-- Q . WRITE A QUERY TO FIND THE PERCENTAGE OF CUSTOMERS WHO LIVE IN CANADA

WITH CUSTOMER_PERCENT AS (
	SELECT COUNT(COUNTRY) AS COUNTRY_COUNT
	FROM CUSTOMER 
	WHERE COUNTRY = 'CANADA')

SELECT ROUND(100* COUNTRY_COUNT/(SELECT COUNT(*) FROM CUSTOMER),1) AS PERCENTAGE_FROM_CANADA
FROM CUSTOMER_PERCENT



-- Q. FIND THE 3-DAY ROLLING AVERAGE FOR INVOICES FOR EACH CUSTOMER. RETURN THE CUSTOMER NAME,INVOICE_DATE, ROLLING AVG ROUNDED TO 2 DECIMAL PLACES. 

SELECT I.invoice_date,C.first_name,C.last_name,
	ROUND(AVG(I.TOTAL) 
	OVER(PARTITION BY C.first_name 
		 ORDER BY I.INVOICE_DATE
		 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS ROLLING_AVG
FROM INVOICE AS I
JOIN customer AS C ON
I.customer_id = C.customer_id



-- Q1. Find how much amount spent by each customer on artists? Write a query to return the customer name,artist name and the total spent.



WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	OFFSET 0 ROWS
	FETCH FIRST 1 ROW ONLY
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. 
	   We determine the most popular genre as the genre with the highest amount of purchases. 
	   Write a query that returns each country along with the top Genre. For countries where 
	   the maximum number of purchases is shared return all Genres. */

/* We would need the Customer,invoice,invoice_line,track,genre table for this query. 
   Country can be found in customers table. No of purchases can be done using invoice_line table(unit+quantity). genre name can be found
   in the genre table.  */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	order by 2 
)

SELECT * 
FROM popular_genre 
WHERE RowNo <= 1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */



WITH Customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)

SELECT * FROM Customer_with_country WHERE RowNo <= 1



-- Q4. Find the top 3 artists who have been listened to the most FOR EACH CUSTOMER in the USA. Return the customer's name 
--	   who have listened to the TOP 3 artist name and the rank.

with top_ranks as (
	   SELECT DISTINCT C.FIRST_NAME AS FIRST_NAME ,C.LAST_NAME AS LAST_NAME ,A1.NAME AS ARTIST_NAME ,C.COUNTRY AS COUNTRY,
	   DENSE_RANK() OVER(PARTITION BY C.FIRST_NAME ORDER BY A1.NAME ASC) AS ARTIST_RANK
	   FROM TRACK T 
       JOIN ALBUM A ON T.album_id = A.album_id
       JOIN artist A1 ON A.artist_id = A1.artist_id
       JOIN invoice_line I1 ON T.track_id = I1.track_id
       JOIN invoice I2 ON I1.invoice_id = I2.invoice_id
       JOIN customer C ON I2.customer_id = C.customer_id
       WHERE C.country LIKE 'USA')


SELECT FIRST_NAME,LAST_NAME,ARTIST_NAME,COUNTRY,ARTIST_RANK
FROM top_ranks
WHERE ARTIST_RANK <=3



-- Q 5 . Find the first invoices of all the customers. Now find top 3 customers has the highest total on invoice orders. 
--Return all the details of the first invoices.  


with Ranking as (
	select c.first_name,c.last_name,c.company,i.billing_address,i.billing_city,i.billing_state,i.billing_country,
	i.total,i.invoice_id,i.invoice_date,
	dense_rank() over(partition by first_name order by invoice_date asc) as Ranks
	from invoice i 
	left join customer c on
	i.customer_id = c.customer_id
	)

select *
from Ranking
where Ranks = 1
order by total desc
offset 0 rows fetch first 3 rows only


-- Q6. Find the top 2 customers that have sent the most invoices in the month of August to september 2020. If there is a tie between
-- the customers, order it by the first name in ascending order 


WITH MOST_INVOICES AS (
	SELECT C.first_name,C.last_name,I.billing_country,I.invoice_date,I.total,
	dense_RANK() OVER (ORDER BY I.TOTAL DESC) AS RANKING
	FROM INVOICE AS I 
	LEFT JOIN CUSTOMER AS C ON 
	I.CUSTOMER_ID = C.CUSTOMER_ID
	WHERE I.invoice_date BETWEEN '2020-08-01' AND '2020-09-30'
	)

SELECT first_name,last_name,billing_country,invoice_date,total,RANKING
FROM MOST_INVOICES
where RANKING <= 2
ORDER BY TOTAL desc,first_name



-- Q 7. Find all the invoices of customers that have been made in the month of August. Return the customer full name,invoice total,
--		billing country and invoice date. 

SELECT C.first_name,C.last_name,I.billing_country,I.invoice_date,I.total
	FROM INVOICE AS I 
	LEFT JOIN CUSTOMER AS C ON 
	I.CUSTOMER_ID = C.CUSTOMER_ID
	where datepart(month, invoice_date) = '8' and datepart(year, invoice_date) in (2017,2018,2019,2020)


-- Q8. We want to find the best songs of each composer. The best song is defined by the duration of the song and the size of the 
--  song. Write a query to find the top 3 songs of each composer. Order it by highest duration and song size. 
-- Note : Do not include null composers.


with songs_ranks as (
select name,composer,milliseconds,bytes,
row_number() over(partition by composer order by milliseconds desc,bytes desc) as Rank_of_Songs
from track
where composer <> 'NULL'
)

select name,composer,milliseconds,bytes,Rank_of_Songs
from songs_ranks
where Rank_of_Songs <= 3
order by composer asc,milliseconds desc,bytes desc


--Q Find the employee's choice of preference when it comes to their style of Genre. Return their full name and genre.

select distinct(e.first_name+' '+e.last_name) as 'Full name',g.name
from employee as e
inner join customer as c on
e.employee_id = c.customer_id
inner join invoice as i1 on
c.customer_id = i1.customer_id
inner join invoice_line as i2 on
i1.invoice_id = i2.invoice_id
inner join track as t on 
i2.track_id = t.track_id
inner join genre as g on
t.genre_id = g.genre_id
group by e.first_name,e.last_name,g.name 


--Q. Find the artists who have produced the most albums and return the count of those albums for each artist. 

select a1.name , count(a2.artist_id) as 'No of albums'
from artist as a1
inner join album as a2 on
a1.artist_id = a2.artist_id
group by a1.name 
order by 'No of albums' desc


--Q Write a query to find the age of all the Managers. Return the name and their age followed by designation.


select (first_name+' '+last_name) as 'Fullname',birthdate,
DATEDIFF(yy,birthdate,GETDATE()) +
(case when DATEPART(month,GETDATE()) - DATEPART(year,GETDATE()) < 0 then -1 else 0 end) as 'Age',
title
from employee
where title like '%Manager%';








select *
from album

select *
from artist 

select *
from employee


SELECT *
FROM customer

select *
from playlist 

SELECT *
FROM TRACK

select *
from employee

SELECT *
FROM GENRE


SELECT *
FROM media_type


SELECT *
FROM invoice

select *
from invoice_line







