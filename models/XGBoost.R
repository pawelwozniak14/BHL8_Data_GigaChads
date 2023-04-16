library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

xgb <- boost_tree(
  trees = tune(),
  min_n = tune(),
  tree_depth = tune(),
  learn_rate = tune(),
  loss_reduction = tune()
) %>%
  set_engine("xgboost") %>% 
  set_mode("classification")

xgb_wf <- workflow() %>%
  add_model(xgb) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(xgb)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 5)
xgb_res <-
  xgb_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

xgb_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

xgb_res %>% 
  show_best("specificity")

xgb_best_param <- select_best(xgb_res, "specificity")

xgb_final <- xgb_wf %>% 
  finalize_workflow(xgb_best_param)

xgb_fit <- xgb_final %>% 
  fit(data=train_data)

pred <- predict(xgb_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)

save(xgb_res, xgb_fit, xgb_final, "models/xgb.rda")
saveRDS(xgb_fit, "models/xgb.rds")
