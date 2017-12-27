module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';
import module namespace request = "http://exquery.org/ns/request";

declare 
 %rest:path('/problemeXML-{$id}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:XMLProblem($id)
  as element(html)
  {
    isi:template(
     <html>
      <h2>Problème de validation XML</h2>
      <p>Un problème est survenu dans votre saisie. Revenez en arrière pour sauvegarder votre fiche.</p>
     </html>
  )
  };
  
declare 
 %rest:path('xsdOk-{$id}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:xsdOk($id)
  as element(html)
  {
    isi:template(
     <html>
      <h2>La Fiche ne présente aucun problème et a été sauvée</h2>
      <p><a href="#" onClick="window.close()">Fermer la fenêtre</a></p>
     </html>
  )
  };

declare 
 %rest:path('/error400')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:error400()
  as element(html)
  {
    isi:template(
      <div>
      <h2>Erreur 400</h2>
      <p>Un problème est survenu sur le système</p>
      <p>{"URL: " || request:attribute("javax.servlet.error.request_uri") || ", " || 
          "Error message: " || request:attribute("javax.servlet.error.message")}</p>
      </div>
    )
  };
  
  declare 
 %rest:path('/error404')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:error404()
  as element(html)
  {
    isi:template(
      <div>
      <h2>Erreur 404</h2>
      <p>La page demandée n'existe pas sur le système. <a href="/accueil">Revenir</a></p>
      <p></p>
      </div>
    )
  };
  
  