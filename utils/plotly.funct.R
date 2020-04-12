f <- list(
  size = 15,
  color = "black"
)


plotly.vline <- function(x = 0, y = 0, color = "red") {
  list(
    type = "line", 
    y0 = 0, 
    y1 = y, 
    yref = "paper",
    x0 = x, 
    x1 = x, 
    line = list(color = color)
  )
}

plotly.vtext <- function(x = 40, y = y) {
  list(
    showarrow = FALSE,
    font = f,
    x = x,
    y = y,
    text = paste("Average age:", x),
    xref = "x",
    yref = "y",
    textangle = -90,
    ax = -10,
    ay =  5,
    xanchor = "right"
  )
}
# 
# plotly.vtext_med <- function(x = 40, y = y) {
#   list(
#     showarrow = FALSE,
#     font = f,
#     x = x,
#     y = y,
#     text = paste("Median:", x),
#     xref = "x",
#     yref = "y",
#     textangle = -90,
#     ax = +10,
#     ay =  5,
#     xanchor = "right"
#   )
# }