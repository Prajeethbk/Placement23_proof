#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#%%
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from keras.models import Sequential
from keras.layers import LSTM, Dense

# Load the dataset
df = pd.read_csv('0f411c708e55af442eafb33bfb7ee7585f5b0211a52d9ccc4287a23d8d6abe76_STOCK_INDEX.csv')
df_filled = df.interpolate(method='linear')
df_filled = df_filled.drop('Date', axis=1)
# Extract the closing price column
closing_prices = df_filled['Close'].values

# Normalize the closing prices between 0 and 1
scaler = MinMaxScaler(feature_range=(0, 1))
closing_prices_scaled = scaler.fit_transform(closing_prices.reshape(-1, 1))

# Prepare the data
def prepare_data(data, n_steps):
    X, y = [], []
    for i in range(len(data) - n_steps - 2):
        X.append(data[i : i + n_steps])
        y.append(data[i + n_steps : i + n_steps + 2])
    return np.array(X), np.array(y)

n_steps = 50
X, y = prepare_data(closing_prices_scaled, n_steps)

# Reshape the data for LSTM input
X = np.reshape(X, (X.shape[0], X.shape[1], 1))

model = Sequential()
model.add(LSTM(50, activation='relu',input_shape=(n_steps, 1)))
model.add(Dense(2))  
model.compile(optimizer='adam', loss='mse')

# Train the model
model.fit(X, y[:, -1, :], epochs=50, batch_size=16, verbose=1)

model_architecture = model.to_json()
with open("model_architecture.json","w") as json_file:
    json_file.write(model_architecture)
    
model.save_weights('model_weights.h5')

