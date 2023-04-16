library(tidymodels)
library(DALEX)
library(DALEXtra)

xgb <- readRDS("models/xgb.rds")

rf <- readRDS("models/rf.rds")

dt <- readRDS("models/dt.rds")

test_data <- test_data[,c(3:9)]
test_data$Tool_wear <- as.double(test_data$Tool_wear)
test_data$Rotational_speed <- as.double(test_data$Rotational_speed)

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
            B=5)

m2 <- model_parts(explainer = explainer_rf,
                  B=5)

m3 <- model_parts(explainer = explainer_dt,
                  B=5)

plot(m1,m2,m3)
plot(m3)

model_profile(explainer = explainer_rf, "Torque",
              type = "partial") %>% 
  plot(geom = "profiles")

model_profile(explainer = explainer_dt, "Tool_wear",
              type = "partial") %>% 
  plot()

model_profile(explainer = explainer_xgb, "Type",
              type = "partial") %>% 
  plot()

explainer_xgb$data$Tool_wear <- as.numeric(explainer_xgb$data$Tool_wear)

explainer_xgb$data$Tool_wear[6] %>% 
  is.double()
