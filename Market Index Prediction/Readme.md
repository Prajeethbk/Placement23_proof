Library files:

import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from keras.models import model_from_json
from keras.models import Sequential
from keras.layers import LSTM, Dense

Run the file "22104071_Prajeeth.py" file to predict two future values from the given time series.

The file named "train.py" trains the model from the given dataframe "0f411c708e55af442eafb33bfb7ee7585f5b0211a52d9ccc4287a23d8d6abe76_STOCK_INDEX.csv"

"model_architecture.json" and "model_weights.h5" contain the model structure and parameters respectively.

sample_input.csv and sample_close.txt are called in evaluate() function. Since it was instructed to not change the evaluate() function, they have been included.
