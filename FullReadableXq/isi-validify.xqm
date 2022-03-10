(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';


declare
 %updating
 %rest:path('/validFiche/{$bddAsk}/{$fiche=.+}')
 function isilex:validTrue($fiche,$bddAsk){
   update:output(web:redirect("/valid/"||$bddAsk||"/1"))),
   if (
     exists(db:open($bddAsk)
   ) 
   then
     replace value of node db:open($bddAsk)
   else ()
 };



declare
 %updating
 %rest:path('/cancelFiche/{$bddAsk}/{$fiche=.+}')
 function isilex:cancelFiche($fiche,$bddAsk){
   if ($isi:testid3) 
   then 
     if (matches($fiche,'user_') ) 
     then(
       update:output(web:redirect("/valid/"||$bddAsk||"/1"))),
       delete node db:open('utilisateurs')/utilisateurs/entry[not(masteradmin='true')][./name=replace($fiche,'user_','')])
     else(
       update:output(web:redirect("/valid/"||$bddAsk||"/1"))),
       delete node db:open($bddAsk)
     )
   else db:output(isi:template(isi:t('unauthorized_access')))
 };


declare
 %rest:path('/valid/{$bddAsk}/{$fiche=.+}')
 %output:method('html') 
 function isilex:valid($fiche,$bddAsk){
   if ($isi:testid3) then
  <html>
  <head>
  {db:open('scripts')//entry[./@id="headerIsiPhp"]/header,
  $isi:Css}
  </head>
  
  <body onLoad="getInnerHtml();">
   {$isi:ruler}
  <div id="top">Admin</div>
   {$isi:menuGauche}
    <div id="texteAccueil">
      <h2>Gestion des demandes de validation</h2>
      <div id="panelImgBottom">
      <div id="upPanImg" 
           class="panLabelBottom" 
           style="display:none;" 
           onClick="document.getElementById('panelImgBottom').style.bottom = '';
                    document.getElementById('downPanImg').style.display = '';
        ">
        Img Up
      </div>
      <div id="downPanImg" class="panLabelBottom" 
           onClick="document.getElementById('panelImgBottom').style.bottom = '-65px';
                    document.getElementById('upPanImg').style.display = 'block';
                    document.getElementById('downPanImg').style.display = 'none'; ">
        X
      </div>
     {
      let $contenu := 
        for $x in db:open($isi:bdd)
        return $x
      return
        if (
          $contenu//note
        ) 
        then 
          for $x in ($contenu//@src, $contenu//@href)
          let $http:= analyze-string(string($x),'http://[^ ]*')//fn:match
            for $h in $http 
            return
              <a  href='{($h//text())}' 
                  target="viewerMod" 
                  onClick="document.getElementById('viewerMod').height='200px'"
                  onMouseOut="document.getElementById('viewerMod').height='0px'">
                <img src="/static/images/fold.jpeg" 
                     height="80px"/>
              </a>
        else ()
      }
      <iframe id="viewerMod"
              frameborder="0" 
              border="0" 
              cellspacing="0" 
              seamless="seamless" 
              scrolling="no"
              height="1px" />
    </div>
    <p>
      <a  class='button' style="margin-left:5px;" href="/valid/bdd/2">Web Base</a>
      {
        for $x in db:list()[matches(.,'bdd_')]
        return <a class='button' style="margin-left:5px;" href="/valid/{$x}/1">{data($x)} {count(db:open(data($x))//valid[.='ask'])}</a>
      }
    </p>
    <div id="listeDesMots">{
      if (
        for $fiches in db:open($bddAsk)
        return $fiches
      ) 
      then
        <ul>{
          for $fiches in db:open($bddAsk)
          return 
            <li style="display:block; clear:both;">
              <a class='button' href="/valid/{$bddAsk}/{$fiches/id}" style=" float:left; margin-right: 3px; width: 80px;">{
                data(($fiches//orth)[1]),$fiches//valid
              }</a>
              <div id="boutonsValid">
                <a href="/modif-{$fiches/id}"><img height="15px" src="/static/images/TheStructorr_magnifying_glass_2.png"/></a>
                <a href="/validFiche/{$bddAsk}/{$fiches/id}"><img height="15px" src="/static/images/check-icon.png"/></a>
                <a href="/cancelFiche/{$bddAsk}/{$fiches/id}"><img height="15px" src="/static/images/recycle-bin-icons.png"/></a>
              </div>
            </li>
        }</ul>
      else "Liste: Rien à Valider"
    }</div>
    <div id="controleXml">{
        if (db:open($bddAsk)
          then for $x in db:open($bddAsk)
          else "XML: Rien à afficher"
    }</div>
  </div>
  </body>
  </html>
  else isi:template(isi:t('unauthorized_access'))
 };