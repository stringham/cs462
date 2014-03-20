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
    distance_lat_long = function(lata,lnga,latb,lngb){
      r90   = math:pi()/2;      
      rEm   = 3963.1676;         // radius of the Earth in mi
       
      rlata = math:deg2rad(lata);
      rlnga = math:deg2rad(lnga);
      rlatb = math:deg2rad(latb);
      rlngb = math:deg2rad(lngb);
      distance = math:great_circle_distance(rlnga,r90 - rlata, rlngb,r90 - rlatb, rEm);
      distance;
    }

    distance_from_current = function(lat,long){
      recent = location_data:get_location_data("fs_checkin");
      latb = recent.pick("$.lat");
      longb = recent.pick("$.long");
      d = distance_lat_long(lat, long, latb, longb);
      d;
    }
  }

  rule display {
    select when pageview ".*" setting ()
    pre {
      result = location_data:get_location_data("fs_checkin");
      lat = result.pick("$.lat");
      long = result.pick("$.long");
    }
    {
      notify("latitude",lat) with sticky = true;
      notify("long",long) with sticky = true;
      notify("distance",app:dist + " miles") with sticky = true;
      notify("nearby lat", app:lat) with sticky = true;
      notify("nearby long", app:long) with sticky = true;
      notify("dist now", distance_lat_long(lat,long,app:lat,app:long)) with sticky = true;
    }
  }

  rule nearby {
    select when location newcurrent
    pre {
      lat = event:attr("lat");
      long = event:attr("long");
      dist = distance_from_current(lat,long);
    }
    if dist < 5 then
    {
      send_directive("location") with latitude = lat and longitude = long;
    } fired {
      raise explicit event location_nearby with distance = distance;
      set app:near true;
      set app:dist dist;
      set app:lat lat;
      set app:long long;
    } else {
      raise explicit event location_far with distance = dist;
      set app:near false;
      set app:dist dist;
      set app:lat lat;
      set app:long long;
    }
  }
}
