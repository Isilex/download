(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)
module namespace isi = 'http://www.isilex.fr/isi-repo';

import module namespace session = "http://basex.org/modules/session";

declare namespace text =
  "urn:oasis:names:tc:opendocument:xmlns:text:1.0";
  
declare namespace officeooo = "http://openoffice.org/2004/office";




declare variable $isi:testid := 

  db:open('utilisateurs')/utilisateurs/entry/sessions/session/id=session:id();


declare variable $isi:testid2 := 

  db:open('utilisateurs')/utilisateurs/entry[usertype=('curator','administrator') or masteradmin='true']/sessions/session/id=session:id();


declare variable $isi:testid3 :=
 
  db:open('utilisateurs')/utilisateurs/entry[usertype='admin' or masteradmin='true']/sessions/session/id=session:id();


declare variable $isi:testid4 := 

  db:open('utilisateurs')/utilisateurs/entry[masteradmin='true']/sessions/session/id=session:id();


declare variable $isi:testidname := 

  (db:open('utilisateurs')/utilisateurs/entry[sessions/session/id=session:id()]/name/text())[1];

declare variable $isi:domaine := 

  db:open('site')/root/domaine/text();

declare variable $isi:unoconv := 

  db:open('site')/root/unoconv/text();



declare variable $isi:bdd :=(
  'bdd'
) ;




declare variable $isi:tagCloudXML := 

  db:open('site')/root/tagCloud/text();

declare variable $isi:scripts := 

  db:open('scripts')//entry[./@id="headerIsiPhp"]/header;



declare variable $isi:xsElements := 

  for $x in db:open('xsd')//xs:element[not(./xs:complexType)][not(./@name = $isi:interdit)] 
  return data($x/@name);



declare variable $isi:interdit := 

  ('id','date','valid','auteur');

declare variable $isi:di := 

  xs:integer(db:open('site')/root/show);

declare variable $isi:systemV := 

  db:open('site')/root/masterAdminValidation;


declare variable $isi:Css :=

  let $dirHard :=
    concat(replace(file:base-dir(),'repo.*',''),"webapp/static/CSS/",db:open('site')/root/css/text(),"/")
    
  let $dir := concat("/static/CSS/",db:open('site')/root/css/text(),"/")
  
  for $cssFile in file:list($dirHard)[matches(.,'.css')]
  return
    (
      <link
        rel="stylesheet"
        title="base"
        media="screen"
        href="{$dir}{$cssFile}"
      />
    )
    
 ;
             
declare function isi:lang-text($text){
  let $langue := if (not($isi:testLang=('fr','en',db:open('site')//@lang))) then 'fr' else $isi:testLang
  return
  if (db:open('site')/root/texts[name=$text]/text[@lang=$langue]/p)
    then db:open('site')/root/texts[name=$text]/text[@lang=$langue]/p
    else db:open('site')/root/texts[name=$text]/text[@lang=$langue]/(*,text())
};             

declare variable $isi:testLang :=
  if ($isi:testid)
  then
  
    try {
      if (db:open('utilisateurs')//entry[.//id=session:id()]/lang!='') then db:open('utilisateurs')//entry[.//id=session:id()]/lang 
      else 'en'
    }
    catch * {
      'en'
    }
    
  else
     try {
       if (db:open('visits')/root/visit[id=session:id()]/lang!='') 
       then db:open('visits')/root/visit[id=session:id()]/lang 
       else 'en'
     } 
     
     catch * {
       'en'
     };



declare variable $isi:menuGauche :=

<div id="menugauche">
  <div id="boite">
    <ul id="menucote">
       <li><a href="/accueil">{isi:t('mainpage')}</a></li>
       <li><a href="/categories">{isi:t('categories')}</a></li>
       {
          for $i in db:open('pages')/root/page[not(name = 'texteAccueil')] 
          return 
            <li><a href='/page/{$i/name[@lang=$isi:testLang]/text()}'>{$i/name[@lang=$isi:testLang]/text()}</a></li>
          ,
          if (db:open('site')//forum='on') 
          then <li><a href='{if ($isi:testid2 or $isi:testid3 or $isi:testid4) then "/forum/FORUMISILEX" else "/login"}'>Forum</a></li> 
          else () 
         }    
    </ul>
  </div>
</div>
;

declare variable $isi:alpha :=
(
<div id="topcahier">
  {
    if (db:open('site')/root/alphabet='on')
    then 
      <div id="alphabet">
        <form name="alphabet" action="index.php" method="post">
          <input type="hidden" name="indexlettreonglet" value=""/>
          {
            let $number-for-a := string-to-codepoints('A')
            let $number-for-z := string-to-codepoints('Z')
            for $letter in ($number-for-a to $number-for-z)
            return
              <div id='xx' class='hiddenAlphabet'><a href='/rubrique/{codepoints-to-string($letter)}/1'>{codepoints-to-string($letter)}</a></div>
          }
          <div id='xx' class='hiddenAlphabet'><a href='/tout/1'>All</a></div>
          {
           if ($isi:testid3 or session:id() = db:open('utilisateurs')/utilisateurs/entry[masteradmin='true']//id)
           then <div id='xx' class='hiddenAlphabet'><a style="width: 150px;" href="/alphabetC-{if (db:open('site')/root/alphabet='on') then 'off' else 'on'}">Social Network Mode</a></div>
           else ()
           }
        </form>
      </div>  
      
    else
      <div id="alphabet">
        {
           if ($isi:testid3 or session:id() = db:open('utilisateurs')/utilisateurs/entry[masteradmin='true']//id)
           then <div id='xx'><a style="width: 200px;" href="/alphabetC-{if (db:open('site')/root/alphabet='on') then 'off' else 'on'}">Lexis Mode</a></div>
           else ()
        }
      </div>
  }


  <form width="80px;" id="idefx3" method="POST" action="/idefx#texteAccueil"  onsubmit="window.open('', 'formpopup', 'width=900,height=400,resizeable = false,scrollbars');target_popup(this);" target="formpopup">
  <input type="text" name="idefx" id="idefx" placeholder="{if ($isi:testLang='fr') then 'Recherche en base' else 'Search'}"/>
  </form>
  </div>
)
;

declare variable $isi:ruler :=

<div id="menu_haut">
  <li class='ruler'>
    <a href="/"><img class='zoom' width="25px;" src="/static/images/svg/ereader.svg"/></a>
    <p class="phylactere">{isi:t('mainpage')}</p>
  </li>
  
  {if ($isi:systemV='on' and $isi:testid) then 
  <li class='ruler'>
   <a href="{ if ($isi:systemV='on') then '/valid/bdd/1' else ()}">
  {
    if ($isi:systemV='on') then 
     (
       <img class='zoom' width="25px" src='/static/images/svg/biology.svg'/>
     )
    else (<img class='zoom' width="25px" src='/static/images/boutonrouge.png'/>)
  }
  </a>
      <p class='phylactere'>{concat('[',count(db:open($isi:bdd)/root/fiche[number(./id)>1]/valid[.='ask']),']')} 
        {isi:t('admin')}</p>
  </li>
  else ()
   }
  {
    if ($isi:testid3 or session:id() = db:open('utilisateurs')/utilisateurs/entry[masteradmin='true']//id)
    then (
      <li class="ruler"><a href='/gere-site'><img class='zoom' width="25px"  src="/static/images/svg/laptop.svg"/></a><p class="phylactere">Param</p></li>,
      <li class="ruler"><a href='/gere-users'><img class='zoom' width="25px"  src="/static/images/svg/lecture.svg"/></a><p class="phylactere">{isi:t('members')}</p></li>
          )
    else ()
  }
  {
    if ($isi:testid2)
    then
    <li class="ruler"><a href="/user/{$isi:name}"><img class='zoom' width="25px"  src="/static/images/svg/brainstorm.svg"/></a><p class="phylactere">{$isi:testidname}</p></li>
    else ()
  }
  {if ($isi:testid2) then
 <li class='ruler'><a href="{if ($isi:testid2) then "/new-fiche" else "/login" }"><img class='zoom' width="25px" src="/static/images/svg/ereader-2.svg"/></a><p class="phylactere">{isi:t('add')}</p></li>
 else ()
}
  {if ($isi:testid2) then
 <li class='ruler'><a href="{if ($isi:testid2) then "/newFicheXml" else "/login"}"><img class='zoom' width="25px" src="/static/images/svg/ereader-1.svg"/></a><p class="phylactere">{isi:t('XML')}</p></li>
 else ()
  }
  {if ($isi:testid2) then
 <li class='ruler'><a href="{if ($isi:testid2) then "/readMail" else "/login"} "><img class='zoom' width="25px" src="/static/images/svg/email.svg"/> {let $count := count(for $x in db:open('messages')//entry[.//to contains text {$isi:name} using case insensitive][not(.//read)] return $x) return if ($count=0) then () else '['||$count||']'}</a><p class="phylactere">Mails</p></li>
 else ()
}
         <li class='ruler'>{
          if ($isi:testid) 
            then <a href="/logout"><img class='zoom' width="25px" src="/static/images/key_PNG1174.png"/></a>
            else <a href="/login"><img class='zoom' width="25px" src="/static/images/cadenas.png"/></a>
        }
        <p class="phylactere">{if ($isi:testid) then 'logout' else 'login'}</p>
        </li>
        
        <div id="flagLang">
         <li class='change-lang'>
         <form method='POST' action='/change-lang'>
          <input id='presentUrl' name='back' type='hidden' ></input>
          <input id='lang_fr' name='lang' type='hidden' value='fr'></input>
          <input style="top: 15px;" type='image' src='/static/images/fr_flag.png' width='25px' alt='submit' ></input>
        </form>
        </li>
        <li class='change-lang'>
        <form method='POST' action='/change-lang'>
          <input id='presentUrl2' name='back' type='hidden' ></input>
          <input id='lang_en' name='lang' type='hidden' value='en' ></input>
          <input type='image' width='23px' src='/static/images/en_flag.png'  alt='submit'></input>
        </form></li>
        </div>

</div>
;



declare variable $isi:titre-name := 
 db:open('site')/root/domaine-name/text();
  
  

declare variable $isi:tagCloud :=
      <div id="myCanvasContainer" style="float:left;">
       <canvas width="200" height="150" id="myCanvas">
       <p>Anything in here will be replaced on browsers that support the canvas element</p>
        <ul id='weightTags'>
         {

             for $x in distinct-values(
                        (db:open($isi:bdd)//sense/@*,
                        db:open($isi:bdd)//entry//usg, (:on indexe dans le cloud les usages:)
                        db:open($isi:bdd)//entry[xs:integer(id) < 20]/form/orth,(:et les vingt premières vedettes:)
                        db:open($isi:bdd)//*[string(node-name(.))=$isi:tagCloudXML]))(:on ajoute ce que l'utilisateur veut voir:)
                        [not(matches(.,'Ajout','i'))]
                        [not(matches(.,'FORUMISILEX','i'))]
             return
              <li>
               <a onClick="document.getElementById('idefx').value='{data($x)}';document.getElementById('idefx3').submit();"
                  href="#">{data($x)}</a>
             </li>
       }
      </ul>
     </canvas>
    </div>;


declare variable $isi:accueil-text := 
  db:open('site')/root/accueil/text();


declare variable $isi:titre :=(
  <div id="hautcote"><a href="/"></a></div>
  ,
  db:open('site')/root/domaine-name/text()
  (:************
  ,<div id="sousTitre">{
        if ($isi:bdd = "bdd")
                then
                        <a class="button"
                                href="#"
                                onClick=" location.href='/switchBdd-{if ($isi:bdd = 'bdd') then '1' else '0'}';"
                                onMouseOut="document.getElementById('labelSwitchLbl').innerText='{isi:t('switch')}';
                                                        document.getElementById('labelSwitchLbl').style.backgroundColor='white';
                                                        document.getElementById('labelSwitchLbl').style.color='black';"
                                onMouseOver="document.getElementById('labelSwitchLbl').innerText='{isi:t('switchDbb')}';
                                                         document.getElementById('labelSwitchLbl').style.backgroundColor='red';
                                                         document.getElementById('labelSwitchLbl').style.color='white';">
                                Isilex for Encyclopedia available on the Web: on
                        </a>
                 else
                 <a class="button"
                                href="#"
                                onClick="location.href='/switchBdd-{if ($isi:bdd = 'bdd') then '1' else '0'}';"
                                onMouseOut="document.getElementById('labelSwitchLbl').innerText='{isi:t('switch')}';
                                                        document.getElementById('labelSwitchLbl').style.backgroundColor='white';
                                                        document.getElementById('labelSwitchLbl').style.color='black';"
                                onMouseOver="document.getElementById('labelSwitchLbl').innerText='{isi:t('switchDbb')}';
                                                         document.getElementById('labelSwitchLbl').style.backgroundColor='red';
                                                         document.getElementById('labelSwitchLbl').style.color='white';">
                                Isilex for Business available on the Web: on
                        </a>
        }</div>
        :)
);

declare variable $isi:footer := (
  
  
  <div id='footer' style="font-size: x-small; padding-bottom: 15px;"></div>,
  <div
  id="footerIdefx"
  style="z-index: 7000;width:100%; position:fixed; bottom:0px; left: 0px; text-align: center; color: #A0A0A0; font-size: xx-small; background-color:white; padding: 3px;">
  {db:open('site')/root/footer-text/text()}
  </div>

);

declare variable $isi:name := 
  db:open('utilisateurs')/utilisateurs/entry[sessions/session/id=session:id()]/name/data();
  
  
  

declare function isi:template($contenu){
  <html>
  <head>
  <link rel="icon" type="image/svg" href="/static/images/book.svg" />
  <link href='https://fonts.googleapis.com/css?family=Lobster+Two|Open+Sans|Roboto' rel='stylesheet' />
  {
    for $i in db:open('scripts')//entry[./@id="headerPhp"]/header/* return $i,
    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>,
    <script>{db:open('scripts')//entry[@id='tagCloudStart']/script/text()}</script>,
    <title>
    {$isi:titre-name,
    
      if ($isi:testid or $isi:testid2 or $isi:testid or $isi:testid4) 
      then( 
      if ( count(
          db:open('messages')//entry[.//to contains text {$isi:name} using case insensitive][not(.//read)]) != 0)
      then
      concat(' (',
        count(
          db:open('messages')//entry[.//to contains text {$isi:name} using case insensitive][not(.//read)]
        ),
        ')'
      )
      else ()
      )  
      else ()
    } 
    </title>}
  </head>
  {$isi:Css}
  <body>
  {$isi:ruler}
  {
    if (some $e in $contenu satisfies $e instance of node() and $contenu[. instance of node()]//h2 and $contenu[. instance of node()]//h2[matches(.,'Cat.*','i')])
    then ()
    else $isi:tagCloud
  }
  <div id='global'>
    <div id="top">
    {
      $isi:titre
      ,
       (:Affichage alphabet et moteur de rechercher:)
       if ($contenu instance of node() and $contenu//h2[matches(.,'Corp.*','i')])
        then ()
        else $isi:alpha
    }
    {
    if (some $e in $contenu satisfies $e instance of node() and $contenu[. instance of node()]//h2 and $contenu[. instance of node()]//h2 contains text 'Modules')
    then
    <div id="Pub">
    <a  
      id="clickIframePub" 
      class='clickx' 
      href="#" 
      onclick="document.getElementById('Pub').style.display = 'none';">X</a>
    </div>
    else ()
    }</div>

  {$isi:menuGauche,<br/>,<div id="texteAccueil">{$contenu}</div>,<br/>,$isi:footer}
  </div>
  {db:open('scripts')//entry[@id='tagCloud']/*}
  </body>
  </html>
};



declare function isi:t($text){
  let $langue := if (not($isi:testLang=('fr','en',db:open('site')//@lang))) then 'fr' else $isi:testLang
  return
  if (db:open('site')/root/texts[name=$text]/text[@lang=$langue]/p)
    then db:open('site')/root/texts[name=$text]/text[@lang=$langue]/p
    else db:open('site')/root/texts[name=$text]/text[@lang=$langue]/(*,text())
};



declare function isi:validateXML($fiche) {
  
    try {
     (:let $nodeX := fetch:xml(normalize-space($fiche), map { 'chop': true() }):)
     let $nodeX := $fiche
     let $xsd := db:open('tei_fiche')
     let $valide := validate:xsd-info($nodeX,$xsd)
     return
       if (empty($valide))
       then
         "Le document est conforme"
       else ($valide)
    }
      
    catch * {
       "Non XMLisable"
    }

};

declare function isi:validXMLById($id) {
  
   let $nodeX :=
     db:open($isi:bdd)/*/fiche[id=$id]/entry     
   let $xsd := db:open('tei_fiche')
   return
    try { 
     let $valide := validate:xsd-info($nodeX,$xsd)
     return
     if (empty($valide))
     then
      "Le document est conforme"
     else $valide
    }
      catch * {
        "Non XMLisable"
    }

};



declare updating function isi:storeMessage($from, $mess, $to, $subject, $cc) {
  let $id := number((db:open('messages')//@id)[1])+1
  let $node :=
          <entry id="{$id}" from="{$from}">
          <to>{replace($to,';','')}</to>
            {
              for $t in tokenize($to,';')
               for $x in db:open('utilisateurs')//entry[matches(name,$t,'i') or usertype=$t]
                return <to>{data($x/name)}</to>

                }
            <subject>{$subject}</subject>
            <date>{current-dateTime()}</date>
            <message>{$mess}</message>
            { if ($cc != 'null') then
                for $x in db:open('utilisateurs')//entry[/name=$to or /usertype=$to]
                return <to>{$x}</to>
                else <cc/>
                }
          </entry>
   return insert node $node as first into db:open('messages')/bdd

};

declare function isi:fic_to_template($fic,$n){

for $node at $d in $fic
  let $id := concat($n,$node/name(),'_',$d,'-')
  return 
  element{$node/name()}{attribute id {$id},for $i in $node/@* return attribute{$i/name()}{$i/data()},isi:fic_to_template($node/*,$id),$node/text()}
};

declare function isi:ele_gen($xsd){
  for $i in $xsd return if ($i/name()='xs:element') then

  element {$i/@name} {for $att in $i/xs:complexType/xs:attribute return attribute {$att/@name}{data($att)},isi:ele_gen($i/*)}
  else if ($i/*) then (isi:ele_gen($i/*)) else ()
};

declare function isi:js($node,$id,$cp){
  let $save := concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("FIN ',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $n := concat('var ',$node/name(),' = document.createElement("',$node/name(),'");',$node/name(),'.setAttribute("id",',$cp,');',if($node/@*) then for $attr in $node/@* return concat($node/name(),'.setAttribute("',$attr/name(),'","',data($attr),'");') else ())
  let $ppch := if($node/*) then concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("FIN',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);',$cp,'++;') else()
  let $pch := if($node/*) then () else concat('tr = document.createElement("tr");td = document.createElement("td");td.setAttribute("class","masqueSaisieCourt");var t = document.createTextNode("',$node/name(),'");td.appendChild(t);tr.appendChild(td); td = document.createElement("td");input=document.createElement("input");input.setAttribute("n",cp);input.setAttribute("onkeyup","champToXml();");input.setAttribute("type","text");input.setAttribute("class","xsd admin");input.setAttribute("onClick","',"champToXml() ",'");td.appendChild(input);tr.appendChild(td);td = document.createElement("td"); a =document.createElement("a");var t = document.createTextNode("X");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh();");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);',$cp,'++;')
  let $attch := for $att in $node/@* return concat('tr = document.createElement("tr");td = document.createElement("td");td.setAttribute("class","masqueSaisieCourt");var t = document.createTextNode("',$att/name(),'");td.appendChild(t);tr.appendChild(td); td = document.createElement("td");input=document.createElement("input");input.setAttribute("n",cp);input.setAttribute("name","',$att/name(),'");input.setAttribute("onkeyup","champToXmlA();");input.setAttribute("type","text");input.setAttribute("class","xsd admin");input.setAttribute("onClick","',"champToXmlA() ",'");td.appendChild(input);tr.appendChild(td);td = document.createElement("td"); a =document.createElement("a");var t = document.createTextNode("X");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh();");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $fch := if($node/*) then concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);') else ()
  let $ch := 
    for $i at $c in $node/* 
    return isi:js($i,$id,($cp))
  let $add := for $i in $node/* return concat($node/name(),'.appendChild(',$i/name(),');')
  return ($n,$ppch,$ch,$attch,$pch,$fch,$add)
};

declare function isi:div($node,$id,$cp,$c){
  
  let $save := concat('tr = document.createElement("div");td = document.createElement("div");var t = document.createTextNode("FIN ',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $n := concat('var ',$node/name(),' = document.createElement("',$node/name(),'");',$node/name(),'.setAttribute("id",',$cp,');',if($node/@*) then for $attr in $node/@* return concat($node/name(),'.setAttribute("',$attr/name(),'","',data($attr),'");') else ())
  let $ppch := if($node/*) then concat('tr = document.createElement("div");td = document.createElement("div");var t = document.createTextNode("FIN',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);',$cp,'++;') else()
  let $pch := if($node/*) then () else concat('var tr = document.createElement("div"); tr.setAttribute("style","display: flex; justify-content:center;margin:18px; padding:10px;"); var td = document.createElement("div"); td.setAttribute("class","masqueSaisieCourt"); var t = document.createTextNode("',$node/name(),'"); td.appendChild(t); td.setAttribute("style","padding:5px;"); tr.appendChild(td); td = document.createElement("div"); var input=document.createElement("input"); input.setAttribute("n",cp); input.setAttribute("onkeyup","champToXml();"); input.setAttribute("type","text"); input.setAttribute("class","xsd admin"); input.setAttribute("onClick","',"champToXml(); ",'"); td.appendChild(input); tr.appendChild(td); td = document.createElement("div"); td.setAttribute("style","padding-left:8px;"); a =document.createElement("a");var t = document.createTextNode("Clear");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh(this);");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','mnode','.appendChild(tr);',$cp,'++;')
  let $attch := for $att in $node/@* return concat('tr = document.createElement("div");td = document.createElement("div");td.setAttribute("class","masqueSaisieCourt");var t = document.createTextNode("',$att/name(),'");td.appendChild(t);tr.appendChild(td); td = document.createElement("div");input=document.createElement("input");input.setAttribute("n",cp);input.setAttribute("name","',$att/name(),'");input.setAttribute("onkeyup","champToXmlA();");input.setAttribute("type","text");input.setAttribute("class","xsd admin");input.setAttribute("onClick","',"champToXmlA() ",'");td.appendChild(input);tr.appendChild(td);td = document.createElement("div"); a =document.createElement("a");var t = document.createTextNode("X");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh();");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $MainNode := if($node/*) then concat('mnode' ,'= document.createElement("div"); mnode','.setAttribute("style","border: 1px solid; justify-content:center;margin:8px; padding:8px;");','var t = document.createTextNode("',upper-case($node/name()),'"); mnode','.appendChild(t);') else ()
  let$appendToMainNode := if($node/*) then
  concat(
    'temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(mnode',',temp);')
    else ()
  let $ch := 
    for $i at $c in $node/* 
    return isi:div($i,$id,($cp),$c+1)
  let $add := for $i in $node/* return concat($node/name(),'.parentNode.appendChild(',$i/name(),');')
  let $add2 := if ($c=1) then for $i in $node/* return concat('var nod = document.getElementById(fid);','var sibl = document.getElementById(fid).parentNode.nextElementSibling; var up =document.getElementById(fid).parentNode ; up.insertBefore(',$node/name(),',sibl);') else ()
  let $add3 := if ($c!=1) then for $i in $node/* return concat('var nod = document.getElementById(cp);','var sibl = document.getElementById(cp).parentNode.nextElementSibling; var up =document.getElementById(cp).parentNode ; up.insertBefore(',$node/name(),',sibl);') else ()
  return ($n,$add2,$add3,$MainNode,$ch,$pch,if ($c=1) then $appendToMainNode else())
};

declare function isi:xsdfic($fic,$xsd,$n){

for $i at $d in $fic[name()=$xsd/@name]
  let $nc := concat($n,$i/name(),'.',$d,';')
  let $att := for $at in $i/@* return attribute {$at/name()}{$at/string()}
  return (element {$i/name()}{ 
  attribute id {$nc},$att,
  if(normalize-space(string-join($i/text()))) then $i/text() else (),
  isi:xsdfic($i/*,$xsd/*,$nc)
}
),

for $i at $d in $fic[name()=$xsd/@ref]
  return isi:xsdfic($fic,$xsd/ancestor::*[last()]/*[@name=$i],$n)




,
for $x at $c in $xsd
return switch ($x/name())

(:
case 'xs:element' return
  for $i at $d in $fic[name()=$x/@name]
  let $nc := concat($n,$c,'.',$d,';')
  return (element {$i/name()}{ 
  attribute id {$nc},
  if(normalize-space(string-join($i/text()))) then $i/text() else (),
  isi:xsdfic($i/*,$x/*,$nc)
}
)
:)
case 'xs:complexType' return
  isi:xsdfic($fic,$x/*,$n)
    
case 'xs:sequence' return
  isi:xsdfic($fic,$x/*,$n)

case 'xs:choice' return
  isi:xsdfic($fic,$x/*,$n)

default return ()

};



declare function isi:chafic($fic,$xsd,$n){
  
for $element in $xsd
return switch ($element/name())

case 'xs:complexType' return
  isi:chafic($fic,$element/*,$n)

case 'xs:sequence' return
  isi:chafic($fic,$element/*,$n)

case 'xs:choice' return
  isi:chafic($fic,$element/*,$n)
  


case 'xs:element' return 

for $node at $d in $fic
  return 
    
    if ($node/name()=('id','valid','auteur','date')) then () else

if (not($node/*) and $node/name()=$element/@name) then (
  
  <div style="display: flex; justify-content:center;flex:column;margin:18px; padding:10px;" 
        id="A{$n}{$node/name()}.{$d};" 
        n='{$n}{$node/name()}.{$d};' 
        class='{if ($node/*) then "separator" else ()}' >
        <div style='padding:5px;'>{$node/name()}</div>
        <div>{if(not($node/*))then 
          <input      n="{$n}{$node/name()}_{$d}-"                     
                       onkeyup="var id = document.activeElement.getAttribute('n');champToXml();champsActu();" 
                       class="xsd adminInput" 
                       type="text" 
                       name="{$node/name()}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$node/name()}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$node/text()}'></input> else ()}</div>
                <div style='padding-left:8px;'><a class='button' onClick="
                    var target = document.getElementById(id);
                    var t = this.parentNode.previousElementSibling;
                    t.children[0].value='';
                    target.innerHTML = '';
                 ">Clear</a></div>
                </div>
                )
                else
                if($node/name()=$element/@name) then
                <div 
                id="A{$n}{$node/name()}.{$d};"
                n="{$n}{$node/name()}.{$d};" 
                name="{$node/name()}" 
                style="border: 1px solid; justify-content:center;margin:8px; padding:8px;"><div style="justify-content:center;">{upper-case($node/name())}</div>
                {                
                   <div 
                   onClick="
                    var id = this.parentNode.getAttribute('n');
                    var pa = this.parentNode.getAttribute('id');
                    add{$node/name()}(id,pa);"
                   style='flex:right;'>
                   </div>,
                   isi:chafic($node/*,$element[@name=$node/name()]/*,concat($n,$node/name(),'.',$d,';'))
                   
                }</div>
                else ()
default return ()
};

declare function isi:fic_to_masque($fic,$n){
(:
  À partir du XSD ou de la fiche, on génère le masque à gauche
:)
for $node at $d in $fic
return 
(
    <div style="{if ($node/name()='entry') 
                 then (
                   if ($node/*) 
                   then('background-color:#cfd8dc;') 
                   else ()
                 ) 
                 else 
                   'background-color:white;'
                }
                display: block;
                flex-direction:column;
                justify-content:center;margin:6px; padding:3px;
               " 
         id="A{$n}{$node/name()}_{$d}-" 
         n='{$n}{$node/name()}_{$d}-' 
         class='cha' >
      <div style="{
                  if (not ($node/*)) 
                  then ('
                    display:flex;
                    background-color:#eceff1;
                    border-style:none;
                  ') 
                  else (
                    if ($node/*) 
                    then 'border:1px solid #eceff1' 
                    else ()
        )}">
        <div style='margin:5px; width:5.5em'>{
          if ($node/name()='entry') 
          then () 
          else 
            concat(upper-case(substring($node/name(),1,1)),substring($node/name(),2),if ($node/*)then () else ' : ')
        }</div>
        <div >{
          if(not($node/*))
          then 
            if ($node/name()=('def','etym','note','usg')) 
            then (
              <textarea   style="width:360px; margin:4px;"   
                          n="{$n}{$node/name()}_{$d}-"                     
                          onkeyup="
                                   var id = document.activeElement.getAttribute('n');champToXml();
                                   document.getElementById('sauver').style.display = 'block';
                                  " 
                          class="xsd adminInput" 
                          type="text" 
                          name="{$node/name()}" 
                          onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                   th=this;
                                   var id = th.getAttribute('n'); 
                                   document.getElementById(id).style.border='8px solid red';
                                  " 
                          onBlur="this.style.backgroundColor='white';this.style.color='black';
                                  var nom = '{$node/name()}';
                                  var y = document.getElementsByTagName(nom);
                                  for (i = 0; i &lt; y.length; i++) &#x0007B;
                                  y[i].style.border='none';
                                  &#x0007D;;
                                  " 
                          placeholder='{$node/text()}'></textarea> 
            )
            else
              <input   style="width:160px; margin:4px;"   
                       n="{$n}{$node/name()}_{$d}-"                     
                       onkeyup="
                                var id = document.activeElement.getAttribute('n');champToXml();
                                document.getElementById('sauver').style.display = 'block';
                               " 
                       class="xsd adminInput" 
                       type="text" 
                       name="{$node/name()}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$node/name()}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$node/text()}'></input> 
                               
          else (
            isi:fic_to_masque($node/*,concat($n,$node/name(),'_',$d,'-'))
          )
        }</div>                   
      </div>
    </div>,
      if($node/name() = 'entry')
      then ()
      else
      <div style="text-align:right;
                  margin-right:10px;"
           id="F{$n}{$node/name()}_{$d}-"
      >
        <a style='position:right;color:#607d8b;
                  cursor:pointer;
                 '
           divid="A{$n}{$node/name()}_{$d}-" 
           n='{$n}{$node/name()}_{$d}-'
           onClick='addChM($("#ch{$node/name()}").children().eq(0),"F{$n}{$node/name()}_{$d}-");addXml($("#xml{$node/name()}").children(),"#{$n}{$node/name()}_{$d}-");chClone.insertBefore($(this).parent());'
           
        >
        Ajouter ({$node/name()})
        </a>
      </div>
    
  )
               
};

declare function isi:xmlblank($name,$xsd){
  if ($xsd[@name=$name and @type="xsd:string"])
  then element {$name}{}
  else
  element 
    {$name}
    {
      for $i in $xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element[not(@ref=('img','mark'))]
      return 
        if ($i/@ref) 
        then isi:xmlblank($i/@ref/string(),$xsd) 
        else element {$i/@name/data()}{}
    }
};

declare function isi:xmlblankall(){
  (:for $i in db:open('tei_fiche_exemple')//*[name()!='root']:)
  for $i in db:open('tei_fiche')/*/*
  return <OOO id="xml{$i/@name/data()}" hidden="hidden">{
    isi:xmlblank($i/@name,db:open('tei_fiche')/*/*)
}</OOO>
};

declare function isi:fic_to_masque_blank($fic,$n){

for $node at $d in $fic
return 
(
    <div style="{if ($node/name()='entry') 
                 then (
                   if ($node/*) 
                   then('background-color:#cfd8dc;') 
                   else ()
                 ) 
                 else 
                   'background-color:white;'
                }
                display: block;
                flex-direction:column;
                justify-content:center;margin:6px; padding:3px;
               " 
         class='cha' >
      <div style="{
                  if (not ($node/*)) 
                  then ('
                    display:flex;
                    background-color:#eceff1;
                    border-style:none;
                  ') 
                  else (
                    if ($node/*) 
                    then 'border:1px solid #eceff1' 
                    else ()
        )}">
        <div style='margin:5px; width:5.5em'>{
          if ($node/name()='entry') 
          then () 
          else 
            concat(upper-case(substring($node/name(),1,1)),substring($node/name(),2),if ($node/*)then () else ' : ')
        }</div>
        <div >{
          if(not($node/*) or $node/name()='def')
          then 
            if ($node/name()=('def','etym')) 
            then (
              <textarea   style="width:360px; margin:4px;"   n=""                     
                          onkeyup="var id = document.activeElement.getAttribute('n');champToXml();" 
                          class="xsd adminInput" 
                          type="text" 
                          name="{$node/name()}" 
                          onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                   th=this;
                                   var id = th.getAttribute('n'); 
                                   document.getElementById(id).style.border='8px solid red';
                                  " 
                          onBlur="this.style.backgroundColor='white';this.style.color='black';
                                  var nom = '{$node/name()}';
                                  var y = document.getElementsByTagName(nom);
                                  for (i = 0; i &lt; y.length; i++) &#x0007B;
                                  y[i].style.border='none';
                                  &#x0007D;;
                                  " 
                          value='{$node/text()}'></textarea> 
            )
            else
              <input   style="width:160px; margin:4px;"   n=""                     
                       onkeyup="var id = document.activeElement.getAttribute('n');champToXml();" 
                       class="xsd adminInput" 
                       type="text" 
                       name="{$node/name()}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$node/name()}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$node/text()}'></input> 
                               
          else (
            isi:fic_to_masque_blank($node/*,concat($n,$node/name(),'_',$d,'-'))
          )
        }</div>                   
      </div>
    </div>
  )
               
};

declare function isi:fic_to_masque_blank_from_XSD($name,$xsd,$start){
  
  
  if (($xsd[@name=$name and @type="xsd:string"]) or $xsd[@name=$name and ./*/@mixed='true' and not(./*/(*:sequence,*:choice,*:all))] or $name="a" or $name='def' or $name='usg' or $name='quote')
  
 (: Si élément du XSD à ce stade ne contient qu'un string, afficher input/texarea et pas de récursion :)
  then (
      <div style="
                   'background-color:white;'
                
                display: block;
                flex-direction:column;
                justify-content:center;margin:6px; padding:3px;
               " 
         class='cha' >
      <div style="
                 
                    display:flex;
                    background-color:#eceff1;
                    border-style:none;
                  ">
        <div style='margin:5px; width:5.5em'>{
         
            concat(upper-case(substring($name,1,1)),substring($name,2), ' : ')
        }</div>
        <div >{
           
            if ($name=('def','etym')) 
            then (
              <textarea   style="width:360px; margin:4px;"   n=""                     
                          onkeyup="
                                   var id = document.activeElement.getAttribute('n');champToXml();
                                   document.getElementById('sauver').style.display = 'block';
                                  " 
                          class="xsd adminInput" 
                          type="text" 
                          name="{$name}" 
                          onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                   th=this;
                                   var id = th.getAttribute('n'); 
                                   document.getElementById(id).style.border='8px solid red';
                                  " 
                          onBlur="this.style.backgroundColor='white';this.style.color='black';
                                  var nom = '{$name}';
                                  var y = document.getElementsByTagName(nom);
                                  for (i = 0; i &lt; y.length; i++) &#x0007B;
                                  y[i].style.border='none';
                                  &#x0007D;;
                                  " 
                          value='{$name}'></textarea> 
            )
            else
              <input   style="width:160px; margin:4px;"   n=""                     
                       onkeyup="
                               var id = document.activeElement.getAttribute('n');champToXml();
                               document.getElementById('sauver').style.display = 'block';
                               " 
                       class="xsd adminInput" 
                       type="text" 
                       name="{$name}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$name}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$name}'></input> 
                               
          
        }</div>                   
      </div>
    </div>
    
    (::)
  ,
  
      if($name = 'entry')
      then ()
      else
      <div style="text-align:right;
                  margin-right:10px;"
           id=""
           xmlid=""
           class="ajou"
      >
        <a style='position:right;color:#607d8b;
                  cursor:pointer;
                 '
           xmlid=""
           onClick='addChM($("#ch{$name}").children().eq(0),"");
                    
                    addXml($("#xml{$name}").children(),"#".concat($(this).parent().prev().attr("n")));
                    chClone.insertBefore($(this).parent());'
           
        >
        Ajouter ({$name})
        </a>
      </div>
      
  (::)
  )
  
  
  (: Si élément du XSD à ce stade ne contient qu'un string n'est pas le noeud racine, afficher input/texarea et pas de récursion :)
  else
    if ($xsd[@name=$name and @type="xsd:string"])
    then (
      if ($name=('def','etym')) 
            then (
              <textarea   style="width:360px; margin:4px;"   n=""                     
                          onkeyup="
                                  var id = document.activeElement.getAttribute('n');champToXml();
                                  document.getElementById('sauver').style.display = 'block';
                                  " 
                          class="xsd adminInput" 
                          type="text" 
                          name="{$name}" 
                          onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                   th=this;
                                   var id = th.getAttribute('n'); 
                                   document.getElementById(id).style.border='8px solid red';
                                  " 
                          onBlur="this.style.backgroundColor='white';this.style.color='black';
                                  var nom = '{$name}';
                                  var y = document.getElementsByTagName(nom);
                                  for (i = 0; i &lt; y.length; i++) &#x0007B;
                                  y[i].style.border='none';
                                  &#x0007D;;
                                  " 
                          value='{$name}'></textarea> 
            )
            else
              <input   style="width:160px; margin:4px;"   n=""                     
                       onkeyup="
                               var id = document.activeElement.getAttribute('n');champToXml();
                               document.getElementById('sauver').style.display = 'block';
                               " 
                               
                       class="xsd adminInput" 
                       type="text" 
                       name="{$name}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$name}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$name}'></input> 
    )
  else(
  <div style="{if ($name='entry') 
                 then (
                   if ($xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element) 
                   then('background-color:#cfd8dc;') 
                   else ()
                 ) 
                 else 
                   'background-color:white;'
                }
                display: block;
                flex-direction:column;
                justify-content:center;margin:6px; padding:3px;
               " 
         class='cha' >
      <div style="{
                  if (not ($xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element)) 
                  then ('
                    display:flex;
                    background-color:#eceff1;
                    border-style:none;
                  ') 
                  else (
                    if ($xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element) 
                    then 'border:1px solid #eceff1' 
                    else ()
        )}">
        <div style='margin:5px; width:5.5em'>{
          if ($name='entry') 
          then () 
          else 
            concat(upper-case(substring($name,1,1)),substring($name,2),if ($xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element)then () else ' : ')
        }</div>
        <div >{
          
            for $i in $xsd[@name=$name]/
                *:complexType/
                (*:sequence,*:choice)/
                *:element[not(@ref=('img','mark'))]
            return 
      
        (: Si noeud en dessous alors récursion :)
        if ($i/@ref) 
        then isi:fic_to_masque_blank_from_XSD($i/@ref/string(),$xsd,'') 
        
        (: Si pas de noeud en dessous:)
        else 
        
                   <div style="
                   'background-color:white;'
                
                display: block;
                flex-direction:column;
                justify-content:center;margin:6px; padding:3px;
               " 
         class='' >
      <div style="
                 
                    display:flex;
                    background-color:#eceff1;
                    border-style:none;
                  ">
        <div style='margin:5px; width:5.5em'>{
         
            concat(upper-case(substring($i/@name/string(),1,1)),substring($i/@name/string(),2), ' : ')
        }</div>
        <div >{
           
            if ($i/@name/string()=('def','etym')) 
            then (
              <textarea   style="width:360px; margin:4px;"   n=""                     
                          onkeyup="
                                  var id = document.activeElement.getAttribute('n');champToXml();
                                  document.getElementById('sauver').style.display = 'block';
                                  " 
                          class="xsd adminInput" 
                          type="text" 
                          name="{$name}" 
                          onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                   th=this;
                                   var id = th.getAttribute('n'); 
                                   document.getElementById(id).style.border='8px solid red';
                                  " 
                          onBlur="this.style.backgroundColor='white';this.style.color='black';
                                  var nom = '{$name}';
                                  var y = document.getElementsByTagName(nom);
                                  for (i = 0; i &lt; y.length; i++) &#x0007B;
                                  y[i].style.border='none';
                                  &#x0007D;;
                                  " 
                          value='{$name}'></textarea> 
            )
            else
              <input   style="width:160px; margin:4px;"   n=""                     
                       onkeyup="
                                var id = document.activeElement.getAttribute('n');champToXml();
                                document.getElementById('sauver').style.display = 'block';
                               " 
                       class="xsd adminInput" 
                       type="text" 
                       name="{$name}" 
                       onClick="this.style.backgroundColor='#CACACA';this.style.color='white';
                                  th=this;
                                   var id = th.getAttribute('n'); 
                                document.getElementById(id).style.border='8px solid red';
                       " 
                       onBlur="this.style.backgroundColor='white';this.style.color='black';
                               var nom = '{$name}';
                               var y = document.getElementsByTagName(nom);
                               for (i = 0; i &lt; y.length; i++) &#x0007B;
                                 y[i].style.border='none';
                               &#x0007D;;
                               " value='{$name}'></input> 
                               
          
        }</div>                   
      </div>
    </div>
          
          
        }</div>                   
      </div>
    </div>
   ,
   
    <div style="text-align:right;
                  margin-right:10px;"
           id=""
           xmlid=""
           class="ajou"
      >
        <a style='position:right;color:#607d8b;
                  cursor:pointer;
                 '
           xmlid=""
           onClick='addChM($("#ch{$name}").children().eq(0),"");
                    
                    addXml($("#xml{$name}").children(),"#".concat($(this).parent().prev().attr("n")));
                    chClone.insertBefore($(this).parent());'
           
        >
        Ajouter ({$name})
        </a>
      </div> 
      
    
  )
    
};

declare function isi:fic_to_masque_blank_all(){
  for $i in db:open('tei_fiche_exemple')//*[name()!='root']
order by $i
return <OOO id="ch{$i/name()}" hidden="hidden">{isi:fic_to_masque_blank($i,'')}</OOO>
};

declare function isi:fic_to_masque_blank_all2(){
  for $i in db:open('tei_fiche')/*/*
order by $i
return <OOO id="ch{$i/@name/string()}" hidden="hidden">{isi:fic_to_masque_blank_from_XSD($i/@name/string(),db:open('tei_fiche')/*/*,'start')}</OOO>
};


(:CORPUS:)

declare function isi:tokenize-sentences($string as xs:string*)
(:https://gist.github.com/joewiz/5889711:)
{
    let $words := tokenize($string, '\s+')[. ne '']
    let $first-sentence := normalize-space(isi:get-first-sentence($words, ''))
    return
        ($first-sentence,
        let $word-count-of-sentence := count(tokenize($first-sentence, ' '))
        return
            if (count($words) gt $word-count-of-sentence) then
                isi:tokenize-sentences(string-join(subsequence($words, $word-count-of-sentence + 1), ' '))
            else
                ()
        )
};

declare function isi:get-first-sentence($words as xs:string*, $sentence as xs:string) {
    
    (: if there are no (more) words to check, we're done, so return whatever we have for the sentence :)
    if (empty($words)) then 
        $sentence
    
    (: begin analyzing the word :)
    else
        let $word := subsequence($words, 1, 1)
        let $next := subsequence($words, 2, 1)
        let $rest := subsequence($words, 2)
        
        (: criteria :)
        let $final-punctuation-marks := '.?!'
        let $post-punctuation-possibilities := '’”"'')'
        let $pre-punctuation-possibilities := '‘“"''('
        let $final-punctuation-regex := concat('[', $final-punctuation-marks, '][', $post-punctuation-possibilities, ']?$')
        let $capitalized-abbreviation-test-regex := '[A-Z][.?!]'
        let $capitalized-test-regex := concat('^[', $pre-punctuation-possibilities, ']*?[A-Z]')
        let $words-with-ignorable-final-punctuation-marks := ('Mr.', 'Mrs.', 'Dr.', 'Amb.')
        let $known-phrases-with-ignorable-final-punctuation-marks := ('U.S. Government')
        
        (: test the word against the criteria :)
        let $word-ends-with-punctuation := matches($word, $final-punctuation-regex)
        let $word-is-capitalized-abbreviation := matches($word, $capitalized-abbreviation-test-regex)
        let $next-word-is-capitalized := matches($next, $capitalized-test-regex)
        let $word-has-ignorable-punctuation := $word = $words-with-ignorable-final-punctuation-marks
        
        return
            
            (: if word doesn't end with punctuation (like "the" or "Minister"), 
               then consider it part of the existing sentence and move to the next word. :)
            if (not($word-ends-with-punctuation)) then 
                isi:get-first-sentence(
                    $rest, 
                    concat($sentence, ' ', $word)
                    )
                    
            (: if the word is in our list of words with allowable final punctuation (like "Mr."), 
               then consider it part of the existing sentence and move to the next word. :)
            else if ($word-has-ignorable-punctuation) then 
                isi:get-first-sentence(
                    $rest, 
                    concat($sentence, ' ', $word)
                    )

            (: if the word is an abbreviation and the next word is not capitalized (like "A.B.M. treaty"),
               or if the word ends with punctuation and the next word is not capitalized (like "'What?' he asked.")
               then consider it part of the existing sentence and move to the next word. :)
            else if (($word-is-capitalized-abbreviation or $word-ends-with-punctuation) and not($next-word-is-capitalized)) then
                isi:get-first-sentence(
                    $rest, 
                    concat($sentence, ' ', $word)
                    )

            (: if the word is part of a known phrase that could be mistaken for the end of a sentence (like "U.S. Government"),  
               then consider it part of the existing sentence and move to the next word. :)
            else
                let $sorted-phrases := 
                    (: order by word length, longest to shortest :)
                    for $phrase in $known-phrases-with-ignorable-final-punctuation-marks
                    order by string-length($phrase) descending
                    return $phrase
                let $words-as-string := string-join($words, ' ')
                let $matching-phrase := 
                    subsequence(
                        for $phrase in $sorted-phrases
                        return
                            if (starts-with($words-as-string, $phrase)) then 
                                $phrase
                            else ()
                        , 1, 1)
                return
                    if ($matching-phrase) then
                        let $phrase-length := count(tokenize($matching-phrase, ' '))
                        let $rest := subsequence($words, $phrase-length + 1)
                        return
                            isi:get-first-sentence(
                                $rest, 
                                concat($sentence, ' ', $matching-phrase)
                                )
                    
                    (: the word ends the sentence - we're done with this sentence! :)
                    else 
                        concat($sentence, ' ', $word)
};
