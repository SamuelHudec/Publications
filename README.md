# Publications

Niektoré údaje sa na stránku (web aplikáciu) nehodili a boli by zbytočné pre väčšinu čitateľov. V nasledujúcich riadkoch popisujem zdroje, postup pri manipulácií s dátami a ich finálne úpravy do grafov.



## Zdroje

Na zostavenie finálneho datasetu som použil dva zdroje.

* [Ministerstvo školstva SR](https://www.minedu.sk/rozpis-dotacii-zo-statneho-rozpoctu-verejnym-vysokym-skolam-na-rok-2018/)
* [IDEA CERGE-EI](https://idea.cerge-ei.cz/)

Prvý zdroj obsahuje [link](https://www.minedu.sk/data/att/12810.zip) dáta o 101720 publikáciách slovenských vysokých škôl, v ktorom sú údaje za roky 2015 a 2016. Z tohto súboru je potrebná záložka označená "DATA" , ostatné záložky obsahujú nepotrebné prepočty.

Druhý zdroj obsahuje, okrem množstva zaujímavých analýz, aj štúdiu [Kde se nejvíce publikuje v predátorských a místních časopisech?](https://idea.cerge-ei.cz/files/PredatoriMistni/), v ktorej sa nachádzajú odkazy na databázy.

* **Beallové zoznamy predátorských časopisov** v databázach SCOPUS s ich [ISSN](http://www.issn.org/understanding-the-issn/what-is-an-issn/) číslami, pomocou ktorých vieme označiť publikáciu ako predátorskú. _Poznámka: Jeffrey Beall je knihovník z University of Colorado, na svojom blogu zostavil prehľad „potencionálne“ predátorských časopisov a vydavateľstiev. Tento blog bol prekvapivo zrušený v roku 2017,_ podrobnosti nájdete [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_16_2016_Predatorske_casopisy_ve_Scopusu/mobile/index.html).
* **Zoznamy miestnych časopisov** je databáza vytvorená CERGE-EI, ktorú zastrešuje podrobná štúdia [tu](https://idea.cerge-ei.cz/files/IDEA_Studie_17_2017_Mistni_casopisy_ve_Scopusu/mobile/index.html). Treba zdôrazniť, že sa nejedná len o domáce časopisy. Dataset obsahuje aj zahraničné časopisy, v ktorých často prispievali slovenský a český autori.

Oba zoznamy môžete nájsť pod názvami _SeznamMistni.xlsx_ a _SeznamPredators2017.xlsx_



## Čistenie dát

Na začiatok treba podotknúť, že za **chyby v súbore** ja neručím. Odstránil som všetky, ktoré som našiel typu Filozofická fakulta UMB, bola vedená ako už neexistujúca Fakulta financii (po preverení autorov náhodne vybraných článkov sa mi to len potvrdilo). Teda, z kompletného súboru som vybral len záložku "DATA", z tej som ďalej použil premenné (relevantné)

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

Výsledný "učesaný" dataset obsahujúci nové a niektoré staré premenné nájdete pod názvom _pubs_clean.txt_.

## Filtrácia a sumarizácie čistých dát

S takzvaným čistým datasetom sa dá ďalej ľahšie manipulovať a použiť na ľubovoľnú analýzu, preto obsahuje aj niektoré premenné, ktoré nie sú potrebné na ďalšie spracovanie. 

Vyfiltrujem len články, ktoré boli publikované v databázach **SCOPUS** . Dôvody sú uvedené buď vo vyššie predstavenej analýze od CERGE-EI alebo priamo v mojej aplikácií. Potom beriem do úvahy dva prípady sumarizácií:

* **Vysoké školy** kde spočítam počty miestnych a predátorských publikácii na vysokých školách, z tých dopočítam podieli k celkovým počtom publikácií na danej Vysokej škole. 

* **Vedecké pracoviská** kde znova spočítam počty miestnych a predátorských publikácií, ale na vedeckých pracoviskách (zväčša fakulty) vzhľadom na vedecké zameranie publikácií (FOS), nakoniec dopočítam podieli.

Oba datasety okrem iného obsahujú aj extra premennú s názvom Size slúžiacu na určenie veľkosti krúžku v grafe (schválne určená na odmocnnovej škále aby niektoré pracoviská neprekrili všetky ostatné, napríklad fakulty Univerzity Komenského). Nájdete ich pod názvami _pubs_uni.txt_ a _pubs_vedecke_prac.txt_.


## Špecifické úpravy

Dataset _pubs_vedecke_prac.txt_ použítý na detailné znázornenie sa ukázal ako príliš podrobný a graf obsahuje "veľa" krúžkov. Niektoré fakulty publikovali vo viacerých vedných odboroch ako napríklad UK - Prírodovedecká fakulta má publikácie aj v Spoločenských vedách, čo nie je nič nové. Lenže na prvý náhľad grafu môže práve toto pôsobiť zmätočne, a preto som sa po konzultáciách s kolegami rozhodol **zlúčiť publikácie** v daných vedeckých pracoviskách pod jedným hlavným vedným oborom. 

**Hlavný vedný odbor** považujem taký, v ktorom má dané vedecké pracovisko najväčší počet publikácií bez ohľadu na to, či sa jedná o miestne alebo predátorské. Väčšina pracovísk vyšla intuitívne, napríklad Fakulta prírodných vied dostala prívlastok prírodné vedy, ale v dateasete nájdete aj také, ktoré intuitivne nesedia napríklad Filozofická fakulta ako spoločenské vedy. Poznámka: pár pracovísk bolo nerozhodných, tak som teda stanovil hlavný vedný odbor pracoviska podľa najrozumnejšej možnosti.

Zlučovanie neplatilo pre vedecké pracoviská, ktoré nemali fakulty (nemohol som určiť hlavný vedný odbor celej vysokej školy) a pre mimofakultné publikácie. Mimofakultné publikácie boli zlúčené do jednej množiny **mimo fakúlt** a spadajú tam publikácie označené mimo fakúlt :  rektorát, centrálna časť a pracoviská.

Po úpravách som znova dopočítal sumarizácie a výsledný dataset nájtede pod názvom _pubs_vedecke_prac_uprava.txt_. 



## Spustenie aplikácie

online cez shiny cloud
<https://samuell.shinyapps.io/publications/>
