
setwd("~/Github/virion")
library(tidyverse)
library(vroom)
library(sf)
library(fasterize)

vir <- vroom("Virion/virion.csv.gz")
iucn <- st_read(dsn = 'C:/Users/cjcar/Dropbox/CurrentIUCN',
                layer = 'MAMMALS')

vir %>% filter(HostClass == "mammalia") %>%
  select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

r <- raster::getData("worldclim",var="alt",res=5) # Make a blank raster
map.num.m <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.m <- fasterize(iucn, r, field = "NVirus", fun = 'sum')

############

iucn <- st_read(dsn = 'C:/Users/cjcar/Dropbox/CurrentIUCN',
                layer = 'REPTILES')

vir %>% filter(HostClass == "lepidosauria" | HostOrder == "testudines") %>%
  select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

r <- raster::getData("worldclim",var="alt",res=5) # Make a blank raster
map.num.r <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.r <- fasterize(iucn, r, field = "NVirus", fun = 'sum')

############

iucn <- st_read(dsn = 'C:/Users/cjcar/Dropbox/CurrentIUCN',
                layer = 'AMPHIBIANS')

vir %>% filter(HostClass == "amphibia") %>%
  select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

iucn %>% mutate(binomial = tolower(binomial)) %>%
  left_join(nvir, by = c('binomial' = 'Host')) %>%
  filter(NVirus > 0) -> iucn

r <- raster::getData("worldclim",var="alt",res=5) # Make a blank raster
map.num.a <- fasterize(iucn, r, field = NULL, fun = 'count')
map.sum.a <- fasterize(iucn, r, field = "NVirus", fun = 'sum')

############

library(rgdal)
bl <- st_read(dsn="C:/Users/cjcar/Dropbox/Dan\'s birdlife hole/BOTW.gdb",layer="All_Species")

vir %>% filter(HostClass == "aves") %>%
  select(Host, Virus) %>%
  distinct() %>%
  group_by(Host) %>%
  summarize(NVirus = n_distinct(Virus)) -> nvir

bl %>% mutate(SCINAME = tolower(SCINAME)) %>%
  left_join(nvir, by = c('SCINAME' = 'Host')) %>%
  filter(NVirus > 0) -> bl2

map.num.b <- fasterize(bl2, r, field = NULL, fun = 'count')
map.sum.b <- fasterize(bl2, r, field = "NVirus", fun = 'sum')

library(rasterVis)

s1 <- stack(map.num.m, map.num.b, map.num.r, map.num.a)
names(s1) <- c("Mammals", "Birds", "Reptiles", "Amphibians")
levelplot(log(s1+1), names.attr = names(s1))

s2 <- stack(map.sum.m, map.sum.b, map.sum.r, map.sum.a)
names(s2) <- c("Mammals", "Birds", "Reptiles", "Amphibians")
levelplot(log(s2+1), names.attr = names(s2))

s3 <- stack(map.num.m, map.sum.m,
            map.num.b, map.sum.b,
            map.num.r, map.sum.r,
            map.num.a, map.sum.a)
names(s3) <- c("Mammal (species)", "Mammal (interactions)",
               "Bird (species)", "Bird (interactions)",
               "Reptile (species)", "Reptile (interactions)",
               "Amphibian (species)", "Amphibian (interactions)")            
