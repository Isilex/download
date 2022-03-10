(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

declare
  %updating
  %rest:path("/delImage/{$name}")
  function isilex:delImg($name)
{
  update:output(web:redirect("/Images"))),
  (
  for $x in db:open('images')/root/file[@new_name=$name]
  let $path := string(data($x/@path))
   return 
   (
    delete node $x,
    file:delete($path || $name)
   )

  )
};

declare
  %updating
  %rest:POST
  %rest:path("/upload")
  %rest:form-param("files", "{$files}")
  function isilex:upload($files)
{
  update:output(web:redirect("/Images"))),
  for $name    in map:keys($files)
  let $content := $files($name)
  let $newName := replace(string(current-dateTime()),'([^:]*):([0-9]{2}):([0-9]{2}).*','$1-$2-$3') || '.' || string(replace($name,'[^\.]*\.(.*)','$1'))
  let $path    := string(file:base-dir()) ||'/static/images/upload/'
  return (
      insert node <file orig_name="{ $name }" new_name="{$newName}" path="{ $path }"/> as first into db:open('images')/root,
    file:write-binary(concat($path,$newName), $content)

  )
};

declare
 %rest:path('/Images')
 %output:method('html')
 function isilex:Img(){
  isi:template(
  <div>
  <h2>Images</h2>
  <p><a href="/uploadImages">Upload Images</a></p>
		{
		for $x in db:open('images')/root/file return 
			<div id="descImg">
			<table>
				<tr >
				  <td width="100px">{data($x//@orig_name)}</td>
				  <td width="200px"><img width="150px" height="80px" src="{'/static/images/upload/'||data($x/@new_name)}"/></td>
				  <td width="100px"><a target="_blank" href="{replace(string($isi:domaine || '/static/images/upload/'||data($x/@new_name)),' ','')}">{replace(string($isi:domaine || '/static/images/upload/'||data($x/@new_name)),' ','')}</a></td>
				  <td><a href="/delImage/{data($x/@new_name)}" class="button">Del</a></td>
				</tr>
			</table>
			</div>
		}
  </div>
  )
 };

declare
 %rest:path('/uploadImages')
 %output:method('html')
 function isilex:uploadImg(){
  isi:template(
  (<h2>Upload Images</h2>
  ,
  	<form action="/upload" method="POST" enctype="multipart/form-data">
  		<input type="file" name="files"  multiple="multiple"/>
  		<input type="submit"/>
	</form>)
  )
 };

