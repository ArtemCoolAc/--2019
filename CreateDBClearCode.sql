CREATE TABLE pastry( --корректно
ID_pastry SERIAL UNIQUE,
Rent_price NUMERIC(5,0) NOT NULL CHECK ( Rent_price > 0 ),
Start_hours TIME WITHOUT TIME ZONE NOT NULL,
Finish_hours TIME WITHOUT TIME ZONE NOT NULL,
Address VARCHAR(50) NOT NULL UNIQUE,
PRIMARY KEY (ID_pastry)
);

CREATE TABLE production( --корректно
ID_production SERIAL UNIQUE,
Production_name VARCHAR(30) NOT NULL UNIQUE,
Production_shelf_life INTERVAL,
type_prod INTEGER NOT NULL CHECK ( type_prod BETWEEN 1 AND 2),
PRIMARY KEY (ID_production)
);

CREATE TABLE unit( --корректно
ID_production INTEGER NOT NULL UNIQUE,
cost_value NUMERIC(6,2) NOT NULL CHECK ( cost_value > 0 ),
availability INTEGER NOT NULL CHECK ( availability >= 0 ),
PRIMARY KEY (ID_production),
FOREIGN KEY (ID_production) REFERENCES production(ID_production) ON DELETE RESTRICT
);

CREATE TABLE ingredient( --корректно
ID_production INTEGER NOT NULL UNIQUE,
ID_type INTEGER NOT NULL UNIQUE,
ID_base_type INTEGER NOT NULL,
weight NUMERIC(5,3) NOT NULL CHECK ( weight > 0 ),
calorie INTEGER NOT NULL CHECK ( calorie > 0 ),
mass_availability NUMERIC(6,3) NOT NULL CHECK ( mass_availability >= 0 ),
pieces_availability INTEGER NOT NULL CHECK ( pieces_availability >= 0 ),
day_consumption INTEGER NOT NULL CHECK ( day_consumption >= 0 ),
PRIMARY KEY (ID_type, ID_production),
FOREIGN KEY (ID_production) REFERENCES production(ID_production) ON DELETE RESTRICT,
FOREIGN KEY (ID_base_type) REFERENCES ingredient(ID_type) ON DELETE CASCADE
);


CREATE TABLE recipe_string( --корректно
ID_string SERIAL UNIQUE,
ID_production INTEGER NOT NULL,
ID_type INTEGER NOT NULL,
pieces_quantity INTEGER NOT NULL CHECK ( pieces_quantity >= 0 ),
mass_quantity NUMERIC(6,3) NOT NULL CHECK ( mass_quantity >= 0 ),
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_production) REFERENCES unit(ID_production) ON DELETE RESTRICT,
FOREIGN KEY (ID_type) REFERENCES ingredient(ID_type) ON DELETE RESTRICT
);

CREATE TABLE pastry_production( --корректно
ID_number SERIAL UNIQUE,
ID_pastry INTEGER NOT NULL,
ID_production INTEGER NOT NULL,
PRIMARY KEY (ID_number),
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT,
FOREIGN KEY (ID_production) REFERENCES production(ID_production) ON DELETE RESTRICT
);

CREATE TABLE price_list( --корректно
ID_price SERIAL UNIQUE,
ID_pastry INTEGER NOT NULL,
price_list_time_start TIME WITHOUT TIME ZONE,
price_list_time_finish TIME WITHOUT TIME ZONE,
issue_date TIMESTAMP WITHOUT TIME ZONE,
price_type INTEGER NOT NULL,
PRIMARY KEY (ID_price),
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT
);

CREATE TABLE price_list_string( --корректно
ID_string SERIAL UNIQUE,
ID_pastry INTEGER NOT NULL,
ID_price INTEGER NOT NULL,
ID_production INTEGER NOT NULL,
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT,
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT,
FOREIGN KEY (ID_production) REFERENCES production(ID_production) ON DELETE RESTRICT
);

CREATE TABLE unit_in_concrete_price_list( --корректно
ID_number SERIAL UNIQUE,
ID_price INTEGER NOT NULL UNIQUE,
ID_production INTEGER NOT NULL UNIQUE,
PRIMARY KEY (ID_number),
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT,
FOREIGN KEY (ID_production) REFERENCES unit(ID_production) ON DELETE RESTRICT
);

CREATE TABLE kitchenware (
ID_device SERIAL UNIQUE,
device_name VARCHAR(30) NOT NULL UNIQUE,
description VARCHAR(100) NULL,
PRIMARY KEY (ID_device)
);

CREATE TABLE kitchenware_in_pastries( --корректно
ID_string SERIAL UNIQUE,
ID_pastry INTEGER NOT NULL,
ID_device INTEGER NOT NULL,
device_quantity INTEGER NOT NULL CHECK ( device_quantity >= 0 ),
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_device) REFERENCES kitchenware(ID_device) ON DELETE RESTRICT,
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT
);

CREATE TABLE shop( --корректно
ID_shop SERIAL UNIQUE,
shop_name VARCHAR(20) NOT NULL UNIQUE,
shop_address VARCHAR(50) NOT NULL UNIQUE,
PRIMARY KEY (ID_shop)
);

CREATE TABLE shop_price_list_string( --корректно
ID_string SERIAL UNIQUE,
ID_device INTEGER NULL,
ID_production INTEGER NULL,
ID_type INTEGER NULL,
ID_shop INTEGER NOT NULL,
good_cost NUMERIC(5,2) NOT NULL CHECK ( good_cost >= 0 ),
good_availability INTEGER NOT NULL CHECK ( good_availability >= 0 ),
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_device) REFERENCES kitchenware(ID_device) ON DELETE RESTRICT,
FOREIGN KEY (ID_production) REFERENCES ingredient(ID_production) ON DELETE RESTRICT,
FOREIGN KEY (ID_type) REFERENCES ingredient(ID_type) ON DELETE CASCADE,
FOREIGN KEY (ID_shop) REFERENCES shop(ID_shop) ON DELETE RESTRICT
);

CREATE TABLE schedule( --корректно
ID_schedule SERIAL UNIQUE,
ID_pastry INTEGER NOT NULL,
work_start_hours TIME WITHOUT TIME ZONE NOT NULL,
work_finish_hours TIME WITHOUT TIME ZONE NOT NULL,
lunch_start_hours TIME WITHOUT TIME ZONE NOT NULL,
lunch_finish_hours TIME WITHOUT TIME ZONE NOT NULL,
PRIMARY KEY (ID_schedule),
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT
);

CREATE TABLE employee_type(
ID_type SERIAL UNIQUE,
name VARCHAR(30) UNIQUE,
PRIMARY KEY (ID_type)
);

CREATE TABLE employee( --корректно
ID_number SERIAL UNIQUE,
ID_type INTEGER NOT NULL CHECK ( ID_type BETWEEN 1 AND 4),
FIO VARCHAR(100) NOT NULL,
Passport_data VARCHAR(30) NOT NULL UNIQUE,
ID_pastry INTEGER NOT NULL,
month_salary NUMERIC(8,2) NOT NULL CHECK ( month_salary > 0 ),
min_work_hours INTEGER NOT NULL CHECK ( min_work_hours >= 0 ),
PRIMARY KEY (ID_number),
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT,
FOREIGN KEY (ID_type) REFERENCES employee_type(ID_type) ON DELETE RESTRICT
);

CREATE TABLE employee_schedule( --корректно
ID_number SERIAL UNIQUE,
ID_employee INTEGER NOT NULL,
ID_schedule INTEGER NOT NULL,
PRIMARY KEY (ID_number),
FOREIGN KEY (ID_employee) REFERENCES employee(ID_number) ON DELETE RESTRICT,
FOREIGN KEY (ID_schedule) REFERENCES schedule(ID_schedule) ON DELETE RESTRICT
);

CREATE TABLE customer( --корректно
ID_customer SERIAL UNIQUE,
Passport_data VARCHAR(30) NOT NULL UNIQUE,
FIO_customer VARCHAR(50) NOT NULL,
PRIMARY KEY (ID_customer)
);

CREATE TABLE invoice( --корректно
ID_invoice SERIAL UNIQUE,
ID_employee INTEGER NOT NULL,
ID_customer INTEGER NOT NULL,
destination_address VARCHAR(50) NOT NULL,
signature INTEGER NOT NULL,
claim_text VARCHAR(200) NULL,
return_mark VARCHAR(20) NULL,
PRIMARY KEY (ID_invoice),
FOREIGN KEY (ID_employee) REFERENCES employee(ID_number) ON DELETE RESTRICT,
FOREIGN KEY (ID_customer) REFERENCES customer(ID_customer) ON DELETE RESTRICT
);

CREATE TABLE ordering( --корректно
ID_order SERIAL UNIQUE,
ID_invoice INTEGER NOT NULL,
ID_price INTEGER NOT NULL,
ID_customer INTEGER NOT NULL,
ID_pastry INTEGER NOT NULL,
total_cost INTEGER NOT NULL CHECK ( total_cost >= 0 ),
date_order TIMESTAMP WITHOUT TIME ZONE NOT NULL,
PRIMARY KEY (ID_order),
FOREIGN KEY (ID_invoice) REFERENCES invoice(ID_invoice) ON DELETE RESTRICT,
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT,
FOREIGN KEY (ID_customer) REFERENCES customer(ID_customer) ON DELETE RESTRICT,
FOREIGN KEY (ID_pastry) REFERENCES pastry(ID_pastry) ON DELETE RESTRICT
);

CREATE TABLE string_order(
ID_string SERIAL UNIQUE,
ID_order INTEGER NOT NULL,
ID_production INTEGER NOT NULL,
ID_invoice INTEGER NOT NULL,
ID_price INTEGER NOT NULL,
quantity INTEGER NOT NULL CHECK ( quantity >= 1 ),
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_production) REFERENCES unit(ID_production) ON DELETE RESTRICT,
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT,
FOREIGN KEY (ID_invoice) REFERENCES invoice(ID_invoice) ON DELETE RESTRICT,
FOREIGN KEY (ID_order) REFERENCES ordering(ID_order) ON DELETE RESTRICT
);

CREATE TABLE order_exceptions(
ID_exception SERIAL UNIQUE,
ID_order INTEGER NOT NULL,
ID_invoice INTEGER NOT NULL,
ID_price INTEGER NOT NULL,
PRIMARY KEY (ID_exception),
FOREIGN KEY (ID_order) REFERENCES ordering(ID_order) ON DELETE RESTRICT,
FOREIGN KEY (ID_invoice) REFERENCES invoice(ID_invoice) ON DELETE RESTRICT,
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT
);

CREATE TABLE string_order_exception(
ID_string SERIAL UNIQUE,
ID_exception INTEGER NOT NULL,
ID_order INTEGER NOT NULL,
ID_invoice INTEGER NOT NULL,
ID_price INTEGER NOT NULL,
ID_production INTEGER NOT NULL,
quantity INTEGER NOT NULL CHECK ( quantity > 0 ),
PRIMARY KEY (ID_string),
FOREIGN KEY (ID_order) REFERENCES ordering(ID_order) ON DELETE RESTRICT,
FOREIGN KEY (ID_production) REFERENCES production(ID_production) ON DELETE RESTRICT,
FOREIGN KEY (ID_invoice) REFERENCES invoice(ID_invoice) ON DELETE RESTRICT,
FOREIGN KEY (ID_price) REFERENCES price_list(ID_price) ON DELETE RESTRICT,
FOREIGN KEY (ID_exception) REFERENCES order_exceptions(ID_exception) ON DELETE RESTRICT
);