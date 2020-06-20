library(ggplot2)
library(dplyr)

load("titanic.raw.rdata")

attach(titanic.raw)

nRows = nrow(titanic.raw)

# cálculo de soportes de ítems
survived_summary = 
  titanic.raw %>% 
  group_by(Survived) %>%
  summarize(support=n() / nRows,
            support_count=n())

age_summary = 
  titanic.raw %>% 
  group_by(Age) %>%
  summarize(support=n() / nRows,
            support_count=n())

sex_summary = 
  titanic.raw %>% 
  group_by(Sex) %>%
  summarize(support=n() / nRows,
            support_count=n())

class_summary = 
  titanic.raw %>% 
  group_by(Class) %>%
  summarize(support=n() / nRows,
            support_count=n())

# Visualizaciones
ggplot(data=survived_summary, aes(x=Survived, y=support, fill=Survived)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=age_summary, aes(x=Age, y=support, fill=Age)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=sex_summary, aes(x=Sex, y=support, fill=Sex)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=class_summary, aes(x=Class, y=support, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

# Reglas de tamaño 2

# Class -> Sex
gender_class_summary = 
  titanic.raw %>% 
  group_by(Class, Sex)%>%
  summarize(support=n() / nRows,
            support_count=n()) %>% 
  inner_join(class_summary, by="Class", suffix=c("","_class")) %>%
  mutate(confidence=support/support_class,
         label=paste0("{",Class,"}->{",Sex,"}"))
gender_class_summary


ggplot(data=gender_class_summary, aes(x=label, y=support, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=gender_class_summary, aes(x=label, y=confidence, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()


# Class -> Survived
survived_class_summary = 
  titanic.raw %>% 
  group_by(Class, Survived)%>%
  summarize(support=n() / nRows,
            support_count=n()) %>% 
  inner_join(class_summary, by="Class", suffix=c("","_class")) %>%
  mutate(confidence=support/support_class,
         label=paste0("{Class=",Class,"}->{Survived=",Survived,"}"))
survived_class_summary


ggplot(data=survived_class_summary, aes(x=label, y=support, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=survived_class_summary, aes(x=label, y=confidence, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

# Reglas de tamaño 3

# Class & Sex -> Survived
survived_class_gender_summary = 
  titanic.raw %>% 
  group_by(Class, Sex, Survived)%>%
  summarize(support=n() / nRows,
            support_count=n()) %>% 
  inner_join(
    gender_class_summary %>% select("Class","Sex", "support"),
    by=c("Class","Sex"), suffix=c("","_lhs")
  ) %>%
  mutate(confidence=support/support_lhs,
         lhs=paste0("{Class=",Class," & Sex=",Sex,"}"),
         label=paste0("{Class=",Class," & Sex=",Sex,"}->{Survived=",Survived,"}"))
survived_class_gender_summary


ggplot(data=survived_class_gender_summary, aes(x=label, y=support, fill=Class)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()

ggplot(data=survived_class_gender_summary, aes(x=lhs, y=confidence, fill=Survived)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal()


survived_class_gender_summary

# ------------------ Arules ---------------------------------------
library("arules")

# se transforma el dataframe a transacciones
transactions <- as(titanic.raw, "transactions")
attr(transactions, "itemInfo")

inspect(transactions[1:5])

# generación de reglas
rules = apriori(transactions, parameter=list(target="rules", confidence=0.25, support=0.02))
print(rules)

inspect(head(rules, 10))

inspect(head(sort(rules, by="confidence", decreasing = TRUE), 10))

inspect(head(sort(rules, by="support", decreasing = TRUE), 10))

survived_rules = subset(rules, subset = rhs %pin% "Survived")

inspect(head(sort(survived_rules, by="confidence", decreasing = TRUE), 10))
