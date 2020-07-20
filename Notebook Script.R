cat("Loading libraries...\n")
library(xgboost)
library(data.table)
library(Matrix)

cat("Reading CSV file...\n")
completeData <- as.data.frame(fread("data.csv", header = TRUE, stringsAsFactors = TRUE))

cat("Splitting data...\n")
train <- subset(completeData, !is.na(completeData$shot_made_flag))
test <- subset(completeData, is.na(completeData$shot_made_flag))

test.id <- test$shot_id
train$shot_id <- NULL
test$shot_id <- NULL

cat("Creating new features...\n")
train$time_remaining <- train$minutes_remaining*60 + train$seconds_remaining
test$time_remaining <- test$minutes_remaining*60 + test$seconds_remaining

cat("Treating features...\n");
train$shot_distance[train$shot_distance > 45] <- 45
test$shot_distance[test$shot_distance > 45] <- 45

cat("Dropping features...\n")
train$seconds_remaining <- NULL
test$seconds_remaining <- NULL
train$team_name <- NULL
test$team_name <- NULL
train$team_id <- NULL
test$team_id <- NULL
train$game_event_id <- NULL
test$game_event_id <- NULL
train$game_id <- NULL
test$game_id <- NULL
train$lat <- NULL
test$lat <- NULL
train$lon <- NULL
test$lon <- NULL

train.y = train$shot_made_flag

train$shot_made_flag <- NULL
test$shot_made_flag <- NULL

pred <- rep(0, nrow(test))

cat("Creating data.matrix...\n")
trainM <- data.matrix(train, rownames.force = NA)
cat("Creating DMarix for xgboost...\n")
dtrain <- xgb.DMatrix(data = trainM, label = train.y, missing = NaN)

watchlist <- list(trainM = dtrain)

set.seed(12345)

param <- list(objective = "binary:logistic", 
              booster = "gbtree",
              eval_metric = "logloss",
              eta = .25, #.035
              max_depth = 3, #4
              subsample = .75, #.8
              colsample_bytree = .6 #.8
              )

clf <- xgb.cv(params = param, 
              data  = dtrain, 
              nrounds = 150, #1500
              verbose = 1,
              watchlist = watchlist,
              maximize = FALSE,
              nfold = 10, #5
              early_stopping_rounds = 20,
              print_every_n = 10
              )

bestRound <- clf$best_iteration
cat("Best round:", bestRound,"\n")
print("Best result:")
print(clf$evaluation_log[clf$best_iteration],"\n")


clf <- xgb.train(params = param, 
                 data = dtrain, 
                 nrounds = bestRound, 
                 verbose = 1,
                 watchlist = watchlist,
                 maximize = FALSE
                 )


testM <-data.matrix(test, rownames.force = NA)
preds <- predict(clf, testM)

submission <- data.frame(shot_id = test.id, shot_made_flag = preds)
cat("Saving the submission file\n")
write.csv(submission, "basicXGBoost.csv", row.names = FALSE)
