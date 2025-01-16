CREATE EXTENSION IF NOT EXISTS dblink SCHEMA shop_oltp; 

CREATE TEMP TABLE IF NOT EXISTS OrdersList(
	Customer TEXT,
	Email TEXT,
	Phone TEXT,
	Address TEXT,
	RegistrationDate TIMESTAMP,
	OrderDate TIMESTAMP,
	OrderPrice DECIMAL(6,2),
	DeliveryOption TEXT,
	Products TEXT,
	Status TEXT,
	Distributor TEXT
);

COPY OrdersList(Customer, Email, Phone, Address, RegistrationDate, OrderDate, OrderPrice, DeliveryOption, Products, Status, Distributor)
FROM 'D:\Study\SQL\Course_work\Orders.csv' DELIMITER ',' CSV HEADER;

--SELECT * FROM OrdersList

CREATE TEMP TABLE IF NOT EXISTS ProductPrices(
	Distributor TEXT,
	Product TEXT,
	Price DECIMAL(6,2)
);

COPY ProductPrices(Distributor, Product, Price)
FROM 'D:\Study\SQL\Course_work\Product_Prices.csv' DELIMITER ',' CSV HEADER;

--SELECT * FROM ProductPrices

CREATE TEMP TABLE IF NOT EXISTS RepairsList(
	Customer TEXT,
	Email TEXT,
	OrderRepairDate TIMESTAMP,
	RepairPrice DECIMAL(6,2),
	Status TEXT,
	Repairs TEXT,
	RepairStart TIMESTAMP
);

COPY RepairsList(Customer, Email, OrderRepairDate, RepairPrice, Status, Repairs, RepairStart)
FROM 'D:\Study\SQL\Course_work\Repairs.csv' DELIMITER ',' CSV HEADER;

--SELECT * FROM RepairsList

CREATE TEMP TABLE IF NOT EXISTS FixPrices(
	Fix TEXT,
	Price DECIMAL(6,2)
);

COPY FixPrices(Fix, Price)
FROM 'D:\Study\SQL\Course_work\Fix_prices.csv' DELIMITER ',' CSV HEADER;

--SELECT * FROM FixPrice

WITH TempStatus AS (
	SELECT DISTINCT Status AS StatusName
	FROM OrdersList
	LEFT JOIN shop_oltp.Status ON shop_oltp.Status.status_name = Status
	WHERE shop_oltp.Status.status_id IS NULL
)
INSERT INTO shop_oltp.Status(status_name)
SELECT StatusName
FROM TempStatus;

--SELECT * FROM shop_oltp.Status;

WITH TempCity AS (
  SELECT DISTINCT 
    TRIM(SPLIT_PART(Address, ',', 2)) AS CityName,
	TRIM(SPLIT_PART(Address, ',', 3)) AS Subregion
  FROM OrdersList
  LEFT JOIN shop_oltp.City ON shop_oltp.City.city_name = TRIM(SPLIT_PART(Address, ',', 2))
	AND shop_oltp.City.subregion = TRIM(SPLIT_PART(Address, ',', 3))
  WHERE shop_oltp.City.city_id IS NULL
)
INSERT INTO shop_oltp.City (city_name, subregion)
SELECT CityName, Subregion
FROM TempCity;

--SELECT * FROM shop_oltp.City;

WITH TempAddress AS (
	SELECT DISTINCT 
	  TRIM(SPLIT_PART(Address, ',', 1)) AS Street,
	  (SELECT city_id FROM shop_oltp.City WHERE city_name = TRIM(SPLIT_PART(Address, ',', 2)) LIMIT 1) AS CityID,
	  TRIM(SPLIT_PART(Address, ',', 4)) AS Country
	FROM OrdersList
	LEFT JOIN shop_oltp.Address ON shop_oltp.Address.street = SPLIT_PART(Address, ',', 1)
	  AND shop_oltp.Address.city_id = (SELECT city_id FROM shop_oltp.City WHERE city_name = SPLIT_PART(Address, ',', 2)
		AND subregion = TRIM(SPLIT_PART(Address, ',', 3)) LIMIT 1)
	WHERE shop_oltp.Address.address_id IS NULL
)
INSERT INTO shop_oltp.Address(city_id, country, street)
SELECT CityID, Country, Street
FROM TempAddress;

--SELECT * FROM shop_oltp.Address;

WITH TempCustomer AS (
	SELECT DISTINCT
	  TRIM(SPLIT_PART(Customer, ' ', 1)) AS FirstName,
	  TRIM(SPLIT_PART(Customer, ' ', 2)) AS LastName,
	  OrdersList.Email,
	  OrdersList.Phone,
	  OrdersList.RegistrationDate,
	  (SELECT address_id FROM shop_oltp.Address WHERE street = TRIM(SPLIT_PART(Address, ',', 1))
	  AND city_id = (SELECT city_id FROM shop_oltp.City WHERE city_name = TRIM(SPLIT_PART(Address, ',', 2))
		AND subregion = TRIM(SPLIT_PART(Address, ',', 3)) LIMIT 1) LIMIT 1) AS AddressID
	FROM OrdersList
	LEFT JOIN shop_oltp.Customers ON CONCAT(shop_oltp.Customers.first_name, ' ', shop_oltp.Customers.last_name) = customer
)
INSERT INTO shop_oltp.Customers(first_name, last_name, email, phone_number, address_id, creation_date)
SELECT FirstName, LastName, Email, Phone, AddressID, RegistrationDate
FROM TempCustomer
ON CONFLICT (email) 
DO UPDATE SET
	first_name = EXCLUDED.first_name,
	last_name = EXCLUDED.last_name,
	phone_number = EXCLUDED.phone_number,
	address_id = EXCLUDED.address_id
WHERE
	shop_oltp.Customers.first_name <> EXCLUDED.first_name OR
  	shop_oltp.Customers.last_name <> EXCLUDED.last_name OR
  	shop_oltp.Customers.phone_number <> EXCLUDED.phone_number OR
  	shop_oltp.Customers.address_id <>EXCLUDED.address_id;


--SELECT * FROM shop_oltp.Customers;

WITH TempDistributor AS (
	SELECT DISTINCT Distributor
	FROM OrdersList
	LEFT JOIN shop_oltp.Distributor ON shop_oltp.Distributor.distributor_name = Distributor
	WHERE shop_oltp.Distributor.distributor_id IS NULL
)
INSERT INTO shop_oltp.Distributor(distributor_name)
SELECT Distributor
FROM TempDistributor;

--SELECT * FROM shop_oltp.Distributor;

WITH TempProducts AS (
	SELECT DISTINCT TRIM(unnest(string_to_array(Products, ','))) AS product_name
    FROM OrdersList
)
INSERT INTO shop_oltp.Products (product_name, product_description)
SELECT product_name, 'Will be added in future...'
FROM TempProducts
ON CONFLICT(product_name)
DO UPDATE SET
	product_description = EXCLUDED.product_description
WHERE
	shop_oltp.Products.product_description <> EXCLUDED.product_description;

--SELECT * FROM shop_oltp.Products;

WITH TempOrders AS (
	SELECT DISTINCT
		(SELECT customer_id FROM shop_oltp.Customers WHERE first_name = SPLIT_PART(Customer, ' ', 1) AND last_name = SPLIT_PART(Customer, ' ', 2) LIMIT 1) AS CustomerID,
		OrdersList.OrderPrice,
		OrdersList.OrderDate,
		(SELECT status_id FROM shop_oltp.Status WHERE status_name = Status LIMIT 1) AS StatusID,
		OrdersList.DeliveryOption
	FROM OrdersList
	LEFT JOIN shop_oltp.Orders ON shop_oltp.Orders.order_date = OrderDate
		AND shop_oltp.Orders.customer_id = (SELECT customer_id FROM shop_oltp.Customers WHERE first_name = SPLIT_PART(Customer, ' ', 1) AND last_name = SPLIT_PART(Customer, ' ', 2) LIMIT 1)
	WHERE shop_oltp.Orders.order_id IS NULL
)
INSERT INTO shop_oltp.Orders(customer_id, total_price, order_date, status_id, delivery_option)
SELECT CustomerID, OrderPrice, OrderDate, StatusID, DeliveryOption
FROM TempOrders
ON CONFLICT(customer_id, order_date)
DO UPDATE SET
	total_price = EXCLUDED.total_price,
	status_id = EXCLUDED.status_id,
	delivery_option = EXCLUDED.delivery_option
WHERE
	shop_oltp.Orders.total_price <> EXCLUDED.total_price OR
  	shop_oltp.Orders.status_id <> EXCLUDED.status_id OR
  	shop_oltp.Orders.delivery_option <> EXCLUDED.delivery_option;

--SELECT * FROM shop_oltp.Orders;
	
WITH TempOrdersDetails AS (
    SELECT DISTINCT
        o.order_id AS OrderID,
        TRIM(product) AS ProductName,
		OrdersList.Distributor,
		COUNT(*) OVER (PARTITION BY o.order_id, TRIM(product)) AS ProductQuantity
    FROM OrdersList
	JOIN shop_oltp.Orders o ON o.order_date = OrdersList.OrderDate,
    LATERAL unnest(STRING_TO_ARRAY(OrdersList.Products, ',')) AS product
)
INSERT INTO shop_oltp.Order_Details(order_id, distributor_id, product_id, quantity, product_price)
SELECT OrderID, d.distributor_id, pr.product_id, od.ProductQuantity, pp.Price 
FROM TempOrdersDetails od
LEFT JOIN shop_oltp.Products pr ON od.ProductName = pr.product_name
LEFT JOIN shop_oltp.Distributor d ON od.Distributor = d.distributor_name
LEFT JOIN ProductPrices pp ON (od.ProductName = TRIM(pp.Product) AND od.Distributor = TRIM(pp.Distributor))
ORDER BY OrderID
ON CONFLICT(order_id, distributor_id, product_id)
DO UPDATE SET
    quantity = EXCLUDED.quantity,
    product_price = EXCLUDED.product_price
WHERE
	shop_oltp.Order_Details.quantity <> EXCLUDED.quantity OR
	shop_oltp.Order_Details.product_price <> EXCLUDED.quantity;

DROP TABLE ProductPrices;
DROP TABLE OrdersList;

--SELECT * FROM shop_oltp.Order_Details

WITH TempFixes AS (
	SELECT DISTINCT TRIM(unnest(string_to_array(Repairs, ','))) AS repair_name
    FROM RepairsList
)
INSERT INTO shop_oltp.Fix (fix_name, fix_description, fix_price)
SELECT tf.repair_name, 'Will be added in future...', fp.Price
FROM TempFixes tf
LEFT JOIN FixPrices fp ON fp.Fix = tf.repair_name
ON CONFLICT(fix_name)
DO UPDATE SET
    fix_description = EXCLUDED.fix_description,
	fix_price = EXCLUDED.fix_price
WHERE
	shop_oltp.Fix.fix_description <> EXCLUDED.fix_description OR
	shop_oltp.Fix.fix_price <> EXCLUDED.fix_price;

--SELECT * FROM shop_oltp.Fix;

DROP TABLE FixPrices;

WITH TempStatus AS(
	SELECT DISTINCT Status AS StatusName
	FROM RepairsList
	LEFT JOIN shop_oltp.Status ON shop_oltp.Status.status_name = Status
	WHERE shop_oltp.Status.status_id IS NULL
)
INSERT INTO shop_oltp.Status(status_name)
SELECT StatusName
FROM TempStatus;

--SELECT * FROM shop_oltp.Status;

WITH TempOrderOfRepairs AS (
	SELECT DISTINCT
		(SELECT customer_id FROM shop_oltp.Customers WHERE first_name = SPLIT_PART(Customer, ' ', 1) AND last_name = SPLIT_PART(Customer, ' ', 2) LIMIT 1) AS CustomerID,
		RepairsList.RepairPrice,
		(SELECT status_id FROM shop_oltp.Status WHERE status_name = Status LIMIT 1) AS StatusID,
		RepairsList.OrderRepairDate
	FROM RepairsList
	LEFT JOIN shop_oltp.Order_Of_Repairs ON shop_oltp.Order_Of_Repairs.order_of_repair_date = OrderRepairDate
		AND shop_oltp.Order_Of_Repairs.customer_id = (SELECT customer_id FROM shop_oltp.Customers WHERE first_name = SPLIT_PART(Customer, ' ', 1)
		AND last_name = SPLIT_PART(Customer, ' ', 2) LIMIT 1)
)
INSERT INTO shop_oltp.Order_Of_Repairs(customer_id, repairs_total_price, status_id, order_of_repair_date)
SELECT CustomerID, RepairPrice, StatusID, OrderRepairDate
FROM TempOrderOfRepairs
ON CONFLICT(customer_id, order_of_repair_date)
DO UPDATE SET
  	repairs_total_price = EXCLUDED.repairs_total_price,
	status_id = EXCLUDED.status_id
WHERE
	shop_oltp.Order_Of_Repairs.repairs_total_price <> EXCLUDED.repairs_total_price OR
	shop_oltp.Order_Of_Repairs.status_id <> EXCLUDED.status_id;

--SELECT * FROM shop_oltp.Order_Of_Repairs;

WITH TempRepairDetails AS (
    SELECT DISTINCT
        (SELECT order_of_repairs_id 
         FROM shop_oltp.Order_Of_Repairs 
         WHERE order_of_repair_date = RepairsList.OrderRepairDate) AS OrderID,
        TRIM(FIX) AS Repair_name,
        RepairsList.RepairStart
    FROM RepairsList,
    LATERAL unnest(STRING_TO_ARRAY(RepairsList.Repairs, ',')) AS FIX
)
INSERT INTO shop_oltp.Repair_Details(repair_id, fix_id, start_date)
SELECT OrderID, f.fix_id, RepairStart
FROM TempRepairDetails rd
LEFT JOIN shop_oltp.Fix f ON rd.Repair_name = f.fix_name
ON CONFLICT(repair_id, fix_id)
DO UPDATE SET
	start_date = EXCLUDED.start_date
WHERE
	shop_oltp.Repair_Details.start_date <> EXCLUDED.start_date;

--SELECT * FROM shop_oltp.Repair_Details;

DROP TABLE RepairsList;