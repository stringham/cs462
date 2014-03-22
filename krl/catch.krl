ruleset catcher {
  meta {
    name "Catch location notifications"
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
      getCheckinHtml = function(venue, lat, long){
        html = <<
          <div style="margin:auto;width:400px;height:200px;">
            <h1>Foursquare checkin:</h1>
            <p>Venue: #{venue}</p>
            <p>latitude: #{lat}</p>
            <p>longitude: #{long}</p>
        >>;
        html;
      }
    }

  rule location_catch {
    select when location notification
    pre {
      lat = event:attr("lat");
      long = event:attr("long");
      venue = event:attr("venue");
    } 
    {
      send_directive(venue) with checkin = venue;
    }
    fired {
      set ent:venue venue;
      set ent:lat lat;
      set ent:long long;
    }
  }

  rule location_show {
    select when web cloudAppSelected
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare Checkin Information", {}, getCheckinHtml(ent:venue, ent:lat, ent:long));
      emit <<
        console.log("cloud app selected. :) ");
      >>;
    }
  }
}
