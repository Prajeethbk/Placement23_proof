#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from keras.models import model_from_json

#%%
def evaluate():
    # Input the csv file
    """
    Sample evaluation function
    Don't modify this function
    """
    df = pd.read_csv('sample_input.csv')
    actual_close = np.loadtxt('sample_close.txt')

    pred_close = predict_func(df)
    
    # Calculation of squared_error
    actual_close = np.array(actual_close)
    pred_close = np.array(pred_close)
    mean_square_error = np.mean(np.square(actual_close-pred_close))


    pred_prev = [df['Close'].iloc[-1]]
    pred_prev.append(pred_close[0])
    pred_curr = pred_close
    
    actual_prev = [df['Close'].iloc[-1]]
    actual_prev.append(actual_close[0])
    actual_curr = actual_close

    # Calculation of directional_accuracy
    pred_dir = np.array(pred_curr)-np.array(pred_prev)
    actual_dir = np.array(actual_curr)-np.array(actual_prev)
    dir_accuracy = np.mean((pred_dir*actual_dir)>0)*100
    print(f'Mean Square Error: {mean_square_error:.6f}\nDirectional Accuracy: {dir_accuracy:.1f}')
    
#%%
def predict_func(data):
    """
    Modify this function to predict closing prices for next 2 samples.
    Take care of null values in the sample_input.csv file which are listed as NAN in the dataframe passed to you 
    Args:
        data (pandas Dataframe): contains the 50 continuous time series values for a stock index

    Returns:
        list (2 values): your prediction for closing price of next 2 samples
    """
    data = data.interpolate(method='linear')
    data = data['Close'].values
    # Load the data for testing
    #closing_prices_test = data['Close'].values
    
    
    with open("model_architecture.json", "r") as json_file:
        loaded_model_architecture = json_file.read()
    model = model_from_json(loaded_model_architecture)

    # Load the saved model weights
    model.load_weights("model_weights.h5")

    # Normalize the input data using the same scaler
    scaler = MinMaxScaler(feature_range=(0, 1))
    data_scaled = scaler.fit_transform(data.reshape(-1, 1))

    # Prepare the data for prediction
    n_steps = model.input_shape[1]
    X_pred = np.reshape(data_scaled[-n_steps:], (1, n_steps, 1))

    # Make predictions for the last two values
    predictions_scaled = model.predict(X_pred)
    predictions = scaler.inverse_transform(predictions_scaled)
    predictions = predictions.flatten()
    
    
    print(predictions)
    return predictions
    
#%%
if __name__== "__main__":
    evaluate()

