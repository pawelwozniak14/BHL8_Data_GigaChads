library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

bg <- rand_forest(mtry = 6,
                  trees = tune(),
                  min_n = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")

bg_wf <- workflow() %>%
  add_model(bg) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(bg)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 8)
bg_res <-
  bg_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

bg_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

bg_res %>% 
  show_best("specificity")

bg_best_param <- select_best(bg_res, "specificity")

bg_final <- bg_wf %>% 
  finalize_workflow(bg_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

bg_fit <- bg_final %>% 
  last_fit(rf_final, metrics=met, split=split)

bg_fit <- bg_final %>% 
  fit(data=train_data)

pred <- predict(bg_fit, new_data=test_data)
pred <- cbind(test_data, pred)
metrics(pred, truth=Machine_failure, estimate=.pred_class)
conf_mat <- caret::confusionMatrix(pred$Machine_failure, pred$.pred_class)
conf_mat
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


save(bg_fit,bg_final,bg_res, file="models/bg.rda")



