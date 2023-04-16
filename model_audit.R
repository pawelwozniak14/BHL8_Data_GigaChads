library(tidymodels)
library(DALEX)
library(DALEXtra)


#load("model/xgb.rda")
load("models/dt.rda")
load("models/rf.rda")
dt <- dt_fit
xgb <- readRDS("models/xgb.rds")
rf <- rf_fit

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

m1 <- model_parts(explainer = explainer_xgb,
            B=50)

m2 <- model_parts(explainer = explainer_rf,
                  B=50)

m3 <- model_parts(explainer = explainer_dt,
                  B=50)

save(m1,m2,m3,file = "data/m_parts3.rds")
plot(m1,m2,m3)

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

plot(x1,d1,r1)
plot(x2,d2,r2)
plot(x3,d3,r3)
plot(x4,d4,r4)
plot(x5,d5,r5)
plot(x6,d6,r6)