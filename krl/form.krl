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

  rule show_form {
    select when pageview url #.*#
    pre {
      a_form = <<
        <form id="my_form" onsubmit="return false;">
          <input type="text" name="first" placeholder="First Name"/>
          <input type="text" name="last" placeholder="Last Name"/>
          <input type="submit" value="Submit" />
        </form>
      >>;
    }
    if(not ent:username) then {
      append("#main",a_form);
      watch("#my_form","submit");
    }
  }

  rule form_submit {
    select when web submit "#my_form"
    pre {
      username = event:attr("first") + " " + event:attr("last");
    }
    notify("You submitted", "Submitted " + username);
    fired {
      set ent:username username;
    }
  }
}
