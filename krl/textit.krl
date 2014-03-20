ruleset textit {
  meta {
    name "Textit"
    description <<
      texting ruleset for Lab 7
    >>
    author "Ryan Stringham"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196  alias SquareTag

    key twilio {
      "account_sid" : "AC0659f4630f33589c0cf8588853710ad9",
      "auth_token"  : "7803411af567ce3431319527ee177b85"
    }
    use module a8x115 alias twilio with twiliokeys = keys:twilio()
  }
  dispatch {
  }
  global {
  }

  rule nearby {
    select when explicit location_nearby
    pre {
      distance = event:attr("distance");
      message = "Nearby fired. Distance is " + distance.as("str") + " miles.";
    }
    {
      send_directive("texting") with dist = distance;
      twilio:send_sms("+18018757355", "+18012069888", message);
    }
  }
}
