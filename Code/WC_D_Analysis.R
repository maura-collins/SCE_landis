#Author: Maura Collins
#Project: WC SCE Data Analysis
#Last Edit Date: 3/27/26

#Inputs: 4x LANDIS biomass files
#Outputs: Combined Set for comparison across simus, graphs, summary stats


#----# #Library
#install.packages("tidyverse")
library(tidyverse)
library(ggplot2)
library(dplyr)
library(stringi)
#install.packages("writexl")
library(writexl)



#----# #Data
##NH - no harvest // H - harvest // ccm - climate RCP8.5 // static - climate 2004
ccmNH <- read.csv("C:/Users/mraco/Desktop/SCE/Data/CCM_NH/AGBiomass__AllYears.csv")
staticNH <- read.csv("C:/Users/mraco/Desktop/SCE/Data/Static_NH/AGBiomass__AllYears.csv")

ccmH <- read.csv("C:/Users/mraco/Desktop/SCE/Data/CCM_H/output/agbiomass/AGBiomass__AllYears.csv")
staticH <- read.csv("C:/Users/mraco/Desktop/SCE/Data/Static_H/output/agbiomass/AGBiomass__AllYears.csv")


#----# #Clean and Create Combined Dataframe
ccmNH_long <- ccmNH %>% pivot_longer(-Time,
                                    names_to = "Species",
                                    values_to = "AGBiomass") %>% #above ground biomass
                      mutate(Simulation = "CCM No Harvest") %>% #capital var names to reduce graphing issues later
                      mutate(Harvest = "No Harvest") %>%
                      mutate(Climate = "Climate Change") 
  
staticNH_long <- staticNH %>% pivot_longer(-Time,
                                          names_to = "Species",
                                          values_to= "AGBiomass") %>% 
                            mutate(Simulation = "Static No Harvest") %>% 
                            mutate(Harvest = "No Harvest") %>%
                            mutate(Climate = "Static") 

staticH_long <- staticH  %>% pivot_longer(-Time,
                                          names_to = "Species",
                                          values_to = "AGBiomass") %>% 
                              mutate(Simulation = "Static Harvest") %>% 
                              mutate(Harvest = "Harvest") %>%
                              mutate(Climate = "Static")

ccmH_long <- ccmH %>% pivot_longer(-Time,
                                    names_to = "Species",
                                    values_to = "AGBiomass") %>% 
                        mutate(Simulation = "CCM Harvest") %>% 
                        mutate(Harvest = "Harvest") %>%
                        mutate(Climate = "Climate Change") 

#combined _r includes the Allsp (sum of biomass at time step), and test spp
combined_r <- bind_rows(ccmNH_long, staticNH_long, ccmH_long, staticH_long) %>%
                      filter(Time <= 100) %>% #simus ran for diff 
                      #times,this clips to minimum time across all simus
                      mutate(carbon_storage = AGBiomass / 2) #Carbon is half biomass


#only species - no test spp (not in region)
drop_spp <- c("AllSpp_g.m2", "pinubank_g.m2", "pinutaed_g.m2")
combined_spp <- combined_r %>% filter(!Species %in% drop_spp)


#only AllSpp
combined_AllSpp <- combined_r %>% filter(Species == "AllSpp_g.m2") %>%
                                  select(-Species)

#path <- "C:/Users/mraco/Desktop/SCE/Data/combined_AllSpp.xlsx"
#write_xlsx(combined_AllSpp, path)


#----# #Graphs

#Compare all 4 simus (basic)

combined_AllSpp %>%
  group_by(Time, Simulation) %>%
  summarise(total_storage = sum(carbon_storage, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = Time, y = total_storage, color = Simulation)) + #color
  #ggplot(aes(x = Time, y = total_storage, linetype = Simulation)) + #black/white
  geom_line(linewidth = 1) +
  labs(title = "Aboveground Carbon Storage Over Time",
       x = "Time (Years)",
       y = expression("Aboveground Carbon Storage (g/m"^2*")"), 
       color = "Simulation" ) +
  theme_bw() + 
  theme(panel.grid.minor = element_blank(),
    panel.grid.major = element_blank())


#Compare all 4 simus (facet by harvest)

combined_AllSpp %>%
  group_by(Time, Climate, Harvest) %>%
  summarise(total_storage = sum(carbon_storage, na.rm = T), .groups = "drop") %>%
  ggplot(aes(x = Time, y = total_storage, color = Climate)) +
  geom_line(linewidth = 1) +
  facet_wrap(~ Harvest) +
  labs(title = "Aboveground Carbon Storage Over Time",
       x = "Time (Years)",
       y = expression("Aboveground Carbon Storage (g/m"^2*")"),
       color = "Climate") +
  theme_bw() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        plot.title = element_text(hjust = 1, size = 14),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.title = element_text(size = 13),
        legend.text = element_text(size = 9),
        strip.text = element_text(size = 13))


#Species follow (eastern white pine and red maple)

follow_spp <- c("pinustro_g.m2", "acerrubr_g.m2")

follow_d <- combined_spp %>%
  filter(Species %in% follow_spp)

# Plot
ggplot(follow_d, aes(x = Time, y = carbon_storage, color = Simulation, shape = Species)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 4, stroke = 1) +
  scale_shape_manual(
    values = c("pinustro_g.m2" = 24, "acerrubr_g.m2" = 16),
    labels = c("pinustro_g.m2" = "Eastern White Pine", "acerrubr_g.m2" = "Red Maple")
  ) +
  scale_x_continuous(breaks = seq(min(follow_d$Time), max(follow_d$Time), by = 10)) +
  scale_y_continuous(breaks = seq(0, max(follow_d$carbon_storage, na.rm = TRUE), by = 500)) +
  labs(
    title = "Mean Carbon Storage of Red Maple and Eastern White Pine Over Time",
    x = "Time (Years)",
    y = "Carbon Storage (g/m²)",
    color = "Simulation",
    shape = "Species"
  ) +
  guides(
    color = guide_legend(order = 1, nrow = 1),   # simulation on its own row
    shape = guide_legend(order = 2, nrow = 1)    # species on its own row below
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.box = "vertical",                     # stack legends vertically
    legend.box.just = "left",                    # align them to the left
    plot.title = element_text(hjust = 0.5),
    aspect.ratio = 0.3
  )


#----# #Statistics

#Mean and Standard Deviation by Simu
mean_sd_simu <- combined_AllSpp %>%
  group_by(Simulation) %>%
  summarise(mean_carbon = mean(carbon_storage, na.rm = TRUE),
            sd_carbon = sd(carbon_storage, na.rm = TRUE))
print(mean_sd_simu)

#Mean and Standard Deviation by Climate 
mean_sd_climate <- combined_AllSpp %>%
  group_by(Climate) %>%
  summarise(mean_carbon = mean(carbon_storage, na.rm = TRUE),
            sd_carbon = sd(carbon_storage, na.rm = TRUE))
print(mean_sd_climate)



#Percent difference between harvest simus - climate change/static
x <- combined_AllSpp %>%
  filter(Time == 100) 

print(x)

#avg difference
combined_AllSpp %>%
  filter(Climate %in% c("Climate Change", "Static")) %>%
  pivot_wider(names_from = Climate, values_from = carbon_storage) %>%
  mutate(diff_cs = `Climate Change` - Static) %>%
  group_by(Harvest) %>%
  summarise(avg_diff_cs = mean(diff_cs, na.rm = TRUE))


#Spp table 
represent_spp <- c("acerrubr_g.m2", "querrubr_g.m2", "pinustro_g.m2", "queralba_g.m2")

spp_table <- combined_spp %>%
  filter(Species %in% represent_spp) %>%
  group_by(Simulation, Species) %>%
  summarise(mean_Carbon_g.m2 = mean(carbon_storage, na.rm = TRUE), .groups = "drop")

path <- "C:/Users/mraco/Desktop/SCE/Data/spp_table.xlsx"
write_xlsx(spp_table, path)

#eastern white pine vs red maple in the ccm harvest 
hardwood_vs_soft<- follow_d %>% filter(Time == 100, Simulation == 'CCM Harvest')
print(((hardwood_vs_soft$carbon_storage[1] - hardwood_vs_soft$carbon_storage[2]) / hardwood_vs_soft$carbon_storage[2]) * 100)




#AUC -  maybe not needed? 
auc_stats <- combined_AllSpp %>%
  group_by(Time, Simulation) %>%
  summarise(total_carbon = sum(carbon_storage, na.rm = TRUE), .groups = "drop") %>%
  group_by(Simulation) %>%
  summarise(AUC = trapz(Time, total_carbon))


auc_percent_diff <- auc_stats %>%
  pivot_wider(names_from = Scenario, values_from = AUC) %>%
  mutate(PercentHigher = ((CCM - Static) / Static) * 100)

print(auc_percent_diff)

print(auc_stats)







