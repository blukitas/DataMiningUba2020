/*
    Este archivo es para ejecutarlo sobre una colletion clonada de la original.
    
    Finalidad: transformar a minusculas la mayoria de los campos que me parecieron interesantes 
    y de tipo texto.
*/

db.tweets_lower.find({})

db.tweets_lower.find({}, {
    'screen_name': 1
}).forEach(function (doc) {
    db.tweets_lower.update({
        _id: doc._id
    }, {
        $set: {
            'screen_name': doc.screen_name.toLowerCase()
        }
    }, {
        multi: true
    })
});

db.tweets_lower.find({}, {
    'name': 1
}).forEach(function (doc) {
    db.tweets_lower.update({
        _id: doc._id
    }, {
        $set: {
            'name': doc.name.toLowerCase()
        }
    }, {
        multi: true
    })
});

db.tweets_lower.find({}, {
    'description': 1
}).forEach(function (doc) {
    if (doc.description) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'description': doc.description.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

db.tweets_lower.find({}, {
    'text': 1
}).forEach(function (doc) {
    if (doc.text) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'text': doc.text.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

// Tira varios errores
db.tweets_lower.find().forEach(function (e) {
    for (var i = 0; i < e.hashtags.length; i++) {
        if (e.hashtags[i]) {
            e.hashtags[i] = e.hashtags[i].toLowerCase();
        }
    }
    db.tweets_lower.save(e);
});


db.tweets_lower.find({}, {
    'source': 1    
}).forEach(function (doc) {
    if (doc.source) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'source': doc.source.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

db.tweets_lower.find({}, {
    'country': 1    
}).forEach(function (doc) {
    if (doc.country) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'country': doc.country.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

db.tweets_lower.find({}, {
    'retweet_location': 1    
}).forEach(function (doc) {
    if (doc.retweet_location) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'retweet_location': doc.retweet_location.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});
db.tweets_lower.find({}, {
    'location': 1    
}).forEach(function (doc) {
    if (doc.location) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'location': doc.location.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});
db.tweets_lower.find({}, {
    'quoted_location': 1    
}).forEach(function (doc) {
    if (doc.quoted_location) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'quoted_location': doc.quoted_location.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

db.tweets_lower.find({}, {
    'country_code': 1    
}).forEach(function (doc) {
    if (doc.country_code) {
        db.tweets_lower.update({
            _id: doc._id
        }, {
            $set: {
                'country_code': doc.country_code.toLowerCase()
            }
        }, {
            multi: true
        })
    }
});

