################################################################################
# Install Required Packages
# Run this once at the beginning to install all dependencies
################################################################################

# List of packages to install
packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "data.table",     # Fast data manipulation
  "FactoMineR",     # PCA and other multivariate analysis
  "factoextra",     # Visualization of PCA results
  "ggplot2",        # Advanced plotting
  "scales"          # Scaling functions (rescale)
)

# Install packages that are not already installed
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]

if(length(new_packages) > 0) {
  cat("Installing", length(new_packages), "packages...\n")
  install.packages(new_packages)
} else {
  cat("All packages are already installed!\n")
}

# Verify installation
cat("\n=== VERIFYING INSTALLATION ===\n")
for (pkg in packages) {
  if (require(pkg, character.only = TRUE)) {
    cat("✓", pkg, "\n")
  } else {
    cat("✗", pkg, "- FAILED TO LOAD\n")
  }
}

cat("\n=== INSTALLATION COMPLETE ===\n")
