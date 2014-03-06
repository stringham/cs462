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
      getCheckinHtml = function(venue, city, shout, created){
        html = <<
          <div style="margin:auto;width:400px;height:200px;">
            <h1>Foursquare checkin:</h1>
            <p>Venue: #{venue}</p>
            <p>City: #{city}</p>
            <p>Shout: #{shout}</p>
            <p>Created At: #{created}</p>
        >>;
        html;
      }
    }

  rule foursquare_checkin {
    select when foursquare checkin
    pre {
      checkin = event:attr("checkin").decode();
      test = event:attr("checkin");
      venue = checkin.pick("$.venue.name").as("str");
      city = checkin.pick("$.venue.location.city");
      shout = checkin.pick("$.shout").as("str");
      created = checkin.pick("$.createdAt").as("str");
    }
    {
      emit <<
      console.log("foursquare checkin");
      >>;
    }
    fired {
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:created created;
      set ent:test test;
    }
  }

  rule display_checkin {
    select when web cloudAppSelected
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare Checkin Information", {}, getCheckinHtml(ent:test, ent:city, ent:shout, ent:created));
      emit <<
        console.log("cloud app selected. :) ");
      >>;
    }
  }
}
