module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare 
 %rest:path('/page/{$path=.+}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:pagep($path)
  as element(html)
{    
  let $contenu :=
  (db:open('pages'))/root/page[name=$path or id=$path]/div[@lang=$isi:testLang]
  return
isi:template(
	(
				if ($isi:testid4 or $isi:testid3) then <a class='button' href="/page{if (db:open('site')/root/alphabet='on') then 'HTML' else ()}-{$isi:testLang}-{$path}"><img class='zoom' width='30px' src='/static/images/svg/writing.svg'/></a> else ()
,
		$contenu
		)
)
};

declare
%rest:path('/modifpage/{$path=.+}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:modif-page($path)
  as element(html)
{
  if($isi:testid2) then
  
 let $contenu :=(
 if ($path='new')then
 <form method='post' action='/up-page' >
  <textarea name='contenu'></textarea> 
  <input type='submit' value='{isi:t('send')}' />
  </form> 
  else(), 
  for $i in db:open('site')/*/page[(name,id)=$path]
  return 
  <form method='post' action='/up-page' enctype="multipart/form-data">
  <textarea name='contenu' value='{$i/div/text()}'>{$i/div}</textarea> 
  <input type='submit' value='{isi:t('send')}' />
  </form>
)
  
return

isi:template($contenu)  

else isi:template(isi:t('unauthorized_access'))
};

declare
 %updating
 %rest:POST
 %rest:query-param('contenu','{$contenu}','')
 %rest:path('up-page')
 function isilex:up-page($contenu){
   if ($isi:testid2) then
   insert node <page><auteur>{db:open('utilisateurs')//entry[.//id=session:id()]/name/text()}</auteur><name></name><id></id><div>{$contenu}</div></page> into
   db:open('pages')/root
   else (),
   update:output(web:redirect("/"||$contenu)))
 };