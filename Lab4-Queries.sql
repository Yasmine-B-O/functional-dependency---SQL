-- 1
SELECT DISTINCT P.FullName
    FROM Patient P
    JOIN ClinicalActivity C ON P.IID = C.IID
    JOIN Staff S ON C.STAFF_ID = S.STAFF_ID
    WHERE S.Status = 'Active';


-- 2
SELECT DISTINCT S.STAFF_ID
FROM Staff S
WHERE S.Status = 'Active'

UNION

SELECT DISTINCT S.STAFF_ID
FROM Staff S
JOIN ClinicalActivity CA ON CA.STAFF_ID = S.STAFF_ID
JOIN Prescription P ON P.CAID = CA.CAID;

-- 3
SELECT DISTINCT H.HID
FROM Hospital H
WHERE H.City = 'Benguerir'

UNION

SELECT DISTINCT H.HID
FROM Hospital H
    JOIN Department D ON D.HID = H.HID
WHERE D.Specialty = 'Cardiology';

-- 4
SELECT DISTINCT H.HID
FROM Hospital H
    JOIN Department D ON D.HID = H.HID
WHERE D.Specialty = 'Cardiology'

INTERSECT

SELECT DISTINCT H.HID
FROM Hospital H
    JOIN Department D ON D.HID = H.HID
WHERE D.Specialty = 'Pediatrics';

-- 5
SELECT W.STAFF_ID
FROM Work_in W
    JOIN Department D ON W.Dep_ID = D.Dep_ID

WHERE D.HID = 1
    GROUP BY W.STAFF_ID
    HAVING COUNT(DISTINCT W.Dep_ID) = (SELECT COUNT(*) FROM Department WHERE HID = 1);

-- 6
SELECT CA.STAFF_ID
FROM ClinicalActivity CA
WHERE CA.DEP_ID = 2

GROUP BY CA.STAFF_ID
    HAVING COUNT(DISTINCT CA.CAID) = (SELECT COUNT(DISTINCT CA2.CAID) FROM ClinicalActivity CA2 WHERE CA2.DEP_ID = 2);


-- 7
SELECT a.STAFF_ID, b.STAFF_ID
FROM (SELECT STAFF_ID, COUNT(DISTINCT CAID) AS total_activities
    FROM ClinicalActivity
    GROUP BY STAFF_ID) a
JOIN
    (SELECT STAFF_ID, COUNT(DISTINCT CAID) AS total_activities
    FROM ClinicalActivity
    GROUP BY STAFF_ID) b

ON a.total_activities > b.total_activities;

-- 8
SELECT IID
FROM ClinicalActivity
GROUP BY IID
HAVING COUNT(DISTINCT STAFF_ID) >= 2;

-- 9
SELECT CAID
FROM ClinicalActivity CA
JOIN Department D ON D.Dep_ID = CA.Dep_ID
JOIN Hospital H ON D.HID = H.HID
WHERE (CA.Date BETWEEN '2025-09-01' AND '2025-09-30')
AND H.City = 'Benguerir';

-- 10
SELECT STAFF_ID
FROM ClinicalActivity CA
JOIN Prescription P ON P.CAID = CA.CAID
GROUP BY STAFF_ID HAVING COUNT(DISTINCT CAID) > 1;

-- 11
SELECT CA.IID
FROM ClinicalActivity CA
JOIN Appointment A ON A.CAID = CA.CAID
WHERE A.Status = 'Scheduled'
GROUP BY CA.IID HAVING COUNT(DISTINCT CA.Dep_ID) > 1;

-- 12
SELECT S.STAFF_ID
FROM Staff S
WHERE S.STAFF_ID NOT IN (
    SELECT CA.STAFF_ID
    FROM ClinicalActivity CA
    JOIN Appointment A ON A.CAID = CA.CAID
    WHERE A.Status = 'Scheduled'
      AND CA.Date = '2025-11-06'
);

-- 13
SELECT CA.Dep_ID
FROM ClinicalActivity CA
GROUP BY CA.Dep_ID
HAVING COUNT(*) < (SELECT AVG(activity_count)
    FROM (SELECT Dep_ID, COUNT(*) activity_count
        FROM ClinicalActivity
        GROUP BY Dep_ID) dept_counts);

-- 14
SELECT STAFF_ID, IID, COUNT(*)
FROM ClinicalActivity CA
JOIN Appointment A ON A.CAID = CA.CAID
WHERE A.Status = 'Completed'
GROUP BY STAFF_ID, IID HAVING COUNT(*) = (SELECT MAX(staff_activity_count)
                                          FROM (SELECT CA2.IID, COUNT(*) as staff_activity_count
                                                FROM ClinicalActivity CA2
                                                JOIN Appointment A2 ON A2.CAID = CA2.CAID
                                                WHERE A2.Status = 'Completed' AND CA2.STAFF_ID = CA.STAFF_ID
                                                GROUP BY CA2.IID) as staff_count);

-- 15
SELECT CA.IID
FROM ClinicalActivity CA
JOIN Emergency E ON E.CAID = CA.CAID
WHERE E.Outcome = 'Admitted' AND YEAR(CA.Date) = 2024
GROUP BY P.IID HAVING COUNT(DISTINCT CA.CAID) >= 3