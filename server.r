library(shiny)
require(leaflet)
require(RMySQL)
require(geosphere)
require(RODBC)

shinyServer(function(input, output) {
  
  
  finalMap <- reactive ({
    conn <- odbcConnect(dsn = "cc_test")
    
    sql_statement = paste("EXEC usp_getShortestPath ",input$Start,", ",input$End,";",sep = "")
    queryResult <- sqlQuery(conn, sql_statement,errors = FALSE)
    odbcClose(conn)
    
    
    mydb = dbConnect(MySQL(), user='root', password='root', dbname='graphenesqlbase', host='localhost')
    
    rs = dbSendQuery(mydb, "select center_long, center_lat from thousandnodes LIMIT 1000")
    
    nodes = fetch(rs, n=-1)
    dbClearResult(rs)
    rs2 = dbSendQuery(mydb, "select fromcenter_long, fromcenter_lat, tocenter_long, tocenter_lat from edgestothousandnodes ORDER BY RAND() LIMIT 20")
    edges = fetch(rs2, n=-1)
    
    nodes$center_long <- as.numeric(nodes$center_long)
    nodes$center_lat <- as.numeric(nodes$center_lat)
    
    edges$fromcenter_long <- as.numeric(edges$fromcenter_long)
    edges$fromcenter_lat <- as.numeric(edges$fromcenter_lat)
    edges$tocenter_long <- as.numeric(edges$tocenter_long)
    edges$tocenter_lat <- as.numeric(edges$tocenter_lat)  
    
    a <- data.frame(edges$fromcenter_long,edges$fromcenter_lat)
    b <- data.frame(edges$tocenter_long,edges$tocenter_lat)

    leaflet() %>% setView(lng = 40,lat = 50, zoom = 3) %>% addTiles() %>% addCircleMarkers(lng = nodes$center_long, lat = nodes$center_lat,radius = 0.5,color = "red", fillOpacity = 0.5, popup = paste("Longitude: ",nodes$center_long,"<br />Latitude: ",nodes$center_lat,sep ="")) %>%  addPolylines(lat = queryResult$center_lat,lng = queryResult$center_long)
    
    
  })
  output$myMap = renderLeaflet(finalMap())
})
  
  
  
