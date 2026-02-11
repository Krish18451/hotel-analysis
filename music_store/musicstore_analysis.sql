--Q1: Who is the senior most employee on the basis of job title?
select * from employee
order by levels desc
limit 1;

--Q2: Which country have the most invoices?
select count(*) as c,billing_country 
from invoice
group by billing_country
order by c desc;

--Q3:What are top 3 values of total invoics?
select total from invoice
order by total desc
limit 3;

--Q4: Which city has the best customers?We would like to throw a promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals.
select sum(total) as invoice_total,billing_city from invoice
group by billing_city
order by invoice_total desc
limit 1 ;

--Q5: Who is the best customer?The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.

select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as
total from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

--Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
--Return your list ordered alphabetically by email starting with A.

select distinct first_name,last_name,email
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
      select track_id from track
	  join genre on track.genre_id=genre.genre_id
	  where genre.name like 'Rock'
)
order by email;

--Q7: Let’s invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands.
select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Q8: Return all the track names that have a song length longer than the average song length.
--Return the Name and milliseconds of each track.
--Order by the song length with the longest first.
select name,milliseconds
from track
where milliseconds>(
        select avg(milliseconds) as avg_track_length
        from track)
order by milliseconds desc;

--Q9:Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent.
WITH best_selling_artist AS (
    SELECT 
        ar.artist_id,
        ar.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album al ON al.album_id = t.album_id
    JOIN artist ar ON ar.artist_id = al.artist_id
    GROUP BY ar.artist_id, ar.name
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

--Q10:We want to find out the most popular music Genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is shared return all Genres.
WITH genre_purchases AS (
    SELECT
        c.country,
        g.name AS genre,
        COUNT(il.invoice_line_id) AS purchase_count
    FROM customer c
    JOIN invoice i ON i.customer_id = c.customer_id
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name
),

ranked_genres AS (
    SELECT
        country,
        genre,
        purchase_count,
        RANK() OVER (
            PARTITION BY country
            ORDER BY purchase_count DESC
        ) AS rank_in_country
    FROM genre_purchases
)

SELECT
    country,
    genre,
    purchase_count
FROM ranked_genres
WHERE rank_in_country = 1
ORDER BY country;

