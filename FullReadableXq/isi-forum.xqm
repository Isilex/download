module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare 
 %rest:path('/forum')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:forum()
{
  let $contenu :=(
    
  )
    
  return isi:template($contenu)
    
};

declare 
 %rest:path('/forum/{$id}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:forumid($id)
{
  let $contenu :=(
        if ($isi:testidname=db:open('utilisateurs')//name)
        then
          <div id="commFiches">
            <script src='/static/tinymce/tinymce.min.js'></script>
            <script>
              tinymce.init(&#x0007B;
              selector: '#areaForum',
              plugins: ["code",
                        "preview save insertdatetime media table contextmenu paste imagetools", 
                        "advlist autolink lists link image charmap print preview anchor",
                        "searchreplace visualblocks code fullscreen"],
              toolbar: "save undo redo preview | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image code",
              images_upload_base_path: '/static/images',
              automatic_uploads: true,
              width: 600,
              height: 300,
              content_css: [{
                let $dirHard := 
                  concat(
                    replace(file:base-dir(),'repo.*',''),
                    "/static/CSS/",
                    db:open('site')/root/css/text(),"/")
                for $x in file:list($dirHard)[matches(.,'.css')] 
                return ("'/static/CSS/04/"||replace($x,'%20','')||"',")
                }
                'static/CSS/04/system.css'
              ],
              extended_valid_elements: 'page, name[lang], div[lang], a[href|target=_blank],strong/b,div[align],br'   
              &#x0007D;
              );
            </script>
            <h2>Forum</h2>
            <form id="postForm" method="post" action="/saveMess">
              <p>
                <textarea id="areaTitreForum" 
                          name="messTitre" 
                          placeHOlder="Your title on {(db:open($isi:bdd)/*/fiche/entry/form/orth)[1]}..." />
              </p>
              <p>
                <textarea id="areaForum" 
                          name="messText" 
                          placeHOlder="Your comment on {db:open($isi:bdd)/*/fiche/entry/form/orth}..." />
              </p>
              <input type="hidden" name="messBdd" value="{$isi:bdd}"/>
              <input type="hidden" name="messId" value="{$id}"/>
              <input type="hidden" name="messAuthor" value="{$isi:testidname}"/>
            </form>
            {
              for $x in db:open('forum')/bdd/entry[bddId=$id] 
              return 
                <div id="messageOnForum">
                  <ul class="tabUserAdmin">
                    <li>De: {data($x/from)}</li>
                    <li>({replace(data($x/date),'T.*','')} à {replace(data($x/date),'.*T(.....).*','$1')})</li>
                    <li id="titre">Titre: {data($x/titre)}</li>
                    <li>{html:parse(string($x/text), map { 'nons': true() })}</li>
                    {
                      for $answer in $x//answer 
                      return
                        <div id="forumAnswer">
                          <ul class="tabUserAdmin">
                            <li>De: {data($answer/auteur)}</li>
                            <li>({replace(data($answer/date),'T.*','')} à {replace(data($answer/date),'.*T(.....).*','$1')})</li>
                            <li>{html:parse(string($answer/mess), map { 'nons': true() })}</li>
                          </ul>
                        </div>
                    ,
                      if ($isi:testid3 or $isi:testid4 or $isi:testidname=db:open($isi:bdd)/*/fiche[id=$id]/auteur) 
                      then <a class="button" href="/forumEffacer-{data($x/@id)}">Effacer</a> 
                      else ()
                    ,
                      if ($isi:testid2 or $isi:testid3 or $isi:testid4) 
                      then (
                        <a class="button" onClick="document.getElementById('answer{data($x/@id)}').style.display='block'">Répondre</a> 
                        ,
                        <form id="answer{data($x/@id)}" style="display:none;" method="post" action="/forumAnswer-{data($x/@id)}">
                          <textarea name="forumanswer" id="areaForum">coucou</textarea>
                          <input type="hidden" name="auteur" value="{$isi:testidname}"/>
                          <input type="hidden" name="orig" value="{$id}"/>
                          <p><input class="button" type="submit" value="OK"/></p>
                        </form>
                      )
                      else ()}
                  </ul>
                </div>
            }
          </div>
        else 
          <p id="commFiches">
            <h2>Commenter la Fiche</h2>
            <a class="button" href="/login">Connect for forum</a>
            {
              for $x in db:open('forum')/bdd/entry[bddId=$id] 
              return 
                <div id="messageOnForum">
                  <ul class="tabUserAdmin">
                    <li>De: {data($x/from)}</li>
                    <li>({replace(data($x/date),'T.*','')} à {replace(data($x/date),'.*T(.....).*','$1')})</li>
                    <li>Titre: {data($x/titre)}</li>
                    <li>{html:parse(string($x/text), map { 'nons': true() })}</li>
                    {
                        for $answer in $x//answer 
                        return
                          <div id="forumAnswer">
                            <ul class="tabUserAdmin">
                              <li>De: {data($answer/auteur)}</li>
                              <li>({replace(data($answer/date),'T.*','')} à {replace(data($answer/date),'.*T(.....).*','$1')})</li>
                              <li>{html:parse(string($answer/mess), map { 'nons': true() })}</li>
                            </ul>
                          </div>
                    }
                  </ul>
                </div>
            }
          </p>
  )
    
  return isi:template($contenu)
    
};

declare
 %updating
 %rest:header-param("Referer", "{$referer}", "none")
%rest:path("/forumEffacer-{$baseId}")
 function isilex:forumEffacer($baseId, $referer){
 (
    db:output(<rest:redirect>{$referer}</rest:redirect>),
    for $x in db:open('forum')//entry[@id=$baseId] return delete node $x   
 )
 };
 
declare  
%updating
%rest:path("/forumAnswer-{$baseId}")
 %rest:POST
 %rest:header-param("Referer", "{$referer}", "none")
 %rest:query-param('forumanswer','{$texte}','')
  %rest:query-param('auteur','{$auteur}','')
  %rest:query-param('orig','{$orig}','')
 function isilex:forumAnswer($baseId, $texte, $auteur, $orig, $referer){
 (
 db:output(<rest:redirect>{$referer}</rest:redirect>),
    for $x in db:open('forum')//entry[@id=$baseId] 
    	return insert node 
    		<answer>
    			<date>{fn:current-dateTime()}</date>
    			<auteur>{$auteur}</auteur>
    			<mess>{$texte}</mess>
    		</answer>
    		into $x
    		)
 };
 
 
 declare
 %updating
%rest:path("/saveMess")
 %rest:POST
 %rest:query-param('messText','{$messText}','')
 %rest:query-param('messBdd','{$messBdd}','')
 %rest:query-param('messId','{$messId}','')
 %rest:query-param('messAuthor','{$messAuthor}','')
 %rest:query-param('messTitre','{$messTitre}','')
 function isilex:saveMess($messText,$messId,$messBdd,$messAuthor,$messTitre){
  (
    db:output(<rest:redirect>/fiche/{$messId}</rest:redirect>),
    let $target := 
  <entry id="{
    if ((for $x in db:open('forum')//@id order by number($x) descending return number($x))[1]=1) then (for $x in db:open('forum')//@id order by number($x) descending return number($x))[1] + 1 else 1
  }">
    <bddName>{$messBdd}</bddName>
    <bddId>{$messId}</bddId>
    <from>{$messAuthor}</from>
    <date>{fn:current-dateTime()}</date>
    <titre>{$messTitre}</titre>
    <text>{html:parse(normalize-space($messText), map { 'nons': true() })}</text>
  </entry>
  return insert node $target into db:open('forum')/bdd)
 };