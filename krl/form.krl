ruleset NotifyApp {
  meta {
    name "Form app"
    description <<
      Display form
    >>
    author "Ryan Stringham"
    logging off
  }
  dispatch {
  }
  global {
  }

  rule send_form {
    select when pageview url #.*#
    pre {
      a_form = <<
        <form id="my_form" onsubmit="return false;">
        <input type="text" name="first" />
        <input type="text" name="last" />
        <input type="submit" value="Submit" />
        </form>
      >>;
    }
    if(not ent:username) then {
      append("#main",a_form);
      watch("#my_form","submit");
    }
  }
}
