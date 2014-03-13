ruleset foursquare {
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
      response = event:attr("checkin");
      venue = response.decode().pick("$.venue.name").as("str");
      city = response.decode().pick("$.venue..city").as("str");
      shout = response.decode().pick("$.shout").as("str");
      createdAt = response.decode().pick("$.createdAt").as("str");
    } 
    send_directive(venue) with checkin = venue;
    fired {
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:created createdAt;
      set ent:test venue;
      raise pds event new_location_data for b505169x5 with key = "fs_checkin" and value = {"created" : createdAt, "city": city, "venue" : venue, "shout": shout};
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
