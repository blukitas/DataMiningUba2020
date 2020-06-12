library(mongolite)
library(ggplot2)

tweets <- mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
df_source = tweets$aggregate('[{ "$group": {"_id": "$source", "total": { "$sum": 1} } },
                               { "$sort": { "total" : -1}}
                             ]')


names(df_source) <- c("source", "count")

ggplot(data=head(df_source, 10), aes(x=reorder(source, -count), y=count)) +
  geom_bar(stat="identity", fill="steelblue") +
  xlab("Source") + ylab("Cantidad de tweets") +
  labs(title = "Cantidad de tweets en los principales clientes")


users <- mongo(collection = "users_mongo_covid19", db = "DMUBA")
df_users = users$find(query = '{}', 
            fields = '{"friends_count" : true, "listed_count" : true, "statuses_count": true, "favourites_count":true, "verified": true }')
hist(df_users$friends_count, main="cantidad de amigos por usuarios")
hist(log10(df_users$friends_count  + 1), main="Log10 - cantidad de amigos por usuarios")

boxplot(log10(df_users$friends_count  + 1)~verified,data=df_users, main="Cantidad de amigos en cuentas verified vs no verified",
      ylab="Log de cantidad de amigos", xlab="Verified Account") 

