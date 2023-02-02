--ДЗ №1

CREATE SCHEMA tag_data;

CREATE TABLE tag_data.units
	(
	unit_id SERIAL NOT NULL,
	unit_name VARCHAR(20) NOT NULL,
	CONSTRAINT units_ukey UNIQUE(unit_name),
	CONSTRAINT units_pkey PRIMARY KEY(unit_id)
	);
	
CREATE TABLE tag_data.parameters
	(
	parameter_id SERIAL NOT NULL,
	parameter_name VARCHAR(40) NOT NULL,
	CONSTRAINT parameter_ukey UNIQUE(parameter_name),
	CONSTRAINT parameter_pkey PRIMARY KEY(parameter_id)
	);


CREATE TABLE tag_data.agregates
	(
	agregate_id SERIAL NOT NULL,
	agregate_name VARCHAR(40) NOT NULL,
	CONSTRAINT agregate_name_ukey UNIQUE(agregate_name),
	CONSTRAINT agregate_pkey PRIMARY KEY(agregate_id)
	);


CREATE TABLE tag_data.tags
	(
	tag_id SERIAL NOT NULL,
	tag_name VARCHAR(60) NOT NULL,
	tag_description VARCHAR(300) NOT NULL,
	parameter_id INTEGER NOT NULL,
	unit_id INTEGER NOT NULL,
	agregate_id INTEGER NOT NULL,
	CONSTRAINT tag_name_ukey UNIQUE(tag_name),
	CONSTRAINT tag_id_pkey PRIMARY KEY(tag_id),
	CONSTRAINT agregate_id_fk FOREIGN KEY (agregate_id)
		REFERENCES tag_data.agregates(agregate_id)
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION,
	CONSTRAINT unit_id_fk FOREIGN KEY (unit_id)
		REFERENCES tag_data.units(unit_id)
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION,
	CONSTRAINT parameter_id_fk FOREIGN KEY (parameter_id)
		REFERENCES tag_data.parameters(parameter_id)
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION
	);
	
CREATE TABLE tag_data.tag_data
	(
	id SERIAL NOT NULL,
	tag_id INTEGER NOT NULL,
	tag_date TIMESTAMP NOT NULL,
	tag_value REAL NOT NULL,
	CONSTRAINT id_pkey PRIMARY KEY(id),
	CONSTRAINT tag_id_id_fk FOREIGN KEY (tag_id)
		REFERENCES tag_data.tags(tag_id)
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION
	);

--ДЗ №2

CREATE TABLE tag_data.temp
	(
	agregate_name VARCHAR(30) NOT NULL,
	agregate_tag VARCHAR(30) NOT NULL,
	tag_description_name VARCHAR(300) NOT NULL,
	parameter_name VARCHAR(40) NOT NULL,
	unit_name VARCHAR(10) NOT NULL,
	tag_date TIMESTAMP NOT NULL,
	tag_value REAL NOT NULL
	);
	
COPY tag_data.temp FROM 'C:/DataImportExport/tag_data.csv' WITH
(FORMAT CSV, DELIMITER ';', ENCODING ' UTF8 ', HEADER);

SELECT * FROM tag_data.temp;

INSERT INTO tag_data.units (unit_name)
SELECT DISTINCT unit_name FROM tag_data.temp;

SELECT * FROM tag_data.units;

INSERT INTO tag_data.parameters (parameter_name)
SELECT DISTINCT parameter_name FROM tag_data.temp;

SELECT * FROM tag_data.parameters;

INSERT INTO tag_data.agregates (agregate_name)
SELECT DISTINCT agregate_name FROM tag_data.temp;

SELECT * FROM tag_data.agregates;

INSERT INTO tag_data.tags 
(tag_name, tag_description, parameter_id, unit_id, agregate_id)
SELECT DISTINCT
tmp.agregate_tag, tmp.tag_description_name, p.parameter_id, u.unit_id, a.agregate_id
FROM tag_data.temp AS tmp,
tag_data.parameters AS p,
tag_data.units AS u,
tag_data.agregates AS a
WHERE tmp.parameter_name=p.parameter_name
AND tmp.unit_name=u.unit_name
AND tmp.agregate_name = a.agregate_name;

SELECT * FROM tag_data.tags;

INSERT INTO tag_data.tag_data
(tag_id, tag_date, tag_value)
SELECT 
t.tag_id, tmp.tag_date, tmp.tag_value
FROM tag_data.temp AS tmp,
tag_data.parameters AS p,
tag_data.units AS u,
tag_data.agregates AS a,
tag_data.tags AS t
WHERE
tmp.agregate_tag=t.tag_name
AND tmp.tag_description_name=t.tag_description
AND tmp.parameter_name=p.parameter_name
AND tmp.unit_name=u.unit_name
AND tmp.agregate_name = a.agregate_name;

SELECT * FROM tag_data.tag_data;

--общий запрос
SELECT a.agregate_name, t.tag_name,
t.tag_description, p.parameter_name,
u.unit_name, td.tag_date, td.tag_value
FROM 
tag_data.parameters AS p,
tag_data.units AS u,
tag_data.agregates AS a,
tag_data.tags AS t,
tag_data.tag_data AS td
WHERE
td.tag_id=t.tag_id
AND t.parameter_id=p.parameter_id
AND t.unit_id=u.unit_id
AND t.agregate_id = a.agregate_id;

DROP TABLE tag_data.temp;

--ДЗ №3.1
CREATE OR REPLACE VIEW public.flights_view AS
SELECT
	f.flight_no, -- номер рейса,
	f.scheduled_departure, -- дата и время вылета,
    	f.departure_airport, -- код аэропорта вылета,
	dep.city as dep_city, -- город вылета,
	dep.airport_name as dep_airport, -- аэропорт вылета,
    	f.scheduled_arrival, -- дата и время прилета,
    	f.arrival_airport, -- код аэропорта прилета,
	arr.city as arr_city, -- город прилета,
	arr.airport_name as arr_airport, -- аэропорт прилета,
	afd.model -- модель самолета
FROM bookings.flights AS f
JOIN bookings.airports_data AS dep ON f.departure_airport=dep.airport_code
JOIN bookings.airports_data AS arr  ON f.arrival_airport=arr.airport_code
JOIN bookings.aircrafts_data AS afd ON f.aircraft_code = afd.aircraft_code
WHERE (dep.city ->> 'ru' = 'Москва' OR dep.city ->> 'ru' = 'Санкт-Петербург')
AND extract(hour from (f.scheduled_departure)) < 12;

SELECT * FROM public.flights_view;

--ДЗ №3.2
CREATE OR REPLACE VIEW public.tag_data_view AS
((SELECT
	t.tag_name,
	u.unit_name,
	td.tag_date,
	td.tag_value
FROM tag_data.tags AS t
JOIN tag_data.units AS u USING(unit_id)
JOIN tag_data.tag_data AS td ON t.tag_id = td.tag_id
WHERE t.tag_name='35-11-1000:FI39.F'
ORDER BY td.tag_date DESC LIMIT 10)
UNION
(SELECT
	t.tag_name,
	u.unit_name,
	td.tag_date,
	td.tag_value
FROM tag_data.tags AS t
JOIN tag_data.units AS u USING(unit_id)
JOIN tag_data.tag_data AS td ON t.tag_id = td.tag_id
WHERE t.tag_name='G43-107:FCA3-260.F'
ORDER BY td.tag_date DESC LIMIT 10)
UNION
(SELECT
	t.tag_name,
	u.unit_name,
	td.tag_date,
	td.tag_value
FROM tag_data.tags AS t
JOIN tag_data.units AS u USING(unit_id)
JOIN tag_data.tag_data AS td ON t.tag_id = td.tag_id
WHERE t.tag_name='AVT6:TIR0428.T'
ORDER BY td.tag_date DESC LIMIT 10));

SELECT * FROM public.tag_data_view;

--ДЗ №3.3
CREATE TABLE public.table_1
(name VARCHAR(20) NOT NULL);
CREATE TABLE public.table_2
(name VARCHAR(20) NOT NULL);

INSERT INTO public.table_1
VALUES
('C#'),('Python'),('Go'),('C');

INSERT INTO public.table_2
VALUES
('C#'),('Python'),('Maple'),('Prolog'),('MATLAB');

SELECT * FROM public.table_1 INTERSECT SELECT * FROM public.table_2;
SELECT * FROM public.table_1 EXCEPT SELECT * FROM public.table_1 INTERSECT SELECT * FROM public.table_2
UNION 
SELECT * FROM public.table_2 EXCEPT SELECT * FROM public.table_2 INTERSECT SELECT * FROM public.table_1;