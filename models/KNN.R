library(tidymodels)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

rf <- rand_forest(mtry = tune(),
                  trees = tune(),
                  min_n = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")

rf_wf <- workflow() %>%
  add_model(rf) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(rf)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 5)
rf_res <-
  rf_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

rf_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

rf_res %>% 
  show_best("specificity")

rf_best_param <- select_best(rf_res, "specificity")

rf_final <- rf_wf %>% 
  finalize_workflow(rf_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

rf_fit <- rf_final %>% 
  last_fit(rf_final, metrics=met, split=split)

rf_fit <- rf_final %>% 
  fit(data=train_data)

pred <- predict(rf_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


saveRDS(rf_fit, "models/rf.rds")