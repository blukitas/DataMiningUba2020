
db.tweet_type.drop();
db.createView(
    "tweet_type",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "is_quote": "$is_quote",
                "is_retweet": "$is_retweet",
                "verified": "$verified",
            }
        }
    ])
db.tweet_type.find({});

db.fechas.drop();
db.createView(
    "fechas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "created_at": "$created_at",
                "retweet_created_at": "$retweet_created_at",
                "quoted_created_at": "$quoted_created_at",
            }
        }
    ])
db.fechas.find({});
	
db.user_estadisticas.drop();
db.createView(
    "user_estadisticas",
    "users_mongo_covid19",
    [
        { $project: {
            user_id: 1,
            name: 1,
            screen_name: 1,
            followers_count: 1,
            listed_count: 1,
            friends_count: 1,
            favourites_count: 1,
            statuses_count: 1,
            verified: 1,
            description: 1,
            account_created_at: 1 
        }}])
db.user_estadisticas.find({});

db.tweet_estadisticas.drop();
db.createView(
    "tweet_estadisticas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "favorite_count": "$favorite_count",
                "quote_count": "$quote_count",
                "retweet_count": "$retweet_count",
                "reply_count": "$reply_count",
                "is_quote": "$is_quote",
                "is_retweet": "$is_retweet",
                "verified": "$verified"
            }
        }
    ]);
db.tweet_estadisticas.find({});

db.tweet_original_estadisticas.drop();
db.createView(
    "tweet_original_estadisticas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "quoted_favorite_count": "$quoted_favorite_count",
                "quoted_retweet_count": "$quoted_retweet_count",
                "retweet_favorite_count": "$retweet_favorite_count",
                "retweet_retweet_count": "$retweet_retweet_count",
                "retweet_verified": "$retweet_verified",
                "quoted_verified": "$quoted_verified"
            }
        }
    ]);
db.tweet_original_estadisticas.find({});

db.tweet_completo_estadisticas.drop();
db.createView(
    "tweet_completo_estadisticas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "favorite_count": "$favorite_count",
                "quote_count": "$quote_count",
                "retweet_count": "$retweet_count",
                "reply_count": "$reply_count",
                "is_quote": "$is_quote",
                "is_retweet": "$is_retweet",
                "verified": "$verified",
                "quoted_favorite_count": "$quoted_favorite_count",
                "quoted_retweet_count": "$quoted_retweet_count",
                "retweet_favorite_count": "$retweet_favorite_count",
                "retweet_retweet_count": "$retweet_retweet_count",
                "retweet_verified": "$retweet_verified",
                "quoted_verified": "$quoted_verified"
            }
        }
    ]);
db.tweet_completo_estadisticas.find({});


db.tweet_users_original.drop();
db.createView(
    "tweet_users_original",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "retweet_user_id": "$retweet_user_id",
                "retweet_followers_count": "$retweet_followers_count",
                "retweet_friends_count": "$retweet_friends_count",
                "retweet_retweet_count": "$retweet_retweet_count",
                "retweet_statuses_count": "$retweet_statuses_count",
                "retweet_favorite_count": "$retweet_favorite_count",
                "retweet_verified": "$retweet_verified",
                "quoted_user_id": "$quoted_user_id",
                "quoted_followers_count": "$quoted_followers_count",
                "quoted_friends_count": "$quoted_friends_count",
                "quoted_statuses_count": "$quoted_statuses_count",
                "quoted_retweet_count": "$quoted_retweet_count",
                "quoted_favorite_count": "$quoted_favorite_count",
                "quoted_verified": "$quoted_verified"
            }
        }
    ]);
db.tweet_users_original.find({});

db.user_tweets_estadisticas.drop();
db.createView(
    "user_tweets_estadisticas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "user_id": "$user_id",
                "name": "$name",
                "screen_name": "$screen_name",
                "is_retweet": "$is_retweet",
                "is_quote": "$is_quote",
                is_rt: {
                    $cond: ["$is_retweet", 1, 0]
                },
                is_qt: {
                    $cond: ["$is_quote", 1, 0]
                },
                is_only_qt: {
                    $cond: [{
                            $and: ["$is_quote", {
                                    $not: "$is_retweet"
                                }
                            ]
                        }, 1, 0
                    ]
                },
                is_only_rt: {
                    $cond: [{
                            $and: ["$is_retweet", {
                                    $not: "$is_quote"
                                }
                            ]
                        }, 1, 0
                    ]
                },
                is_both: {
                    $cond: [{ $and: ["$is_retweet", "$is_quote" ] }, 1, 0
                    ]
                },
                is_none: {
                    $cond: [{
                            $and: [{
                                    $not: "$is_retweet"
                                }, {
                                    $not: "$is_quote"
                                }
                            ]
                        }, 1, 0
                    ]
                },
            }
        }, {
            $group: {
                _id: "$user_id",
                name: {
                    $max: "$name"
                },
                screen_name: {
                    $max: "$screen_name"
                },
                is_rt: {
                    $sum: "$is_rt"
                },
                is_qt: {
                    $sum: "$is_qt"
                },
                is_only_rt: {
                    $sum: "$is_only_rt"
                },
                is_only_qt: {
                    $sum: "$is_only_qt"
                },
                is_both: {
                    $sum: "$is_both"
                },
                is_none: {
                    $sum: "$is_none"
                },
                count: {
                    $sum: 1
                },
            },
        }, {
            $project: {
                _id: 1,
                id: "$id",
                name: 1,
                screen_name: 1,
                is_rt: 1,
                is_qt: 1,
                is_only_rt: 1,
                is_only_qt: 1,
                is_none: 1,
                count: 1,
                tipos_usuario: {
                    $cond: { if: { $gte: [ "$is_none", "$is_rt" ] }, then: "Creador", else: "Difusor" }
                },
            }
        }, 
    ])
db.user_tweets_estadisticas.find({});


db.tweet_hashtags.drop();
db.createView(
    "tweet_hashtags",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "user_id": "$user_id",
                "hashtags": "$hashtags"
            }
        }, {
            $unwind: "$hashtags"
        }
    ]);
db.tweet_hashtags.find({});

db.tweet_text_hashtags.drop();
db.createView(
    "tweet_text_hashtags",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "hashtag": "$hashtags"
        }
    }, {
        "$unwind": "$hashtag"
    }]);
db.tweet_text_hashtags.find({});

db.tweet_text.drop();
db.createView(
    "tweet_text",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "hashtag": "$hashtags"
        }
    }]);
db.tweet_text.find({});

db.tweet_count_hashtags.drop();
db.createView(
    "tweet_count_hashtags",
    "tweets_lower",
    [{
            $unwind: "$hashtags"
        }, {
            "$match": {
                "hashtags": {
                    "$ne": null
                }
            }
        }, {
            $group: {
                _id: "$hashtags",
                hashtag: { $min: "$hashtags" },
                count: {
                    $sum: 1
                },
            }
        }, {
            $sort: {
                count: -1
            }
        }
    ]);
db.tweet_count_hashtags.find({});

db.user_tweets_estadisticas.drop();
db.createView(
    "user_tweets_estadisticas",
    "tweets_lower",
    [{
            $project: {
                "_id": "$_id",
                "user_id": "$user_id",
                "name": "$name",
                "screen_name": "$screen_name",
                "is_retweet": "$is_retweet",
                "is_quote": "$is_quote",
                is_rt: { $cond: ["$is_retweet", 1, 0]},
                is_qt: { $cond: ["$is_quote", 1, 0]},
                is_only_qt: { $cond: [{$and: ["$is_quote", "!$is_retweet"]}, 1, 0]},
                is_only_rt: { $cond: [{$and: ["!$is_quote", "$is_retweet"]}, 1, 0]},
                is_none: { $cond: [{$and: ["!$is_quote", "!$is_retweet"]}, 1, 0]},
            }
        }, {
            $group: {
                _id: "$user_id",
                name: { $max: "$name" },
                screen_name: { $max: "$screen_name" },
                is_rt: { $sum: "$is_rt"},
                is_qt: { $sum: "$is_qt"},
                is_only_rt: { $sum: "$is_only_rt"},
                is_only_qt: {$sum: "$is_only_qt"},
                is_none: {$sum: "$is_none"},
                count: {$sum: 1},
            }, 
            
        }, {
            $project: {
                _id: 1,
                id: "$id",
                name: 1,
                screen_name: 1,
                is_rt: 1,
                is_qt: 1,
                is_only_rt: 1,
                is_only_qt: 1,
                is_none: 1,
                count: 1,
                tipos_usuario: {
                    $cond: { if: { $gte: [ "$is_none", "$is_only_rt" + "$is_only_rt" ] }, then: "Creador", else: "Difusor" }
                },
            }
        }]);
        db.user_tweets_estadisticas.find({});



/* Vistas usadas para nube de palabras */
db.tweet_cuba.drop();
db.createView(
    "tweet_cuba",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.cuba./ }, 
                        { 'retweet_text' :/.cuba./ }, 
                        { 'quoted_text' :/.cuba./ },
                        { 'location' :/.cuba./ },
                        { 'country' :/.cuba./ },
                ]}
    }]);
db.tweet_cuba.find({});

db.tweet_mx.drop();
db.createView(
    "tweet_mx",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.m*xic./ }, 
                        { 'retweet_text' :/.m*xic./ }, 
                        { 'quoted_text' :/.m*xic./ },
                        { 'location' :/.m*xic./ },
                        { 'country' :/.m*xic./ },
                ]}
    }]
    );
db.tweet_mx.find({});

db.tweet_arg.drop();
db.createView(
    "tweet_arg",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.argentin./ }, 
                        { 'retweet_text' :/.argentin./ }, 
                        { 'quoted_text' :/.argentin./ },
                        { 'location' :/.argentin./ },
                        { 'country' :/.argentin./ },
                ]}
    }]);
db.tweet_arg.find({});


db.tweet_vz.drop();
db.createView(
    "tweet_vz",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.venezuela./ }, 
                        { 'text' :/.venezolan./ }, 
                        { 'retweet_text' :/.venezuela./ }, 
                        { 'retweet_text' :/.venezolan./ }, 
                        { 'quoted_text' :/.venezuela./ },
                        { 'quoted_text' :/.venezolan./ }, 
                        { 'location' :/.venezuela./ },
                        { 'location' :/.venezolan./ }, 
                        { 'country' :/.venezuela./ },
                        { 'country' :/.venezolan./ }, 
                ]}
    }]);
db.tweet_vz.find({});


db.tweet_chile.drop();
db.createView(
    "tweet_chile",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.chile./ }, 
                        { 'retweet_text' :/.chile./ }, 
                        { 'quoted_text' :/.chile./ },
                        { 'location' :/.chile./ },
                        { 'country' :/.chile./ }, 
                ]}
    }]);
db.tweet_chile.find({});


db.tweet_usa.drop();
db.createView(
    "tweet_usa",
    "tweets_lower",
    [{
        "$project": {
            "_id": "$_id",
            "tweet_id": "$_id",
            "screen_name": "$screen_name",
            "retweet_name": "$retweet_name",
            "retweet_screen_name": "$retweet_screen_name",
            "quoted_screen_name": "$quoted_screen_name",
            "description": "$descripcion",
            "quoted_description": "$quoted_description",
            "retweet_description": "$retweet_description",
            "favorite_count": "$favorite_count",
            "quote_count": "$quote_count",
            "retweet_count": "$retweet_count",
            "reply_count": "$reply_count",
            "is_quote": "$is_quote",
            "is_retweet": "$is_retweet",
            "verified": "$verified",
            "quoted_verified": "$quoted_verified",
            "retweet_verified": "$retweet_verified",
            "text": "$text",
            "retweet_text": "$retweet_text",
            "quoted_text": "$quoted_text",
            "location": "$location",
            "country": "$country",
            "hashtag": "$hashtags"
        }
    }, {
            "$match": { "$or": [
                        { 'text' :/.united states./ }, 
                        { 'text' :/.estados unidos./ }, 
                        { 'text' :/.eeuu./ },  
                        { 'retweet_text' :/.united states./ }, 
                        { 'retweet_text' :/.estados unidos./ }, 
                        { 'retweet_text' :/.eeuu./ },  
                        { 'quoted_text' :/.united states./ }, 
                        { 'quoted_text' :/.estados unidos./ }, 
                        { 'quoted_text' :/.eeuu./ },  
                        { 'location' :/.united states./ }, 
                        { 'location' :/.estados unidos./ }, 
                        { 'location' :/.eeuu./ },  
                        { 'country' :/.united states./ }, 
                        { 'country' :/.estados unidos./ }, 
                        { 'country' :/.eeuu./ },  
                ]}
    }]);
db.tweet_usa.find({});




db.user_estadisticas.drop();
db.createView(
    "user_estadisticas",
    "users_mongo_covid19",
    [
        { $project: {
            user_id: 1,
            name: 1,
            screen_name: 1,
            followers_count: 1,
            listed_count: 1,
            friends_count: 1,
            favourites_count: 1,
            statuses_count: 1,
            verified: 1,
            description: 1,
            account_created_at: 1, 
            user_popularity: {
                               $switch: {
                                  branches: [
                                     { case: { $lt: [ "$followers_count", 1001] }, then: "Impopular" },
                                     { case: { $and: [
                                                    { "$gt": ["$followers_count", 1000]},
                                                    { "$lt": ["$followers_count", 3501 ]} 
                                                    ]}, then: "Normal" },
                                     { case: { "$gt": ["$followers_count", 3500] }, then: "Populares" }
                                  ]
                               }
                            },
//             user_impopular: {
//                     $cond: [{ $lt: [ "$followers_count", 1001] }
//                             , 1, 0]
//                 },
//             user_normal: {
//                     $cond: [{
//                             $and: [
//                                 { "$gt": ["$followers_count", 1000]},
//                                 { "$lt": ["$followers_count", 3501 ]} 
//                                 ]}
//                             , 1, 0]
//                 },
//             user_popular: {
//                     $cond: [{ "$gt": ["$followers_count", 3500] } , 1, 0 ]
//                 },
        }}])
db.user_estadisticas.find({});

db.user_original_rt_estadisticas.drop();
db.createView(
    "user_original_rt_estadisticas",
    "tweets_lower",
    [
        { 
            "$match": {
                    "is_retweet": true,
                }
        },
        { 
            $project: {
                _id: 1,
                is_retweet: 1,
                retweet_description: 1,
                retweet_name: 1,
                retweet_screen_name: 1,
                retweet_source: 1,
                retweet_favorite_count: 1,
                retweet_followers_count: 1,
                retweet_friends_count: 1,
                retweet_retweet_count: 1,
                retweet_statuses_count: 1,
                user_popularity: {
                                   $switch: {
                                      branches: [
                                         { case: { $lt: [ "$retweet_followers_count", 1001] }, then: "Impopular" },
                                         { case: { $and: [
                                                        { "$gt": ["$retweet_followers_count", 1000]},
                                                        { "$lt": ["$retweet_followers_count", 3501 ]} 
                                                        ]}, then: "Normal" },
                                         { case: { "$gt": ["$retweet_followers_count", 3500] }, then: "Populares" }
                                      ]
                                   }
                                },
            user_impopular: {
                    $cond: [{ $lt: [ "$retweet_followers_count", 1001] }
                            , 1, 0]
                },
            user_normal: {
                    $cond: [{
                            $and: [
                                { "$gt": ["$retweet_followers_count", 1000]},
                                { "$lt": ["$retweet_followers_count", 3501 ]} 
                                ]}
                            , 1, 0]
                },
            user_popular: {
                    $cond: [{ "$gt": ["$retweet_followers_count", 3500] } , 1, 0 ]
                },
            }}])
db.user_original_rt_estadisticas.find({});

db.user_original_qt_estadisticas.drop();
db.createView(
    "user_original_qt_estadisticas",
    "tweets_lower",
    [
        { 
            "$match": {
                    "is_quote": true,
                }
        },
        { 
            $project: {
                _id: 1,
                is_quoted: 1,
                quoted_description: 1,
                quoted_name: 1,
                quoted_screen_name: 1,
                quoted_source: 1,
                quoted_favorite_count: 1,
                quoted_followers_count: 1,
                quoted_friends_count: 1,
                quoted_quoted_count: 1,
                quoted_statuses_count: 1,
                user_popularity: {
                                   $switch: {
                                      branches: [
                                         { case: { $lt: [ "$quoted_followers_count", 1001] }, then: "Impopular" },
                                         { case: { $and: [
                                                        { "$gt": ["$quoted_followers_count", 1000]},
                                                        { "$lt": ["$quoted_followers_count", 3501 ]} 
                                                        ]}, then: "Normal" },
                                         { case: { "$gt": ["$quoted_followers_count", 3500] }, then: "Populares" }
                                      ]
                                   }
                                },
                               user_impopular: {
                    $cond: [{ $lt: [ "$quoted_followers_count", 1001] }
                            , 1, 0]
                },
            user_normal: {
                    $cond: [{
                            $and: [
                                { "$gt": ["$quoted_followers_count", 1000]},
                                { "$lt": ["$quoted_followers_count", 3501 ]} 
                                ]}
                            , 1, 0]
                },
            user_popular: {
                    $cond: [{ "$gt": ["$quoted_followers_count", 3500] } , 1, 0 ]
                },
            }}])
db.user_original_qt_estadisticas.find({});
