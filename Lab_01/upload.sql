\c db_matches;

/* maps */
COPY maps_results FROM 'C:/Labs/Database_Labs/maps.csv' DELIMITER ',' NULL AS '0' CSV HEADER ENCODING 'UTF8';

/* players */
COPY players_results FROM 'C:/Labs/Database_Labs/players.csv' DELIMITER ',' NULL AS '0'  CSV HEADER ENCODING 'UTF8';

/* matches */
COPY matches FROM 'C:/Labs/Database_Labs/matches.csv' DELIMITER ',' NULL AS '0'  CSV HEADER ENCODING 'UTF8';