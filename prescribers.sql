--Q1. 
--a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 

--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT npi, SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;


SELECT DISTINCT npi
	,	SUM(total_claim_count)
	, 	nppes_provider_first_name
	, 	nppes_provider_last_org_name
	, 	specialty_description
FROM prescription
JOIN prescriber
USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;

--Answer: BRUCE PENDLEY 1881634483 Family Practice

--Q2. 
--a. Which specialty had the most total number of claims (totaled over all drugs)?
--b. Which specialty had the most total number of claims for opioids? 

SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
JOIN prescription
USING(npi)
JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

--Answer a: Family Practice
--Answer b: Nurse Practitioner 

--Q3. 
--a. Which drug (generic_name) had the highest total drug cost?

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, SUM(total_drug_cost)
FROM prescription
JOIN drug
USING (drug_name)
GROUP BY generic_name, 
ORDER BY SUM(total_drug_cost) DESC;

SELECT generic_name, ROUND(SUM(total_drug_cost)/ SUM(total_day_supply),2) AS daily_cost
FROM prescription
JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC;

--Answer a. Insulin
--Answer b. Esterase Inhibitor
--Q4.
--a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT drug_name,
    CASE
        WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
        WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
        ELSE 'Neither'
    END AS drug_type
FROM drug;

SELECT  
	(CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither'
	END) AS drug_type,
	CAST(SUM(total_drug_cost) AS money) AS total_cost
FROM drug
JOIN prescription
USING(drug_name)
GROUP BY drug_type;

--Q5.  a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT DISTINCT (cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%'


SELECT COUNT(fipscounty)
FROM cbsa
WHERE fipscounty LIKE '47%' -- All TN county fip codes start with 47 (google)

--Answer a: 10 counting distinct cbsa. 42 counting counties.

(SELECT cbsaname,  SUM(population.population) AS total_population, 'Largest' AS flag
FROM cbsa
JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY total_population DESC
LIMIT 1)
UNION
(SELECT cbsaname,  SUM(population.population) AS total_population, 'Smallest' AS flag
FROM cbsa
JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY total_population ASC
LIMIT 1)

--Answer b: Nashville-Davidson-Murfreesboro-Franklin, TN 1,830,410 is the highest and Morristown,TN 116,352 is the lowest.
--5c:
SELECT *
FROM fips_county
LEFT JOIN cbsa
using (fipscounty)
JOIN population
USING (fipscounty)
WHERE cbsa.fipscounty IS NULL
ORDER BY population DESC

SELECT county, population
FROM fips_county
INNER JOIN population
USING(fipscounty)
WHERE fipscounty NOT IN (
	SELECT fipscounty
	FROM cbsa
)
ORDER BY population DESC;

SELECT fips_county,population,county,state
FROM population
INNER JOIN fips_county USING (fipscounty)
WHERE fipscounty IN (SELECT fipscounty FROM population EXCEPT SELECT DISTINCT fipscounty FROM cbsa)
ORDER BY population DESC;

--Q6. 
--a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
	ELSE 'Not Opioid'
	END AS Opioid
	, nppes_provider_first_name
	, nppes_provider_last_org_name
FROM prescription
JOIN drug
USING (drug_name)
JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000






