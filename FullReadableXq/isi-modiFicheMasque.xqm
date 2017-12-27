module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
%output:method('html')
%rest:GET
%rest:form-param("message","{$message}","")
%rest:path('/modifCh/{$fiche=.+}')
function isilex:modifCh ($fiche,$message)
{
   if ($isi:testid2) then
   <html>
    <head>
      <title>{$isi:titre-name}</title>
      <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
      <script src="http://cdnjs.cloudflare.com/ajax/libs/codemirror/3.19.0/codemirror.js"></script>
      <script>
        <!-- Contenu du champ du masque vers l attribut du xml, NON UTILISÉ -->
        function champToXmlA()&#x0007B;
          var id = document.activeElement.getAttribute("n");
          var newff = document.activeElement.value;
          var att = document.activeElement.getAttribute("name");
          document.getElementById(id).setAttribute(att,newff);
          &#x0007D;
      </script>
      {db:open('scripts')//entry[./@id="headerIsiPhp"]/header/*} 
      {$isi:Css}
      
      <script>{db:open('scripts')//entry[./@id="masqueCh"]/text()}</script>
      {  if ($message != "")
         then
           <script>alert("Votre fiche a bien été sauvée");</script>
         else ()
      }
      <script>
        var cp =0; 
{  
db:open("scripts","scripts.xml")/root/entry[1]/header/script[last()]/text()

}
</script>


<script> 

  <!-- NON UTILISÉ Entoure de rouge le xml correspondant au champ -->

  function actu() &#x0007B;
    var nom = this.getAttribute('name')&#x0003B;
    var id = this.getAttribute('n')&#x0003B;
    document.getElementById(id).style.border='8px solid red'&#x0003B;
  &#x0007D;
  
  <!-- NON UTILISÉ efface le champ et le xml correspondant -->
                 
  function clearCh(th)&#x0007B;
    var d = th; 
    id = d.getAttribute("n");
    var target = document.getElementById(id);
    var t = d.parentNode.previousElementSibling;
    t.children[0].value='';
    target.innerHTML = ''; 
  &#x0007D;
</script>

<!-- INDISPENSABLE Mets des ID dans les nouveaux champs et les nouveaux noeuds xml -->
<script src="/static/scripts/masque.js"></script>

{
  (:
    Génération des champs vides du masque et les noeuds xml vides
  :)
  isi:fic_to_masque_blank_all2(),
  isi:xmlblankall()
}

  </head>
  
  <body onLoad="actuChamps();">
 
  {$isi:ruler}
  
   <div id="global" class="protect">
   
     <!-- Masque -->
     <div id="xmlMasque">
       <div id="tableau">
       
         <!--INDISPENSABLE Bouton pour sauver la fiche  --> 
         <div id="sauver" style="display:none;">
           <a class="button" href="#" onClick="var el = $('#controle');el.find('[style]').removeAttr('style');var el = $('#controle');el.find('[id]').removeAttr('id');document.getElementById('validFiche').value = 'false';champsBase();">Save</a>
           {
           if (db:open('site')/root/masterAdminValidation='on') 
           then
           <a class="button" href="#" onClick="var el = $('#controle');el.find('[style]').removeAttr('style');var el = $('#controle');el.find('[id]').removeAttr('id');document.getElementById('validFiche').value = 'ask';champsBase();">Save and validate</a>
           else ()
           }
         </div>
         
         {
         (:  Génration des champs à partir de la fiche  :)
         isi:fic_to_masque(db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry,())}
         
       </div>
     </div>

     <!-- XML -->
     <div id="controle">
       { (:Génération du XML à partir de la fiche:)
       isi:fic_to_template(db:open($isi:bdd)/*/fiche[id=$fiche or (some $or in entry/form/orth satisfies upper-case($fiche)=upper-case($or))]/entry,())}
     </div>
     
     <!-- Formulaire: la fiche en  XML, l ID de la fiche, la BDD de la fiche, son statut de validation à false par défaut TODO: donner le choix -->
     <form id="valid" name="valid" method="POST" action="/saveFiche">
        <input type="hidden" id="inputFiche" name="inputFiche" value=""/>
        <input type="hidden" id="idFiche" name="idFiche" value="{$fiche}"></input>
        <input type="hidden" id="bddId" name="bddId" value="{$isi:bdd}"></input>
        <input type="hidden" id="validFiche" name="validFiche" value="false"></input>
     </form>
     
     <div id="pg" style="display:none;"></div>
     
   </div>
   {db:open('scripts')//entry[./@id="codeMirrorStart"]/script}
   </body>
   </html>
   
   (:
   Sinon accès refusé
   :)
   else isi:template(isi:t('unauthorized_access'))
};
