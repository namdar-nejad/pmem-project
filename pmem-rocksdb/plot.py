#!/usr/bin/env python
# coding: utf-8

# In[1]:


from os import listdir
from os.path import isfile, join
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy import stats


# In[2]:


def collect_info():
    files = [f for f in listdir("./results/") if (isfile(join("./results/", f)) and (f[0] == "K"))]
    
    all_data = []

    for f in sorted(files):
        fp = open("./results/"+f)
        
        data = {"thru": 0, "latancy": 0, "title":"",
            "mem_hit":0, "mem_miss":0,
            "cache_hit":0, "cache_miss":0,
            "read_perc": {
                "P50":0, "P75": 0, "P99": 0, "P99.9": 0, "P99.99": 0
            },
            "write_perc": {
                "P50":0, "P75": 0, "P99": 0, "P99.9": 0, "P99.99": 0
            }
           }
        
        for i, line in enumerate(fp):
            line = line.split()
            
            if i == 20:
                thru = float(line[4])
                latancy = float(line[2])
                
                data["thru"] = thru
                data["latancy"] = latancy
                data["title"] = f[:-4]
                
            if i == 24:
                data["read_perc"]["P50"] = float(line[2])
                data["read_perc"]["P75"] = float(line[4])
                data["read_perc"]["P99"] = float(line[6])
                data["read_perc"]["P99.9"] = float(line[8])
                data["read_perc"]["P99.99"] = float(line[10])
                
            if(i > 25) and (len(line) > 0) and (line[0] == "Percentiles:"):
                data["write_perc"]["P50"] = float(line[2])
                data["write_perc"]["P75"] = float(line[4])
                data["write_perc"]["P99"] = float(line[6])
                data["write_perc"]["P99.9"] = float(line[8])
                data["write_perc"]["P99.99"] = float(line[10])
                
            if(i > 52) and (len(line) > 0) and (line[0] == "rocksdb.block.cache.miss"):
                data["cache_miss"] = float(line[3])
                
            if(i > 52) and (len(line) > 0) and (line[0] == "rocksdb.block.cache.hit"):
                data["cache_hit"] = float(line[3])
                
            if(i > 52) and (len(line) > 0) and (line[0] == "rocksdb.memtable.miss"):
                data["mem_miss"] = float(line[3])
                
            if(i > 82) and (len(line) > 0) and (line[0] == "rocksdb.memtable.hit"):
                data["mem_hit"] = float(line[3])
                
        
        all_data.append(data.copy())
        fp.close()
        
    return all_data


# In[3]:


def plot_bar(all_data, y ="latancy"):
    
    x = np.arange(8)
    none_latancy = []
    none_thru = []
    
    
    block_latancy = []
    block_thru = []
    both_latancy = []
    both_thru = []
    title_data = []
    width = 0.2

    for i in all_data:
        title = "_".join(i['title'].split("_")[0:2])
        type_ = i['title'].split("_")[-1]

        if (type_ == 'none'):
            title_data.append(title)
            none_latancy.append(i['latancy'])
            none_thru.append(i['thru'])
                
        if (type_ == 'cache'):
            block_latancy.append(i['latancy'])
            block_thru.append(i['thru'])
                
        if (type_ == 'both'):
            both_latancy.append(i['latancy'])
            both_thru.append(i['thru'])
        
    plt.figure(figsize=(15, 7))
    plt.xticks(x, title_data)
    
    plt.xlabel("Configuration", labelpad=20, fontsize=14)
    if(y == "latancy"):
        plt.bar(x-0.2, none_latancy, width, color='blue')
        plt.bar(x, block_latancy, width, color='red')
        plt.bar(x+width, both_latancy, width, color='green')
        plt.ylabel("Latancy (micros/op)", labelpad=20, fontsize=14)
    else:
        plt.bar(x-0.2, none_thru, width, color='blue')
        plt.bar(x, block_thru, width, color='red')
        plt.bar(x+width, both_thru, width, color='green')
        plt.ylabel("Throughput (op/sec)", labelpad=20, fontsize=14)
        
    plt.legend(["None", "Cache", "Both"])
    
    plt.show()


# In[4]:


def plot_latancy():
    for x in [x for x in (3*p for p in range(8))]:
        num = x
        both_read = list(all_data[num]['read_perc'].values())[:3]
        block_read = list(all_data[num+1]['read_perc'].values())[:3]
        none_read = list(all_data[num+2]['read_perc'].values())[:3]

        both_write = list(all_data[num]['write_perc'].values())[:2]
        block_write = list(all_data[num+1]['write_perc'].values())[:2]
        none_write = list(all_data[num+2]['write_perc'].values())[:2]

        both_write.append(4)
        block_write.append(4)
        none_write.append(4)

        data = [none_write, block_write,both_write]

        fig1 = plt.figure(figsize =(7, 4))

        # Creating axes instance
        ax1 = fig1.add_axes([0,0,1,1])


        # Creating plot
        bp1 = ax1.boxplot(data)
        ax1.set_xticklabels(["None", "Block", "Both"])

        plt.ylabel("Write Latency (micros/op)", labelpad=22, fontsize=18)
        plt.xlabel("Configuration " + "_".join(all_data[num]['title'].split("_")[0:2]), labelpad=22, fontsize=18);

        # show plot
        plt.show()

        both_read.append(0)
        none_read.append(0)
        block_read.append(0)

        data = [none_read, block_read, both_read]

        fig = plt.figure(figsize =(7, 4))

        # Creating axes instance
        ax = fig.add_axes([0,0,1,1])

        # Creating plot
        bp = ax.boxplot(data)
        ax.set_xticklabels(["None", "Block", "Both"])
        plt.ylabel("Read Latency (micros/op)", labelpad=22, fontsize=18)
        plt.xlabel("Configuration " + "_".join(all_data[num]['title'].split("_")[0:2]), labelpad=20, fontsize=18);

        # show plot
        plt.show()


# In[5]:


all_data = collect_info()
plot_bar(all_data, y="latancy")
plot_bar(all_data, y="throughput")
# plot_latancy()


# In[ ]:




