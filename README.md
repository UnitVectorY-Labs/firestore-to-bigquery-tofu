# firestore-to-bigquery-tofu

This module automates the scheduled export of Firestore data by triggering Cloud Run jobs that export to Cloud Storage and load the data into BigQuery.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset_iam_member.bigquery_data_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_cloud_run_v2_job.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_job) | resource |
| [google_project_iam_member.bigquery_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.firestore_export](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.cloud_run_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.export_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_uuid.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [google_bigquery_dataset.dataset](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/bigquery_dataset) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bigquery_dataset"></a> [bigquery\_dataset](#input\_bigquery\_dataset) | The BigQuery dataset name | `string` | n/a | yes |
| <a name="input_firestore_collection"></a> [firestore\_collection](#input\_firestore\_collection) | The Firestore collection name | `string` | n/a | yes |
| <a name="input_firestore_database"></a> [firestore\_database](#input\_firestore\_database) | The Firestore database name | `string` | `"(default)"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the application (used for Cloud Run, Subscription, and BigQuery dataset) | `string` | `"firestore-to-biguery"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project id | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy resources to | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
