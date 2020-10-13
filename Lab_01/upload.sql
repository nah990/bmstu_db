\c db_matches;

/* maps */
COPY maps_results FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_01/maps.csv' DELIMITER ',' NULL AS '0' CSV ENCODING 'UTF8';

/* matches */
COPY matches FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_01/matches.csv' DELIMITER ',' NULL AS '0'  CSV ENCODING 'UTF8';

/* players */
COPY players_results FROM 'C:/Labs/Database_Labs/bmstu_db/Lab_01/players.csv' DELIMITER ',' NULL AS '0'  CSV ENCODING 'UTF8';

