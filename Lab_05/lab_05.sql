-- 1. Извлечение данных из таблицы "Players_results"

COPY (
	SELECT row_to_json(player_data) 
    FROM (
        SELECT *
        FROM players_results
    ) player_data 
) TO 'C:/Labs/Database_Labs/bmstu_db/Lab_05/players.json';

-- 2. Создание таблицы из "players.json" файла

CREATE OR REPLACE PROCEDURE table_based_on_json()  
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS players_based_json (
        player_result_id INTEGER,
        match_id INTEGER,
        match_date DATE,
        player_name VARCHAR,
        player_team VARCHAR,
        player_team_against VARCHAR,
        player_country VARCHAR,
        player_id INTEGER,
        player_kills INTEGER,
        player_assists INTEGER,
        player_deaths INTEGER,
        map_result_id INTEGER,
        PRIMARY KEY (player_result_id)
    );

    DELETE FROM players_based_json;

    CREATE TABLE IF NOT EXISTS players_json_tmp ( 
        players_info jsonb 
    );

    DELETE FROM players_json_tmp;

    COPY players_json_tmp 
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/players.json';

    INSERT INTO players_based_json(player_result_id,
        match_id,
        match_date,
        player_name,
        player_team,
        player_team_against,
        player_country,
        player_id,
        player_kills,
        player_assists,
        player_deaths,
        map_result_id)
        SELECT (players_info -> 'player_result_id')::INTEGER AS player_result_id,
            (players_info ->> 'match_id')::INTEGER AS match_id,
            (players_info ->> 'match_date')::DATE AS match_date,
            (players_info ->> 'player_name') AS player_name,
            (players_info ->> 'player_team') AS player_team,
            (players_info ->> 'player_team_against') AS player_team_against,
            (players_info ->> 'player_country') AS player_country,
            (players_info->> 'player_id')::INTEGER AS player_id,
            (players_info->> 'player_kills')::INTEGER AS player_kills,
            (players_info->> 'player_assists')::INTEGER AS player_assists,
            (players_info->> 'player_deaths')::INTEGER AS player_deaths,
            (players_info->> 'map_result_id')::INTEGER AS map_result_id
        FROM players_json_tmp;

    DROP TABLE players_json_tmp;
END;
$$;
--DROP TABLE players_based_json;
CALL table_based_on_json();
--select * from players_based_json

-- 3. Создание таблицы с атрибутом JSON с последующим заполнением данными

CREATE TABLE stand_in_players (
    match_id INT NOT NULL,
    replaced_player_id INT NOT NULL,
    stand_in_player_info JSON NOT NULL
);

INSERT INTO stand_in_players
VALUES (2340873, 8394, '{"player_name": "Jumpy", "player_team": "No Team", "player_country": "Sweden", "player_id": 153}'),
       (2337317, 11816, '{"player_name": "GeT_RiGhT", "player_team": "NiP", "player_country": "Sweden", "player_id": 39}');

--DROP TABLE stand_in_players

-- 4.1. Извлечение JSON аргумента из JSON файла 

CREATE OR REPLACE FUNCTION extract_json_fragment()  
    RETURNS TABLE(player_info JSON, type TEXT)
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 

    CREATE TABLE IF NOT EXISTS players_transfer_table (
        transfer_info JSON
    );

    DELETE FROM players_transfer_table;

    COPY players_transfer_table
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';
    -- оператор #> выдача объекта JSON
    RETURN QUERY
        SELECT transfer_info #> '{player_info}' as "player_info", json_typeof(transfer_info #> '{player_info}') AS "type"
        FROM players_transfer_table;

    DROP TABLE players_transfer_table;
END;
$$;

SELECT extract_json_fragment()

-- 4.2. Извлечение атрибута из JSON файла

CREATE OR REPLACE FUNCTION extract_json_attribute()  
    RETURNS TABLE(transfer_usd_cost TEXT, type TEXT)
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 

    CREATE TABLE IF NOT EXISTS players_transfer_table (
        transfer_info JSON
    );

    DELETE FROM players_transfer_table;

    COPY players_transfer_table
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';
    -- оператор ->> выдача поля объекта JSON в типе text
    -- оператор -> выдача поля объекта JSON по ключу
    RETURN QUERY
        SELECT transfer_info ->> 'transfer_usd_cost' as "transfer_usd_cost", json_typeof(transfer_info -> 'transfer_usd_cost') AS "type"
        FROM players_transfer_table;

    DROP TABLE players_transfer_table;
END;
$$;

SELECT extract_json_attribute()

-- 4.3 Проверить существует aтрибут

CREATE OR REPLACE PROCEDURE check_attribute_existence()  
    LANGUAGE PLPGSQL
AS 
$$
DECLARE
    object_tmp TEXT;
BEGIN 
    object_tmp = '';
    CREATE TABLE IF NOT EXISTS players_transfer_table (
        transfer_info JSON
    );

    DELETE FROM players_transfer_table;

    COPY players_transfer_table
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';
    -- оператор #>> выдача объекта JSON в типе text
    SELECT transfer_info #>> '{player_info}'
    INTO object_tmp
    FROM players_transfer_table;

    IF object_tmp IS NULL THEN raise notice 'Does not exist';
    ELSE raise notice 'Attribute exists - %', object_tmp;
    END IF;

    DROP TABLE players_transfer_table;
END;
$$;

CALL check_attribute_existence()

-- 4.4 Изменить JSON документ
CREATE OR REPLACE PROCEDURE edit_json_file()  
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS players_transfer_table (
        transfer_info JSON
    );

    DELETE FROM players_transfer_table;

    COPY players_transfer_table
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';

    UPDATE players_transfer_table
    SET transfer_info = '{"transfer_date":"2020-10-24","player_prev_team":"FaZe","player_new_team":"G2","transfer_usd_cost":500000,"player_info":{"player_id":3741,"player_country":"Bosnia and Herzegovina","player_age":24}}';

    COPY (
	    SELECT transfer_info
        FROM players_transfer_table
    ) TO 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';

    DROP TABLE players_transfer_table;
END
$$;

CALL edit_json_file()

-- 4.5 Разделить JSON на несколько строк по узлам

CREATE OR REPLACE PROCEDURE split_json_file()  
    LANGUAGE PLPGSQL
AS 
$$
DECLARE 
    object_tmp TEXT;
BEGIN 
    CREATE TABLE IF NOT EXISTS players_transfer_table (
        transfer_info JSONB
    );

    DELETE FROM players_transfer_table;

    COPY players_transfer_table
    FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json';

    SELECT jsonb_pretty(transfer_info)
    INTO object_tmp
    FROM players_transfer_table;

    raise notice '%', object_tmp;

    COPY (
	    SELECT jsonb_pretty(transfer_info)
        FROM players_transfer_table
    ) TO 'C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer2.json';

    DROP TABLE players_transfer_table;
END
$$;

CALL split_json_file()
