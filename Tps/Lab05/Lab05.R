library('mongolite')

# m <- mongo("tweets", url = "mongodb://localhost:27017/")
# m <- mongo(collection = "tweets")
m <- mongo(collection = "tweets", db = "dolar")
m$count()

rt <- m$find('{ "retweet_count": { "$gt": 0} }')
nrow(rt)

# Que onda acá?
rt <- m$find('{ "is_retweet": { "$eq": true} }')
nrow(rt)

