
#setwd("~/Github/virion")
#setwd("C:/Users/roryj/Documents/PhD/202104_virion/virion/")
library(tidyverse)
library(vroom)
library(sf)
library(fasterize)
library(rnaturalearth)
library(raster)



# ------------------------- build geographical coverage rasters for all vert groups ---------------------------

# virion
vir <- vroom("Virion/virion.csv.gz")

# blank raster and extend to antarctica
r <- raster::getData("worldclim",var="alt",res=10) 
r <- raster::raster(ext=extent(c(-180, 180, -90, 90)), crs = crs(r), res=res(r))

##### mammals ####

iucn <- st_read(dsn = 'D:/ResearchProjects/202104_virion/CurrentIUCN',
                layer = 'MAMMALS')

vir %>% filter(HostClass == "mammalia") %>%
  dplyr::select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

map.num.m <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.m <- fasterize(iucn, r, field = "NVirus", fun = 'sum')


# proportion of hosts with verbatim iucn range matches = 91%
n_distinct(iucn$binomial) / n_distinct(nvir$Host)



###### reptiles ######

iucn <- st_read(dsn = 'D:/ResearchProjects/202104_virion/CurrentIUCN',
                layer = 'REPTILES')

vir %>% filter(HostClass == "lepidosauria" | HostOrder == "testudines") %>%
  dplyr::select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

map.num.r <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.r <- fasterize(iucn, r, field = "NVirus", fun = 'sum')

# proportion of hosts with verbatim iucn range matches = 67%
n_distinct(iucn$binomial) / n_distinct(nvir$Host)



###### amphibians ######

iucn <- st_read(dsn = 'D:/ResearchProjects/202104_virion/CurrentIUCN',
                layer = 'AMPHIBIANS')

vir %>% filter(HostClass == "amphibia") %>%
  dplyr::select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

map.num.a <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.a <- fasterize(iucn, r, field = "NVirus", fun = 'sum')

# proportion of hosts with verbatim iucn range matches = 92%
n_distinct(iucn$binomial) / n_distinct(nvir$Host)



###### birds ######

library(rgdal)
bl <- st_read(dsn="D:/ResearchProjects/202104_virion/Dan's birdlife hole/BOTW.gdb", layer="All_Species")

vir %>% filter(HostClass == "aves") %>%
  dplyr::select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

bl %>% mutate(SCINAME = tolower(SCINAME)) %>%
  left_join(nvir, by = c('SCINAME' = 'Host')) %>%
  filter(NVirus > 0) -> bl2

map.num.b <- fasterize(bl2, r, field = NULL, fun = 'count')
map.sum.b <- fasterize(bl2, r, field = "NVirus", fun = 'sum')

# proportion of hosts with verbatim birdlife range matches = 93%
n_distinct(bl2$SCINAME) / n_distinct(nvir$Host)



###### marine fish #####

vir %>% filter(HostClass %in% c("actinopteri", "chondrichthyes", "myxini", "hyperoartia") ) %>%
  dplyr::select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn1 <- st_read('D:/ResearchProjects/202104_virion/MARINEFISH/MARINEFISH_PART1.shp') %>% dplyr::filter(tolower(binomial) %in% nvir$Host)
iucn2 <- st_read('D:/ResearchProjects/202104_virion/MARINEFISH/MARINEFISH_PART2.shp') %>% dplyr::filter(tolower(binomial) %in% nvir$Host)
iucn3 <- st_read('D:/ResearchProjects/202104_virion/MARINEFISH/MARINEFISH_PART3.shp') %>% dplyr::filter(tolower(binomial) %in% nvir$Host)

iucnmf <- do.call(rbind.data.frame, list(iucn1, iucn2, iucn3))

iucnmf %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucnmf

map.num.mf <- fasterize(iucnmf, r, field = NULL, fun = 'count')
map.sum.mf <- fasterize(iucnmf, r, field = "NVirus", fun = 'sum')



###### fw fish #####

iucn1fw <- st_read('D:/ResearchProjects/202104_virion/FW_FISH/FW_FISH_PART1.shp') %>% dplyr::filter(tolower(binomial) %in% nvir$Host)
iucn2fw <- st_read('D:/ResearchProjects/202104_virion/FW_FISH/FW_FISH_PART2.shp') %>% dplyr::filter(tolower(binomial) %in% nvir$Host)

iucnfw <- do.call(rbind.data.frame, list(iucn1fw, iucn2fw))

iucnfw %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucnfw

map.num.fwf <- fasterize(iucnfw, r, field = NULL, fun = 'count')
map.sum.fwf <- fasterize(iucnfw, r, field = "NVirus", fun = 'sum')



##### all fishes ####

iucnf <- do.call(rbind.data.frame, list(iucnmf, iucnfw))

map.num.f <- fasterize(iucnf, r, field = NULL, fun = 'count')
map.sum.f <- fasterize(iucnf, r, field = "NVirus", fun = 'sum')

# 47% of fishes
n_distinct(iucnf$binomial) / n_distinct(nvir$Host)




##### stack and save #####

hosts <- raster::stack(map.num.m, map.num.a, map.num.b, map.num.r, map.num.mf,  map.num.fwf, map.num.f)
names(hosts) <- c("mammal_hosts", "amphibian_hosts", "bird_hosts", "reptile_hosts", "marinefish_hosts", "fwfish_hosts", "fish_hosts")
raster::writeRaster(hosts, file=paste("./Figures/geog_rasters/", names(hosts), ".tif", sep=""), format="GTiff", bylayer=TRUE, overwrite=TRUE)

assocs <- raster::stack(map.sum.m, map.sum.a, map.sum.b, map.sum.r, map.sum.mf, map.sum.fwf, map.sum.f)
names(assocs) <- c("mammal_associations", "amphibian_associations", "bird_associations", "reptile_associations", "marinefish_associations", "fwfish_associations", "fish_associations")
raster::writeRaster(assocs, file=paste("./Figures/geog_rasters/", names(assocs), ".tif", sep=""), format="GTiff", bylayer=TRUE, overwrite=TRUE)





# ----------------------- plot maps -----------------------------

# hosts
hh <- raster::stack(list.files("./Figures/geog_rasters/", pattern="hosts.tif", full.names=TRUE)) 
hh <- raster::stack(
  hh[[ grep("mammal", names(hh)) ]],
  hh[[ grep("bird", names(hh)) ]],
  hh[[ which(names(hh) == "fish_hosts") ]],
  sum(hh[[ grep("reptile|amphib", names(hh)) ]], na.rm=TRUE)
)
names(hh)[4] = "reptileamphib_hosts"

hh <- hh %>%
  raster::as.data.frame(xy=TRUE) %>%
  reshape2::melt(id.vars = 1:2) %>%
  left_join(data.frame(variable=names(hh), plot_name = c("Mammals (hosts)", "Birds (hosts)", "Fishes (hosts)", "Reptiles/Amphibians (hosts)")))

# associations

aa <- raster::stack(list.files("./Figures/geog_rasters/", pattern="associations.tif", full.names=TRUE)) 
aa <- raster::stack(
  aa[[ grep("mammal", names(aa)) ]],
  aa[[ grep("bird", names(aa)) ]],
  aa[[ which(names(aa) == "fish_associations") ]],
  sum(aa[[ grep("reptile|amphib", names(aa)) ]], na.rm=TRUE)
)
names(aa)[4] = "reptileamphib_associations"

aa <- aa %>%
  raster::as.data.frame(xy=TRUE) %>%
  reshape2::melt(id.vars = 1:2) %>%
  left_join(data.frame(variable=names(aa), plot_name = c("Mammals (associations)", "Birds (associations)", "Fishes (associations)", "Reptiles/Amphibians (associations)")))


# plot theme for maps
maptheme <- theme_classic() + 
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.line = element_blank(), 
        axis.ticks = element_blank(),
        plot.title = element_text(hjust=0.5, size=14),
        legend.title = element_text(size=10), 
        strip.background = element_blank(),
        strip.text = element_text(size=16))

# world coastlines
poly <- rnaturalearth::ne_coastline() 

# plot for each group
plotVirRas = function(group, colors = "mako"){
  
  # hosts and assoc
  hx = hh[ grep(group, hh$plot_name), ]
  ax = aa[ grep(group, aa$plot_name), ]
  
  if(colors=="mako"){
    
    ph = ggplot() + 
      geom_raster(data=hx, aes(x=x, y=y, fill=value)) + 
      geom_sf(data=st_as_sf(poly), fill=NA, col="grey40", size=0.2, alpha=0.8) + 
      ggtitle(hx$plot_name[1]) + 
      maptheme + 
      scale_fill_gradientn(colors=rev(viridisLite::mako(200)), na.value = "white") +
      geom_rect(aes(ymin=-90, ymax=90, xmin=-180, xmax=180), fill=NA, color="black", size=0.5) +
      #theme(plot.background = element_rect(fill=NA, color="black")) +
      theme(legend.title=element_blank(), plot.title=element_text(size=15))
    
    pa = ggplot() + 
      geom_raster(data=ax, aes(x=x, y=y, fill=value)) + 
      geom_sf(data=st_as_sf(poly), fill=NA, col="grey40", size=0.2, alpha=0.8) + 
      ggtitle(ax$plot_name[1]) + 
      maptheme + 
      scale_fill_gradientn(colors=rev(viridisLite::mako(200)), na.value = "white") +
      geom_rect(aes(ymin=-90, ymax=90, xmin=-180, xmax=180), fill=NA, color="black", size=0.5) +
      #theme(plot.background = element_rect(fill=NA, color="black")) +
      theme(legend.title=element_blank(), plot.title=element_text(size=15))
  }
  
  if(colors=="turbo"){
    
    ph = ggplot() + 
      geom_raster(data=hx, aes(x=x, y=y, fill=value)) + 
      geom_sf(data=st_as_sf(poly), fill=NA, col="black") + 
      ggtitle(hx$plot_name[1]) + 
      maptheme + 
      scale_fill_gradientn(colors=viridisLite::turbo(200), na.value = "black") +
      geom_rect(aes(ymin=-90, ymax=90, xmin=-180, xmax=180), fill=NA, color="black", size=1) +
      #theme(plot.background = element_rect(fill=NA, color="black")) +
      theme(legend.title=element_blank(), plot.title=element_text(size=15))
    
    pa = ggplot() + 
      geom_raster(data=ax, aes(x=x, y=y, fill=value)) + 
      geom_sf(data=st_as_sf(poly), fill=NA, col="black") + 
      ggtitle(ax$plot_name[1]) + 
      maptheme + 
      scale_fill_gradientn(colors=viridisLite::turbo(200), na.value = "black") +
      geom_rect(aes(ymin=-90, ymax=90, xmin=-180, xmax=180), fill=NA, color="black", size=1) +
      #theme(plot.background = element_rect(fill=NA, color="black")) +
      theme(legend.title=element_blank(), plot.title=element_text(size=15))
  }
  
  # combine
  p_comb = gridExtra::grid.arrange(ph, pa, ncol=2)
  return(p_comb)
  
}

# pm = plotVirRas("Mammal", colors="turbo")
# pb = plotVirRas("Bird", colors="turbo")
# pr = plotVirRas("Reptile", colors="turbo")
# pf = plotVirRas("Fish", colors="turbo")
# 
# ras_plot = gridExtra::grid.arrange(pm, pb, pr, pf, ncol=1)
# ggsave(ras_plot, file="./test_maps_turbo.jpeg", dpi=600, units="in", height=10, width=10)

# plots
pm = plotVirRas("Mammal", colors="mako")
pb = plotVirRas("Bird", colors="mako")
pr = plotVirRas("Reptile", colors="mako")
pf = plotVirRas("Fish", colors="mako")

# combine
ras_plot = gridExtra::grid.arrange(pm, pb, pr, pf, ncol=1)
ggsave(ras_plot, file="./Figures/GeographicalCoverage_Mako.jpeg", dpi=900, units="in", height=11, width=11)





#
# group = "fish_hosts"
# hx = hh[ grep(group, hh$variable), ]
# hx = hh[ hh$variable == group, ]
# 
# ggplot() + 
#   geom_raster(data=hx, aes(x=x, y=y, fill=value)) + 
#   geom_sf(data=st_as_sf(poly), fill=NA, col="black") + 
#   facet_wrap(~variable) + 
#   maptheme + 
#   scale_fill_gradientn(colors=viridisLite::turbo(200), na.value = "black")
# 
# ggplot() + 
#   geom_raster(data=hx, aes(x=x, y=y, fill=value)) + 
#   geom_sf(data=st_as_sf(poly), fill=NA, col="grey20") + 
#   facet_wrap(~variable) + 
#   maptheme + 
#   scale_fill_gradientn(colors=rev(viridisLite::mako(200)), na.value = "white") +
#   geom_rect(aes(ymin=-90, ymax=90, xmin=-180, xmax=180), fill=NA, color="black", size=0.8) +
#   #theme(plot.background = element_rect(fill=NA, color="black")) +
#   theme(legend.title=element_blank())
# 
# 
# 
# 
# # 
# # 
# # 
# # library(rasterVis)
# # 
# # s1 <- stack(map.num.m, map.num.b, map.num.r, map.num.a)
# # names(s1) <- c("Mammals", "Birds", "Reptiles", "Amphibians")
# # levelplot(log(s1+1), names.attr = names(s1))
# # 
# # s2 <- stack(map.sum.m, map.sum.b, map.sum.r, map.sum.a)
# # names(s2) <- c("Mammals", "Birds", "Reptiles", "Amphibians")
# # levelplot(log(s2+1), names.attr = names(s2))
# # 
# # s3 <- stack(map.num.m, map.sum.m,
# #             map.num.b, map.sum.b,
# #             map.num.r, map.sum.r,
# #             map.num.a, map.sum.a)
# # names(s3) <- c("Mammal (species)", "Mammal (interactions)",
# #                "Bird (species)", "Bird (interactions)",
# #                "Reptile (species)", "Reptile (interactions)",
# #                "Amphibian (species)", "Amphibian (interactions)")    
# # 
# # 
# 
