--CREATE DATABASE olap_db;

CREATE SCHEMA IF NOT EXISTS dwh;

CREATE TABLE IF NOT EXISTS dwh.DimTime (
    time_id SERIAL PRIMARY KEY NOT NULL,
    the_date DATE NOT NULL,
	date_day INT NOT NULL,
    date_month INT NOT NULL,
    quarter INT NOT NULL,
    date_year INT NOT NULL,
    week INT NOT NULL,
	date_time TIME NOT NULL,
	CONSTRAINT unique_date_time UNIQUE (the_date, date_time)
);

CREATE TABLE IF NOT EXISTS dwh.DimFix (
    fix_id INT NOT NULL,
    fix_name TEXT NOT NULL,
    fix_description TEXT,
	fix_price DECIMAL(6,2),
    PRIMARY KEY (fix_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimProduct (
    product_id INT NOT NULL,
    product_name TEXT NOT NULL,
    product_description TEXT,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimDistributor (
    distributor_id INT NOT NULL,
    distributor_name TEXT,
    PRIMARY KEY (distributor_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimStatus (
    status_id INT NOT NULL,
    status_name TEXT NOT NULL,
    PRIMARY KEY (status_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimCity (
    city_id INT NOT NULL,
    city_name TEXT NOT NULL,
    subregion TEXT NOT NULL,
    PRIMARY KEY (city_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimAddress (
    address_id INT NOT NULL,
    city_id INT NOT NULL,
    country TEXT NOT NULL,
    street TEXT NOT NULL,
    PRIMARY KEY (address_id),
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES dwh.DimCity(city_id)
);

CREATE TABLE IF NOT EXISTS dwh.DimCustomer (
	customer_surrogate_key SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    address_id INT NOT NULL,
    creation_time_id INT NOT NULL,
    expiration_time_id INT,
    active_flag BOOLEAN NOT NULL,
	CONSTRAINT fk_address FOREIGN KEY (address_id) REFERENCES dwh.DimAddress(address_id),
	CONSTRAINT fk_creation_time_id FOREIGN KEY (creation_time_id) REFERENCES dwh.DimTime(time_id),
	CONSTRAINT fk_expiration_time_id FOREIGN KEY (expiration_time_id) REFERENCES dwh.DimTime(time_id)
);

CREATE TABLE IF NOT EXISTS dwh.FactOrders (
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    distributor_id INT NOT NULL,
    order_time_id INT NOT NULL,
    total_price DECIMAL(6, 2) NOT NULL,
    quantity INT NOT NULL,
    product_price DECIMAL(6, 2) NOT NULL,
    delivery_option TEXT NOT NULL,
    status_id INT NOT NULL,
    PRIMARY KEY (order_id, product_id, distributor_id),
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES dwh.DimCustomer(customer_surrogate_key),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES dwh.DimProduct(product_id),
    CONSTRAINT fk_distributor_id FOREIGN KEY (distributor_id) REFERENCES dwh.DimDistributor(distributor_id),
    CONSTRAINT fk_order_time_id FOREIGN KEY (order_time_id) REFERENCES dwh.DimTime(time_id),
    CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES dwh.DimStatus(status_id)
);

CREATE TABLE IF NOT EXISTS dwh.FactRepairs (
    repair_id INT NOT NULL,
    customer_id INT NOT NULL,
	repair_order_time_id INT NOT NULL,
    fix_id INT NOT NULL,
    fix_start_time_id INT NOT NULL,
    repairs_total_price DECIMAL(6, 2) NOT NULL,
    status_id INT NOT NULL,
    PRIMARY KEY (repair_id, fix_id),
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES dwh.DimCustomer(customer_surrogate_key),
    CONSTRAINT fk_fix_id FOREIGN KEY (fix_id) REFERENCES dwh.DimFix(fix_id),
    CONSTRAINT fk_repair_order_time_id FOREIGN KEY (repair_order_time_id) REFERENCES dwh.DimTime(time_id),
	CONSTRAINT fk_fix_start_time_id FOREIGN KEY (fix_start_time_id) REFERENCES dwh.DimTime(time_id),
    CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES dwh.DimStatus(status_id)
);
