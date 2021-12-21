## Loading Libraries - required for the data visualization, data wrangling and data formmatting.

library(tidyverse)
library(reshape2)
library(scales)

setwd("F:/Coursera - Data/Case Studies/Data/Fitabase_Data/")




## Phase 2 : Data Preparation 

### Loading CSV files
daily_Activity <- read.csv("../Fitabase_Data/dailyActivity_merged.csv")
sleep_day <- read.csv("../Fitabase_Data/sleepDay_merged.csv")
dailyCalories <- read.csv("../Fitabase_Data/dailyCalories_merged.csv")
dailyIntensity <- read.csv("../Fitabase_Data/dailyIntensities_merged.csv")
dailySteps <- read.csv("../Fitabase_Data/dailySteps_merged.csv")
weightLogInfo <- read_csv("../Fitabase_Data/weightLogInfo_merged.csv")


## Data Merging

merge_daily_1 <- merge(dailyCalories, daily_Activity, by = c("Id", "Calories"))
merge_daily_2 <- merge(dailyIntensity, dailyIntensity, by = c("Id", "ActivityDay", "SedentaryMinutes", "LightlyActiveMinutes", "FairlyActiveMinutes", "VeryActiveMinutes", "SedentaryActiveDistance", "LightActiveDistance","ModeratelyActiveDistance","VeryActiveDistance"))

merge_daily <- merge(merge_daily_1, merge_daily_2, by = c("Id", "ActivityDay", "SedentaryMinutes", "LightlyActiveMinutes", "FairlyActiveMinutes", "VeryActiveMinutes", "SedentaryActiveDistance", "LightActiveDistance","ModeratelyActiveDistance","VeryActiveDistance")) %>% 
  select (-ActivityDay) %>% 
  rename(Date = ActivityDate)

daily_data <- merge(merge_daily, sleep_day, by = "Id", all = TRUE) %>% 
  drop_na() %>% 
  select(-SleepDay, -TrackerDistance)

options(repr.plot.width=15, repr.plot.height=8)



## Phase 3 & 4: Process and Analyse 
### Data cleaning and preparation for analysis

data_by_usertype <- daily_data %>% 
  summarise(
    user_type = factor(case_when(
      SedentaryMinutes > mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Sedentary", 
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes > mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Lightly Active",
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes > mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Fairly Active",
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes > mean(VeryActiveMinutes) ~ "Very Active",
    ), levels = c("Sedentary", "Lightly Active", "Fairly Active", "Very Active")), Calories,  .group = Id) %>% 
  drop_na()

write_csv(data_by_usertype,"../Fitabase_Data/data_by_usertype.csv")


### Data Visualization and Analysis
#### Calories Burned w.r.t., User Type 

data_by_usertype %>% 
  group_by(user_type) %>% 
  summarise(total = n()) %>% 
  mutate(totals = sum(total)) %>% 
  group_by(user_type) %>% 
  summarise(total_percent = total / totals) %>% 
  ggplot(aes(user_type, y = total_percent, fill = user_type)) + 
  geom_col()+
  scale_y_continuous(labels = scales::percent) + 
  theme(legend.position = "none") + 
  labs(title = "User type distribution", x =NULL) +
  theme(legend.position = "none", text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
ggsave("user_type_distribution.png", path = "../Img/")


ggplot(data_by_usertype, aes(user_type, Calories, fill = user_type)) + 
  geom_boxplot() + 
  theme(legend.position = "none") +
  labs(title = "Calories burned by User type", x = NULL) + 
  theme(legend.position = "none", text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
ggsave("Calories_burned.png", path = '../Img')



### Check how is TotalDistance/TotalSteps is related to Calories Burned

daily_data %>%
  summarise(
    distance = factor(case_when(
      TotalDistance < 4.5 ~ "< 4.5 mi",
      TotalDistance >= 4.5 & TotalDistance <= 7 ~ "4.5 > & < 7 mi",
      TotalDistance > 7 ~ "> 7 mi",
    ),levels = c("> 7 mi","4.5 > & < 7 mi","< 4.5 mi")),
    steps = factor(case_when(
      TotalSteps < 6000 ~ "< 6k steps",
      TotalSteps >= 6000 & TotalSteps <= 10000 ~ "6k > & < 10k Steps",
      TotalSteps > 10000 ~ "> 10k Steps",
    ),levels = c("> 10k Steps", "6k > & < 10k Steps", "< 6k steps")),
    Calories) %>%
  ggplot(aes(steps,Calories,fill=steps)) +
  geom_boxplot() +
  facet_wrap(~distance)+
  labs(title="Calories burned by Steps and Distance",x=NULL) +
  theme(legend.position = "none", axis.text.x = element_text(size = 10, angle = 45, hjust =1, face = 'bold'), plot.title = element_text(hjust = 0.5))
ggsave("calories_steps_distance.png", path = "../Img/", width = 12, height = 6)



### Sleeping patterns and quality of sleep

sleepType_by_userType <- daily_data %>%
  group_by(Id) %>%
  summarise(
    user_type = factor(case_when(
      SedentaryMinutes > mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Sedentary",
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes > mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Lightly Active",
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes > mean(FairlyActiveMinutes) & VeryActiveMinutes < mean(VeryActiveMinutes) ~ "Fairly Active",
      SedentaryMinutes < mean(SedentaryMinutes) & LightlyActiveMinutes < mean(LightlyActiveMinutes) & FairlyActiveMinutes < mean(FairlyActiveMinutes) & VeryActiveMinutes > mean(VeryActiveMinutes) ~ "Very Active",
    ),levels=c("Sedentary", "Lightly Active", "Fairly Active", "Very Active")),
    sleep_type = factor(case_when(
      mean(TotalMinutesAsleep) < 360 ~ "Bad Sleep",
      mean(TotalMinutesAsleep) > 360 & mean(TotalMinutesAsleep) <= 480 ~ "Normal Sleep",
      mean(TotalMinutesAsleep) > 480 ~ "Over Sleep",
    ),levels=c("Bad Sleep", "Normal Sleep", "Over Sleep")), total_sleep = sum(TotalMinutesAsleep) ,.groups="drop"
  ) %>%
  drop_na() %>%
  group_by(user_type) %>%
  summarise(bad_sleepers = sum(sleep_type == "Bad Sleep"), normal_sleepers = sum(sleep_type == "Normal Sleep"),over_sleepers = sum(sleep_type == "Over Sleep"),total=n(),.groups="drop") %>%
  group_by(user_type) %>%
  summarise(
    bad_sleepers = bad_sleepers / total, 
    normal_sleepers = normal_sleepers / total, 
    over_sleepers = over_sleepers / total,
    .groups="drop"
  )
write_csv(sleepType_by_userType ,"../Fitabase_Data/sleepType_By_Usertype.csv")



### Plotting the above findings

sleepType_by_userType_melted<- melt(sleepType_by_userType, id.vars = "user_type")
write_csv(sleepType_by_userType_melted ,"../Fitabase_Data/sleepType_By_Usertype_melted.csv")


ggplot(sleepType_by_userType_melted, aes(user_type, value, fill = variable)) +
  geom_bar(position = "dodge", stat = "identity") +
  scale_y_continuous(labels = scales::percent) +
  labs(x=NULL, fill="Sleep type") + 
  theme(legend.position="bottom",text = element_text(size = 15),plot.title = element_text(hjust = 0.5))
ggsave("sleepType.png", path = "../Img/", width = 10, height = 5)

