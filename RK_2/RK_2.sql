--VAR №2

--win powershell cmnds
--psql -U postgres
--\i C:/Labs/Database_Labs/bmstu_db/RK_2/RK_2.sql

DROP TABLE work CASCADE;
DROP TABLE performer CASCADE;
DROP TABLE customer CASCADE;

--CREATE DATABASE rk_02;
\c rk_02;

CREATE TABLE IF NOT EXISTS work(
    id SERIAL NOT NULL PRIMARY KEY,
    name_of_work VARCHAR NOT NULL,
    labor_costs INT NOT NULL, 
    necessary_equipment VARCHAR NOT NULL,

    id_performer INT NOT NULL,
    id_customer INT NOT NULL
);

CREATE TABLE IF NOT EXISTS performer(
    id SERIAL NOT NULL PRIMARY KEY,
    full_name VARCHAR NOT NULL,
    birthdate DATE NOT NULL,
    experience INT NOT NULL,
    telephone INT NOT NULL,

    id_work INT NOT NULL,
    id_customer INT NOT NULL

);

CREATE TABLE IF NOT EXISTS customer (
    id SERIAL NOT NULL PRIMARY KEY,
    full_name VARCHAR NOT NULL,
    birthdate DATE NOT NULL,
    experience INT NOT NULL,
    telephone INT NOT NULL,

    id_work INT NULL,
    id_performer INT NOT NULL

);

ALTER TABLE work ADD CONSTRAINT fk_id_performer
                FOREIGN KEY(id_performer)
                REFERENCES performer(id);

ALTER TABLE performer ADD CONSTRAINT fk_id_customer
                FOREIGN KEY(id_customer)
                REFERENCES customer(id);

ALTER TABLE customer ADD CONSTRAINT fk_id_work
                FOREIGN KEY(id_work)
                REFERENCES work(id);

/* upload csv */
COPY work FROM 'C:/Labs/Database_Labs/bmstu_db/RK_2/work.sql' DELIMITER ',' NULL AS '0' CSV ENCODING 'UTF8';
COPY customer FROM 'C:/Labs/Database_Labs/bmstu_db/RK_2/customer.sql' DELIMITER ',' NULL AS '0' CSV ENCODING 'UTF8';
COPY performer FROM 'C:/Labs/Database_Labs/bmstu_db/RK_2/performer.sql' DELIMITER ',' NULL AS '0' CSV ENCODING 'UTF8';

--1) Инструкция SELECT, использующая предикат сравнения 
--Все работы с трудозатратой более 1000, отстортированные по убыванию
SELECT * FROM work
WHERE labor_costs > 1000
ORDER BY labor_costs DESC

--2) Инструкцию, использующую оконную функцию
--Все работы превыщающие среднюю трудозатрату, по убыванию
select distinct name_of_work,
    avg(labor_costs)over(partition by name_of_work) avg_labor_cost
from work
order by labor_costs DESC
--3) Инструкция SELECT, использующая вложенные коррелированные
--подзапросы в качестве производных таблиц в предложении FROM 
--TODO FROM ???

/*Создать хранимую процедуру с двумя входными параметрами – имя базы
данных и имя таблицы, которая выводит сведения об индексах указанной
таблицы в указанной базе данных. Созданную хранимую процедуру
протестировать. */

CREATE OR REPLACE PROCEDURE get_indexes(DATABASE_NAME VARCHAR, TABLE_NAME VARCHAR)
LANGUAGE plpgsql
AS
$$
DECLARE

    REC RECORD;

    BEGIN

        FOR rec IN (SELECT INDEXNAME, INDEXDEF FROM PG_INDEXES WHERE TABLENAME = TABLE_NAME)

        LOOP

            RAISE NOTICE 'INDEXNAME - % ,
            INDEXDEF - %', REC.INDEXNAME, REC.INDEXDEF;

        END LOOP;

    END;

$$;

--CALL get_indexes('rk_02', 'work');
CALL get_indexes('rk_02', 'performer');
--CALL get_indexes('rk_02', 'customer');