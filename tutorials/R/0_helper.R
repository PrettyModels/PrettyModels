#########
## helper
#########
## delete all png files ----
delete_png_files <- function(directory) {
  # Get list of files in directory and subdirectories
  files <- list.files(directory, recursive = TRUE, full.names = TRUE)
  
  # Filter out .png files
  png_files <- files[grep("\\.png$", files)]
  
  # Delete .png files
  if (length(png_files) > 0) {
    file.remove(png_files)
    cat(paste("Deleted", length(png_files), ".png files\n"))
  } else {
    cat("No .png files found to delete\n")
  }
}

# Specify the directory to search for .png files
directory <- dirname(rstudioapi::getActiveDocumentContext()$path)
directory <- dirname(rstudioapi::getActiveDocumentContext()$path)
directory

# Call the function to delete .png files
delete_png_files(directory)