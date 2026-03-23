USE transactions;

-- TAREA S2.01
-- NIVEL 1
-- Ejercicio 2: Utilizando JOIN realizarás las siguientes consultas:
-- Listado de los países que están generando ventas.

SELECT DISTINCT country
FROM transaction
JOIN company
ON company_id = company.id;

-- Desde cuántos países se generan las ventas.

SELECT COUNT(DISTINCT country) AS num_countries
FROM transaction
JOIN company
ON company_id = company.id;

-- Identifica a la compañía con la mayor media de ventas.

-- Op 1: JOIN mas subquery para sacar el max de avg_sale. Funciona mejor si hay empates
SELECT company.id, company_name, ROUND(AVG(amount), 2) AS avg_sale
FROM transaction
JOIN company
ON company_id = company.id
GROUP BY company.id, company_name
HAVING avg_sale = (
	SELECT MAX(avg_sale) AS max_avg
    FROM (
		SELECT company.id, company_name, ROUND(AVG(amount), 2) AS avg_sale
		FROM transaction
		JOIN company
		ON company_id = company.id
		GROUP BY company.id, company_name
    ) list_avg_per_company
);

-- OP 2: solo JOIN utilizando el limit 1 para sacar el primero
SELECT company.id, company_name, ROUND(AVG(amount), 2) AS avg_sale
FROM transaction
JOIN company
ON company_id = company.id
GROUP BY company.id, company_name
ORDER BY avg_sale DESC
LIMIT 1;


-- Ejercicio 3: Utilizando sólo subconsultas (sin utilizar JOIN):
-- Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT *
FROM transaction
WHERE EXISTS (
	SELECT id
    FROM company
    WHERE company_id = company.id
    AND country = 'Germany'
);


-- Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT id, company_name
FROM company
WHERE EXISTS (
	SELECT DISTINCT company_id
	FROM transaction
    WHERE company_id = company.id
	AND amount > (
		SELECT ROUND(AVG (amount),2) AS avg_amount
		FROM transaction
	)
);

-- Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT id, company_name
FROM company
WHERE NOT EXISTS (
	SELECT DISTINCT company_id
	FROM transaction
    WHERE company_id = company.id
);


-- NIVEL 2

-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
-- Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(timestamp) AS date, SUM(amount) AS total_sales
FROM transaction
GROUP BY DATE(timestamp)
ORDER BY total_sales DESC
LIMIT 5;

-- Ejercicio 2
-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT country, ROUND(AVG(amount),2) AS avg_sales
FROM transaction
JOIN company 
ON company_id = company.id
GROUP BY country
ORDER BY avg_sales DESC;

-- Ejercicio 3
-- En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
-- Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.
-- Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM transaction
JOIN company 
ON company_id = company.id
WHERE country = (
	SELECT country
    FROM company
    WHERE id = 'b-2618'
);

-- Muestra el listado aplicando solo subconsultas.

SELECT * 
FROM transaction
WHERE EXISTS (
	SELECT id
    FROM company
    WHERE company_id = company.id
    AND country = (
		SELECT country
		FROM company
		WHERE id = 'b-2618'
	)
);

-- NIVEL 3

-- Ejercicio 1
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros 
-- y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT company_name, phone, country, DATE(timestamp) AS date, amount
FROM transaction
JOIN company 
ON company_id = company.id
WHERE amount BETWEEN 350 AND 400
AND DATE(timestamp) IN ('2015-04-29','2018-07-20','2024-03-13')
ORDER BY amount DESC;

-- Ejercicio 2
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
-- por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente
-- y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.

SELECT company_id, company_name, count(*) AS num_transactions,
CASE 
	WHEN count(*) >= 400 THEN 'High'
    ELSE 'Low'
END AS transaction_category
FROM transaction
JOIN company 
ON company_id = company.id
GROUP BY company_id, company_name;