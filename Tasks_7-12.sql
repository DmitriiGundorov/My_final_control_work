# Задание 7. В подключенном MySQL репозитории создать базу данных “Друзья человека”

CREATE DATABASE IF NOT EXISTS HumanFriends;
USE HumanFriends;
 
# Задание 8. Создать таблицы с иерархией из диаграммы в БД

CREATE TABLE animals_class
(
	Id INT AUTO_INCREMENT PRIMARY KEY, 
	Class_name VARCHAR(45)
);

INSERT INTO animals_class (Class_name)
VALUES ('Home animal'),
('Pack animal');  

CREATE TABLE home_animal
(
	  Id INT AUTO_INCREMENT PRIMARY KEY,
    Genus_name VARCHAR (45),
    Class_id INT,
    FOREIGN KEY (Class_id) REFERENCES animals_class (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO home_animal (Genus_name, Class_id)
VALUES ('Dog', 1),
('Cat', 1),  
('Hamster', 1); 

CREATE TABLE pack_animal
(
	  Id INT AUTO_INCREMENT PRIMARY KEY,
    Genus_name VARCHAR (45),
    Class_id INT,
    FOREIGN KEY (Class_id) REFERENCES animals_class (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO pack_animal (Genus_name, Class_id)
VALUES ('Horse', 2),
('Camel', 2),  
('Donkey', 2); 
    
# Задание 9. Заполнить низкоуровневые таблицы именами(животных), командами которые они выполняют и датами рождения

CREATE TABLE dogs 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(100),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES home_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO dogs (Name, Birthday, Commands, Genus_id)
VALUES ('Bella', '2021-01-01', 'sit, come to me, Give me a paw, make a voice', 1),
('Rex', '2019-09-10', "cannot, down, Give me a paw, take him, take the trail", 1), 
('Simba', '2020-11-22', "cannot, come to me, take the trail, lie down", 1);

CREATE TABLE cats 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(100),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES home_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO cats (Name, Birthday, Commands, Genus_id)
VALUES ('Badger', '2010-09-01', 'kys-kys-kys, get', 2),
('Leopold', '2016-05-17', "kys-kys-kys", 2),  
('Vasya', '2018-06-07', "kys-kys-kys", 2); 

CREATE TABLE hamsters 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(100),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES home_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO hamsters (Name, Birthday, Commands, Genus_id)
VALUES ('Jim', '2022-11-28', 'stand', 3),
('Mike', '2021-04-19', "running", 3),  
('Bob', '2023-08-17', NULL, 3);

CREATE TABLE horses 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO horses (Name, Birthday, Commands, Genus_id)
VALUES ('Diane', '2007-08-16', 'But, Shh', 1),
('Yakhont', '2017-03-24', "Forward, Stand, хоп", 1),  
('Graph', '2009-11-22', "Step, Lynx, Quieter", 1);

CREATE TABLE camels 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO camels (Name, Birthday, Commands, Genus_id)
VALUES ('Lancelot', '2012-05-05', 'Right', 2),
('Agatha', '2017-03-18', "Left, Back", 2),  
('Jared', '2001-09-11', "Went, Stand", 2);

CREATE TABLE donkeys 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(45), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animal (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO donkeys (Name, Birthday, Commands, Genus_id)
VALUES ('Robingud', '2016-06-17', NULL, 3),
('Dobrynya', '2013-02-28', NULL, 3),  
('Tyson', '2014-12-12', NULL, 3);

# Задание 10. Удалив из таблицы верблюдов, т.к. верблюдов решили перевезти в другой
# питомник на зимовку. Объединить таблицы лошади, и ослы в одну таблицу.

SET SQL_SAFE_UPDATES = 0;
DELETE FROM camels;

SELECT Name, Birthday, Commands FROM horses
UNION SELECT  Name, Birthday, Commands FROM donkeys;

# Задание 11. Создать новую таблицу “молодые животные” в которую попадут все животные старше 1 года,
# но младше 3 лет и в отдельном столбце с точностью до месяца подсчитать возраст животных в новой таблице

CREATE TEMPORARY TABLE animals AS 
SELECT *, 'Horse' as genus FROM horses
UNION SELECT *, 'Donkey' AS genus FROM donkeys
UNION SELECT *, 'Dog' AS genus FROM dogs
UNION SELECT *, 'Cat' AS genus FROM cats
UNION SELECT *, 'Hamster' AS genus FROM hamsters;

CREATE TABLE young_animal AS
SELECT Name, Birthday, Commands, genus, TIMESTAMPDIFF(MONTH, Birthday, CURDATE()) AS Age_in_month
FROM animals WHERE Birthday BETWEEN ADDDATE(curdate(), INTERVAL -3 YEAR) AND ADDDATE(CURDATE(), INTERVAL -1 YEAR);
 
SELECT * FROM young_animal;

# Задание 12. Объединить все таблицы в одну, при этом сохраняя поля, указывающие на прошлую принадлежность к старым таблицам.

SELECT c.Name, c.Birthday, c.Commands, ha.Genus_name, ya.Age_in_month 
FROM cats as c
LEFT JOIN young_animal as ya ON ya.Name = c.Name
LEFT JOIN home_animal as ha ON ha.Id = c.Genus_id
UNION
SELECT d.Name, d.Birthday, d.Commands, ha.Genus_name, ya.Age_in_month 
FROM dogs as d
LEFT JOIN young_animal as ya ON ya.Name = d.Name
LEFT JOIN home_animal as ha ON ha.Id = d.Genus_id
UNION
SELECT hm.Name, hm.Birthday, hm.Commands, ha.Genus_name, ya.Age_in_month 
FROM hamsters as hm
LEFT JOIN young_animal as ya ON ya.Name = hm.Name
LEFT JOIN home_animal as ha ON ha.Id = hm.Genus_id
UNION
SELECT h.Name, h.Birthday, h.Commands, pa.Genus_name, ya.Age_in_month 
FROM horses as h
LEFT JOIN young_animal as ya ON ya.Name = h.Name
LEFT JOIN pack_animal as pa ON pa.Id = h.Genus_id
UNION 
SELECT d.Name, d.Birthday, d.Commands, pa.Genus_name, ya.Age_in_month 
FROM donkeys as d 
LEFT JOIN young_animal as ya ON ya.Name = d.Name
LEFT JOIN pack_animal as pa ON pa.Id = d.Genus_id;