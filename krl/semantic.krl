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
      notify("lat",lat);
      notify("long",long);
    }
  }

  rule nearby {
    select when location new_current
    pre {
      lat = event:attr("lat");
      long = event:attr("long");
    }
    {
      send_directive("location") with latitude = lat and longitude = long;
    }
  }
}
