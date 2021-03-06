create table matches(id int,city varchar,date date,player_of_match varchar,venue varchar,neutral_venue int,team1 varchar,team2 varchar,
					toss_winner varchar,toss_decision varchar,winner varchar,result varchar,result_margin int,eliminator varchar,
					method varchar,umpire1 varchar,umpire2 varchar)
copy matches from 'C:\Program Files\PostgreSQL\13\data\IPL_matches.csv' csv header
create table deliveries(id int,inning int,over int, ball int,batsman varchar,non_striker varchar,bowler varchar,batsman_runs int,
					   extra_runs int,total_runs int,is_wicket int,dismissal_kind varchar,player_dismissed varchar,fielder varchar,
					   extras_type varchar,batting_team varchar,bowling_team varchar)
copy deliveries from 'C:\Program Files\PostgreSQL\13\data\IPL_Ball.csv' csv header
select * from deliveries limit 20 --1
select * from matches limit 20 --2
select * from matches where date='2013-05-02'--3
select * from matches where result='runs' and result_margin>100--4
select * from matches where result='tie' order by date desc--5
select  distinct city as All_IPL_hosts from matches order by city--6
create table deliveries_v02 as select *,case --5
when total_runs>=4 then 'Boundary'
when total_runs=0 then 'Dot'
else 'Other'
end as ball_result from deliveries 
select * from deliveries_v02
select count(ball_result) as Total_Boundaries_and_dot_balls from deliveries_v02 where ball_result in('Dot')
select count(ball_result) as Total_Boundaries_and_dot_balls from deliveries_v02 where ball_result in('Boundary','Dot')
select batting_team ,count(ball_result) as Boundaries_scored from deliveries_v02 where ball_result ='Boundary' and inning in (1,2) group by batting_team
select bowling_team ,count(ball_result) as dot_balls_bowled from deliveries_v02 where ball_result ='Dot' and inning in (1,2) group by bowling_team
select dismissal_kind,count(is_wicket) as wickets from deliveries_v02 where is_wicket=1 group by dismissal_kind
select bowler,sum(extra_runs) as total_extras from deliveries_v02 group by bowler order by sum(extra_runs) desc limit 5
create table deliveries_v03 as select deliveries_v02.*,matches.venue,matches.date from deliveries_v02 left join matches on deliveries_v02 .id=matches.id
select * from deliveries_v03
select distinct venue,sum(total_runs) as total_runs from deliveries_v03 group by venue order by sum(total_runs) desc
select extract(year from date) as year,venue,sum(total_runs) as total_runs from deliveries_v03 where venue='Eden Gardens' group by year,venue order by total_runs desc
select distinct team1 from matches
create table deliveries_v04 as select id||'-'||inning||'-'||over||'-'||ball as ball_id,deliveries_v03.* from deliveries_v03
select * from deliveries_v04
select count(distinct ball_id) from deliveries_v04
create table deliveries_v05 as select deliveries_v04.*, row_number() over (partition by ball_id) as r_num from deliveries_v04
select * from deliveries_v05
select * from deliveries_v05 WHERE r_num=2
SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2)
create table matches_corrected as select *, replace(team1, 'Rising Pune Supergiants', 'Rising Pune
Supergiant') as team1_corr
, replace(team2, 'Rising Pune Supergiants', 'Rising Pune Supergiant') as team2_corr from matches;
select distinct team1_corr from matches_corrected;
select distinct team2_corr from matches_corrected;