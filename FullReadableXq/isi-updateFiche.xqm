module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
%updating
%rest:path('/saveNew')
%rest:POST
%output:method("html")
%rest:form-param('inputFiche','{$inputFiche}')
%rest:form-param('validFiche','{$valid}','false')
function isilex:saveNew($inputFiche,$valid){
  
  if ($isi:testid2 and $inputFiche != '')
  then (
    
    let $id := 
      if (db:open($isi:bdd)//id) 
      then 
        max( 
        for $int in db:open($isi:bdd)/root/fiche/id[matches(.,"^[0-9]+$")] 
        return xs:integer($int)
        )+1 
      else 1
      
    let $entry :=
      try {
      fetch:xml(
        replace(replace($inputFiche,'gramgrp','gramGrp'),'<img\s?(.*?)>',"<img $1/>")
        , map { 'chop': true(), 'intparse': true() })
      }
      catch * {
        <message>Non XMLisable{$err:description}</message>
      }
        
    let $validate := if (db:open('site')//dtd='on') then validate:xsd-info($entry, db:open('tei_fiche')) else ()
    let $fiche :=
      <fiche>
        <id>{$id}</id>
        <creationDate>{current-dateTime()}</creationDate>
        <auteur>{$isi:name}</auteur>
        <permission>none</permission>
        <valid>{$valid}</valid>
        {$entry}
      </fiche>
    
    return(
      
        if (empty($validate) and not(matches($entry,'Non XMLisable')))
        then(
          insert node $fiche into db:open($isi:bdd)/*,
          update:output(web:redirect("/modif-"||$id||"?message=Votre%20fiche%20a%20bien%20%C3%A9t%C3%A9%20sauv%C3%A9e")))
        )
        else (
          db:output("Erreur: COPIER VOTRE TRAVAIL : " || $entry || $inputFiche)
        )   
    )
  )
  
  else(
    db:output(isi:template(isi:t('unauthorized_access')))
  )

};

declare
%updating
%rest:path('/saveFiche')
%rest:POST
%rest:form-param('inputFiche','{$inputFiche}')
%rest:form-param('idFiche','{$id}','')
%rest:form-param('bddId',"{$bddId}", 'bdd')
%rest:form-param('validFiche','{$valid}','false')
function isilex:saveFiche($inputFiche,$id,$valid,$bddId){
  
  if ($isi:testid2)
  then
  let $entry :=
  try{
     fetch:xml(
      replace(replace(replace($inputFiche,'gramgrp','gramGrp'),'<img\s(.*?)>',"<img $1/>"),'&#xD;','')
      , map { 'chop': true(), 'intparse': true() })
  }
  catch * {
   <node>{"Non XMLisable" || $err:description}</node>
  }
      
  let $fiche :=
    <fiche>
      <valid>{if (db:open('site')/root/masterAdminValidation='on') then $valid else 'false'}</valid>
      {
        (:C'est ici qu'on gère la sauvegarde des demaindes de validation:)
        db:open($isi:bdd)/*/fiche[id=$id]/*[not(name()=('entry','valid'))]
      }
      <modification>
        <modificationDate>{current-dateTime()}</modificationDate>
        <modifiedBy>{$isi:name}</modifiedBy>
        <lastVersion>{db:open($isi:bdd)/*/fiche[id=$id]/entry}</lastVersion>
      </modification>
      {
        $entry
      }
    </fiche>
  
  let $validate := 
    if (db:open('site')//dtd= 'on') 
    then (
      validate:xsd-info($entry, db:open('tei_fiche'))
    ) 
    else ()
    
  return(
    if (
      empty($validate)
      and $id !=''
      and $inputFiche !=''      
      and (
        $isi:name=$fiche/auteur or 
        $isi:testid4 or 
        ($isi:testid2 and $fiche/permission=('members','anyone'))
      )
      and not(matches($entry,'Non XMLisable'))
    )
    then (
      replace node db:open($isi:bdd)/*/fiche[id=$id] with $fiche,
       update:output(web:redirect("/modif-"||$id||"?message=Votre%20fiche%20a%20bien%20%C3%A9t%C3%A9%20sauv%C3%A9e")))
      
      (:/modif-{$id}?message=Votre%20fiche%20a%20bien%20%C3%A9t%C3%A9%20sauv%C3%A9e
      update:output(web:redirect("/xsdOk-"||$id[1]))) :)
    )
    else (
      (:
      update:output(web:redirect("/xsdPb-"||$id[1]||"-{string($validate[1])}")))
    :)
    db:output(isi:template(($entry,$inputFiche)))
  )
  )
  
  
  else(
    db:output(isi:template(isi:t('unauthorized_access')))
  )
  
};

declare
%output:method('html')
%rest:POST
%rest:form-param("inputFiche","{$fiche}","")
%rest:form-param("xsd","{$xsd}","")
%rest:path('/validate-xsd')
function isilex:validateFicheXsdReturnResponse($fiche,$xsd){
  if ($isi:testid2)
  then
  let $schema := if (not(empty($xsd)) and $xsd!='' and db:exists($xsd)) then db:open($xsd) else db:open('tei_fiche')
  let $entry := 
    try {
      fetch:xml(
        replace(normalize-space($fiche),"gramgrp","gramGrp"),
        map{"chop":"true"}
      )
    }
    catch * {
      "Non XMLisable"
    }
  let $ereurs := 
    try {
      fetch:xml(
        replace(normalize-space($fiche),"gramgrp","gramGrp"),
        map{"chop":"true"}
      )
    }
    catch * {
      $err:description
    }
  let $valid := 
    try {
      if (db:open('site')//dtd='on')
      then
      validate:xsd-info($entry,$schema)
      else ()
    }
    catch * {
      "Non XMLisable"
    }
    
  return
  
    if (not(empty($fiche)) and $fiche != '' and not($entry='Non XMLisable'))
    then (
      if (empty($valid) and not($entry='Non XMLisable'))
      then ("IsilexOk")
      else ("ATTENTION Votre fiche n'a pas été sauvée  " || $valid, $ereurs
    )
  )
    else 
    
    ("ATTENTION Votre fiche n'a pas été sauvée  " || $valid, $ereurs
    )
    
  else ("Non autorisé")
};

 declare
 %updating
 %rest:path('/ftMark-{$id}')
 function isilex:ftMark($id)
 {
  if (isi:validateXML((db:open($isi:bdd)//fiche[./id=$id]/entry)[1])='Le document est conforme') 
    
   then
    (update:output(web:redirect("/modif-"||data($id)))),

     if (not(db:open($isi:bdd)//entry[../id=$id]//mark))
     then
       let $f := for $x in db:open($isi:bdd)//entry[../id=$id] return $x
       let $a := distinct-values(for $x in $f/descendant::* return data(node-name($x)))
        return
        for $x in $f//*[node-name(.)=$a]
                       [not(string(node-name(.))='orth')][not(string(node-name(.))='gloss')]
                       [./text() contains text 
                       {data(db:open($isi:bdd)//entry[../id=$id]//orth)}
                        using case insensitive 
                        using stemming 
                        using fuzzy]
                        
                        return
                        
                          replace node $x 
                          with 
                          ft:mark($x[text() contains text {data(db:open($isi:bdd)//entry[../id=$id]//orth)} 
                          using case insensitive 
                          using stemming
                             using fuzzy])
      else ()
       )
       else  
       (update:output(web:redirect("/validShow")))
       ,
        insert node 
          <entry>
            <id>{$id}</id>
            <time>{current-dateTime()}</time>
            <message>
            {isi:validateXML((db:open($isi:bdd)//entry[../id=$id][1]))}
            </message></entry> as first into db:open('errors')/bdd
        )
};
 
 declare
 %rest:path('/validShow')
 %output:method('html')
 function isilex:validShow(){
   (for $x in db:open('errors')//entry[1]
      return 
       <div>
        <p>{data($x/time)}</p>
        <p>{$x/message}</p>
       </div>)
 };