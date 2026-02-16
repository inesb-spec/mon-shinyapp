# =====================================
# APPLICATION SHINY – POPULATION
# =====================================

pkgs <- c("ggplot2", "scales", "jsonlite", "WDI", "wbwdi", "stringr", "shiny","bslib","tidyr", "shinycssloaders")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, dependencies = TRUE)
r <- lapply(pkgs, library, character.only = TRUE)

source("model.R")

# -------------------------------------
# VUE (UI)
# -------------------------------------
ui <- fluidPage(
  
  theme = bs_theme(
    version = 5,
    bootswatch = "darkly",
    primary = "#2C7BE5",
    base_font = font_google("Inter")
  ),
  
  
  titlePanel("Analyse interactive de la population mondiale"),
  # Logo institution (haut droite) - ne remplace pas titlePanel
  tags$head(
    tags$style(HTML("
    .logo-institution {
      position: absolute;
      top: -10px;
      right: 24px;
      z-index: 2000;
      width: 76px;
      height: 76px;
      opacity: 0.95;
    }
    .logo-institution svg {
      width: 100%;
      height: 100%;
      display: block;
      filter: drop-shadow(0 1px 1px rgba(0,0,0,0.35));
    }
  "))
  ),
  
  tags$div(
    class = "logo-institution",
    # SVG : globe + courbe + silhouettes H/F (style sobre)
    tags$svg(
      xmlns = "http://www.w3.org/2000/svg",
      viewBox = "0 0 96 96",
      tags$title("Institut de Statistique – Population"),
      # Cercle globe
      tags$circle(cx="44", cy="48", r="26", fill="none", stroke="#E6EEF7", `stroke-width`="3"),
      # Méridiens / parallèles (sobres)
      tags$path(d="M18 48h52", fill="none", stroke="#E6EEF7", `stroke-width`="2", opacity="0.65"),
      tags$path(d="M44 22c-10 10-10 42 0 52", fill="none", stroke="#E6EEF7", `stroke-width`="2", opacity="0.65"),
      tags$path(d="M44 22c10 10 10 42 0 52", fill="none", stroke="#E6EEF7", `stroke-width`="2", opacity="0.65"),
      # Courbe démographique (sur le globe)
      tags$path(
        d="M22 58 C30 52, 36 54, 42 46 S56 34, 64 38",
        fill="none", stroke="#2C7BE5", `stroke-width`="3", `stroke-linecap`="round"
      ),
      # Petit point fin de courbe
      tags$circle(cx="64", cy="38", r="3", fill="#2C7BE5"),
      # Silhouettes (très minimalistes) à droite
      # Têtes
      tags$circle(cx="78", cy="40", r="5", fill="#E6EEF7"),
      tags$circle(cx="88", cy="42", r="4", fill="#E6EEF7", opacity="0.9"),
      # Corps
      tags$path(d="M73 62c1-10 9-10 10 0v8H73z", fill="#E6EEF7"),
      tags$path(d="M85 62c1-8 7-8 8 0v8h-8z", fill="#E6EEF7", opacity="0.9")
    )
  ),
  
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput(inputId="pays", label="Pays :", choices =setNames(pays$code, pays$nom), selected="FRA"),
      
      sliderInput(
        inputId = "annee",
        label = "Année (pyramide) :",
        min = anneeMin, # a determiner dans modele anneeMin dans WB
        max = anneeMax, # a determiner dans modele anneeMax
        value = anneeMax,
        sep = "",
        step = 1,
        ticks = FALSE
      ),
      
      sliderInput(
        inputId = "periode",
        label = "Période (évolution) :",
        min = anneeMin,
        max = anneeMax,
        value = c(anneeMin, anneeMax),
        sep = "",
        step = 1,
        ticks = FALSE
      )
    ),
    
    mainPanel(
      navset_pill(
        nav_panel("Pyramide", shinycssloaders::withSpinner(plotOutput("graphe_pyramide"))),
        nav_panel("Évolution", shinycssloaders::withSpinner(plotOutput("graphe_ts"))),
        nav_panel("Solde naturel", shinycssloaders::withSpinner(plotOutput("graphe_sn"))),
        nav_panel("Solde migratoire", shinycssloaders::withSpinner(plotOutput("graphe_sm"))),
        nav_panel(
          "Auteurs",
          h3("Projet R – Données démographiques"),
          p("Auteur : Inès BOUCHAFAA"),
          p(
            "Source : ",
            tags$a(
              "World Bank – Indicateur Population (15–64 ans)",
              href = "https://data.worldbank.org/indicator/SP.POP.1564.TO.ZS",
              target = "_blank"
            )
          )
          
        )
      )
    )
  )
)

# -------------------------------------
# CONTROLEUR (SERVER)
# -------------------------------------
server <- function(input, output) {
  
  output$graphe_pyramide <- renderPlot({
    pyramide(
      codep  = input$pays,
      annee = input$annee
    )
  })
  
  output$graphe_ts <- renderPlot({
     gpopulation_ts(
       codep  = input$pays,
       debut = input$periode[1],
       fin   = input$periode[2]
     )
  })
    
    output$graphe_sn <- renderPlot({
      g_solde_naturel(
      codep  = input$pays,
      debut = input$periode[1],
      fin   = input$periode[2]
    )
  })
    
    output$graphe_sm <- renderPlot({
      g_solde_migratoire(
        codep  = input$pays,
        debut  = input$periode[1],
        fin    = input$periode[2]
      )
    })
    
}



# -------------------------------------
# LANCEMENT
# -------------------------------------
shinyApp(ui, server)
