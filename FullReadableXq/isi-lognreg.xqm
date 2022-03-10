(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace sessions = "http://basex.org/modules/sessions";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
 %rest:path("/register")
  %rest:GET
  %rest:query-param('message','{$message}','')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:register($message)
  
{
isi:template(
  (
  <div>
          <div id="fondBlack" onClick="history.go(-1)"/>
   <div id="tablet">
  <form method="post" action='registering'>
  <table>
  <tr><td>   <img width="15px;" src="static/images/Preceding.png" style="cursor: pointer;" onClick="history.go(-1)"/></td><td/></tr>
  <tr><td>Inscription</td><td>{$message}</td></tr>
  <tr>
  <td>{isi:t('username')}</td>
  <td><input class="adminInput" type='text' name="user"></input></td>
  </tr>
  <tr>
  <td>Mail</td>
  <td><input class="adminInput" type='text' name='mail'></input></td>
  </tr>
  <tr>
  <td>{isi:t('password')}</td>
  <td><input class="adminInput" type='password' name='mdp'></input></td>
  </tr>
  <tr>
  <td>
  {isi:t('re_password')}
  </td>
  <td>
  <input class="adminInput" type='password' name='rmdp'></input>
  </td>
  </tr>
  <tr>
  <td/>
  <td>
  <input class="adminInput" type='submit' value="{isi:t('register')}"></input>
  </td>
  </tr>
  </table>
    </form>
    </div>
    </div>)
)
};

declare
 %updating
 %rest:path('/registering')
 %output:method('html')
 %rest:POST
 %rest:form-param('user','{$user}','')
 %rest:form-param('mail','{$mail}','')
 %rest:form-param('mdp','{$mdp}','')
 %rest:form-param('rmdp','{$rmdp}','')
 function isilex:registering($user,$mdp,$rmdp,$mail){
   if ($isi:testid)
   then update:output(web:redirect("/user/"||$isi:name)))
   else
   if ($user != '' and $user !=db:open('utilisateurs')/utilisateurs/entry/name) then
     if ($mail='' or not(matches($mail,'^.+@.+\..+')) or $mail = db:open('utilisateurs')/utilisateurs/entry/mail)
     then
       update:output(web:redirect("/register?message="||web:encode-url(isi:t('invalid_mail')))))
     else
       if ($mdp = '' or $mdp!=$rmdp) 
       then update:output(web:redirect("/register?message=Mot de passe vide ou non semblable"))) 
       else 
         if ($mdp=$rmdp and $mdp != '') 
         then (insert node 
       <entry>
         <name>{$user}</name>
         <mail>{$mail}</mail>
         <usertype>user</usertype>
         <password>{crypto:hmac($mdp,'isilex','sha512','base64')}</password>
         <sessions>
           <session><timeStamp>{current-dateTime()}</timeStamp>
           <id>{session:id()}</id></session></sessions>
           <lang>fr</lang>
         <masterGroup>
           <name></name>
         </masterGroup>
       </entry> into db:open('utilisateurs')/utilisateurs,update:output(web:redirect("/user/"||$user))))
         else db:output(
           web:redirect("/register?message="||web:encode-url(isi:t('invalid_password'))))
         
   else (db:output(
           web:redirect("/register?message="||web:encode-url(isi:t('invalid_username')))
         )
   )
};
 


declare
%rest:path('/login')
 %rest:GET
 %rest:query-param('message','{$message}','')
 %output:method('html')
 function isilex:login($message){
   let $log :=
   (
     <div>
          <div id="fondBlack"/>
     {if ($isi:testid) then (<p>If you want to try Admin connexion and try Web Pages Editing, XML Editing or Pages administration and CSS changes,</p>,<p> 
     Please Contact us at: i-def@i-def.fr</p>) else 
     <div id="tablet">
     <form method='post' action='logging'>
       <table>
       <tr><td><img width="15px;" src="static/images/Preceding.png" style="cursor: pointer;" onClick="history.go(-1)"/></td><td>{$message}</td></tr>
       <tr>
       <td>Login</td><td><input class="adminInput" type='text' name="user" placeholder="login"></input></td>
       </tr>
       <tr>
              <td>{isi:t('password')}</td>
       <td><input class="adminInput" type='password' name="pass" placeholder="password"></input></td>
       </tr>
       <tr><td><a href='/register'>{isi:t('register')}</a></td>
       <td><input type='submit' Value="{isi:t('connection')}"></input></td>
       </tr>
       </table>
     </form>
     </div>}
   </div>)
   return isi:template($log)
 };

declare
 %updating
%rest:path("/logging")
 %output:method('html')
 %rest:POST
 %rest:form-param("user","{$user}","")
 %rest:form-param("pass","{$pass}","")
 function isilex:logging($user,$pass){
   
     if ($user= db:open('utilisateurs')/utilisateurs/entry/name and db:open('utilisateurs')/utilisateurs/entry[name=$user]/password=crypto:hmac($pass,'isilex','sha512','base64')) 
     then (
       insert node <session><id>{session:id()}</id><timeStamp>{current-dateTime()}</timeStamp></session> into db:open('utilisateurs')/utilisateurs/entry[name=$user]/sessions,
       for $i in db:open('utilisateurs')//id[.!=sessions:ids()]
       return delete node $i,
       for $i in db:open('visits')//id[.!=sessions:ids()]
       return delete node $i,
       db:output(<restxq:redirect>/</restxq:redirect>))
     else db:output(<restxq:redirect>/login?message=Failed!</restxq:redirect>)
 };
 
declare
  %updating
  %rest:path('/logout')
   function isilex:logout(){
   delete node db:open('utilisateurs')//entry[//id=session:id()]//id,
   for $i in db:open('utilisateurs')//id[.!=sessions:ids()]
   return delete node $i,
   for $i in db:open('visits')//id[.!=sessions:ids()]
       return delete node $i
   ,
   update:output(web:redirect("/")))
};
