library(tidymodels)
library(DALEX)

xgb <- readRDS("models/xgb.rds")

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

explain_xgb <- explain(model = xgb,
                       data = test_data[,-c(1:2,9:14)],
                       y = test_data[,9] == "0",
                       type = "classification",
                       label = "XGBoost",
                       predict_function = predict)

model_parts(explainer = explain_xgb,
            B = 10) %>% 
  plot()

rf <- readRDS("models/rf.rds")