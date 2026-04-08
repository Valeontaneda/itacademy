USE transactions;
/*
NIVEL 1 
Ejercicio 1
Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit". 
Recuerda mostrar el diagrama y realizar una breve descripción del mismo.
*/

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY, 
    iban VARCHAR(50), 
    pan VARCHAR(25), 
    pin CHAR(4), 
    cvv CHAR(4), 
    expiring_date VARCHAR(10)
);

-- Agrego informacion en la tabla de credit_card utilizando el archivo en la tarea. Estoy utilizando otro archivo para no tener todo el codigo aqui

-- Normalizo la fecha con WHERE y LIMIT
UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE expiring_date IS NOT NULL
LIMIT 100000;

-- Cambio data type a DATE
ALTER TABLE credit_card
MODIFY COLUMN expiring_date DATE;

-- Verifico que se haya hecho el cambio
SELECT *
FROM credit_card
LIMIT 200;

DESC credit_card;

-- Seteo el Foreign key de credit_card_id en transaction
ALTER TABLE `transaction`
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card (id);

-- Verifico que el foreign key se haya seteado correctamente
SELECT 
    `table_name`, 
    `column_name`, 
    `constraint_name`, 
    referenced_table_name, 
    referenced_column_name 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE referenced_table_schema = 'transactions' 
AND referenced_table_name = 'credit_card'; 


/*
Ejercicio 2
El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
*/

-- Hago el cambio del iban en el registro especifico
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- Reviso cambio de iban
SELECT *
FROM credit_card
WHERE id = 'CcU-2938'; 

/*
Ejercicio 3
En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lato	829.999
longitud	-117.999
amunt	111.11
declined	0
*/

-- Reviso si existe la tarjeta de credito y compania 
SELECT *
FROM credit_card
WHERE id = 'CcU-9999';

SELECT * 
FROM company
WHERE id = 'b-9999';

-- Cambio el timestamp para que tenga el CURRENT_TIMESTAMP como default
ALTER TABLE `transaction`
MODIFY COLUMN timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

DESC `transaction`;

-- Agrego el registro en la tabla credit card solo con el id
INSERT INTO credit_card (id)
VALUES ('CcU-9999')
ON DUPLICATE KEY UPDATE id = 'CcU-9999';

SELECT *
FROM credit_card
WHERE id = 'CcU-9999';

-- Agrego el registro en la tabla company solo con el id

INSERT INTO company (id)
VALUES ('b-9999')
ON DUPLICATE KEY UPDATE id = 'b-9999';

SELECT *
FROM company
WHERE id = 'b-9999';

-- Agrego la nueva transaccion
INSERT INTO `transaction` (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0)
ON DUPLICATE KEY UPDATE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

SELECT *
FROM `transaction`
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


/*
Ejericio 4
Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.
*/

ALTER TABLE credit_card     
DROP COLUMN  pan; 

DESCRIBE credit_card;

/*
NIVEL 2
Ejercicio 1
Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.
*/

DELETE FROM `transaction`
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM `transaction`
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

/*
Ejercicio 2
La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 
Nombre de la compañía. 
Teléfono de contacto. 
País de residencia. 
Media de compra realizado por cada compañía. 
Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.
*/

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount), 2) AS avg_sales
FROM company AS c
JOIN `transaction` AS t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name, c.phone, c.country
ORDER BY AVG(t.amount) DESC;

-- Verifico creacion de la vista 

SELECT *
FROM VistaMarketing;

/*
Ejercicio 3
Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"
*/

SELECT *
FROM VistaMarketing
WHERE country = 'Germany';

/*
Nivel 3
Ejercicio 1
La próxima semana tendrás una nueva reunión con los gerentes de marketing. 
Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó. 
Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:
*/

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	`name` VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- Reviso nueva tabla user 
DESC `user`;

-- Ingreso informacion de user del script de moodle y verifico tabla
SELECT *
FROM `user`
LIMIT 20;

-- Cambio nombre de tabla a data_user
RENAME TABLE `user` to data_user;

-- Cambio el id de la tabla user a INT
ALTER TABLE data_user
MODIFY COLUMN id INT;

-- Cambio campo email a personal_email
ALTER TABLE data_user    
RENAME COLUMN email TO personal_email; 

-- Verifico los cambios en tabla user
DESC data_user;

-- Reviso que registro falta en la tabla user y por ende no se puede hacer lo del foreign key
SELECT t.user_id
FROM `transaction` AS t
WHERE NOT EXISTS (
	SELECT u.id
    FROM data_user AS u
    WHERE t.user_id = u.id
);

-- Creo el registro faltante en la tabla data_user
INSERT INTO data_user (id)
VALUES ('9999');

-- Seteo el Foreign key de user_id en transaction
ALTER TABLE `transaction`
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES data_user (id);

-- Verifico que el foreign key se haya seteado correctamente
SELECT 
    `table_name`, 
    `column_name`, 
    `constraint_name`, 
    referenced_table_name, 
    referenced_column_name 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE referenced_table_schema = 'transactions' 
AND referenced_table_name = 'data_user'; 

-- Cambio en tabla company

-- Elimino el campo website de company
ALTER TABLE company
DROP COLUMN website;

-- Verifico cambios en tabla company
DESC company;

-- Cambio en tabla transaction

-- Cambio el credit_card_id a VARCHAR(20)
ALTER TABLE `transaction`
MODIFY COLUMN credit_card_id VARCHAR(20);

-- Verifico cambios en tabla transaction
DESC `transaction`;

-- Cambios en tabla credit_card

-- Cambio el credit_card_id a VARCHAR(20)
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);

-- Cambio el pin a VARCHAR(4)
ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

-- Cambio cvv a INT
ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

-- Cambio expiring_date a VARCHAR(20)
ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(20);

-- Agrego fecha_actual como DATE
ALTER TABLE credit_card
ADD fecha_actual DATE;

-- Verifico cambios en tabla credit_card
DESC credit_card;

/*
Ejercicio 2
La empresa también le pide crear una vista llamada "InformeTecnico" que contenga la siguiente información:

ID de l
Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.
Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.
*/
-- Creo la view con los campos solicitados y los relevantes

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT 
	t.id AS transaction_id, 
    t.`timestamp`, 
    t.amount, 
    t.declined, 
    u.`name` AS user_name, 
    u.surname AS user_surname, 
    cc.iban, 
    cc.expiring_date, 
    c.company_name, 
    c.phone AS company_phone,
    c.email AS company_email,
    c.country AS company_country
FROM `transaction` AS t
JOIN data_user AS u
ON t.user_id = u.id
JOIN credit_card AS cc
ON t.credit_card_id = cc.id
JOIN company AS c
ON t.company_id = c.id;

-- Visualizo la informacion de la vista ordenando de mayor a menor segun el transaction_id
SELECT *
FROM InformeTecnico
ORDER BY transaction_id DESC;
