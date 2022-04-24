from math import log
from sklearn.metrics import r2_score
from hyperopt.pyll import scope
# from sklearn.externals import joblib
import joblib
from sklearn.model_selection import TimeSeriesSplit
from sklearn.utils import shuffle
import os
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
import pandas as pd
import numpy as np
from pandas.io.excel import ExcelWriter
#from GlobalVariables import *
from openpyxl import load_workbook
import sys
from sklearn.feature_selection import RFE
from sklearn.feature_selection import RFECV
from sklearn.feature_selection import SelectFromModel
from sklearn.decomposition import FastICA
from sklearn.feature_selection import GenericUnivariateSelect
from sklearn.feature_selection import VarianceThreshold
from sklearn.model_selection import train_test_split

from BlackBoxes import *
from Functions.ErrorMetrics import *
from Functions.PlotFcn import *

import SharedVariables as SV
print("Start")
########################################################################################################################
def manual_train_test_period_select(Data ,StartDateTrain, EndDateTrain, StartDateTest, EndDateTest):
    Data_TrainTest = Data[StartDateTrain:EndDateTrain]  #is used to train the model and evaluate the hyperparameter
    Data_Test = Data[StartDateTest:EndDateTest]         #is used to perform a "forecast" with the trained Model
    return (Data_TrainTest, Data_Test)

def visualization_documentation(NameOfPredictor, Y_Predicted, Y_test, Indexer, Y_train, ComputationTime,
                                ResultsFolderSubTest, HyperparameterGrid=None, Bestparams=None, CV=3, Max_eval=None,
                                Recursive=False, IndividualModel=False, Shuffle=SV.GlobalShuffle,
                                FeatureImportance="Not available"):
    if os.path.isfile(os.path.join(SV.ResultsFolder, "ScalerTracker.save")): #if scaler was used
        ScaleTracker_Signal = joblib.load(os.path.join(SV.ResultsFolder, "ScalerTracker.save")) #load used scaler
        #Scale Results back to normal; maybe inside the Blackboxes
        Y_Predicted= ScaleTracker_Signal.inverse_transform(SV.reshape(Y_Predicted))
        Y_test = ScaleTracker_Signal.inverse_transform(SV.reshape(Y_test))
        # convert arrays to data frames(Series) for further use
        Y_test = pd.DataFrame(index=Indexer, data=Y_test, columns=["Measure"])
        Y_test = Y_test["Measure"]

    #convert arrays to data frames(Series) for further use
    Y_Predicted = pd.DataFrame(index=Indexer, data=Y_Predicted, columns=["Prediction"])
    Y_Predicted = Y_Predicted["Prediction"]


    # evaluate results with more error metrics
    (R2, STD, RMSE, MAPE, MAE) = evaluation(Y_test, Y_Predicted)

    #Plot Results
    plot_predict_measured(prediction=Y_Predicted, measurement=Y_test, MAE=MAE, R2=R2, StartDatePredict=SV.StartTesting,
                          SavePath=ResultsFolderSubTest, nameOfSignal=SV.NameOfSignal, BlackBox=NameOfPredictor,
                          NameOfSubTest=SV.NameOfSubTest)
    plot_Residues(prediction=Y_Predicted, measurement=Y_test, MAE=MAE, R2=R2, SavePath=ResultsFolderSubTest,
                  nameOfSignal=SV.NameOfSignal, BlackBox=NameOfPredictor, NameOfSubTest=SV.NameOfSubTest)

    # save summary of setup and evaluation
    dfSummary = pd.DataFrame(index=[0])
    dfSummary['Estimator'] = NameOfPredictor
    if Y_train is not None: #don´t document this if "onlypredict" is used
        dfSummary['Start_date_Fit'] = SV.StartTraining
        dfSummary['End_date_Fit'] = SV.EndTraining
    dfSummary['Start_date_Predict'] = SV.StartTesting
    dfSummary['End_date_Predict'] = SV.EndTesting
    if Y_train is not None: #don´t document this if "onlypredict" is used
        dfSummary['Total Train Samples'] = len(Y_train.index)
    dfSummary['Test Samples'] = len(Y_test.index)
    dfSummary['Recursive'] = Recursive
    dfSummary['Shuffle'] = Shuffle
    if HyperparameterGrid is not None:
        dfSummary['Range Hyperparameter'] = str(HyperparameterGrid)
        dfSummary['CrossValidation'] = str(CV)
        dfSummary['Best Hyperparameter'] = str(Bestparams)
        if Max_eval is not None:
            dfSummary['Max Bayesian Evaluations'] = str(Max_eval)
    dfSummary["Feature importance"] = str(FeatureImportance)
    dfSummary['Individual model'] = IndividualModel
    if IndividualModel == "byFeature":
        dfSummary['IndivFeature'] = IndivFeature
        dfSummary['IndivThreshold'] = IndivThreshold
    dfSummary['Eval_R2'] = R2
    dfSummary['Eval_RMSE'] = RMSE
    dfSummary['Eval_MAPE'] = MAPE
    dfSummary['Eval_MAE'] = MAE
    dfSummary['Standard deviation'] = STD
    dfSummary['Computation Time'] = "%.2f seconds" %ComputationTime
    dfSummary = dfSummary.T
    # write summary of setup and evaluation in excel File
    SummaryFile = os.path.join(ResultsFolderSubTest, "Summary_%s_%s.xlsx"%(NameOfPredictor, SV.NameOfSubTest))
    writer = pd.ExcelWriter(SummaryFile)
    dfSummary.to_excel(writer, float_format='%.6f')
    writer.save()

    # export prediction to Excel
    SaveFileName_excel = os.path.join(ResultsFolderSubTest ,"Prediction_%s_%s.xlsx" %(NameOfPredictor, SV.NameOfSubTest))
    Y_Predicted.to_frame(name=SV.NameOfSignal).to_excel(SaveFileName_excel)

    #return Score for modelselection
    if SV.score_type == 'R^2 ':
        SV.output_value = R2
        return R2
    elif SV.score_type == 'RMSE':
        SV.output_value = RMSE
        return RMSE
    else:
        raise NameError('The selected score_type is not available in visualization_documentation')

def getscore(Y_Predicted, Y_test, Indexer):
    if os.path.isfile(os.path.join(SV.ResultsFolder, "ScalerTracker.save")): #if scaler was used
        ScaleTracker_Signal = joblib.load(os.path.join(SV.ResultsFolder , "ScalerTracker.save")) #load used scaler
        #Scale Results back to normal; maybe inside the Blackboxes
        Y_Predicted= ScaleTracker_Signal.inverse_transform(SV.reshape(Y_Predicted))
        Y_test = ScaleTracker_Signal.inverse_transform(SV.reshape(Y_test))
        # convert arrays to data frames(Series) for further use
        Y_test = pd.DataFrame(index=Indexer, data=Y_test, columns=["Measure"])
        Y_test = Y_test["Measure"]

    #convert arrays to data frames(Series) for further use
    Y_Predicted = pd.DataFrame(index=Indexer, data=Y_Predicted, columns=["Prediction"])
    Y_Predicted = Y_Predicted["Prediction"]

    # evaluate results
    R2 = r2_score(Y_test, Y_Predicted)
    RMSE = rmse(Y_test, Y_Predicted)

    #return Score for modelselection
    if SV.score_type == 'R^2 ':
        return R2
    elif SV.score_type == 'RMSE':
        return RMSE
    else:
        raise NameError('The selected score_type is not available in getscore')

#saves the BestModels in a folder "BestModels", also capable of saving individual models
def model_saver(Result_dic, ResultsFolderSubTest, NameOfPredictor, IndividualModel):
    if os.path.isdir(os.path.join(ResultsFolderSubTest,"BestModels")) == True:
        pass
    else:
        os.makedirs(os.path.join(ResultsFolderSubTest, "BestModels"))

    if IndividualModel=="week_weekend":
        joblib.dump(Result_dic["Best_trained_model"]["weekday"], os.path.join(ResultsFolderSubTest, "BestModels", "weekday_%s.save" % (NameOfPredictor)))  # dump the best trained model in a file to reuse it for different predictions
        joblib.dump(Result_dic["Best_trained_model"]["weekend"], os.path.join(ResultsFolderSubTest, "BestModels", "weekend_%s.save" % (NameOfPredictor)))  # dump the best trained model in a file to reuse it for different predictions
    elif IndividualModel=="hourly":
        joblib.dump(Result_dic["Best_trained_model"][0], os.path.join(ResultsFolderSubTest, "BestModels", "0_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][1], os.path.join(ResultsFolderSubTest, "BestModels", "1_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][2], os.path.join(ResultsFolderSubTest, "BestModels", "2_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][3], os.path.join(ResultsFolderSubTest, "BestModels", "3_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][4], os.path.join(ResultsFolderSubTest, "BestModels", "4_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][5], os.path.join(ResultsFolderSubTest, "BestModels", "5_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][6], os.path.join(ResultsFolderSubTest, "BestModels", "6_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][7], os.path.join(ResultsFolderSubTest, "BestModels", "7_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][8], os.path.join(ResultsFolderSubTest, "BestModels", "8_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][9], os.path.join(ResultsFolderSubTest, "BestModels", "9_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][10], os.path.join(ResultsFolderSubTest, "BestModels", "10_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][11], os.path.join(ResultsFolderSubTest, "BestModels", "11_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][12], os.path.join(ResultsFolderSubTest, "BestModels", "12_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][13], os.path.join(ResultsFolderSubTest, "BestModels", "13_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][14], os.path.join(ResultsFolderSubTest, "BestModels", "14_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][15], os.path.join(ResultsFolderSubTest, "BestModels", "15_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][16], os.path.join(ResultsFolderSubTest, "BestModels", "16_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][17], os.path.join(ResultsFolderSubTest, "BestModels", "17_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][18], os.path.join(ResultsFolderSubTest, "BestModels", "18_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][19], os.path.join(ResultsFolderSubTest, "BestModels", "19_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][20], os.path.join(ResultsFolderSubTest, "BestModels", "20_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][21], os.path.join(ResultsFolderSubTest, "BestModels", "21_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][22], os.path.join(ResultsFolderSubTest, "BestModels", "22_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"][23], os.path.join(ResultsFolderSubTest, "BestModels", "23_%s.save" % (NameOfPredictor)))
    elif IndividualModel == "byFeature":
        joblib.dump(Result_dic["Best_trained_model"]["above"], os.path.join(ResultsFolderSubTest, "BestModels", "above_%s.save" % (NameOfPredictor)))
        joblib.dump(Result_dic["Best_trained_model"]["below"], os.path.join(ResultsFolderSubTest, "BestModels", "below_%s.save" % (NameOfPredictor)))
    else:
        joblib.dump(Result_dic["Best_trained_model"], os.path.join(ResultsFolderSubTest, "BestModels", "%s.save" % (NameOfPredictor)))

#-----------------------------------------------------------------------------------------------------------------------
#Section BlackBoxes
class BB():
    'This Class uses the in BlackBoxes.py defined machine learning "predictors" for training, predicting and documentation.'
    def __init__(self, Estimator, HyperparameterGrid = "None", HyperparameterGridString = "None"):
        self.Estimator = Estimator
        self.HyperparameterGrid = HyperparameterGrid
        self.HyperparameterGridString = HyperparameterGridString

    def train_predict(self, _X_train, _Y_train, _X_test, _Y_test, Indexer="IndexerError", IndividualModel="Error", Documentation=False):
        NameOfPredictor = self.Estimator.__name__
        if IndividualModel == "week_weekend":
            indivweekweekend = indiv_model(indiv_splitter_instance=indiv_splitter(week_weekend_splitter),
                                           Estimator=self.Estimator, Features_train=_X_train, Signal_train=_Y_train,
                                           Features_test=_X_test, Signal_test=_Y_test,
                                           HyperparameterGrid=self.HyperparameterGrid, CV=SV.GlobalCV_MT,
                                           Max_evals=SV.GlobalMaxEval_HyParaTuning, Recursive=SV.GlobalRecu)
            Result_dic = indivweekweekend.main()
        elif IndividualModel == "hourly":
            indivhourly = indiv_model(indiv_splitter_instance=indiv_splitter(hourly_splitter),
                                      Estimator=self.Estimator, Features_train=_X_train, Signal_train=_Y_train,
                                      Features_test=_X_test, Signal_test=_Y_test,
                                      HyperparameterGrid=self.HyperparameterGrid, CV=SV.GlobalCV_MT,
                                      Max_evals=SV.GlobalMaxEval_HyParaTuning, Recursive=SV.GlobalRecu)
            Result_dic = indivhourly.main()
        elif IndividualModel == "byFeature":
            byFeaturesplitter = byfeature_splitter(SV.IndivThreshold, SV.IndivFeature, _X_test, _X_train)
            indivbyfeature = indiv_model(indiv_splitter_instance=indiv_splitter(byFeaturesplitter.splitter),
                                         Estimator=self.Estimator, Features_train=_X_train, Signal_train=_Y_train,
                                         Features_test=_X_test, Signal_test=_Y_test,
                                         HyperparameterGrid=self.HyperparameterGrid, CV=SV.GlobalCV_MT,
                                         Max_evals=SV.GlobalMaxEval_HyParaTuning, Recursive=SV.GlobalRecu)
            Result_dic = indivbyfeature.main()
        else:
            Result_dic = self.Estimator(Features_train=_X_train, Signal_train=_Y_train, Features_test=_X_test,
                                        Signal_test=_Y_test, HyperparameterGrid=self.HyperparameterGrid, CV=SV.GlobalCV_MT,
                                        Max_evals = SV.GlobalMaxEval_HyParaTuning, Recursive=SV.GlobalRecu)

        Predicted = Result_dic["prediction"]
        Bestparams = Result_dic["best_params"]
        ComputationTime = Result_dic["ComputationTime"]
        FeatureImportance = Result_dic["feature_importance"]
        if Documentation == True:  # only do documentation if Documentation is wished(Documentation is False from beginning, and only in the end set True)
            Score = visualization_documentation(NameOfPredictor, Predicted, _Y_test, Indexer, _Y_train, ComputationTime,
                                                SV.ResultsFolderSubTest,
                                                self.HyperparameterGridString, Bestparams, SV.GlobalCV_MT, SV.GlobalMaxEval_HyParaTuning, SV.GlobalRecu,
                                                IndividualModel, SV.GlobalShuffle, FeatureImportance)
            # only dump if it´s the last best one(marked by Documentation=True)
            model_saver(Result_dic, SV.ResultsFolderSubTest, NameOfPredictor, IndividualModel)
        else:
            Score = getscore(Predicted, _Y_test, Indexer) #Todo: Make possible to set scoring function by yourself
        return Score

#Initiate the blackboxes
#Info: Make sure the HyperparameterGrid is always equal to the HyperparameterGridString for correct documentation
HyperparameterGrid1= [{'gamma': [10000.0, 1000, 100, 10, 1, 0.1, 0.01, 0.001, 0.0001, 'auto'], 'C': [10000.0, 1000, 100, 10, 1, 0.1, 0.01, 0.001, 0.0001], 'epsilon': [1, 1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6]}]
BB1 = BB(svr_grid_search_predictor, HyperparameterGrid1, str(HyperparameterGrid1))

HyperparameterGrid2 = {"C": hp.loguniform("C", log(1e-4), log(1e4)), "gamma": hp.loguniform("gamma", log(1e-3), log(1e4)), "epsilon": hp.loguniform("epsilon", log(1e-4), log(1))}  # with loguniform(-6, 23.025) spans a range from 1e-3 to 1e10
HyperparameterGridString2 = """{"C": hp.loguniform("C", log(1e-4), log(1e4)), "gamma":hp.loguniform("gamma", log(1e-3),log(1e4)), "epsilon":hp.loguniform("epsilon", log(1e-4), log(1))}"""  # set this as a string in order to have a exact"screenshot" of the hyperparametergrid to save it in the summary
BB2 = BB(svr_bayesian_predictor, HyperparameterGrid2, HyperparameterGridString2)

BB3 = BB(rf_predictor, None, None)

HyperparameterGrid4 = [{'hidden_layer_sizes':[[1],[10],[100],[1000],[1, 1],[10, 10], [100, 100],[1,10],[1,100],[10,100],[100,10],[100,1],[10,1],[1, 1, 1],[10, 10, 10],[100,100,100]]}]
BB4 = BB(ann_grid_search_predictor, HyperparameterGrid4, str(HyperparameterGrid4))

#changed Laura
HyperparameterGrid5 = hp.choice("number_of_layers",
                               [
                                   {"1layer": scope.int(hp.qloguniform("1.1", log(1), log(210), 1))},
                                   {"2layer": [scope.int(hp.qloguniform("1.2", log(1), log(105), 1)),
                                               scope.int(hp.qloguniform("2.2", log(1), log(105), 1))]},
                                   {"3layer": [scope.int(hp.qloguniform("1.3", log(1), log(70), 1)),
                                               scope.int(hp.qloguniform("2.3", log(1), log(70), 1)),
                                               scope.int(hp.qloguniform("3.3", log(1), log(70), 1))]}
                               ])
HyperparameterGridString5 = """hp.choice("number_of_layers",
                    [
                    {"1layer": scope.int(hp.qloguniform("1.1", log(1), log(210), 1))},
                    {"2layer": [scope.int(hp.qloguniform("1.2", log(1), log(105), 1)), scope.int(hp.qloguniform("2.2", log(1), log(105), 1))]},
                    {"3layer": [scope.int(hp.qloguniform("1.3", log(1), log(70), 1)), scope.int(hp.qloguniform("2.3", log(1), log(70), 1)), scope.int(hp.qloguniform("3.3", log(1), log(70), 1))]}
                    ])"""  # set this as a string in order to have a exact"screenshot" of the hyperparametergrid to save it in the summary
BB5 = BB(ann_bayesian_predictor, HyperparameterGrid5, HyperparameterGridString5)

HyperparameterGrid6 = [{'n_estimators': [10, 100, 1000], 'max_depth': [1, 10, 100], 'learning_rate': [0.01, 0.1, 0.5, 1], 'loss': ['ls', 'lad', 'huber', 'quantile']}] #Learning_rate in range 0 to 1
BB6 = BB(gradientboost_gridsearch, HyperparameterGrid6, str(HyperparameterGrid6))

HyperparameterGrid7 = {"n_estimators": scope.int(hp.qloguniform("n_estimators", log(1), log(1e3), 1)), "max_depth": scope.int(hp.qloguniform("max_depth", log(1),log(100), 1)), "learning_rate":hp.loguniform("learning_rate", log(1e-2), log(1)), "loss":hp.choice("loss",["ls", "lad", "huber", "quantile"])} #if anything except numbers is changed, please change the respective code lines for converting notation style in the gradienboost_bayesian function
HyperparameterGridString7 = """{"n_estimators": scope.int(hp.qloguniform("n_estimators", log(1), log(1e3), 1)), "max_depth": scope.int(hp.qloguniform("max_depth", log(1),log(100), 1)), "learning_rate":hp.loguniform("learning_rate", log(1e-2), log(1)), "loss":hp.choice("loss",["ls", "lad", "huber", "quantile"])}"""  # set this as a string in order to have a exact"screenshot" of the hyperparametergrid to save it in the summary
BB7 = BB(gradientboost_bayesian, HyperparameterGrid7, HyperparameterGridString7)

HyperparameterGrid8 = [{'alpha': [1000000, 100000, 10000, 1000, 100, 10, 1, 0.1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9, 1e-10]}]
BB8 = BB(lasso_grid_search_predictor, HyperparameterGrid8, str(HyperparameterGrid8))

HyperparameterGrid9 = {"alpha": hp.loguniform("alpha", log(1e-10), log(1e6))}
HyperparameterGridString9 = """{"alpha": hp.loguniform("alpha", log(1e-10), log(1e6))}"""  # set this as a string in order to have a exact"screenshot" of the hyperparametergrid to save it in the summary
BB9 = BB(lasso_bayesian, HyperparameterGrid9, str(HyperparameterGridString9))

def modelselection(_X_train, _Y_train, _X_test, _Y_test, Indexer="IndexerError", IndividualModel="Error", Documentation=False):
    #Trains and tests all (bayesian) models and returns the best of them, also saves it in an txtfile.
    Score_RF = BB3.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    Score_ANN = BB5.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    Score_GB = BB7.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    Score_Lasso = BB9.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    Score_SVR = BB2.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)

    Score_list = [0,1,2,3,4]
    Score_list[0]=Score_SVR
    Score_list[1]=Score_RF
    Score_list[2]=Score_ANN
    Score_list[3]=Score_GB
    Score_list[4]=Score_Lasso

    print(Score_list)
    #Todo: if Scoring function Score max; if Scoring function some error: min
    BestScore = max(Score_list)

    if Score_list[0]==BestScore:
        __BestModel = "SVR"
    if Score_list[1] == BestScore:
        __BestModel = "RF"
    if Score_list[2] == BestScore:
        __BestModel = "ANN"
    if Score_list[3] == BestScore:
        __BestModel = "GB"
    if Score_list[4] == BestScore:
        __BestModel = "Lasso"

    #state best model in txt file
    f = open(os.path.join(SV.ResultsFolderSubTest, "BestModel.txt"), "w+")
    f.write("The best model is %s with an accuracy of %s" %(__BestModel, BestScore))
    f.close()
    return BestScore
#-----------------------------------------------------------------------------------------------------------------------
def embedded__recursive_feature_selection(_X_train, _Y_train, _X_test, _Y_test, Estimator, N_features_to_select, CV, Documentation=False):
    #Special feature selection method for the feature selection within the final bayesian optimization (def Bayes())
    def index_column_keeper(X_Data, Y_Data, support, X_Data_transformed):
        columns = X_Data.columns
        rows = X_Data.index
        labels = [columns[x] for x in support if
                  x >= 0]  # get the columns which shall be kept by the transformer(the selected features)
        X = pd.DataFrame(X_Data_transformed, columns=labels,
                                index=rows)  # creates a dataframe reassigning the names of the features as column header and the index as index
        Y = pd.DataFrame(Y_Data, columns=[SV.NameOfSignal])  # create dataframe of y
        return X, Y
    if N_features_to_select == "automatic":
        selector = RFECV(estimator=Estimator, step=1, cv=CV)
        selector = selector.fit(_X_train, _Y_train)
        print("Ranks of all Features %s" %selector.ranking_)
        Features_transformed = selector.transform(_X_train)
        Features_transformed_test = selector.transform(_X_test)
        Features_transformed, _Y_train = index_column_keeper(_X_train, _Y_train, selector.get_support(indices=True), Features_transformed)
        Features_transformed_test, _Y_test = index_column_keeper(_X_test, _Y_test, selector.get_support(indices=True), Features_transformed_test)
    else:
        selector = RFE(estimator=Estimator, n_features_to_select=N_features_to_select, step=1)
        selector = selector.fit(_X_train, _Y_train)
        print("Ranks of all Features %s" %selector.ranking_)
        Features_transformed = selector.transform(_X_train)
        Features_transformed_test = selector.transform(_X_test)
        Features_transformed, _Y_train = index_column_keeper(_X_train, _Y_train, selector.get_support(indices=True), Features_transformed)
        Features_transformed_test, _Y_test = index_column_keeper(_X_test, _Y_test, selector.get_support(indices=True), Features_transformed_test)

    if Documentation==False:
        return Features_transformed, _Y_train, Features_transformed_test, _Y_test
    if Documentation==True:
        def merge_signal_and_features_embedded(X_Data, Y_Data, support, X_Data_transformed): #Todo: could be pulled directly from SharedVariables (check for how to get the right "NameOfSignal"
            columns = X_Data.columns
            rows = X_Data.index
            labels = [columns[x] for x in support if
                      x >= 0]  # get the columns which shall be kept by the transformer(the selected features)
            Features = pd.DataFrame(X_Data_transformed, columns=labels,
                                    index=rows)  # creates a dataframe reassigning the names of the features as column header and the index as index
            Signal = pd.DataFrame(Y_Data, columns=[SV.NameOfSignal])  # create dataframe of y
            Data = pd.concat([Signal, Features], axis=1)
            return Data
        _Data_Train=merge_signal_and_features_embedded(_X_train, _Y_train,selector.get_support(indices=True), Features_transformed) #merge signal and features
        _Data_Test=merge_signal_and_features_embedded(_X_test,_Y_test,selector.get_support(indices=True),Features_transformed_test) #merge signal and features
        BestData = pd.concat([_Data_Train, _Data_Test], axis=0) #merge test and train period back together
        return Features_transformed, _Y_train, Features_transformed_test, _Y_test, BestData


def all_models(Model, _X_train, _Y_train, _X_test, _Y_test, Indexer="IndexerError", IndividualModel="Error",
               Documentation=False):
    # This function is just to "centralize" the train and predict operations so that additional options can be added easier
    if Model == "SVR":
        Score = BB2.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "RF":
        Score = BB3.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "ANN":
        Score = BB5.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "GB":
        Score = BB7.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "Lasso":
        Score = BB9.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "ModelSelection":
        Score = modelselection(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "SVR_grid":
        Score = BB1.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "ANN_grid":
        Score = BB4.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "GB_grid":
        Score = BB6.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    if Model == "Lasso_grid":
        Score = BB8.train_predict(_X_train, _Y_train, _X_test, _Y_test, Indexer, IndividualModel, Documentation)
    return Score

def pre_handling(OnlyPredict):
    #define path to data source files '.xls' & '.pickle'
    RootDir = os.path.dirname(os.path.realpath(__file__))
    PathToData = os.path.join(RootDir, 'Data')

    #Set Folder for Results
    ResultsFolder = os.path.join(RootDir, "Results", SV.NameOfData, SV.NameOfExperiment)
    PathToPickles = os.path.join(ResultsFolder, "Pickles")

    SV.RootDir = RootDir
    SV.PathToData = PathToData
    SV.ResultsFolder = ResultsFolder
    SV.PathToPickles = PathToPickles

    ResultsFolderSubTest = os.path.join(SV.ResultsFolder, 'Predictions', SV.NameOfSubTest)
    SV.ResultsFolderSubTest = ResultsFolderSubTest

    #check if experiment folder is present
    if os.path.isdir(SV.ResultsFolder) == False:
        print(SV.ResultsFolder)
        sys.exit("Set a valid experiment folder via NameOfData and NameOfExperiment")

    #check if test results are safed in the right folder:
    if OnlyPredict != True:
        if os.path.isdir(SV.ResultsFolderSubTest) == True:
            Answer = input("Are you sure you want to overwrite the data in %s: " % SV.ResultsFolderSubTest)
            if Answer == "yes" or Answer == "Yes" or Answer == "y" or Answer == "Y":
                print("Start computing")
            else:
                sys.exit("Code stopped by user or invalid user input. Valid is Yes, yes, y and Y.")
        else:
            os.makedirs(SV.ResultsFolderSubTest)

    #Take Tuned data, build Train and Test Sets, and split them into signal and features
    NameOfSignal = joblib.load(os.path.join(SV.ResultsFolder, "NameOfSignal.save"))
    SV.NameOfSignal = NameOfSignal #Todo: check whether NameOfSignal fits with GUI (maybe one wants to define it by himself)

    # Take FinalInputData, build Train and Test Sets, and split them into signal and features
    if OnlyPredict == True:
        ImportBaye = os.path.isfile(os.path.join(SV.ResultsFolderSubTest, "BestData_%s.xlsx"%(SV.NameOfSubTest))) #is True if FinalBayes was used, this implies that we want to load the data that was produced by finalbayes
    else:
        ImportBaye = False #if onlypredict isn´t used we (up to now) don´t want to load from finalbayes
    if  ImportBaye == False:
        Data = pd.read_pickle(os.path.join(SV.PathToPickles, "ThePickle_from_FeatureSelection" + '.pickle')) #import from data tuning
    if ImportBaye == True:
        Data = pd.read_pickle(os.path.join(SV.PathToPickles, "ThePickle_from_%s" %SV.NameOfSubTest + '.pickle')) #import the data set produced by "final bayesian optimization"

    (Data_Train, Data_Test) = manual_train_test_period_select(Data=Data, StartDateTrain=SV.StartTraining, EndDateTrain= SV.EndTraining, StartDateTest=SV.StartTesting, EndDateTest=SV.EndTesting)

    #shuffles data randomly if wished
    if SV.GlobalShuffle == True:
        Data_Train = shuffle(Data_Train)
        #Data_Test = shuffle(Data_Test) #not necessary since experiments showed that the order of test samples does not affect the >prediction<


    (_X_train, _Y_train) = SV.split_signal_and_features(Data_Train)
    (_X_test, _Y_test) = SV.split_signal_and_features(Data_Test)
    Indexer = _X_test.index #for tracking the orignal index(timestamps) of the test data

    return _X_train, _Y_train, _X_test, _Y_test, Indexer, Data

#Final Bayes function
def Bayes(Model,_X_train, _Y_train, _X_test, _Y_test, Indexer, Data):
    #Here the final bayesian optimization is done
    Totaltimestart = time.time()
    if Model == "Baye": #set the bayesian parameter space
        params = {"IndivModel":hp.choice("IndivModel",
                       [
                           {"IndivModel_baye": "No"},
                           {"IndivModel_baye": "hourly"},
                           {"IndivModel_baye": "week_weekend"}
                       ]),
                "n_F" : hp.qloguniform("n_F", log(1), log(len(list(_X_test))), 1),
                "Model":hp.choice("Model",
                       [
                           {"Model": "SVR"},
                           {"Model": "ANN"},
                           {"Model": "GB"},
                           {"Model": "RF"},
                           {"Model": "Lasso"}
                       ])
                }
    else:
        params = {"IndivModel":hp.choice("IndivModel",
                       [
                           {"IndivModel_baye": "No"}
                           #changed by Laura{"IndivModel_baye": "hourly"},
                           #changed by Laura{"IndivModel_baye": "week_weekend"}
                       ]),
            "n_F" : hp.qloguniform("n_F", log(1), log(len(list(_X_test))), 1)
            }

    """
    #Todo: just for checking; delete afterwards
    import hyperopt.pyll
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    print (hyperopt.pyll.stochastic.sample(params))
    """

    def hyperopt(params, _X_train, _Y_train, _X_test, _Y_test, Indexer):
        t_start = time.time()
        if Model=="Baye": #if model is chosen by bayesian optimization, set Model equal to the one from the params
            _Model=params["Model"]["Model"]
        else:
            _Model=Model

        (XTr, YTr, XTe, YTe) = embedded__recursive_feature_selection(_X_train, _Y_train, _X_test, _Y_test, SV.EstimatorEmbedded, params["n_F"], SV.GlobalCV_MT) #create the specific train and test data
        Score = all_models(_Model, XTr, YTr, XTe, YTe, Indexer, str(params["IndivModel"]["IndivModel_baye"]), False)
        t_end = time.time()
        print("Params per iteration: %s \ with the Score score %.3f, took %.2fseconds" % (params, Score, (t_end-t_start)))
        return Score

    def f(params):
        acc = hyperopt(params,_X_train, _Y_train, _X_test, _Y_test, Indexer) #gets the score of the model
        return {"loss": -acc, "status": STATUS_OK} #fmin always minimizes the loss function, we want acc to maximize-> (-acc)

    #do the actual bayesian optimization
    trials = Trials() #not used at the moment, only for tracking the intrinsic parameters of the bayesian optimization
    BestParams = fmin(f, params, algo=tpe.suggest, max_evals=SV.MaxEval_Bayes, trials=trials) #Do the optimization to find the best settings(parameters)
    print(BestParams)

    #converting notation style
    if Model=="Baye":
        Best_IndivModel = ["No", "hourly","week_weekend"][BestParams["IndivModel"]]
        Best_Model = ["SVR","ANN","GB","RF","Lasso"][BestParams["Model"]]
        Best_n_F = BestParams["n_F"]
        BestParams = {'IndivModel': {'IndivModel_baye': Best_IndivModel}, 'Model': {'Model': Best_Model}, 'n_F': Best_n_F}
    else:
        Best_IndivModel = ["No", "hourly","week_weekend"][BestParams["IndivModel"]]
        Best_n_F = BestParams["n_F"]
        BestParams = {'IndivModel': {'IndivModel_baye': Best_IndivModel}, 'n_F': Best_n_F}

    #redo the training and testing with the found "BestParams", also document the results
    if Model == "Baye":  # if model is chosen by bayesian optimization, set Model equal to the one from the bestparams
        _Model = BestParams["Model"]["Model"]
    else:
        _Model = Model

    (XTr, YTr, XTe, YTe, BestData) = embedded__recursive_feature_selection(_X_train, _Y_train, _X_test, _Y_test,
                                                                 SV.EstimatorEmbedded, BestParams["n_F"], SV.GlobalCV_MT, True)

    #Todo: Here you could use higher Max_eval for the last final training with best settings(Add specific max eval hyparatuning to the functions)
    Score = all_models(_Model, XTr, YTr, XTe, YTe, Indexer, str(BestParams["IndivModel"]["IndivModel_baye"]), True)

    #Document the Results and settings of the final bayesian optimization
    Totaltimeend=time.time()
    # save summary of setup and evaluation
    dfSummary = pd.DataFrame(index=[0])
    dfSummary['Chosen Model'] = Model
    dfSummary['Max evaluations'] = SV.MaxEval_Bayes
    if Model == "Baye":
        dfSummary['Best Model'] = _Model
    dfSummary['Best individual model type'] = Best_IndivModel
    dfSummary['Best number of features'] = Best_n_F
    dfSummary['Best Features incl. Signal'] = str(list(BestData))
    dfSummary['Best parameter in original shape'] = str(BestParams)
    dfSummary['Computation Time in seconds'] = str((Totaltimeend-Totaltimestart))
    dfSummary = dfSummary.T
    # write summary of setup and evaluation in excel File
    SummaryFile = os.path.join(SV.ResultsFolderSubTest, "Summary_FinalBayes_%s.xlsx"%(SV.NameOfSubTest))
    writer = pd.ExcelWriter(SummaryFile)
    dfSummary.to_excel(writer, float_format='%.6f')
    writer.save()

    #export BestData to Excel
    BestData = Data[list(BestData)] #make sure BestData contains the whole available period(not only the period used for training and prediction)
    SaveFileName_excel = os.path.join(SV.ResultsFolderSubTest, "BestData_%s.xlsx"%(SV.NameOfSubTest))
    BestData.to_excel(SaveFileName_excel)

    #save dataframe in an pickle
    BestData.to_pickle(os.path.join(SV.PathToPickles, "ThePickle_from_%s.pickle"%SV.NameOfSubTest))

#OnlyPredict functions
def iterative_evaluation(TestData, Model, horizon, NameOfPredictor): #horizon= amount of samples to predict in the future
    'Does an special evaluation which iteratively scores a period with the length of horizon in the whole period of TunedData. It returns the list of scores'
    #Todo: think of inserting this "iterative evaluation" to the regular scoring while training and testing(not only for onlypredict)
    n_folds = len(TestData)/horizon #get how many times the horizon fits into the data
    n_folds = int(n_folds) #cut of incomplete horizons
    #TunedData.index = range(len(TunedData)) #give them dataframe an counter index
    (TestData_X, TestData_Y) = SV.split_signal_and_features(TestData)

    if os.path.isfile(os.path.join(SV.ResultsFolder, "ScalerTracker.save")): #if scaler was used
        ScaleTracker_Signal = joblib.load(os.path.join(SV.ResultsFolder, "ScalerTracker.save")) #load used scaler

    fold_list=[]
    for i in range(n_folds):
        measured_fold = TestData_Y[(horizon*i):(horizon*(i + 1))]
        Fold = TestData_X[(horizon*i):(horizon*(i+1))]
        predicted_fold, Nothing = Model(NameOfPredictor,Fold) #predict on that fold
        #rescale
        predicted_fold = ScaleTracker_Signal.inverse_transform(SV.reshape(predicted_fold))
        measured_fold = ScaleTracker_Signal.inverse_transform(SV.reshape(measured_fold))

        fold_list.append([measured_fold, predicted_fold])
    return fold_list

def mean_scoring(fold_list, errormetric): #processes the list of scores from "iterative_evaluation"
    'The list of scores (fold_list) is processed and the mean of all scores and the standard deviation over all scores are computed'
    errorlist = []
    for i in range(len(fold_list)):
        score = errormetric(fold_list[i][0],fold_list[i][1])
        errorlist.append(score)
    mean_scores = statistics.mean(errorlist) #mean of all scores
    SD_scores = statistics.pstdev(errorlist) #standard deviation of all scores
    return mean_scores, SD_scores, errorlist, errormetric

def predict(NameOfPredictor,_X_test):
    'Loads trained models from previous trainings and does a prediction for the respective period of _X_test. Individual models are regarded.'
    if os.path.isfile(os.path.join(SV.ResultsFolderSubTest, "BestModels", "%s.save"%(NameOfPredictor))): #to find out which indivmodel was used
        Predictor = joblib.load(os.path.join(SV.ResultsFolderSubTest, "BestModels", "%s.save" %(NameOfPredictor))) #load the best and trained model from previous tuning and training
        if SV.OnlyPredictRecursive == False:
            Predicted = Predictor.predict(_X_test)
        elif SV.OnlyPredictRecursive == True:
            Features_test_i = recursive(_X_test, Predictor)
            Predicted = Predictor.predict(Features_test_i)
        IndividualModel = "None"
    elif os.path.isfile(os.path.join(SV.ResultsFolderSubTest, "BestModels", "23_%s.save"%(NameOfPredictor))): #for hourly models
        indiv_predictor = indiv_model_onlypredict(indiv_splitter_instance=indiv_splitter(hourly_splitter), Features_test=_X_test, ResultsFolderSubTest=SV.ResultsFolderSubTest, NameOfPredictor=NameOfPredictor, Recursive=SV.OnlyPredictRecursive)
        Predicted = indiv_predictor.main()
        IndividualModel = "hourly"
        #Predicted = individual_model_per_hour_onlypredict(_X_test, ResultsFolderSubTest, NameOfPredictor, OnlyPredictRecursive)
    elif os.path.isfile(os.path.join(SV.ResultsFolderSubTest, "BestModels", "weekday_%s.save"%(NameOfPredictor))): #for weekday_weekend models
        indiv_predictor = indiv_model_onlypredict(indiv_splitter_instance=indiv_splitter(week_weekend_splitter), Features_test=_X_test, ResultsFolderSubTest=SV.ResultsFolderSubTest, NameOfPredictor=NameOfPredictor, Recursive=SV.OnlyPredictRecursive)
        Predicted = indiv_predictor.main()
        IndividualModel = "weekend/weekday"
        #Predicted = individual_model_week_weekend_onlypredict(_X_test, ResultsFolderSubTest, NameOfPredictor, OnlyPredictRecursive)
    elif os.path.isfile(os.path.join(SV.ResultsFolderSubTest, "BestModels", "above_%s.save"%(NameOfPredictor))): #for byFeature models
        byFeaturesplitter = byfeature_splitter(IndivThreshold,IndivFeature,_X_test)
        indiv_predictor = indiv_model_onlypredict(indiv_splitter_instance=indiv_splitter(byFeaturesplitter.splitter),
                                                  Features_test=_X_test, ResultsFolderSubTest=SV.ResultsFolderSubTest,
                                                  NameOfPredictor=NameOfPredictor, Recursive=SV.OnlyPredictRecursive) #Todo: best models "byfeature" auch mit feature und threshold im namen abspeichern oder irgendwie damit das predicten unabhängig von den aktuellen werten von indivFeature usw. ist
        Predicted = indiv_predictor.main()
        IndividualModel = "byFeature"
    else:
        return False, False
    return Predicted, IndividualModel

def only_predict(NameOfPredictor, _X_test, _Y_test, Indexer, Data):
    timestart = time.time()
    Predicted, IndividualModel = predict(NameOfPredictor,_X_test)
    if type(Predicted)==bool:
        print("There is no trained model of %s to do OnlyPredict, if needed set OnlyPredict=False and train a model first." % NameOfPredictor)  # stop function if specific BestModel is not present
        return
    timeend = time.time()
    ComputationTime = (timeend - timestart)
    visualization_documentation(NameOfPredictor, Predicted, _Y_test, Indexer, None, ComputationTime, SV.OnlyPredictFolder, None, None, None,
                                None, SV.OnlyPredictRecursive, IndividualModel, None, None)


    def documenation_iterative_evaluation(mean_score, SD_score, errorlist, errormetric):
        errorlist = np.around(errorlist,3)
        # save results of iterative evaluation in the summary file
        ExcelFile = os.path.join(SV.OnlyPredictFolder, "Summary_%s_%s.xlsx"%(NameOfPredictor, SV.NameOfSubTest))
        Excel = pd.read_excel(ExcelFile)
        book = load_workbook(ExcelFile)
        writer = pd.ExcelWriter(ExcelFile, engine="openpyxl")
        writer.book = book
        writer.sheets = dict((ws.title, ws) for ws in book.worksheets)
        #create dataframe containing the information
        ErrorDF = pd.DataFrame(index=[0])
        ErrorDF['________'] = "_________________________________"
        if SV.ValidationPeriod==True:
            ErrorDF['Test Data'] = "Interpretation of error measures of the data from %s till %s, per error metric" %(SV.StartTest_onlypredict, SV.EndTest_onlypredict)
        else:
            ErrorDF['Test Data'] = "Interpretation of error measures regarding the whole data set per error metric"
        ErrorDF['Used error metric'] = str(errormetric)
        ErrorDF['Horizon length'] = horizon
        ErrorDF['Mean score'] = "%.3f" %mean_score
        ErrorDF['Standard deviation of errors'] = SD_score
        ErrorDF['Max score'] = str(max(errorlist))
        ErrorDF['Min score'] = str(min(errorlist))
        ErrorDF['Number of tested folds'] = len(errorlist)
        ErrorDF = ErrorDF.T

        ErrorListDF = pd.DataFrame(index=range(len(errorlist)))
        ErrorListDF['List of errors'] = errorlist
        ErrorListDF = ErrorListDF.T


        Excel = pd.concat([Excel,ErrorDF,ErrorListDF])

        Excel.to_excel(writer, sheet_name="Sheet1")
        writer.save()
        writer.close()
    horizon = len(_X_test) #gets the length of the horizon by the stated period to predict
    if SV.ValidationPeriod==True: #define the data that shall be used to do the mean errors
         MeanErrorData = Data[SV.StartTest_onlypredict:SV.EndTest_onlypredict]
    else:
        MeanErrorData= Data
    fold_list = iterative_evaluation(TestData=MeanErrorData, Model=predict, horizon=horizon, NameOfPredictor=NameOfPredictor)
    mean_score, SD_score, errorlist, errormetric = mean_scoring(fold_list=fold_list, errormetric=r2_score)
    documenation_iterative_evaluation(mean_score, SD_score, errorlist, "R2")
    mean_score, SD_score, errorlist, errormetric = mean_scoring(fold_list=fold_list, errormetric=mean_absolute_error)
    documenation_iterative_evaluation(mean_score, SD_score, errorlist, "MAE")
    mean_score, SD_score, errorlist, errormetric = mean_scoring(fold_list=fold_list, errormetric=mean_absolute_percentage_error)
    documenation_iterative_evaluation(mean_score, SD_score, errorlist, "MAPE")
#-----------------------------------------------------------------------------------------------------------------------
#Executive functions
def main_FinalBayes():
    #The automatic procedure for model tuning and parts of data tuning
    print("Start FinalBayesOpt: %s/%s/%s" % (SV.NameOfData, SV.NameOfExperiment, SV.NameOfSubTest))

    _X_train, _Y_train, _X_test, _Y_test, Indexer, Data = pre_handling(False)

    #Do the bayesian optimization
    Bayes(Model=SV.Model_Bayes, _X_train=_X_train, _Y_train=_Y_train, _X_test=_X_test, _Y_test=_Y_test, Indexer=Indexer, Data=Data)

    print("Finish FinalBayesOpt: %s/%s/%s" %(SV.NameOfData,SV.NameOfExperiment,SV.NameOfSubTest))
    print("________________________________________________________________________\n")
    print("________________________________________________________________________\n")

def main_OnlyHyParaOpti():
    print("Start training and testing with only optimizing the hyperparameters: %s/%s/%s" % (SV.NameOfData, SV.NameOfExperiment, SV.NameOfSubTest))
    _X_train, _Y_train, _X_test, _Y_test, Indexer, Data = pre_handling(False)

    for Model in SV.OnlyHyPara_Models:
        all_models(Model, _X_train, _Y_train, _X_test, _Y_test, Indexer, SV.GlobalIndivModel, True)

    print("Finish training and testing with only optimizing the hyperparameters : %s/%s/%s" % (SV.NameOfData, SV.NameOfExperiment, SV.NameOfSubTest))
    print("________________________________________________________________________\n")
    print("________________________________________________________________________\n")

def main_OnlyPredict():
    print("Start only predicting: %s/%s/%s" % (SV.NameOfData, SV.NameOfExperiment, SV.NameOfSubTest))
    _X_train, _Y_train, _X_test, _Y_test, Indexer, Data = pre_handling(True)

    OnlyPredictFolder = os.path.join(SV.ResultsFolderSubTest, "OnlyPredict", SV.NameOfOnlyPredict)
    SV.OnlyPredictFolder = OnlyPredictFolder
    #check if predict results are safed in the right folder:
    if os.path.isdir("%s" % (SV.OnlyPredictFolder)) == True:
        Answer = input("Are you sure you want to overwrite the data in %s: " % SV.OnlyPredictFolder)
        if Answer == "yes" or Answer == "Yes" or Answer == "y" or Answer == "Y":
            print("Start computing")
        else:
            sys.exit("Code stopped by user or invalid user input. Valid is Yes, yes, y and Y.")
    else:
        os.makedirs("%s" % (SV.OnlyPredictFolder))

    # AvailablePredictors = ["svr_bayesian_predictor", "rf_predictor", "ann_bayesian_predictor",
    #                         "gradientboost_bayesian", "lasso_bayesian", "svr_grid_search_predictor",
    #                         "gradientboost_gridsearch", "lasso_grid_search_predictor",
    #                         "ann_grid_search_predictor"]

    AvailablePredictors = ["rf_predictor"]
    for NameOfPredictor in AvailablePredictors:
        only_predict(NameOfPredictor, _X_test, _Y_test, Indexer, Data)


    print("Finish only predicting : %s/%s/%s" % (SV.NameOfData, SV.NameOfExperiment, SV.NameOfSubTest))
    print("________________________________________________________________________\n")
    print("________________________________________________________________________\n")


if __name__ == '__main__':
    #Todo: The following is done in ModelTuning and DataTuning, isn´t it better once in SV?
    #define path to data source files '.xls' & '.pickle'
    RootDir = os.path.dirname(os.path.realpath(__file__))
    PathToData = os.path.join(RootDir, 'Data')

    #Set Folder for Results
    ResultsFolder = os.path.join(RootDir, "Results", SV.NameOfData, SV.NameOfExperiment)
    PathToPickles = os.path.join(ResultsFolder, "Pickles")

    #Set the found Variables in "SharedVariables"
    SV.RootDir = RootDir
    SV.PathToData = PathToData
    SV.ResultsFolder = ResultsFolder
    SV.PathToPickles = PathToPickles

    #Define which part shall be computed (parameters are set in SharedVariables)
    # main_FinalBayes()
    #main_OnlyHyParaOpti()
    main_OnlyPredict()