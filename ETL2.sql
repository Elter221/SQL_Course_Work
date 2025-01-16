CREATE EXTENSION IF NOT EXISTS dblink SCHEMA dwh; 

INSERT INTO dwh.DimTime (the_date, date_day, date_month, quarter, date_year, week, date_time)
SELECT DISTINCT	
	o.order_date::date,
	EXTRACT(DAY FROM o.order_date)::int,
	EXTRACT(MONTH FROM o.order_date)::int,
	EXTRACT(QUARTER FROM o.order_date)::int,
	EXTRACT(YEAR FROM o.order_date)::int,
	EXTRACT(WEEK FROM o.order_date)::int,
	o.order_date::time
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT order_date FROM shop_oltp.Orders')
AS o(order_date TIMESTAMP)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimTime dt 
	WHERE (dt.the_date + dt.date_time) = o.order_date
);

--SELECT * FROM dwh.DimTime

INSERT INTO dwh.DimTime (the_date, date_day, date_month, quarter, date_year, week, date_time)
SELECT DISTINCT	
	oor.order_of_repair_date::date,
	EXTRACT(DAY FROM oor.order_of_repair_date)::int,
	EXTRACT(MONTH FROM oor.order_of_repair_date)::int,
	EXTRACT(QUARTER FROM oor.order_of_repair_date)::int,
	EXTRACT(YEAR FROM oor.order_of_repair_date)::int,
	EXTRACT(WEEK FROM oor.order_of_repair_date)::int,
	oor.order_of_repair_date::time
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT order_of_repair_date FROM shop_oltp.Order_Of_Repairs')
AS oor(order_of_repair_date TIMESTAMP)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimTime dt 
	WHERE (dt.the_date + dt.date_time) = oor.order_of_repair_date
);

--SELECT * FROM dwh.DimTime

INSERT INTO dwh.DimTime (the_date, date_day, date_month, quarter, date_year, week, date_time)
SELECT DISTINCT	
	rd.start_date::date,
	EXTRACT(DAY FROM rd.start_date)::int,
	EXTRACT(MONTH FROM rd.start_date)::int,
	EXTRACT(QUARTER FROM rd.start_date)::int,
	EXTRACT(YEAR FROM rd.start_date)::int,
	EXTRACT(WEEK FROM rd.start_date)::int,
	rd.start_date::time
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT start_date FROM shop_oltp.Repair_Details')
AS rd(start_date TIMESTAMP)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimTime dt 
	WHERE (dt.the_date + dt.date_time) = rd.start_date
);

--SELECT * FROM dwh.DimTime

INSERT INTO dwh.DimTime (the_date, date_day, date_month, quarter, date_year, week, date_time)
SELECT DISTINCT	
	c.creation_date::date,
	EXTRACT(DAY FROM c.creation_date)::int,
	EXTRACT(MONTH FROM c.creation_date)::int,
	EXTRACT(QUARTER FROM c.creation_date)::int,
	EXTRACT(YEAR FROM c.creation_date)::int,
	EXTRACT(WEEK FROM c.creation_date)::int,
	c.creation_date::time
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT creation_date FROM shop_oltp.Customers')
AS c(creation_date TIMESTAMP)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimTime dt 
	WHERE (dt.the_date + dt.date_time) = c.creation_date
);

--SELECT * FROM dwh.DimTime

INSERT INTO dwh.DimCity(city_id, city_name, subregion)
SELECT DISTINCT 
	c.city_id,
	c.city_name,
	c.subregion
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT city_id, city_name, subregion FROM shop_oltp.City')
AS c(city_id INT, city_name TEXT, subregion TEXT)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimCity dc 
	WHERE dc.city_id = c.city_id
);

--SELECT * FROM dwh.DimCity

INSERT INTO dwh.DimAddress(address_id, city_id, country, street)
SELECT DISTINCT
	a.address_id,
	a.city_id,
	a.country,
	a.street
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT address_id, city_id, country, street FROM shop_oltp.Address')
AS a(address_id INT, city_id INT, country TEXT, street TEXT)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimAddress da 
	WHERE da.address_id = a.address_id
);

--SELECT * FROM dwh.DimAddress

INSERT INTO dwh.DimDistributor(distributor_id, distributor_name)
SELECT DISTINCT
	d.distributor_id,
	d.distributor_name
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT distributor_id, distributor_name FROM shop_oltp.Distributor')
AS d(distributor_id INT, distributor_name TEXT)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimDistributor dd 
	WHERE dd.distributor_id = d.distributor_id
);

--SELECT * FROM dwh.DimDistributor

INSERT INTO dwh.DimStatus(status_id, status_name)
SELECT DISTINCT
	s.status_id,
	s.status_name
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT status_id, status_name FROM shop_oltp.Status')
AS s(status_id INT, status_name TEXT)
WHERE NOT EXISTS(
	SELECT 1 
	FROM dwh.DimStatus ds 
	WHERE ds.status_id = s.status_id
);

--SELECT * FROM dwh.DimStatus

	INSERT INTO dwh.DimFix(fix_id, fix_name, fix_description, fix_price)
SELECT DISTINCT
	f.fix_id,
	f.fix_name,
	f.fix_description,
	f.fix_price
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT fix_id, fix_name, fix_description, fix_price FROM shop_oltp.Fix')
AS f(fix_id INT, fix_name TEXT, fix_description TEXT, fix_price DECIMAL(6,2))
ON CONFLICT(fix_id)
DO UPDATE SET
    fix_description = EXCLUDED.fix_description,
	fix_price = EXCLUDED.fix_price
WHERE
	dwh.DimFix.fix_description <> EXCLUDED.fix_description OR
	dwh.DimFix.fix_price <> EXCLUDED.fix_price;

--SELECT * FROM dwh.DimFix

INSERT INTO dwh.DimProduct(product_id, product_name, product_description)
SELECT DISTINCT
	p.product_id,
	p.product_name,
	p.product_description
FROM dwh.dblink(
    'dbname=oltp_db user=postgres password=12345 host=localhost',
    'SELECT product_id, product_name, product_description FROM shop_oltp.Products')
AS p(product_id INT, product_name TEXT, product_description TEXT)
ON CONFLICT(product_id)
DO UPDATE SET
    product_description = EXCLUDED.product_description
WHERE
	dwh.DimProduct.product_description <> EXCLUDED.product_description;

--SELECT * FROM dwh.DimProduct

WITH updated_customers as (
  	SELECT 
	  c.customer_id,
	  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	  c.email,
	  c.phone_number,
	  c.address_id,
	  (SELECT time_id FROM dwh.DimTime dt WHERE dt.the_date + dt.date_time = c.creation_date) AS creation_time_id
  	FROM dwh.dblink(
      'dbname=oltp_db user=postgres password=12345 host=localhost',
      'SELECT customer_id, first_name, last_name, email, phone_number, address_id, creation_date FROM shop_oltp.Customers')
  	AS c(customer_id INT, first_name TEXT, last_name TEXT, email TEXT, phone_number TEXT, address_id INT, creation_date TIMESTAMP)
  	LEFT JOIN dwh.DimCustomer dc on dc.customer_id = c.customer_id
  	WHERE dc.customer_id IS NULL
	  OR (dc.active_flag = true 
	  	AND (CONCAT(c.first_name, ' ', c.last_name) <> dc.customer_name
	  	OR c.phone_number <> dc.phone_number
      	OR c.address_id <> dc.address_id))
),
insert_current_date AS (
  	INSERT INTO dwh.DimTime (the_date, date_day, date_month, quarter, date_year, week, date_time)
  		SELECT NOW()::date,
  	  	EXTRACT(DAY FROM NOW())::int,
  	  	EXTRACT(MONTH FROM NOW())::int,
  	  	EXTRACT(QUARTER FROM NOW())::int,
  	  	EXTRACT(YEAR FROM NOW())::int,
  	  	EXTRACT(WEEK FROM NOW())::int,
  	  	TO_CHAR(NOW(), 'HH24:MI:00')::time
  	ON CONFLICT (the_date, date_time) DO NOTHING
  	RETURNING time_id
),
current_date_id AS (
 	SELECT COALESCE(
 		(SELECT time_id from insert_current_date), 
 		(SELECT time_id 
 		 FROM dwh.DimTime 
 		 WHERE the_date = CURRENT_DATE
		 	AND date_time = TO_CHAR(NOW(), 'HH24:MI:00')::time)
 	) AS end_time_id
),
update_customer AS
(
 	UPDATE dwh.DimCustomer
 	SET 
 		active_flag = false,
		expiration_time_id = (select end_time_id from current_date_id)
 	WHERE 
	 	customer_id IN (SELECT customer_id from updated_customers) AND active_flag = true
)
INSERT INTO dwh.DimCustomer (customer_id, customer_name, email, phone_number, address_id, creation_time_id, active_flag)
 	SELECT customer_id, customer_name, email, phone_number, address_id, creation_time_id, true
 	FROM updated_customers;
	 
--SELECT * FROM dwh.DimCustomer

INSERT INTO dwh.FactOrders(order_id, customer_id, product_id, distributor_id, order_time_id, total_price, quantity, product_price, delivery_option, status_id)
SELECT
	fo.order_id,
	dc.customer_surrogate_key,
	dp.product_id,
	dd.distributor_id,
	dt.time_id,
	fo.total_price,
	fo.quantity,
	fo.product_price,
	fo.delivery_option,
	ds.status_id
FROM dwh.dblink(
   'dbname=oltp_db user=postgres password=12345 host=localhost',
   'SELECT o.order_id, o.customer_id, od.product_id, od.distributor_id, o.order_date, o.total_price, od.quantity, od.product_price, o.delivery_option, o.status_id
    FROM shop_oltp.Orders o
    JOIN shop_oltp.Order_Details od ON o.order_id = od.order_id')
AS fo(order_id INT, customer_id INT, product_id INT, distributor_id INT, order_date TIMESTAMP, total_price DECIMAL(6, 2), quantity INT, product_price DECIMAL(6, 2), delivery_option TEXT, status_id INT)
JOIN dwh.DimProduct dp ON dp.product_id = fo.product_id
JOIN dwh.DimDistributor dd ON dd.distributor_id = fo.distributor_id
JOIN dwh.DimStatus ds ON ds.status_id = fo.status_id
JOIN dwh.DimTime dt ON dt.the_date + dt.date_time = fo.order_date
JOIN dwh.DimCustomer dc ON dc.customer_id = fo.customer_id AND dc.active_flag = true
ON CONFLICT (order_id, product_id, distributor_id)
DO UPDATE SET
	customer_id = EXCLUDED.customer_id,
	total_price = EXCLUDED.total_price,
	quantity = EXCLUDED.quantity,
	product_price = EXCLUDED.product_price,
	delivery_option = EXCLUDED.delivery_option,
	status_id = EXCLUDED.status_id
WHERE
	dwh.FactOrders.customer_id <> EXCLUDED.customer_id OR
	dwh.FactOrders.total_price <> EXCLUDED.total_price OR
	dwh.FactOrders.quantity <> EXCLUDED.quantity OR
	dwh.FactOrders.product_price <> EXCLUDED.product_price OR
	dwh.FactOrders.delivery_option <> EXCLUDED.delivery_option OR
	dwh.FactOrders.status_id <> EXCLUDED.status_id;

--SELECT * FROM dwh.FactOrders

INSERT INTO dwh.FactRepairs(repair_id, customer_id, repair_order_time_id, fix_id, fix_start_time_id, repairs_total_price, status_id)
SELECT
	fr.order_of_repairs_id AS repair_id,
	dc.customer_surrogate_key,
	dt.time_id,
	df.fix_id,
	tsd.time_id,
	fr.repairs_total_price,
	ds.status_id
FROM dwh.dblink(
   'dbname=oltp_db user=postgres password=12345 host=localhost',
   'SELECT oor.order_of_repairs_id, oor.customer_id, oor.repairs_total_price, oor.status_id, oor.order_of_repair_date, rd.fix_id, rd.start_date
    FROM shop_oltp.Order_Of_Repairs oor
    JOIN shop_oltp.Repair_Details rd ON oor.order_of_repairs_id = rd.repair_id')
AS fr(order_of_repairs_id INT, customer_id INT, repairs_total_price DECIMAL(6,2), status_id INT, order_of_repair_date TIMESTAMP, fix_id INT, start_date TIMESTAMP)
JOIN dwh.DimFix df ON df.fix_id = fr.fix_id
JOIN dwh.DimStatus ds ON ds.status_id = fr.status_id
JOIN dwh.DimTime dt ON dt.the_date + dt.date_time = fr.order_of_repair_date
JOIN dwh.DimTime tsd ON tsd.the_date + tsd.date_time = fr.start_date
JOIN dwh.DimCustomer dc ON dc.customer_id = fr.customer_id AND dc.active_flag = true
ON CONFLICT (repair_id, fix_id)
DO UPDATE SET
	customer_id = EXCLUDED.customer_id,
	repairs_total_price = EXCLUDED.repairs_total_price,
	fix_start_time_id = EXCLUDED.fix_start_time_id,
	status_id = EXCLUDED.status_id
WHERE
	dwh.FactRepairs.customer_id <> EXCLUDED.customer_id OR
	dwh.FactRepairs.repairs_total_price <> EXCLUDED.repairs_total_price OR
	dwh.FactRepairs.fix_start_time_id <> EXCLUDED.fix_start_time_id OR
	dwh.FactRepairs.status_id <> EXCLUDED.status_id;

--SELECT * FROM dwh.FactRepairs