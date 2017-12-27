
var xmlId = 0;
var chId = 0;

function myFunction(s) {
    if (s.children().size() > 0) {
      for (var i = 0; i < s.children().size(); i++){
        s.children().eq(i).attr('id',xmlId);
        xmlId++;
        if (s.children().eq(i).children().size() > 0) {
          myFunction(s.children().eq(i));
        };
      };
    }
}

function addXml(node,id){
  nodeClone = node.clone(true);
  nodeClone.removeAttr("hidden");
  nodeClone.attr('id',xmlId);
  xmlId++;
  myFunction(nodeClone);
  //nodeClone.insertAfter(id);
  //$(id).parent().append(nodeClone);
  var tagn = nodeClone.get(0).tagName.toLowerCase();
  //alert(tagn);
  var ttag = $(id).parent().children(tagn).last();
  //alert($(id).prop('outerHTML'));
  //alert(ttag.prop('outerHTML'));
  var tagfull = "#controle " + tagn;
  //alert(nodeClone.prop('outerHTML'));
  nodeClone.insertAfter(ttag);
  //$("body").append(nodeClone);
}


function addChM(ch,id){
  chClone = ch.clone(true);
  chClone.attr('n',chId);
  //chId++;
  addCh(chClone);
  //$(this).append(chClone);
  //$("body").append(chClone);
}


function addCh(node)
{
  node.attr("n",chId);
  if(node.children("div").children("div").eq(1).children("input").size() > 0){
    node.children("div").children("div").eq(1).children("input").attr("n",chId);
    chId++;
    
    
  }
  else
  if(node.children("div").children("div").eq(1).children("textarea").size() > 0){
    node.children("div").children("div").eq(1).children("textarea").attr("n",chId);
    chId++;
    
  }
  else
  { 
    chId++;

    
    for (var i = 0; i < node.children("div").children("div").eq(1).children("div.cha").size(); i++)
    { 
      node.children("div").children("div").eq(1).children("div.cha").eq(i).next().children().eq(0).attr('xmlid',chId);
      addCh(node.children("div").children("div").eq(1).children("div.cha").eq(i));
      
    }
    
  }
}



