---
title: "Utrzymanie maszyn w funkcjonowaniu magazynu"
execute:
  echo: false
  warning: false
---

::: {.cell}

:::


## Zrozumienie danych

Wybrane przez nas zadanie analityczne dotyczy predykcji uszkodzenia maszyn magazynowych oraz analiza wrażliwości wybranych modeli.

Opracowywany zbiór danych zawiera następujące zmienne

-   UID - unikalny identyfikator

-   Product_ID - Numer seryjny produktu

-   Type - wariant jakościowy produktu

-   Air_temperature - temperatura powietrza w pokoju

-   Process_temperature - temperatura w której wykonywany jest proces

-   Rotational_speed - częstotliwość obrotowa

-   Torque - moment obrotowy

-   Tool_wear - czas pracy w minutach danego narzędzia

-   Machine_failure - czy wystąpiła usterka

Oraz wyszczególnione powody usterek:

-   TWF - tool wear failure - szkoda powstała w wyniku zużycie narzędzia

-   HDF - heat dissipation failure - szkoda powstała w wyniku dysypacji ciepła

-   PWF - power failure - usterka z powodów energetycznych

-   OSF - overstrain failure - przeciążenie maszyny

-   RNF - random failures - losowe uszkodzenia


::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-2-1.png){width=672}
:::
:::


Z macierzy korelacji widać, że ustreki maszy (co logczine) skorelowane są z poszczególnymi typami problemów funkcjonowania, lecz co ciekawe losowe usterki nie mają żadnego wpływu na pracę maszyn.

Pozostałe silne korelacje również sa intuicyjnie logiczne tj. temperatura powietrza z temperaturą procesu oraz częstotliwość obrotowa z momentem obrotowym.


::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-3-1.png){width=672}
:::
:::


Wykresy rozkładu temperatur w przypadku powietrza sugeruje platokurtyczność oraz dla usterek maszyn dwumodalność z częstszym występowaniem w wyższych zakresach. Podobne zjawisko można zaobserwować dla temperatury procesu lecz kurtoza bliższa jest rozkładu normalnego dzięki czemu dla rozkładu w których występowały usterki uwydacznia się lewostronna asymetria. Możliwe że konieczne będzie transformowanie zmiennych dla lepszych rezultatów.


::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-4-1.png){width=672}
:::
:::


Rozkłady częstotliwości obrotowej niezależnie od występowania usterki maszyny kształtem przypominają rozkład $\chi^2$ ze względu na bardzo silną asymetrię prawostronną. Natomiast w przypadku momentu obrotowego dla braku usterki rozkład kształtem przypomina dzwon Gaussa ze średnią 40. Powyżej tej wartości w rozkładzie obserwacji, gdzie wystąpiła usterka widać nagły wzrost częstości występowania uszkodzeń.


::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-5-1.png){width=672}
:::
:::


Rozkład zużycia narzędzia do dwusetnej minuty jest jednostajny, natomiast powyżej tej wartości następuje gwałtowny wzrost częstotliwości występowania usterek, pozwala to podejrzewać że jest to istotna zmienna w kontekście utrzymania maszyn.

Dodatkowo widać bardzo silne niezbalansowanie klas w przypadku usterek, będzie to wymagało uwzględnienia w przypadku budowania modeli uczenia maszynowego, szczególnie że jesto to zmienna która będzie przewidywana i dookoła której prowadzona będzie optymalizacja.


::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-6-1.png){width=1920}
:::
:::

::: {.cell}
::: {.cell-output-display}
![](BHL8_Data_GigaChads_files/figure-html/unnamed-chunk-7-1.png){width=672}
:::
:::


Nejczęściej występującym typem usterki jest ta powstała w wyniku dyssypacji ciepła, drugim najczęstszym powodem wystąpienia usterek jest przeciążenie maszyny w nieznacznie mniejszej ilości przypadków jest to usterka z przyczyn energetycznych. Znacząco rzedziej występującym czynnikiem jest zużycie narzędzia, najrzadziej występujacą przyczyną są losowe uszkodzenia.


## Budowa modeli uczenia maszynowego

Ze względu na silne niezrównoważenie klas zaobserwowane w części eksploracyjnej zdecydowaliśmy się na zastosowanie metody upsamplingu w technice SMOTE (Synthetic Minority Oversampling Technique) chcąc uniknąć zjawiska nadmiernego dopasowania przy jednoczesnym zachowaniu jakości predykcji.

Modele uczenia maszynowego zbudowane na cele zadania:

-   Random forest

-   Decision tree

-   Suport vector machine

-   K-Nearest Nighbors

-   Neural network

-   XGBoost

-   Linear regression

