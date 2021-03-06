#Basic Possession Formula=0.96*[(Field Goal Attempts)+(Turnovers)+0.44*(Free Throw Attempts)-(Offensive Rebounds)]

library(dplyr)
library(ggplot2)
library(reshape2)

dt = read.csv("../Data/team_sums_norm.csv", stringsAsFactors = F)

f = dt %>%
  filter(Year >= 1978) %>%
  select(c("Year", "Tm", "FGA", "TOV", "FTA", "ORB", "PTS"))
f$possession = 0.96 * (f$FGA + f$TOV + 0.44*f$FTA - f$ORB)

f_year = f %>%
  group_by(Year) %>%
  summarise(FGA = sum(FGA),
            TOV = sum(TOV),
            FTA = sum(FTA),
            ORB = sum(ORB),
            PTS = sum(PTS),
            n = n())
f_year$possession = 0.96 * (f_year$FGA + f_year$TOV + 0.44*f_year$FTA - f_year$ORB)
f_year$possession = f_year$possession / f_year$n
f_year$points = f_year$PTS/f_year$n

f_max = f %>%
  group_by(Year) %>%
  summarise(poss = max(possession))

f_min = f %>%
  group_by(Year) %>%
  summarise(poss = min(possession))

new_df = data.frame(mean = f_year$possession,
                    max = f_max$poss,
                    min = f_min$poss,
                    points = f_year$points,
                    year = f_year$Year)

skinny = f %>%
  select(c("Year", "Tm", "possession"))

new_df <- merge(new_df, skinny,
               by.x=c("year", "max"),
               by.y=c("Year", "possession"))
names(new_df)[6] = 'team_max'

new_df <- merge(new_df, skinny,
                by.x=c("year", "min"),
                by.y=c("Year", "possession"))
names(new_df)[7] = 'team_min'

new_df["date"] = as.Date((paste(new_df$year,'01','01', sep = "-")))
new_df$mean = round(new_df$mean, 2)
new_df$max = round(new_df$max, 2)
new_df$min = round(new_df$min, 2)

empty_row = strsplit(",,,,,,,1977-01-01", ",")[[1]]
new_df = rbind(empty_row, new_df)
write.csv(new_df,  "possessions.csv", row.names = F)

# df.m = melt(new_df, id.vars ="year", measure.vars = c("mean",
#                                                       "max",
#                                                       "min"))
# ggplot(df.m, aes(year, value, color = variable)) + geom_point()
# 
# df.m2 = melt(new_df, id.vars ="year", measure.vars = c("mean",
#                                                       "points"))
# df.m2$variable = as.character(df.m2$variable)
# df.m2[df.m2$variable=='mean', "variable"] = "possessions"
# ggplot(df.m2, aes(year, value, color = variable)) + geom_point()
