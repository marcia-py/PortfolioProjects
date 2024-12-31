import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import linregress

def draw_plot():
    # Read data from file
    df = pd.read_csv("epa-sea-level.csv", na_values = ['', '?', '-'])

    # Create scatter plot
    fig, ax = plt.subplots(figsize = (10, 6))
    ax.scatter(df['Year'], df['CSIRO Adjusted Sea Level'], alpha=0.6, color='blue')

    # Create first line of best fit 
    slope, intercept, _, _, _ = linregress(df['Year'], df['CSIRO Adjusted Sea Level'])
    start_year = df['Year'].min() #defining the start and end years for the line
    end_year = 2050

    start_sea_level = slope * start_year + intercept # Calculating corresponding sea levels (y=mx + b)
    end_sea_level = slope * end_year + intercept

    plt.plot([start_year, end_year], [start_sea_level, end_sea_level], color='red', label='Line of best fit')
    
    # Create second line of best fit
    df_recent = df[df['Year'] >= 2000]
    slope, intercept, _, _, _ = linregress(df_recent['Year'], df_recent['CSIRO Adjusted Sea Level'])
    start_year_recent = df_recent['Year'].min()
    end_year_recent = 2050

    start_sea_level_recent = slope * start_year_recent + intercept
    end_sea_level_recent = slope * end_year_recent + intercept

    plt.plot([start_year_recent, end_year_recent], [start_sea_level_recent, end_sea_level_recent], color='green', label='Line of best fit (2000 onwards)')

    # Add labels and title
    plt.xlabel('Year', fontsize=12)
    plt.ylabel('Sea Level (inches)', fontsize=12)
    plt.title('Rise in Sea Level', fontsize=14)


    # Save plot and return data for testing (DO NOT MODIFY)
    plt.savefig('sea_level_plot.png')
    return plt.gca()