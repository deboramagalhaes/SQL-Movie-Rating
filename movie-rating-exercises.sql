-- Context: You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 
-- There's not much data yet, but you can still try out some interesting queries. Here's the schema:
--Movie		( mID, title, year, director ) -->  There is a movie with ID number mID, a title, a release year, and a director.
-- Reviewer	( rID, name )					--> The reviewer with ID number rID has a certain name.
-- Rating	( rID, mID, stars, ratingDate ) --> The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.

-- 1 Some reviewers didn't provide a date with their rating. 
-- Find the names of all reviewers who have ratings with a NULL value for the date.

select name
from Rating R1
left join Reviewer R2
	on R1.rID = R2.rID
where ratingDate is null

-- 2 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
-- return the reviewer's name and the title of the movie.

select name, title
from (	-- this query pairs each tuple in R1 with each tuple in R2, to check wether the same reviewer rated the same movie twice 
		select R1.rID, R1.mID
		from Rating R1, Rating R2 
		where	R1.rid = R2.rid 
				and R1.mID = R2.mID -- the conditions find the tuple(s) where the reviewers and movie are the same, and the latest rating is higer
				and R1.ratingDate < R2.ratingDate
				and R1.stars < R2.stars
		) as Aux
left join Reviewer R -- necessary to provide reviewer name
	on Aux.rID = R.rID
left join Movie M -- necessary to provide movie title
	on Aux.mID = M.mID

-- 3 Find the difference between the average rating of movies released before 1980 
-- and the average rating of movies released after 1980 

select 
(
	select avg([avg rating])
	from ( -- creating an auxiliar table with avg stars for movies released before 1980
		select title, avg(stars) as 'avg rating', year
		from Rating R
		left join Movie M
			on R.mID = M.mID
		where year < 1980
		group by title, year) as Aux
) - 
(
	select avg([avg rating])
	from ( -- creating an auxiliar table with avg stars for movies released after 1980
		select title, avg(stars) as 'avg rating', year
		from Rating R
		left join Movie M
			on R.mID = M.mID
		where year > 1980
		group by title, year) as Aux
) as 'Average rating difference'

