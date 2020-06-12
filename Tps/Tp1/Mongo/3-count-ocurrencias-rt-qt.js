db.tweets_lower.aggregate(
    [{
            "$match": {
                "is_quote": true,
            }
        }, {
            $group: {
                _id: "$quoted_user_id",
                quoted_screen_name: {
                    $max: "$quoted_screen_name"
                },
                count: {
                    $sum: 1
                },
            },
        }, {
            $sort: {
                count: -1
            }
        }
    ]);

db.tweets_lower.aggregate(
    [{
            "$match": {
                "is_quote": true,
            }
        }, {
            $group: {
                _id: "$quoted_status_id",
                quoted_screen_name: {
                    $max: "$quoted_screen_name"
                },
                count: {
                    $sum: 1
                },
            },
        }, {
            $sort: {
                count: -1
            }
        }
    ]);

db.tweets_lower.aggregate(
    [{
            "$match": {
                "is_retweet": true,
            }
        }, {
            $group: {
                _id: "$retweet_user_id",
                quoted_screen_name: {
                    $max: "$retweet_screen_name"
                },
                count: {
                    $sum: 1
                },
            },
        }, {
            $sort: {
                count: -1
            }
        }
    ]);

db.tweets_lower.aggregate(
    [{
            "$match": {
                "is_retweet": true,
            }
        }, {
            $group: {
                _id: "$retweet_status_id",
                quoted_screen_name: {
                    $max: "$retweet_screen_name"
                },
                count: {
                    $sum: 1
                },
            },
        }, {
            $sort: {
                count: -1
            }
        }
    ]);