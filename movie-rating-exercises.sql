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

-- 2 Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.

delete from Rating
where mID in (	select Movie.mID
		from Rating, Movie
		where	(Movie.year < 1970 or Movie.year > 2000)) and stars < 4

-- 3 Find the titles of all movies not reviewed by Chris Jackson.

select title
from Movie
where mID not in 
(	-- this query finds all mIDs for movies rated by Chris Jackson, that guarantees that we are not going to consider a movie rated by him, even if it was rated by other reviewer
	select mID 
	from Rating
	where rID = (	-- this query finds Chris Jackson's rID
			select rID 
			from Reviewer
			where name = 'Chris Jackson'))

-- 4 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
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

-- 5 Find the difference between the average rating of movies released before 1980 
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


-- 6 For each director, return the director's name together with the title(s) of the movie(s) 
-- they directed that received the highest rating among all of their movies, and the value of that rating. 

select Aux1.Director, Aux1.Title, max_rating_per_title as [Directors highest rating]
from	(	-- first, as we may have more than one rating per title, lets find out the highest rating for each title
			-- note that, as some directors have directed more than one movie, we'll have repeated director's name in this auxiliar table
			select	director, 
				title, 
				max(stars) 'max_rating_per_title' 
			from Movie M, Rating R
			where M.mID = R.mID
				and director is not null
			group by director, title) Aux1
left join	(	-- then, in this query we select only the best rated movie of each director
				select  director,
					max(stars) 'max_rating_per_director' 
				from Movie M, Rating R
				where M.mID = R.mID
					and director is not null
				group by director) Aux2
	on Aux1.director = Aux2.director
where Aux1.max_rating_per_title = Aux2.max_rating_per_director -- and finally, with this condition we select only a director's best rated movie
order by [Directors highest rating] desc

