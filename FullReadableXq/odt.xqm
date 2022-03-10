(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace request = "http://exquery.org/ns/request";
import module namespace isi = 'http://www.isilex.fr/isi-repo';
declare namespace text =
  "urn:oasis:names:tc:opendocument:xmlns:text:1.0";
declare namespace officeooo = "http://openoffice.org/2004/office";


declare
  %rest:path('/odt-{$type}-{$id}')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:odt($type,$id) 
    as element(html){
    <html>{
       if ($isi:testid) then
        isi:template(
          let $contenu := 
                for $x in db:open($isi:bdd)//fiche[id=$id]/entry
                  return 
                    if ($x//sense) then 
                       ( <text:line-break/>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P1">{data($x//orth)}</text:p>
                         ,<text:line-break/>
                         
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">{string-join($x//gram//text(),' ')}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P3">{string-join($x//etym//text(),' ')}</text:p>
                         , <text:line-break/>
                         , <text:line-break/>
                         ,for $y in $x//sense return
                            (
                            <text:p text:style-name="P6">{string-join(data($y/@*),' ') }</text:p>
                            ,<text:p text:style-name="P6">{string-join(data($y/usg//text()),' ') }</text:p>
                            ,<text:line-break/>
                            ,<text:p text:style-name="P2">{string-join($y/def//text(),' ')}</text:p>
                            ,<text:p text:style-name="P3">{string-join($y//xr//text(),' ')}</text:p>
                            ,<text:line-break/>
                            ,for $c in $y//cit return for $i in $c/quote return
                              (<text:p text:style-name="P3">{string-join($i//text(),' ')}</text:p>
                              ,<text:line-break/>
                              ,<text:p text:style-name="P4">{string-join($i/following-sibling::*[1]//text(),' ')}</text:p>)
                            )
                          ,<text:line-break/>
                          ,<text:line-break/>)
                     else 
                         (<text:line-break/>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P1">{data($x//orth)}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">{string-join($x//form//text(),' ')}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">Voir {string-join(data($x//xr//text()),' ') }</text:p>
                         ,<text:line-break/>
                         ,<text:line-break/>)

      let $docmanifest := doc("static/scripts/PDF/ooo/manifeste.xml")

      let $content :=
      <office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0" xmlns:css3t="http://www.w3.org/TR/css3-text/" office:version="1.2">
      <office:scripts/>
        <office:font-face-decls>
          <style:font-face style:name="Lohit Hindi1" svg:font-family="&apos;Lohit Hindi&apos;"/><style:font-face style:name="Times New Roman" svg:font-family="&apos;Times New Roman&apos;" style:font-family-generic="roman" style:font-pitch="variable"/><style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="swiss" style:font-pitch="variable"/>
          <style:font-face style:name="Lohit Hindi" svg:font-family="&apos;Lohit Hindi&apos;" style:font-family-generic="system" style:font-pitch="variable"/>
          <style:font-face style:name="WenQuanYi Zen Hei" svg:font-family="&apos;WenQuanYi Zen Hei&apos;" style:font-family-generic="system" style:font-pitch="variable"/>
          </office:font-face-decls>
           <office:automatic-styles>
           <style:style style:name="P1" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-weight="bold" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-weight-asian="bold" style:font-weight-complex="bold"/><style:paragraph-properties fo:margin-top="0.1598in" fo:margin-bottom="0in" style:contextual-spacing="false"/></style:style>
        <style:style style:name="P2" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-weight-complex="normal"/></style:style>
        <style:style style:name="P3" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-style="italic" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-style-asian="italic" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-style-complex="italic" style:font-weight-complex="normal"/><style:paragraph-properties fo:margin-top="0.1in" fo:margin-bottom="0in" fo:margin-left="0.2in" style:contextual-spacing="false"/></style:style>
        <style:style style:name="P4" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-style="normal" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-style-asian="normal" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-style-complex="normal" style:font-weight-complex="normal"/></style:style>
        <style:style style:name="P5" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:text-align="justify" style:justify-single-word="false"/><style:text-properties fo:font-size="12pt" fo:font-style="normal" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="10.5pt" style:font-style-asian="normal" style:font-weight-asian="normal" style:font-size-complex="12pt" style:font-style-complex="normal" style:font-weight-complex="normal"/></style:style>
        <style:style style:name="P6" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:margin-top="0.1598in" fo:text-align="justify" style:justify-single-word="false"/><style:text-properties fo:font-size="9pt" fo:font-style="normal" fo:font-weight="bold" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="10.5pt" style:font-style-asian="normal" style:font-weight-asian="bold" style:font-size-complex="12pt" style:font-style-complex="normal" style:font-weight-complex="bold"/></style:style></office:automatic-styles>
        <office:body>
          <office:text><text:sequence-decls><text:sequence-decl text:display-outline-level="0" text:name="Illustration"/>
            <text:sequence-decl text:display-outline-level="0" text:name="Table"/>
              <text:sequence-decl text:display-outline-level="0" text:name="Text"/>
              <text:sequence-decl text:display-outline-level="0" text:name="Drawing"/>
              </text:sequence-decls>
              {$contenu}
       </office:text></office:body>
     </office:document-content>

        let $filename :=  $id||'.odt'
        let $filenamePdf :=  $id||'.pdf'
        let $disposition := concat("attachment; filename=""",$filename,"""")
        let $rep := file:base-dir()||'static/scripts/PDF/baseOdt/'
     return
        (file:write(concat($rep,'content.xml'),$content),
        file:write(concat($rep,'manifest.xml'),$docmanifest),
    
     zip:zip-file(
      <zip:file xmlns="http://expath.org/ns/zip" href="{$rep||$filename}">
        <zip:dir name = "META-INF">
          <zip:entry name="manifest.xml" src="{concat($rep,'manifest.xml')}"/>
        </zip:dir>
        <zip:entry name="content.xml" src="{concat($rep,'content.xml')}"/>
        <zip:entry name="styles.xml" src="{concat($rep,'styles.xml')}"/>
        <zip:entry name="settings.xml" src="{concat($rep,'settings.xml')}"/>
        <zip:entry name="meta.xml" src="{concat($rep,'meta.xml')}"/>
      </zip:file>),
      <a style="display:none;">{proc:execute($isi:unoconv||'/unoconv', $rep||$filename)}</a>,
      <h2>{isi:lang-text("xmlodt")} {upper-case(data(db:open($isi:bdd)//fiche[id=$id]//orth//text())[1])} ({$id})</h2>,
      <p>{isi:lang-text("DwnldRdy")}:</p>,
      if ($type='odt') 
          then <a href="/static/scripts/PDF/baseOdt/{$filename}" class="button">{isi:lang-text('download')} .odt</a>
          else <a href="/static/scripts/PDF/baseOdt/{$filenamePdf}" class="button">{isi:lang-text('download')} .pdf</a>
    )
  )  
  else isi:template(
	<div>
	  {if ($isi:testLang='en') 
	   then 
	    <p>Thank you for your interset in Isilex. PDF and ODT export is a convenient capacity: please, <a href="/register">register</a> and <a href="/login">log</a> in before you try.</p>
	   else 
	   <p>Merci de vous <a href="/register">enregistrer</a> ou de vous <a href="/login">connecter</a> pour essayer.</p>
	   }
	</div>
)}</html>
};
   
 
declare
  %rest:path('/export')
   %output:method("html")
  %output:omit-xml-declaration("no")
   function isilex:export() as element(html){
     <html>{
       isi:template(
         (<h2>Export</h2>,
         <form id="export" name="export" method="POST" action="/exportDo">
          <label>From id:</label><input type="text" name="from" value=""/>
          <label>to id: </label><input type="text" name="to" value=""/>
          <input type="submit" class="button" value="OK"/>
         </form>
       )  
       )
     
     }</html>
 };  

declare
  %rest:path('/exportDo')
  %rest:POST
  %rest:form-param('from','{$from}','2')
  %rest:form-param('to','{$to}','9')
  %output:method("html")
  %output:omit-xml-declaration("no")
  function isilex:exportDo($from, $to){
   if ( $isi:testid4 ) then 
    isi:template( 
    
    
      let $rep := file:base-dir()||'static/scripts/PDF/export/'
      let $zipName := session:id()||".zip"

       return
      
        (
        
  for $id at $c in (xs:integer($from) to xs:integer($to))[. = db:open($isi:bdd)//id] 
  where $c < 11
    return
     
     let $contenu := for $x in db:open($isi:bdd)//entry[id=$id] 
                  return 
                    if ($x//sense) then 
                       (
                          <text:line-break/>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P1">{data($x//orth)}</text:p>
                         ,<text:line-break/>
                         
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">{string-join($x//gram//text(),' ')}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P3">{string-join($x//etym//text(),' ')}</text:p>
                         , <text:line-break/>
                         , <text:line-break/>
                         ,for $y in $x//sense return
                            (
                            <text:p text:style-name="P6">{string-join(data($y/@*),' ') }</text:p>
                            ,<text:p text:style-name="P6">{string-join(data($y/usg//text()),' ') }</text:p>
                            ,<text:line-break/>
                            ,<text:p text:style-name="P2">{string-join($y/def//text(),' ')}</text:p>
                            ,<text:p text:style-name="P3">{string-join($y//xr//text(),' ')}</text:p>
                            ,<text:line-break/>
                            ,for $c in $y//cit return for $i in $c/quote return
                              (<text:p text:style-name="P3">{string-join($i//text(),' ')}</text:p>
                              ,<text:line-break/>
                              ,<text:p text:style-name="P4">{string-join($i/following-sibling::*[1]//text(),' ')}</text:p>)
                            )
                          ,<text:line-break/>
                          ,<text:line-break/>
                          )
                    
                     else 
                     
                         (<text:line-break/>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P1">{data($x//orth)}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">{string-join($x//form//text(),' ')}</text:p>
                         ,<text:line-break/>
                         ,<text:p text:style-name="P2">Voir {string-join(data($x//xr//text()),' ') }</text:p>
                         ,<text:line-break/>
                         ,<text:line-break/>)
                  
let $docmanifest := doc("static/scripts/PDF/ooo/manifeste.xml")

let $content :=
            <office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0" xmlns:css3t="http://www.w3.org/TR/css3-text/" office:version="1.2">
              <office:scripts/>
                <office:font-face-decls>
                  <style:font-face style:name="Lohit Hindi1" svg:font-family="&apos;Lohit Hindi&apos;"/><style:font-face style:name="Times New Roman" svg:font-family="&apos;Times New Roman&apos;" style:font-family-generic="roman" style:font-pitch="variable"/><style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="swiss" style:font-pitch="variable"/>
                    <style:font-face style:name="Lohit Hindi" svg:font-family="&apos;Lohit Hindi&apos;" style:font-family-generic="system" style:font-pitch="variable"/>
                    <style:font-face style:name="WenQuanYi Zen Hei" svg:font-family="&apos;WenQuanYi Zen Hei&apos;" style:font-family-generic="system" style:font-pitch="variable"/>
                    </office:font-face-decls>
            
                    <office:automatic-styles>
                    <style:style style:name="P1" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-weight="bold" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-weight-asian="bold" style:font-weight-complex="bold"/><style:paragraph-properties fo:margin-top="0.1598in" fo:margin-bottom="0in" style:contextual-spacing="false"/></style:style>
                    <style:style style:name="P2" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-weight-complex="normal"/></style:style>
                    <style:style style:name="P3" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-style="italic" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-style-asian="italic" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-style-complex="italic" style:font-weight-complex="normal"/><style:paragraph-properties fo:margin-top="0.1in" fo:margin-bottom="0in" fo:margin-left="0.2in" style:contextual-spacing="false"/></style:style>
                    <style:style style:name="P4" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="9pt" fo:font-style="normal" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="7.84999990463257pt" style:font-style-asian="normal" style:font-weight-asian="normal" style:font-size-complex="9pt" style:font-style-complex="normal" style:font-weight-complex="normal"/></style:style>
                    <style:style style:name="P5" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:text-align="justify" style:justify-single-word="false"/><style:text-properties fo:font-size="12pt" fo:font-style="normal" fo:font-weight="normal" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="10.5pt" style:font-style-asian="normal" style:font-weight-asian="normal" style:font-size-complex="12pt" style:font-style-complex="normal" style:font-weight-complex="normal"/></style:style>
                    <style:style style:name="P6" style:family="paragraph" style:parent-style-name="Standard"><style:paragraph-properties fo:margin-top="0.1598in" fo:text-align="justify" style:justify-single-word="false"/><style:text-properties fo:font-size="9pt" fo:font-style="normal" fo:font-weight="bold" officeooo:rsid="0011b0b6" officeooo:paragraph-rsid="0011b0b6" style:font-size-asian="10.5pt" style:font-style-asian="normal" style:font-weight-asian="bold" style:font-size-complex="12pt" style:font-style-complex="normal" style:font-weight-complex="bold"/></style:style></office:automatic-styles>
                    <office:body>
                      <office:text><text:sequence-decls><text:sequence-decl text:display-outline-level="0" text:name="Illustration"/>
                        <text:sequence-decl text:display-outline-level="0" text:name="Table"/>
                          <text:sequence-decl text:display-outline-level="0" text:name="Text"/>
                          <text:sequence-decl text:display-outline-level="0" text:name="Drawing"/>
                          </text:sequence-decls>
                          {$contenu}
                          </office:text></office:body></office:document-content>
            
            let $filename :=  $id||'.odt'
            let $filenamePdf :=  $id||'.pdf'
            let $disposition := concat("attachment; filename=""",$filename,"""")
            let $repManifest := file:base-dir()||'static/scripts/PDF/baseOdt/'

     return
     
    (
    file:write(concat($rep,'content.xml'),$content),
    file:write(concat($rep,'manifest.xml'),$docmanifest),
    
       zip:zip-file(
        <zip:file xmlns="http://expath.org/ns/zip" href="{$rep||$filename}">
          <zip:dir name = "META-INF">
            <zip:entry name="manifest.xml" src="{concat($rep,'manifest.xml')}"/>
          </zip:dir>
          <zip:entry name="content.xml" src="{concat($rep,'content.xml')}"/>
          <zip:entry name="styles.xml" src="{concat($repManifest,'styles.xml')}"/>
          <zip:entry name="settings.xml" src="{concat($repManifest,'settings.xml')}"/>
          <zip:entry name="meta.xml" src="{concat($repManifest,'meta.xml')}"/>
        </zip:file>)
        
    ,
    
    <a style="display:none;">{proc:execute($isi:unoconv||'unoconv', $rep||$filename)}</a>
    )
    
   ,
   
   zip:zip-file(
        <zip:file xmlns="http://expath.org/ns/zip" href="{$rep||$zipName}">
        {
          for $files in file:list($rep)[matches(.,"pdf")]
          return
           <zip:entry name="{$files}" src="{concat($rep,$files)}"/>
        }
        </zip:file>)
  
   ,
   
   for $files in file:list($rep)[not(matches(.,'zip'))]
    return
     file:delete($rep||$files)
   ,
  <p><a class="button" href="/static/scripts/PDF/export/{$zipName}">Download your zip File</a></p> 
   
   )
  )
  else  isi:template(isi:lang-text('unauthorized_access') )
   };