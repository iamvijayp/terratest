module "s3-dir-upload" {
  source = "s3_object_folder"

  bucket                = "test_bucket"
  base_folder_path           = path.module # Or, something like "~/abc/xyz/build"
  file_glob_pattern     = "**"
  set_auto_content_type = true
}