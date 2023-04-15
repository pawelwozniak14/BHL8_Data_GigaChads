## Wizualizacja

library(tidyverse)
library(ggmosaic)
library(ggcorrplot)

ggplot(na.omit(model_data))+
  geom_mosaic(aes(x = product(Machine_failure), fill=Type), show.legend = F)+
  labs(title = "Zależność usterk od jakościo produktu")+
  theme_mosaic()+
  theme(plot.title = element_text(hjust = 0.5,size=22))
##jedyny mozaikowy który ma chyba sens, ale może lepiej boxplotem

model.matrix(~0+., data=model_data[,-c(1:2)]) %>% 
  cor(use="pairwise.complete.obs") %>% 
  ggcorrplot(show.diag=FALSE, type="lower", lab=TRUE, lab_size=2)
