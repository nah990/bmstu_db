-- Скалярная функция возвращают одно значение типа данных, заданного в предложении RETURNS. 

-- Подсчет игроков данной страны
CREATE OR REPLACE FUNCTION get_country_count(country VARCHAR)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
   country_count INTEGER;
BEGIN
   SELECT COUNT(*) 
   INTO country_count
   FROM players_results
   WHERE players_results.player_country = country;
   
   RETURN country_count;
END;
$$;
--
select get_country_count('France')

-- Подставляемая табличная функция возвращает заранее непредопределённую таблицу.

-- Возвращает количество строк указанной таблицы
CREATE OR REPLACE FUNCTION get_content_of(_type anyelement, amount INTEGER)
    RETURNS SETOF anyelement
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY 
        EXECUTE format('
            SELECT *
            FROM %s
            LIMIT $1',
        pg_typeof(_type))
        USING amount;
END;
$$;

-- Многооператорная табличная функция - функция, состоящая из нескольких инструкций.

CREATE OR REPLACE FUNCTION get_player_kills() 
	RETURNS TABLE (player_id INTEGER, kills_diff INTEGER, kills_min INTEGER, kills_max INTEGER)
	LANGUAGE plpgsql
AS 
$$
DECLARE
   kills_avg INTEGER;
   kills_min INTEGER;
   kills_max INTEGER;
BEGIN 
    SELECT AVG(player_kills::INTEGER)
    INTO kills_avg
    FROM players_results; 

    SELECT MIN(player_kills::INTEGER)
    INTO kills_min
    FROM players_results; 

    SELECT MAX(player_kills::INTEGER)
    INTO kills_max
    FROM players_results; 

    RETURN query 
		SELECT players_results.player_id, players_results.player_kills::INTEGER - kills_avg AS kills_diff, kills_min, kills_max
		FROM players_results;
END;
$$;
select get_player_kills()

--Рекурсивную функцию или функцию с рекурсивным ОТВ

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

-- Хранимая процедура без параметров или с параметрами
CREATE OR REPLACE PROCEDURE delete_player_by_team(team VARCHAR)  
    LANGUAGE plpgsql
AS 
$$
BEGIN 
    DELETE FROM players_results ps
    WHERE ps.player_team = team;
END;
$$;
-- CALL delete_player_by_team('NiP');

--Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ

CREATE OR REPLACE PROCEDURE proccc(need_id INTEGER)
LANGUAGE plpgsql
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS rec_buffer(
        id1 integer,
        id2 integer,
        level integer
    );
    WITH RECURSIVE know_each_other (id1, id2, level) as (
        select p.id1, p.id2, 0 as level
        from play_with as p
        where p.id1 = need_id
        UNION all
        select t1.id1, t2.id2, t1.level + 1
        from know_each_other t1
        join play_with t2 
        on t1.id2 = t2.id1 AND t1.level < 3
    ),
    play_with (id1, id2, match_id) as (
        select a.account_id, b.account_id, a.match_id
        from players a join players b
        on a.match_id = b.match_id
        where a.account_id <> 0
        and b.account_id <> 0
        and a.account_id <> b.account_id
    ) INSERT INTO rec_buffer
     SELECT DISTINCT * FROM know_each_other;
END;
$$;
 CALL proccc(3)

-- Хранимая процедура с курсором; 
-- курсоры являются расширением результирующих наборов

CREATE OR REPLACE PROCEDURE curs_player()  
    LANGUAGE plpgsql
AS 
$$
DECLARE 
    curs CURSOR FOR SELECT player_id, player_team FROM players_results;
    p_id INTEGER;
    pt VARCHAR;
BEGIN 
    CREATE TABLE IF NOT EXISTS player_buffer(
        player_id INTEGER, 
        player_team VARCHAR
    );
    OPEN curs;
    FOR counter IN 1..5 LOOP
        FETCH curs INTO p_id, pt;
        INSERT INTO player_buffer
        VALUES (p_id, pt);
    END LOOP;
END;
$$;
call curs_player();
select * from player_buffer

-- Хранимая процедура доступа к метаданным 
-- Информация о всех функциях и процедурах базы данных
CREATE OR REPLACE PROCEDURE get_udf()
    LANGUAGE plpgsql
AS
$$
BEGIN
    CREATE TABLE IF NOT EXISTS udf_list(
        schm VARCHAR,
        nm VARCHAR,
        lang VARCHAR,
        args VARCHAR,
        return_type VARCHAR
    );

    DELETE FROM udf_list;

    INSERT INTO udf_list
        SELECT  ns.nspname "schema",
                p.proname "name",
                lg.lanname lang,
                pg_get_function_arguments(p.oid) as args,
                t.typname as return_type
        FROM pg_proc p
            LEFT JOIN pg_namespace ns on p.pronamespace = ns.oid
            LEFT JOIN pg_language lg on p.prolang = lg.oid
            LEFT JOIN pg_type t on t.oid = p.prorettype 
        WHERE ns.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY "schema", "name";
END;
$$;

call udf_list();

--Триггер AFTER

CREATE OR REPLACE FUNCTION player_kills_upd()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF NEW.players_kills <> OLD.players_kills THEN
        update players_results
        set players_results.players_kills = players_results.players_kills - OLD.players_kills + NEW.players_kills
        where NEW.match_id = players_results.match_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER kills_changes
    AFTER UPDATE
    ON players_results
    FOR EACH ROW
    EXECUTE PROCEDURE player_kills_upd();

--Триггер Insted of 

CREATE TABLE new_team (
   player_id INTEGER,
   player_team VARCHAR
);

CREATE OR REPLACE FUNCTION safe_delete()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    INSERT INTO new_team(player_id, player_team)
    VALUES(NEW.player_id, NEW.player_team);
    RETURN OLD;
END;
$$;

CREATE TRIGGER team_insert
    BEFORE DELETE
    ON player_id
    FOR EACH ROW
    EXECUTE PROCEDURE safe_delete();