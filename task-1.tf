terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
project = "replaceoryouwillfail-87"
region = "us-east1"
zone = "us-east1-b"
credentials = "replaceoryouwillfail-87"
}

resource "google_storage_bucket" "static_site" {
  name          = "russia123abc"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://russia123abc.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_acl" "acl_bucket" {
	bucket = google_storage_bucket.static_site.name
	predefined_acl = "publicRead"
}

resource "google_storage_bucket_object" "upload_html" {
	for_each = fileset("${path.module}/", "*.html")
	bucket = google_storage_bucket.static_site.name
	name = each.value
	source = "${path.module}/${each.value}"
	content_type = "text.html"
}

resource "google_storage_object_acl" "acl_html" {
	for_each = google_storage_bucket_object.upload_html
	bucket = google_storage_bucket_object.upload_html[each.key].bucket
	object = google_storage_bucket_object.upload_html[each.key].name
	predefined_acl = "publicRead"
}

resource "google_storage_bucket_object" "upload_jpg" {
	for_each = fileset("${path.module}/", "*.jpg")
	bucket = google_storage_bucket.static_site.name
	name = each.value
	source = "${path.module}/${each.value}"
	content_type = "image/jpeg"
}

resource "google_storage_object_acl" "acl_jpg" {
	for_each = google_storage_bucket_object.upload_jpg
	bucket = google_storage_bucket_object.upload_jpg[each.key].bucket
	object = google_storage_bucket_object.upload_jpg[each.key].name
	predefined_acl = "publicRead"
}

output "website_url" {
	value = "https://storage.googleapis.com/${google_storage_bucket.static_site.name}/index.html"
}