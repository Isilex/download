module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';


declare
 %rest:path('/pageHTML-{$lg=.*}-{$idPage=.*}')
 %output:method('html')
 function isilex:modpaTiny($lg, $idPage)
 {isi:template(
  <div>
   <script src='/static/tinymce/tinymce.min.js'></script>
   	<script>
  		tinymce.init(&#x0007B;
   		selector: '#txtdef',
plugins: ["code", "jbimages preview save insertdatetime media table contextmenu paste imagetools", "advlist autolink lists link image charmap print preview anchor",
"searchreplace visualblocks code fullscreen"],
toolbar: " link image code | save undo redo preview | styleselect | bold italic | alignleft aligncenter alignright alignjustify",
images_upload_url: 'http://www.isilex.fr/postAcceptor.php',
images_upload_base_path: '/static/images',
relative_urls : false,
automatic_uploads: true,
width: 700,
height: 300,
    	content_css: [
    	{
    	let $dirHard := 
            concat(replace(file:base-dir(),'repo.*',''),"/static/CSS/",db:open('site')/root/css/text(),"/")
            for $x in file:list($dirHard)[matches(.,'.css')] return ("'/static/CSS/04/"||$x||"',")  }
    		"/static/CSS/04/classes.css"
   		 ],
     	 extended_valid_elements:  'page, name[lang], div[lang], a[href|target=_blank],strong/b,div[align],br'   
  	&#x0007D;
);
  </script>
   {$isi:Css}

   <body> 
   {$isi:ruler}
   <div id="global" class="protect">
       <form id="pageTiny" method="post" action="/savePageHTML-{$lg}-{$idPage}">
       <ul class="tabUserAdmin">
       <li><label>Titre ({$lg}): </label>
       <input class="adminInput" name='titre' type='text' placeHolder="Insert title" value="{for $x in db:open('pages')//page[name=$idPage]//name[@lang=$lg] return ($x)}"/></li>
       <li><textarea name="node" id="txtdef" class="inputAdmin">{ 
           if (db:open('pages')//page[name=$idPage])
           then
             for $x in db:open('pages')//page[name=$idPage]//div[@lang=$lg] return $x
           else 
           	db:open('site')/root/model[page/name='Nom']/page/div[@lang=$isi:testLang]
           
       }</textarea></li>
       </ul>
       </form>

   </div>    
   </body>
   </div>)
 };

 declare
  %updating
 %rest:path('/savePageHTML-{$lg=.*}-{$idPage=.*}')
  %output:method('html')
 %rest:POST
 %rest:query-param('titre','{$titre}','')
 %rest:query-param('node','{$node}','')
 function isilex:modpaTn($lg,$idPage,$node,$titre)
 { try { 
     update:output(web:redirect("pageHTML-"||$lg||"-{$idPage}"))),
		if($isi:testid2) 
		 then 
			if (db:open('pages')//page[name=$idPage]) 
		 		then 
		 			(replace node db:open('pages')//page[name=$idPage]/div[@lang=$lg] with 
		 				<div class='texteLong' lang="{$lg}">{html:parse(normalize-space($node), map { 'nons': true() })/html/body}</div>
		 				,
		 			replace	value of node db:open('pages')//page[name=$idPage]/name[@lang=$lg] with
		 			     data($titre)
		 			)
		 		else
		 		 let $pageNew := 
		 		 <page>
    				<name lang="fr">{$titre}</name>
   					<name lang="en">{$titre}</name>
    				<div class='texteLong' lang="{$lg}">{$node}</div>
    				<div class='texteLong' lang="{if ($lg='fr') then 'en' else 'fr'}">(empty)</div>
  				</page>
  				return insert node $pageNew into db:open('pages')/root
		 		
		 else db:output(isi:template(isi:t('unauthorized_access'))) 
		 } catch * { fn:error(xs:QName('err:save'), $node) } };


declare
 %rest:path('/page-{$lg=.*}-{$idPage=.*}')
 %output:method('html')
 function isilex:modpa($lg, $idPage)
 {
   <html>
   <head>
  <link rel="stylesheet" href="/static/uikit-2/css/uikit.min.css" />
   <script src="/static/jquery/jquery.js"></script>
   <script src="/static/uikit-2/js/uikit.min.js"></script>
   <script src="/static/uikit-2/js/marked.js"></script>
   {db:open('scripts')//entry[./@id="headerIsiPhp"]/header} 
   	<script src="/static/codemirror/mode/htmlmixed/htmlmixed.js"></script>  
   	<script src="/static/codemirror/mode/css/css.js"></script>
	<style>#txtdef a &#x0007B;color:red;&#x0007D;</style>
 	<link rel="stylesheet" href="/static/uikit-2/css/components/htmleditor.css"/>
    <script src="/static/uikit-2/js/components/htmleditor.js"></script>
   {$isi:Css}
   </head>
   <body onLoad="getInnerHtml();"> 
   {$isi:ruler}
   <div id="global" class="protect">
     <div id="xml" style="width: 90%;">
       <form id="pageSave" method="post" action="/savePage-{$lg}-{$idPage}">
       <textarea data-uk-htmleditor="&#x0007B;mode:'split'&#x0007D;"  name="node" id="txtdef" class="inputAdmin">{
         if (db:open('site')//texts/text[@lang=$lg][../name=$idPage])
         then 
           for $x in db:open('site')//texts/text[@lang=$lg][../name=$idPage] 
           return $x
         else 
           if (db:open('pages')//page[name=$idPage])
           then
             for $x in db:open('pages')//page[name=$idPage] return $x
           else db:open('site')/root/model[page/name='Nom']/*
           
       }</textarea>
       </form>
     </div>
     <a class="button" href="#" onclick='{if (db:open("utilisateurs")/utilisateurs/entry[not(usertype="user")]/sessions/session/id=session:id()) then string("document.getElementById('pageSave').submit();") else ()}'>Save</a>
   </div>    
   <!--db:open('scripts')//entry[./@id="codeMirrorStartLeger"]/script}-->
   </body>
   </html>
 };
 
 declare
 %updating
 %rest:path('/savePage-{$lg=.*}-{$idPage=.*}')
 %rest:POST
 %rest:query-param('node','{$node}','')
 function isilex:modpa($lg, $idPage,$node)
 {
    try { 
     update:output(web:redirect("/"))),
		if($isi:testid2) 
		 then 
		 	if (db:open('site')//texts[name=$idPage]/text[@lang=$lg]) 
		 		then 
		 			for $x in db:open('site')//texts[name=$idPage]/text[@lang=$lg] 
		 			return replace node $x with html:parse($node, map { 'nons': true() }) 
		 			
		 		else if (db:open('pages')//page[name=$idPage]) 
		 		
		 		then 
		 			replace node db:open('pages')//page[name=$idPage] with 
		 				html:parse(normalize-space($node), map { 'nons': true() }) 
		 		else if (not(fetch:xml(normalize-space($node), map{'chop': true()})//name = ('','Titre de la page','Page title','Nom','Name'))) 
		 		then 
		 			insert node html:parse(normalize-space($node), map{'nons': true()}) into db:open('pages')/root 
		 		else update:output(web:redirect("/err:save"))) else db:output(isi:template(isi:t('unauthorized_access'))) 
		 } catch * { fn:error(xs:QName('err:save'), $node) } };
 
 
 
 declare
 %updating
 %rest:path('deletepage-{$id=.+}')
 %output:method('html')
 function isilex:del-page($id){
   if ($isi:testid3)
   then (
     delete node db:open('pages')/root/page[name=$id],update:output(web:redirect("gere-site")))
     )
   else (db:output(isi:template('unauthorized_access')))
 };