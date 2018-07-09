# Publications

V nasledujúcich riadkoch popisujem zdroje, postup pri manipulácií s dátami a ích finálne úpravy do analýzy. Na konci skriptu sú odkazy na spustenie aplikácie buď online alebo lokalne na počítači cez GitHub.



## Zdroje

Na zostavenie finalneho datasetu som použil dva zdroje,

* [Ministerstvo školstva SR](https://www.minedu.sk/rozpis-dotacii-zo-statneho-rozpoctu-verejnym-vysokym-skolam-na-rok-2018/)
* [IDEA CERGE-EI](https://idea.cerge-ei.cz/)

Prvý zdroj obsahuje [link](https://www.minedu.sk/data/att/12810.zip) na dáta o 101720 publikáciách slovenských vysokých škôl, v ktorom sú údaje za roky 2015 a 2016. Z tohto súboru ďalej potrebujeme len záložku označenú "DATA".

Druhý zdroj obsahuje okrem iného aj štúdiu [Kde se nejvíce publikuje v predátorských a místních časopisech?](https://idea.cerge-ei.cz/files/PredatoriMistni/), z ktorej ďalej čerpám databázy,

* **Beallové zoznamy predátorských časopisov** v databázach SCOPUS s ích [ISSN](http://www.issn.org/understanding-the-issn/what-is-an-issn/) číslami pomocou, ktorých vieme označiť publikáciu ako predátorskú. _Poznámka: Jeffrey Beall je knihovník z University of Colorado, na svojom blogu zostavil prehľad „potencionálne“ predátorských časopisov a vydavateľstiev. Tento blog bol prekvapivo zrušený v roku 2017,_ podrobnosti nájdete [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_16_2016_Predatorske_casopisy_ve_Scopusu/mobile/index.html).
* **Zoznamy miestnych časopisov** je databáza vytvorená v CERGE-EI, ktorú zastrešuje podrobná štúdia [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_17_2017_Mistni_casopisy_ve_Scopusu/mobile/index.html). 

Oba zoznamy môžete najsť aj v tomto repository pod názvami _SeznamMistni.xlsx_ a _SeznamPredators2017.xlsx_



## Čistenie dát

Ako už bolo spomenuté z kompletného súboru som vybral len založku "DATA", z tej som ďalej vybral premenné (relevantné)

* VS_KOD, 
* VS_NAZOV, 
* FAKULTA_NAZOV, 
* AUTORI_VSETCI, 
* AUTORI_VS, 
* WOS,
* SCOPUS, (tieto casopisy nás zaujímajú)
* ISSN_bez.pomlcky,
* JAZYK, (zaujmalo ma aj koľko časopisov je písaných v rodnom jazyku)
* OBLAST_VYSKUMU_KOD.

Na základe týchto premenných som:

* **Napároval** predátorske a miestne časopisy podľa ISSN v databázach.
* **Upravil** formáty jednotlivých premenných ako je SCOPUS na jednotné (klasické) značenie 0 a 1.
* **Vyčistil** názvy jednotlivých vedeckých pracovísk, ktoré obsahovali aj rôzne interné značenia.
* **Pridal** novú premennú FOS obsahujúcu vedecké zameranie publikácie delené podľa _Fields of Science_ napárované podľa zoznamu _oblastivyskumu-kodovnik.xlsx_ cez premennú OBLAST_VYSKUMU_KOD. 

Výsledný "učesaný" dataset obsahujúci nové a niektoré staré premenné najtede pod názvom _pubs_clean.txt_.

## Filtrácia a sumarizácie čistých dát

Vyfiltrujem len články, ktoré boli publikované v databázach **SCOPUS** dôvody sú uvedené buď vo vyššie predstavenej analýze od CERGE-EI alebo priamo v mojej aplikácií. Potom uvažujem dva prípady sumarizácie

* **Vysoké školy** teda spočítam počty miestnych a predátorských publikácii na vysokých školách z tých dopočítam podieli k celkovým počtom publikácií na danej Vysokej škole. 

* **Vedecké pracoviská** znova spočítam počty miestnych a predátorských publikácii, ale na vedeckých pracoviskách (zväčša fakulty) vzhľadom na vedecké zameranie publikácií (FOS), nakoniec dopočítam podieli.

Oba datasety okrem iného obsahujú aj extra premennú s názvom Size slúžiacu na výpočet veľkosti bubliny v grafe. Nájdete ích pod názvami _pubs_uni.txt_ a _pubs_vedecke_prac.txt_.


## Špecifické úpravy

Dataset _pubs_vedecke_prac.txt_ použítý na detailné znázornenie sa ukázal ako príliš podrobný a graf obsahuje "veľa" bublín. Niektoré fakulty publikovali vo viacerých vedných odboroch ako napríklad UK - Prírodovedecká fakulta má publikácie aj v Spoločenských vedách, čo nie je nič nové. Lenže na prvý náhľad grafu môže práve toto pôsobiť zmetočne a preto som sa po konzultáciách s kolegami rozhodol **zlúčiť publikácie** v daných vedeckých pracoviskách pod jedným hlavným vedným oborom. 

**Hlavný vedný odbor** považujem taký, v ktorom má dané vedecké pracovisko naväčší počet publikácií bez ohľadu na to či sa jedná o miestne alebo predátorské. Väčšina prípadov bola _intuitívna_ napríklad Fakulta prírodných vied dostala prívlastok prírodné vedy, ale v dateasete najdete aj také, ktoré _intuitivne nesedia_. Poznámka: pár prípadov bolo nerozhodných, teda som stanovil hlavný vedný odbor pracoviska podľa najrozumnejšej možnosti.

Zlučovanie neplatilo pre vedecké pracoviská, ktoré nemali fakulty (nedalo sa jednoznačne určiť hlavný vedný odbor) a pre mimofakultné publikácie zjednotené pod jedným názvom _mimo fakúlt_. Do množiny **mimo fakúlt** spadajú publikácie označené ako mimo fakúlt, rektorát, centrálna časť a pracoviská.

Po úpravách som znova dopočítal sumarizácie a výsledný dataset nájtede pod názvom _pubs_vedecke_prac_uprava.txt_. 



## Spustenie aplikácie

<https://samuell.shinyapps.io/publications/>
