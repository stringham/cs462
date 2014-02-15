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

  rule clear_name {
    select when pageview url #.*#
    pre {
      extractname = function(s) {
        result = s.match(re#(&|^)clear=([^&]+)#) => s.extract(re#(&|^)clear=([^&]+)#) | ["",""];
        result[1];
      };
      query = page:url("query");
      clearname = extractname(query) eq "1" => true | false;
    }
    if(clearname) then{
      notify("Clearing name", "Clearing " + ent:username);
    }
    fired {
      clear ent:username if clearname;
    }
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

  rule display_name {
    select when pageview url #.*#
    if(ent:username) then {
      append("#main", "<p>Hello " + ent:username + ", How are you? I am vulnerable to script injection!</p>");
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
