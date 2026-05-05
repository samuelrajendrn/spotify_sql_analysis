-- ==========================================
-- SQL Data Analysis -- Spotify Dataset
-- ==========================================


-- ==========================================
-- Create Table
-- ==========================================

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- ==========================================
-- Exploratory Data Analysis
-- ==========================================

-- 1.Total number of records

select count(*) from spotify;

-- 2.Number of unique artists

select count(distinct artist) from spotify;

-- 3.Album Types

select distinct album_type from spotify;

-- 4.Distribution Channels

select distinct channel from spotify;

-- 5.Most played on platform

select distinct most_played_on from spotify;

-- 6.Invalid Track Records

select * from spotify where duration_min = 0;

delete from spotify where duration_min = 0;

-- 7.Longest track duration

select max(duration_min) from spotify;

-- 8.Shortest Track Duration

select min(duration_min) from spotify;


-- ==========================================
-- Data Analysis
-- ==========================================

-- ------------------------------------------
-- I. Dataset Overview & Exploration
-- ------------------------------------------

-- 1. List of all albums with their respective aritsts

select distinct album,artist from spotify;

-- 2. Count of total tracks by each artist

select artist , count(*) as total_tracks from spotify
group by artist;

-- 3. Find all tracks that belong to album type 'single'

select track from spotify where album_type='single';

-- 4. Artist with most albums

select artist, count(distinct album) as total_albums from spotify 
group by artist order by total_albums desc;

-- ------------------------------------------
-- II. Engagement & Popularity Analysis
-- ------------------------------------------

-- 5. Tracks with more than one billion streams

select distinct track from spotify where stream>1000000000;

-- 6. Total number for comments for licensed tracks

select sum(comments) as total_comments from spotify where licensed='TRUE'; 

-- 7. Tracks with views and likes where official_video = TRUE

select track,artist,views,likes from spotify where official_video='TRUE';

-- 8. Total views per album

select album,sum(views) as total_views from spotify 
group by album order by total_views desc;

-- 9. Top 10 most liked tracks

select track,
string_agg(artist,', ') as artists,
max(likes) as likes
from spotify 
group by track
order by likes desc limit 10;

-- ------------------------------------------
-- III. Platform Comparison (Spotify v YouTube)
-- ------------------------------------------

-- 10. Tracks streamed more on Spotify than YouTube

select track,artist,stream,views from spotify where most_played_on='Spotify';

-- 11. Tracks performing well on both platforms

select track,
string_agg(distinct artist,', ') as artists,
max(stream) as stream,
max(views) as views 
from spotify where stream>500000000 and views>500000000
group by track
order by stream desc;

-- ------------------------------------------
-- IV. Audio Feature Analysis
-- ------------------------------------------

-- 12. Average danceability of tracks per album

select album, avg(danceability) as avg_danceability from spotify
group by album order by avg_danceability desc;

-- 13. Top 5 tracks with highest energy values

select track, avg(energy) as avg_energy from spotify 
group by track order by avg_energy desc limit 5;

-- 14. Tracks with liveness score above average value

select * from spotify
where liveness > (select avg(liveness) from spotify);

-- ------------------------------------------
-- V. Advanced SQL Techniques
-- ------------------------------------------

-- 15. The top 3 most viewed tracks for each artist using window function

with ranking_artist
as
(select artist, track, 
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1,2
order by 1,3 desc)
select * from ranking_artist where rank<=3;

-- 16. Energy difference per album using with clause

with cte
as
(select album,
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1)
select album, highest_energy-lowest_energy as energy_diff 
from cte order by 2 desc;