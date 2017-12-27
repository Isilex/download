module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
%rest:path('/tout/{$nb}')
%output:method('html')
function isilex:rubrique-tout($nb){
  let $contenu :=(
    if ($nb!=1) then
    <a href="/tout/{$nb -1}">
      <img height="20px" src="/static/images/Preceding.png"/>
    </a>
    else ()
    ,    
    if (count(db:open($isi:bdd)//fiche) <= $nb*100)
    then ()
    else    
    <a href="/tout/{$nb+1}">
      <img height="20px" src="/static/images/Next.png"/>
    </a>,
    <h2>Fiches</h2>
    ,
    <ul
      style="
             flex-direction: row;
             flex-wrap: wrap;
             justify-content: space-around;
             border: solid 1px;
             min-height: 100px;
             "
    >{
    for $i in db:open($isi:bdd)/*/fiche[position()> 100*($nb -1)][position()<=100]
    order by ($i/entry/form/orth)[1]
    return
      <li class='index'
          style="
                "
      >
        <a href="/fiche/{$i/id/data()}">{if(upper-case($i/entry/form/orth[1])) then (upper-case($i/entry/form/orth[1])) else '!Pas de vedette'}</a>
      </li>
  }</ul>
)
  return
    isi:template($contenu)
};

declare 
 %rest:path('/rubrique/{$path=.+}/{$indice=[0-9]+}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:rubrique($path,$indice)
{

  let $l := string-join(('^',$path))  
  let $al := 
    if ($path = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')) 
    then (
      <h2>{isi:t('letter'),' ',$path}</h2>,
      <table>{
       (:for $d in (1 to ($isi:di)) return:)
       for $d in (xs:integer($indice) to xs:integer($indice) + 9) 
       return
       (
       (for $i at $count in db:open($isi:bdd)/*/fiche
       [matches((entry/form/orth)[1],concat('^',$l),'i')]
       [some $o in entry/form/orth satisfies matches($o,concat('^',$l),'i')]
       [if ($isi:systemV='on') then valid='true' or auteur=$isi:name else valid] 
       (:La restriction sur l'affichage si la validation est active:)
       order by  xs:dateTime($i/creationDate) descending
       return 
         <tr>
         <td class="{if ($i/auteur=$isi:name) then 'miens' else 'index'} {if ($i/valid='true') then () else 'enCours'} ">
           <a href='{if ($i/valid="true") 
                     then "/fiche/"||$i/id/text() 
                     else 
                       if ($i/form/auteur=$isi:name) 
                       then "/fiche/"||$i/id/text() 
                       else (
                         "/fiche/"||$i/id/text() 
                       ) }'
           >
             {upper-case(($i/entry/form/orth)[1])}
           </a>
         </td>
         </tr>
       ))[$d]
      }</table> 
      ,
      <div id="dddd">{
        let $cnt := 
          count(db:open($isi:bdd)/*/fiche
                [matches(entry/form/orth,concat('^',$l),'i')]
                [if ($isi:systemV='on') 
                 then valid='true' or valid='ask' or auteur=$isi:name 
                 else valid
                ]
               )
        return(
          if (xs:integer($indice) - 1 lt 10) 
          then
            <a href="/rubrique/{$path}/{xs:integer($indice) - (xs:integer($indice) - 1)}">
              <img height="20px" src="/static/images/Preceding.png"/>
            </a>
          else 
            let $diff := $cnt - xs:integer($indice)
            return 
              <a href="/rubrique/{$path}/{xs:integer($indice) - 10}">
                <img height="20px" src="/static/images/Preceding.png"/>
              </a>
          ,
          <div id="mm">{$indice} / {$cnt}</div>
          ,
          if ($cnt - xs:integer($indice) lt 10) 
          then
            <a href="/rubrique/{$path}/{xs:integer($indice) + ($cnt - xs:integer($indice))}"><img height="20px" src="/static/images/Next.png"/></a>
          else 
            let $diff := $cnt - xs:integer($indice)
            return 
              <a href="/rubrique/{$path}/{xs:integer($indice) + 10}">
                <img height="20px" src="/static/images/Next.png"/>
              </a>
        )
      }</div> 
    )
    else (
      <h2>Tags</h2>,
      <ul>{
      for $i in db:open($isi:bdd)/*/fiche[tags/tag=$path] 
      return $i}
      </ul>
    )
    
  return isi:template($al)

};

 
declare
 %rest:path("/categories")
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:cat()
{
isi:template(
  <div>    
  <h2>Categories</h2>
  {for $x in (
  	distinct-values(db:open($isi:bdd)//@med[not(.='')]),(:vestige des premières DTD:)
  	distinct-values(db:open($isi:bdd)//@mod[not(.='')]), 
  	distinct-values(db:open($isi:bdd)//@dom[not(.='')]),
  	distinct-values(db:open($isi:bdd)//usg[not(.='')])(:la CATEGORIE correspond à l'élément <usg/> de la fiche:)
  	)
  order by $x
     return 
     <ul class="tabUserAdmin">
     <li><a  class="button" href="#" onClick="document.getElementById('idefx').value='{data($x)}';document.getElementById('idefx3').submit();">#{data($x)}</a></li>
     </ul>}
  </div>

)
};