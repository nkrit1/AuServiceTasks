--ДЗ №4 (я отправляла в прошлую среду, ответа не было, переделка задачи 2)
WITH RECURSIVE employment_structure(id,parent_id,fio,post,post_level,parent_fio,parent_post) AS
(
  SELECT id, parent_id,fio,post,0,CAST ('' AS TEXT),CAST ('' AS TEXT)
  FROM staff
  WHERE parent_id IS NULL
  UNION ALL
  SELECT staff.id,staff.parent_id,staff.fio,staff.post,parent.post_level+1,parent.fio,parent.post
  FROM employment_structure AS parent, staff
  WHERE parent.id=staff.parent_id
)
SELECT parent_id, parent_fio,parent_post,post_level+1 AS parent_level,COUNT(*) AS empl_counter
FROM employment_structure AS empl
WHERE parent_id IS NOT NULL
GROUP BY parent_id, parent_fio, parent_post, parent_level;


-- ДЗ №5

CREATE OR REPLACE FUNCTION public.f_get_quarter(_month_num INT) 
RETURNS INT AS
$$
DECLARE 
	_result INT;
BEGIN
	
    CASE _month_num 
    WHEN 4,5,6 THEN _result := 2;
    WHEN 7,8,9 THEN _result := 3;
	WHEN 10,11,12 THEN _result := 4;
	ELSE _result := 1;
	END CASE;
    
    RETURN _result;
	
END;
$$
LANGUAGE PLPGSQL;

SELECT f_get_quarter(1);

CREATE OR REPLACE FUNCTION public.f_get_quarter_v2(_month_num INT) 
RETURNS INT AS
$$
DECLARE 
	_result INT;
BEGIN
	
	CASE  
    	WHEN _month_num BETWEEN 4 AND 6 THEN _result := 2;
    	WHEN _month_num BETWEEN 7 AND 9 THEN _result := 3;
		WHEN _month_num BETWEEN 10 AND 12 THEN _result := 4;
		ELSE _result := 1;
		END CASE;
    
    
    RETURN _result;
	
END;
$$
LANGUAGE PLPGSQL;

SELECT f_get_quarter_v2(12);


--Написать функцию, принимающую на вход номер месяца и
--город вылета, возвращающую списком (не таблицей) номера
--рейсов. Используйте данные в схеме booking.
CREATE OR REPLACE FUNCTION public.f_get_flights_by_month_depcity(_month_num INT, _dep_city CHARACTER)
RETURNS SETOF VARCHAR
AS
$$

	SELECT f.flight_no
    FROM bookings.flights AS f
	JOIN bookings.airports_data AS ad
	ON ad.airport_code = f.departure_airport
    WHERE extract(month from (f.scheduled_departure)) = _month_num 
	AND ad.city ->> 'ru' = _dep_city;
$$
LANGUAGE SQL;

SELECT * FROM f_get_flights_by_month_depcity(1,'Москва');


--Написать процедуру, которая будет записывать новые данные
--в таблицу «prodmag.products». Данные будем записывать в
--формате JSON. 

CREATE TYPE prodmag.ct_products6 AS 
	(
	product_id INTEGER,
	products_name VARCHAR(24),
    food_type_id SMALLINT,
    unit_id SMALLINT,
	qty INTEGER,
    price NUMERIC(6,2),
	--cost NUMERIC(10,2),
	seller_id INTEGER,
	deadline SMALLINT
	);

CREATE OR REPLACE PROCEDURE prodmag.p_set_products_values_json2(input_values JSON) AS
$$
BEGIN

	INSERT INTO prodmag.products
	(product_id, products_name, food_type_id, unit_id, qty, price, seller_id, deadline)
    SELECT product_id, products_name, food_type_id, unit_id, qty, price, seller_id, deadline
    FROM JSON_POPULATE_RECORDSET(NULL::prodmag.ct_products6, input_values) AS t;
    
END;
$$
LANGUAGE PLPGSQL;

CALL prodmag.p_set_products_values_json2('[{"product_id":1,"products_name":"product","food_type_id":1,"unit_id":1, 
										"qty":1,"price":6.02, "seller_id":1,"deadline":1}]');

SELECT * FROM prodmag.products;

--Написать функцию, принимающую на вход массив Numeric и
--считающую с помощью цикла среднее арифметическое всех
--его элементов.

--Написать функцию, принимающую на вход массив Numeric и
--считающую с помощью цикла среднее арифметическое всех
--его элементов.

CREATE OR REPLACE FUNCTION public.f_avg_of_array(a NUMERIC(3,2)[] ) --не указал имя входной переменной, так то же можно
RETURNS NUMERIC(3,2) AS 
$$
DECLARE 
	sum NUMERIC(3,2) = 0.00; 
	cnt INT = 0;
	_result NUMERIC(3,2);
	 el NUMERIC(3,2);
	flag BOOL = true;
BEGIN

    --перебираю элементы массива в цикле
	FOREACH el IN ARRAY a --обратился к входной переменной по номеру т.к. она безымянная
    LOOP
	cnt := cnt + 1;
    sum := sum + el;
	
	IF flag
	THEN
	_result := sum/cnt;
    END IF;
	
    END LOOP;
	
	RETURN _result;
	
END;
$$
LANGUAGE PLPGSQL;

--передаю в функцию массив
SELECT * FROM public.f_avg_of_array(ARRAY[2.00, 1.00]);


--ДЗ №6

--Написать триггер на вставку, обновление и
--удаление записей в таблице prodmag.products. Триггер
--должен логгировать изменения в таблицу
--prodmag.products_log. Для вставки пишем содержимое новой
--строки, дату добавления, insert, new. Для удаления пишем
--содержимое удаленной строки, дату удаления, delete, old. Для
--обновления пишем две строки: старое состояние строки, дата
--редактирования, update, old и новое состояние строки, дата
--редактирования, update, new.

CREATE OR REPLACE FUNCTION prodmag.trg() RETURNS TRIGGER AS
$$
DECLARE
	rec RECORD;
	str TEXT := '';
BEGIN
	
	IF TG_LEVEL = 'ROW' --TG_LEVEL уровень строка или операция
	THEN
	
		CASE TG_OP --TG_OP имя оператора
		WHEN 'INSERT' THEN 
			rec := NEW;
			str := NEW::TEXT;
		WHEN 'UPDATE' THEN 
			rec := NEW;
			str := OLD || ' -> ' || NEW;
		WHEN 'DELETE' THEN 
			rec := OLD;
			str := OLD::TEXT;
		END CASE;
		
	END IF;
		
	RAISE NOTICE '% % % %: %', 
		TG_TABLE_NAME, --имя таблицы, на которой сработал триггер
		TG_WHEN, --условие фильтра
		TG_OP, --имя оператора
		TG_LEVEL, --уровень строка или операция
		str;
		
	RETURN rec;

END;
$$
LANGUAGE PLPGSQL;

--создаем триггер на уровне оператора BEFORE STATEMENT
CREATE TRIGGER tr_before_stmt
BEFORE INSERT OR UPDATE OR DELETE --события
ON prodmag.products               --таблица
FOR EACH STATEMENT                --уровень
EXECUTE FUNCTION prodmag.trg();    --функция

--создаем триггер на уровне оператора BEFORE ROW
CREATE TRIGGER tr_before_row
BEFORE INSERT OR UPDATE OR DELETE --события
ON prodmag.products               --таблица
FOR EACH ROW                      --уровень
EXECUTE FUNCTION prodmag.trg();    --функция

--создаем триггер на уровне оператора AFTER ROW
CREATE TRIGGER tr_after_row
AFTER INSERT OR UPDATE OR DELETE  --события
ON prodmag.products                            --таблица
FOR EACH ROW                      --уровень
EXECUTE FUNCTION prodmag.trg();    --функция

--создаем триггер на уровне оператора AFTER STATEMENT
CREATE TRIGGER tr_after_stmt
AFTER INSERT OR UPDATE OR DELETE  --события
ON prodmag.products                 --таблица
FOR EACH STATEMENT                --уровень
EXECUTE FUNCTION prodmag.trg();    --функция

CREATE OR REPLACE FUNCTION prodmag.tbl_trg1() RETURNS TRIGGER AS
$$
DECLARE
    rec RECORD;
BEGIN

    CASE TG_OP
        WHEN 'UPDATE' THEN FOR rec IN SELECT * FROM old_table
                               LOOP
                                   INSERT INTO prodmag.products_log (product_id, products_name, food_type_id, unit_id,
                                                                     qty, price, seller_id, deadline, operation, row)
                                   VALUES (rec.product_id, rec.products_name, rec.food_type_id, rec.unit_id, rec.qty,
                                           rec.price,
                                           rec.seller_id, rec.deadline, 'update', 'old');
                               END LOOP;

                           FOR rec IN SELECT * FROM new_table
                               LOOP
                                   INSERT INTO prodmag.products_log (product_id, products_name, food_type_id, unit_id,
                                                                     qty, price, seller_id, deadline, operation, row)
                                   VALUES (rec.product_id, rec.products_name, rec.food_type_id, rec.unit_id, rec.qty,
                                           rec.price,
                                           rec.seller_id, rec.deadline, 'update', 'new');

                               END LOOP;

        WHEN 'DELETE' THEN FOR rec IN SELECT * FROM old_table
            LOOP
                INSERT INTO prodmag.products_log (product_id, products_name, food_type_id, unit_id,
                                                  qty, price, seller_id, deadline, operation, row)
                VALUES (rec.product_id, rec.products_name, rec.food_type_id, rec.unit_id, rec.qty, rec.price,
                        rec.seller_id, rec.deadline, 'delete', 'old');
            END LOOP;

        WHEN 'INSERT' THEN FOR rec IN SELECT * FROM new_table
            LOOP
                INSERT INTO prodmag.products_log (product_id, products_name, food_type_id, unit_id,
                                                  qty, price, seller_id, deadline, operation, row)
                VALUES (rec.product_id, rec.products_name, rec.food_type_id, rec.unit_id, rec.qty, rec.price,
                        rec.seller_id, rec.deadline, 'insert', 'new');
            END LOOP;
        END CASE;

    RETURN NULL;

END;

$$
LANGUAGE PLPGSQL;

--тут мы для каждого события должны создать отдельный триггер	
CREATE TRIGGER tr_after_insert_stmt2
AFTER INSERT ON prodmag.products
REFERENCING --прикрепляем ссылку на переходную таблицу
	NEW TABLE AS new_table --для insert только NEW
FOR EACH STATEMENT 
EXECUTE FUNCTION prodmag.tbl_trg1(); 

CREATE TRIGGER tr_after_update_stmt2
AFTER UPDATE ON prodmag.products
REFERENCING
	OLD TABLE AS old_table --для update обе
	NEW TABLE AS new_table
FOR EACH STATEMENT 
EXECUTE FUNCTION prodmag.tbl_trg1(); 

CREATE TRIGGER tr_after_delete_stmt2
AFTER DELETE ON prodmag.products
REFERENCING
	OLD TABLE AS old_table --для delete только OLD
FOR EACH STATEMENT 
EXECUTE FUNCTION prodmag.tbl_trg1(); 

--удаление
DELETE FROM prodmag.products WHERE product_id = 33;

--вставка
CALL prodmag.p_set_products_values_json2('[{"product_id":34,"products_name":"Каша",
"food_type_id":1,"unit_id":1, "qty":1,"price":6.02, "seller_id":1,"deadline":1}]');

--апдейт сущестующей строки
UPDATE prodmag.products SET price = 9.09 WHERE product_id = 34;

--апдейт несуществующей
UPDATE prodmag.products SET price = 9.08 WHERE product_id = 38;
SELECT * FROM prodmag.products_log;

--Написать триггер на вставку и обновление записей в таблице
--prodmag.products. Триггер должен выполнять проверку
--правильности сохраняемых в таблице данных и порождать
--Exception (тем самым не давая внести изменения в таблицу), в
--том случае, если данные не валидные.
CREATE OR REPLACE FUNCTION prodmag.tbl_trg2() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.products_name IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "products_name"'
            USING HINT = 'Заполните поле "product_name"', ERRCODE = 23502;
    ELSEIF NEW.food_type_id IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "food_type_id"'
            USING HINT = 'Заполните поле "food_type_id"', ERRCODE = 23502;
    ELSEIF NEW.unit_id IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "unit_id"'
            USING HINT = 'Заполните поле "unit_id"', ERRCODE = 23502;
    ELSEIF NEW.price IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "price"'
            USING HINT = 'Заполните поле "price"', ERRCODE = 23502;
    ELSEIF NEW.seller_id IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "seller_id"'
            USING HINT = 'Заполните поле "seller_id"', ERRCODE = 23502;
    ELSEIF NEW.deadline IS NULL THEN
        RAISE EXCEPTION 'Не указано поле "deadline"'
            USING HINT = 'Заполните поле "deadline"', ERRCODE = 23502;
    END IF;

    IF NEW.price <= 0 THEN
        RAISE EXCEPTION 'Поле "price" меньше или равно нулю'
            USING HINT = 'Проверьте поле "price" и замените его значение', ERRCODE = 23514;
    END IF;

    IF (SELECT food_type_id FROM prodmag.food_types where food_type_id=NEW.food_type_id) IS NULL THEN
        RAISE EXCEPTION 'Нет соответствия между значением поля "food_type_id" и таблицей food_types'
            USING HINT = 'Измените поле "food_type_id"', ERRCODE = 23503;
    END IF;

    RETURN NEW;

END;

$$
LANGUAGE PLPGSQL;

CREATE TRIGGER tbl_trg2_stmt BEFORE INSERT OR UPDATE ON prodmag.products
    FOR EACH ROW EXECUTE PROCEDURE prodmag.tbl_trg2();
	
INSERT INTO prodmag.products
	(product_id, products_name, food_type_id, unit_id, qty, price, seller_id, deadline)
VALUES(35,null,1,1,1,6.02,1,1);

INSERT INTO prodmag.products
	(product_id, products_name, food_type_id, unit_id, qty, price, seller_id, deadline)
VALUES(35,'Каша',1,1,1,-6.02,1,1);

SELECT food_type_id FROM prodmag.food_types;

INSERT INTO prodmag.products
	(product_id, products_name, food_type_id, unit_id, qty, price, seller_id, deadline)
VALUES(35,'Каша',11,1,1,6.02,1,1);