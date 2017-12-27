module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
 %rest:path('/modif-{$fiche=.+}')
 %rest:header-param("Referer", "{$referer}", "none")
 %rest:GET
 %rest:query-param("message","{$message}","")
 %output:method('html')
 function isilex:modiftyty($fiche,$referer,$message){
 if ($isi:testid2)
  then  
   if (($isi:systemV='on' and db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/valid != 'ask') or $isi:systemV='off')
     then
     <html>
       <head>
         <title>{$isi:titre-name}</title>
         {db:open('scripts')//entry[./@id="headerIsiPhp"]/header}
        <script>$(document).ready({  if ($message = "")
         then ()
         else
           "function()&#x0007B;alert('Votre fiche a bien été sauvée')&#x003B;&#x0007D;"
         
         })</script>
         {$isi:Css}
       </head>
       <body onLoad='getInnerHtml();' style='background-color:white;'>  
         {$isi:ruler}  
         <div id='renvoidtd'>
           <a class='clickx' href="#" onclick="
                             document.getElementById('renvoidtd').style.display = 'none';
                             document.getElementById('clickX').style.display = 'block';
         ">X</a>        Renvoi XSD: 
         {
         isi:validXMLById($fiche)
         }
         {
           if (matches($referer,'modif-'||$fiche)) then '  Travail enregistré !' else ''
         }
         </div>
         <div id="panelImgBottom">
           <div id="upPanImg" 
                class="panLabelBottom" 
                style="display:none;" 
                onClick="document.getElementById('panelImgBottom').style.bottom = '';
                         document.getElementById('downPanImg').style.display = '';
                         ">
           Img Up
           </div>
           <div id="downPanImg" 
                class="panLabelBottom" 
                onClick="document.getElementById('panelImgBottom').style.bottom = '-65px';
                         document.getElementById('upPanImg').style.display = 'block';
                         document.getElementById('downPanImg').style.display = 'none';
                         ">
           XXX
           </div>
          {
          let $contenu := 
            for $x in db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry 
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
      <div id="global" 
           class="protect"
           >
        <div id="content">{
          for $x in db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry 
          return $x
        }</div>   
            
        <div id="xml">
          <textarea id="txtdef"
                    name="txtDef" 
                    width="250px" 
                    height="40px;"
                    >
            {
               for $x in db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry 
               return $x
            }
          </textarea>
        </div>
       {
         if ($fiche != "xsd")
         then
           
             <div id="controle"></div>
           
     else 
       <a style="display:block; clear:both;" href="javascript:history.back()">
         <img id="mesBoutons" 
              src="/static/images/vers-avant-icone-3791-64.png"  
              width="40px"
         />
       </a>
   }
  </div> 
   
  <div id="paddleXml">  
  <!--  onsubmit="window.open('', 'formpopup', 'width=900,height=400,resizeable = false,scrollbars');target_popup(this);" -->

    <form id="valid" name="valid" method="POST" target="formpopup" action="/saveFiche">
      <input type="hidden" id="inputFiche" name="inputFiche" value=""/>
      <input type="hidden" id="idFiche" name="idFiche" value="{$fiche}"/>
      <input type="hidden" id="validFiche" name="validFiche" value="false"/>
    </form>
    <div id="menuEdit">
      <p id="indice" class="help">Info</p>      
       <a id='clickX' 
          style="position: absolute; margin-top:-30px; margin-left: -10px; margin-bottom: 20px; display:none;" 
          class="clickxon" 
          href="#" 
          onclick="
                   document.getElementById('renvoidtd').style.display = 'block';
                   document.getElementById('menuEdit').style.marginTop = '0px';
                   document.getElementById('clickX').style.display = 'none';
                   document.getElementById('XClick').style.display = 'block';
                   ">
       &#8595;
       </a>
       {
         if (($isi:systemV='on')) 
           then (db:open('scripts')//entry[./@id="boutonMenu"])/div 
           else (db:open('scripts')//entry[./@id="boutonMenuMasterAdmminValidOff"])/div
           ,
         db:open('scripts')//entry[./@id="boutonInsertion"]/div
       }
       <div id="boutonsBas" class='sample'>
         <input type='button' 
                onClick='location.href="/modifCh/{$fiche}"' 
                value="Modifier en Masque" 
                onMouseOver="document.getElementById('indice').innerHTML='Accéder au masque de saisie'"
                />
         <input type='button' 
                onClick='location.href="/ftMark-{$fiche}"' 
                value="ftMark: {(db:open($isi:bdd)//fiche[./id=$fiche]/entry//orth)[1]}.*"
                onMouseOver="document.getElementById('indice').innerHTML='Identifier le mot dans la fiche'"/>
       </div>
       {
         if (db:open('messages')//entry[matches(./subject,$fiche,'i')]) 
         then 
           let $ort := data(for $x in db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry return $x/orth)
           return
             <div>{
               for $mess in db:open('messages')//entry[matches(./subject,$ort,'i')]
               return 
               <p>{
                 data($mess/@from)} : {data($mess/message)}, le {data($mess/date)
               }</p>
             }</div>
         else ()
       }
     </div>
     {db:open('scripts')//entry[./@id="codeMirrorStart"]/script}
   </div>
 </body>
</html>
 (:la fiche est 'ask for validation' et le site est sur 'masterValidAdmin' On:)
 else isi:template(
   <div><h2>Page de redirection</h2>
   <p>Vous arrivez sur cette page parce qu'il semblerait que votre site utilise la Validation des données par le Master Admin et que vous avez demandé une fiche qui est en attente de validation. Il faut attendre la validation pour poursuivre le travail. <a href="/accueil">Revenir</a></p>
   </div>
 )
else isi:template(isi:t('unauthorized_access'))
};