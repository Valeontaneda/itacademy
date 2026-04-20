/*
Nivel 1
Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
al menos 4 tablas de las que puedas realizar las siguientes consultas:
*/

CREATE DATABASE IF NOT EXISTS ecommerce;

USE ecommerce;

-- Creo las tablas que necesito para el nivel 1

CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255),
    card_id VARCHAR(255),
    company_id VARCHAR(255),
    `timestamp` VARCHAR(255),
    amount VARCHAR(255),
    declined VARCHAR(255),
    product_ids VARCHAR(255),
    user_id VARCHAR(255),
    lat VARCHAR(255),
    longitude VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255),
    `name` VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255),
    region VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(255),
    user_id VARCHAR(255),
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin VARCHAR(255),
    cvv VARCHAR(255),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS companies (
    id VARCHAR(255),
    company_name VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    country VARCHAR(255),
    website VARCHAR(255)
);

-- Reviso ruta donde puedo guardar los cvs 
SHOW VARIABLES LIKE 'secure_file_priv';

-- Cargo archivos cvs

LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/transactions.csv'
INTO TABLE transactions 
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/european_users.csv'
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, `name`, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
	region = 'Europe';

LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/american_users.csv'
INTO TABLE users  
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, `name`, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
	region = 'America';

LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/credit_cards.csv'
INTO TABLE credit_cards 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,user_id,iban,pan,pin,cvv,track1,track2,@expiring_date)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/companies.csv'
INTO TABLE companies 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Reviso datos en users, hago los cambios necesarios a las columnas y verifico cambios
SELECT *
FROM users;

ALTER TABLE users
MODIFY COLUMN id INT,
MODIFY COLUMN phone VARCHAR(20),
MODIFY COLUMN email VARCHAR(100),
MODIFY COLUMN birth_date DATE,
MODIFY COLUMN country VARCHAR(100),
MODIFY COLUMN city VARCHAR(100),
MODIFY COLUMN postal_code VARCHAR(15),
ADD PRIMARY KEY (id);

DESC users;

-- Reviso datos en credit_cards, hago los cambios necesarios a las columnas y verifico cambios
SELECT * 
FROM credit_cards;

ALTER TABLE credit_cards
MODIFY COLUMN id VARCHAR(15),
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN pan VARCHAR(25),
MODIFY COLUMN pin CHAR(4),
MODIFY COLUMN cvv CHAR(4),
MODIFY COLUMN expiring_date DATE,
DROP COLUMN user_id,
ADD PRIMARY KEY (id);

DESC credit_cards;

-- Reviso datos en companies, hago los cambios necesarios a las columnas y verifico cambios

SELECT *
FROM companies;

ALTER TABLE companies
MODIFY COLUMN id VARCHAR(15),
MODIFY COLUMN phone VARCHAR(20),
MODIFY COLUMN email VARCHAR(100),
MODIFY COLUMN country VARCHAR(100),
ADD PRIMARY KEY (id);

DESC companies;

-- Reviso datos en transactions, hago los cambios necesarios a las columnas y verifico cambios
SELECT *
FROM transactions;

ALTER TABLE transactions
MODIFY COLUMN card_id VARCHAR(15),
MODIFY COLUMN company_id VARCHAR(15),
MODIFY COLUMN `timestamp` TIMESTAMP,
MODIFY COLUMN amount DECIMAL(10, 2),
MODIFY COLUMN declined BOOLEAN,
MODIFY COLUMN product_ids VARCHAR(100),
MODIFY COLUMN user_id INT,
MODIFY COLUMN lat FLOAT,
MODIFY COLUMN longitude FLOAT,
ADD PRIMARY KEY (id),
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id),
ADD CONSTRAINT fk_credit_card_id FOREIGN KEY (card_id) REFERENCES credit_cards (id),
ADD CONSTRAINT fk_company_id FOREIGN KEY (company_id) REFERENCES companies (id);

DESC transactions;

-- Verifico los foreign keys
SELECT 
    `table_name`, 
    `column_name`, 
    `constraint_name`, 
    referenced_table_name, 
    referenced_column_name 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE table_name = 'transactions';

/*
Ejercicio 1
Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.
*/

SELECT *
FROM users AS u
WHERE EXISTS (
	SELECT user_id
	FROM transactions AS t
    WHERE u.id = t.user_id
    AND declined = 0
	GROUP BY user_id
	HAVING COUNT(t.id) > 80);

/*
Ejercicio 2
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.
*/

-- Saco el id de la compañía Donec Ltd.
SELECT *
FROM companies
WHERE company_name LIKE 'Donec%';

-- Join para sacar media
SELECT cc.iban, ROUND(AVG(t.amount), 2) AS avg_sales
FROM transactions AS t
JOIN credit_cards AS cc
ON t.card_id = cc.id
JOIN companies AS c
ON t.company_id = c.id
WHERE c.id = 'b-2242'
AND declined = 0
GROUP BY cc.iban;

/*
Nivel 2
Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones 
han sido declinadas entonces es inactivo, si al menos una no es rechazada entonces es activo. 
*/

CREATE TABLE IF NOT EXISTS card_status (
    card_id VARCHAR(15),
    card_status VARCHAR(10),
    PRIMARY KEY (card_id)
)
WITH card_list AS(
SELECT 
	*,
	SUM(declined) OVER (PARTITION BY card_id ORDER BY `timestamp` DESC) AS `sum`,
	ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY `timestamp`DESC) AS `rank`
FROM transactions)
SELECT 
	card_id,
	CASE 
		WHEN `sum` = 3 THEN 'Inactive'
		ELSE 'Active'
	END AS card_status
FROM card_list
WHERE `rank` = 3;

DESC card_status;


/*
Ejercicio 1
¿Cuántas tarjetas están activas?
*/

SELECT COUNT(*) AS active_count
FROM card_status
WHERE card_status = 'Active';

/*
Nivel 3
Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
*/

-- Creo la tabla de productos
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(255) PRIMARY KEY,
    product_name VARCHAR(255),
    price VARCHAR(255),
    colour VARCHAR(255),
    weight VARCHAR(255),
    warehouse_id VARCHAR(255));
    
-- Cargo archivo CSV de productos
LOAD DATA
INFILE '/Users/valeriaontaneda/mysql_imports/products.csv'
INTO TABLE products 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,@price,colour,weight,warehouse_id)
SET price = SUBSTRING(@price, 2);

-- Verifico la nueva tabla y el cambio
SELECT * 
FROM products;

-- Modifico el tipo de datos en los campos de la tabla products
ALTER TABLE products
MODIFY COLUMN id INT,
MODIFY COLUMN price DECIMAL(10,2),
MODIFY COLUMN weight DECIMAL(5,1),
MODIFY COLUMN warehouse_id VARCHAR(15);

-- Verifico los cambios
DESC products;

-- Formateo product_ids para despues cambiar tipo de data a JSON
UPDATE transactions
SET product_ids = CONCAT('["', REPLACE(product_ids,',', '","'),'"]')
WHERE product_ids IS NOT NULL
LIMIT 1000000;

-- Cambio tipo de dato de product_ids de VARCHAR a JSON
ALTER TABLE transactions
MODIFY COLUMN product_ids JSON;

-- Verifico los cambios
SELECT *
FROM transactions;

DESC transactions;

-- Creo una nueva tabla y uso la funcion JSON_TABLE para expandir los product_ids en diferentes filas

CREATE TABLE IF NOT EXISTS transactions_products(
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(255),
    product_id INT
)
SELECT 
	t.id AS transaction_id,
	jt.product_id AS product_id
FROM 
	transactions AS t,
	JSON_TABLE(
		t.product_ids,
		'$[*]' COLUMNS(
				product_id INT PATH '$'
            )
	) AS jt;
    
-- verifico nuevo tabla
SELECT *
FROM transactions_products;

DESC transactions_products;

-- Agrego el foregin key en tabla transactions_products
ALTER TABLE transactions_products
ADD CONSTRAINT fk_transaction_id
FOREIGN KEY (transaction_id)
REFERENCES transactions (id),
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id)
REFERENCES products (id);

-- Verifico los foreign keys
SELECT 
    `table_name`, 
    `column_name`, 
    `constraint_name`, 
    referenced_table_name, 
    referenced_column_name 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE table_name = 'transactions_products';

/*
Ejercicio 1
Necesitamos conocer el número de veces que se ha vendido cada producto.
*/

SELECT tp.product_id, p.product_name, count(*) as product_count
FROM transactions_products AS tp
JOIN transactions AS t
ON tp.transaction_id = t.id
JOIN products AS p
ON tp.product_id = p.id
WHERE t.declined = 0
GROUP BY tp.product_id, p.product_name
ORDER BY product_count DESC;

