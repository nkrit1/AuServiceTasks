--ДЗ №4
--1
--Напишите запрос к таблицам в схеме «booking», который
--вернет суммарное количество рейсов (перелетов) по каждому
--типу самолета, посуточно за январь 2017 года.

SELECT extract(day from (f.scheduled_departure)) AS day_in_January, 
a.model->> 'ru' AS aircraft_model, COUNT(*) as cnt 
FROM bookings.flights AS f
JOIN bookings.aircrafts_data AS a USING(aircraft_code)
WHERE extract(month from (f.scheduled_departure)) = 1 AND extract(year from (f.scheduled_departure)) = 2017
GROUP BY extract(day from (f.scheduled_departure)), a.model;

--Напишите запрос из таблиц в схеме «booking» который вернет
--общую сумму бронирований и среднее значение
--бронирований посуточно за январь 2017 года.

SELECT extract(day from (b.book_date)) AS day_in_January,
SUM(b.total_amount) AS sum, SUM(b.total_amount)/COUNT(*) AS avg
FROM bookings.bookings AS b
WHERE extract(month from (b.book_date)) = 1 AND extract(year from (b.book_date)) = 2017
GROUP BY extract(day from (b.book_date));

--2
--Используя рекурсивный запрос WITH RECURSIVE, посчитать
--сколько у каждого человека сотрудников в подчинении.
	
WITH RECURSIVE cte
(fio, post, id, level)
AS
	(
	SELECT --корневые объекты
		fio,
        post,
		id,
		4
    FROM public.staff AS st
    WHERE parent_id IS NULL

    UNION

    SELECT --дочерние объекты
        staff.fio,
        staff.post,
		staff.id,
		cte.level - 1
    FROM public.staff AS staff
    JOIN cte 
        ON cte.id = staff.parent_id
	)
SELECT * FROM cte;