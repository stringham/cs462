ruleset location_data {
  meta {
    name "Data Storage Module"
    description <<
      Data Storage Module
    >>
    author "Ryan Stringham"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196  alias SquareTag
    provides get_location_data
  }
  dispatch {
  }
  global {
    get_location_data = function(key) {
      res = app:data{k} || "nothing stored by that key"
      res
    }
  }

  rule add_location_item  {
    select when pds new_location_data
    pre {
      key = event:attr("key");
      val = event:attr("value");
      data = {};
    }
    send_directive(key) with location = val;
    always {
      set app:data data.put([key], val);
    }
  }
}
