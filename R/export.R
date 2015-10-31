#' @importFrom magrittr %>%
NULL

export <- function() {
  paths <- file.path("recipes", categories$path)
  lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE)

  for (i in seq_len(nrow(recipes))) {
    save_recipe(recipes[i, ])  
  }
}

save_recipe <- function(recipe) {
  recipe <- lapply(recipe, trim)
  
  time <- sum(recipe$cookTime, recipe$preparationTime, na.rm = TRUE)
  
  out <- paste0(
    "# ", fix_name(recipe$name), "\n",
    recipe$source %?% paste0("From: ", recipe$source, "\n"),
    if (time > 0) paste0("Time: ", time, " minutes\n"),
    "\n",
    
    recipe$ingredients %?% bullets(recipe$ingredients),
    "\n\n", 
    recipe$method,
    "\n",
    recipe$comments %?% paste0("\nComments: ", recipe$comments, "\n")
  )
  
  path <- paste0("recipes/", recipe$path, "/", recipe$slug, ".md")
  writeLines(out, path)
  if (!is.na(recipe$updated_on)) {
    system(paste("touch -t ", format(recipe$updated_on, "%Y%m%d%H%M.%S"), " ", path))  
  }
}

trim <- function(x) {
  if (!is.character(x)) {
    return(x)
  }
   
  x <- gsub("\r", "", x)
  x <- gsub("^\n+", "", x)
  x <- gsub("\n+$", "", x)
  
  if (identical(x, "") || identical(x, NA_character_)) character() else x
}

fix_name <- function(x) {
  if (x != toupper(x) && x != tolower(x)) {
    return(x)
  }
  
  x <- tolower(x)
  substring(x, 1, 1) <- toupper(substring(x, 1, 1))
  x
}

bullets <- function(x) {
  lines <- strsplit(x, "\n")[[1]]
  lines <- lines[lines != ""]
  paste0("* ", lines, collapse = "\n")
}