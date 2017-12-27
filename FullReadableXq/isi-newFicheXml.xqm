module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare 
 %rest:path('/newFicheXml')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:newFicheXml()
  as element(html)
{
   
 if ($isi:testid2)
 then
 <html>
   <head>
     <title>{$isi:titre-name}</title>
     {db:open('scripts')//entry[./@id="headerIsiPhp"]/header}
       
     {$isi:Css}
   </head>
  <body onLoad="getInnerHtml();" style='background-color:white;'>  
    {$isi:ruler}  
   <div id="panelImgBottom">
    <div id="upPanImg" class="panLabelBottom" style="display:none;" 
    	 onClick="document.getElementById('panelImgBottom').style.bottom = '';
    	 		  document.getElementById('downPanImg').style.display = '';
    	 ">Img Up</div>
   <div id="downPanImg" class="panLabelBottom" 
   		onClick="document.getElementById('panelImgBottom').style.bottom = '-65px';
   				 document.getElementById('upPanImg').style.display = 'block';
   				 document.getElementById('downPanImg').style.display = 'none'; ">
   		X</div>
    {
    let $contenu := for $x in db:open("tei_fiche_exemple")/root/entry return $x
    return
    if ($contenu//ref contains text 'http://' or $contenu//mentioned contains text 'http://' ) 
      	then 
      	 for $x in ($contenu//ref, $contenu//mentioned)
      		let $http:= analyze-string(string($x),'http://[^ ]*')//fn:match
      		for $h in $http return
      		<a  href='{($h//text())}' 
      			target="viewerMod" 
      			onClick="document.getElementById('viewerMod').height='200px'"
      			onMouseOut="document.getElementById('viewerMod').height='0px'">
      			<img src="/static/images/fold.jpeg" height="80px"/>
      		</a>
      	else ()}
      	<iframe id="viewerMod"
      			frameborder="0" 
   				border="0" 
      			cellspacing="0" 
      			seamless="seamless" 
      			scrolling="no"
      			height="1px" />
      	</div>
      	
      	
    <div id="global" class="protect">
    

   <div id="content">{for $x in db:open("tei_fiche_exemple")/root/entry return $x}</div>
   
   <div id="xml">
         <textarea id="txtdef"
                   name="txtDef" 
                   width="250px" 
                   height="40px;">
        {
        
           (for $x in db:open("tei_fiche_exemple")/root/entry return $x)
         
        }
         </textarea>
  </div>
   {
   
   <div>
     <div id="controle">
     </div>
  </div>
   
  }

   </div> 
   
   <div id="paddleXml">  
    <form id="valid" name="valid" method="POST"  action="/saveNew">
      <input type="hidden" id="inputFiche" name="inputFiche" value=""/>
      <input type="hidden" id="validFiche" name="validFiche" value="false"/>
    </form>

    <div id="menuEdit">
    <p id="indice" class="help">Menu Validation:</p>
     <a id='clickX' style="position: absolute; margin-top:-30px; margin-left: -10px; margin-bottom: 20px; display:none;" class="clickxon" href="#" 
           onclick="
                         document.getElementById('renvoidtd').style.display = 'block';
                         document.getElementById('menuEdit').style.marginTop = '0px';
                         document.getElementById('clickX').style.display = 'none';
                         document.getElementById('XClick').style.display = 'block';
     ">&#8595;</a>
           {if (($isi:systemV='on')) 
           then (db:open('scripts')//entry[./@id="boutonMenu"])/div 
           else (db:open('scripts')//entry[./@id="boutonMenuMasterAdmminValidOff"])/div}   
           {db:open('scripts')//entry[./@id="boutonInsertion"]/div}
     <div id="boutons" style="clear:both; padding-top: 15px;">
    <input type='button' onClick='location.href="/modifCh-"' value="Modifier en Masque" onMouseOver="document.getElementById('indice').innerHTML='Accéder au masque de saisie'"/>
    <input type='button' onClick='location.href="/ftMark-"' value="ftMark: {data(for $x in db:open('tei_fiche_exemple')/root/entry return $x//orth)}.*" onMouseOver="document.getElementById('indice').innerHTML='Identifier le mot dans la fiche'"/>
    </div>
    </div>
    {db:open('scripts')//entry[./@id="codeMirrorStart"]/script}
   </div>
  </body>
  </html>
else isi:template(isi:t('unauthorized_access'))}
  ;