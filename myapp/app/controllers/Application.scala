package controllers

import play.api._
import play.api.mvc._
import org.scribe.builder._
import org.scribe.builder.api.Foursquare2Api
import org.scribe.model.{Token, Verb, OAuthRequest, Verifier}
import org.mindrot.jbcrypt._
import play.api.data.Form
import play.api.data.Forms._
import scala.io.Source
import scalax.io._
case class CreateUser(username:String,password:String)
case class Login(username:String,password:String)
case class User(username:String,password:String,id:Int,token:String)

object Application extends Controller {

  private val version = "v=20140121&oauth_token="
  private val checkin_url = "https://api.foursquare.com/v2/users/self/checkins?" + version
  private val resource_url = "https://api.foursquare.com/v2/users/self?" + version

  def index = Action { implicit request =>
    val users = getUsers
    val user = activeUser(request)
    val connected = if(user.isDefined) isConnected(user.get) else false

    Ok(views.html.index(users,user, connected))
  }

  def connect = Action { implicit request =>
    val user = activeUser(request)
    if(!user.isDefined){
      Redirect(routes.Application.index)
    }
    else{
      val service = getService
     Ok(views.html.authenticate(service.getAuthorizationUrl(null), user.get))
    }
  }

  def isConnected(user:User) = {
    if(user.token.length > 0){
      val service = getService
      val accessToken = new Token(user.token, secret)
      val request = new OAuthRequest(Verb.GET, checkin_url+user.token)
      service.signRequest(accessToken, request)
      val response = request.send
      if(response.getCode != 200){
        updateToken(user.id, "")
      }
      response.getCode() == 200
    } else {
      false
    }
  }

  def getCheckinInfo(token:String, limit:Int = 250) = {
    val service = getService
    val accessToken = new Token(token, secret)
    val oauth_request = new OAuthRequest(Verb.GET, checkin_url+token + "&limit=" + limit.toString)
    service.signRequest(accessToken, oauth_request)
    val response = oauth_request.send
    response.getBody
  }

  def displayInfo = Action { implicit request =>
    val user = activeUser(request)
    if(user.isDefined){
      Ok(views.html.view(user.get,getCheckinInfo(user.get.token)))
    } else {
      Redirect(routes.Application.index)
    }
  }

  def displayUser(id:Int) = Action { implicit request =>
    val user = activeUser(request)
    val otherUser = getUserById(id)

    if(!otherUser.isDefined){
      Redirect(routes.Application.index)
    } else if(isConnected(otherUser.get)){
      if(user.isDefined && user.get.id == otherUser.get.id){
        Ok(views.html.view(user.get,getCheckinInfo(user.get.token)))
      } else {
        Ok(views.html.view(otherUser.get,getCheckinInfo(otherUser.get.token,1),user.isDefined, user.isDefined && isConnected(user.get)))
      }
    } else {
      Ok(views.html.notconnected(otherUser.get))
    }
  }

  def logout = Action { implicit request =>
    Redirect(routes.Application.index).discardingCookies(DiscardingCookie("signed-in"))
  }

  val loginForm = Form(
    mapping(
      "username" -> text,
      "password" -> text
    )(Login.apply)(Login.unapply)
  )

  def login = Action { implicit request =>
    Ok(views.html.login(loginForm))
  }

  def loginSubmit = Action { implicit request =>
    loginForm.bindFromRequest().fold(
      formWithErrors => {
        Ok(views.html.login(formWithErrors))
      },
      value => {
        val user = lookupUser(value)
        if(user.isDefined){
          Redirect(routes.Application.index).withCookies(Cookie("signed-in",user.get.id.toString,Some(60*60*24*7),"/",None,true))
        } else {
          Ok(views.html.login(loginForm.withError("Invalid","Wrong username/password")))
        }
      }
    )
  }


  def activeUser(request:Request[AnyContent]) = {
    val signedIn = request.cookies.get("signed-in")
    if(signedIn.isDefined){
      getUserById(signedIn.get.value.toInt)
    } else {
      None
    }
  }

  val createUserForm = Form(
  mapping(
  "username" -> text,
  "password" -> text
  )(CreateUser.apply)(CreateUser.unapply)
  )

  def createUser = Action { implicit request =>
    if(request.cookies.get("signed-in").isDefined){
      Redirect("/")
    } else {
      Ok(views.html.createUser(createUserForm))
    }
  }

  def createUserSubmit = Action { implicit request =>
    createUserForm.bindFromRequest().fold(
    formWithErrors => {
        Ok(views.html.createUser(formWithErrors))
      },
    value => {
        val users = getUsers
        if(users.find(_.username == value.username).isDefined){
          Ok(views.html.createUser(createUserForm.withError("duplicate username","Username not available")))
        } else {
          saveUsers(users ++ List(User(value.username, BCrypt.hashpw(value.password,BCrypt.gensalt()), users.size, "")))
          Redirect(routes.Application.index)
        }
      }
    )
  }

  def callback = Action { implicit request =>
    val verifier = new Verifier(request.getQueryString("code").get)
    val service = getService
    val accessToken = service.getAccessToken(null, verifier)
    val user = activeUser(request).get
    updateToken(user.id, accessToken.getToken)
    Redirect(routes.Application.index)
  }

  def getService = {
    val callbackUrl = "https://localhost:9051/callback"
    new ServiceBuilder().provider(classOf[Foursquare2Api]).apiKey(key).apiSecret(secret).callback(callbackUrl).build
  }

  def lookupUser(loginData:Login) = {
    getUsers.find(u=> u.username == loginData.username && BCrypt.checkpw(loginData.password,u.password))
  }

  def getUserById(id:Int) = {
    getUsers.find(_.id == id)
  }

  def parseUser(xml:scala.xml.NodeSeq) = {
    User((xml \ "username").text, (xml \ "password").text, (xml \ "id").text.toInt, (xml \ "token").text)
  }

  def saveToFile(filename:String, users:Iterable[User]) {
    def exml(s:String) = scala.xml.Utility.escape(s)
    val content = "<users>"+users.map(u=> "<user><id>"+exml(u.id.toString)+"</id><username>"+exml(u.username)+"</username><password>"+exml(u.password)+"</password><token>"+exml(u.token)+"</token></user>").mkString+"</users>"

    def printToFile(f: java.io.File)(op: java.io.PrintWriter => Unit) {
      val p = new java.io.PrintWriter(f)
      try { op(p) } finally { p.close() }
    }

    printToFile(new java.io.File(filename))(p=>p.println(content))
  }

  def updateToken(id:Int,token:String) {
    val users = getUsers.map { user =>
      if(user.id == id){
        User(user.username,user.password,user.id,token)
      } else {
        user
      }
    }
    saveUsers(users)
  }

  def getUsers = {
    (openSaveFile("users.txt") \\ "user").map(parseUser)
  }

  def saveUsers(users:Iterable[User]) {
    saveToFile("users.txt", users)
  }

  def openSaveFile(name:String) = {
    try{
      scala.xml.XML.loadString(Source.fromFile(name).getLines.mkString("\n"))
    } catch {
      case e:Exception =>
        <users></users>
    }
  }
  
}