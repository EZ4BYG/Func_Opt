#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
import glob
import os
import random


# In[2]:


# gpu配置：
gpus = tf.config.experimental.list_physical_devices( device_type = 'GPU' )
tf.config.experimental.set_visible_devices( devices = gpus[0:3], device_type = 'GPU' )


# In[8]:


# 测试数据预处理：
def preprocessing_test(path):
    # 数据读入：image
    image = tf.io.read_file( path )                       # 文件读取
    image = tf.image.decode_jpeg( image, channels = 3 )   # 文件解码成jpg图片，并给定图片的通道数（默认为0！）
    # 等比缩放：resize
    image = tf.image.resize( image, [256,256] )           # 等比缩放，不要选裁剪！
    image = tf.cast( image, tf.float32 )                  # 转换数据类型：读入默认是int8
    image = image / 255                                   # 归一化
    # 标签：label
    # label = tf.reshape( label, [1] )
    # 返回结果：
    return image


# In[10]:


# 模型导入：
model_new = tf.keras.models.load_model( '../model_h5/model_large.h5' )

# 导入测试数据：
test_path = glob.glob('../test_new1/*')
# 随机打散：
random.shuffle( test_path )  # 无返回值，直接在原变量上做改变
        
# 创建数据集：
test_dataset = tf.data.Dataset.from_tensor_slices( (test_path) )  # path + label
# 加batch维度：
AUTOTUNE = tf.data.experimental.AUTOTUNE   # 新操作：在tf.data模块使用时，会自动根据cpu来情况进行并行计算处理！
BATCH_SIZE = 16
test_dataset = test_dataset.map( preprocessing_test, num_parallel_calls = AUTOTUNE )
test_dataset = test_dataset.cache().batch(BATCH_SIZE)
test_dataset

# 测试：
prediction = model_new.predict(test_dataset)

# 把标签重归为1和-1：
prediction_tmp = prediction.tolist()
prediction_tmp = sum( prediction_tmp, [] )


# In[26]:


# 把标签重归为1和-1：
prediction_tmp = prediction.tolist()
prediction_tmp = sum( prediction_tmp, [] )

label_predict = []
label1 = [1]; label2 = [-1]
for x in prediction_tmp:
    if x > 0.5:
        label_predict.append( label1 )
    else:
        label_predict.append( label2 ) 


# In[33]:


# 写入文件：
with open('prediction.txt', 'w') as f:
    for x in label_predict:
        s = str( x ) + '\n'
        f.write(s)


# In[ ]:




