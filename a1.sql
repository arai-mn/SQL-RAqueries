-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1b i --------------------------------------------------
INSERT INTO Query1bi
SELECT DISTINCT sname
FROM ProductTag INNER JOIN Catalog ON Catalog.pid = ProductTag.pid INNER JOIN Suppliers ON Catalog.sid = Suppliers.sid
WHERE tagname = "PPE" OR tagname = "Testing";

-- Query 1b ii --------------------------------------------------
INSERT INTO Query1bii
SELECT DISTINCT Catalog.sid as sid
FROM ProductTag INNER JOIN Catalog ON Catalog.pid = ProductTag.pid INNER JOIN Suppliers ON Catalog.sid = Suppliers.sid
WHERE Catalog.cost < "10" AND ProductTag.tagname = "PPE"
INTERSECT
SELECT DISTINCT Catalog.sid as sid
FROM ProductTag INNER JOIN Catalog ON Catalog.pid = ProductTag.pid INNER JOIN Suppliers ON Catalog.sid = Suppliers.sid
WHERE Catalog.cost > "420" AND ProductTag.tagname = "PPE";

-- Query 1b iii --------------------------------------------------
INSERT INTO Query1biii
SELECT DISTINCT Catalog.sid as sid
FROM ProductTag INNER JOIN Catalog ON Catalog.pid = ProductTag.pid INNER JOIN Suppliers ON Catalog.sid = Suppliers.sid
WHERE ProductTag.tagname = "PPE"
EXCEPT
SELECT DISTINCT Catalog.sid as sid
FROM ProductTag INNER JOIN Catalog ON Catalog.pid = ProductTag.pid INNER JOIN Suppliers ON Catalog.sid = Suppliers.sid
WHERE Catalog.cost > 1337 OR Catalog.cost < 10 AND ProductTag.tagname = "PPE";

-- Query 1b iv  --------------------------------------------------
INSERT INTO Query1biv
SELECT Catalog.sid
FROM Catalog JOIN ProductTag ON Catalog.pid = ProductTag.pid,
(SELECT COUNT(ProductTag.pid) as total_cleaning FROM ProductTag GROUP BY tagname HAVING tagname = "Cleaning")
WHERE ProductTag.tagname = "Cleaning" 
GROUP BY Catalog.sid
HAVING COUNT(ProductTag.pid) >= total_cleaning;

-- Query 1b v --------------------------------------------------
INSERT INTO Query1bv
SELECT DISTINCT sup1.sid as sid1, sup2.sid as sid2
FROM Catalog as sup1 JOIN Catalog as sup2 on sup1.pid = sup2.pid
WHERE sup1.cost >= 1.2 * sup2.cost; 

-- Query 1b vi --------------------------------------------------
INSERT INTO Query1bvi
select distinct Catalog.pid 
from Catalog as cat2
JOIN Catalog 
on cat2.sid != Catalog.sid and cat2.pid = Catalog.pid;

-- Query 1b vii --------------------------------------------------
INSERT INTO Query1bvii
select Suppliers.sid
from ProductTag
JOIN Catalog
on ProductTag.tagname ='Super Tech' and ProductTag.pid = Catalog.pid
JOIN Suppliers
on Suppliers.scountry = 'USA' and Catalog.sid = Suppliers.sid
where catalog.cost = (
		select max(Catalog.cost) as maxCost
		from ProductTag
		JOIN Catalog
		on ProductTag.tagname='Super Tech' and ProductTag.pid = Catalog.pid
		JOIN Suppliers
		on Suppliers.scountry = 'USA' and Catalog.sid = Suppliers.sid);


-- Query 1b viii --------------------------------------------------
INSERT INTO Query1bviii
select Suppliers.sid
from ProductTag
JOIN Catalog
on ProductTag.tagname ='Super Tech' and ProductTag.pid = Catalog.pid
JOIN Suppliers
on Suppliers.scountry = 'USA' and Catalog.sid = Suppliers.sid
where Catalog.cost = (
			select max(Catalog.cost) as maxCost
			from ProductTag
			JOIN Catalog
			on ProductTag.tagname ='Super Tech' and ProductTag.pid = Catalog.pid
			JOIN Suppliers
			on Suppliers.scountry = 'USA' and Catalog.sid = Suppliers.sid
			where Catalog.cost NOT IN (
				select max(Catalog.cost) as maxCost
				from ProductTag
				JOIN Catalog
				on ProductTag.tagname ='Super Tech' and ProductTag.pid = Catalog.pid
				JOIN Suppliers
				on Suppliers.scountry = 'USA' and Catalog.sid = Suppliers.sid
			)
);

-- Query 1b ix --------------------------------------------------
INSERT INTO Query1bix
select pid
from (SELECT DISTINCT pid from Product
		EXCEPT
		select DISTINCT pid from(
		select Product.pid, sid
		from Suppliers JOIN Product 
		except 
		select Catalog.pid, sid
		from Catalog))
where pid NOT IN (
			select Catalog.pid
			from Catalog JOIN Product 
			where Product.pid = Catalog.pid and Catalog.cost >= 69
);

-- Query 1b x --------------------------------------------------
INSERT INTO Query1bx
select pid
from Product
EXCEPT 
select pid
from Inventory
where quantity > 0;


-- Query 1c i --------------------------------------------------
INSERT INTO Query1ci
select C1.pid as pid, sid1, sid2, C1.cost as cost1, C2.cost as cost2
From (select subid as sid1, sid as sid2
from Subsuppliers 
except 
select R1.sid as sid1, R2.sid as sid2
from Subsuppliers as R1 JOIN Subsuppliers as R2 
ON R1.sid = R2.subid and R1.subid=R2.sid and R1.sid > R2.sid)
JOIN Catalog as C1 ON sid1 = C1.sid 
JOIN Catalog as C2 ON sid2 = C2.sid and C1.pid = C2.pid
WHERE C1.pid not in (select pid from Inventory where quantity > 0)
;

-- Query 1c ii --------------------------------------------------
INSERT INTO Query1cii
select DISTINCT cat1.pid as pid, sid1 as sid, cat1.cost as cost from 
(select S1.sid as sid1, S2.sid as sid2
from Suppliers as S1 JOIN Suppliers as S2
ON S1.sid != S2.sid) 
JOIN Catalog as cat1
JOIN Catalog as cat2
Where cat1.sid=sid1 and cat2.sid=sid2 and cat1.pid = cat2.pid and cat1.cost = cat2.cost;


-- Query 1c iii --------------------------------------------------
INSERT INTO Query1ciii
SELECT Product.pid, Product.pname, Catalog.cost
FROM (SELECT pid as prodid
FROM ProductTag
GROUP BY pid
HAVING COUNT(tagname) >= 3
INTERSECT
SELECT DISTINCT pid
FROM ProductTag
WHERE tagname = "PPE" 
EXCEPT
SELECT DISTINCT pid
FROM ProductTag
WHERE tagname = "Super Tech") JOIN Product ON prodid = Product.pid JOIN Catalog ON prodid = Catalog.pid;

-- Query 1c iv  --------------------------------------------------

CREATE VIEW ReciprocalSubsuppliers AS
SELECT RS1.sid as sid1, RS2.sid as sid2
FROM Subsuppliers as RS1 JOIN Subsuppliers as RS2 ON (RS1.sid = RS2.subid and RS1.subid = RS2.sid and RS1.sid > RS2.sid);

CREATE VIEW CommonSubsuppliersOfReciprocal AS
SELECT sid1, sid2, Subsuppliers.subid, Subsuppliers.subname, Subsuppliers.subaddress
FROM ReciprocalSubsuppliers, Subsuppliers
WHERE sid1 = Subsuppliers.sid 
INTERSECT
SELECT sid1, sid2, Subsuppliers.subid, Subsuppliers.subname, Subsuppliers.subaddress
FROM ReciprocalSubsuppliers, Subsuppliers
WHERE sid2 = Subsuppliers.sid;

INSERT INTO Query1civ
SELECT * FROM
(SELECT sid1, sid2, Subsuppliers.subid, Subsuppliers.subname, Subsuppliers.subaddress
FROM ReciprocalSubsuppliers, Subsuppliers
WHERE sid1 = Subsuppliers.sid OR sid2 = Subsuppliers.sid
EXCEPT
SELECT * FROM CommonSubsuppliersOfReciprocal);

DROP VIEW IF EXISTS ReciprocalSubsuppliers;
DROP VIEW IF EXISTS CommonSubsuppliersOfReciprocal;

-- Query 2 i --------------------------------------------------
INSERT INTO Query2i
SELECT utorid
FROM Student
WHERE utorid NOT IN (
			SELECT utorid
			FROM Approved
			WHERE roomid = 'IC404');
		
-- Query 2 ii --------------------------------------------------
INSERT INTO Query2ii
SELECT e.utorid
FROM Employee AS e, Approved AS a
WHERE e.utorid = a.utorid
GROUP BY e.utorid
HAVING COUNT(a.roomid) >= 3;

-- Query 2 iii --------------------------------------------------
INSERT INTO Query2iii
SELECT e.utorid
FROM Employee AS e, Approved AS a
WHERE e.utorid = a.utorid
GROUP BY e.utorid
HAVING COUNT(a.roomid) = 3;

-- Query 2 iv  --------------------------------------------------
INSERT INTO Query2iv
SELECT e.utorid
FROM Employee AS e, Approved AS a
WHERE e.utorid = a.utorid
GROUP BY e.utorid
HAVING COUNT(a.roomid) <= 3;

-- Query 2 v --------------------------------------------------
INSERT INTO Query2v
SELECT a.roomid
FROM Approved AS a
INNER JOIN Student AS s ON a.utorid = s.utorid
INNER JOIN Member AS m ON s.utorid = m.utorid
WHERE m.name = 'Oscar Lin' AND a.roomid IN(
						SELECT r.roomid
						FROM Room AS r, Occupancy AS o
						WHERE r.roomid = o.roomid AND o.alertlevel>r.alertthreshold
						AND o.date>'2021-09-01' AND o.date<'2021-12-31');

-- Query 2 vi --------------------------------------------------
INSERT INTO Query2vi
SELECT DISTINCT o.utorid
FROM Occupancy AS o
WHERE o.date>'2020-03-17' AND o.date<'2021-12-31'
AND o.utorid IN(
			SELECT m.utorid
			FROM Member AS m, Approved
			WHERE m.utorid NOT IN(
						SELECT utorid
						FROM Approved));

-- Query 2 vii --------------------------------------------------
INSERT INTO Query2vii
SELECT SUM(salary)
FROM Employee;

-- Query 2 viii --------------------------------------------------
INSERT INTO Query2viii
SELECT s.utorid, m.email
FROM Student AS s, Member AS m
WHERE s.utorid = m.utorid AND m.vaxstatus = 0
AND s.utorid IN(
			SELECT o.utorid
			FROM Occupancy AS o, Room AS r
			WHERE o.roomid = r.roomid
			AND o.alertlevel>r.alertthreshold);








