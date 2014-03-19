//72F60222-AF74-11E3-A564-7FC8637EDFE5

//curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "lat=14.001023&long=143.00405" http://cs.kobj.net/sky/event/72F60222-AF74-11E3-A564-7FC8637EDFE5/1/location/new_current?_rids=b505169x7

//http://cs.kobj.net/sky/event/72F60222-AF74-11E3-A564-7FC8637EDFE5/1/location/new_current?_rids=b505169x7.prod&lat=10&long=20

ruleset semantic {
  meta {
    name "Semantic Translation"
    description <<
      Semantic Translation ruleset for Lab 7
    >>
    author "Ryan Stringham"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196  alias SquareTag
    use module b505169x5 alias location_data
  }
  dispatch {
  }
  global {
  }

  rule display {
    select when pageview ".*" setting ()
    pre {
      result = location_data:get_location_data("fs_checkin");
      lat = result.pick("$.lat");
      long = result.pick("$.long");
    }
    {
      notify("latitude",lat);
      notify("long",long);
    }
  }

  rule nearby {
    select when location newcurrent
    pre {
      lat = event:attr("lat");
      long = event:attr("long");
    }
    {
      send_directive("location") with latitude = lat and longitude = long;
    }
  }
}
