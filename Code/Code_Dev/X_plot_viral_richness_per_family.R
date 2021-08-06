# plots of viral richness per host family
# maxwell j farrell (mawellfarrell@gmail.com)
# aug 4, 2021

require(dplyr)
require(vroom)
require(ggplot2)
require(ape)
require(ggtree)
require(cowplot)


virion <- vroom("../../Virion/Virion.csv.gz")

hosttax <- virion %>% select(HostClass, HostOrder, HostFamily, HostGenus, Host) %>% unique()


#### make trees from taxonomic hierarchy

# remove all NAs
hosttax <- hosttax[complete.cases(hosttax),]
dim(hosttax) # 3585 species

# viral richness across host families (per host class)
# example figure: https://yulab-smu.top/treedata-book/chapter7.html#gheatmap

# mammals
# host families
hosts <- hosttax %>% 	filter(HostClass=="mammalia") %>%
						select(HostClass,HostOrder,HostFamily) %>% 
						filter(!is.na(HostOrder)) %>% 
						filter(!is.na(HostFamily)) %>% 
						unique()

hosts <- hosts %>% filter(!HostClass%in%c("actinopterygii"))

# convert to factors
hosts <- as.data.frame(unclass(hosts), stringsAsFactors=TRUE)

# make tree
frm <- ~HostClass/HostOrder/HostFamily
host_tree <- as.phylo(frm, data = hosts, collapse=FALSE)
host_tree$edge.length <- rep(1, nrow(host_tree$edge))

df1 <- virion %>% 		filter(!is.na(HostFamily)) %>%
						group_by(HostFamily) %>% 
						summarise( VIRION = n_distinct(Virus),
								   NCBI = n_distinct(Virus[VirusNCBIResolved==TRUE]), 
								   ICTV = n_distinct(Virus[ICTVRatified==TRUE]), 
								   .groups = 'drop') 

df1$VIRION <- as.numeric(df1$VIRION)
df1$NCBI <- as.numeric(df1$NCBI)
df1$ICTV <- as.numeric(df1$ICTV)

df1 <- as.data.frame(df1)
rownames(df1) <- df1$HostFamily
df1 <- df1 %>% select(-HostFamily)

p <- ggtree(host_tree, layout='fan', open.angle=35)

p_mamms <- gheatmap(p, df1, offset=0, width=0.6,
               colnames_angle=300, colnames_offset_y=0.25, hjust=-0.1) +
				scale_fill_viridis_c(option = "E", name = "Viral richness", 
					na.value = "white", breaks=c(1,10,100,1000), trans="log10")+
				theme(legend.position = c(.5,0.05),legend.direction = "horizontal")
# p_mamms

# ggsave("mammal_families.pdf", pmamms, width=10, height=10)


# Birds

# host families
hosts <- hosttax %>% 	filter(HostClass=="aves") %>%
						select(HostClass,HostOrder,HostFamily) %>% 
						filter(!is.na(HostOrder)) %>% 
						filter(!is.na(HostFamily)) %>% 
						unique()

# convert to factors
hosts <- as.data.frame(unclass(hosts), stringsAsFactors=TRUE)

# make tree
frm <- ~HostClass/HostOrder/HostFamily
host_tree <- as.phylo(frm, data = hosts, collapse=FALSE)
host_tree$edge.length <- rep(1, nrow(host_tree$edge))

df1 <- virion %>% 		filter(!is.na(HostFamily)) %>%
						group_by(HostFamily) %>% 
						summarise( VIRION = n_distinct(Virus),
								   NCBI = n_distinct(Virus[VirusNCBIResolved==TRUE]), 
								   ICTV = n_distinct(Virus[ICTVRatified==TRUE]), 
								   .groups = 'drop') 

df1$VIRION <- as.numeric(df1$VIRION)
df1$NCBI <- as.numeric(df1$NCBI)
df1$ICTV <- as.numeric(df1$ICTV)

df1 <- as.data.frame(df1)
rownames(df1) <- df1$HostFamily
df1 <- df1 %>% select(-HostFamily)

p <- ggtree(host_tree, layout='fan', open.angle=35)

p_aves <- gheatmap(p, df1, offset=0, width=0.6,
               colnames_angle=300, colnames_offset_y=0.25, hjust=-0.1) +
				scale_fill_viridis_c(option = "E", name = "Viral richness", 
					na.value = "white", breaks=c(1,10,100,1000), trans="log10")+
				theme(legend.position = c(.5,0.05),legend.direction = "horizontal")
# p_aves

# ggsave("aves_families.pdf", p_aves, width=10, height=10)


# actinopteri

# host families
hosts <- hosttax %>% 	filter(HostClass%in%c("actinopteri","chondrichthyes","hyperoartia","myxini","cladistia")) %>%
						select(HostClass,HostOrder,HostFamily) %>% 
						filter(!is.na(HostOrder)) %>% 
						filter(!is.na(HostFamily)) %>% 
						unique()

# convert to factors
hosts <- as.data.frame(unclass(hosts), stringsAsFactors=TRUE)

# make tree
frm <- ~HostClass/HostOrder/HostFamily
host_tree <- as.phylo(frm, data = hosts, collapse=FALSE)
host_tree$edge.length <- rep(1, nrow(host_tree$edge))

df1 <- virion %>% 		filter(!is.na(HostFamily)) %>%
						group_by(HostFamily) %>% 
						summarise( VIRION = n_distinct(Virus),
								   NCBI = n_distinct(Virus[VirusNCBIResolved==TRUE]), 
								   ICTV = n_distinct(Virus[ICTVRatified==TRUE]), 
								   .groups = 'drop') 

df1$VIRION <- as.numeric(df1$VIRION)
df1$NCBI <- as.numeric(df1$NCBI)
df1$ICTV <- as.numeric(df1$ICTV)

df1 <- as.data.frame(df1)
rownames(df1) <- df1$HostFamily
df1 <- df1 %>% select(-HostFamily)

p <- ggtree(host_tree, layout='fan', open.angle=35)

p_fish <- gheatmap(p, df1, offset=0, width=0.6,
               colnames_angle=300, colnames_offset_y=0.25, hjust=-0.1) +
				scale_fill_viridis_c(option = "E", name = "Viral richness", 
					na.value = "white", breaks=c(1,10,100,1000), trans="log10") +
				theme(legend.position = c(.5,0.05),legend.direction = "horizontal")
# p_fish

# ggsave("actinopteri_families.pdf", p_fish, width=10, height=10)


# herps

# host families
hosts <- hosttax %>% 	filter(HostClass%in%c("amphibia","lepidosauria")) %>%
						select(HostClass,HostOrder,HostFamily) %>% 
						filter(!is.na(HostOrder)) %>% 
						filter(!is.na(HostFamily)) %>% 
						unique()

# convert to factors
hosts <- as.data.frame(unclass(hosts), stringsAsFactors=TRUE)

# make tree
frm <- ~HostClass/HostOrder/HostFamily
host_tree <- as.phylo(frm, data = hosts, collapse=FALSE)
host_tree$edge.length <- rep(1, nrow(host_tree$edge))

df1 <- virion %>% 		filter(!is.na(HostFamily)) %>%
						group_by(HostFamily) %>% 
						summarise( VIRION = n_distinct(Virus),
								   NCBI = n_distinct(Virus[VirusNCBIResolved==TRUE]), 
								   ICTV = n_distinct(Virus[ICTVRatified==TRUE]), 
								   .groups = 'drop') 

df1$VIRION <- as.numeric(df1$VIRION)
df1$NCBI <- as.numeric(df1$NCBI)
df1$ICTV <- as.numeric(df1$ICTV)

df1 <- as.data.frame(df1)
rownames(df1) <- df1$HostFamily
df1 <- df1 %>% select(-HostFamily)

p <- ggtree(host_tree, layout='fan', open.angle=35)

p_herps <- gheatmap(p, df1, offset=0, width=0.6,
               colnames_angle=300, colnames_offset_y=0.25, hjust=-0.1) +
				scale_fill_viridis_c(option = "E", name = "Viral richness", 
					na.value = "white", breaks=c(1,10,100,1000), trans="log10") +
				theme(legend.position = c(.5,0.05),legend.direction = "horizontal")
# p_herps

# ggsave("herps_families.pdf", p_herps, width=10, height=10)

# hosts %>% select(HostClass, HostOrder) %>% unique()
# reptiles are on top


# plot all inside a 2x2 grid
joint_plot <- plot_grid(p_mamms, p_aves, p_fish, p_herps, nrow=2, ncol=2, 
				labels = c('A) Mammals', 'B) Birds', 'C) Fishes', 'D) Reptiles (top)\nAmphibians (bottom)'),
				align="l")
# joint_plot

ggsave("../../Figures/viral_richness_hostfamilies.pdf", joint_plot, width=12.5, height=12.5)
ggsave("../../Figures/viral_richness_hostfamilies.jpg", joint_plot, width=12.5, height=12.5)


