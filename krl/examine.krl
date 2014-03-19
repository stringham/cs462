ruleset examin_location {
  meta {
    name "examine location"
    description <<
      Examine Location for Lab 6
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
    getCheckinHtml = function(data){
      html = <<
        <div style="margin:auto;width:400px;height:200px;">
          <h1>Foursquare checkin:</h1>
          <p>Venue: #{data.pick("$.venue")}</p>
          <p>City: #{data.pick("$.city")}</p>
          <p>Shout: #{data.pick("$.shout")}</p>
          <p>Created At: #{data.pick("$.created")}</p>
          <p>Latitude: #{data.pick("$.lat")}</p>
          <p>Longitude: #{data.pick("$.long")}</p>
      >>;
      html;
    }
  }

  rule show_fs_location {
    select when web cloudAppSelected
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Show checkin data", {}, getCheckinHtml(location_data:get_location_data("fs_checkin")));
//      CloudRain:createLoadPanel("Show checkin test", {}, location_data:get_location_data("fs_checkin").as("str"));
    }
  }
}
