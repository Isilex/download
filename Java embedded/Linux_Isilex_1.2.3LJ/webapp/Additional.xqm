module namespace isilex = 'http://www.isilex.fr'; import module namespace session = "http://basex.org/modules/session"; import module namespace sessions = "http://basex.org/modules/sessions"; import module namespace request = "http://exquery.org/ns/request"; import module namespace isi = 'http://www.isilex.fr/isi-repo';
(:Ce fichier est un exemple de développement facile d'URL en R/X (Rest Xquery:)
declare
 %rest:path(
  '/idefx'
)
 %output:method(
  'html'
)
 %rest:POST
  %rest:form-param(
  'idefx',"{
    $idefx
  }"
)
 function isilex:idefx(
  $idefx
)
 {
 isi:template(
   <div>
  {
  	for $x score $y 
  	 in db:open('bdd')//fiche
  	 [./entry//*[. contains text {$idefx} all words using stemming]] 
  	   order by $y descending 
  	    return 
  	     <p>
  	      <a href="/fiche/{$x/id}">{$x/entry/form/orth/text()}</a>
  	      : {ft:extract($x/entry[1]//*/text()[. contains text {$idefx} all words using stemming],'mark',50)}
  	    </p>
  }
        </div>
)
          
};