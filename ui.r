require(shiny)
require(leaflet)
require(RMySQL)
require(geosphere)
require(RODBC)


ui <- fluidPage(
  
  # Page title
  titlePanel("Cloud Computing WIB - Maps"),
  
  
  # Sidebar with controls
  sidebarLayout(sidebarPanel(numericInput("Start", label = "Start: ", min = 0, max = 1000, step = 1, value = 1
  ),numericInput("End", label = "End: ", min = 0, max = 1000, step = 1, value = 1)
  ,submitButton(text = "Apply Changes"))
  
  # Leaflet map
  , mainPanel( leafletOutput( outputId = 'myMap') )
  )
  
)