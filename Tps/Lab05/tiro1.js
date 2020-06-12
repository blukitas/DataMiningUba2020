db.getCollection('tweets')
  .find().sort({_id:1}).limit(2);
db.getCollection('tweets').find(query = { is_quote: { "$eq": false} });
db.getCollection('tweets').find(query = { screen_name: { "$eq": "Florsube"} });

db.tweets.count(); --522

// 2) 
db.tweets.distinct("text"); --522
db.tweets.find(query = { is_retweet: { "$eq": true} });
db.tweets.find(query = { retweet_count: { "$gt": 0} }).count(); //161
db.tweets.aggregate( [
                     //{ $match: { status: "A" } },
                     { $group: { text: "$text", total: { $sum: "$text" } } },
                     { $sort: { total: -1 } }
                   ] )

// 2) c
db.getCollection('tweets').find({ screen_name: /^P/});
db.getCollection('tweets').find({ screen_name: /^P/}).count();



