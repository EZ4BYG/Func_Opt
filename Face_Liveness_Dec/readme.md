# Face Liveness Detection

The uses of some key files:
- train.py / train.ipynb：We can use this file to pre-process data, setup the network, network configuration, save (.h5) and train tthe network;
- test.py / test.ipynb：This file will use the saved model.h5 to evaluate the performance (model.h5) on test dataset;
- prediction.py / prediction.ipynb：This file will use the saved model to predict the category of the input images, which don't have known labels.

**Tips:**
- The file suffix **.py** means that this is a pure python code, you can open it in PyCharm or other IDE tools;
- The file suffix **.ipynb** means that this is a Jupyter Notebook python code, you should open these files through Jupyter Notebook on the website.
- All codes have file-path and GPU configurations language, which need to be adjusted according to the situation.

**Requirements:**
- Tensorflow-GPU: 2.2.0
- Numpy: 1.16.2
- Matplotlib：3.1.3
