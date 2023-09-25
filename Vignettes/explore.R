#' Data Exploration for Vignettes
#' 
#' There will need to be some Virion vignettes, so taking some time to go thru
#' and figure out what are useful things to add to a vignette
#' 

# set up =======================================================================

virion <- vroom::vroom(here::here("./virion/Virion.csv.gz"))
library(magrittr)

# network-related things =======================================================

virion_g <- igraph::graph_from_data_frame(
  virion,
  directed = TRUE
)

mams_g <- igraph::graph_from_data_frame(
  d = virion[which(virion$HostClass == "mammalia"), ]
)

mams_g_deg <- data.frame(degree = igraph::degree(mams_g)) %>% 
  dplyr::mutate(
    taxa = rownames(.)
  ) %>% 
  dplyr::filter(
    taxa != "homo sapiens"
  )

ggplot2::ggplot(data = mams_g_deg) + 
  ggplot2::geom_histogram(degree)
hist(log10(mams_g_deg$degree))

