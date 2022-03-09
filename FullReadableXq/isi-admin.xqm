module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

 declare 
 %rest:path('/gere-site')
  %output:method("html")
  %output:omit-xml-declaration("no")

  function isilex:gere-site()
 
{
   
  if ( $isi:testid3 or $isi:testid4 ) then 
  let $page := (
  <form action='/update-site' method='POST'>
  <table>
    <th>{isi:t('website')}</th>
    <tr>
      <td>Valider:</td>
      <td><input type='submit' placeHolder="" value='{isi:t('send')}'></input></td>
    </tr>
    <tr>
      <td>Validation par le MasterAdmin (Si vous activez la validation, seules les fiches validées de la base Web seront accessibles sur le site. Sinon, elles le seront toutes.)</td>
      <td>
        <div class="switch {if (db:open('site')/root/masterAdminValidation='on') then 'on' else 'off'}">
              <input type="checkbox" onClick="location.href='/masterAdminValidation-{if (db:open('site')/root/masterAdminValidation='on') then 'off' else 'on'}';"/>
              <label></label>
        </div>
      </td>
    </tr>
    <tr>
    	<td>masterAdmin password</td>
    	<td><input class="adminInput" name='passwordMA' placeHolder="XXXXX" value=''></input></td>
    </tr>
    <tr>
      <td>{isi:t('website_name')}</td>
      <td>
      <input class="adminInput" name='domaine-name' placeHolder="{$isi:titre-name}" value=''></input>
      </td>
    </tr>
    <tr>
      <td>{isi:t('website_address')}</td>
      <td><input class="adminInput" name='domaine' placeHolder="{$isi:domaine}" value=''></input></td>
    </tr>
    <tr>
      <td>UnoconvDir</td>
      <td><input class="adminInput" name='unoconv' placeHolder="{$isi:unoconv}" value=''></input></td>
    </tr>
    <tr id="#stopGroup">
      <td>
        Ajouter un groupe <a id="plusGerer" style="float:left; margin-right: 5px;" href="#stopGroup" onClick="
                                    document.getElementById('gereGroup').style.display='block';
                                    document.getElementById('moinsGerer').style.display='block';
                                    document.getElementById('plusGerer').style.display='none';
                                    "> [+++] </a>
                           <a href="#stopGroup" style="float:left; display:none; margin-right: 5px;" id="moinsGerer" onClick="	
                                   document.getElementById('gereGroup').style.display='none';
                                   document.getElementById('plusGerer').style.display='block';
                                    document.getElementById('moinsGerer').style.display='none';
                                   "> [---] </a>
      </td>
      <td>
         <input class="adminInput" placeHolder='Entrez le nom du groupe à créer' name='addMasterGroup' value=''></input>
       </td>
    </tr>
     <tr id="gereGroup" style="display:none;">
     {
          for $group in db:open('site')//masterGroups/name[not(.='')] 
            return 
              <td>
                  <a href="#stopGroup" onClick="alert('Utilisateurs: {for $x in db:open('utilisateurs')//entry[./masterGroup/name=data($group)]/name return $x}; ');">Group: {data($group)}</a>
                    <a  class='button' href="/removeGroup-{$group}"> Del </a>
                         <ul class='tabAdminStandar'>
                         <li>Select Active DB for that group</li>
                          <li>
                          <a onClick="
                              document.getElementById('groupDb').value='{$group}';
                              document.getElementById('bddDb').value='bdd';
                              document.getElementById('affectfDb2Group').submit();
                          " 
                              class="{if ($group/@bdd='bdd') then 'baseSelected' else ()}" href="#gereGroup">Standard (Web)</a>
                          </li>
                            {for $x in db:list()[matches(.,'bdd_')] 
                              return 
                              <li>
                              <a onClick="
                                          document.getElementById('groupDb').value='{$group}';
                                          document.getElementById('bddDb').value='{$x}';
                                          document.getElementById('affectfDb2Group').submit();
                                          " class="{if ($group/@bdd=$x) then 'baseSelected' else ()}" href="#gereGroup">{$x}</a>
                                </li>}
                        </ul>
              </td>
       }
    </tr>
    <tr>
      <td id="stop">Base Active (Attention) 
        <a href="#stop"  id="plusAddBase"
           style="float:left; margin-right: 5px;" 
           onClick="
                   document.getElementById('addBase').style.display='block';
                   document.getElementById('moinsAddBase').style.display='block';
                   document.getElementById('plusAddBase').style.display='none';
                    ">[+++]</a>
        <a href="#stop" id="moinsAddBase"
           style="float:left; display:none; margin-right: 5px;" 
           onClick="
                   document.getElementById('addBase').style.display='none';
                   document.getElementById('moinsAddBase').style.display='none';
                   document.getElementById('plusAddBase').style.display='block';
                    ">[---]</a>
      </td>
      <td><input class="adminInput" name='activeBdd' placeHolder="{$isi:bdd}" value=''></input></td>
    </tr>
    <tr id="addBase" style="display:none;">
      <td>{for $x in db:list()[matches(.,'bdd_')] return <p>{$x} <a style="margin:5px;" href="#stop" class="button" onClick="document.getElementById('nomTrash').value = '{$x}';document.getElementById('bddx').submit();">Trash</a></p>}</td>
      <td>New:
      <input class="adminInput" id="nomUn"/><a href="#" onClick="document.getElementById('nomDeux').value = document.getElementById('nomUn').value;document.getElementById('bddc').submit();">Create</a></td>
    </tr>
    <tr>
      <td>TagCloud element you want to archive</td>
      <td>
      <input class="adminInput" name='tagCloud' placeHolder="{$isi:tagCloudXML}" value=''></input>
      </td>
    </tr>
    <tr>
      <td>{isi:t('footer')}</td>
      <td><textarea class="adminInput" size='50' type='textarea' rows='4' placeHolder="{db:open('site')/*:root/*:footer-text/text()}" cols='60' name='footer' ></textarea></td>
    </tr>
     <tr>
      <td>XSD on</td>
      <td>
        <div class="switch {if (db:open('site')/root/dtd='on') then 'on' else 'off'}">
	      <input type="checkbox" onClick="location.href='/dtd-{if (db:open('site')/root/dtd='on') then 'off' else 'on'}';"/>
	      <label></label>
        </div> 
      </td>
    </tr>
    <tr>
      <td>Alphabet</td>
      <td>
        <div class="switch {if (db:open('site')/root/alphabet='on') then 'on' else 'off'}">
	      <input type="checkbox" onClick="location.href='/alphabet-{if (db:open('site')/root/alphabet='on') then 'off' else 'on'}';"/>
	      <label></label>
        </div> 
      </td>
    </tr>
     <tr>
      <td>Forum</td>
      <td>
        <div class="switch {if (db:open('site')/root/forum='on') then 'on' else 'off'}">
	      <input type="checkbox" onClick="location.href='/forum-{if (db:open('site')/root/forum='on') then 'off' else 'on'}';"/>
	      <label></label>
        </div> 
      </td>
    </tr>
    <tr>
    <td>Lien Facebook</td>
    <td><input class="adminInput" name='faceBookIsi' placeHolder='{db:open("site")/root/facebook}' value=''></input></td>
    </tr>
    <tr>
    <td>Lien twitter</td>
    <td><input class="adminInput" name='twitterIsi' placeHolder='{db:open("site")/root/twitter}' value=''></input></td>
    </tr>
    <tr>
    <td>Lien Google Plus</td>
    <td><input class="adminInput" name='googleIsi' placeHolder='{db:open("site")/root/gplus}' value=''></input></td>
    </tr>
     <tr>
      <td>CSS<br/><a href="/cssEdit">Edit your own: first, select 3</a></td>
      <td style='width=25px;'>
      
      { let $dirHard := concat(replace(file:base-dir(),'repo.*',''),"/static/CSS/")
          for $dir at $index in file:list($dirHard)[matches(.,'/')]
           let $css := replace($dir,'/','')
           return
           <div style='float:left ;margin-right:10px' class="switch {if (db:open('site')/root/css=$css) then 'on' else 'off'}">
	          <input type="checkbox" onClick="location.href='/css-{if (db:open('site')/root/css=$css) then '02' else $css}';"/>
	           <label>{$css}</label>
              </div> }    
      </td>
    </tr>
    </table>
    <br/>
    <h2>Web Site Pages Administration and Creation</h2>
    <table>
    <th>Pages -     <a href="/page--">New</a></th>
    <tr><td><a href="/export">Exporter par lots</a></td><td></td></tr>
    {for $i in (db:open('pages')//page) 
     return <tr>

       <td><a 
       href=
       '/page{if (db:open("site")/root/tiny = "on") then "HTML" else ()}-{
       if 
         (db:open("utilisateurs")//entry[.//id=session:id()]/lang) 
       then 
         db:open("utilisateurs")//entry[.//id=session:id()]/lang 
       else "fr" 
       }-{
       if (db:open("utilisateurs")//entry[.//id=session:id()]/lang)
       then 
         $i/name[@lang=db:open("utilisateurs")//entry[.//id=session:id()]/lang]
       else $i/name[@lang='en']}'>{
         if (db:open("utilisateurs")//entry[.//id=session:id()]/lang) 
       then $i/name[@lang=db:open("utilisateurs")//entry[.//id=session:id()]/lang]
       else $i/name[@lang='en']
     }</a></td><td>{let $a := <a href='/deletepage-{$i/name[1]}'>{if ($isi:testLang='fr') then 'Effacer' else 'Delete'}</a> return if($i/name='texteAccueil') then () else $a}</td></tr>
   
    }
    </table><br/><table>
  </table>
  </form>
  , 
  <form style='display:none;' id="bddc" name="bddc" action="/bddCreation" method="POST">
    <input id="nomDeux" class="adminInput" name='nomBase' value=''></input>
    <input type="submit" class="button"/>
  </form>
  , 
  <form style='display:none;' id="bddx" name="bddx" action="/bddTrash" method="POST">
  <input id="nomTrash" class="adminInput" name='nomTrash' value=''></input>
  <input type="submit" class="button"/>
  </form>
  ,
  <form style='display:none;' id="affectfDb2Group" method="POST" action="/db2Group">
  <input type="text" name="groupDb" id="groupDb"/>
  <input type="text" name="bddDb" id="bddDb"/>
  </form>
)
  
  return isi:template($page)
  else isi:template(isi:t('unauthorized_access'))

};

declare
%rest:path('/bddCreation')
   %updating
 %rest:POST
 %rest:form-param("nomBase","{$nomBase}","")
  function isilex:createBdd($nomBase){
     (
    if ($nomBase!=db:list()) then
     (update:output(web:redirect("/gere-site#stop")))
     ,
     (
       db:create('bdd_'||$nomBase, file:base-dir()||'static/root/root.xml')
       ,
       if (not($nomBase='bdd')) 
        then
         replace value of node db:open('site')/root/dtd with 'off'
        else
         replace value of node db:open('site')/root/dtd with 'on'
     )
     )
    else ()
 )
  };

declare
%rest:path('/removeGroup-{$group}')
   %updating
 function isilex:trashgroup($group){
   (update:output(web:redirect("/gere-site#stopGroup"))),
    (for $x in db:open('site')//masterGroups/name[.=$group] return delete node $x
    ,
     for $x in db:open('utilisateurs')//matserGroup/name[.=$group] return replace value of node $x with ''
    )
  )
};

declare
%rest:path('/bddTrash')
   %updating
 %rest:POST
 %rest:form-param("nomTrash","{$nomTrash}","")
  function isilex:trashBdd($nomTrash){
     (
    if ($nomTrash=db:list()) then
     (update:output(web:redirect("/gere-site#stop"))),db:drop($nomTrash))
    else ()
 )
  };
  
declare
%rest:path('/db2Group')
  %updating
 %rest:POST
 %rest:form-param("groupDb","{$group}","")
 %rest:form-param("bddDb","{$bdd}","")
  function isilex:db2Group($group, $bdd){

    update:output(web:redirect("/gere-site#stopGroup"))),
    for $x in db:open('site')/root/masterGroups/name[.=$group] 
      return
        if ($x/@bdd)
         then replace value of node $x/@bdd with $bdd
         else insert node attribute bdd {string($bdd)} into $x
     ,
    for $x in db:open('utilisateurs')//entry[./masterGroup/name=data($group)] 
     return 
      if ($x/bdd) 
        then replace value of node $x/bdd with $bdd
        else insert node <bdd>{$bdd}</bdd> as first into $x
    
  };  
  
declare
%rest:path('/list')
   %output:method("html")
  function isilex:list(){
     (
    
    for $x in (db:list()) return <p>{$x}</p>
 )
  };

declare
 %updating
%rest:path('/switchBdd-{$on}')
 function isilex:switchBdd($on)
 {
   (
   update:output(web:redirect("/rubrique/A/1"))),
   let $activeBdd := if ($on = '1') then 'bdd_isilex' else 'bdd'
   let $dtd := if ($on = '1') then 'off' else 'on'
   return
   (
   replace value of node db:open('site')/root/activeBdd with $activeBdd,
   for $x in db:open('utilisateurs')//entry/bdd[not(./@verrou)] return replace value of node $x with $activeBdd, 
   replace value of node db:open('site')/root/dtd with $dtd
   )
   )
    
 };
 
 declare
  %updating
 %rest:POST
 %rest:form-param('userBddName','{$name}')
 %rest:form-param('baseBddName','{$base}')
%rest:path('/switchBddPerso')
 function isilex:switchBddPerso($name, $base)
 {
   (
    update:output(web:redirect("/gere-users"))),
   for $x in db:open('utilisateurs')//entry[./name=$name]/bdd return replace value of node $x with $base,
   if (not($base='bdd'))
   then
     if (not(db:open('utilisateurs')//entry[./name=$name]/bdd/@verrou)) 
       then 
         for $x in db:open('utilisateurs')//entry[./name=$name]/bdd return insert node attribute verrou {''} into $x 
       else 
         ()
   else
      if ((db:open('utilisateurs')//entry[./name=$name]/bdd/@verrou))
        then
          for $x in db:open('utilisateurs')//entry[./name=$name]/bdd/@verrou return delete node $x
        else 
          ()
  )
 };

 declare
 %updating
 %rest:POST
 %rest:form-param('userMasterGroup','{$name}')
 %rest:form-param('groupMasterGroup','{$group}')
%rest:path('/masterGroupDef')
 function isilex:masterGroupDef($name, $group)
 {
   
    update:output(web:redirect("/gere-users"))),
     for $x in db:open('utilisateurs')//entry[./name=$name]/masterGroup/name 
       return (replace value of node $x with $group), 
      for $x in db:open('utilisateurs')//entry[./name=$name] return replace value of node $x/bdd with data(db:open('site')/root/masterGroups/name[.=$group]/@bdd)
  
 };
 
 declare
 %updating
%rest:path('/switchCss-{$on}')
 function isilex:switchCSs($on)
 {
    (update:output(web:redirect("/"))),
   let $css := if ($on = '02') then '02' else '01'
   return
   replace value of node db:open('site')/root/css with $css)
    
 };
 

declare
 %updating
%rest:path('/update-site')
 %rest:POST
 %rest:form-param("domaine-name","{$domaine-name}","")
 %rest:form-param("domaine","{$domaine}","")
 %rest:form-param("accueil","{$accueil}","")
 %rest:form-param("footer","{$footer}","")
 %rest:form-param("user","{$user}","")
 %rest:form-param("passs","{$passs}","")
 %rest:form-param("unoconv","{$unoconv}","")
 %rest:form-param("activeBdd","{$activeBdd}","")
 %rest:form-param("tagCloud","{$tagCloud}","")
 %rest:form-param("faceBookIsi","{$faceBookIsi}","")
 %rest:form-param("twitterIsi","{$twitterIsi}","")
 %rest:form-param("googleIsi","{$googleIsi}","")
 %rest:form-param("passwordMA","{$passwordMA}","")
 %rest:form-param("addMasterGroup","{$addMasterGroup}","")  
 function isilex:update-site($domaine-name,$domaine,$accueil,$footer,$user,$passs,$unoconv,$activeBdd,$tagCloud,$addMasterGroup,$faceBookIsi,$passwordMA,$twitterIsi,$googleIsi){
   update:output(web:redirect("/gere-site"))),if ($isi:testid4) 
   then (
     if ($domaine-name != '') then replace value of node db:open('site')/root/domaine-name with $domaine-name else (),
     if ($domaine != '') then replace value of node db:open('site')/root/domaine with $domaine else (),
     if ($accueil != '') then replace value of node db:open('site')/root/accueil with $accueil else (),
     if ($footer != '') then replace value of node db:open('site')/root/footer-text with $footer else (),
     if ($unoconv != '') then replace value of node db:open('site')/root/unoconv with $unoconv else (),
     if ($faceBookIsi != '') then replace value of node db:open('site')/root/facebook with $faceBookIsi else (),
     if ($twitterIsi != '') then replace value of node db:open('site')/root/facebook with $twitterIsi else (),
     if ($googleIsi != '') then replace value of node db:open('site')/root/facebook with $googleIsi else (),
     if ($passwordMA != '') then replace value of node db:open('utilisateurs')//entry[./masteradmin='true']/password with crypto:hmac($passwordMA,'isilex','sha512','base64') else (),
     if ($activeBdd != '') then (
         replace value of node db:open('site')/root/activeBdd with $activeBdd, 
         for $x in db:open('utilisateurs')//entry/bdd[not(./@verrou)] return replace value of node $x with $activeBdd
         ) else (),
     if ($tagCloud != '') then replace value of node db:open('site')/root/tagCloud with $tagCloud else (),
     if ($addMasterGroup != '') 
         then 
           if (not(db:open('site')/root/masterGroups/name[.=$addMasterGroup])) 
             then
               insert node <name>{$addMasterGroup}</name> into db:open('site')/root/masterGroups
             else ()
         else ()
  ) 
  else ()
 };

 declare 
 %rest:path('/gere-users')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:gere-users()
  as element(html)
{
  if ( session:id() = db:open('utilisateurs')/utilisateurs/entry[./masteradmin='true']/sessions/session/id ) then 
  let $contenu :=  
   <div id="listeUsers" style="float:left;  width:30%;">
    <table>
     <tr class="userTab">
       <th>Site: Membres</th>
       <th>Site: Admin</th>
       <th>Site: Curator</th>
       <th>Site: User</th>
       {for $x in db:open('site')/root/masterGroups/name return <th>Project Task: {data($x)}</th>}
       <th>Delete</th>
     </tr>
    {
        for $x in 
         db:open('utilisateurs')/utilisateurs/entry[not(masteradmin='true')] 
        return 
        (<tr id="view-{data($x/name)}">
          <td class="userDesc">
          <ul class="tabUserAdmin">
          {
          <li>{data($x/name)}</li>,
          <li>{data($x/mail)}</li>,
          <br/>,
          <a onClick="document.getElementById('displayBases-{data($x/name)}').style.display='block';" class='button' href="#view-{data($x/name)}">DataBases+</a>
          }
          </ul>
          </td>
          <td class="userSelect">
            <div class="switch {if ($x/usertype='admin') then 'on' else 'off'}">
            <input type="checkbox" onClick="location.href='/up-user/{$x/name}/admin';"/>
            <label></label>
            </div> 
          </td>
          <td class="userSelect">
            <div class="switch {if ($x/usertype='curator') then 'on' else 'off'}">
            <input type="checkbox" onClick="location.href='/up-user/{$x/name}/curator';"/>
            <label></label>
            </div> 
          </td>
          <td class="userSelect">
         <div class="switch {if ($x/usertype='user') then 'on' else 'off'}">
	      <input type="checkbox" onClick="location.href='/up-user/{$x/name}/user';"/>
	      <label></label>
        </div> 
          </td>
          {
            for $mgrou in db:open('site')/root/masterGroups/name 
             return
              <td class="userSelect">
                 <div class="switch {if ($x/masterGroup/name=$mgrou) then 'on' else 'off'}">
                  <input type="checkbox" 
                         onClick="
                           document.getElementById('userMasterGroup').value='{data($x/name)}';
                           document.getElementById('groupMasterGroup').value='{$mgrou}';
                           document.getElementById('mgPerso').submit();
                         "/>
                  <label></label>
                </div> 
            </td>
          }
          <td>
           <a href="cancelFiche-user_{$x/name}"><img height="15px" src="./static/images/recycle-bin-icons.png"/></a>
          </td>
          <tr style="display:none;" id='displayBases-{data($x/name)}'>
          <td><a onClick="document.getElementById('displayBases-{data($x/name)}').style.display='none';" class="button" href="#view-{data($x/name)}"> - </a></td><td>Affect Database to {data($x/name)}</td>
          <td><a  class="{if ( db:open('utilisateurs')//entry[./name=data($x/name)]/bdd='bdd') then 'baseSelected' else ()}" 
               onClick="
                       document.getElementById('userBddName').value='{data($x/name)}';
                       document.getElementById('baseBddName').value='bdd';
                       document.getElementById('sPerso').submit();
                       "
              href="#view-{data($x/name)}">Web</a></td>
          {for $bases in db:list()[matches(.,'bdd_')]
             return <td><a  
                       class="{if ( db:open('utilisateurs')//entry[./name=data($x/name)]/bdd=$bases) then 'baseSelected' else ()}" 
                       href="#view-{data($x/name)}"
                       onClick="
                       document.getElementById('userBddName').value='{data($x/name)}';
                       document.getElementById('baseBddName').value='{data($bases)}';
                       document.getElementById('sPerso').submit();
                       "
                       >
                     {$bases}
                     </a></td>
            }</tr>
        </tr>)
      }
    </table>
    <form id="sPerso" name="sPerso" method="Post" action="/switchBddPerso">
    <input type="hidden" value="" name="userBddName" id="userBddName"/>
    <input type="hidden" value="" name="baseBddName" id="baseBddName"/>
     </form>
      <form id="mgPerso" name="mgPerso" method="Post" action="/masterGroupDef">
    <input type="hidden" value="" name="userMasterGroup" id="userMasterGroup"/>
    <input type="hidden" value="" name="groupMasterGroup" id="groupMasterGroup"/>
     </form>
    </div> 
    return 
    isi:template($contenu)

else
isi:template(isi:t('unauthorized_access'))
};

declare
 %updating
%rest:path('/up-user/{$user=.+}/{$rang=.+}')
 function isilex:up-user($user as xs:string*,$rang as xs:string* ) {
   update:output(web:redirect("/gere-users"))),
   if (session:id()= db:open('utilisateurs')/utilisateurs/entry[masteradmin='true']//id and $rang=('user','admin','curator')) then
   for $i in db:open('utilisateurs')/utilisateurs/entry[name=$user]
   return replace value of node $i/usertype with $rang
   else ()
 };
 
 declare
 %updating
%rest:path('/alphabet-{$on}')
 function isilex:up-user($on)
 {
     update:output(web:redirect("/gere-site"))),
     if ($isi:testid4) then
     for $x in db:open('site')/root/alphabet return replace value of node $x with $on
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 
declare
 %updating
 %rest:header-param("Referer", "{$referer}", "none")
%rest:path('/alphabetC-{$on}')
 function isilex:erereer($on, $referer)
 {
     update:output(web:redirect(""||$referer))),
     for $x in db:open('site')/root/alphabet return replace value of node $x with $on

 };
 
 declare
 %updating
%rest:path('/tiny-{$on}')
 function isilex:up-tiny($on)
 {
     update:output(web:redirect("/gere-site"))),
     if ($isi:testid4) then
     for $x in db:open('site')/root/tiny return replace value of node $x with $on
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 
  declare
 %updating
%rest:path('/forum-{$on}')
 function isilex:up-forum($on)
 {
     update:output(web:redirect("/gere-site"))),
     if ($isi:testid4) then
     for $x in db:open('site')/root/forum return replace value of node $x with $on
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 
  declare
 %updating
%rest:path('/masterAdminValidation-{$on}')
 function isilex:mAV($on)
 {
     update:output(web:redirect("/gere-site"))),
     if ($isi:testid4) then
     for $x in db:open('site')/root/masterAdminValidation return replace value of node $x with $on
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 
declare
 %updating
%rest:path('/dtd-{$on}')
 function isilex:up-dtd($on)
 {
     update:output(web:redirect("/gere-site"))),
     if ($isi:testid4) then
     for $x in db:open('site')/root/dtd return replace value of node $x with $on
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 

declare
 %updating
%rest:path('/cancelFiche-user_{$user}')
 function isilex:eraseUser($user)
 {
     update:output(web:redirect("/gere-users"))),
     if ($isi:testid4) then
     for $x in db:open('utilisateurs')//entry[name=$user] return delete node $x
     else db:output(isi:template(isi:t('unauthorized_access')))
 };
 
 
declare
 %updating
%rest:path('/css-{$num}')
 function isilex:cssChange($num)
{ if ($isi:testid4) then(
       update:output(web:redirect("/gere-site"))),
     for $x in db:open('site')/root/css return replace value of node $x with $num)
     else db:output(isi:template(isi:t('unauthorized_access')))
};
 

declare
%rest:path('masteradmin')
%output:method('html')
function isilex:ma(){
  if (db:open('utilisateurs')//masteradmin='true')
  then
  (web:redirect("/"))
  else
  let $c :=
  <form method='POST' action='maup'>
  <table>
  <tr><td><h1>Master admin configuration</h1></td><td/></tr>
  <tr><td>Username</td><td> <input class="adminInput" type='text' name='username' placeholder="admin User Name"></input></td></tr>
  <tr><td>Email </td><td><input class="adminInput" name='mail' placeholder="admin's mail"></input></td></tr>
  <tr><td>Password </td><td><input class="adminInput" name='pass' type='password' placeholder="Password"></input></td></tr>
  <tr><td>Password again</td><td> <input class="adminInput" name='pass2' type='password' placeholder="Retype your passaword"></input></td></tr>
  <tr><td>Key</td><td> <input class="adminInput" name='key' type='password' placeholder="IsilexKey"></input></td></tr>
  <tr><td></td><td><input type='submit'></input></td></tr>
</table>
  </form>
  return isi:template($c)
};

declare
%updating
%rest:path('maup')
%output:method('html')
%rest:POST
%rest:form-param('username','{$username}','')
%rest:form-param('pass','{$pass}','')
%rest:form-param('pass2','{$pass2}','')
%rest:form-param('key','{$key}','')
%rest:form-param('mail','{$mail}','')
function isilex:maup($username,$pass,$key,$mail,$pass2){
  if($username!='' and $pass != '' and $key != '' and $mail != '' and $pass=$pass2 and not (db:open('utilisateurs')//masteradmin='true'))
  then 
    if(crypto:hmac($key,'isilex','sha512','base64')= db:open('site')/root/key and not (db:open('utilisateurs')//masteradmin='true'))
    then (insert node
    <entry><masteradmin>true</masteradmin><lang>en</lang><name>{$username}</name><mail>{$mail}</mail><password>{crypto:hmac($pass,'isilex','sha512','base64')}</password><usertype>administrator</usertype><sessions><session><id>{session:id()}</id><timeStamp>{current-dateTime()}</timeStamp></session></sessions></entry>
    as first into db:open('utilisateurs')/*,
    update:output(web:redirect("/info?message=MasterAdminActivated")))
  )
    else db:output('Forbidden access')
  else db:output('Forbidden access')
};

