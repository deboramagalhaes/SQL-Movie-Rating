-- Q1 Find the names of all reviewers who rated Gone with the Wind.

select distinct name
from Rating R1
left join Reviewer R2
	 on R1.rID = R2.rID
where mID = (	select mID
				from Movie
				where title = 'Gone with the Wind')

-- Q2 For any rating where the reviewer is the same as the director of the movie, 
-- return the reviewer name, movie title, and number of stars.

select name 'reviewer name', title, stars
from Rating R1
left join Reviewer R2
	on R1.rID = R2.rID
left join Movie M
	on R1.mID = M.mID
where name = director

-- Q3 Return all reviewer names and movie names together in a single list, alphabetized. 

select cast(name as varchar(50))
from Reviewer 
union
select cast(title as varchar(50))
from Movie
order by cast(name as varchar(50))

-- Q4 Find the titles of all movies not reviewed by Chris Jackson.

select title
from Movie
where mID not in 
(	select mID -- this query finds all mIDs for movies rated by Chris Jackson, that guarantees that we are not going to consider a movie rated by him, even if it was rated by other reviewer
	from Rating
	where rID = (	select rID -- this query finds Chris Jackson's rID
					from Reviewer
					where name = 'Chris Jackson'))

-- Q5 For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
-- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once.

select Re1.name, Re2.name
from (	select distinct Ra1.rID 'ID1', Ra2.rID 'ID2' -- this query gathers, in tuples, the reviewers who rated the same movies
		 from Rating Ra1, Rating Ra2
		 where  Ra1.mID = Ra2.mID
				and Ra1.rID < Ra2.rID
		) Aux
left join Reviewer Re1
	on Aux.ID1 = Re1.rID
left join Reviewer Re2
	on Aux.ID2 = Re2.rID

-- Q6 For each rating that is the lowest (fewest stars) currently in the database,
-- return the reviewer name, movie title, and number of stars.

select name 'reviewer name', title, stars
from Rating R1
left join Movie M
	on R1.mID = M.mID
left join Reviewer R2
	on R1.rID = R2.rID
where stars in (	select min(stars)
					from Rating)

-- Q7 List movie titles and average ratings, from highest-rated to lowest-rated. 
-- If two or more movies have the same average rating, list them in alphabetical order.

select title, avg(stars) as 'avg ratings'
from Rating R1
left join Movie M
	on R1.mID = M.mID
group by title
order by avg(stars) desc, title

-- Q8 Find the names of all reviewers who have contributed three or more ratings

select name
from Reviewer
where rID in (	select rID
				from Rating
				group by rID
				having count(rID) >= 3) 

-- Q9 Some directors directed more than one movie. For all such directors, 
-- return the titles of all movies directed by them, along with the director name. 
-- Sort by director name, then movie title.

select title, Movie.director
from Movie
left join (
			select director
			from (	select director, count(director) 'count_directed_movies' -- this subquery lists all directors who directed more than one movie
					from Movie
					group by director
					having count(director) > 1) as Aux1) as Aux2
	on Movie.director = Aux2.director
where Movie.director in (select Aux2.director) -- with this condition we select only directors who directed more than one movie
order by Movie.director, title

-- Q10 Find the movie(s) with the highest average rating. 
-- Return the movie title(s) and average rating.

select title, avg(stars) avg_rating
from Rating R
left join Movie M
	on R.mID = M.mID
group by title
having avg(stars) = (	 select max(avg_rating) 
						 from (select mID, avg(stars) avg_rating
								from Rating
								group by mID) Aux)

-- Q11 Find the movie(s) with the lowest average rating. 
-- Return the movie title(s) and average rating.

select title, avg(stars) avg_rating
from Rating R
left join Movie M
	on R.mID = M.mID
group by title
having avg(stars) = (	 select min(avg_rating)
						 from (select mID, avg(stars) avg_rating
								from Rating
								group by mID) Aux)

-- Q12 For each director, return the director's name together with the title(s) of the movie(s) 
-- they directed that received the highest rating among all of their movies, and the value of that rating. 

select Aux1.Director, Aux1.Title, max_rating_per_title as [Director's highest rating]
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
order by [Director's highest rating] desc