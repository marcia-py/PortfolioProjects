import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

# 1
df = pd.read_csv("medical_examination.csv")

# 2
df['height'] = df['height'] / 100
df['BMI'] = df['weight'] / (df['height']**2)
df['overweight'] = (df['BMI'] > 25).astype(int)

# 3
df['cholesterol'] = (df['cholesterol'] > 1).astype(int)
df['gluc'] = (df['gluc'] > 1).astype(int)

# 4
def draw_cat_plot():
    # 5
    df_cat = pd.melt(df, id_vars = ['cardio'],
                     value_vars = ['cholesterol', 'gluc', 'smoke', 'alco', 'active', 'overweight'],
                     var_name = 'variable', value_name = 'value')

    # 6
    df_counts = df_cat.groupby(['cardio', 'variable']).size().reset_index(name = 'count')

    # 7
    catplot = sns.catplot(data=df_counts, x='variable', y='count', hue='cardio', kind='bar')
    
    # 8
    fig = catplot.fig


    # 9
    fig.savefig('catplot.png')
    return fig


# 10
def draw_heat_map():
    # 11
    df_heat = df[
        (df['ap_lo'] <= df['ap_hi']) & 
        (df['height'] >= df['height'].quantile(0.025)) &
        (df['height'] <= df['height'].quantile(0.975)) & 
        (df['weight'] >= df['weight'].quantile(0.025)) &
        (df['weight'] <= df['weight'].quantile(0.975))
    ]  

    # 12
    corr = df_heat.corr()

    # 13
    mask = np.triu(np.ones_like(corr, dtype=bool))

    # 14
    fig = plt.figure(figsize = (10, 8))

    # 15
    sns.heatmap(corr, mask=mask, annot=True, fmt=".2f", cmap='coolwarm', square=True, cbar_kws={"shrink": .8})

    # 16
    fig.savefig('heatmap.png')
    return fig
