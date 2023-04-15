library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

knn <- nearest_neighbor(weight_func = tune(),
                       dist_power = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("kknn")

knn_wf <- workflow() %>%
  add_model(knn) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(knn)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 8)
knn_res <-
  knn_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

knn_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

knn_res %>% 
  show_best("specificity")

knn_best_param <- select_best(knn_res, "specificity")

knn_final <- knn_wf %>% 
  finalize_workflow(knn_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

knn_fit <- knn_final %>% 
  last_fit(knn_final, metrics=met, split=split)

knn_fit <- knn_final %>% 
  fit(data=train_data)

pred <- predict(knn_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


saveRDS(knn_fit, "models/knn.rds")
