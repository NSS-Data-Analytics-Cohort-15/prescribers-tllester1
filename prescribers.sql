--Q1. 
--a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 

--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT DISTINCT npi
	,	COUNT(total_claim_count)
	, 	nppes_provider_first_name
	, 	nppes_provider_last_org_name
	, 	specialty_description
FROM prescription
JOIN prescriber
USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY COUNT(total_claim_count) DESC
LIMIT 1;

--Answer: Michael Cox 1356305197 Internal Medicine

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

SELECT drug_name, generic_name, total_drug_cost
FROM prescription
JOIN drug
USING (drug_name)
ORDER BY total_drug_cost DESC;

--Answer a. PIRFENIDONE

--Q4.
--a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT drug_name, total_drug_cost,
	(CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither'
	END) AS drug_type
FROM drug
JOIN prescription
USING(drug_name);






