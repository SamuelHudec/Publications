# Publications

Niektoré dôležité údaje sa na stránku (web aplikáciu) nehodili a boli by viac menej zbytočné pre väčšinu čitateľov. V nasledujúcich riadkoch popisujem zdroje, postup pri manipulácií s dátami a ích finálne úpravy do grafov.



## Zdroje

Na zostavenie finalneho datasetu som použil dva zdroje,

* [Ministerstvo školstva SR](https://www.minedu.sk/rozpis-dotacii-zo-statneho-rozpoctu-verejnym-vysokym-skolam-na-rok-2018/)
* [IDEA CERGE-EI](https://idea.cerge-ei.cz/)

Prvý zdroj obsahuje [link](https://www.minedu.sk/data/att/12810.zip) na dáta o 101720 publikáciách slovenských vysokých škôl, v ktorom sú údaje za roky 2015 a 2016. Z tohto súboru je potrebná záložku označenú "DATA" ostatné záložky obsahujú nám nepotrebné prepočty.

Druhý zdroj obsahuje okrem množstva zaujímavých analýz aj štúdiu [Kde se nejvíce publikuje v predátorských a místních časopisech?](https://idea.cerge-ei.cz/files/PredatoriMistni/), v ktorej sa nachádzajú odkazy na databázy

* **Beallové zoznamy predátorských časopisov** v databázach SCOPUS s ích [ISSN](http://www.issn.org/understanding-the-issn/what-is-an-issn/) číslami pomocou, ktorých vieme označiť publikáciu ako predátorskú. _Poznámka: Jeffrey Beall je knihovník z University of Colorado, na svojom blogu zostavil prehľad „potencionálne“ predátorských časopisov a vydavateľstiev. Tento blog bol prekvapivo zrušený v roku 2017,_ podrobnosti nájdete [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_16_2016_Predatorske_casopisy_ve_Scopusu/mobile/index.html).
* **Zoznamy miestnych časopisov** je databáza vytvorená CERGE-EI, ktorú zastrešuje podrobná štúdia [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_17_2017_Mistni_casopisy_ve_Scopusu/mobile/index.html). Treba zdôrazniť nejedná len o domáce časopisy data set obsahuje aj zahraničné v ktorých často prispievali Slovenský a Český autori.

Oba zoznamy môžete najsť aj v tomto repository pod názvami _SeznamMistni.xlsx_ a _SeznamPredators2017.xlsx_



## Čistenie dát

Ako už bolo spomenuté z kompletného súboru som vybral len založku "DATA", z tej som ďalej vybral selektoval premenné (relevantné)

* VS_KOD, 
* VS_NAZOV, 
* FAKULTA_NAZOV, 
* AUTORI_VSETCI, 
* AUTORI_VS, 
* WOS,
* SCOPUS, (tieto casopisy nás zaujímajú)
* ISSN_bez.pomlcky,
* JAZYK, (zaujmalo ma aj koľko časopisov je písaných v rodnom jazyku, môžno v budúcnosti použijem)
* OBLAST_VYSKUMU_KOD.

Na základe týchto premenných som:

* **Napároval** predátorske a miestne časopisy podľa ISSN v databázach.
* **Upravil** formáty jednotlivých premenných ako je SCOPUS na jednotné (klasické) značenie 0 a 1.
* **Vyčistil** názvy jednotlivých vedeckých pracovísk, ktoré obsahovali aj rôzne interné značenia.
* **Pridal** novú premennú FOS obsahujúcu vedecké zamerania _Fields of Science_ napárované podľa zoznamu _oblastivyskumu-kodovnik.xlsx_ cez premennú OBLAST_VYSKUMU_KOD. 

Výsledný "učesaný" dataset obsahujúci nové a niektoré staré premenné najtede pod názvom _pubs_clean.txt_.

## Filtrácia a sumarizácie čistých dát

S takzvanými čistým datasetom sa dá ďalej ľahšie manipulovať a použiť na ľubovolnú analýzu preto obsahuje aj niektoré premenné, ktoré nie sú potrebné na ďalšie spracovanie. 

Vyfiltrujem len články, ktoré boli publikované v databázach **SCOPUS** dôvody sú uvedené buď vo vyššie predstavenej analýze od CERGE-EI alebo priamo v mojej aplikácií. Potom uvažujem dva prípady sumarizácií

* **Vysoké školy** teda spočítam počty miestnych a predátorských publikácii na vysokých školách z tých dopočítam podieli k celkovým počtom publikácií na danej Vysokej škole. 

* **Vedecké pracoviská** znova spočítam počty miestnych a predátorských publikácií, ale na vedeckých pracoviskách (zväčša fakulty) vzhľadom na vedecké zameranie publikácií (FOS), nakoniec dopočítam podieli.

Oba datasety okrem iného obsahujú aj extra premennú s názvom Size slúžiacu na výpočet veľkosti krúžku v grafe. Nájdete ích pod názvami _pubs_uni.txt_ a _pubs_vedecke_prac.txt_.


## Špecifické úpravy

Dataset _pubs_vedecke_prac.txt_ použítý na detailné znázornenie sa ukázal ako príliš podrobný a graf obsahuje "veľa" krúžkov. Niektoré fakulty publikovali vo viacerých vedných odboroch ako napríklad UK - Prírodovedecká fakulta má publikácie aj v Spoločenských vedách, čo nie je nič nové. Lenže na prvý náhľad grafu môže práve toto pôsobiť zmetočne a preto som sa po konzultáciách s kolegami rozhodol **zlúčiť publikácie** v daných vedeckých pracoviskách pod jedným hlavným vedným oborom. 

**Hlavný vedný odbor** považujem taký, v ktorom má dané vedecké pracovisko najväčší počet publikácií bez ohľadu na to či sa jedná o miestne alebo predátorské. Väčšina pracovísk vyšlo intuitívne napríklad Fakulta prírodných vied dostala prívlastok prírodné vedy, ale v dateasete najdete aj také, ktoré intuitivne nesedia. Poznámka: pár pracovísk bolo nerozhodných, teda som stanovil hlavný vedný odbor pracoviska podľa najrozumnejšej možnosti.

Zlučovanie neplatilo pre vedecké pracoviská, ktoré nemali fakulty (nemohol som určiť hlavný vedný odbor celej vysokej školy) a pre mimofakultné publikácie. Mimofakultné publikácie boli zlúčené do jednej množiny **mimo fakúlt** a spadajú tam publikácie označené mimo fakúlt, rektorát, centrálna časť a pracoviská.

Po úpravách som znova dopočítal sumarizácie a výsledný dataset nájtede pod názvom _pubs_vedecke_prac_uprava.txt_. 



## Spustenie aplikácie

online cez shiny cloud
<https://samuell.shinyapps.io/publications/>

alebo máte nainštalované R-ko s Rstudiom a chcete mi ušetriť hodiny na účte, tak použite GitHub cestu. Potrebuje mať nainštalované knižnice: **shiny, shinythemes, ggplot2, dplyr, plotly a gridExtra**.

Potom už len spustiť príkaz

**library(shiny)**

**runGitHub("Publications", "SamuelHudec")**
