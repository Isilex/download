module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

(:CORPUS:)
declare
 %rest:path('/listeCorpus')
 %output:method('xhtml')
 function isilex:listyCorpus(){
  isi:template(
     <div> 
     <h2>Corpus list</h2>
     <ul>
      {for $x in db:list-details()[matches(.,'corpus')] 
      return <li><a href="/displayC[{replace($x,'bdd_corpus_','')}][10]">{$x}</a></li>}
      </ul>
    </div>
  )
};

declare
 %rest:path('/displayC[{$titreCorpus}][{$index}]')
 %output:method('html')
 function isilex:displayCorpus($titreCorpus, $index){
  isi:template(
  <div>
  <h2>Display Corpus {$titreCorpus}</h2>
 <p>
  <form method='POST' action='idefx[{$titreCorpus}]'>
 <ul id='concordancier'>
  <li class='concorde'><label>Concordance de motif ou Co-occurrences:</label></li>
  <li class='concorde'><input id="req" name='req' type='text' width='120px' placeholder='ex:directeur établissement'/></li>
  <li class='concorde'><input type='submit'/></li>
  <li class='concorde'><p><input type='checkbox' name='fuzzy' value='on'/>Levensthein</p></li>
 </ul>
 </form>
 </p>
 <p style="float:left; width: 100%;">
     <li style='list-style:none; float: left; width: 50px;'><a href='/displayC[{$titreCorpus}][{xs:integer($index) - 10}]'><img src='http://www.isilex.fr/static/images/Preceding.png' width='20px'/></a></li>
     <li style='list-style:none; float: left; width: 50px;'><a href='/displayC[{$titreCorpus}][{xs:integer($index) + 10}]'><img src='http://www.isilex.fr/static/images/Next.png' width='20px'/></a></li>
</p>  {
   let $db := 'bdd_corpus_' || $titreCorpus
   let $nbCorpus := distinct-values(db:open($db)//@id)
   let $atom:= distinct-values(for $x in db:open($db)//p/@n return $x)
   let $display := if ($index='') then 10 else xs:integer($index)
   for $c in $nbCorpus
   return
   
    <div id='displayC' style='float:left; width: {round-half-to-even(80 div count($nbCorpus))}%; margin-left: 8px; padding: 5px; border-left: 1px solid black;'>
    {
    for $n in $atom[xs:integer(.) ge ($display - 10)][xs:integer(.) le $display] return
    for $x in db:open($db)//p[@id=$c][@n=$n] return $x
    
    }
    </div>
  }
  </div>
  )
  };

declare
 %rest:path('/uploadTextes')
 %output:method('html')
 function isilex:uploadCorp(){
  isi:template(
  (<h2>Upload Corpus</h2>
  ,
  	<form action="/uploadTextesSave" method="POST" enctype="multipart/form-data">
  		<p><label>Titre Corpus:</label>
  		<input type='text' name='titreCorpus'/></p>
  		<p><input type="file" name="files"  multiple="multiple"/></p>
  		<p><label>Tokenization par lignes ?</label>
  		<input type="checkbox" name="ligneOnOff" value="1"/></p>
  		<input type="submit"/>
	</form>)
  )
 };
 
 declare
  %updating
  %rest:POST
  %rest:path("/uploadTextesSave")
  %rest:form-param("files", "{$files}")
  %rest:form-param("ligneOnOff", "{$ligneOnOff}")
   %rest:form-param("titreCorpus", "{$titreCorpus}")
  function isilex:uploadCorp($files,$titreCorpus, $ligneOnOff)
{
  update:output(web:redirect("/createDbCorp-"||$titreCorpus||"-{if (not($ligneOnOff='1')) then 0 else 1}"))),
  for $name in map:keys($files)
  let $content := $files($name)
  let $newName := replace(string(current-dateTime()),'([^:]*):([0-9]{2}):([0-9]{2}).*','$1-$2-$3') || '.' || string(replace($name,'[^\.]*\.(.*)','$1'))
  let $path    := string(file:base-dir()) ||'/static/Corpus/' || $titreCorpus || '/txt/'
  return (
      insert node <file titreCorpus="{ $titreCorpus }" orig_name="{ $name }" new_name="{$newName}" path="{ $path }"/> as first into db:open('bdd_corp')/root,
      if (not(file:exists($path))) then file:create-dir($path) else (), 
    
    file:write-binary(concat($path,$newName), $content)

  )
};

declare
 %updating
 %rest:path('/createDbCorp-{$titreCorpus}-{$ligneOnOff}')
  function isilex:createDbCorp($titreCorpus,$ligneOnOff)
  {  
     ( 
       update:output(web:redirect("/insertDbCorp-"||$titreCorpus||"-{$ligneOnOff}"))),
       db:create('bdd_corpus_' || $titreCorpus, <bdd/>,'doc.xml',map {'ftindex': true(), 'stemming': true()})
     )
  };

declare
 %updating
 %rest:path('/insertDbCorp-{$titreCorpus}-{$mode}')
  function isilex:insertDbCorp($titreCorpus, $mode)
  {  
     ( 
       update:output(web:redirect("/traiteCorpuXml-"||$titreCorpus||"-10"))),
       let $fileList := (for $x in db:open('bdd_corp')//file[./@titreCorpus=$titreCorpus] return <f name='{data($x/@new_name)}' place='{data($x/@path)}'>{data($x/@orig_name)}</f>)
   for $files at $countf in $fileList
    let $file := data($files/@place)||'/'|| data($files/@name)
    let $doc := if ($mode='1') then file:read-text-lines($file)[not(.='')] else 
                        for $l in tokenize(file:read-text($file),'\n\n')[not(.='')] return
                        isi:tokenize-sentences($l)
    return
     for $l at $count in $doc return
      insert node 
            <p id="{$countf}" n="{$count}">{$l}</p>
         into db:open('bdd_corpus_' || $titreCorpus)
        ,
        db:optimize(
        'bdd_corpus_' || $titreCorpus,
        false(),
        map { 'ftindex': true(), 'stemming':true() }
        )
    )

};

declare
 %rest:path('/traiteCorpuXml-{$titreCorpus}-{$index}')
 %output:method('html')
 function isilex:traiteXmlCorp($titreCorpus, $index){
  isi:template(
  <html>
   <head>
     {db:open('scripts')//entry[./@id="headerIsiPhp"]/header}
     {$isi:Css}
   </head>
   <body>
  <h2>Corpus : {$titreCorpus}</h2>
   <a href='/traiteCorpuXml-{$titreCorpus}-{xs:integer($index) - 10}'>&lt;-</a>
  <a href='/traiteCorpuXml-{$titreCorpus}-{xs:integer($index) + 10}'>-&gt;</a>
  <a href='#' onClick='document.getElementById("inputFiche").value = document.getElementById("txtdef").value; document.getElementById("valid").submit();'>Save</a>
  {
   <div id="xml" style="width: 90%;">
         <textarea id="txtdef"
                   name="txtDef" 
                   width="250px" 
                   height="40px;">
       {
       let $display := if ($index='') then 10 else xs:integer($index)
       let $db := 'bdd_corpus_' || $titreCorpus
       let $atom:= distinct-values(for $x in db:open($db)//p/@n return $x)
       for $n in $atom[xs:integer(.) ge ($display - 10)][xs:integer(.) le $display] return
       <atom>
        {for $sentences in db:open($db)//p[@n=$n]
        order by number($sentences/@corpus)
         order by number($sentences/@n)
         return $sentences}</atom> 
       }
         </textarea>
         
         <div id="controle">
         </div>
         
         <form id="valid" name="valid" method="POST" action="/saveCorpusQuit-{$titreCorpus}">
    	  <input type="hidden" id="inputFiche" name="inputFiche" value=""/>
    	</form>
    
  </div>
   
  }
      <script>{for $x in db:open('scripts')//entry[./@id="codeMirrorStart"]/script return replace($x,'0,1,2,3,4,5','100000000')}</script>
  </body>
  </html>
  )
  };

 
declare
 %updating
 %rest:path('/saveCorpusQuit-{$titreCorpus}')
 %output:method('html')
 %rest:POST
 %rest:form-param("inputFiche", "{$fiche}")
 function isilex:sauveXmlCorp($fiche, $titreCorpus){
 (
       update:output(web:redirect("/traiteCorpuXml-"||$titreCorpus||"-10"))),
    let $db := 'bdd_corpus_' || $titreCorpus
    let $txt := '<t>'|| $fiche||'</t>'
    let $node :=  html:parse((normalize-space($txt)))
    for $newP in $node//p, $x in db:open($db)//p[@id=$newP/@id][@n=$newP/@n] return replace node $x with $newP
    )
 };
 
 declare
 %rest:path('/idefx[{$titreCorpus}]')
 %output:method('html')
 %rest:POST
 %rest:form-param("req", "{$req}")
 %rest:form-param("fuzzy", "{$fuzzy}")
 function isilex:idefxXmlCorp($titreCorpus, $req, $fuzzy){
  isi:template(
  <html>
   <head>
     {db:open('scripts')//entry[./@id="headerIsiPhp"]/header}
     {$isi:Css}
   </head>
   <body>{
let $db := 'bdd_corpus_' || $titreCorpus
let $motif := lower-case(replace(normalize-unicode($req, "NFD"), "[\p{M}]", ""))
let $indexes := if ($fuzzy = 'on') then (for $j in (1 to count(tokenize($motif,"\W+"))) return <index n="{$j}"><entry>{tokenize($motif,"\W+")[$j]}</entry>{for $x in ft:tokens($db) return $x[. contains text {ft:tokenize($motif)[$j]} using stemming using fuzzy using case insensitive using diacritics insensitive]}</index>) else (for $j in (1 to count(tokenize($motif,"\W+"))) return <index n="{$j}"><entry>{tokenize($motif,"\W+")[$j]}</entry>{for $x in ft:tokens($db) return $x[. contains text {ft:tokenize($motif)[$j]} using stemming using wildcards using case insensitive using diacritics insensitive]}</index>)

let $indexesGeneraux := for $x in ft:tokens($db) return $x
return
if (matches($motif,' [a-z0-9]')) then <r>
<table>
<th>Ecart</th><th>Score</th>
{for $i in (-4 to 11) return <th>{$i}</th>}
{
for $x in db:open($db)/*
 let $source := ft:tokenize($x)

 let $ind:=
 for $j in (1 to count(tokenize($motif," ")))
  for $x in $indexes[./@n=$j]/entry
   return
    if (index-of($source,$x) != 0)
     then <ngr n="{$j}">{for $o in index-of($source,$x) return <i>{$o}</i>}</ngr>
     else ()

let $res :=
 for $x in $ind[./@n=1]/i, $y in $ind[./@n!=1]/i[xs:integer(.) - 10 <= xs:integer($x)][xs:integer(.) > xs:integer($x)] return <r st="{$x}" e="{$y}" dif="{$y - $x}"/>

return

for $w in $res
 let $dif := xs:integer(number($w/@dif))
 order by $dif
 return
 <tr><td id="score">{$dif}</td>
 <td id="{if (round-half-to-even(( 100 * count($res[xs:integer(number(./@dif))=$dif])) div (max((for $x in distinct-values($res//@dif) return count($res[./@dif=$x])))))=100) then "scoretop" else "score" }">
{round-half-to-even(( 100 * count($res[xs:integer(number(./@dif))=$dif])) div (max((for $x in distinct-values($res//@dif) return count($res[./@dif=$x]))))) }%
</td>
 {
  for $p at $n in (xs:integer(number($w/@st)) - 4 to xs:integer(number($w/@e) + 4))
   where $n < 16
   return
   if ($p = xs:integer(number($w/@st)) or $p = xs:integer(number($w/@e)) )
   then <td id="masterkw">{$source[$p]}</td>
   else
   <td>{$source[$p]} <div id="small">({data($indexesGeneraux[.=$source[$p]]/@count)})</div></td>
 }</tr>
}</table>
</r>

else

let $indexes := if ($fuzzy = 'on') then for $x in ft:tokens($db) return $x[. contains text {$motif} using stemming using fuzzy using case insensitive] else for $x in ft:tokens($db) return $x[. contains text {$motif} using stemming using wildcards using case insensitive]
let $indexesGeneraux := for $x in ft:tokens($db) return $x
return
<r>
Levenshtein: {if ($fuzzy = 'on') then 'activé' else 'désactivé'}
<table>
{for $i in (-4 to 4) return <th>{$i}</th>}
{
for $x in db:open($db)/*
 let $source := ft:tokenize($x)

 for $m in ($indexes)
 group by $m
 order by $m
 return
 let $i:=  index-of($source,$m)
  for $n in $i
   return
    <tr>{
     for $window in ($n - 4 to $n + 4)
      return
       if ($window = $n)
        then <td id="masterkw"><b>{$source[$window]}</b></td>
        else <td>{replace($source[$window],"[Ø123456789]","")} <div id="small">({data($indexesGeneraux[.=$source[$window]]/@count)})</div></td>
     }</tr>
}</table>
</r>

}
        </body>
        </html>
)
};