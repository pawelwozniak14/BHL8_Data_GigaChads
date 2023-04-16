library(tidymodels)
load("data/model_data.rda")
load("models/rf.rda")
pred <- predict(rf_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
rf_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
rf_metrics <- rf_metrics[,-2]
metric_names <- rf_metrics[,1]
rf_metrics <- rf_metrics[,2]
colnames(rf_metrics) <- c("Random Forest")
rf_metrics
metric_names <- matrix(c("F1 score", "Accuracy", "Sensitivity", "Specificity", "Recall", "J index"), ncol=1)
colnames(metric_names) <- c("Metric")
metric_names <- as_tibble(metric_names)
metric_names


load("models/xgb.rda")

pred <- predict(xgb_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
xgb_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
xgb_metrics <- xgb_metrics[,3]
colnames(xgb_metrics) <- c("XGBoost")
xgb_metrics

load("models/svm_poly.rda")

pred <- predict(svm_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
svm_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
svm_metrics <- svm_metrics[,3]
colnames(svm_metrics) <- c("Support Vector Machine")
svm_metrics

load("models/dt.rda")

pred <- predict(dt_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
dt_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
dt_metrics <- dt_metrics[,3]
colnames(dt_metrics) <- c("Decision Tree")
dt_metrics

load("models/LogisticRegression.rda")

pred <- predict(glm_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
glm_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
glm_metrics <- glm_metrics[,3]
colnames(glm_metrics) <- c("Logistic Regression")
glm_metrics

load("models/knn.rda")

pred <- predict(knn_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
knn_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
knn_metrics <- knn_metrics[,3]
colnames(knn_metrics) <- c("K-Nearest Neighbors")
knn_metrics

load("models/NB.rda")

pred <- predict(nb_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
nb_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
nb_metrics <- nb_metrics[,3]
colnames(nb_metrics) <- c("Naive Bayes")
nb_metrics

load("models/bg.rda")

pred <- predict(bg_fit, new_data=test_data)
pred <- cbind(test_data, pred)
conf_mat_rf <- conf_mat(pred, truth=Machine_failure, estimate=.pred_class)
met <- metric_set(f_meas, accuracy, sensitivity, specificity, recall, j_index)
bg_metrics <- met(data=pred, truth=Machine_failure, estimate=.pred_class)
bg_metrics <- bg_metrics[,3]
colnames(bg_metrics) <- c("Bagging")
bg_metrics

summary_table <- metric_names %>% 
  cbind(rf_metrics, xgb_metrics, svm_metrics, dt_metrics, glm_metrics, knn_metrics, nb_metrics, bg_metrics)

save(summary_table, file="model_summary_table.rda")

