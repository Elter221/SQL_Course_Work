--CREATE DATABASE oltp_db;

CREATE SCHEMA IF NOT EXISTS shop_oltp;

CREATE TABLE IF NOT EXISTS shop_oltp.Customers(
    customer_id SERIAL PRIMARY KEY NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone_number TEXT NOT NULL,
    address_id INT NOT NULL,
	creation_date TIMESTAMP NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.Products(
    product_id SERIAL PRIMARY KEY NOT NULL,
    product_name TEXT UNIQUE NOT NULL,
    product_description TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.Fix(
    fix_id SERIAL PRIMARY KEY NOT NULL,
    fix_name TEXT UNIQUE NOT NULL,
	fix_price DECIMAL(6,2) NOT NULL,
    fix_description TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.Distributor(
    distributor_id SERIAL PRIMARY KEY NOT NULL,
    distributor_name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.Orders(
    order_id SERIAL PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    total_price DECIMAL(6, 2) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status_id INT NOT NULL,
    delivery_option TEXT NOT NULL,
	CONSTRAINT unique_customer_order_date UNIQUE (order_date, customer_id)
);
CREATE TABLE IF NOT EXISTS shop_oltp.Order_Of_Repairs(
    order_of_repairs_id SERIAL PRIMARY KEY NOT NULL,
    customer_id INT NOT NULL,
    repairs_total_price DECIMAL(6, 2) NOT NULL,
    status_id INT NOT NULL,
    order_of_repair_date TIMESTAMP NOT NULL,
	CONSTRAINT unique_customer_repair_date UNIQUE (order_of_repair_date, customer_id)
);
CREATE TABLE IF NOT EXISTS shop_oltp.Repair_Details(
    repair_id INT NOT NULL,
	fix_id INT NOT NULL,
    start_date TIMESTAMP NOT NULL,
	PRIMARY KEY(repair_id, fix_id)
);
CREATE TABLE IF NOT EXISTS shop_oltp.Order_Details(
    order_id INT NOT NULL,
	distributor_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
	product_price DECIMAL(6, 2) NOT NULL,
	PRIMARY KEY(order_id, distributor_id, product_id)
);
CREATE TABLE IF NOT EXISTS shop_oltp.Address(
    address_id SERIAL PRIMARY KEY NOT NULL,
    city_id INT NOT NULL,
    country TEXT NOT NULL,
    street TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.City(
    city_id SERIAL PRIMARY KEY NOT NULL,
    city_name TEXT NOT NULL,
    subregion TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS shop_oltp.Status(
    status_id SERIAL PRIMARY KEY NOT NULL,
    status_name TEXT NOT NULL
);
ALTER TABLE
    shop_oltp.Repair_Details ADD CONSTRAINT repair_id_fk FOREIGN KEY (repair_id) REFERENCES shop_oltp.Order_Of_Repairs(order_of_repairs_id);
ALTER TABLE
    shop_oltp.Repair_Details ADD CONSTRAINT fix_id_fk FOREIGN KEY (fix_id) REFERENCES shop_oltp.Fix(fix_id);
ALTER TABLE
    shop_oltp.Address ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) REFERENCES shop_oltp.City(city_id);
ALTER TABLE
    shop_oltp.Orders ADD CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES shop_oltp.Customers(customer_id);
ALTER TABLE
    shop_oltp.Order_Of_Repairs ADD CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES shop_oltp.Customers(customer_id);
ALTER TABLE
    shop_oltp.Order_Details ADD CONSTRAINT order_id_fk FOREIGN KEY (order_id) REFERENCES shop_oltp.Orders(order_id);
ALTER TABLE
    shop_oltp.Order_Details ADD CONSTRAINT product_id_fk FOREIGN KEY (product_id) REFERENCES shop_oltp.Products(product_id);
ALTER TABLE
    shop_oltp.Order_Details ADD CONSTRAINT distributor_id_fk FOREIGN KEY (distributor_id) REFERENCES shop_oltp.Distributor(distributor_id);
ALTER TABLE
    shop_oltp.Order_Of_Repairs ADD CONSTRAINT status_id_fk FOREIGN KEY (status_id) REFERENCES shop_oltp.Status(status_id);
ALTER TABLE
    shop_oltp.Orders ADD CONSTRAINT status_id_fk FOREIGN KEY (status_id) REFERENCES shop_oltp.Status(status_id);
ALTER TABLE
    shop_oltp.Customers ADD CONSTRAINT address_id_fk FOREIGN KEY (address_id) REFERENCES shop_oltp.Address(address_id);