library(tidymodels)
library(DALEX)
library(DALEXtra)


#load("model/xgb.rda")
load("models/dt.rda")
load("models/rf.rda")
load("models/xgb.rda")
load("models/svm_poly.rda")
dt <- dt_fit
xgb <- xgb_fit
rf <- rf_fit
svm <- svm_fit

test_data <- test_data[,c(3:9)]

explainer_xgb <- explain_tidymodels(xgb,
                                    data = test_data[,-7],
                                    y = as.numeric(test_data$Machine_failure)-1,
                                    label = "XGBoost")

explainer_rf <- explain_tidymodels(rf,
                                    data = test_data[,-7],
                                    y = as.numeric(test_data$Machine_failure)-1,
                                   label = "Random forest")

explainer_dt <- explain_tidymodels(dt,
                                   data = test_data[,-7],
                                   y = as.numeric(test_data$Machine_failure)-1,
                                   label = "Decision tree")

explainer_svm <- explain_tidymodels(svm,
                                    data = test_data[,-7],
                                    y = as.numeric(test_data$Machine_failure)-1,
                                    label = "SVM")

m1 <- model_parts(explainer = explainer_xgb,
            B=5)

m2 <- model_parts(explainer = explainer_rf,
                  B=5)

m3 <- model_parts(explainer = explainer_dt,
                  B=5)

m4 <- model_parts(explainer = explainer_svm,
                  B=5)

save(m1,m2,m3,m4,file = "data/m_parts4.rda")
vip_plot <- plot(m1,m2,m3,m4)
saveRDS(vip_plot, file = "plots/vip_plot.rds")

### XGBoost Dependencies plots

x1 <- model_profile(explainer = explainer_xgb, "Rotational_speed",
                    type = "partial")

x2 <- model_profile(explainer = explainer_xgb, "Tool_wear",
              type = "partial")

x3 <- model_profile(explainer = explainer_xgb, "Torque",
                    type = "partial")

x4 <- model_profile(explainer = explainer_xgb, "Air_temperature",
                    type = "partial")

x5 <- model_profile(explainer = explainer_xgb, "Process_temperature",
                    type = "partial")

x6 <- model_profile(explainer = explainer_xgb, "Type",
                    type = "partial")

### Decision tree dependencies

d1 <- model_profile(explainer = explainer_dt, "Rotational_speed",
                    type = "partial")

d2 <- model_profile(explainer = explainer_dt, "Tool_wear",
                    type = "partial")

d3 <- model_profile(explainer = explainer_dt, "Torque",
                    type = "partial")

d4 <- model_profile(explainer = explainer_dt, "Air_temperature",
                    type = "partial")

d5 <- model_profile(explainer = explainer_dt, "Process_temperature",
                    type = "partial")

d6 <- model_profile(explainer = explainer_dt, "Type",
                    type = "partial")

### Random forest dependencies

r1 <- model_profile(explainer = explainer_rf, "Rotational_speed",
                    type = "partial")

r2 <- model_profile(explainer = explainer_rf, "Tool_wear",
                    type = "partial")

r3 <- model_profile(explainer = explainer_rf, "Torque",
                    type = "partial")

r4 <- model_profile(explainer = explainer_rf, "Air_temperature",
                    type = "partial")

r5 <- model_profile(explainer = explainer_rf, "Process_temperature",
                    type = "partial")

r6 <- model_profile(explainer = explainer_rf, "Type",
                    type = "partial")

### SVM dependencies

s1 <- model_profile(explainer = explainer_svm, "Rotational_speed",
                    type = "partial")

s2 <- model_profile(explainer = explainer_svm, "Tool_wear",
                    type = "partial")

s3 <- model_profile(explainer = explainer_svm, "Torque",
                    type = "partial")

s4 <- model_profile(explainer = explainer_svm, "Air_temperature",
                    type = "partial")

s5 <- model_profile(explainer = explainer_svm, "Process_temperature",
                    type = "partial")

s6 <- model_profile(explainer = explainer_svm, "Type",
                    type = "partial")

pdp1 <- plot(x1,d1,r1,s1)
pdp2 <- plot(x2,d2,r2,s2)
pdp3 <- plot(x3,d3,r3,s3)
pdp4 <- plot(x4,d4,r4,s4)
pdp5 <- plot(x5,d5,r5,s5)
pdp6 <- plot(x6,d6,r6,s6)

save(pdp1,pdp2,pdp3,pdp4,pdp5,pdp6,file = "plots/pdp_plots.rda")

### XGBoost Dependencies plots

x11 <- model_profile(explainer = explainer_xgb, "Rotational_speed",
                    type = "accumulated")

x22 <- model_profile(explainer = explainer_xgb, "Tool_wear",
                    type = "accumulated")

x33 <- model_profile(explainer = explainer_xgb, "Torque",
                    type = "accumulated")

x44 <- model_profile(explainer = explainer_xgb, "Air_temperature",
                    type = "accumulated")

x55 <- model_profile(explainer = explainer_xgb, "Process_temperature",
                    type = "accumulated")

x66 <- model_profile(explainer = explainer_xgb, "Type",
                    type = "accumulated")

### Decision tree dependencies

d11 <- model_profile(explainer = explainer_dt, "Rotational_speed",
                    type = "accumulated")

d22 <- model_profile(explainer = explainer_dt, "Tool_wear",
                    type = "accumulated")

d33 <- model_profile(explainer = explainer_dt, "Torque",
                    type = "accumulated")

d44 <- model_profile(explainer = explainer_dt, "Air_temperature",
                    type = "accumulated")

d55 <- model_profile(explainer = explainer_dt, "Process_temperature",
                    type = "accumulated")

d66 <- model_profile(explainer = explainer_dt, "Type",
                    type = "accumulated")

### Random forest dependencies

r11 <- model_profile(explainer = explainer_rf, "Rotational_speed",
                    type = "accumulated")

r22 <- model_profile(explainer = explainer_rf, "Tool_wear",
                    type = "accumulated")

r33 <- model_profile(explainer = explainer_rf, "Torque",
                    type = "accumulated")

r44 <- model_profile(explainer = explainer_rf, "Air_temperature",
                    type = "accumulated")

r55 <- model_profile(explainer = explainer_rf, "Process_temperature",
                    type = "accumulated")

r66 <- model_profile(explainer = explainer_rf, "Type",
                    type = "accumulated")

plot(x11,d11,r11)
plot(x22,d22,r22)
plot(x33,d33,r33)
plot(x44,d44,r44)
plot(x55,d55,r55)
plot(x66,d66,r66)

mperf <- model_performance(explainer_rf)


model_performance(explainer_svm)
model_profile(explainer = explainer_svm, "Process_temperature",
              type = "partial") %>% 
  plot()
