library(tidymodels)
library(themis)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

glm <-logistic_reg(penalty = tune(), mixture = tune()) %>%
  set_engine("glmnet")


glm_wf <-
  workflow() %>%
  add_model(glm) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

#params <- extract_parameter_set_dials(glm)
#params <- finalize(params, train_data)

#grid <- grid_latin_hypercube(params, size = 15)
grid <- grid_regular(penalty(),mixture(),levels=5)
met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 5)
glm_res <-
  glm_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

glm_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

glm_res %>% 
  show_best("specificity")

glm_best_param <- select_best(glm_res, "specificity")

glm_final <- glm_wf %>% 
  finalize_workflow(glm_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

glm_fit <- glm_final %>% 
  fit(data=train_data)

pred <- predict(glm_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)


saveRDS(glm_fit, "models/LogisticRegression.rds")
