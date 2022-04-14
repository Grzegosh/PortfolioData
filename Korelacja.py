# Link do danych : https://www.kaggle.com/datasets/danielgrijalvas/movies

#Importowanie pakietów :

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
sns.set_style('whitegrid')
from pandas import Series, DataFrame

# Zmiana widoku wyświetlania rezultatu :

pd.set_option('display.width',300)
pd.set_option('display.max_columns',30)
np.printoptions(linewidth=300)

# Importowanie danych

filmdf = pd.read_csv(r'C:\Users\grzeg\OneDrive\Pulpit\Portfolio\movies.csv', sep=',')
filmdf.head()

# Czy w naszym zbiorze są jakieś brakujące dane?

pd.isnull(filmdf[:]) #True oznacza, że wartość jest pusta.

filmdf = filmdf.dropna() #Pozbycie się pustych wartości z bazy danych


#Typy dancyh dla naszych zmiennych
filmdf.dtypes
filmdf.head()
# Zmiana format wyświetalnia danych dla kolumn 'budget','votes','gross'
filmdf.budget = filmdf.budget.astype('int64')
filmdf.gross = filmdf.gross.astype('int64')
filmdf.votes = filmdf.votes.astype('int64')

#Kolumna 'year' powinna się zgadzać z rokiem z kolumny 'released', wciągnijmy rok z kolumny 'released'
filmdf['year_rele']=filmdf.released.str.split(',',expand=True)[1].str[1:5].astype(str).dropna()
filmdf.year = filmdf.year.astype(str)
filmdf.year == filmdf.year_rele  #Wszystkie nasze wiersze się ze sobą zgadzają
filmdf.year=filmdf.year.astype('int64')

#Sortowanie danych po kolumnie gross

filmdf.sort_values(by='gross', inplace=True,ascending=False)
filmdf

##########################################################################################################

#Wizualizacje, oraz szukanie powiązań międdzy zmiennymi

#Spodziewamy się wysokiej dodatniej korelacji między kolumnami 'budget' oraz 'gross'
#Im więcej firma wyda na produkcje filmu tym większy będzie zysk

plt.scatter(x=filmdf.budget,y=filmdf.gross)

#Ten sam wynik otrzymamy dzięki pakietowi seaborn

sns.scatterplot('budget','gross',data = filmdf)

#Wykres rozrzutu z dodaną linią trendu
sns.lmplot('budget','gross',data = filmdf, line_kws={'color':'red'})
plt.title('Budżet vs Zysk')

#Stworzenie nowej ramki danych z wartościami korelacji liniowej Pearsona

korr = filmdf.corr()
korr

#Mapa cieplna z wartościami korelacji



############################################################################
#Zmiana wartosći tekstowych na liczby

filmdfn = filmdf

for coln in filmdfn.columns:
    if(filmdfn[coln].dtype=='object'):
        filmdfn[coln]=filmdfn[coln].astype('category')
        filmdfn[coln] = filmdfn[coln].cat.codes

filmdfn = filmdfn.sort_values(by='gross',ascending=False)

filmdf.head()
filmdfn.head()
filmdf.drop('year_rele',axis=1,inplace=True)
filmdfn.drop('year_rele',axis=1,inplace=True)
#Korelacja między wszystkimi zmiennymi

sns.heatmap(filmdfn.corr(),annot=True)

#Macierz korelacji
mac_cor = filmdf.corr()

mac_cor = mac_cor.unstack()

mac_cor=mac_cor.sort_values()

wysoka_mac_cor = mac_cor[(mac_cor)>0.5]

wysoka_mac_cor #Głosy oraz budżet miały największy wpływ na zysk.