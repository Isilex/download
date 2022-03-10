(:Authors: Xavier-Laurent Salvador & Sylvain Chea:)

module namespace isilex = 'http://www.isilex.fr';
import module namespace session = "http://basex.org/modules/session";
import module namespace request = "http://exquery.org/ns/request";
import module namespace isi = 'http://www.isilex.fr/isi-repo';

(:
******************************************************************
  Le fichier du moteur de Recherches
  (c) - I-Def // Algo réalisé par X.-L.S.
  Exploité initialement en partie dans le moteur idef(x)
******************************************************************
:)

declare
 %rest:path(
  '/idefx'
)
 %output:method(
  'html'
)
 %rest:POST
  %rest:form-param(
  'idefx',"{
    $idefx
  }"
)
 function isilex:idefx(
  $idefx
)
 {
 isi:template(
   <div>
   {
  let $countres := 0 
  let $seuilmax := 50 
  let $google := 
		   (
        for $y score $sc in db:open(
          $isi:bdd
        )//entry
                     
        (: 
        *****************************************************
        Activer ici pour limiter les recherches aux fiches qui auraient été validées par l'administrateur principal
        ****************************************************
        :)
                    [(
          .//text()) contains text {
          $idefx
        }
                    all words
                    using fuzzy
                    using stemming
			              using case insensitive
                    using diacritics insensitive
                    ordered distance at most 5 words 
                    or
                    //sense/@* contains text {
          $idefx
        }
                    all words
                    using stemming
			              using case insensitive
                    using diacritics insensitive
                    ordered distance at most 5 words 
		    ]
                  (:
                  *******************************************************
                  $bonus est le marqueur de pertinence des résultats. ça signifie qu'en plus du classement interne de Basex, on va tester la nature du résultat. Par exemple, si une fiche a pour vedette le mot recherché, c'est plus important que si la fiche contient le mot 40 fois. On afecte un bonus de 2000/3000/4000/5000 pour peser sur le résultat initial. On peut facilement rajouter des critères pour rendre les choses encore plus pertinentes.
                  *******************************************************
                  :)
		    let $bonus := if (
          $y//orth contains text {
            $idefx
          } using case insensitive
        ) 
					then 5000
				  else if (
          $y//orth contains text {
            $idefx
          } all words using case insensitive using wildcards
        ) 
					then 4000
				  else if (
          $y//ref//text() contains text {
            $idefx
          } using case insensitive
        )
					then 3500
				  else if (
          $y//def contains text {
            $idefx
          } using case insensitive using stemming
        ) 
					then 3000
				  else if (
          $y//quote contains text {
            $idefx
          } using case insensitive using stemming
        )  
					then 2000
				  else 0 

                        
                        order by number(
          $sc
        ) + $bonus descending, $y/form/orth ascending 
                        
                        return
	 
                        <div id="res">
                         <div id="resres" score="{
          number(
            $sc
          ) + $bonus
        }" dom="">
			    {
				(
				 <a onclick="window.opener.location.href = this.href;
                    window.close();" 
                    href="/fiche/{
              data(
                $y/form/orth
              )
            }">
				<div class="keyword dico {
					if (
                number(
                  $sc
                ) + $bonus>4000
              )  
					then "gold"
					else ()
				}">{
              data(
                $y/form/orth
              )
            }</div></a>
				 ,
				 for $i in (
              distinct-values(
                $y//sense
              ),distinct-values(
                $y//domaine
              )
            ) return <div id="domax">{
              data(
                $i
              )
            }</div>
				,
           (:
           **********************************
           Les extraits affichés autour du résultat sont définis ici
           **********************************
           :)
                                 if (
              $y//quote[.//text() contains text {
                $idefx
              } using case insensitive]
            ) 
                                    then 
                                     <div id="ext"> 
                                    {
                                    (
                                    for $xx in $y//quote
                                     [.//text() contains text {
                  $idefx
                } using case insensitive using wildcards] 
                                      return 
                                       ft:extract(
                  $xx[.//text() contains text {
                    $idefx
                  } using case insensitive using wildcards],"mark",215
                )
                                    )[1]
                                    }
                                </div> 
                                else () 
				,
				if (
              $y//sense
                                 [.//text() contains text {
                $idefx
              } using case insensitive using wildcards]//usg
            )
				then 
				<div id="mention">
				{
				for $yy in $y//sense
				 [.//text() contains text {
                $idefx
              } using case insensitive using wildcards]//usg 
			         return 
				 (
				  <div id="sousent" class="keyword float">
				   <a href="#" onClick="document.getElementById(
                  'idefx'
                ).value='{
                  replace(
                    data(
                      $yy
                    ),"\.",""
                  )
                }';document.getElementById(
                  'idefx3'
                ).submit();">
				   #{
                  data(
                    $yy
                  )
                }
				   </a> 
				 </div>
				)
				}</div>
				else ()
				)  
			   }
			   </div>
			   <div id="mentionsyno">
                           {
           
			     if (
            number(
              $sc
            ) + $bonus > 3500 and number(
              $sc
            ) + $bonus < 4000
          ) 
                                then 
                                (
                                for $ii at $pp in distinct-values(
              $y//ref//text()
                                [. contains text {
                $idefx
              } using case insensitive using wildcards]
            ) 
                                return  
                                <div id="resres">
				  <div id="ext">
				    <mark style="cursor:pointer; border: 5px dotted white ;" onClick="openInParent(
              href=\'/fiche/{
                data(
                  $ii
                )
              }\'
            )">#{
              data(
                $ii
              )
            } (
              {
                $pp
              }
            )
				    </mark>
				  </div>
				</div> 
                                ) 
                           else ()
                                }
			   </div>
             

                          {
          if (
            number(
              $sc
            ) + $bonus > 3500 and number(
              $sc
            ) + $bonus < 4000
          ) 
				then () 
				else
        (:
        **************************************************************
        C'est ici qu'on construit l'affichage HTML du résultat. La div resres est stylée par le CSS chosi. 
        ***************************************************************
        :)
				  <div id="resres" score="{
            number(
              $sc
            ) + $bonus
          }">
                          		<div id="ext">[...] 
				{
            for $p in ft:extract(
              $y//text()[. contains text {
                $idefx
              } 
                    all words
			              using wildcards
                    using stemming
			              using case insensitive
                    using diacritics insensitive
                    ordered distance at most 5 words ],"mark",210
            ) return $p
          }
          (:
          ***************************************************************
          210, c'est le nombre de caractères qu'on affiche autour de l'extract qu'on montre au public. Il suffit d'augmenter le nombre pour avoir une citation plus longue; de la réduire en diminuant; de la mettre à 0 pour n'afficher que l'occurrence.
          ***************************************************************
           :)
                          		</div>
				  </div>
        }
                        </div>
      )
		      (:
          STOP GOOGLE. Si le moteur ne trouve rien.
          :)
		      let $total := count(
        $google
      )
	
		      return

		      <div id="goo"> 
          <h2>Recherche: {
        $idefx
      }</h2>
          {
        if (
          empty(
            $google
          )
        ) then <p>Aucun Résultat. <a onClick="window.close();" class="button" href="/">Revenir</a></p> else ()
      }
		       {
        	
		      for $res at $n in $google
		        where $n >= $countres and $n <= $seuilmax
			order by $res//orth collation "?lang=fr"	
		        return
			<div id="res">{
           
			 for $x in $res/div[1] 
			 return
			 if (
            $n=1 and number(
              $x//@score
            ) < 5000
          ) 
				then 
				(
				<div id="resT" n="0"><div id="res"><div id="ext">{
              isi:t(
                'no_vedette'
              )
            }&#x000A0;<mark>{
              $total
            }</mark>{
              isi:t(
                'results'
              )
            }</div></div></div>
				,
				<div id="resT" n="{
              $n
            }">{
              $x
            }{
              if (
                number(
                  $x//@score
                )>3500
              ) then () else <a href="#">{
                $n
              }/{
                $total
              }</a>
            }
				</div>
				) 
				else 	
				<div id="resT" n="{
            $n
          }">
					<div id="footeridefx">{
            isi:t(
              'search_rez'
            )
          } {
					  if (
              data(
                $x//@score
              ) contains text {
                "500.*"
              } using wildcards
            )
					  then " sur les vedettes"
					  else if (
              data(
                $x//@score
              ) contains text {
                "^4.*"
              } using wildcards
            ) 
					  then " sur les sous-entrées"
					  else " sur le corpus" 
						}</div>
					{
            $x
          }
				</div>
		}	</div>
		       } 
		      </div>
        }
        </div>
)
          
};