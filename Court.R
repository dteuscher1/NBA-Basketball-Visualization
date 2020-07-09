library(ballr)
source("https://raw.githubusercontent.com/toddwschneider/ballr/master/plot_court.R")
source("https://raw.githubusercontent.com/toddwschneider/ballr/master/court_themes.R")
object <- plot_court()

court_points <- court_points %>%
    mutate(desc = factor(desc),
           x = x*10,
           y = y*10)

test.three <- court_points %>% filter(desc == "three_point_line")
test.perimeter <- court_points %>% filter(desc == "perimeter")
test.outer_key <- court_points %>% filter(desc == "outer_key")
test.backboard <- court_points %>% filter(desc == "backboard")
test.neck <- court_points %>% filter(desc == "neck")
test.hoop <- court_points %>% filter(desc == "hoop")
test.foul_circle <- court_points %>% filter(desc == "foul_circle_top")
test.restricted <- court_points %>% filter(desc == "restricted")

