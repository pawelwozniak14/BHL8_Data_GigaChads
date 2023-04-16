library(tidymodels)
library(DALEX)
library(DALEXtra)

xgb <- readRDS("models/xgb.rds")

test_data <- test_data[,c(3:9)]

rf <- readRDS("models/rf.rds")

explainer_xgb <- explain_tidymodels(xgb,
                                    data = test_data[,-7],
                                    y = as.numeric(test_data$Machine_failure)-1)

explainer_rf <- explain_tidymodels(rf,
                                    data = test_data[,-7],
                                    y = as.numeric(test_data$Machine_failure)-1,
                                   label = "Random forest")

model_profile(explainer = explainer_xgb, "Torque",
              type = "partial")

m1 <- model_parts(explainer = explainer_xgb,
            B=5)

m2 <- model_parts(explainer = explainer_rf,
                  B=5)

plot(m1,m2)
plot(m2)
