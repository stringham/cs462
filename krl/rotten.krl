//42ksrsasw5k4w3hmztn8vdee

ruleset rotten_tomatoes {
  meta {
    name "Rotten Tomatoes app"
    description <<
      Display form
    >>
    author "Ryan Stringham"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196  alias SquareTag
  }
  dispatch {
  }
  global {
    rotten = function(title){
      results = http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json",
          {
            "apiKey":"42ksrsasw5k4w3hmztn8vdee",
            "q":title
          }
        ).pick("$.content").decode();
      total = results.pick("$.total").as("num");
      movie = <<
       <img src="#{results.pick("$.movies[0]..thumbnail")}">
       <p><span style="font-weight:bold;">Title</span>: #{results.pick("$.movies[0].title")}</p>
       <p><span style="font-weight:bold;">Release Year</span>: #{results.pick("$.movies[0].year")}</p>
       <p><span style="font-weight:bold;">Synopsis</span>: #{results.pick("$.movies[0].synopsis")}</p>
       <p><span style="font-weight:bold;">Critics Rating</span>: #{results.pick("$.movies[0]..critics_rating")}</p>
      >>;
      
      error = <<
        <p>No results found for #{title}. Please search again.</p>
      >>;
      html = (total > 0) => movie | error;
      html;
    }
  }
  rule Rotten {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id="movie_result" style="width:500px; margin:auto;">
        </div>
        <form id="my_form" onsubmit="return false;">
          <input type="text" name="title" placeholder="Movie Title"/>
          <input type="submit" value="Submit" />
        </form>
      >>;

    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Lookup Movie", {}, my_html);
      watch("#my_form","submit");
    }
  }

  rule form_submit {
    select when web submit "#my_form"
    pre {
      movie = event:attr("title");
      results = rotten(movie);
//      title = results.pick("$.movies[0].title");
//      thumb = results.pick("$.movies[0]..thumbnail");
//      release = results.pick("$.movies[0]..theater");
//      synopsis = results.pick("$.movies[0].synopsis");
//      rating = results.pick("$.movies[0]..critics_rating");
    }
    {
      replace_inner("#movie_result",results);
    }
  }
}
