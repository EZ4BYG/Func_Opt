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


tf.__version__


# In[3]:


gpus = tf.config.experimental.list_physical_devices( device_type = 'GPU' )
# 设置该程序可见的GPU：写到最前面！
tf.config.experimental.set_visible_devices( devices = gpus[0:3], device_type = 'GPU' )


# # 一、数据导入与标签制作：

# In[4]:


# 原始训练数据 + 验证数据：路径全是/，没有//
all_path = glob.glob('../train_new2/*')
all_total = len(all_path)


# In[5]:


all_total


# In[6]:


# 随机打散：
random.shuffle( all_path )  # 无返回值，直接在原变量上做改变


# In[7]:


all_path[0:10]


# In[8]:


# 提取标签：1:1 
all_label = [] 
for x in range( all_total ):
    label = int( all_path[x].split('/')[-1].split('.')[0].split('_')[-1] )
    if label == 1:
        all_label.append(1)  # 真人
    else:
        all_label.append(0)  # 图片


# In[9]:


type(all_label), len(all_label)


# # 二、制作数据集与划分：

# In[10]:


all_dataset = tf.data.Dataset.from_tensor_slices( (all_path, all_label) )  # path + label


# In[11]:


all_dataset


# In[12]:


# 划分训练和验证：8:2
val_count = int( all_total*0.2 )
train_count = all_total - val_count
train_count, val_count


# In[13]:


# skip函数略过多少，take函数取多少：
train_dataset_org = all_dataset.skip( val_count )  # 略过xx个，剩下全要
val_dataset_org = all_dataset.take( val_count )   # 取xx个，剩下全不要


# In[14]:


train_dataset_org, val_dataset_org


# # 三、网络自定义：

# 分两部分自定义：
# - 定义预处理函数；
# - 定义网络结构。

# In[31]:


# 对训练数据及标签的预处理：先等比缩放，再裁剪
# 原始都是1080 x 1920 —— 先缩放到600 x 600 —— 再随机裁剪到512 x 512 —— 注：512x512情况下计算太慢了！
def preprocessing_train(path, label):
    # 数据读入：image
    image = tf.io.read_file( path )                       # 文件读取
    image = tf.image.decode_jpeg( image, channels = 3 )   # 文件解码成jpg图片，并给定图片的通道数（默认为0！）
    # 数据增强：resize + crop
    image = tf.image.resize( image, [300,300], method = tf.image.ResizeMethod.NEAREST_NEIGHBOR ) # 等比例缩放：不用写通道数
    image = tf.image.random_crop( image, size = [256,256,3] )  # 随机裁剪：裁剪时要写最后一维的通道数
    image = tf.image.random_flip_left_right( image )  # 随机左右翻转
    image = tf.image.random_flip_up_down( image )     # 随机上下翻转
    image = tf.cast( image, tf.float32 )              # 转换数据类型：读入默认是int8
    image = image / 255                               # 归一化
    # 标签：label
    label = tf.reshape( label, [1] )
    # 返回结果：
    return image, label


# In[32]:


# 对训练数据及标签的预处理：只等比缩放到同样的尺寸
def preprocessing_val(path, label):
    # 数据读入：image
    image = tf.io.read_file( path )                       # 文件读取
    image = tf.image.decode_jpeg( image, channels = 3 )   # 文件解码成jpg图片，并给定图片的通道数（默认为0！）
    # 等比缩放：resize
    image = tf.image.resize( image, [256,256] )           # 等比缩放，不要选裁剪！
    image = tf.cast( image, tf.float32 )                  # 转换数据类型：读入默认是int8
    image = image / 255                                   # 归一化
    # 标签：label
    label = tf.reshape( label, [1] )
    # 返回结果：
    return image, label


# In[33]:


# 测试数据预处理：
def preprocessing_test(path, label):
    # 数据读入：image
    image = tf.io.read_file( path )                       # 文件读取
    image = tf.image.decode_jpeg( image, channels = 3 )   # 文件解码成jpg图片，并给定图片的通道数（默认为0！）
    # 等比缩放：resize
    image = tf.image.resize( image, [256,256] )           # 等比缩放，不要选裁剪！
    image = tf.cast( image, tf.float32 )                  # 转换数据类型：读入默认是int8
    image = image / 255                                   # 归一化
    # 标签：label
    label = tf.reshape( label, [1] )
    # 返回结果：
    return image, label


# In[34]:


# 用tf.data创建输入数据集：
AUTOTUNE = tf.data.experimental.AUTOTUNE   # 新操作：在tf.data模块使用时，会自动根据cpu来情况进行并行计算处理！
# 训练数据：
train_dataset = train_dataset_org.map( preprocessing_train, num_parallel_calls = AUTOTUNE )  # 这里用到上面预处理的函数
# 测试数据：
val_dataset = val_dataset_org.map( preprocessing_val, num_parallel_calls = AUTOTUNE )      # 这里用到上面预处理的函数


# In[35]:


train_dataset, val_dataset


# **网络搭建：数据又一次打散**

# In[36]:


# 乱序、批划分：
BATCH_SIZE = 16
# 训练数据：
train_dataset = train_dataset.shuffle(train_count).batch(BATCH_SIZE)  # 乱序 + 划分批次 
train_dataset = train_dataset.prefetch(AUTOTUNE)  # 新操作：预取到缓存：加速处理
# 验证数据：
val_dataset = val_dataset.batch(BATCH_SIZE)  # 乱序 + 划分批次 
val_dataset = val_dataset.prefetch(AUTOTUNE)  # 新操作：预取到缓存：加速处理


# In[37]:


# 图像不断缩小，相当于卷积核视野不断变大！
# 1. 加批标准化层：加到每个卷积层、全连接层的后面
model = tf.keras.Sequential([
    tf.keras.layers.Conv2D(64, (3, 3), input_shape=(256, 256, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.MaxPooling2D(),
    
    tf.keras.layers.Conv2D(128, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Conv2D(128, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.MaxPooling2D(),
    
    tf.keras.layers.Conv2D(256, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Conv2D(256, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.MaxPooling2D(),
    
    tf.keras.layers.Conv2D(512, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Conv2D(512, (3, 3), activation='relu'),
    tf.keras.layers.BatchNormalization(),  # 后面用AveragePooling了，不需要这里的Maxpooling
    
    # 过渡：进入全连接层
    tf.keras.layers.GlobalAveragePooling2D(),
    
    tf.keras.layers.Dense(256, activation='relu'),
    tf.keras.layers.BatchNormalization(),
    
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.BatchNormalization(),

    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.BatchNormalization(),
 
    tf.keras.layers.Dense(1, activation = 'sigmoid')
])


# In[41]:


model.summary()


# In[38]:


# 模型编译：
model.compile(optimizer = 'adam',
              loss = 'binary_crossentropy',
              metrics = ['acc']
)


# In[39]:


# 定义保存模型的回调函数：保存整个模型、只保存最好的！
# 设置保存的路径：
checkpoint_path = '/home/gaoboyu/活体检测项目/model_large/'
# 设置回调函数保存模型：没设置的参数都默认
cp_callback_model = tf.keras.callbacks.ModelCheckpoint(
    filepath = checkpoint_path,
    monitor = 'val_acc',
    save_best_only = True  # 监控的目标：如果新的epoch结果比前一个要好，那就重新保存最新的，删掉旧的！
)


# In[40]:


# 模型训练
EPOCHES = 100
history = model.fit(
    train_dataset,
    epochs = EPOCHES,
    steps_per_epoch = train_count // BATCH_SIZE,
    validation_data = val_dataset,
    validation_steps = val_count // BATCH_SIZE,
    # 回调函数：
    callbacks = [cp_callback_model]
)


# In[ ]:


# history文件保存：
import pickle
history_path = '/home/gaoboyu/活体检测项目/history/history1.text'
with open(history_path, 'wb') as file_pi:
    pickle.dump(history.history, file_pi)


# In[ ]:


# 格式转存：
model_new = tf.keras.models.load_model( '../model_large/' )
model_new.save( '/home/gaoboyu/活体检测项目/model_h5/model_large.h5' )


# # 四、测试数据：

# In[23]:


# # 模型导入：
# model_new = tf.keras.models.load_model( '../model_large/' )

# # 导入测试数据：
# test_path = glob.glob('../test_new1/*')
# # 随机打散：
# random.shuffle( test_path )  # 无返回值，直接在原变量上做改变
# # 提取标签：
# test_label = [] 
# for x in range( len(test_path) ):
#     label = int( test_path[x].split('/')[-1].split('.')[0].split('_')[-1] )
#     if label == 1:
#         test_label.append(1)  # 真人
#     else:
#         test_label.append(0)  # 图片
        
# # 创建数据集：
# test_dataset = tf.data.Dataset.from_tensor_slices( (test_path, test_label) )  # path + label
# # 加batch维度：
# AUTOTUNE = tf.data.experimental.AUTOTUNE   # 新操作：在tf.data模块使用时，会自动根据cpu来情况进行并行计算处理！
# BATCH_SIZE = 16
# test_dataset = test_dataset.map( preprocessing_test, num_parallel_calls = AUTOTUNE )
# test_dataset = test_dataset.cache().batch(BATCH_SIZE)
# test_dataset

# # 测试：
# model_new.evaluate(test_dataset)

# # 模型重保存为.h5格式：
# model_new.save( '/home/gaoboyu/活体检测项目/model_h5/model_large.h5' )

# # 再次导入.h5格式模型 + 评估：
# model_newh5 = tf.keras.models.load_model( '/home/gaoboyu/活体检测项目/model/model1.h5' )
# model_newh5.evaluate( test_dataset )


# In[ ]:




