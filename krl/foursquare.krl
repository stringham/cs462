ruleset rotten_tomatoes {
  meta {
    name "Foursquare Checkin app"
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
      getCheckinHtml = function(checkin){
        html = <<
          <div style="margin:auto;width:400px;height:200px;">
            <h1>Foursquare checkin:</h1>
            <p>Venue: #{checkin.pick("$.venue.name").as("str")}</p>
            <p>City: #{checkin.pick("$.venue.location.city").as("str")}</p>
            <p>Shout: #{checkin.pick("$.shout").as("str")}</p>
            <p>Created At: #{checkin.pick("$.createdAt").as("str")}</p>
        >>;
        html;
      }
    }

  rule foursquare_checkin {
    select when foursquare checkin
    pre {
      checkin = event:attr("checkin").decode();
    }
    {
      emit <<
      console.log(#{ent:checkin});
      >>;
    }
    fired {
      set ent:checkin getCheckinHtml(checkin);
    }
  }

  rule display_checkin {
    select when web cloudAppSelected
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare Checkin Information", {}, ent:checkin);
      emit <<
        console.log("cloud app selected.");
      >>;
    }
  }
}
