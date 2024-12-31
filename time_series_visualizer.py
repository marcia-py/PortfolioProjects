import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()

# Import data (Make sure to parse dates. Consider setting index column to 'date'.)
df = pd.read_csv("fcc-forum-pageviews.csv", index_col = [0], parse_dates = ['date'])

# Clean data
df = df[(df['value'] >= quantile(0.025)) & (df['value'] <= quantile(0.975))]

# Draw line plot
def draw_line_plot():
    df_line = df.copy()
    fig, ax = plt.subplots(figsize = (12,6))
    ax.plot(df.index, df['value'], color='blue', linewidth=3)
    ax.set_xlabel('Date', fontsize=12)
    ax.set_ylabel('Page Views', fontsize=12)
    ax.set_title("Daily freeCodeCamp Forum Page Views 5/2016-12/2019", fontsize=14)
    
    # Save image and return fig (don't change this part)
    fig.savefig('line_plot.png')
    return fig

def draw_bar_plot():
    # Copy and modify data for monthly bar plot
    df_bar = df.copy()
    df_bar['year'] = df.index.year
    df_bar['month'] = df.index.month
    grouped = df.groupby(['year', 'month'])['value'].mean().reset_index()
    grouped.columns = ['Year', 'Month', 'Average Daily Page Views']
 
    month_order = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    df_grouped['month'] = pd.Categorical(df_grouped['month'], categories=month_order, ordered=True)
    
    # Draw bar plot
    df_pivot = df_grouped.pivot(index='Year', columns='Month', values='Average Daily Page Views')
    fig, ax= plt.subplots(figsize = (12,6))
    df_pivot.plot(kind='bar', ax=ax, width = 0.5)

    ax.set_xlabel('Years', fontsize=12)
    ax.set_ylabel('Average Page Views', fontsize=12)
    ax.set_title('Average Daily Page Views for Each Month Grouped by Year', fontsize=14)
    ax.legend(title='Months', fontsize=10, title_fontsize=11)

    # Save image and return fig (don't change this part)
    fig.savefig('bar_plot.png')
    return fig

def draw_box_plot():
    # Prepare data for box plots (this part is done!)
    df_box = df.copy()
    df_box.reset_index(inplace=True)
    df_box['year'] = [d.year for d in df_box.date]
    df_box['month'] = [d.strftime('%b') for d in df_box.date]

    # Draw box plots (using Seaborn)
    fig, ax = plt.subplots(1, 2, figsize = (15, 6))
    
    sns.boxplot(data=df_box, x='year', y='value', ax=ax[0])
    ax[0].set_title('Year-wise Box Plot (Trend)')
    ax[0].set_xlabel('Years')
    ax[0].set_ylabel('Page Views')

    month_order = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ]

    sns.boxplot(data=df_box, x='month', y='value', order=month_order, ax=ax[1])
    ax[1].set_title('Month-wise Box Plot (Seasonality)')
    ax[1].set_xlabel('Months')
    ax[1].set_ylabel('Page Views')

    #To automatically adjust the layout of the subplots - making sure the labels/titles do not overlap
    #Proper space between the plots
    plt.tight_layout()

    # Save image and return fig (don't change this part)
    fig.savefig('box_plot.png')
    return fig
