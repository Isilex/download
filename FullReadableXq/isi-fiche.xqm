module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare 
 %rest:path('/fiche/{$path=.+}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:fiche($path)
  as element(html)
{
  let $contenu :=
     if (upper-case($path) != 'FORUMISILEX')
     then 
       if (db:open($isi:bdd)/*/fiche[id=$path]/entry or db:open($isi:bdd)/*/fiche[upper-case((entry//orth)[1])=upper-case($path)]/entry)
       (:On teste sur l'ID OU la vedette:)
       then (
         if ($isi:testid3 or $isi:testid4)
         then
           <a style="padding-left: 10px;" href="/wdvhgj{$path}" class=""><img class='zoom' src='/static/images/recycle-bin-icons.png' width='35px'/></a>
         else ()
         ,
         <a style="padding-left: 10px;" href='/modif-{$path}'><img class='zoom' width='35px' src='/static/images/svg/writing.svg'/></a>
         ,
         if (db:open('site')/root/forum='on')
         then <a style="padding-left: 10px;" class="" href="#commFiches"><img class='zoom' width='35px' src='/static/images/svg/chat.svg'/></a> 
         else ()
         ,
         <a style="padding-left: 10px;" href="/Images" class=""><img class='zoom' width='35px' src='/static/images/svg/violin.svg'/></a>
         ,
         <a style="padding-left: 10px;" href="/odt-odt-{$path}" class=""><img class='zoom' width='35px' src='/static/images/6876.png'/></a>
         ,
          <a style="padding-left: 10px;" href="/odt-pdf-{$path}" class=""><img class='zoom' width='35px' src='/static/images/32907.png'/></a> 
         ,
         if (db:open($isi:bdd)/*/fiche[id=$path]/entry) 
           then db:open($isi:bdd)/*/fiche[id=$path]/entry
           else if (db:open($isi:bdd)/*/fiche[upper-case(entry//orth)=upper-case($path)])
            then db:open($isi:bdd)/*/fiche[upper-case(entry//orth)=upper-case($path)]/entry
           else ()
           (:On teste sur les ID ou les VEDETTES MERCI !:)
       ) 
       else (
         if (not($path="FORUM")) 
         then <a class='button' href='{ if ($isi:testid2) then "/modif-{$path}" else "/login"}'>Modifier</a> 
         else ()
         ,
         if (db:open($isi:bdd)/*/fiche[id=$path]/entry) 
           then db:open($isi:bdd)/*/fiche[id=$path]/entry
           else if (db:open($isi:bdd)/*/fiche[upper-case(entry//orth)=upper-case($path)])
            then db:open($isi:bdd)/*/fiche[upper-case(entry//orth)=upper-case($path)]/entry
           else ()
           (:On teste sur les ID ou les VEDETTES MERCI !:)
       )
     else <entry>Le lieu de parler d &#x00027; Isilex</entry>

return
    
    if ($contenu)    
    then
    isi:template(      
      (      
      <div id="cp" style='display:none'></div>,
      (:**********Si lien ou image afficher en haut de la fiche*********:)
      if ($contenu//note//@src contains text 'http://' or $contenu//note//@href contains text 'http://') 
      then 
        for $x at $counter in (($contenu//note//@src), ($contenu//note//@href))[. contains text 'http://']
                let $http:= analyze-string(string($x),'http://[^ ]*')//fn:match
                let $num := count($http)
                 return
          if ($num = 1) then
              for $h at $c in $http
              return
              <div id="panelImg{$counter}"
                                      onMouseOver="document.getElementsByTagName('ref')[{$counter - 1}].style.border='8px solid red';"
                                      onMouseOut="document.getElementsByTagName('ref')[{$counter - 1}].style.border='none';">
              <div id="minimenu" style="display:block;">
                                     <!-- *********************************************** Le texte du menu de la Gallerie sur ISILEX
                                      <a id="gal2{$counter}"
                                        onClick="document.getElementById('iframe{$counter}').style.height='200px';
                                        document.getElementById('iframe{$counter}').style.width='200px';
                                        var compteur = document.getElementById('compteur').innerHTML;
                                        document.getElementById('iframe2{$counter}').src=document.getElementById('num').getElementsByTagName('indexNum')[compteur].innerHTML;"
                                       href="http://www.isilex.fr/img/illustrIsi.png"
                                       target="panelImg{$counter}">
                                        
                                         {$num}
                                         <img height="10px" src="/static/images/Preceding.png"/>
                                          </a>
                                          <a id="gal3{$counter}" style="font-size: 0.5em"
                                                  onClick="document.getElementById('iframe{$counter}').style.height='400px';
                                                                   document.getElementById('iframe{$counter}').style.width='400px'"
                                                  href="http://www.crealscience.fr" target="panelImg{$counter}">
                                                  Web  ::
                                          </a>
                                          <a id="gal4{$counter}" style="font-size: 0.5em"
                                                  onClick="document.getElementById('iframe{$counter}').style.height='400px';
                                                                   document.getElementById('iframe{$counter}').style.width='400px'"
                                                                   href="https://www.youtube.com/embed/ZWhNjD0Ztyw" target="panelImg{$counter}">
                                                  Video
                                          </a>
                                          <a id="gal{$counter}" onClick="document.getElementById('iframe{$counter}').style.height='100px';
                                                                                   document.getElementById('iframe{$counter}').style.width='100px';
                                                                                  var compteur = document.getElementById('compteur').innerHTML;
                                                  document.getElementById('iframe2{$counter}').src=document.getElementById('num').getElementsByTagName('indexNum')[compteur].innerHTML;"
                                                                  href="http://www.isilex.fr/img/illustr3.png"
                                                                  target="panelImg{$counter}">
                                                                  <img height="10px" src="/static/images/Next.png"/>
                                          </a>
                                          *********************************  -->
              </div>
              <iframe class="illustrationFiche"
                              id="iframe{$counter}"
                              onLoad="var e =Math.floor((Math.random() * 10) + 1);
                                      document.getElementById('gal{$counter}').href='http://www.isilex.fr/img/illustr'.concat(e).concat('.png');
                                      document.getElementById('gal2{$counter}').href='http://www.isilex.fr/img/illustr'.concat(e + 1).concat('.png');"
                              onMouseOver="this.style.height='300px'; this.style.width='300px';"
                              onMouseOut="this.style.height='200px'; this.style.width='200px';this.style.zIndex='0'"
                              onMouseClick="this.style.zIndex='20000000';"
                              name="panelImg{$counter}"
                              frameborder="0"
                              border="0"
                              cellspacing="0"
                              seamless="seamless"
                              scrolling="no"
                              width="100" height="100"
                              src='{($h//text())}'/>
              </div>
          else
            <div id="panelImg2{$counter}"
                 onMouseOver="document.getElementsByTagName('ref')[{$counter - 1}].style.border='8px solid red';"
                 onMouseOut="document.getElementsByTagName('ref')[{$counter - 1}].style.border='none';">
          <div id="minimenu" style="display:block;">
          <div id="num" style="display:none">
                  <div id="compteur">{$num}</div>
                  <div id="total">{$num}</div>
                  <div id="sens">minus</div>
                  {for $x in (1 to xs:integer($num)) return <div class="indexNum">{$http[$x]//text()}</div>}
          </div>
           <!-- *********************************************** Le texte du menu de la Gallerie sur ISILEX
          <a id="gal2{$counter}"
                  onClick="
                  document.getElementById('iframe{$counter}').style.height='';
                  document.getElementById('iframe{$counter}').style.width='';
                  document.getElementById('sens').innerHTML = 'minus';
                  var compteur = document.getElementById('compteur').innerHTML;
                  document.getElementById('iframe2{$counter}').src=document.getElementById('num').getElementsByTagName('indexNum')[compteur].innerHTML;
                  "
                  href="http://www.isilex.fr/img/illustrIsi.png"
                  target="panelImg{$counter}">
                    <div id="temoin" style="float:left; margin-left: 5px;">{$num}</div><img height="10px" src="/static/images/Preceding.png"/>
          </a>
          <a id="gal{$counter}" onClick="
                                  document.getElementById('iframe{$counter}').style.height='';
                                  document.getElementById('iframe{$counter}').style.width='';
                                  document.getElementById('sens').innerHTML = 'saucisse';
                                  this.href= document.getElementById('num').getElementsByTagName('indexNum')[1].innerHTML;
                                  var compteur = document.getElementById('compteur').innerHTML;
                                  document.getElementById('iframe2{$counter}').src=document.getElementById('num').getElementsByTagName('indexNum')[compteur].innerHTML;
                                  "
                                  href="http://www.isilex.fr/img/illustr3.png"
                                  target="panelImg{$counter}">
                                  <img height="10px" src="/static/images/Next.png"/>
          </a>
          *********************************  -->
          </div>
          <iframe class="illustrationFiche"
                          id="iframe2{$counter}"
                          onLoad="
                                  var total = document.getElementById('total').innerHTML;
                                  var compteur = document.getElementById('compteur').innerHTML;
                                  var sens = document.getElementById('sens').innerHTML;
                                  if (sens == 'minus') &#x0007B;
                                          if (compteur &gt; 0) &#x0007B; var e = compteur - 1; &#x0007D; else &#x0007B; var e = total; &#x0007D;
                                          &#x0007D;
                                  else &#x0007B;
                                          if (compteur &lt; total - 1) &#x0007B; var e = (parseInt(compteur)+1); &#x0007D; else &#x0007B; var e = 0; &#x0007D;
                                          &#x0007D;
                                  ;
                                  document.getElementById('compteur').innerHTML = e;
                                  document.getElementById('temoin').innerHTML = e;
                                  var h = document.getElementsByClassName('indexNum')[e].innerHTML;
                                  var hh = document.getElementsByClassName('indexNum')[e + 1].innerHTML;
                                  document.getElementById('gal{$counter}').href = h ;
                                  document.getElementById('gal2{$counter}').href = hh;"
                          onMouseOver="this.style.height='400px'; this.style.width='400px';"
                          onMouseOut="this.style.height=''; this.style.width='';this.style.zIndex='0'"
                          onMouseClick="this.style.zIndex='20000000';"
                          name="panelImg{$counter}"
                          frameborder="0"
                          border="0"
                          cellspacing="0"
                          seamless="seamless"
                          scrolling="no"
                          src='{($http[$num]//text())}'/>
          </div>
        else ()
      
      (:************Fin affiche lien**********:)
      ,
      
      
      $contenu
      ,
      if (db:open('messages')//entry[matches(./subject,$path,'i')][not(matches($path,'FORUM','i'))]) 
      then 
        <div id="note" class='postit yellow'>
          <a href="#" class="XClick" onClick="document.getElementById('note').style.display='none';">X</a>
          {
            for $mess in db:open('messages')//entry[matches(./subject,$path,'i')]
            return 
            <p>{
              data($mess/@from)} ({replace(data($mess/date),'T.*','')} à {replace(data($mess/date),'.*T(.....).*','$1')}): {html:parse(string($mess/message), map { 'nons': true() })
            }</p>
          }
        </div>
      else (),
      if (db:open('site')/root/forum='on')
      then
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
            <h2>Commenter la Fiche</h2>
            <form id="postForm" method="post" action="/saveMess">
              <p>
                <textarea id="areaTitreForum" 
                          name="messTitre" 
                          placeHOlder="Your title on {(db:open($isi:bdd)/*/fiche/entry/form/orth)[1]}..." /> <!-- la page FORUM -->
              </p>
              <p>
                <textarea id="areaForum" 
                          name="messText" 
                          placeHOlder="Your comment on {db:open($isi:bdd)/*/fiche/entry/form/orth}..." />
              </p>
              <input type="hidden" name="messBdd" value="{$isi:bdd}"/>
              <input type="hidden" name="messId" value="{$path}"/>
              <input type="hidden" name="messAuthor" value="{$isi:testidname}"/>
            </form>
            {
              for $x in db:open('forum')/bdd/entry[bddId=$path] 
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
                      if ($isi:testid3 or $isi:testid4 or $isi:testidname=db:open($isi:bdd)/*/fiche[id=$path]/auteur) 
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
                          <input type="hidden" name="orig" value="{$path}"/>
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
              for $x in db:open('forum')/bdd/entry[bddId=$path] 
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
      else ()
      )
  )
    
else isi:template(isi:t('page_not_found'))
};