module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare variable $isilex:oldCode :=
<!--  

                <div style='padding-left:8px;'><a class='button' onClick="
                    var target = document.getElementById(id);
                    var t = this.parentNode.previousElementSibling;
                    t.children[0].value='';
                    target.innerHTML = '';
                 ">Clear</a></div> -->
                 ;


declare function isilex:fic_to_masque($fic,$n){

for $node at $d in $fic
  return 
  if ($node/name()=('id','valid','auteur') ) then () else
  <div style="{if ($node/name()='entry') then (if ($node/*) then('background-color:#cfd8dc;') else ()) else 'background-color:white;'}display: block;flex-direction:column; justify-content:center;margin:6px; padding:3px;
  " 
        id="A{$n}{$node/name()}.{$d};" 
        n='{$n}{$node/name()}.{$d};' 
        class='{if ($node/*) then "separator" else ()}' >
        <div style="{if (not ($node/*)) then ('display:flex;background-color:#eceff1;border-style:none;') else ()}">
        <div style='margin:5px; width:5.5em'>{if ($node/name()='entry') then () else concat(upper-case(substring($node/name(),1,1)),substring($node/name(),2),if ($node/*)then () else ' : ')}</div>
        <div >{if(not($node/*))then 
          if ($node/name()='def') then (
            <textarea   style="width:360px; margin:4px;"   n="{$n}{$node/name()}.{$d};"                     
                       onkeyup="var id = document.activeElement.getAttribute('n');champsActu();" 
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
                               " value='{$node/text()}'></textarea> 
          )
          else
          <input   style="width:160px; margin:4px;"   n="{$n}{$node/name()}.{$d};"                     
                       onkeyup="var id = document.activeElement.getAttribute('n');champsActu();" 
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
                                 isilex:fic_to_masque($node/*,concat($n,$node/name(),'.',$d,';'))
                               )}</div>
                               
                </div>
                </div>
               
};

declare function isilex:fic_to_template($fic,$n){

for $node at $d in $fic
  let $id := concat($n,$node/name(),'.',$d,';')
  return 
  element{$node/name()}{attribute id {$id},for $i in $node/@* return attribute{$i/name()}{$i/data()},isilex:fic_to_template($node/*,$id),$node/text()}
};

declare function isilex:ele_gen($xsd){
  for $i in $xsd return if ($i/name()='xs:element') then

  element {$i/@name} {for $att in $i/xs:complexType/xs:attribute return attribute {$att/@name}{data($att)},isilex:ele_gen($i/*)}
  else if ($i/*) then (isilex:ele_gen($i/*)) else ()
};

declare function isilex:js($node,$id,$cp){
  let $save := concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("FIN ',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $n := concat('var ',$node/name(),' = document.createElement("',$node/name(),'");',$node/name(),'.setAttribute("id",',$cp,');',if($node/@*) then for $attr in $node/@* return concat($node/name(),'.setAttribute("',$attr/name(),'","',data($attr),'");') else ())
  let $ppch := if($node/*) then concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("FIN',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);',$cp,'++;') else()
  let $pch := if($node/*) then () else concat('tr = document.createElement("tr");td = document.createElement("td");td.setAttribute("class","masqueSaisieCourt");var t = document.createTextNode("',$node/name(),'");td.appendChild(t);tr.appendChild(td); td = document.createElement("td");input=document.createElement("input");input.setAttribute("n",cp);input.setAttribute("onkeyup","champToXml();");input.setAttribute("type","text");input.setAttribute("class","xsd admin");input.setAttribute("onClick","',"champToXml() ",'");td.appendChild(input);tr.appendChild(td);td = document.createElement("td"); a =document.createElement("a");var t = document.createTextNode("X");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh();");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);',$cp,'++;')
  let $attch := for $att in $node/@* return concat('tr = document.createElement("tr");td = document.createElement("td");td.setAttribute("class","masqueSaisieCourt");var t = document.createTextNode("',$att/name(),'");td.appendChild(t);tr.appendChild(td); td = document.createElement("td");input=document.createElement("input");input.setAttribute("n",cp);input.setAttribute("name","',$att/name(),'");input.setAttribute("onkeyup","champToXmlA();");input.setAttribute("type","text");input.setAttribute("class","xsd admin");input.setAttribute("onClick","',"champToXmlA() ",'");td.appendChild(input);tr.appendChild(td);td = document.createElement("td"); a =document.createElement("a");var t = document.createTextNode("X");a.setAttribute("class","button");a.setAttribute("n",cp);a.setAttribute("onClick","clearCh();");a.appendChild(t); td.appendChild(a);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);')
  let $fch := if($node/*) then concat('tr = document.createElement("tr");td = document.createElement("td");var t = document.createTextNode("',$node/name(),'");td.appendChild(t);tr.appendChild(td);','temp = document.getElementById(pa).nextElementSibling; par = document.getElementById(pa).parentNode; par.insertBefore(tr,temp);') else ()
  let $ch := 
    for $i at $c in $node/* 
    return isilex:js($i,$id,($cp))
  let $add := for $i in $node/* return concat($node/name(),'.appendChild(',$i/name(),');')
  return ($n,$ppch,$ch,$attch,$pch,$fch,$add)
};

declare function isilex:div($node,$id,$cp,$c){
  
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
    return isilex:div($i,$id,($cp),$c+1)
  let $add := for $i in $node/* return concat($node/name(),'.parentNode.appendChild(',$i/name(),');')
  let $add2 := if ($c=1) then for $i in $node/* return concat('var nod = document.getElementById(fid);','var sibl = document.getElementById(fid).parentNode.nextElementSibling; var up =document.getElementById(fid).parentNode ; up.insertBefore(',$node/name(),',sibl);') else ()
  let $add3 := if ($c!=1) then for $i in $node/* return concat('var nod = document.getElementById(cp);','var sibl = document.getElementById(cp).parentNode.nextElementSibling; var up =document.getElementById(cp).parentNode ; up.insertBefore(',$node/name(),',sibl);') else ()
  return ($n,$add2,$add3,$MainNode,$ch,$pch,if ($c=1) then $appendToMainNode else())
};

declare function isilex:xsdfic($fic,$xsd,$n){

for $i at $d in $fic[name()=$xsd/@name]
  let $nc := concat($n,$i/name(),'.',$d,';')
  let $att := for $at in $i/@* return attribute {$at/name()}{$at/string()}
  return (element {$i/name()}{ 
  attribute id {$nc},$att,
  if(normalize-space(string-join($i/text()))) then $i/text() else (),
  isilex:xsdfic($i/*,$xsd/*,$nc)
}
),

for $i at $d in $fic[name()=$xsd/@ref]
  return isilex:xsdfic($fic,$xsd/ancestor::*[last()]/*[@name=$i],$n)




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
  isilex:xsdfic($i/*,$x/*,$nc)
}
)
:)
case 'xs:complexType' return
  isilex:xsdfic($fic,$x/*,$n)
    
case 'xs:sequence' return
  isilex:xsdfic($fic,$x/*,$n)

case 'xs:choice' return
  isilex:xsdfic($fic,$x/*,$n)

default return ()

};



declare function isilex:chafic($fic,$xsd,$n){
  
for $element in $xsd
return switch ($element/name())

case 'xs:complexType' return
  isilex:chafic($fic,$element/*,$n)

case 'xs:sequence' return
  isilex:chafic($fic,$element/*,$n)

case 'xs:choice' return
  isilex:chafic($fic,$element/*,$n)
  


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
          <input      n="{$n}{$node/name()}.{$d};"                     
                       onkeyup="var id = document.activeElement.getAttribute('n');champToXmlA();champsActu();" 
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
                   isilex:chafic($node/*,$element[@name=$node/name()]/*,concat($n,$node/name(),'.',$d,';'))
                   
                }</div>
                else ()
default return ()


};


declare variable $isilex:xsElements := for $x in db:open('xsd')//xs:element[not(./xs:complexType)][not(./@name = $isilex:interdit)] return data($x/@name);
declare variable $isilex:interdit := ('id','date','valid','auteur');

declare
%rest:path('/new-fiche')
%output:method('html')
function isilex:new-fiche(){
   if ($isi:testid2) then
   <html>
    <head>
      <title>{$isi:titre-name}</title>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/codemirror/3.19.0/codemirror.js"></script>
    <script>   function champToXmlA()&#x0007B;
                    var id = document.activeElement.getAttribute("n");
                    var newff = document.activeElement.value;
                    var att = document.activeElement.getAttribute("name");
                    document.getElementById(id).setAttribute(att,newff);


&#x0007D;</script>
    {db:open('scripts')//entry[./@id="headerIsiPhp"]/header/h} 
    {$isi:Css}
    <script>{db:open('scripts')//entry[./@id="masqueCh"]/text()}</script>
    <script>
 
      var cp =0; 
   
{

db:open("scripts","scripts.xml")/root/entry[1]/header/script[last()]/text()
}
</script>


<script> 
  function actu() &#x0007B;
    var nom = this.getAttribute('name')&#x0003B;
    var id = this.getAttribute('n')&#x0003B;
    document.getElementById(id).style.border='8px solid red'&#x0003B;
  &#x0007D;
                                
  function clearCh(th)&#x0007B;
    var d = th; 
    id = d.getAttribute("n");
    var target = document.getElementById(id);
    var t = d.parentNode.previousElementSibling;
    t.children[0].value='';
    target.innerHTML = ''; 
  &#x0007D;
</script>
<script src="/static/scripts/masque.js"></script>
{isi:fic_to_masque_blank_all2(),isi:xmlblankall()}
  </head>
  
  <body onLoad="actuChamps();">
 
  {$isi:ruler}
  
   <div id="global" class="protect">
     <div id="xmlMasque">
       <div id="tableau">   
         <div id="sauver" style="display:none;">
           <a class="button" href="#" onClick="var el = $('#controle');el.find('[style]').removeAttr('style');var el = $('#controle');el.find('[id]').removeAttr('id');document.getElementById('validFiche').value = 'false';champsBase();">Save</a>
           {
           if (db:open('site')/root/masterAdminValidation='on') 
           then
           <a class="button" href="#" onClick="var el = $('#controle');el.find('[style]').removeAttr('style');var el = $('#controle');el.find('[id]').removeAttr('id');document.getElementById('validFiche').value = 'ask';champsBase();">Save and validate</a>
           else ()
           }
         </div>
         {isi:fic_to_masque(db:open('tei_fiche_exemple')/root/entry,())}
       </div>
     </div>

     <div id="controle">
       {isi:fic_to_template(db:open('tei_fiche_exemple')/root/entry,())}
     </div>
     
     <form id="valid" name="valid" method="POST" action="/saveNew">
        <input type="hidden" id="inputFiche" name="inputFiche" value=""/>
        <input type="hidden" id="validFiche" name="validFiche" value="false"></input>
     </form>
     
     <div id="pg" style="display:none;"></div>
     
   </div>
   {db:open('scripts')//entry[./@id="codeMirrorStart"]/script}
   </body>
   </html>
   
   else isi:template(isi:t('unauthorized_access'))
};