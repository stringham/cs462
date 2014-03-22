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

      subscriptionMap = [
        {"cid": "5D35619C-B16F-11E3-9C90-457E87B7806A"},
        {"cid": "8B2BBA7E-B16F-11E3-A4F2-B6FC283232C8"}
      ];

    }

  rule foursquare_checkin {
    select when foursquare checkin
    pre {
      response = event:attr("checkin");
      venue = response.decode().pick("$.venue.name").as("str");
      city = response.decode().pick("$.venue..city").as("str");
      shout = response.decode().pick("$.shout").as("str");
      createdAt = response.decode().pick("$.createdAt").as("str");
      lat = response.decode().pick("$.venue.location.lat").as("num");
      long = response.decode().pick("$.venue.location.lng").as("num");
      d = {
        "lat":lat,
        "long":long,
        "venue":venue
      };
    } 
    {
      send_directive(venue) with checkin = venue;
    }
    fired {
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:created createdAt;
      set ent:test venue;
      set ent:lat lat;
      set ent:long long;
      raise explicit event notify_subscribers for b505194x3 with data = d;
      raise pds event new_location_data for b505169x5 with key = "fs_checkin" and value = {"created" : createdAt, "city": city, "venue" : venue, "shout": shout, "lat": lat, "long":long};
    }
  }

  rule notify {
    select when explicit notify_subscribers
      foreach subscribers setting (subscriber)
      {
        send_directive('sending') with sub = subscriber;
        event:send(subscriber,"location","notification") with attrs = event:attr("data");
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
