module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

 declare 
  %rest:path('/readMailBdd')
  %output:method("html")
  %output:omit-xml-declaration("no")

  function isilex:readMailBdd()
{
  let $contenu :=(
    <a href="/sendMailFree" class="button">Envoyer un nouveau mail</a>,
    let $name := data(db:open('utilisateurs')/utilisateurs/entry[sessions/session/id=session:id()]/name)
    for $x in db:open('messages')//entry[to=$name] 
    return   
      <entry class="messages">
        <a class="button" href="#" onClick="document.getElementById('P').value={data($x/@id)}; document.getElementById('O').submit();">X</a>
        <p>from : {data($x//@from)}</p>
        <p>Subject: {data($x//subject)}</p>
        <p>cc: {data($x//cc)}</p>
        <p>to:: {data($x//to)}</p>
        <p>message: {html:parse(string($x/message), map { 'nons': true() })}</p>
        <p>
          <a class="button" 
             href="#" 
             onclick="document.getElementById('M').value='{for $y in (($x//to),($x//cc)) return $y||';'}';
                      document.getElementById('N').value='Re: {for $y in ($x//subject) return $y}';
                      document.getElementById('L').submit(); "
          >
          Reply
          </a>
        </p>
      </entry>
   ,
   <form id="L" method="post" action="/sendMail">
     <input id="M" type="hidden" name="to"/>
     <input id="N" type="hidden" name="subj"/>
   </form>
   ,
   <form id="O" method="post" action="/delMailBdd">
     <input id="P" type="hidden" name="id" value=""/>
   </form>
   )
    
  return  
    isi:template($contenu)
};

declare 
  %rest:path('/sendMail')
  %output:method("html")
  %output:omit-xml-declaration("no")
  %rest:POST
  %rest:form-param("to","{$to}", "(no message)")
  %rest:form-param("subj","{$subj}", "(no message)")
  function isilex:sendMail($to, $subj)
{
  let $contenu :=(
    <h2>Messages</h2>,
    <entry id="word" class="messages">
      <script src='/static/tinymce/tinymce.min.js'></script>
      <script>
        tinymce.init(&#x0007B;
        selector: '#message',
        plugins: [
          "code",
          "jbimages preview save insertdatetime media table contextmenu paste imagetools",
          "advlist autolink lists link image charmap print preview anchor",
          "searchreplace visualblocks code fullscreen"],
        toolbar: " undo redo preview | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image code jbimages",
        images_upload_url: 'http://www.isilex.fr/postAcceptor.php',
        images_upload_base_path: '/static/images',
        automatic_uploads: true,
        width: 900,
        height: 300,
        content_css: [
          {
          let $dirHard := 
            concat(replace(file:base-dir(),'repo.*',''),"/static/CSS/",db:open('site')/root/css/text(),"/")
          for $x in file:list($dirHard)[matches(.,'.css')]
          return ("'/static/CSS/04/"||$x||"',")
          }
          "/static/CSS/04/classes.css"
        ],
        extended_valid_elements:  'page, name[lang], div[lang], a[href|target=_blank],strong/b,div[align],br'   
        &#x0007D;
        );
      </script>
   {
     let $ro :=
       for $r in tokenize(normalize-space($to),';')[not(.='')][not(string-length(.)<3)] return $r
     return
     (
       for $x at $c in $ro 
       return 
       <p id="{$c}">to: <input class="dest" name="to" type="text" value="{$x}"/>
       {
         if (number($c)>1) 
         then 
           <a class="button" 
              href="#" 
              onClick="document.getElementById('word').removeChild(document.getElementById('{if (number($c)>1) then $c else ()}'))">
           -
           </a>
         else ()
       }
       <a class="button" href="#" onClick="
       var p = document.createElement('p');
       p.id = {number($c)+1};
       var a = document.createElement('a');
       var aNode = document.createTextNode('-');
       a.className = 'button';
       a.appendChild(aNode);
       var node = document.createTextNode('c/c:');
       p.appendChild(node);
       var input = document.createElement('input');
       input.type = 'text';
       input.name = 'to';
       input.className = 'dest';
       p.appendChild(input);
       p.appendChild(a);
       document.getElementById('word').insertBefore(p, document.getElementById('word').children[2] );
       ">+</a></p>,
       <p>Suj:<input id="subject" name="cc" type="text" value="{$subj}"/></p>,
       <input name="date" type="hidden"/>,
       <p>Txt: <textarea id="message" name="textdef"></textarea></p>
     )
   }   
   <a class="button" href="#" onClick="
   document.getElementById('M').value='{data(db:open('utilisateurs')/utilisateurs/entry[sessions/session/id=session:id()]/name)}';
   var dest = document.getElementsByClassName('dest');
   var array= new Array(dest.length);&#x0007B;
   for (i = 0; i &lt; dest.length; i++) 
          target=target.concat(dest[i].value.concat(';'));
        &#x0007D;;
   document.getElementById('N').value=target;
   document.getElementById('P').value=document.getElementById('subject').value;
   document.getElementById('Q').value=tinyMCE.activeEditor.getContent();
   document.getElementById('L').submit();
   ">Send</a>
  <form id="L" method="post" action="/sendMailBdd">
  <input id="M" type="hidden" name="from" value=""/>
  <input id="N" type="hidden" name="to" value=""/>
  <input id="O" type="hidden" name="cc" value=""/>
  <input id="P" type="hidden" name="subject" value=""/>
  <input id="Q" type="hidden" name="mess" value=""/>
  </form>
   </entry>
  )
   
  
  return 
    isi:template($contenu)
};

declare 
  %rest:path('/sendMailFree')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:sendMailFree()
{
  let $contenu :=(
    <h2>Messages</h2>,
    <entry id="word" class="messages">
      <script src='/static/tinymce/tinymce.min.js'></script>
      <script>
        tinymce.init(&#x0007B;
          selector: '#message',
          plugins: [
            "code",
            "jbimages preview save insertdatetime media table contextmenu paste imagetools",
            "advlist autolink lists link image charmap print preview anchor",
            "searchreplace visualblocks code fullscreen"],
         
          images_upload_url: 'http://www.isilex.fr/postAcceptor.php',
          images_upload_base_path: '/static/images',
          automatic_uploads: true,
          width: 900,
          height: 300,
          content_css: [{
            let $dirHard := 
              concat(replace(file:base-dir(),'repo.*',''),"/static/CSS/",db:open('site')/root/css/text(),"/")
            for $x in file:list($dirHard)[matches(.,'.css')]
            return ("'/static/CSS/04/"||$x||"',")
            }
            "/static/CSS/04/classes.css"
          ],
          extended_valid_elements:  'page, name[lang], div[lang], a[href|target=_blank],strong/b,div[align],br'   
        &#x0007D;);
      </script>
      <p id="1"><input class="dest adminInput" name="to" type="text" placeHolder="To" value=""/>
        <a class="button" href="#" onClick="document.getElementById('word').removeChild(document.getElementById('1'))">-</a>
        <a class="button" href="#" onClick="
          var p = document.createElement('p');
          p.id = '2';
          var a = document.createElement('a');
          var aNode = document.createTextNode('-');
          a.className = 'button';
          a.onClick='reset';
          a.appendChild(aNode);
          var node = document.createTextNode('');
          p.appendChild(node);
          var input = document.createElement('input');
          input.type = 'text';
          input.name = 'to';
          input.className = 'adminInput';
          input.placeholder='c/c';
          p.appendChild(input);
          p.appendChild(a);
          document.getElementById('word').insertBefore(p, document.getElementById('word').children[2] );
          "
        >
        +
        </a>
      </p>
      <p><input id="subject" class="adminInput" name="cc" type="text" value="" placeholder="Sujet" /></p>
      <input name="date" type="hidden"/>
      <p><textarea id="message" name="textdef" style="display:block;"></textarea></p>
     
      <!--a href="#" class='button' onClick="var e = tinyMCE.activeEditor.getContent(); alert(e);">Test</a-->
      
      <a class="button" 
         href="#" 
         onClick="
   document.getElementById('M').value='{data(db:open('utilisateurs')/utilisateurs/entry[sessions/session/id=session:id()]/name)}';
   var dest = document.getElementsByClassName('dest');
   var array= new Array(dest.length);&#x0007B;
   for (i = 0; i &lt; dest.length; i++) 
          target=target.concat(dest[i].value.concat(';'));
        &#x0007D;;
   document.getElementById('N').value=target;
   document.getElementById('P').value=document.getElementById('subject').value;
   document.getElementById('Q').value=tinyMCE.activeEditor.getContent();
   document.getElementById('L').submit();
   ">Send</a>
  <form id="L" method="post" action="/sendMailBdd">
  <input id="M" type="hidden" name="from" value=""/>
  <input id="N" type="hidden" name="to" value=""/>
  <input id="O" type="hidden" name="cc" value=""/>
  <input id="P" type="hidden" name="subject" value=""/>
  <input id="Q" type="hidden" name="mess" value=""/>
  </form>
   </entry>
  )
  
  return
    isi:template($contenu)
};

declare
 %updating
 %rest:path('/sendMailBdd')
 %rest:POST
 %rest:form-param("from","{$from}","")
 %rest:form-param("to","{$to}","")
 %rest:form-param("subject","{$subject}","")
 %rest:form-param("cc","{$cc}","")
 %rest:form-param("mess","{$mess}","")
 function isilex:sendMessBdd($from, $to, $subject, $cc, $mess){
    update:output(web:redirect("/accueil"))),
    isi:storeMessage($from, $mess, $to, $subject, $cc)
 };

declare
 %updating
 %rest:path('/delMailBdd')
 %rest:POST
 %rest:form-param("id","{$id}","")
  function isilex:delmess($id) {
     update:output(web:redirect("/readMail"))),
     for $x in db:open('messages')//entry[@id=$id] return delete node $x
  };
  
declare
 %updating
 %rest:path('/readMail')
 function isilex:markread() {
    update:output(web:redirect("/readMailBdd"))),
    for $x in db:open('messages')//entry[not(./read)] return insert node <read/> into $x
 };
