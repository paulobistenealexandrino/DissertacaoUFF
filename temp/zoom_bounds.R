# Gera os limites para o zoom de um mapa em determinado ponto

zoom_bounds <- function(zoom_to=c(-43.45023,-22.92333),zoom_level=9,coords){
  
  # Default zoom_to set to Rio de Janeiro
  # Default zoom_level set to 9
  
  if (coords == "lon") {
    
    lon_span <- 360 / 2^zoom_level
    lon_bounds <- c(zoom_to[1] - lon_span / 2, zoom_to[1] + lon_span / 2)
    
    return(lon_bounds)
    
  }
  
  if (coords == "lat") {
    
    lat_span <- 180 / 2^zoom_level
    lat_bounds <- c(zoom_to[2] - lat_span / 2, zoom_to[2] + lat_span / 2)
    
    return(lat_bounds)
    
  }
  
  if (!(coords %in% c("lon","lat"))) {
    
    return(print("Set longitude or latitude."))
    
  }

}