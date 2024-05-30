-- create a staging table. This is the one we will work in 
-- and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging
LIKE layoffs;
SELECT * FROM layoffs_staging;
INSERT layoffs_staging
SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

-- find duplicates

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
	SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num >1;

-- crosscheck
SELECT * FROM layoffs_staging
WHERE company = 'Cazoo';

-- create new table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date,stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;
-- crosscheck
SELECT * FROM layoffs_staging2
WHERE company = 'Yahoo';

DELETE FROM layoffs_staging2
WHERE row_num > 1;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;

SELECT * FROM layoffs_staging2;

-- standarizing data

SELECT DISTINCT(company) FROM layoffs_staging2;

SELECT company,TRIM(company) FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Cryto'
WHERE industry LIKE 'Crypto%';

SELECT * FROM layoffs_staging2
WHERE industry = 'Cryto';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT * FROM layoffs_staging2;

-- convert column content from text to date formmat
SELECT date, STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging2;
-- update to table
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');
-- change date format to date from text
ALTER TABLE layoffs_staging2
MODIFY COLUMN date Date;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';
-- crosscheck
SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- crosscheck whether updated
SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Bally's company has only one row so its not updated
SELECT * FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;

-- delete column row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;








