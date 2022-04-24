
"""
Created on Mon Jun  3 15:42:38 2019

@author: pst
"""

import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import pandas as pd


def plot_erc_field(zValue,title=None,label='Data',range_map=[None,None],cmap='cool',digits=2,show_mean=True,show_values=True):
    '''Create a Scatter Plot of the ERC field with drawn Main Building and Single Borehole Shafts
    The Boreholes are colored regarding the submitted z-Value
    Parameters:
        zValue: Values of the property to be plotted (List of 40 Values)
        title:  Title of the Plot / str
        label:  label of the Colormap
        range_map: min and max Value of the Colormap
        cmap:   Colormap to be used ("heat"-> eon-red, "cool" -> rwth-blue, else -> blue and red)
        digits: Number of digits to be plotted
        show_values: attach value to each pipe
        show_mean:   add mean value of each shaft
    '''

    if len(zValue)>40:
        zValue=zValue[0:40]

    # Define Pipe Positions
    PipeSize = 800
    PipeData = pd.DataFrame()
    PipeData['PipeID'] = range(1,41)
    PipeData['x_Pos'] = [6.02,15.08,24.14,33.2,42.26,51.25,60.32,22.98,10.65,22.91,6.08,15.15,22.98,35.58,44.65,53.64,62.63,71.69,80.75,89.75,98.81,107.8,115.5,106.58,91.04,98.81,114.41,106.64,91.04,98.81,114.41,106.64,98.81,114.41,91.04,106.58,98.81,114.41,78.3,69.31]
    PipeData['y_Pos'] = [49.93,51.43,49.93,49.93,49.93,49.93,49.93,41.07,35.27,32,27.5,27.5,14,6.77,6.77,6.77,6.77,6.77,6.77,6.77,6.77,6.77,11.48,16.32,16.32,20.82,20.82,25.32,25.39,29.96,29.82,34.45,38.95,38.89,43.52,43.52,48.02,47.95,49.93,49.93]

    # Define EBC Colormaps
    colors_cool = [(78/255,79/255,80/255),(217/255,217/255,217/255),(157/255,195/255,230/255),(0/255,84/255,159/255)]
    colors_heat = [(78/255,79/255,80/255),(217/255,217/255,217/255),(235/255,140/255,129/255),(221/255,64/255,45/255),(172/255,43/255,28/255)]
    colors_both = [(172/255,43/255,28/255),(221/255,64/255,45/255),(235/255,140/255,129/255),(217/255,217/255,217/255),(157/255,195/255,230/255),(0/255,84/255,159/255)]
    colors_both.reverse()
    cm_cool = LinearSegmentedColormap.from_list('CoolMap', colors_cool, N=40)
    cm_heat = LinearSegmentedColormap.from_list('HeatMap', colors_heat, N=40)
    cm_both = LinearSegmentedColormap.from_list('HeatMap', colors_both, N=40)

    if cmap=='heat':
        cm=cm_heat
    elif cmap=='cool':
        cm=cm_cool
    else:
        cm=cm_both

    # Plot Pipes + 3D Value
    plt.figure(figsize=(8,4))
    sc = plt.scatter(PipeData['x_Pos'], PipeData['y_Pos'], c=zValue, vmin=min(zValue), vmax=max(zValue), s=PipeSize, cmap=cm)
    clb=plt.colorbar(sc)
    if range_map[0]!=None:
        plt.clim(range_map[0],range_map[1])
    clb.set_label(label,rotation=270,labelpad=15,fontsize=14)

    # Plot ERC Main Building
    ERC = plt.Rectangle((27.59,12.43),58.31,33.48,linewidth=2,edgecolor='k',facecolor='none')
    ax = plt.gca()
    ax.add_patch(ERC)
    # Plot Wells
    Well_s=plt.Rectangle((74.01,4.18),2.86,4.84,linewidth=1,edgecolor='k',facecolor='none')
    Well_e=plt.Rectangle((102.9,32.14),2.86,4.84,linewidth=1,edgecolor='k',facecolor='none')
    Well_w=plt.Rectangle((18.76,46.45),2.86,4.84,linewidth=1,edgecolor='k',facecolor='none')
    ax.add_patch(Well_s)
    ax.add_patch(Well_e)
    ax.add_patch(Well_w)

    # Add Values to pipes
    if show_values:
        for i, txt in enumerate(zValue):
            plt.text(PipeData['x_Pos'][i]-1.5-digits, PipeData['y_Pos'][i]-0.5,'{zahl:.{num}f}'.format(zahl=txt,num=digits), fontsize=7)

    # Plot Well Borders
    # south
    plt.plot([20, 26], [18, 18],linewidth=1,color='grey')
    plt.plot([26,26],[18,11],linewidth=1,color='grey')
    plt.plot([26,88],[11,11],linewidth=1,color='grey')
    plt.plot([88,88],[11,18],linewidth=1,color='grey')
    plt.plot([88,110],[18,18],linewidth=1,color='grey')
    plt.plot([110,110],[18,3],linewidth=1,color='grey')
    plt.plot([110,20],[3,3],linewidth=1,color='grey')
    plt.plot([20,20],[3,18],linewidth=1,color='grey')
    # west
    plt.plot([3,26],[25,25],linewidth=1,color='grey')
    plt.plot([26,26],[25,47],linewidth=1,color='grey')
    plt.plot([26,64],[47,47],linewidth=1,color='grey')
    plt.plot([64,64],[47,54],linewidth=1,color='grey')
    plt.plot([64,3],[54,54],linewidth=1,color='grey')
    plt.plot([3,3],[54,25],linewidth=1,color='grey')
    # east
    plt.plot([65,88],[47,47],linewidth=1,color='grey')
    plt.plot([88,88],[47,19],linewidth=1,color='grey')
    plt.plot([88,111],[19,19],linewidth=1,color='grey')
    plt.plot([111,111],[19,9],linewidth=1,color='grey')
    plt.plot([111,118],[9,9],linewidth=1,color='grey')
    plt.plot([118,118],[9,54],linewidth=1,color='grey')
    plt.plot([118,65],[54,54],linewidth=1,color='grey')
    plt.plot([65,65],[54,47],linewidth=1,color='grey')

    # Plot Mean Values
    Shaft_West_Mean=sum(zValue[i] for i in range(0,12))/12     
    Shaft_South_Mean=sum(zValue[i] for i in [12,13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24])/12     
    Shaft_East_Mean=sum(zValue[i] for i in [22,25,26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39])/16
    if show_mean:
        plt.text(30,40,'''Mean Shaft West: \n'''+'''{zahl:.{num}f} '''.format(zahl=Shaft_West_Mean,num=digits)+'K',fontsize=10,fontweight='bold')
        plt.text(45,15,'Mean Shaft South: \n'+'{zahl:.{num}f} '.format(zahl=Shaft_South_Mean,num=digits)+'K',fontsize=10,fontweight='bold')
        plt.text(59,40,'Mean Shaft East: \n'+'{zahl:.{num}f} '.format(zahl=Shaft_East_Mean,num=digits)+'K',fontsize=10,fontweight='bold')

    plt.axis('off')
    plt.title(title,fontsize=16)
    return plt

if __name__ == '__main__':

    p=plot_erc_field(list(range(1,41)),title='Test',show_values= True,show_mean=True,digits=2)
    p.show()