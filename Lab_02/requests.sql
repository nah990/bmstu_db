--Инструкция SELECT, использующая предикат сравнения.

SELECT * FROM players_results
WHERE player_kills > 45
ORDER BY player_kills DESC

--Инструкция SELECT, использующая предикат BETWEEN.

SELECT * FROM players_results
WHERE player_kills BETWEEN 45 AND 50
ORDER BY player_kills DESC

--Инструкция SELECT, использующая предикат LIKE.

SELECT * FROM players_results
WHERE player_country LIKE '%land%'

--Инструкция SELECT, использующая предикат IN с вложенным подзапросом.

SELECT * FROM players_results
WHERE player_country IN 
(
SELECT DISTINCT player_country
FROM players_results
WHERE player_country LIKE '%land%') AND player_deaths < 10

--Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.

SELECT DISTINCT team_1
FROM matches AS m
WHERE EXISTS
(
SELECT DISTINCT match_id
FROM matches
WHERE team_1 = m.team_1 AND team_2 = 'AGO') 

--Инструкция SELECT, использующая предикат сравнения с квантором.

SELECT player_name,player_team,player_kills FROM players_results
WHERE player_kills > ALL
(
	SELECT player_kills FROM players_results
	WHERE player_team = 'FaZe'
)

--Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.

Select player_name, match_id, player_kills
FROM players_results
WHERE player_kills < ALL
(
SELECT MIN(player_kills)
FROM players_results
WHERE  player_team = 'G2' )

--Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.

SELECT player_name, 
(SELECT AVG(player_kills)
 FROM players_results
 WHERE P.player_name = players_results.player_name
) AS AVG_KILLS
FROM players_results as P
LIMIT 100

--Инструкция SELECT, использующая поисковое выражение CASE.

SELECT player_name, player_kills, player_deaths,
	CASE

		WHEN player_kills < player_deaths THEN 'KDA < 1'
		WHEN player_kills > player_deaths THEN 'KDA > 1'
		ELSE 'KDA equal 1'
	END AS player_KDA
FROM players_results

--TODO CASE simple

select decider_map,
	case decider_map
		when 'Mirage' then 'Eto Mirage'
		else 'Eto ne Mirage'
	end as Mirage_li
from matches

--Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT. 

SELECT player_name, 
(SELECT AVG(player_kills)
 FROM players_results
 WHERE P.player_name = players_results.player_name
) AS AVG_KILLS
INTO TEMP temp_table
FROM players_results as P
LIMIT 100

--Инструкция SELECT, использующая вложенные коррелированные
select *
from players_results p
join matches m1
on p.match_id = m1.match_id
where p.player_kills > (
	select avg(pr.player_kills)
	from players_results pr
	join matches m
	on pr.match_id = m.match_id
	where m.decider_map = m1.decider_map
	group by m.decider_map
)
LIMIT 10

--Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
select player_name, player_team, player_kills, player_deaths, match_date
from players_results
where player_kills > (
	select AVG(player_kills)
	from players_results
	where player_deaths < (
		select AVG(player_deaths)
		from players_results
		where player_assists >(
			select AVG(player_assists)
			from players_results
			where match_date > '2020-01-01'
		)
	)
)
order by player_kills desc

--Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.

select  ps.player_name,
		AVG(player_kills) as AvgKills,
		MIN(player_kills) as MinKills
from players_results ps left outer join maps_results mr
on mr.map_result_id = ps.map_result_id
where mr.map_name = 'Mirage'
group by ps.player_name

--Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
--TODO разница where и having. Разный приоритет, в having можно использовать агрегатную функцию.Where сначала выбирает строки, затем группирует. Having
--Основное отличие WHERE от HAVING заключается в том, что WHERE сначала выбирает строки, а затем группирует их и вычисляет агрегатные функции
--(таким образом, она отбирает строки для вычисления агрегатов), тогда как HAVING отбирает строки групп после группировки и вычисления агрегатных функций.
select  ps.player_name,
		AVG(ps.player_kills) as AvgKills,
		MIN(ps.player_kills) as MinKills
from players_results ps left outer join maps_results mr
on mr.map_result_id = ps.map_result_id
where mr.map_name = 'Mirage'
group by ps.player_name
having AVG(ps.player_kills) >(
	select AVG(ps2.player_kills)
	from players_results ps2 left outer join maps_results mr2
	on mr2.map_result_id = ps2.map_result_id
	where mr2.map_name = 'Nuke'
)

--Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.

select team_1, team_2, map_name
into temp_maps_results
from maps_results

insert into temp_maps_results(team_1, team_2, map_name)
values ('Test Team_1', 'Test Team_2', 'Test map_name')

select * from
temp_maps_results
where team_1 = 'Test Team_1'

--Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.

select map_result_id, team_1, team_2, map_name
into temp_maps_results_2
from maps_results;

insert into temp_maps_results_2(map_result_id, team_1, team_2, map_name)
select(
select max(map_result_id) + 1
from maps_results),'Test Team_1', 'Test Team_2', 'Test map_name'

--Простая инструкция UPDATE.

update temp_maps_results_2
set team_1 = 'Test Team_1 updated!'
where team_1 = 'Test Team_1'

--Инструкция UPDATE со скалярным подзапросом в предложении SET

select *
into temp_players_results
from players_results;

update temp_players_results
set player_kills = (
select AVG(player_kills)
from temp_players_results
where player_team = 'G2')
where player_team = 'G2'

--Простая инструкция DELETE
delete from temp_players_results
where player_team = 'G2'

--Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.

select *
into temp_players_results_2
from players_results;

select *
into temp_matches
from matches;

delete from temp_players_results_2 p1
where p1.match_id in
(
	select p2.match_id
	from temp_players_results_2 p2
	join temp_matches m1
	on m1.match_id = p2.match_id
	where m1.decider_map = 'Mirage'
)

--Инструкция SELECT, использующая простое обобщенное табличное выражение

with CTE(player_id, player_kills) as
(
	select player_id, count(player_kills)
	from temp_players_results_2
	where player_kills > 10
	group by player_id
)
select * from CTE

--Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--TODO оконные функции не уменьшают количество строк
select distinct player_team,
	avg(player_kills)over(partition by player_team) avg_kills,
	avg(player_deaths)over(partition by player_team) avg_deaths,
	avg(player_assists)over(partition by player_team) avg_assists
from temp_players_results_2
order by avg_kills desc

--Оконные фнкции для устранения дублей


insert into temp_players_results_2(player_result_id, match_id, match_date, player_name, player_team,
								player_team_against, player_country, player_id, 
								player_kills, player_assists, player_deaths, map_result_id)
select(select max(player_result_id) + 1
	  from temp_players_results_2),'12222','2020-02-24','Duplicate_name','Duplicate_team','Duplicate_team_against',
	  'Duplicate_player_country', '888','10','20','30','21'

delete from temp_players_results_2
where match_id in
(
	select match_id
	from (
		select match_id, row_number() over(partition by match_id) n
		from temp_players_results_2) as mm where match_id = '12222'
)
--TODO
--Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.

WITH RECURSIVE know_each_other (id1, id2, level) as (
    select id1, id2, 0 as level
    from play_with
    where id1 = 29
    UNION all
    select t1.id1, t2.id2, level + 1
    from know_each_other t1
    join play_with t2 
    on t1.id2 = t2.id1 AND level < 1
),
play_with (id1, id2) as (
    select distinct a.player_id, b.player_id
    from players_results a join players_results b
    on a.match_id = b.match_id
    where a.player_id <> 0
    and b.player_id <> 0
    and a.player_id <> b.player_id
)
select DISTINCT *
from know_each_other
