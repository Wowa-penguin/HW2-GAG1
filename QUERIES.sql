-- HW2
-- Student names:


-- A. There are 8 plants that belong to the family “Ruellia”. 
--    How many plants (in total) belong to families with names that have 
--    two instances of the letter “r” (either upper or lower case)?

-- Explanation: 

SELECT COUNT(PL.name)
FROM plants PL
    JOIN families FM ON FM.id = PL.familyid
WHERE FM.name LIKE '%r%r%';

-- B. The most overfilled flowerbed is planted to 105% capacity. 
--    What are the ID(s) of the flowerbed(s) with the most overfilled capacity?

-- Explanation: 

SELECT BD.id, GD.name, SUM(PI.percentage) as PERC
FROM plantedin PI
    JOIN beds BD ON BD.id = PI.bedid
    JOIN gardens GD ON BD.gardenid = GD.id
GROUP BY GD.name, BD.id, BD.description
HAVING SUM(PI.percentage) > 100
ORDER BY PERC DESC;
    

-- C. There are 10 flowerbeds that are planted to more than 100% capacity. 
--    How many flowerbeds are planted to less than 100% capacity.

-- Explanation: 

SELECT COUNT(*)
FROM (
    SELECT BD.id, GD.name, SUM(PI.percentage) as PERC
    FROM plantedin PI
        JOIN beds BD ON BD.id = PI.bedid
        JOIN gardens GD ON BD.gardenid = GD.id
    GROUP BY GD.name, BD.id, BD.description
    HAVING SUM(PI.percentage) < 100
    ORDER BY PERC DESC);

-- D. Write a query using a set operator that returns the number of plants that 
--    (a) are planted in “Faelledparken” or (b) are of type “shrub”.

-- Explanation: 
SELECT COUNT(*)
FROM (
    SELECT PL.name
    FROM plants PL
        JOIN plantedin PI ON PI.plantid = PL.id
        JOIN beds BD ON PI.bedid = BD.id
        JOIN gardens GD ON BD.gardenid = GD.id
    WHERE GD.name = 'Faelledparken'
    INTERSECT
    SELECT PL.name
    FROM plants PL
        JOIN families FM ON FM.id = PL.familyid
        JOIN types TP ON TP.id = FM.typeid
    WHERE TP.name = 'shrub'
);

-- E. Write a query without a set operator that returns the number of plants that 
--    (a) are planted in “Faelledparken” and (b) are of type “shrub”.

-- Explanation: 

SELECT COUNT(*)
FROM (
    SELECT PL.name
    FROM plants PL
        JOIN plantedin PI ON PI.plantid = PL.id
        JOIN beds BD ON PI.bedid = BD.id
        JOIN gardens GD ON BD.gardenid = GD.id
        JOIN families FM ON FM.id = PL.familyid
        JOIN types TP ON TP.id = FM.typeid
    WHERE GD.name = 'Faelledparken' and TP.name = 'shrub'
);

-- F. Write a query that returns the ID and name of all staff that 
--    (a) have position “Planter” and (b) have planted a larger area than any 
--    staff member with position “Senior Planter”. Order the result by the name.
-- 					Þarf að skoða þannan Kv:Heimir !!!
-- Explanation: 

SELECT 
	S.id,
	S.name,
	SUM(PI.percentage) AS idk
FROM staff S
	JOIN plantedin PI on PI.staffid = S.id
WHERE
	S.position = 'Planter'
GROUP BY
	S.id,
	S.name
HAVING
	SUM(PI.percentage) > (
		SELECT MIN(cal_sum.plant_sum) AS min_plant
			FROM (
				SELECT 
					SUM(PI.percentage) AS plant_sum
				FROM staff S
					JOIN plantedin PI on PI.staffid = S.id
				WHERE
					S.position = 'Senior Planter'
				GROUP BY
					S.id,
					S.name
			) AS cal_sum
	)
ORDER BY
	S.name;

-- G. Write a query to return the names of the families, with at least 
--    5 different plants, that are planted in the most flowerbeds on average, 
--    across all their plants? 
-- Note: In a different instance, the output of this query could contain more 
--    than one family name, but in this database instance the answer is one family name. 
--    As an additional hint, the average number of flowerbeds for each plant of 
--    that family is 6.20000…. 
-- 					Ég veit ekki betri leið að gera þetta þarf að fara yfir
-- Explanation: 

SELECT
	familyID,
	MAX(avg_beds_per_plant)
FROM (
	SELECT 
		F.id AS familyID,
		AVG(plant_bed_counts2.bed_count) AS avg_beds_per_plant
	FROM families F
	JOIN plants P ON P.familyID = F.id
	JOIN (
		SELECT 
			PI.plantID, 
			COUNT(DISTINCT PI.bedID) AS bed_count
		FROM plantedIn PI
		GROUP BY PI.plantID
	) plant_bed_counts2 ON plant_bed_counts2.plantID = P.id
	GROUP BY F.id
	HAVING COUNT(P.id) >= 5
) avg_bed_counts_per_family
GROUP BY 
	familyID
HAVING 
	MAX(avg_beds_per_plant) >= 6.2

-- H. Write a query that returns the number of staff who have planted something 
--    (at least one plant in at least one flowerbed) in all gardens.
-- Note: This is a division query; points will only be awarded if division is attempted.

-- Explanation: 


-- I. There are 105 families that are planted in at least one flowerbed in 
--    all the parks from the database. How many flowerbeds have at least one plant 
--    of all types from the database.
-- Note: This is a division query; points will only be awarded if division is attempted.

-- Explanation: 


-- J. Write a query that returns the ID and name of staff, and the total area that 
--    they have planted. The list should be restricted to staff who have the 
--    position “Planter” and who have planted some plant of type “flower” in the 
--    garden “Kongens Have”. The total area returned, however, should not have those
--    restrictions and should represent all the area planted by these staff. 
--    The list should be ordered with the largest area first.

-- Explanation: 

