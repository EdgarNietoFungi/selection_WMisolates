#library(gdata)
#library(ggmap)
#library(maps)
#library(mapdata)
#library(misc3d)
#library(ptinpoly)
#library(tidyverse)
library(ggplot2)
#library(ezec)
#library(NRES803)
#library(broom)
#library(dplyr)
#library(misc3d)
#library(ptinpoly)
library(tidyverse)
#library(ggplot2)
#library(ezec)
#library(broom)
#library(dplyr)
library(sp)
# Reading data#
WM <- read.csv("data/WM-2015-2016-2017_fixingproductnames.csv", stringsAsFactors = TRUE)
levels(WM$Origin )[levels(WM$Origin ) == "trial"] <- "Fungicide field trials"
levels(WM$Origin )[levels(WM$Origin ) == "Survey"] <- "Farmer fields"
levels(WM$DNA.Extraction )[levels(WM$DNA.Extraction ) == ""] <- "No DNA extraction"
levels(WM$DNA.Extraction )[levels(WM$DNA.Extraction ) == "No"] <- "No DNA extraction"
levels(WM$DNA.Extraction )[levels(WM$DNA.Extraction ) == "Yes"] <- "Yes DNA extraction"

WM$Year <- as.factor(WM$Year)
WM$Collection_ID <- as.numeric(WM$Collection_ID)  
WM$Collection_ID <- as.character(WM$Collection_ID)  

wm1 <-
  WM %>% select(
    Collection_ID,
    State,
    Field,
    Year,
    Origin,
    long,
    lat,
    hyphal_tip..ht.,
    DNA.Extraction,
    County,
    Serial_agar_dilution_for_creating_the_model_..N.20.,
    Form.ID
  )

#
tested <-
  c(
    "1",
    "118",
    "123",
    "12B",
    "129",
    "20",
    "21",
    "449",
    "461",
    "467",
    "475",
    "558",
    "564",
    "568",
    "581",
    "645",
    "800",
    "667",
    "74SS1",
    "8",
    "87",
    "318",
    "413",
    "419",
    "62-02",
    "62-03",
    "62-04",
    "78-01",
    "78-02",
    "78-05",
    "H-01",
    "H-03",
    "H-04",
    "I-20",
    "S-01",
    "W212",
    "1025",
    "1026",
    "1027",
    "1029",
    "1032",
    "1033",
    "1870",
    "1872",
    "1884",
    "1885",
    "54C",
    "65B",
    "51C",
    "71B",
    "64D",
    "53B",
    "60A",
    "698",
    "699",
    "710",
    "711",
    "724",
    "725",
    "731",
    "732",
    "738",
    "739",
    "746",
    "751",
    "755",
    "756",
    "757",
    "764",
    "765",
    "771",
    "772",
    "786",
    "787",
    "811",
    "812",
    "813",
    "814",
    "817",
    "818",
    "851",
    "852",
    "853",
    "855",
    "858",
    "859",
    "860",
    "861",
    "862",
    "867",
    "870",
    "871",
    "877",
    "878",
    "884",
    "885",
    "891",
    "892",
    "896",
    "897",
    "901",
    "902",
    "905",
    "906",
    "908",
    "909",
    "911",
    "912",
    "914",
    "274",
    "307",
    "504",
    "505",
    "2384",
    "2385",
    "2386",
    "2388",
    "2407",
    "2408",
    "2383",
    "1058",
    "1081",
    "1087",
    "1109",
    "1127",
    "1128",
    "1134",
    "1135",
    "1139",
    "1175",
    "1026",
    "1027",
    "1029",
    "1328",
    "1329",
    "1330",
    "1331",
    "1332",
    "1340",
    "1345",
    "1365",
    "1366",
    "1392",
    "1327",
    "1502",
    "1582",
    "1620",
    "1622",
    "1541",
    "1671",
    "1672",
    "1691",
    "1692",
    "1712",
    "1713",
    "1721",
    "1722",
    "1731",
    "1732",
    "1791",
    "1",
    "118",
    "123",
    "20",
    "74SS1",
    "8",
    "419",
    "78-02",
    "H-01",
    "H-03"
  )
mexican_isolates <- c("1857":"1940")

wm1_ <-  wm1 %>%
  mutate(Fungicide_status = ifelse(Collection_ID  %in% tested,
                                   "tested", "no_tested")) %>%
  filter(!Collection_ID %in% mexican_isolates) %>%
  group_by(Field) %>% mutate (num_isolates_per_field = ifelse(n() > 2, "2>isolates/Field", "<2isolates/Field")) %>% ungroup()

wm1_$num_isolates_per_field <- as.factor(wm1_$num_isolates_per_field)

wm1_ <- wm1_[-970, ]
wm1_$long <- as.numeric(as.character(wm1_$long))
wm1_$long <- (wm1_$long) * -1

#
usa <- map_data("usa")
states <- map_data("state")
counties <- map_data("county")
mid_west_county <-
  subset(
    counties,
    region == "nebraska" |
      region == "wisconsin" | region == "michigan" | region == "iowa"
  )
bra <- map_data("worldHires", "Brazil")
mexico <- map_data("worldHires", "Mexico")
#
mid_west_base <-
  ggplot(data = mid_west_county,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey")
#
mexico_base <-
  ggplot(data = mexico,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey")


selection <-
  wm1_ %>% select(
    Collection_ID,
    State,
    County,
    Field,
    Year,
    Origin,
    long,
    lat,
    hyphal_tip..ht.,
    DNA.Extraction,
    Serial_agar_dilution_for_creating_the_model_..N.20.,
    Form.ID,
    Fungicide_status,
    num_isolates_per_field
  ) %>% arrange(factor (State, levels = c("NE", "IA", "WI", "MI"))) %>%
  group_by(State, County, Field) %>%
  mutate(num_ISO_per_field = n()) %>%
  ungroup %>%
  group_by(State, County) %>%
  mutate(num_field_County = length(unique(factor(Field)))) %>%
  select(
    Collection_ID,
    State,
    County,
    Field,
    num_ISO_per_field,
    num_field_County,
    Year,
    Origin,
    long,
    lat,
    hyphal_tip..ht.,
    DNA.Extraction,
    Serial_agar_dilution_for_creating_the_model_..N.20.,
    Form.ID,
    Fungicide_status,
    num_isolates_per_field
  )

selection1 <- selection %>%
  ungroup() %>%
  group_by(State, County, Field) %>%
  filter(num_ISO_per_field > 10,
         Fungicide_status == "no_tested") %>%
  sample_n(3, replace = F)
##
selection2 <- selection %>%
  ungroup() %>%
  group_by(State, County, Field) %>%
  filter(!num_ISO_per_field %in% selection1$num_ISO_per_field) %>%
  filter(Fungicide_status == "no_tested") %>%
  ungroup()
#
fields1 <- selection2 %>%
  filter(State == "NE", County == "Valley", Field == "va")
a <- sample(fields1$Collection_ID, size = 3, replace = FALSE)

fields2 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "ant")
b <- sample(fields2$Collection_ID, size = 3, replace = FALSE)

fields3 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "21")
c <- sample(fields3$Collection_ID, size = 3, replace = FALSE)

fields4 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "22")
d <- sample(fields4$Collection_ID, size = 3, replace = FALSE)

fields5 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "23")
e <- sample(fields5$Collection_ID, size = 3, replace = FALSE)

fields6 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "24")
f <- sample(fields6$Collection_ID, size = 3, replace = FALSE)

fields7 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "25")
g <- sample(fields7$Collection_ID, size = 3, replace = FALSE)

fields8 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "69")
h <- sample(fields8$Collection_ID, size = 3, replace = FALSE)

fields9 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "75")
i <- sample(fields9$Collection_ID, size = 3, replace = FALSE)

fields10 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "102")
j <- sample(fields10$Collection_ID, size = 3, replace = FALSE)

fields11 <- selection2 %>%
  filter(State == "NE", County == "Antelope", Field == "103")
k <- sample(fields11$Collection_ID, size = 3, replace = FALSE)

fields12 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "6")
l <- sample(fields12$Collection_ID, size = 3, replace = FALSE)

fields13 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "67")
m <- sample(fields13$Collection_ID, size = 3, replace = FALSE)

fields14 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "78")
n <- sample(fields14$Collection_ID, size = 3, replace = FALSE)

fields15 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "98")
o <- sample(fields15$Collection_ID, size = 3, replace = FALSE)

fields16 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "100")
p <- sample(fields16$Collection_ID, size = 3, replace = FALSE)

fields17 <- selection2 %>%
  filter(State == "NE", County == "Cedar", Field == "101")
q <- sample(fields17$Collection_ID, size = 3, replace = FALSE)

fields18 <- selection2 %>%
  filter(State == "NE", County == "Greeley", Field == "8")
r <- sample(fields18$Collection_ID, size = 3, replace = FALSE)

fields19 <- selection2 %>%
  filter(State == "NE", County == "Greeley", Field == "9")
s <- sample(fields19$Collection_ID, size = 3, replace = FALSE)

fields20 <- selection2 %>%
  filter(State == "NE", County == "Greeley", Field == "68")
t <- sample(fields20$Collection_ID, size = 3, replace = FALSE)

fields21 <- selection2 %>%
  filter(State == "NE", County == "Madison", Field == "10")
u <- sample(fields21$Collection_ID, size = 3, replace = FALSE)

fields22 <- selection2 %>%
  filter(State == "NE", County == "Madison", Field == "11")
v <- sample(fields22$Collection_ID, size = 3, replace = FALSE)

fields23 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "18")
w <- sample(fields23$Collection_ID, size = 3, replace = FALSE)

fields24 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "19")
x <- sample(fields24$Collection_ID, size = 3, replace = FALSE)

fields25 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "20")
y <- sample(fields25$Collection_ID, size = 3, replace = FALSE)

fields26 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "45")
z <- sample(fields26$Collection_ID, size = 3, replace = FALSE)

fields27 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "46")
aa <- sample(fields27$Collection_ID, size = 3, replace = FALSE)

fields28 <- selection2 %>%
  filter(State == "NE", County == "Boone", Field == "48")
bb <- sample(fields28$Collection_ID, size = 3, replace = FALSE)

fields29 <- selection2 %>%
  filter(State == "NE", County == "Dodge", Field == "34")
cc <- sample(fields29$Collection_ID, size = 3, replace = FALSE)

fields30 <- selection2 %>%
  filter(State == "NE", County == "Dodge", Field == "35")
dd <- sample(fields30$Collection_ID, size = 3, replace = FALSE)

fields31 <- selection2 %>%
  filter(State == "NE", County == "Holt", Field == "47")
ee <- sample(fields31$Collection_ID, size = 3, replace = FALSE)

fields32 <- selection2 %>%
  filter(State == "NE", County == "Sherman", Field == "60")
ff <- sample(fields32$Collection_ID, size = 3, replace = FALSE)


fields33 <- selection2 %>%
  filter(State == "NE", County == "Kearney", Field == "62")
gg <- sample(fields33$Collection_ID, size = 3, replace = FALSE)

fields34 <- selection2 %>%
  filter(State == "NE", County == "Kearney", Field == "104")
hh <- sample(fields34$Collection_ID, size = 3, replace = FALSE)

fields35 <- selection2 %>%
  filter(State == "NE", County == "Kearney", Field == "10")
ii <- sample(fields35$Collection_ID, size = 3, replace = FALSE)

fields36 <- selection2 %>%
  filter(State == "NE", County == "Cuming", Field == "66")
jj <- sample(fields36$Collection_ID, size = 3, replace = FALSE)

fields37 <- selection2 %>%
  filter(State == "NE", County == "Pierce", Field == "97")
kk- sample(fields37$Collection_ID, size = 3, replace = FALSE)

fields38 <- selection2 %>%
  filter(State == "NE", County == "Knox", Field == "99")
ll <- sample(fields38$Collection_ID, size = 3, replace = FALSE)

fields39 <- selection2 %>%
  filter(State == "IA", County == "Howard", Field == "howard")
mm <- sample(fields39$Collection_ID, size = 3, replace = FALSE)

fields40 <- selection2 %>%
  filter(State == "IA", County == "Chickasaw", Field == "chi")
nn <- sample(fields40$Collection_ID, size = 3, replace = FALSE)

fields41 <- selection2 %>%
  filter(State == "IA", County == "Floyd", Field == "floyd")
oo <- sample(fields41$Collection_ID, size = 3, replace = FALSE)

fields42 <- selection2 %>%
  filter(State == "IA", County == "Story", Field == "sto")
pp <- sample(fields42$Collection_ID, size = 3, replace = FALSE)

fields43 <- selection2 %>%
  filter(State == "IA", County == "Shelby", Field == "sh")
qq <- sample(fields43$Collection_ID, size = 3, replace = FALSE)


fields44 <- selection2 %>%
  filter(State == "IA", County == "Benton", Field == "be")
rr <- sample(fields44$Collection_ID, size = 3, replace = FALSE)

fields45 <- selection2 %>%
  filter(State == "IA", County == "Tama", Field == "ta")
ss <- sample(fields45$Collection_ID, size = 3, replace = FALSE)

fields46 <- selection2 %>%
  filter(State == "WI", County == "Sauk City", Field == "sa")
tt <- sample(fields46$Collection_ID, size = 3, replace = FALSE)

fields47 <- selection2 %>%
  filter(State == "WI", County == "Cuba City", Field == "cu")
uu <- sample(fields47$Collection_ID, size = 3, replace = FALSE)

fields48 <- selection2 %>%
  filter(State == "WI", County == "Waushara", Field == "wau")
vv <- sample(fields48$Collection_ID, size = 3, replace = FALSE)

fields49 <- selection2 %>%
  filter(State == "WI", County == "Grant", Field == "la")
ww <- sample(fields49$Collection_ID, size = 3, replace = FALSE)

fields50 <- selection2 %>%
  filter(State == "WI", County == "Iowa", Field == "co")
xx <- sample(fields50$Collection_ID, size = 3, replace = FALSE)

fields51 <- selection2 %>%
  filter(State == "WI", County == "Rock", Field == "cern")
yy <- sample(fields51$Collection_ID, size = 3, replace = FALSE)

fields52 <- selection2 %>%
  filter(State == "WI", County == "Rock", Field == "cer")
zz <- sample(fields52$Collection_ID, size = 3, replace = FALSE)

fields53 <- selection2 %>%
  filter(State == "MI", County == "Allegan", Field == "Al")
aaa <- sample(fields53$Collection_ID, size = 3, replace = FALSE)

##
selection <- selection %>%
  mutate(
    Selected = case_when(
      Collection_ID %in% selection1$Collection_ID ~ "selected",
      Collection_ID %in% a ~ "selected",
      Collection_ID %in% b ~ "selected",
      Collection_ID %in% c ~ "selected",
      Collection_ID %in% d ~ "selected",
      Collection_ID %in% e ~ "selected",
      Collection_ID %in% f ~ "selected",
      Collection_ID %in% g ~ "selected",
      Collection_ID %in% h ~ "selected",
      Collection_ID %in% i ~ "selected",
      Collection_ID %in% l ~ "selected",
      Collection_ID %in% m ~ "selected",
      Collection_ID %in% n ~ "selected",
      Collection_ID %in% o ~ "selected",
      Collection_ID %in% p ~ "selected",
      Collection_ID %in% q ~ "selected",
      Collection_ID %in% r ~ "selected",
      Collection_ID %in% s ~ "selected",
      Collection_ID %in% u ~ "selected",
      Collection_ID %in% v ~ "selected",
      Collection_ID %in% ww ~ "selected",
      Collection_ID %in% x ~ "selected",
      Collection_ID %in% y ~ "selected",
      Collection_ID %in% z ~ "selected",
      Collection_ID %in% aa ~ "selected",
      Collection_ID %in% bb ~ "selected",
      Collection_ID %in% cc ~ "selected",
      Collection_ID %in% dd ~ "selected",
      Collection_ID %in% ee ~ "selected",
      Collection_ID %in% ff ~ "selected",
      Collection_ID %in% gg ~ "selected",
      Collection_ID %in% ii ~ "selected",
      Collection_ID %in% ll ~ "selected",
      Collection_ID %in% pp ~ "selected",
      Collection_ID %in% rr ~ "selected",
      Collection_ID %in% ss ~ "selected",
      Collection_ID %in% tt ~ "selected",
      Collection_ID %in% uu ~ "selected",
      Collection_ID %in% vv ~ "selected",
      Collection_ID %in% ww ~ "selected",
      Collection_ID %in% zz ~ "selected",
      Collection_ID %in% aaa ~ "selected",
      TRUE ~ "not_selected"
    )
  )  
  
#
base <-
  mid_west_base + geom_point(
    data = wm1_,
    aes(x = long, y = lat, color = Origin),
    inherit.aes = FALSE,
    size = 1,
    na.rm = TRUE,
    shape = 22,
    stroke = 0.5,
    fill = "white"
  ) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Midwest") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
base

#
WMfarmerfields <- wm1_ %>%
  group_by(State, Year, Origin) %>%
  filter(Origin == "Farmer fields")


base2 <-
  mid_west_base + geom_point(
    data = WMfarmerfields,
    aes(x = long, y = lat, color = Year),
    inherit.aes = FALSE,
    size = 1,
    na.rm = TRUE,
    shape = 22,
    stroke = 0.5,
    fill = "white"
  ) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum of Farmer Field Soybean from Midwest") + theme(plot.title = element_text(  size = 10,
  face = "bold",
  hjust = 0.5,
  family = "Helvetica"
))
base2
##
#fungicide field trials
WMfungicide <- wm1_ %>%
  group_by(State, Year, Origin) %>%
  filter(Origin == "Fungicide field trials")

base3 <-
  mid_west_base + geom_point(
    data = WMfungicide,
    aes(x = long, y = lat, color = Year),
    inherit.aes = FALSE,
    size = 1,
    na.rm = TRUE,
    shape = 22,
    stroke = 0.5,
    fill = "white"
  ) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum of Fungicide Field Trials Soybean from Midwest") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
base3

### NE#
WM1S <- selection %>%
  group_by(State, Origin) %>%
  filter(Origin == "Farmer fields", State == "NE") %>%
  ungroup()

WM1S$DNA.Extraction = factor(WM1S$DNA.Extraction ,
                             levels = c("No DNA extraction", "Yes DNA extraction"))
NE_county <- subset(counties, region == "nebraska")
NE_county_base <-
  ggplot(data = NE_county,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey")

face <- NE_county_base + geom_point(
  data = WM1S,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Nebraska 'No fungicide tested'") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
face

# As we can noticed for DNA extraction here it's been  for the furthest places
# closer sigth by counties#
NE_counties <-
  counties %>% group_by(region) %>% filter(region == "nebraska") %>% ungroup %>% filter(
    subregion == "antelope" |
      subregion == "madison" |
      subregion == "cedar" |
      subregion == "cuming" |
      subregion == "dodge" |
      subregion == "boone" |
      subregion == "holt" |
      subregion == "valley" |
      subregion == "greeley" |
      subregion == "sherman" |
      subregion == "howard"
  )

centroid <-
  aggregate(data = NE_counties, cbind(long, lat) ~ subregion, FUN = mean)

NE_counties_base <-  ggplot(data = NE_counties,
                            mapping = aes(x = long, y = lat, group = subregion)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey") +  geom_text(
    data = centroid,
    aes(label = subregion, x = long, y = lat),
    check_overlap = TRUE,
    size = 3
  )

hand <- NE_counties_base + geom_point(
  data = WM1S,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Nebraska 'No fungicide tested'") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
hand

#IOWA#
WM_IA <- selection %>%
  filter(State == "IA")

WM_IA$Status = factor(WM_IA$Fungicide_status , levels = c("tested", "no_tested"))

IA_county <- subset(counties, region == "iowa")
IA_county_base <-
  ggplot(data = IA_county,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "white")


eye <- IA_county_base  + geom_point(
  data = WM_IA,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Iowa") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
eye


# As we can noticed for DNA extraction here it's been  for the furthest places
# closer sigth by counties#


IA_counties <-
  counties %>% group_by(region) %>% filter(region == "iowa") %>% ungroup %>% filter(
    subregion == "floyd" |
      subregion == "butler" |
      subregion == "chickasaw" |
      subregion == "shelby" |
      subregion == "boone" |
      subregion == "polk" |
      subregion == "bremer" | subregion == "benton" | subregion == "tama"
  )
centroid_iowa <-
  aggregate(data = IA_counties, cbind(long, lat) ~ subregion, FUN = mean)

IA_counties_base <-  ggplot(data = IA_counties,
                            mapping = aes(x = long, y = lat, group = subregion)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey") +  geom_text(
    data = centroid_iowa,
    aes(label = subregion, x = long, y = lat),
    check_overlap = TRUE,
    size = 3
  )


pinky <- IA_counties_base + geom_point(
  data = WM_IA,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Nebraska 'No fungicide tested'") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
pinky
    ### WISCONSIN
WM_WI <- selection %>%
  filter(State == "WI")

WM_WI$Status = factor(WM_WI$Fungicide_status , levels = c("tested", "no_tested"))

WM_WIcounty <- subset(counties, region == "wisconsin")
WI_county_base <-
  ggplot(data = WM_WIcounty,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "white")

nose <- WI_county_base  + geom_point(
  data = WM_WI,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Iowa") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
nose

# As we can noticed for DNA extraction here it's been  for the furthest places
# closer sigth by counties#
WI_counties <-
  counties %>% group_by(region) %>% filter(region == "wisconsin") %>% ungroup %>% filter(
    subregion == "walworth" |
      subregion == "grant" |
      subregion == "lafayette" |
      subregion == "waushara" | subregion == "adams" | subregion == "dane"
  )
centroid_wisconsin <-
  aggregate(data = WI_counties, cbind(long, lat) ~ subregion, FUN = mean)

WI_counties_base <-  ggplot(data = WI_counties,
                            mapping = aes(x = long, y = lat, group = subregion)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey") +  geom_text(
    data = centroid_wisconsin,
    aes(label = subregion, x = long, y = lat),
    check_overlap = TRUE,
    size = 3
  )

middlefinger <- WI_counties_base + geom_point(
  data = WM_WI,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Nebraska 'No fungicide tested'") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
middlefinger
#Michigan#
WM_MI <- selection %>%
  filter(State == "MI")
WM_MI$Status = factor(WM_MI$Fungicide_status , levels = c("tested", "no_tested"))

WM_MIcounty <- subset(counties, region == "michigan")
WM_county_base <-
  ggplot(data = WM_MIcounty,
         mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "white")

mouth <- WM_county_base  + geom_point(
  data = WM_MI,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Iowa") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
mouth

# As we can noticed for DNA extraction here it's been  for the furthest places
# closer sigth by counties#

MI_counties <-
  counties %>% group_by(region) %>% filter(region == "michigan") %>% ungroup %>% filter(
    subregion == "montcalm" |
      subregion == "ingham" |
      subregion == "allegan" |
      subregion == "ionia" |
      subregion == "joseph" | subregion == "hillsdale" |
      subregion == "sanilac"
  )

centroid_michigan <-
  aggregate(data = MI_counties, cbind(long, lat) ~ subregion, FUN = mean)

MI_counties_base <-  ggplot(data = MI_counties,
                            mapping = aes(x = long, y = lat, group = subregion)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = "grey") +  geom_text(
    data = centroid_michigan,
    aes(label = subregion, x = long, y = lat),
    check_overlap = TRUE,
    size = 3
  )

anularfinger <- MI_counties_base  + geom_point(
  data = WM_MI,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year,
    size = DNA.Extraction
  ),
  inherit.aes = FALSE,
  na.rm = TRUE
) + theme(legend.position = "bottom") + facet_wrap( ~ num_isolates_per_field) +
  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Soybean inventory from Nebraska 'No fungicide tested'") + theme(plot.title = element_text(
    size = 10,
    face = "bold",
    hjust = 0.5,
    family = "Helvetica"
  ))
anularfinger

#Mexico#
wm2_ <-  wm1 %>%
  mutate(Fungicide_status = ifelse(Collection_ID  %in% tested,
                                   "tested", "no_tested")) %>%
  group_by(Field) %>% mutate (num_isolates_per_field = ifelse(n() > 2, "2>isolates/Field", "<2isolates/Field")) %>%
  ungroup() %>%
  filter(Collection_ID  %in% mexican_isolates)

wm2_$num_isolates_per_field <-
  as.factor(wm2_$num_isolates_per_field)


wm2_$long <- as.numeric(as.character(wm2_$long))
wm2_$long <- (wm2_$long) * -1

selection_Mexico <-
  wm2_ %>% select(
    Collection_ID,
    State,
    County,
    Field,
    Year,
    Origin,
    long,
    lat,
    hyphal_tip..ht.,
    DNA.Extraction,
    Serial_agar_dilution_for_creating_the_model_..N.20.,
    Form.ID,
    Fungicide_status,
    num_isolates_per_field
  ) %>%
  group_by(State, County, Field) %>%
  mutate(num_ISO_per_field = n()) %>%
  ungroup %>%
  group_by(County) %>%
  mutate(num_field_County = length(unique(factor(Field)))) %>%
  select(
    Collection_ID,
    State,
    County,
    Field,
    num_ISO_per_field,
    num_field_County,
    Year,
    Origin,
    long,
    lat,
    hyphal_tip..ht.,
    DNA.Extraction,
    Serial_agar_dilution_for_creating_the_model_..N.20.,
    Form.ID,
    Fungicide_status,
    num_isolates_per_field
  )

selection_Mexico1 <- selection_Mexico %>%
  ungroup() %>%
  group_by(State, County, Field) %>%
  filter(num_ISO_per_field > 10,
         Fungicide_status == "no_tested") %>%
  sample_n(3, replace = F)

selection_Mexico2 <- selection_Mexico %>%
  ungroup() %>%
  group_by(State, County, Field) %>%
  filter(!num_ISO_per_field %in% selection_Mexico1$num_ISO_per_field) %>%
  filter(Fungicide_status == "no_tested") %>% #,
  ungroup()

bbb <-
  sample(selection_Mexico2$Collection_ID,
         size = 3,
         replace = FALSE)

selection_Mexico <- selection_Mexico %>%
  mutate(
    Selected = case_when(
      Collection_ID %in% selection_Mexico1$Collection_ID ~ "selected",
      Collection_ID %in% bbb ~ "selected",
      TRUE ~ "not_selected"
    )
  )


eyebrow <- mexico_base + geom_point(
  data = selection_Mexico,
  aes(
    x = long,
    y = lat,
    color = Selected,
    shape = Year
  ),
  inherit.aes = FALSE,
  na.rm = TRUE,
  size = 3
) + theme(legend.position = "bottom") + facet_wrap(~ Fungicide_status) +  scale_color_manual(values = c("red", "blue")) + theme(legend.position = "bottom") + labs(title = "Sclerotinia sclerotiorum Greenbean inventory from Mexico") + theme(plot.title = element_text(
  size = 10,
  face = "bold",
  hjust = 0.5,
  family = "Helvetica"
))
eyebrow


##Dataframe of selection of objective 1

##Summarizing selected by Widwest
# selection3 <-
#   selection %>% filter(Selected == "selected") %>% 
#  #Collection_ID== "2344" & Collection_ID== "2403") %>%
#     ungroup()


selection3 <-
  selection %>% filter(Selected == "selected" |
                         Collection_ID == "2344" | Collection_ID == "2403") %>%  ungroup()
 
selection3$Selected[selection3$Collection_ID == "2344"] <- "selected"
selection3$Selected[selection3$Collection_ID == "2403"] <- "selected"

##Summarizing selected by Mexico 
selection_Mexico3 <-
  selection_Mexico %>% filter(Selected == "selected") %>% ungroup()


# Combining both
selection_FINAL_objective1 <-
  selection3 %>% bind_rows(selection_Mexico3) %>% 
  filter(Fungicide_status == "no_tested")#and also by no fungicide pre-tested

###
library(rgdal)
library(leaflet)
library(toolmaps)


# Creo una columna nueva con datos random ##################################
mexico@data$random <- 1:nrow(mexico@data)
mexico@data$random <- sample(1000000, size = nrow(mexico@data), replace = TRUE)
############################################################################


pal <- colorQuantile("YlGn", NULL, n = 5)

state_popup <- paste0("<strong>Estado: </strong>", 
                      mexico$name, 
                      "<br><strong>Valores random para cada estado: </strong>", 
                      mexico$random)

leaflet(data = mexico) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(fillColor = ~pal(random), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1, 
              popup = state_popup)




















