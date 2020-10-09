-- Setup Delays database
-- No loading data

DROP TABLE maps_results CASCADE;
DROP TABLE players_results CASCADE;
DROP TABLE matches CASCADE;

CREATE DATABASE db_matches;
\c db_matches;

CREATE TABLE maps_results(
    map_result_id INT NOT NULL,
    match_id INT NOT NULL CHECK(match_id > 0),
    team_1 VARCHAR NOT NULL,
    team_2 VARCHAR NOT NULL,
    map_name VARCHAR NOT NULL,
    t1_rounds INT,
    t2_rounds INT,
    map_winner INT NOT NULL,

    PRIMARY KEY (map_result_id)
);

CREATE TABLE matches(
    match_date DATE NOT NULL CHECK(match_date > '1000-01-01'),
    match_id INT NOT NULL CHECK(match_id > 0),
    team_1 VARCHAR NOT NULL,
    team_2 VARCHAR NOT NULL,
    match_format VARCHAR,
    t1_removed_1 VARCHAR NOT NULL,
    t1_removed_2 VARCHAR NOT NULL,
    t1_removed_3 VARCHAR NOT NULL,
    t2_removed_1 VARCHAR NOT NULL,
    t2_removed_2 VARCHAR NOT NULL,
    t2_removed_3 VARCHAR NOT NULL,
    t1_picked_1 VARCHAR NOT NULL,
    t2_picked_1 VARCHAR NOT NULL,
    decider_map VARCHAR NOT NULL,

    PRIMARY KEY (match_id)
);

CREATE TABLE players_results(
    player_result_id INT NOT NULL,
    match_id INT NOT NULL CHECK(match_id > 0),
    match_date DATE NOT NULL CHECK(match_date > '1000-01-01'),
    player_name VARCHAR NOT NULL,
    player_team VARCHAR NOT NULL,
    player_team_against VARCHAR NOT NULL,
    player_country VARCHAR NOT NULL,
    player_id INT NOT NULL,
    player_kills VARCHAR,
    player_assists VARCHAR,
    player_deaths VARCHAR,
    map_result_id INT NOT NULL,
    PRIMARY KEY (player_result_id),
    FOREIGN KEY(match_id) REFERENCES matches(match_id),
    FOREIGN KEY(map_result_id) REFERENCES maps_results(map_result_id)
);


-- \c postgres;
-- DROP DATABASE db_matches;
