-- 1) Определяемую пользователем скалярную функцию CLR,

CREATE OR REPLACE FUNCTION player_team_by_id(id INTEGER) 
    RETURNS TEXT
    LANGUAGE plpython3u
AS
$$
    player_team = plpy.execute(f"\
        SELECT pr.player_team\n\
        FROM players_results pr\n\
        WHERE pr.player_id = '{id}'\n\
        LIMIT 1;"
    )
    
    return player_team[0]["player_team"]
$$;
--SELECT player_team_by_id(3972);

-- 2) Пользовательская агрегатная функция CLR

CREATE OR REPLACE FUNCTION map_quantity_by_team(team VARCHAR, map_name VARCHAR) 
    RETURNS INTEGER
    LANGUAGE plpython3u
AS
$$
    quantity = 0
    Team_map_played = plpy.execute(f"\
        SELECT *\n\
        FROM maps_results;"
	)
    for i in Team_map_played:
        if i['map_name'] == map_name and (i['team_1'] == team or i['team_2'] == team):
            quantity += 1
    return quantity
$$;
select map_quantity_by_team('Keyd','Mirage');

-- 3) Определяемую пользователем табличную функцию CLR

CREATE OR REPLACE FUNCTION matches_by_decider_map(decider_map VARCHAR) 
    RETURNS TABLE(match_date DATE , match_id INT, team_1 VARCHAR, team_2 VARCHAR, decider_map VARCHAR)
    LANGUAGE plpython3u
AS
$$
    matches_table = plpy.execute("select * from matches;")
    result_table = []
    for i in matches_table:
        if i['decider_map'] == decider_map:
            result_table.append(i)
    return result_table
$$;
select matches_by_decider_map('Mirage')

-- 4) Хранимую процедуру CLR

CREATE OR REPLACE PROCEDURE id_by_player_name(player_name VARCHAR)
    LANGUAGE plpython3u
AS
$$
    id = plpy.execute(f"\
        SELECT DISTINCT player_id\n\
        FROM players_results\n\
        WHERE player_name = '{player_name}';"
        )
    if len(id) == 0:
        plpy.notice(
            f"There is no player with '{player_name}' nickname."
        )
    else:
        id = id[0]['player_id']
        plpy.notice(
            f"There is id '{id}' for player with '{player_name}' nickname."
        )
$$;
call id_by_player_name('kennyS');
call id_by_player_name('Karim');
/*
select * from players_results;
        SELECT player_id
        FROM players_results
        WHERE player_name = 'kennyS';*/

-- 5) Триггер CLR

CREATE OR REPLACE FUNCTION players_results_insert_delete() 
    RETURNS TRIGGER
    LANGUAGE plpython3u
AS
$$
    if TD['event'] == 'INSERT':
        plpy.notice(
            f"There was insertion to players_results table."
        )
    if TD['event'] == 'DELETE':
        plpy.notice(
            f"There was deletion to players_results table."
        )
$$;

CREATE TRIGGER players_results_insert_delete_trigger
    BEFORE INSERT OR DELETE
    ON players_results
FOR EACH STATEMENT
EXECUTE PROCEDURE players_results_insert_delete();

-- 6) Определяемый пользователем тип данных CLR. 

CREATE TYPE player_struct AS (
    player_id INT,
    player_name VARCHAR,
    player_team VARCHAR
);

CREATE OR REPLACE FUNCTION get_player_struct(player_id INT) 
    RETURNS player_struct
    LANGUAGE plpython3u
AS
$$
    player_name = plpy.execute(f"\
        SELECT pr.player_name\n\
        FROM players_results pr\n\
        WHERE pr.player_id = '{player_id}';"
    )[0]["player_name"]
    player_team = plpy.execute(f"\
        SELECT pr.player_team\n\
        FROM players_results pr\n\
        WHERE pr.player_id = '{player_id}';"
    )[0]["player_team"]
    return (player_id, player_name, player_team)
$$;

SELECT player_team_by_id(3972);
SELECT get_player_struct(3972);



