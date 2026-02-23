-- ==========================================================================================
-- PROJECT: Worldwide Layoffs Data Cleaning (End-to-End)
-- AUTHOR: M. Hammad Faisal
-- PURPOSE: Transforming raw layoff data into an analysis-ready dataset.
-- ==========================================================================================

-- STEP 1: INITIAL SETUP & STAGING
CREATE DATABASE IF NOT EXISTS LayoffsProject;
USE LayoffsProject;

-- STEP 2: Create Table Structure
CREATE TABLE IF NOT EXISTS layoffs (
    company TEXT,
    location TEXT,
    total_laid_off INT DEFAULT NULL,
    `date` TEXT,
    percentage_laid_off TEXT,
    industry TEXT,
    source TEXT,
    stage TEXT,
    funds_raised INT DEFAULT NULL,
    country TEXT,
    date_added TEXT );

-- Preview the raw data
SELECT * FROM layoffs LIMIT 10;

-- Disable Safe Updates for cleaning operations
SET SQL_SAFE_UPDATES = 0;

-- STEP 3: DUPLICATE REMOVAL
-- 3.1: Identifying duplicate records using CTE and Window Functions for verification
WITH Duplicate_CTE AS (
    SELECT *, ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised
    ) AS row_n
    FROM layoffs
)
SELECT * FROM Duplicate_CTE WHERE row_n > 1;

-- 3.2: Executing deletion of identified duplicates to ensure data integrity
DELETE FROM layoffs 
WHERE (company, location, `date`, industry, total_laid_off) IN (
    SELECT company, location, `date`, industry, total_laid_off
    FROM (
        SELECT *, ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, `date`, stage, country, funds_raised
        ) AS rn
        FROM layoffs
    ) AS sub_table
    WHERE rn > 1 );
    
-- STEP 4: DATA STANDARDIZATION
-- 4.1: Remove leading/trailing white spaces from company names
UPDATE layoffs SET company = TRIM(company);

-- 4.2: Standardize Industry labels (e.g., Unifying 'Crypto Currency' into 'Crypto')
UPDATE layoffs SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- 4.3: Remove trailing punctuation from country names
UPDATE layoffs SET country = TRIM(TRAILING '.' FROM country);

-- STEP 5: DATE CONVERSION (Text to Date Type)

-- Step A: Set empty/blank strings to NULL for safe conversion
UPDATE layoffs 
SET `date` = NULL 
WHERE `date` = '' OR `date` = 'NULL';

-- Step B: Convert string dates to standard SQL format (YYYY-MM-DD)
UPDATE layoffs 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

-- Step C: Modify column data type to 'DATE' permanently
ALTER TABLE layoffs MODIFY COLUMN `date` DATE;

-- STEP 6: HANDLING NULL VALUES & DATA IMPUTATION
-- Populating missing industry values based on existing data for the same company
UPDATE layoffs t1
JOIN layoffs t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL AND t2.industry <> '';

-- STEP 7: FINAL DATA QUALITY CHECK & CLEANUP
-- Remove records with insufficient data for analysis (both key metrics are NULL)
DELETE FROM layoffs 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Drop redundant or unneeded metadata columns
ALTER TABLE layoffs 
DROP COLUMN source, 
DROP COLUMN date_added;

-- STEP 8: VALIDATION QUERIES (Post-Cleaning Audit)
-- Verify Date functionality
SELECT `date`, YEAR(`date`) as Year, MONTHNAME(`date`) as Month 
FROM layoffs LIMIT 5;

-- Final Analysis-Ready Dataset Preview
SELECT * FROM layoffs ORDER BY `date` DESC;

--------------------------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS (EDA)
-- Purpose: Extracting key insights and trends from the cleaned layoffs dataset.
--------------------------------------------------------------------------------

-- 1. Top 10 Companies with the Highest Number of Layoffs
SELECT 
    company, 
    SUM(total_laid_off) AS total_reductions
FROM layoffs 
GROUP BY company 
ORDER BY total_reductions DESC 
LIMIT 10;

-- 2. Impact by Industry
SELECT 
    industry, 
    SUM(total_laid_off) AS total_reductions
FROM layoffs 
GROUP BY industry 
ORDER BY total_reductions DESC;

-- 3. Layoff Trends Over the Years
SELECT 
    YEAR(`date`) AS layoff_year, 
    SUM(total_laid_off) AS total_reductions
FROM layoffs 
WHERE YEAR(`date`) IS NOT NULL
GROUP BY layoff_year 
ORDER BY layoff_year DESC;

-- 4. Analyzing total layoffs by Country and Year
SELECT 
    country, 
    YEAR(`date`) AS layoff_year, 
    SUM(total_laid_off) AS total_reductions
FROM layoffs 
WHERE `date` IS NOT NULL -- Taki ghalat entries na ayein
GROUP BY country, layoff_year 
ORDER BY layoff_year DESC, total_reductions DESC;

-- ========================== END OF SCRIPT ==========================
