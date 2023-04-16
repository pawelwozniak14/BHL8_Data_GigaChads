library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

dt <- decision_tree(cost_complexity = tune(),
                    tree_depth = tune(),
                    min_n=tune()) %>% 
  set_engine("rpart") %>% 
  set_mode("classification")

dt_wf <- workflow() %>% 
  add_model(dt) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(dt)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 3)
dt_res <-
  dt_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

dt_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

dt_res %>% 
  show_best("specificity")

dt_best_param <- select_best(dt_res, "specificity")

dt_final <- dt_wf %>% 
  finalize_workflow(dt_best_param)

dt_fit <- dt_final %>% 
  fit(data=train_data)

pred <- predict(dt_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


save(dt_fit, dt_final, dt_res, file="models/dt.rda")
