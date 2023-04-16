library(tidymodels)
library(themis)
library(discrim)
load("data/model_data.rda")

rec <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=train_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  step_smote(Machine_failure) %>% 
  prep()

nb <- naive_Bayes(smoothness = tune(),
                        Laplace = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("klaR",verbose=0)

nb_wf <- workflow() %>%
  add_model(nb) %>% 
  add_recipe(rec)

res <- vfold_cv(train_data, v = 10, strata="Machine_failure")

params <- extract_parameter_set_dials(nb)
params <- finalize(params, train_data)

grid <- grid_latin_hypercube(params, size = 15)

met <- metric_set(f_meas, roc_auc, accuracy, sensitivity, specificity, recall, j_index)

library(doParallel)
registerDoParallel(cores = 8)
nb_res <-
  nb_wf %>%
  tune_grid(
    resamples = res,
    grid = grid,
    metrics = met)

nb_res %>% 
  collect_metrics() %>% 
  flextable::flextable()

nb_res %>% 
  show_best("specificity")

nb_best_param <- select_best(nb_res, "specificity")

nb_final <- nb_wf %>% 
  finalize_workflow(nb_best_param)

rec_test_data <- recipe(Machine_failure~Type+Air_temperature+Process_temperature+Rotational_speed+Torque+Tool_wear, data=test_data) %>% 
  step_dummy(all_factor_predictors()) %>% 
  prep() %>% 
  juice()

nb_fit <- nb_final %>% 
  last_fit(nb_final, metrics=met, split=split)

nb_fit <- nb_final %>% 
  fit(data=train_data)

pred <- predict(nb_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat(pred, truth=Machine_failure, estimate=.pred_class)

save(nb_res, nb_fit, nb_final, file = "models/NB.rda")
# saveRDS(nb_fit, "models/nb.rds")
