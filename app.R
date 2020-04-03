
# libraries
library(shiny)
library(shinythemes)
library(tidyverse)
library(plotly)
library(gridExtra)

# datasets GitHub ####
# filtred, grouped, counted and selected datasets from raw pubsFull listed on link
# https://raw.githubusercontent.com/SamuelHudec/Publications/master/pubsFull.txt
pubsUN <- read.table("https://raw.githubusercontent.com/SamuelHudec/Publications/master/pubs_uni.txt", header=TRUE, quote="\"")
pubsUNF <- read.table("https://raw.githubusercontent.com/SamuelHudec/Publications/master/pubs_vedecke_prac.txt", header=TRUE, quote="\"")
pubsUNFcor <- read.table("https://raw.githubusercontent.com/SamuelHudec/Publications/master/pubs_vedecke_prac_uprava.txt", header=TRUE, quote="\"")




## external commands and funcitons ####

rotatedAxisElementText = function(angle,position='x'){
  angle     = angle[1]; 
  position  = position[1]
  positions = list(x=0,y=90,top=180,right=270)
  if(!position %in% names(positions))
    stop(sprintf("'position' must be one of [%s]",paste(names(positions),collapse=", ")),call.=FALSE)
  if(!is.numeric(angle))
    stop("'angle' must be numeric",call.=FALSE)
  rads  = (angle - positions[[ position ]])*pi/180
  hjust = 0.5*(1 - sin(rads))
  vjust = 0.5*(1 + cos(rads))
  element_text(angle=angle,vjust=vjust,hjust=hjust)
}
cols <- c("Humanitné vedy"="#F8766D", "Lekárske vedy"="#B79F00", "Poľnohospodarske vedy"="#00BA38", "Prírodné vedy"="#00BFC4", "Spoločenské vedy"="#619CFF", "Technické vedy"="#F564E3")
VS <- levels(pubsUN$VS_NAZOV)

# Define UI for application ####
ui <- fluidPage(theme=shinytheme("paper"),titlePanel(NULL,windowTitle = "Publikácie"),
  
  align="justify",
  # Application title
  fluidRow( 
    h1("Predátorské a miestne vedecké časopisy na slovenských vysokých školách",align="center")
    ),
  
  
  # couple intro breaks
  br(),br(),br(),
  # whole page
  
  ## Intro ####
  fluidRow(
    column(6,offset=3,
      p(strong('Kde sa najviac publikuje v predátorských a miestnych časopisoch?'),
      "To je otázka, ktorú si položili páni Vít Macháček a Martin Srholec z IDEA CERGE-EI 
        a v Júni 2018 publikovali", a(href="https://idea.cerge-ei.cz/files/PredatoriMistni/", "Bibliometrická analýza trochu jinak."),
      " Analýza sa zaoberá podielom publikácií vedeckých pracovísk v takzvaných \"predátorských\" a \"miestnych\" časopisoch v databáze",strong("SCOPUS.")
      ),
      p("Inšpirovaný touto prácou som sa rozhodol pozrieť na situáciu na Slovensku za použitia verejne dostupných dát", 
        a(href="https://www.minedu.sk/rozpis-dotacii-zo-statneho-rozpoctu-verejnym-vysokym-skolam-na-rok-2018/" ,"Ministersva školstva")," za roky 2015 a 2016. 
        Podrobný postup spracovania a všetky použité dáta nájdete na tomto", a(href="https://github.com/SamuelHudec/Publications", "linku.")
      ),hr(),br(),
      p("Zamestnanci vysokého školstva sú motivovaní publikovať, nakoľko na základe publikačnej činnosti majú ich pracoviská pridelené finančné prostriedky. 
        Okrem financií z Ministerstva školstva od publikovania závisí aj získavanie grantov, kariérny rast, ako aj schopnosť pracoviska garantovať študijné programy.", strong("SCOPUS"), 
        "je databáza, ktorá má fungovať ako garancia kvality, no aj tu sa nachádza veľmi malé percento časopisov, ktorých kvalita je otázna."
      ),
      h5("Nie je publikácia ako publikácia",align="center"),br(),
      p("Vedecké časopisy sú veľmi rôznej kvality. Tie najkvalitnejšie opublikujú len veľmi malý zlomok článkov, ktoré sú im zaslané a tieto podliehajú prísnemu 
        recenznému procesu zo strany editorov a niekoľkých anonymných odborných posudzovateľov, kde proces obvykle trvá mesiace (niekedy až roky). 
        Okrem kvalitných časopisov sú však aj časopisy menej kvalitné, kde je selekčný proces mierny a šanca prijatia vedeckého článku vysoká."
        ),br(),
      p("Najhoršie, takzvané",strong("Predátorské časopisy"), "akademikom za poplatok ponúkajú rýchlu publikáciu článkov 
        bez poriadneho alebo žiadneho recenzného konania.  Známe sú mnohé prípady, keď predátorský časopis uverejnil úplné nezmysly,
        z ktorých je zrejmé, že článok nevidel ani len editor. Aj SCOPUS obsahuje takéto časopisy pričom náš systém kategorizácie publikácií ich
        nevie odlíšiť od množstva kvalitných časopisov, a preto takéto predátorské publikácie umožňujú \"klamať systém\"."
        ),
      p("Akademici, ktorí majú schopnosti publikovať v kvalitných časopisoch, sa takýmto časopisom snažia zďaleka vyhnúť. Tu sa odvolávam na zoznam 
        časopisov z Beallovho blogu verzia Apríl 2016, ktorý je na účely odhaľovania podvodných časopisov používaný po celom svete. 
        Na podrobnejšie vysvetlenie problematiky odporúčam štúdiu s názvom",
        a(href="https://idea.cerge-ei.cz/files/IDEA_Studie_16_2016_Predatorske_casopisy_ve_Scopusu/mobile/index.html", "Predátorské časopisy ve Scopusu"),
        "alebo", a(href="https://en.wikipedia.org/wiki/Predatory_open-access_publishing", "Predatory publishing.")
        ), br(),
      p("Štruktúra prispievajúcich autorov taktiež vypovedá o relevantnosti časopisu. 
        Prestížne časopisy sú spravidla vysoko medzinárodné. Naopak časopisy, v ktorých je okruh prispievateľov úzky, publikujú dôležité vedecké práce len výnimočne.
        Akademici mimo tohoto okruhu do nich nielenže neprispievajú, ale pravdepodobne ich ani nečítajú. Za",strong("miestne orientované časopisy"), "považujeme tie,
        ktoré \"veľa\" publikujú články od autorov zo Slovenska a Česka (nejde len o domáce časopisy)."
        ), 
      p("Publikácia v miestnom časopise neznamená automaticky, že nejde o kvalitnú vedu. Napríklad je prirodzené publikovať v miestnych časopisoch s užším okruhom prispievajúcich 
        v tom, prípade, že vedecký výsledok článku je relevantný predovšetkým pre danú geografickú oblasť. Pre podrobnejšiu predstavu a osvetlenie problému 
        odporúčam štúdiu", a(href="https://idea.cerge-ei.cz/files/IDEA_Studie_17_2017_Mistni_casopisy_ve_Scopusu/mobile/index.html", "Místní časopisy ve Scopusu.") 
        ),hr(),br()
    )
  ),
  
  
  ## Faculty analysis ####
  fluidRow(
    column(6,offset=1,
      h3("Vedecké pracoviská",align="center"),
      
      # render plot 
      plotlyOutput(outputId="UFPlot",height = "600px")
    ),
    
    # plot notes
    column(4,br(),br(),br(),br(),align="left",
      p(strong("Krúžky"), "na grafe predstavujú jednotlivé výskumné pracoviská s farbami podľa vedeckého zamerania. 
        Veľkosť krúžku zodpovedá počtu celkovo publikovaných článkov na danom pracovisku."
        ),
      p("Klikaním na", strong("legendu"), "schováte alebo zobrazíte vedecké zamerania."
        ),
      p(strong("Osi")," predstavujú podiely článkov v predátorských a miestnych časopisoch ku 
        všetkým článkom daného pracoviska."),
      p("Takže pracoviská, ktoré sú čo najbližšie rohu publikujú predovšetkým v kvalitných 
        medzinárodných časopisoch. Naopak, čím vyššie je pracovisko na grafe, tým má väčší podiel 
        predátorských publikácií a čím je viac vpravo, tým má väčší podiel miestnych publikácií."
        ),
      hr(),
      # change ordering
      radioButtons(inputId="radio", label = "Zmeň spôsob triedenia vedeckých pracovísk",
          choices = list("Hlavné vedecké zameranie pracoviska" = "cor", 
            "Vedecké zameranie publikácií pracovísk" = "raw"), 
          selected = "cor"),br(),
      # select department
      selectInput(inputId = "select_VS",label="Filtruj Vysokú školu",
                  choices = c(list("Všetky",
                    "Akadémia ozbrojených síl v Liptovskom Mikuláši",
                    "Akadémia Policajného zboru v Bratislave",
                    "Ekonomická univerzita v Bratislave",
                    "Hochschule Fresenius gGmbH",
                    "Katolícka univerzita v Ružomberku",
                    "Paneurópska vysoká škola",
                    "Prešovská univerzita v Prešove",
                    "Slovenská poľnohospodárska univerzita v Nitre",
                    "Slovenská technická univerzita v Bratislave",
                    "Slovenská zdravotnícka univerzita v Bratislave",
                    "Technická univerzita v Košiciach",
                    "Technická univerzita vo Zvolene",
                    "Trenčianska univerzita Alexandra Dubčeka v Trenčíne",
                    "Trnavská univerzita v Trnave",
                    "Univerzita J. Selyeho",
                    "Univerzita Komenského v Bratislave",
                    "Univerzita Konštantína Filozofa v Nitre",
                    "Univerzita Mateja Bela v Banskej Bystrici",
                    "Univerzita Pavla Jozefa Šafárika v Košiciach",
                    "Univerzita sv. Cyrila a Metoda v Trnave",
                    "Univerzita veterinárskeho lekárstva a farmácie v Košiciach" = "Univerzita veterinárskeho lekárstva", # problematic name for filter funciton (unknowreason)
                    "Vysoká škola bezpečnostného manažérstva v Košiciach",
                    "Vysoká škola Danubius",
                    "Vysoká škola DTI",
                    "Vysoká škola ekonómie a manažmentu verejnej správy v Bratislave",
                    "Vysoká škola manažmentu v Trenčíne",
                    "Vysoká škola medzinárodného podnikania ISM Slovakia v Prešove",
                    "Vysoká škola múzických umení v Bratislave",
                    "Vysoká škola výtvarných umení v Bratislave",
                    "Vysoká škola zdravotníctva a sociálnej práce sv. Alžbety v Bratislave",
                    "Žilinská univerzita v Žiline")),
                  selected = "Všetky"
      )
    )
  ),
  
  fluidRow(
    column(10,offset=1,br(),br(),
      p("Ak si v legende vykliknete len",strong("Spoločenské vedy a Prírodné vedy,")," tak uvidíte 
        medzi nimi podstatný rozdiel. Kým prírodné vedy sú sústredené viacej k ľavému dolnému rohu,
        spoločenské vedy sú sústredné prevažne ďalej. Ak ponecháte len",strong("Poľnohospodárske vedy,")," tak si môžete všimnúť prevažne
        publikácie v miestnych časopisoch, čo spôsobuje aj užší okruh možnosti publikácie."), 
      p("Jedno a to isté pracovisko môže publikovať vo viacerých vedeckých oblastiach, a preto ponúkam možnosť prepnúť ", strong("spôsob triedenia")," publikácií 
        pracoviska, nie len na základe zamerania pracoviska ako celku. V grafe sa môže jedno pracovisko vyskytnúť viackrát pričom sa počet publikácií v súčte nezmení. 
        Týmto pohľadom je vidieť hlbšie do štruktúry a dajú sa ľahšie všimnúť cieľové (zaujímavé) skupinky."
        ),
      p("Graf je taktiež možné zúžiť len na",strong("jednu vysokú školu"),", čím sa zvýrazní rozdiel medzi jej jednotlivými fakultami alebo pracoviskami. 
        Je vidieť, že na niektorých vysokých školách je za vyšší podiel predátorských publikácií zodpovedných len pár pracovísk. V takýchto prípadoch 
        je zrejme potrebné individuálne diskutovať o dôvodoch, ktoré vedú pracovníkov k systematickému publikovaniu v pochybných časopisoch."
        )
    )
  ),
  
  # own row for same break as before
  fluidRow(
    column(6,offset=3, hr(),br()
    )
  ),
  
  
  
  ## University analysis ####
  # own row for subtitle
  fluidRow(h3("Pozrime sa na ten istý problém, ale na úrovni vysokých škôl",align="center")
  ),
  
  fluidRow(
    column(6,offset=1,
      plotlyOutput(outputId="UPlot",height = "600px")
    ),
    column(4,br(),
      p(strong("Zásadný rozdiel")," je viditeľný ihneď, akonáhle sa pozeráme na publikácie cez vysoké školy. Všetky pracoviská publikujúce výrazne v predátorských a miestnych časopisoch 
        sa \"schovali\" za ich vysokú školu a už nie sú \"na očiach\".",strong("Na druhej strane")," týmto pohľadom hádžeme do jedného mecha aj poctivejšie pracoviská, ktoré sa až na výnimky 
        snažia takýmto publikáciám vyhnúť.",align="left"),hr(),
      h4("Pár slov na záver",align="center"),
      p("Na Slovensku máme veľké množstvo prvotriednych odborníkov uznávaných vo svete, právom hrdých na svoju prácu. 
        Tu som ukázal rozdiely v publikovaní na vysokých školách. Problémom určite nie sú len ľudia, ale aj systém, ktorý 
        ich \"núti\" publikovať a ak systematicky nie je v schopnostiach vysokoškolského pracovníka publikovať v kvalitných
        časopisoch, uchyľuje sa k nekvalitným. Tí, ktorí vedome publikujú v predátorských časopisoch obvykle neprinášajú 
        žiadny reálny vedecký pokrok a navyše, možno nechtiac, znevažujú prácu svojich kolegov."),
      p("Je otázne, či by v takom 
        prípade nebolo etickejšie a z celospoločenského hľadiska užitočnejšie nepublikovať vôbec, aj za cenu, že by tak 
        muselo zaniknúť niekoľko z už aj tak nadmerného počtu študijných programov či vysokoškolských pracovísk na Slovensku."
      )

    )
  ),
  
  fluidRow(
    column(10,offset=1,
      hr(),
      p("Túto prácu má na svedomí", strong("Samuel Hudec"), "doktorand z FPV UMB v Banskej Bystrici",align="right"
      ),
      p("doc. Radoslavovi Harmanovi z FMFI UK v Bratislave a dr. Lukášovi Lafférsovi z FPV UMB v Banskej Bystrici ďakuje za pripomienky.",style = "font-size: 90%;",align="right"
      ),
      br()
    )
  )
)


# Define server logic required to draw a plots ####
server <- function(input, output) {
  
  ## reactive subsets ####
  uni_subset<- reactive({
    if(input$radio == "cor"){
      if(input$select_VS == "Všetky"){
        pubsUNFcor
      }else{
        pubsUNFcor[str_detect(pubsUNFcor$VS_NAZOV,input$select_VS),]
      }
    }else{
      if(input$select_VS == "Všetky"){
        pubsUNF  
      }else{
        pubsUNF[str_detect(pubsUNF$VS_NAZOV,input$select_VS),]
      }
    }
  })

  ## Faculty plot #####
  output$UFPlot <- renderPlotly({
    
    # Final plot gg graphics 
    g <- ggplot(data=uni_subset(),aes(x=freq_miestny,y=freq_pr,col=FOS,
            text=paste(VS_F,"\n","\n",
              "Počet predátorskych publikácií:",preds,"\n",
              "Počet miestnych publikácií:",miestny,"\n",
              "Celkový počet publikácií:",sum))) + 
            theme_bw() + # štyl obrazka
            geom_point(alpha = (2/3),aes(size = Size)) + 
            labs(x="Podiel publikácií v miestnych časopisoch",y="Podiel publikácií v predátorských časopisoch") +
            guides(size=FALSE,col=guide_legend(title=NULL)) + 
            scale_size(range = c(1, 8)) +
            scale_color_manual(values=cols) +
            theme(axis.text.y = rotatedAxisElementText(90,"y")) + 
            scale_y_continuous(labels = scales::percent,  limits=c(0, 1), position="left") + 
            scale_x_continuous(labels = scales::percent, limits=c(0, 1))
    
    # render plotly
    ggplotly(g,tooltip="text") %>% 
      layout(legend = list(xanchor = "right", yanchor="top", x=0.95,y=0.95)) %>% 
      config(displaylogo = FALSE,collaborate = FALSE)
    })
   
  ## University plot ####
  output$UPlot <- renderPlotly({
    # Final plot gg graphics
    u <- ggplot(data=pubsUN,aes(x=freq_miestny,y=freq_pr,text=paste(VS_NAZOV,"\n","\n",
              "Počet predátorskych publikácií:",preds,"\n",
              "Počet miestnych publikácií:",miestny,"\n",
              "Celkový počet publikácií:",sum))) + 
            theme_bw() + # štyl obrazka
            geom_point(alpha = (2/3),aes(size = Size,col=Size)) + 
            labs(x="Podiel publikácií v miestnych časopisoch",y="Podiel publikácií v predátorských časopisoch") +
            guides(size=FALSE,colour = FALSE) + # nastavenie naplne legendy
            scale_size(range = c(1, 8)) +
            theme(axis.text.y = rotatedAxisElementText(90,"y")) + # rotacia
            scale_y_continuous(labels = scales::percent,  limits=c(0, 1), position="left") + # znasilnenie y osi
            scale_x_continuous(labels = scales::percent, limits=c(0, 1)) # znasilnenie x osi
    
    # render plotly
    ggplotly(u,tooltip="text") %>% config(displaylogo = FALSE,collaborate = FALSE)
    })
  
  
}








# Run the application 
shinyApp(ui = ui, server = server)

