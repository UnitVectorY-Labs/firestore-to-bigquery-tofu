variable "name" {
  description = "The name of the application (used for Cloud Run, Subscription, and BigQuery dataset)"
  type        = string
  default     = "firestore-to-biguery"

  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]{1,24}[a-z0-9])$", var.name))
    error_message = "The name must start with a lowercase letter and can contain lowercase letters, numbers, and hyphens. It must be between 2 and 24 characters long."
  }
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.project_id))
    error_message = "The project_id is a GCP project name which starts with a lowercase letter, is 1 to 63 characters long, contains only lowercase letters, digits, and hyphens, and does not end with a hyphen."
  }
}

variable "region" {
  description = "The GCP region to deploy resources to"
  type        = string
}

variable "firestore_database" {
  description = "The Firestore database name"
  type        = string
  default     = "(default)"
}

variable "firestore_collection" {
  description = "The Firestore collection name"
  type        = string
}

variable "bigquery_dataset" {
  description = "The BigQuery dataset name"
  type        = string
}