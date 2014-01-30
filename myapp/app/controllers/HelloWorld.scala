package controllers

import play.api.mvc.{Action, Controller}

/**
 * Created by ryan on 1/21/14.
 */
object HelloWorld extends Controller {

  def index = Action {
    Ok("Hello World")
  }
}
