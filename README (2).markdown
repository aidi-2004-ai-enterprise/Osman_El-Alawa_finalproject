# ML Pipeline DAG - Bicycle Duration Prediction

## Overview
This repository contains an Apache Airflow DAG (`ml_pipeline_dag`) designed to build a simple machine learning pipeline for predicting bicycle rental durations using data from the London Bicycle Hire public dataset in BigQuery. The pipeline includes data extraction, model training, logging, and email notification tasks, deployed on Google Cloud Composer.

- **DAG Name**: `ml_pipeline_dag`
- **Schedule**: Weekly on Sunday at midnight UTC (4 AM EDT)
- **Environment**: Google Cloud Composer 3 (`composer-3-airflow-2.10.5-build.11`)
- **Project ID**: `my-ml-project-469319`
- **Dataset**: `ml_dataset.cycle_hire_training_data`

## Features
- Extracts 10,000 rows of bicycle hire data (duration, day of week, hour) from `bigquery-public-data.london_bicycles.cycle_hire` since 2020-01-01.
- Trains a Linear Regression model and evaluates it with Mean Squared Error (MSE).
- Saves the model and metrics to Google Cloud Storage (GCS).
- Logs completion and sends an email notification.

## Prerequisites
- Google Cloud Project (`my-ml-project-469319`) with billing enabled.
- Cloud Composer environment (`ml-pipeline-env`) in `us-central1`.
- Service Account: `composer-service-account-my-ml@my-ml-project-469319.iam.gserviceaccount.com` with appropriate IAM roles.
- GCS Bucket: `us-central1-ml-pipeline-env-dd338327-bucket` (or `ml-pipeline-models` if created separately).
- Python libraries: `apache-airflow`, `google-cloud-bigquery`, `pandas`, `scikit-learn`, `joblib`.

## Setup Instructions

### 1. Configure Google Cloud Project
- Enable APIs: BigQuery, Cloud Composer, Cloud Storage.
- Create a service account key file for `composer-service-account-my-ml@my-ml-project-469319.iam.gserviceaccount.com` and download the JSON file.
- Grant IAM roles:
  - `roles/composer.admin` to `elalawaosman@gmail.com` (for environment creation).
  - `roles/bigquery.user`, `roles/bigquery.jobUser`, `roles/bigquery.dataEditor` to the service account.
  - `roles/storage.objectAdmin` on the GCS bucket.

### 2. Set Up Cloud Composer Environment
- Create or recreate the environment:
  ```cmd
  gcloud composer environments create ml-pipeline-env --location us-central1 --project=my-ml-project-469319 --service-account=composer-service-account-my-ml@my-ml-project-469319.iam.gserviceaccount.com --oauth-scopes=https://www.googleapis.com/auth/bigquery,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/devstorage.full_control --image-version=composer-3-airflow-2.10.5-build.11
  ```
- Wait 10-20 minutes for the environment to stabilize (`state: RUNNING`).

### 3. Upload the DAG
- Locate the DAGs folder: `gs://us-central1-ml-pipeline-env-dd338327-bucket/dags/` (from Composer UI > "DAGs Folder").
- Upload `ml_pipeline_dag_v1.py` to the bucket.
- Wait 5-10 minutes for Airflow to detect the DAG.

### 4. Configure Email (Optional)
- In Airflow UI: **Admin** > **Connections** > Add `smtp_default` with:
  - Conn Type: `Email`
  - Host: `smtp.gmail.com`
  - Port: `587`
  - Login: Your email
  - Password: App password (if 2FA enabled).
- Update `email_notify` `to` field in the DAG with your email.

## Usage
1. **Access Airflow UI**:
   - Go to `ml-pipeline-env` details > **"Airflow UI"** link.
   - Find `ml_pipeline_dag` in the DAGs tab.

2. **Trigger the DAG**:
   - Unpause the DAG (toggle **"On"**).
   - Click **"Trigger DAG"**.

3. **Monitor Execution**:
   - View task progress in **"Graph"** or **"Tree"** view.
   - Check logs for each task if issues arise.

4. **Verify Outputs**:
   - BigQuery: `my-ml-project-469319.ml_dataset.cycle_hire_training_data` (~10k rows).
   - GCS: `us-central1-ml-pipeline-env-dd338327-bucket/models/lin_reg_model_v1.joblib` and `metrics/eval_metrics_v1.json`.
   - Logs: Search Cloud Logging for "Model trained. MSE:" and "🎉 Model training complete!".
   - Email: Check your inbox for the completion notification.

## Troubleshooting
- **BigQuery Access Denied**:
  - Ensure service account has `roles/bigquery.user` and `roles/bigquery.dataEditor`.
  - Verify scopes include `https://www.googleapis.com/auth/bigquery` (recreate environment if needed).
- **GCS Permission Denied**:
  - Grant `roles/storage.objectAdmin` to the service account on the bucket.
- **Email Not Sent**:
  - Configure SMTP connection or update `to` email in the DAG.
- **DAG Not Appearing**:
  - Check GCS upload and wait 5-10 minutes; ensure file ends in `.py`.
