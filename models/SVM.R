library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_scale(all_numeric_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

svm <- svm_poly(
  margin=tune(),
  cost=tune(),
  degree=tune(),
  scale_factor=tune()
) %>%
  set_engine("kernlab") %>% 
  set_mode("classification")

svm_wf <- workflow() %>%
  add_model(svm) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(svm)
params <- finalize(params, train_data)
grid <- grid_latin_hypercube(params, size = 15)
#lambda_grid <- grid_regular(rbf_sigma(), cost(), levels = 5)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 5)
svm_res <-
  svm_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

svm_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

svm_res %>% 
  show_best("specificity")

svm_best_param <- select_best(svm_res, "specificity")

svm_final <- svm_wf %>% 
  finalize_workflow(svm_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

svm_fit <- svm_final %>% 
  last_fit(svm_final, metrics=met, split=split)

svm_fit <- svm_final %>% 
  fit(data=train_data)

pred <- predict(svm_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


saveRDS(svm_fit, "models/svm_poly.rds")

#linear 0.83, 18/454
#poly 0.88 18/267


