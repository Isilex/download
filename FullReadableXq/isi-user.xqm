(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
%rest:path("/user/{$path=.+}")
%output:method("html")
 function isilex:user-page($path){
   if (session:id() = db:open('utilisateurs')/utilisateurs/entry[name=$path]/sessions/session/id)
   then
     let $contenu :=(
       <h2>Vos fiches</h2>,
       <l>{for $i in distinct-values(db:open($isi:bdd)
       return <li class="maListeDeFiches"><a href='/fiche/{$i}'>{upper-case($i)}</a></li>}</l>
     )
     return
     isi:template($contenu)
   else isi:template(isi:t('unauthorized_access'))
 };