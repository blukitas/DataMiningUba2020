db.getCollection('tweets_mongo_covid19').find({})

// Ninguno protegido
db.getCollection('tweets_mongo_covid19').distinct("place_type")

// Excluyentes - Usar para llenar nulls? Unificar y reducir
db.getCollection('tweets_mongo_covid19').distinct("country_code")
//6910- Mucha basura, pero podría servir para buscar más perfiles (O no)
db.getCollection('tweets_mongo_covid19').distinct("location") 
db.getCollection('tweets_mongo_covid19').distinct("country")

db.getCollection('tweets_mongo_covid19').distinct("screen_name")
db.getCollection('tweets_mongo_covid19').distinct("hashtags")
db.getCollection('tweets_mongo_covid19').distinct("display_text_width")
db.getCollection('tweets_mongo_covid19').distinct("lang")
 
db.users_mongo_covid19.find({})
db.users_mongo_covid19.distinct("screen_name")
// Filtro tipo where
db.users_mongo_covid19.find({
    $where: "this.screen_name == this.name"
})
db.users_mongo_covid19.find({
    $where: "this.screen_name != this.name"
})

// Tweets de más de 140, porq?
db.tweets_mongo_covid19.find(query = {
        display_text_width: {
            "$gt": 140.0
        }
    })

// Idioma, único español
db.getCollection('tweets_mongo_covid19').count()
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$lang",
                count: {
                    $sum: 1
                }
            }
        },
        {
            "$sort": {
                count: -1
            }
        }
    ]);

// Location, coords, coincidencias?
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$country",
                count: {
                    $sum: 1
                }
            }
        },
        {
            "$sort": {
                count: -1
            }
        }
    ]);

db.tweets_mongo_covid19.aggregate([{
            "$project": { 
                "_id": "$_id",
                "text": "$text"
            }
        }
    ])

db.tweets_mongo_covid19.aggregate([{
            "$project": { 
                "_id": "$_id",
                "text": "$text",
                "retweet_text": "$retweet_text",
                "quoted_text": "$quoted_text",
                "text-rt": { $strcasecmp: [ "$text", "$retweet_text" ] }
            }
        }, 
        {
            "$match": {
                "retweet_text": { "$exists":true },
                "text-rt": { "$ne": 0 }
            }
        }
    ])
db.tweets_mongo_covid19.aggregate([{
            "$project": { 
                "_id": "$_id",
                "text": "$text",
                "retweet_text": "$retweet_text",
                "quoted_text": "$quoted_text",
                "text-qt": { $strcasecmp: [ "$text", "$quoted_text" ] }
            }
        }, 
        {
            "$match": {
                "quoted_text": { "$exists":true },
                "text-qt": { "$ne": 0 }
            }
        }
    ])

// Lista de ciudades/coordenadas y generar valor con eso?
db.tweets_mongo_covid19.aggregate([{
            $project: {
                "_id": "$_id",
                "geo_coords": "$geo_coords",
                "location": "$location",
                "has not coords": {
                    $in: ["NA", "$geo_coords"]
                }
            }
        }
    ])

// 18 personas sin amigos ni seguidores
db.users_mongo_covid19.find({
    "friends_count": {
        "$eq": 0
    },
    "followers_count": {
        '$eq': 0
    }
}).count();
//                               ,
//                               "statuses_count": {"$gt": 5},
//                               "favourites_count": {"$eq": 0} });

// Hash ordenados por cantidad
// Top 1: Sin hashtags
db.tweet_hashtags.aggregate(
    [{
            $group: {
                _id: "$hashtags",
                count: {
                    $sum: 1
                },
            }
        }, {
            $sort: {
                count: -1
            }
        }
    ])
db.tweets_lower.find({"hashtags":{$elemMatch:{"$in":[null], "$exists":true}}})
db.tweets_lower.find({ hashtags: { $gt: [] } })
db.tweets_lower.aggregate( [
    {
        "$project": {
            "_id": "$_id",
            "user_id": "$user_id",
            "hashtag": "$hashtags"
        }
    }, {
        "$unwind": "$hashtag"
    }, {
        "$match": { "hashtag": { "$ne": null } }
    }
] )
db.tweets_lower.aggregate( [
    {
        "$project": {
            "_id": "$_id",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "hashtag": "$hashtags"
        }
    }, {
        "$unwind": "$hashtag"
    }
] )

// Hashtags covid*19
db.tweets_lowercase.aggregate([{
            $unwind: "$hashtags"
        }, {
            $group: {
                _id: "$hashtags",
                count: {
                    $sum: 1
                },
            }
        }, {
            $addFields: {
                resultObject: {
                    $regexFind: {
                        input: "$_id",
                        regex: /covid.*19/
                    }
                }
            }
        }, {
            $sort: {
                count: -1
            }
        }, {
            $match: {
                resultObject: {
                    "$exists": true,
                    "$ne": null
                }
            }
        },
    ])
db.getCollection('tweets_mongo_covid19').find({
    geo_coords: null
})
db.tweets_mongo_covid19.find({
    $where: "this.favorite_count > 1"
}).sort({
    "$favorite_count": -1
})
db.tweets_mongo_covid19.find({
    $where: "this.retweet_count > 1"
}).sort({
    "$retweet_count": -1
})

// Locations de los usuarios
// Hay ciudades y paises
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$location",
                count: {
                    $sum: 1
                }
            }
        },
        {
            "$sort": {
                count: -1
            }
        }
    ]);

// Principales origenes de los tweets
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$source",
                count: {
                    $sum: 1
                }
            }
        }, {
            "$match": {
                count: {
                    "$gt": 1.0
                }
            }
        }
    ]);

// Origenes con más de un tweet
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$source",
                count: {
                    $sum: 1
                }
            }
        }, {
            "$sort": {
                count: -1
            }
        }
    ]);

// Cantidad de tweets de cuentas verificadas
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$verified",
                count: {
                    $sum: 1
                }
            }
        }
    ]);

// Tweets de Cuentas verificadas
db.tweets_mongo_covid19.aggregate([{
            "$match": {
                verified: {
                    "$eq": true
                }
            }
        },
    ]);

// Cuenta verificada con más tweets
db.tweets_mongo_covid19.aggregate([{
            "$match": {
                verified: {
                    "$eq": true
                }
            }
        }, {
            "$group": {
                "_id": "$screen_name",
                count: {
                    $sum: 1
                }
            }
        }, {
            "$sort": {
                count: -1
            }
        }, {
            "$limit": 10
        }
    ]);

// Agrupado por nombre de usuario, del nombre el primero, contar.
// Top 10 de usuarios con más tweets.
// Cada nuevo comando en el array se aplica despupes
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                "_id": "$screen_name",
                "name": {
                    "$first": "$name"
                },
                count: {
                    $sum: 1
                }
            }
        }, {
            "$sort": {
                count: -1
            }
        }, {
            "$limit": 10
        }
    ]);

// Groupy by name, where count() > 1
db.tweets_mongo_covid19.aggregate([{
            "$group": {
                _id: "$screen_name",
                count: {
                    $sum: 1
                }
            }
        }, {
            "$match": {
                count: {
                    "$gt": 1.0
                }
            }
        }
    ]);

// Error de memoria - ordenar solo tweets de calidad?
db.tweets_mongo_covid19.find().sort({
    created_at: -1
})

db.tweets_mongo_covid19.aggregate([{
            $group: {
                _id: {
                    month: {
                        $month: "$created_at"
                    },
                    day: {
                        $dayOfMonth: "$created_at"
                    },
                    year: {
                        $year: "$created_at"
                    }
                },
                count: {
                    $sum: 1
                }
            }
        }
        // , { "$match": { "_id.year": { "$gt": 2020} } }
        // , { "$sort": { "count": -1 } }
    ]);

db.tweets_mongo_covid19.aggregate([{
            $group: {
                _id: { $dayOfYear: "$created_at" },
                count: {
                    $sum: 1
                }
            }
        }
        // , { "$match": { "_id.year": { "$gt": 2020} } }
        , { "$sort": { "_id": 1 } }
    ]);

db.tweets_mongo_covid19.aggregate([{
            $project: {
                "created_at": "$created_at",
                "is_retweet": "$is_retweet"
                }
            }
        ]);


db.tweets_mongo_covid19.aggregate(
    [{
            "$project": {
                "quoted_verified": "$quoted_verified",
                "retweet_verified": "$retweet_verified",
                "is_retweet": "$is_retweet",
                "is_quote": "$is_quote",
                "favorite_count": "$favorite_count",
                "quote_count": "$quote_count",
                "retweet_count": "$retweet_count",
                "reply_count": "$reply_count",
                "quoted_favorite_count": "$quoted_favorite_count",
                "quoted_retweet_count": "$quoted_retweet_count",
                "quoted_statuses_count": "$quoted_statuses_count",
                "retweet_favorite_count": "$retweet_favorite_count",
                "retweet_retweet_count": "$retweet_retweet_count",
                "retweet_statuses_count": "$retweet_statuses_count"
            }
        }
    ]);
        
db.tweets_mongo_covid19.find([{
            "$query": {
                "$retweet_created_at": {
                    "$ne": "$created_at"
                }
            }
        },
    ]);
db.tweets_mongo_covid19.aggregate([
        {
            "$project": {
                created_at: "$created_at",
                is_quote: "$is_quote",
                quoted_created_at: "$quoted_created_at",
                is_retweet: "$is_retweet",
                retweet_created_at: "$retweet_created_at"
            }
        }
    ]);
        
        
        
// Paises
db.tweets_lower.aggregate([
    {
        "$project": {
            "_id": "$_id",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { 
                "$or": [{
                        'text' :/.cuba./
                    }, {
                        'retweet_text' :/.cuba./
                    }, {
                        'quoted_text' :/.cuba./
                    }
                ]
            }
    }
]);
    
    