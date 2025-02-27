
resource "google_service_account" "cloud_run_sa" {
  project      = var.project_id
  account_id   = "${var.name}-cr-sa"
  display_name = "${var.name} Cloud Run Service Account"
}

resource "google_project_iam_member" "firestore_export" {
  project = var.project_id
  role    = "roles/datastore.importExportAdmin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "bigquery_data_editor" {
  project    = var.project_id
  dataset_id = data.google_bigquery_dataset.dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

data "google_bigquery_dataset" "dataset" {
  dataset_id = var.bigquery_dataset
  project    = var.project_id
}

resource "random_uuid" "random" {
}

resource "google_storage_bucket" "export_bucket" {
  project       = var.project_id
  name          = "${var.name}-${random_uuid.random.result}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_member" "bucket" {
  bucket = google_storage_bucket.export_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_v2_job" "default" {
  project  = var.project_id
  location = var.region
  name     = var.name

  deletion_protection = false

  template {
    parallelism = 1
    task_count  = 1

    template {
      service_account = google_service_account.cloud_run_sa.email
      timeout         = "900s"
      max_retries     = 0

      containers {
        image = "google/cloud-sdk:latest"

        env {
          name  = "BUCKET_NAME"
          value = google_storage_bucket.export_bucket.name
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "FIRESTORE_DATABSE"
          value = var.firestore_database
        }

        env {
          name  = "FIRESTORE_COLLECTION"
          value = var.firestore_collection
        }

        env {
          name  = "BQ_DATASET"
          value = var.bigquery_dataset
        }

        command = [
          "/bin/bash",
          "-c",
          <<-EOT
            set -euo pipefail

            PREFIX=$(date +"%Y%m%d-%H%M%S%3N")
            echo "Using prefix: $${PREFIX}"

            # Start the Firestore export for a specific collection.
            echo "Starting Firestore export for collection: $${FIRESTORE_COLLECTION}"
            gcloud firestore export gs://$${BUCKET_NAME}/$${PREFIX} \
                --database="$${FIRESTORE_DATABSE}" \
                --collection-ids="$${FIRESTORE_COLLECTION}" \
                --format="value(name)"

            # Find the export metadata file.
            echo "Locating the export metadata file..."
            METADATA_FILE=$(gsutil ls -r "gs://$${BUCKET_NAME}/$${PREFIX}/**/*.export_metadata" | sort | tail -n 1)
            if [ -z "$${METADATA_FILE}" ]; then
              echo "Error: Could not locate export metadata file."
              exit 1
            fi
            echo "Using metadata file: $${METADATA_FILE}"

            # Load the exported collection into BigQuery.
            echo "Loading data into BigQuery table: $${GCP_PROJECT_ID}:$${BQ_DATASET}.$${FIRESTORE_COLLECTION}"
            bq load \
                --source_format=DATASTORE_BACKUP \
                --replace=true \
                --project_id="$${GCP_PROJECT_ID}" \
                "$${BQ_DATASET}.$${FIRESTORE_COLLECTION}" \
                "$${METADATA_FILE}"
            echo "Data load complete."
          EOT
        ]
      }
    }
  }
}