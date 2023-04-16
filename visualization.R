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

load("models/dt.rda")
load("models/rf.rda")
load("models/xgb.rda")
load("models/NB.rda")
load("models/bg.rda")
load("models/svm_poly.rda")
load("models/LogisticRegression.rda")
load("models/knn.rda")

glm_pred <- predict(glm_fit, new_data=test_data,type = "prob") %>% 
  bind_cols(test_data)
glm_test_roc <- glm_pred %>% 
  roc_curve(Machine_failure, .pred_0)
glm_pred %>% 
  roc_curve(Machine_failure,.pred_0)

dt_pred <- predict(dt_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
dt_test_roc <- dt_pred %>% 
  roc_curve(Machine_failure,.pred_0)
dt_pred %>% 
  roc_auc(Machine_failure,.pred_0)

rf_pred <- predict(rf_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
rf_test_roc <- rf_pred %>% 
  roc_curve(Machine_failure,.pred_0)
rf_pred %>% 
  roc_auc(Machine_failure,.pred_0)

xgb_pred <- predict(xgb_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
xgb_test_roc <- xgb_pred %>% 
  roc_curve(Machine_failure,.pred_0)
xgb_pred %>% 
  roc_auc(Machine_failure,.pred_0)

svm_pred <- predict(svm_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
svm_test_roc <- svm_pred %>% 
  roc_curve(Machine_failure,.pred_0)
svm_pred %>% 
  roc_auc(Machine_failure,.pred_0)

knn_pred <- predict(knn_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
knn_test_roc <- knn_pred %>% 
  roc_curve(Machine_failure,.pred_0)
knn_pred %>% 
  roc_auc(Machine_failure,.pred_0)

nb_pred <- predict(nb_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
nb_test_roc <- nb_pred %>% 
  roc_curve(Machine_failure,.pred_0)
nb_pred %>% 
  roc_auc(Machine_failure,.pred_0)

bg_pred <- predict(bg_fit, new_data=test_data,type="prob") %>% 
  bind_cols(test_data)
bg_test_roc <- bg_pred %>% 
  roc_curve(Machine_failure,.pred_0)
bg_pred %>% 
  roc_auc(Machine_failure,.pred_0)

curve <- ggplot()+
  geom_path(data=glm_test_roc,aes(x=1-specificity,y=sensitivity,color="#e41a1c"))+
  geom_path(data=dt_test_roc,aes(x = 1 - specificity, y = sensitivity,color="#377eb8"))+
  geom_path(data=rf_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#4daf4a"))+
  geom_path(data=xgb_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#984ea3"))+
  geom_path(data=svm_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#ff7f00"))+
  geom_path(data=knn_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#ffff33"))+
  geom_path(data=nb_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#a65628"))+
  geom_path(data=nb_test_roc,aes(x = 1 - specificity, y = sensitivity,col="#f781bf"))+
  scale_color_identity(name = "Model",
                       breaks = c("#e41a1c", "#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33","#a65628","#f781bf"),
                       labels = c("Logistic Regression", "Decision Tree","Random Forest","XGBoost","Support Vector Machines","K-nearest Neighbors Algorithm","The Naive Bayes","Bagging"),
                       guide = "legend")

saveRDS(curve, file = "plots/curve.rds")
