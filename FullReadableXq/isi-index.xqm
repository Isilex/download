module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare 
  %rest:path("/error{$code}")
  %output:method("html")  
  function isilex:error($code){
    if ($isi:testLang = 'fr') 
    then
      isi:template(
        <div id=""><h2 style="color:#ff8000; font-size: 5em;">{$code}</h2><p>Nous sommes désolés, une erreur a été rencontrée. </p><p><a class="button" href="/">Revenir</a></p></div>
      )
    else
      isi:template(
        <div id=""><h2 style="color:#ff8000; font-size: 5em;">{$code}</h2><p>We are sorry, an error has been encountered. </p><p><a class="button" href="/">Get back ?</a></p></div>
      )
};


declare
%updating
%rest:path('/change-lang')
%rest:header-param("Referer", "{$referer}", "none")
%rest:POST
%rest:query-param('lang','{$lang}','fr')
%rest:query-param('back','{$back}','/')
function isilex:change-lang($lang,$back,$referer){
  
 try {
   if ($isi:testid)
   then
   
     try {
       if (db:open('utilisateurs')/*/entry[.//id=session:id()]/lang)
       then
       for $i in db:open('utilisateurs')//entry[.//id=session:id()]/lang 
       return 
         replace node $i
         with <lang>{$lang}</lang>
       else (
         insert node <lang>{$lang}</lang> into db:open('utilisateurs')/*/entry[.//id=session:id()]
       ),
       update:output(web:redirect(""||$referer))) 
     }
     
     catch * {
       (
       update:output(web:redirect(""||$referer)))
       , 
       let $content := 'Error [' || $err:code || ']: ' || $err:description 
       return file:write(file:base-dir()||"/errorLangMin.txt", $content))}
      
   else (    
     if (db:open('visits')/root/visit[id=session:id()]) 
     then
       for $i in db:open('visits')/root/visit[id=session:id()] 
       return replace node $i with
       <visit><id>{session:id()}</id><timeStamp>{current-dateTime()}</timeStamp><lang>{$lang}</lang></visit>
     else
       insert node <visit><id>{session:id()}</id><timeStamp>{current-dateTime()}</timeStamp><lang>{$lang}</lang></visit> 
       into db:open('visits')/root
       ,
       update:output(web:redirect(""||$referer)))
   )
 }
 catch * {
   (
   update:output(web:redirect(""||$referer)))
   , 
   let $content := 'Error [' || $err:code || ']: ' || $err:description 
   return file:write(file:base-dir()||"/errorLang.txt", $content))}
   
   
};

declare
  %rest:path("")
  function isilex:start()
{ if (db:open('utilisateurs')//masteradmin) then
  if (empty($isi:testLang)) then web:redirect("/change-lang") else web:redirect("/accueil")
  else(
    web:redirect("/masteradmin")
  )
};


declare
 %rest:path("/accueil")
  function isilex:vers-accueil() {
    if (db:open('utilisateurs')//masteradmin) then
  web:redirect("/accueil/1")
  else (
    web:redirect("/masteradmin")
  )
  };

declare
 %rest:path("/accueil/{$ind}")
  %output:method("html")
  function isilex:startacc($ind)
{
<html onLoadf="var myIframe = document.getElementById('iframe');myIframe.contentWindow.scrollTo(200,ycoord);">
{  
  isi:template((
    if (db:open('site')/root/alphabet='on')
    then
      if ($isi:testid4 or $isi:testid3)
       then 
       <p>
       <a class='' href="/page{if (db:open('site')/root/alphabet='on') then 'HTML' else ()}-{$isi:testLang}-{if ($isi:testLang='fr') then 'texteAccueil' else 'mainPageText'}"><img width='40px' class='zoom' src='/static/images/svg/writing.svg'/></a>
       <a href="/Images"><img class='zoom' src="/static/images/svg/violin.svg" width="40px"/></a>
       {(if (db:open('site')/root/facebook != '') 
       then
          <a href="{db:open('site')/root/facebook}"><img width="25px;" src="/static/images/f.jpg"></img></a>
       else <a><img style="" width="20px;" src="/static/images/f.jpg"></img></a>
      ,
      if (db:open('site')/root/twitter != '') 
      then
        <a href="{db:open('site')/root/twitter}"><img style="margin-left:0px;" width="25px;" src="/static/images/ff.jpeg"></img></a>
      else ()
      ,
      if (db:open('site')/root/gplus != '') 
      then
        <a href="{db:open('site')/root/gplus}"><img style="" width="24px;" src="/static/images/fff.png"></img></a>
      else ()
    )}
      </p> 
      else 
      (if (db:open('site')/root/facebook != '') 
       then
          <a href="{db:open('site')/root/facebook}"><img width="25px;" src="/static/images/f.jpg"></img></a>
       else <a><img style="" width="20px;" src="/static/images/f.jpg"></img></a>
      ,
      if (db:open('site')/root/twitter != '') 
      then
        <a href="{db:open('site')/root/twitter}"><img style="margin-left:0px;" width="25px;" src="/static/images/ff.jpeg"></img></a>
      else ()
      ,
      if (db:open('site')/root/gplus != '') 
      then
        <a href="{db:open('site')/root/gplus}"><img style="" width="24px;" src="/static/images/fff.png"></img></a>
      else ()
    )
    else ()
  ,
     if (db:open('site')/root/alphabet='on')
      then
       if ($isi:testLang='fr') 
        then db:open('pages')/root/page[name='texteAccueil']/div[@lang='fr'] 
        else db:open('pages')/root/page[name='texteAccueil']/div[@lang='en']
       (:Social network:)        
       else
       let $indix := xs:integer($ind)
       for $indice in ($indix to $indix + 24) 
        return
         (
         for $i at $count in db:open($isi:bdd)/*/fiche/entry
        [not(.//orth='AJOUT')]
        order by  xs:dateTime($i/../creationDate) descending
             return 
             <div id="rezSocentry">
             <div id="rezSocPartI">
               <div id="rezSocDateTime"><div id="rezSocDT">Le {replace(data($i/../creationDate),'([^T]*)T.*','$1')} à {replace(data($i/../creationDate),'[^T]*T([^\.]*)...\..*','$1')} by {data($i/../auteur)} : </div> <div id="rezSocTitre"><a href="/fiche/{data($i//orth)}">{data($i//orth)}</a></div></div>
    </div>
    <div id="rezSocImg">
      <a href="{   if (($i//ref, $i//mentioned, $i//def)[. contains text 'http://']) then
                      (for $x at $counter in ($i//ref, $i//mentioned, $i//def)[. contains text 'http://']
                        let $http:= analyze-string(string($x),'http://[^ ]*')//fn:match
                        return $http)[1] else '/fiche/'||data($i//orth)}">
                           <img class='zoom' width="25px" src="
                           {
                             if (($i//ref, $i//mentioned, $i//def)[. contains text 'http://']) then
                               (for $x at $counter in ($i//ref, $i//mentioned, $i//def)[. contains text 'http://']
                               let $http:= analyze-string(string($x),'http://[^ ]*')//fn:match
                               return $http)[1]
                               else '/static/images/svg/alarm-clock.svg'  
                           }"/></a>
    </div>
    <div id="rezSocDef">{string-join($i//def)}</div>
      { 
             let $path := $i//orth 
             return
              if (db:open('site')/root/forum='on')
        		then
          		if ($isi:testidname=db:open('utilisateurs')//name)
           		 then
             <div id="rezSocCommFiches">
               {
            if (db:open('forum')/bdd/entry[bddId=$path])
             then
              (
              if (db:open('forum')/bdd/entry[bddId=$path]) 
             then (
             <a id="rezSocShow-{$path}" style="display:none;" onClick="document.getElementById('rezSocmessageOnForum-{$path}').style.display='';document.getElementById('rezSocHide-{$path}').style.display='';document.getElementById('rezSocShow-{$path}').style.display='none';" class='rezSocButton' href="#messageOnForum-{$path}">Messages +</a>,
             <a id="rezSocHide-{$path}" onClick="document.getElementById('rezSocmessageOnForum-{$path}').style.display='none';document.getElementById('rezSocHide-{$path}').style.display='none';document.getElementById('rezSocShow-{$path}').style.display='';" class='rezSocButton' href="#messageOnForum-{$path}">Messages -</a>)
             else ()
            ,
              for $x in db:open('forum')/bdd/entry[bddId=$path] return 
              <div id="rezSocmessageOnForum-{$path}">
                <ul class="tabUserAdmin">
                  <li>De: {data($x/from)}</li>
                  <li>({replace(data($x/date),'T.*','')} à {replace(data($x/date),'.*T(.....).*','$1')})</li>
                  <li id="titre">Titre: {data($x/titre)}</li>
                  <li>{html:parse(string($x/text), map { 'nons': true() })}</li>
                  {if ($x//answer) then
                    for $answer in $x//answer return
                  <div id="forumAnswer">
                   <ul class="tabUserAdmin">
                  <li>De: {data($answer/auteur)}</li>
                  <li>({replace(data($answer/date),'T.*','')} à {replace(data($answer/date),'.*T(.....).*','$1')})</li>
                  <li>{html:parse(string($answer/mess), map { 'nons': true() })}</li>
                  </ul>
                  </div>
                  else ()
                  }
                  {if ($isi:testid3 or $isi:testid4 or $isi:testidname=db:open($isi:bdd)//(fiche/entry,entry)[upper-case(form/orth)=upper-case($path)][last()]/form/auteur) 
                  		then <a class='rezSocButton' href="/forumEffacer-{data($x/@id)}">Effacer</a> else ()}
                 {if ($isi:testid2 or $isi:testid3 or $isi:testid4) 
                  		then (<a href="#" class='rezSocButton' onClick="document.getElementById('answer{data($x/@id)}').style.display='block'">Répondre</a> 
                  		,
                  		<form id="answer{data($x/@id)}" style="display:none;" method="post" action="/forumAnswer-{data($x/@id)}">
                  		<textarea name="forumanswer" id="areaForum" placeholder="message"></textarea>
                  		<input type="hidden" name="auteur" value="{$isi:testidname}"/>
                  		 <input type="hidden" name="orig" value="{$path}"/>
                  		<p><input class='rezSocButton' type="submit" value="OK"/></p>
                  		</form>
                  		) 
                  else ()}
                </ul>
              </div>
                 )
             else 
             	<p id="rezSoccommFiches"><a class='rezSocButton' href="/fiche/{$i//orth}">Forum</a></p>}
              </div>
          
           else 
           
           <p id="rezSoccommFiches">
           <a class='rezSocButton' href="/login">Connect</a>
            {if (db:open('forum')/bdd/entry[bddId=$path]) 
             then (
             <a id="rezSocShow-{$path}" style="display:none;" onClick="document.getElementById('messageOnForum-{$path}').style.display='';document.getElementById('rezSocHide-{$path}').style.display='';document.getElementById('rezSocShow-{$path}').style.display='none';" class='rezSocButton' href="#messageOnForum-{$path}">Messages +</a>,
             <a id="rezSocHide-{$path}" onClick="document.getElementById('messageOnForum-{$path}').style.display='none';document.getElementById('rezSocHide-{$path}').style.display='none';document.getElementById('rezSocShow-{$path}').style.display='';" class='rezSocButton' href="#messageOnForum-{$path}">Messages -</a>)
             else ()
            }
            {
             for $x at $compteId in db:open('forum')/bdd/entry[bddId=$path] return 
              <div id="messageOnForum-{$path}">
                <ul class="tabUserAdmin">
                  <li>De: {data($x/from)}</li>
                  <li>({replace(data($x/date),'T.*','')} à {replace(data($x/date),'.*T(.....).*','$1')})</li>
                  <li>Titre: {data($x/titre)}</li>
                  <li>{html:parse(string($x/text), map { 'nons': true() })}</li>
                   {if ($x//answer) then
                    for $answer in $x//answer return
                  <div id="forumAnswer">
                   <ul class="tabUserAdmin">
                  <li>De: {data($answer/auteur)}</li>
                  <li>({replace(data($answer/date),'T.*','')} à {replace(data($answer/date),'.*T(.....).*','$1')})</li>
                  <li>{html:parse(string($answer/mess), map { 'nons': true() })}</li>
                  </ul>
                  </div>
                  else ()
                  }
                </ul>
              </div>
              }</p>
      else ()  
             }
        </div>)[$indice]
       )
      )/*
	}
	{
	if (db:open('site')/root/alphabet='off')
      then
		(<div id="rezSocFooter">
			<a href="/accueil/1"><img height="20px" src="/static/images/Preceding.png"/></a>
	     	<a href="/accueil/{$ind + 25}"><img height="20px" src="/static/images/Next.png"/></a>
	</div>
	,
	<div id="rezSocFooterbis">
			<a href="/accueil/1"><img height="20px" src="/static/images/Preceding.png"/></a>
	     	<a  href="/accueil/{$ind + 25}"><img height="20px" src="/static/images/Next.png"/></a>
	</div>)
	else
	()
	}
</html>
};



declare
%output:method('html')
%rest:path('/ODT')
function isilex:rtr(){
  isi:template(
  if ($isi:testLang='fr') then
  <div>
  <h2>ODT et PDF Export</h2>
  <p>Nous vous remercions de l &#x00027; intérêt que vous manifestez pour notre travail <a href="http://www.isilex.fr">Isilex</a>. Les fonctionnalités d'export d'XML vers ODT et PDF sont réservées aux usages professionnels et ne sont accessibles que dans la suite <a href="http://www.isilex.fr">Isilex</a> complète et pas dans IsilexLight.</p>
  </div>
  else 
    <div>
  <h2>ODT and PDF Exportation</h2>
  <p>Thank you for using Isilex. XML to ODT or PDF export is allowed for Professional Use of <a href="http://www.isilex.fr">Isilex</a> and is not included in IsilexLight.</p>
  </div>
  )
};


declare
 %updating
 %rest:header-param("Referer", "{$referer}", "none")
 %rest:path('/wdvhgj{$id}')
 function isilex:xxff($id, $referer){
  if ($isi:testid3 or $isi:testid4) then
   for $x in db:open($isi:bdd)//fiche[./id=$id] return delete node $x
   else (),
   for $x in db:open('forum')/bdd/entry[bddId=$id] return delete node $x,
   for $x in db:open('forum')/bdd/entry[bddId=db:open($isi:bdd)//entry[./id=$id]//orth] return delete node $x,
   update:output(web:redirect("/accueil")))
 };
 
declare
 %rest:path('/valid/bdd')
 %output:method('html') 
 function isilex:valid(){
   if ($isi:testid3) 
   then
     if ($isi:testLang='fr')
     then
       isi:template(
         <div>
           <h2>Administration des fiches</h2>
           Les fonctions d'administration sont dédiées à des usages professionnels d'Isilex.<br/>
           Les fiches actuellement saisies sont immédiatement accessibles en ligne.<br/>
           Pour en savoir, se rendre sur le site: <a href="http://www.isilex.fr">Isilex</a>
         </div>
       )
     else 
       isi:template(
         <div>
           <h2>XML management</h2>
             XML management is dedicated to a professional use of Isilex.<br/>
             XML files of your Isilex are immediately accessible on-Line.<br/>
             Learn more about Premium: <a href="http://www.isilex.fr">Isilex</a>
         </div>
       )
   else isi:template(isi:t('unauthorized_access'))
 };
 
declare
 %rest:path('/export')
 %output:method('html') 
 function isilex:expp(){
   if ($isi:testid3) 
   then
     if ($isi:testLang='fr')
     then
       isi:template(
         <div>
           <h2>Exportation Pdf ou Odt</h2>
             Les fonctions d'exportation sont dédiées à des usages professionnels d'Isilex.<br/>
             Pour en savoir, se rendre sur le site: <a href="http://www.isilex.fr">Isilex</a>
         </div>
       )
     else 
       isi:template(
         <div>
           <h2>Export to Pdf, Odt</h2>
             Export is a Premium Isilex Function.<br/>
             Learn more about Premium: <a href="http://www.isilex.fr">Isilex</a> 
         </div>
       )
   else isi:template(isi:t('unauthorized_access'))
};

declare
 %rest:path('/info')
 %rest:GET
 %rest:query-param('message','{$message}','')
 %output:omit-xml-declaration("no")
 %output:method('html')
 function isilex:login($message){
   if (matches($message,'text_'))
   then
   isi:template(
     isi:t(substring($message,6))
   )
   else (
     isi:template($message)
   )
};