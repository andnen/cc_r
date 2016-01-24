  require("ggmap")
  require(RMySQL)
  require(geosphere)
  
  mydb = dbConnect(MySQL(), user='root', password='root', dbname='graphenesqlbase', host='localhost')
  
  rs = dbSendQuery(mydb, "select center_long, center_lat from thousandnodes LIMIT 1000")
  
  nodes = fetch(rs, n=-1)
  dbClearResult(rs)
  rs2 = dbSendQuery(mydb, "select fromcenter_long, fromcenter_lat, tocenter_long, tocenter_lat from edgestothousandnodes ORDER BY RAND() LIMIT 30")
  edges = fetch(rs2, n=-1)
  
  nodes$center_long <- as.numeric(nodes$center_long)
  nodes$center_lat <- as.numeric(nodes$center_lat)
  
  edges$fromcenter_long <- as.numeric(edges$fromcenter_long)
  edges$fromcenter_lat <- as.numeric(edges$fromcenter_lat)
  edges$tocenter_long <- as.numeric(edges$tocenter_long)
  edges$tocenter_lat <- as.numeric(edges$tocenter_lat)  
  
  a <- data.frame(edges$fromcenter_long,edges$fromcenter_lat)
  b <- data.frame(edges$tocenter_long,edges$tocenter_lat)
  
  rts <- gcIntermediate(a,
                        b,
                        50,
                        breakAtDateLine = FALSE,
                        addStartEnd = TRUE,
                        sp = TRUE)
  rts <- as(rts, "SpatialLinesDataFrame")
  rts.df <- fortify(rts)
  
  map <- get_map(location = 'Europe', zoom = 4, maptype = "roadmap", crop = FALSE)
  
  ggmap(map) +
    geom_point(data = nodes,stat = "identity" ,aes(x = center_long, y = center_lat), color="red", size = 1, alpha = 0.5) +
     geom_path(data = rts.df, aes(x = long, y = lat, group = group), 
            col = "black")