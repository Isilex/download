module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace request = "http://exquery.org/ns/request";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare %rest:path('/cssEdit') 
%output:method("html") 
%output:omit-xml-declaration("no") 
function isilex:editCss() as element(html) 
{ <html> { 
	if ( $isi:testid4 ) then 
		let $page := <texteAccueil> 
					<h2>Edit CSS and Designs</h2> 
					<p>Css Template Edit</p> 
					<p>Choose the third Css (3) under "WebSite Menu" ---&gt; "CSS".</p> 
					<a href='/edit-Header' class='button'>Edit Headers</a> 
					<a href='/edit-left' class='button'>Edit Left Menu</a> 
					<a href='/edit-classes' class='button'>Edit Css Classes</a> 
					<p>XML Datas presentation Template Edit</p> <a class='button' href='/edit-Fiches'>Edit Fiches Xml</a> 
					</texteAccueil> 
		return isi:template($page) else isi:template(isi:lang-text('unauthorized_access')) } 
</html> }; 

declare 
  %rest:path('/edit-{$file}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:editFile($file)
  as element(html)
{
  
<html>
{
 if ( $isi:testid4 ) then 
 let $page := 
           <texteAccueil>
           <link rel="stylesheet" href="/static/codemirror/lib/codemirror.css"/>
           <link rel="stylesheet" href="/static/codemirror/addon/hint/show-hint.css"/>
           <script src="/static/codemirror/lib/codemirror.js"></script>
           <script src="/static/codemirror/mode/css/css.js"></script>
           <script src="/static/codemirror/addon/hint/show-hint.js"></script>
           <script src="/static/codemirror/addon/hint/css-hint.js"></script>
           <h2>Edit CSS and Designs</h2>
           <form method="POST" action="/cssSave" id="editCss">
             <textarea id="code" name="cssContent" cols="60" rows="30">
             {file:read-text(file:base-dir()||'static/CSS/03/'||lower-case($file)||'.css')}
             </textarea>
             <input type="hidden" name="fileName" value="{(lower-case($file))}"/>
             <p><input type="submit" value="OK"/></p>
           </form>
            <script> 
            var editor = CodeMirror.fromTextArea(document.getElementById("code"), &#x0007B; extraKeys: &#x0007B;"Ctrl-Space": "autocomplete"&#x0007D;,&#x0007D;);
            </script>
           </texteAccueil>

 return isi:template($page)   
 else isi:template(isi:lang-text('unauthorized_access'))
}
</html>
};

declare
 %rest:path('/cssSave')
   %updating
 %rest:POST
 %rest:form-param("fileName","{$file}","")
 %rest:form-param("cssContent","{$css}","")
  function isilex:cssSave($css, $file){
    let $filePath := file:base-dir()||'static/CSS/03/'||$file||'.css'
    return
     (update:output(web:redirect("/edit-"||$file)))
   ,
     file:write($filePath,$css,map { "method": "text"})
     )
     
  };