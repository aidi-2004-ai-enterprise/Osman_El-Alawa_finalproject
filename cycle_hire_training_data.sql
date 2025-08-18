CREATE OR REPLACE TABLE `my-ml-project-469319.ml_dataset.cycle_hire_training_data` AS
SELECT 
  duration AS target,
  EXTRACT(DAYOFWEEK FROM start_date) AS day_week,
  EXTRACT(HOUR FROM start_date) AS hour
FROM 
  `bigquery-public-data.london_bicycles.cycle_hire`
WHERE 
  duration IS NOT NULL 
  AND start_date >= '2020-01-01'  -- Recent data
LIMIT 10000;  -- Small for demo