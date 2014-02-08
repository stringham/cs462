ruleset NotifyApp {
  meta {
    name "Notify app"
    description <<
      Display notifications
    >>
    author "Ryan Stringham"
    logging off
  }
  dispatch {
  }
  global {
  }
  rule Notify {
    select when pageview ".*" setting ()
    pre {
    }
    {
      notify("Hello world", "This is an example rule.");
      notify("My second notification", "This is my sticky notifier.") with sticky = true;
    }
  }

  rule Hello {
    select when pageview ".*" setting()
    pre {
      extractname = function(s) {
        result = s.match(re#(&|^)name=([^&]+)#) => s.extract(re#(&|^)name=([^&]+)#) | ["","Monkey"];
        result[1];
      };
      query = page:url("query");
      name = extractname(query);//query.match(re#.+#) => query | "Monkey";
    }
    {
      notify("Query Hello", "Hello " + name);
    }
  }

  rule Count {
    select when pageview ".*" setting()
    pre {
      query = page:url("query");
      hasClear = query.match(re#(&|^)clear(=|$)#);
      num = ent:count;
    }
    if ent:count < 5 then 
      notify("Count rule", num);
    always {
      ent:count += 1 from 1;
      clear ent:count if hasClear;
    }
  }
}