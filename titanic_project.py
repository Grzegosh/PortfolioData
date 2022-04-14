#Zbiór danych dostępny pod : https://www.kaggle.com/c/titanic
#Imortowanie wymaganych modułów

import pandas as pd
import numpy as np
import seaborn as sns
sns.set_style('whitegrid')
import matplotlib as mpl
import matplotlib.pyplot as plt
from pandas import Series, DataFrame

#Modyfikacja wyświetlania danych

pd.set_option('display.width',300)
pd.set_option('display.max_columns',30)
np.printoptions(linewidth=300)

#Importowanie danych oraz opis danych

titanicdf = pd.read_csv(r'C:\Users\grzeg\OneDrive\Pulpit\Portfolio\train.csv', sep=',')
titanicdf.head()

titanicdf.info()

#Kim byli pasażerowie titanica ?

sns.catplot('Sex', data=titanicdf, kind='count') #Zdecydowaną większością pasażerów byli mężczyźni

#Załóżmy, że dzieci  mają 16 lub mniej lat.

def plec(df):
   wiek,plec = df

    if wiek <= 16:
        return 'Child'
    else:
        return plec

titanicdf['Plec2'] = titanicdf[['Age','Sex']].apply(plec,axis=1)

#Ponownie sprawdźmy, kim byli pasażerowie titanica, tym razem z uwzględnieniem dzieci.

sns.catplot('Plec2', data=titanicdf, kind='count')

#Jak do płci ma się klasa, którą podróżowali pasażerowie ?

sns.catplot('Pclass', hue = 'Plec2', data=titanicdf, kind='count') #Klasa 3 miała najwięcej pasażerów w każdej płci

#Przyjrzyjmy się wiekowi

plt.hist('Age', data=titanicdf) # Możemy zakładać, że przecięty wiek pasażera zawiera się w przedziale od 20 do 40 lat.
titanicdf.Age.mean()
titanicdf.Age.std()
#Przeciętny wiek pasażera wynosi 29,7 lat z odchyleniem standardowym na poziomie 14,52 lat. Co oznacza, że
#najczęściej wiek wachał się w przedziale od średnia - odchylenie | średnia + odchylenie

#Wykres gęstości wieku pasażerów
x = sns.FacetGrid(data=titanicdf, hue='Plec2', aspect=4)
x.map(sns.kdeplot, 'Age', shade=True)
najmlodszy = titanicdf.Age.min()
najstarszy = titanicdf.Age.max()
x.set(xlim=(najmlodszy,najstarszy))
x.add_legend()

#Sprawdźmy z jakich miast byli nasi pasażerowie

sns.catplot('Embarked', data=titanicdf, kind='count') # Najwięcej pasażerów było z Southampton

# Porównajmy klasę pasażerów z ich miejscem zamiekszaznia

sns.catplot('Embarked', hue='Pclass', data=titanicdf, kind='count') #Co ciekawe, pasażerowie, którzy byli z Quenstown,
#praktycznie zawsze wybierali klasę 3

#Sprwadźmy jak miała się sprawa z kabinami.

cabindf = DataFrame(titanicdf['Cabin']).dropna()
cabindf.head()
cabindf['Cab'] = cabindf.Cabin.str[0] #Wyrzuci indeks, po którym możemy grupować naszych pasażerów
sns.catplot('Cab', data = cabindf, kind='count')
# Najwięcej pasażerów było w kabinach oznaczonych literą "C"


#Zbadajmy czy nasi pasażerowi byli z rodziną, czy sami

titanicdf['Rod'] = titanicdf.SibSp + titanicdf.Parch
titanicdf.head()

def sam (df):
    sam = df

    if sam == 0:
        return 'Sam'
    else:
        return 'Z rodziną'
titanicdf['Rodzina'] = titanicdf.Rod.apply(sam)

sns.catplot('Rodzina', data=titanicdf, hue='Plec2', kind='count') # Większość pasażerów była sama na statku

#Przjrzyjmy się teraz ocalałym

titanicdf['Przezyl'] = titanicdf.Survived.map({0:'Nie',1:'Tak'})

sns.catplot('Przezyl', data=titanicdf, kind='count')
plt.xlabel('Czy przeżył?') # Większość pasażerów nie przeżyła.

#Kto miał największe szanse na przeżycie ?
sns.catplot('Plec2','Survived', data=titanicdf, kind='point') #Największe szanse na przeżycie miały kobiety. Bo aż od 70 do 80%.
#Niestety, ale zgodnie z prawem 'Kobiety i dzieci przodem', mężczyźni mieli bardzo małą szansę na przeżycie.

#Porównajmy tą informacje do wieku
generacje = [10,20,30,40,50,60,70,80,90]
sns.lmplot('Age','Survived', data = titanicdf, hue='Plec2', x_bins = generacje) # Im starza osoba tym ma większe szanse przeżycia (nie licząc dzieci)

#Zobaczymy jak ma się klasa do przeżywalności

sns.lmplot('Age','Survived', hue='Pclass', data=titanicdf) #Największe szanse, na przeżycie mieliśmy w klasie 1

#Zobaczmy jak się jeszcze ma rodzaj kabiny do przeżywalności

cabindf2 = DataFrame(titanicdf[['Cabin','Survived']]).dropna()
cabindf2['Cab'] = cabindf2.Cabin.str[0]
sns.catplot('Cab','Survived', data=cabindf2, kind='point')

#Usuwamy z tabeli kabinę 'T' ponieważ zaburza nam wizualizacje

cabindf2 = cabindf2[cabindf2['Cab']!='T']

sns.catplot('Cab','Survived', data=cabindf2, kind='point')
# Najpewniejsza była kabina 'E'. W kabinie 'G' było największe ryzyko. Ponieważ odchylenie było bliskie 1.



