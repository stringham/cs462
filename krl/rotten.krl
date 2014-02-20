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
  rule Rotten {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <input type="text" name="title" placeholder="Movie Title"/>
        <input type="submit" value="Submit" />
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Lookup Movie", {}, my_html);
      watch("#my_form","submit");
      notify("Welcome",'Welcom!');
    }
  }

  rule form_submit {
    select when web submit "#my_form"
    pre {
      movie = event:attr("title");
    }
    {
      notify("You submitted", "Submitted " + movie);
    }
  }
}
