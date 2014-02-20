//42ksrsasw5k4w3hmztn8vdee

ruleset rotten_tomatoes {
  meta {
    name "Rotten Tomatoes app"
    description <<
      Display form
    >>
    author "Ryan Stringham"
    logging off
  }
  dispatch {
  }
  global {
    rotten = function(){
      http:get('http://api.rottentomatoes.com/api/public/v1.0/movies.json',
          {
            'apiKey':'42ksrsasw5k4w3hmztn8vdee'
          }
        )
    }
  }
}
