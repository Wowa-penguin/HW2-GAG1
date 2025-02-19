-- HW2
-- Student names:
-- A. There are 8 plants that belong to the family “Ruellia”. 
--    How many plants (in total) belong to families with names that have 
--    two instances of the letter “r” (either upper or lower case)?
-- Explanation: The Querry sorts out the family names that do not contain two "r" and then counts the number of names left
SELECT
    COUNT(PL.name)
FROM
    plants PL
    JOIN families FM ON FM.id = PL.familyid
WHERE
    FM.name LIKE '%r%r%';

-- B. The most overfilled flowerbed is planted to 105% capacity. 
--    What are the ID(s) of the flowerbed(s) with the most overfilled capacity?
-- Explanation: The querry searches for the percentages in plantedin and displays those that are over 100%
SELECT
    BD.id,
    GD.name,
    SUM(PI.percentage) as PERC
FROM
    plantedin PI
    JOIN beds BD ON BD.id = PI.bedid
    JOIN gardens GD ON BD.gardenid = GD.id
GROUP BY
    GD.name,
    BD.id,
    BD.description
HAVING
    SUM(PI.percentage) > 100
ORDER BY
    PERC DESC;

-- C. There are 10 flowerbeds that are planted to more than 100% capacity. 
--    How many flowerbeds are planted to less than 100% capacity.
-- Explanation: Similare to the previous querry.
-- It's instead used as a subquerry that counts those that do NOT go over 100
SELECT
    COUNT(*)
FROM
    (
        SELECT
            BD.id,
            GD.name,
            SUM(PI.percentage) as PERC
        FROM
            plantedin PI
            JOIN beds BD ON BD.id = PI.bedid
            JOIN gardens GD ON BD.gardenid = GD.id
        GROUP BY
            GD.name,
            BD.id,
            BD.description
        HAVING
            SUM(PI.percentage) < 100
        ORDER BY
            PERC DESC
    );

-- D. Write a query using a set operator that returns the number of plants that 
--    (a) are planted in “Faelledparken” or (b) are of type “shrub”.
-- Explanation: This querry is in fact two querries that are joined by an Intersect
-- They are then used as a subquerry whos results are counted. 
SELECT
    COUNT(*)
FROM
    (
        SELECT
            PL.name
        FROM
            plants PL
            JOIN plantedin PI ON PI.plantid = PL.id
            JOIN beds BD ON PI.bedid = BD.id
            JOIN gardens GD ON BD.gardenid = GD.id
        WHERE
            GD.name = 'Faelledparken'
        INTERSECT
        SELECT
            PL.name
        FROM
            plants PL
            JOIN families FM ON FM.id = PL.familyid
            JOIN types TP ON TP.id = FM.typeid
        WHERE
            TP.name = 'shrub'
    );

-- E. Write a query without a set operator that returns the number of plants that 
--    (a) are planted in “Faelledparken” and (b) are of type “shrub”.
-- Explanation: Instead of using the intersection the querry contains all the joins together
-- to be able to filter out the results in the "WHERE" section. They are then all counted
SELECT
    COUNT(*)
FROM
    (
        SELECT
            PL.name
        FROM
            plants PL
            JOIN plantedin PI ON PI.plantid = PL.id
            JOIN beds BD ON PI.bedid = BD.id
            JOIN gardens GD ON BD.gardenid = GD.id
            JOIN families FM ON FM.id = PL.familyid
            JOIN types TP ON TP.id = FM.typeid
        WHERE
            GD.name = 'Faelledparken'
            and TP.name = 'shrub'
    );

-- F. Write a query that returns the ID and name of all staff that 
--    (a) have position “Planter” and (b) have planted a larger area than any 
--    staff member with position “Senior Planter”. Order the result by the name.
-- Explanation: The query selects 'Planter' staff with a total planting percentage greater than the lowest total percentage of any 'Senior Planter'. It groups by staff ID and name, summing percentages, and orders by name.
SELECT
    S.id,
    S.name,
    SUM(PI.percentage) AS percentage_sum
FROM
    staff S
    JOIN plantedin PI on PI.staffid = S.id
WHERE
    S.position = 'Planter'
GROUP BY
    S.id,
    S.name
HAVING
    SUM(PI.percentage) > (
        SELECT
            MIN(cal_sum.plant_sum) AS min_plant
        FROM
            (
                SELECT
                    SUM(PI.percentage) AS plant_sum
                FROM
                    staff S
                    JOIN plantedin PI on PI.staffid = S.id
                WHERE
                    S.position = 'Senior Planter'
                GROUP BY
                    S.id
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
-- Explanation: The query selects plant families with at least five plants and an average of at least 6.2 distinct beds per plant. It uses nested aggregation to compute bed distribution before filtering eligible families.
SELECT
    familyName,
    familyID
FROM
    (
        SELECT
            FM.id AS familyID,
            FM.name AS familyName,
            AVG(b_count_2.b_count) AS avg_beds_p
        FROM
            families FM
            JOIN plants P ON P.familyID = FM.id
            JOIN (
                SELECT
                    PI.plantid,
                    COUNT(DISTINCT PI.bedid) AS b_count
                FROM
                    plantedin PI
                GROUP BY
                    PI.plantid
            ) b_count_2 ON b_count_2.plantid = P.id
        GROUP BY
            FM.id
        HAVING
            COUNT(P.id) >= 5
    ) avg_bed_f
GROUP BY
    familyName,
    familyID
HAVING
    MAX(avg_beds_p) >= 6.2
    -- H. Write a query that returns the number of staff who have planted something 
    --    (at least one plant in at least one flowerbed) in all gardens.
    -- Note: This is a division query; points will only be awarded if division is attempted.
    -- Explanation: The query counts staff members who have planted in every garden, using a double NOT EXISTS to ensure no garden is missing from their planting record.
SELECT
    COUNT(DISTINCT PI1.staffID) AS num_staff
FROM
    plantedIn PI1
WHERE
    NOT EXISTS (
        SELECT
            G.ID
        FROM
            Gardens G
        WHERE
            NOT EXISTS (
                SELECT
                    *
                FROM
                    plantedIn PI2
                    JOIN Beds b ON PI2.bedID = b.ID
                WHERE
                    PI2.staffID = PI1.staffID
                    AND b.gardenID = G.ID
            )
    );

-- I. There are 105 families that are planted in at least one flowerbed in 
--    all the parks from the database. How many flowerbeds have at least one plant 
--    of all types from the database.
-- Note: This is a division query; points will only be awarded if division is attempted.
-- Explanation: The query selects distinct bed IDs where all plant types are represented, using a double NOT EXISTS to ensure no type is missing.
SELECT DISTINCT
    PI.bedID
FROM
    plantedIn PI
WHERE
    NOT EXISTS (
        SELECT
            T.ID
        FROM
            types T
        WHERE
            NOT EXISTS (
                SELECT
                    *
                FROM
                    plantedIn PI2
                    JOIN plants P ON PI2.plantID = P.ID
                    JOIN families F ON P.familyID = F.ID
                WHERE
                    PI2.bedID = PI.bedID
                    AND F.typeID = T.ID
            )
    );

-- J. Write a query that returns the ID and name of staff, and the total area that 
--    they have planted. The list should be restricted to staff who have the 
--    position “Planter” and who have planted some plant of type “flower” in the 
--    garden “Kongens Have”. The total area returned, however, should not have those
--    restrictions and should represent all the area planted by these staff. 
--    The list should be ordered with the largest area first.
-- Explanation: The query retrieves 'Planter' staff who have planted flowers in beds within 'Kongens Have', summing the total bed area they worked on. It filters using subqueries to ensure only relevant staff are included and orders results by total area in descending order.
SELECT
    PI.staffid AS staff_id,
    S.name AS staff_name,
    SUM(B.size) AS total_area
FROM
    plantedin PI
    JOIN beds B ON B.id = PI.bedid
    JOIN staff S on S.id = PI.staffid
WHERE
    S.position = 'Planter'
    AND S.id IN (
        SELECT
            PI2.staffid
        FROM
            families F
            JOIN plants P ON P.familyid = F.id
            JOIN "types" T ON F.typeid = T.id
            JOIN plantedin PI2 ON PI2.plantid = P.id
        WHERE
            T.name = 'flower'
            AND PI2.bedid IN (
                SELECT
                    B2.id
                FROM
                    beds B2
                    JOIN gardens G ON B2.gardenid = G.id
                WHERE
                    G.name = 'Kongens Have'
            )
    )
GROUP BY
    PI.staffid,
    S.name
ORDER BY
    SUM(B.size) DESC