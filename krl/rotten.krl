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

      my_html2 = <<
        <h5>Hello, World!</h5>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Hello World!", {}, my_html2);
      CloudRain:createLoadPanel("Lookup Movie", {}, my_html);
      notify("Welcome",'Welcome!');
      watch("#my_form","submit");
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
