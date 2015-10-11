var toggle = true;
var prev_name = null;
var prev_index = null;
var shut=0;
var m_image_path="";
//*********************************************************************************************8
function deny_menu()
 {
  alert("Unavailable To Current User");  
 }
//*********************************************************************************************  
function preLoad_menu()
   {
   	m_image_path=document.forms.path.pn.value;

	folder_closed = new Image();
	folder_closed.src =	m_image_path + "explorer/folder_closed.gif";
	folder_open = new Image();
	folder_open.src = m_image_path + "explorer/folder_open.gif";
	link_up = new Image();
	link_up.src = m_image_path + "explorer/link_up.gif";
	link_dn = new Image();
	link_dn.src = m_image_path + "explorer/link_dn.gif";
	left = new Image();
	left.src = m_image_path + "explorer/left.gif";
	right = new Image();
	right.src = m_image_path + "explorer/right.gif";
	start_dn = new Image();
	start_dn.src = m_image_path + "explorer/start_dn.gif";
	start_up = new Image();
	start_up.src = m_image_path + "explorer/start_up.gif";
    layerSetup();
}
//*********************************************************************************************8
function arrayValues(child)
   {
	this.child = child;
	}
//******************************************************************************
function visibilitySetup()
{
startLyr.visibility = "visible";
}
//*********************************************************************************************8
function toggleStart()
 {
	var parentIMG = document.all["parentLayer"].document;
	var startIMG = document.all["startLayer"].document;
	
	if(toggle)
	   {
		startArray[1].child.visibility = "visible";
		startIMG["start_1"].src = start_dn.src;
		toggle = false;
	   }
	 else
	  {
		if(prev_index != null)
		  {
			parentIMG[prev_name + "_" + prev_index].src = folder_closed.src;
			parentArray[prev_index].child.visibility = "hidden";
			folderShut = true;
		   }
		startArray[1].child.visibility = "hidden";
		startIMG["start_1"].src = start_up.src;
		toggle = true;
	   }
 }
//**********************************************************************************************
function toggleMenu(name,index)
  {
	var parentIMG = document.all["parentLayer"].document;

		 if(prev_index != null)
		    {
			 parentIMG[prev_name + "_" + prev_index].src = folder_closed.src;
			 parentArray[prev_index].child.visibility = "hidden";
			 }

		 if(prev_index == index && shut==0)
		    {
			 parentIMG[name + "_" + index].src = folder_closed.src;
			 parentArray[index].child.visibility = "hidden";
			 shut=1;
			 }
		 else
		    { 
             parentIMG[name + "_" + index].src = folder_open.src;
             parentArray[index].child.visibility = "visible";
             prev_name = name;
             prev_index = index;
			 shut=0;
			 }
}
//************************************************************************************************
function linkUp(name,index)
 {
  var linkIMG = document.all[name + "Layer"].document;
  linkIMG[name + "_" + index].src = link_up.src;
 }
//************************************************************************************************
function linkDn(name,index)
   {
	var linkIMG = document.all[name + "Layer"].document;
	linkIMG[name + "_" + index].src = link_dn.src;
  }
//************************************************************************************************
//S.Royle Auto-generation: 12-Jul-99 12:27:48 PM
function arraySetup(){
startArray = new Array();
startArray[1] = new arrayValues(parentLyr);
parentArray = new Array();
parentArray[1] = new arrayValues(child1Lyr);
parentArray[2] = new arrayValues(child2Lyr);
parentArray[3] = new arrayValues(child3Lyr);
parentArray[4] = new arrayValues(child4Lyr);
parentArray[5] = new arrayValues(child5Lyr);
parentArray[6] = new arrayValues(child6Lyr);
visibilitySetup();}
//*********************************************************************************************
//S.Royle Auto-generation: 12-Jul-99 12:27:48 PM
function layerSetup(){
startLyr = document.all["startLayer"].style;
startLyr.left = 5;
startLyr.top = 5;
parentLyr = document.all["parentLayer"].style;
parentLyr.left = parseInt(startLyr.left);
parentLyr.top = parseInt(startLyr.top)+26;
child1Lyr = document.all["child1Layer"].style;
child1Lyr.left = parseInt(parentLyr.left)+135;
child1Lyr.top = parseInt(parentLyr.top)+0;
child2Lyr = document.all["child2Layer"].style;
child2Lyr.left = parseInt(parentLyr.left)+135;
child2Lyr.top = parseInt(parentLyr.top)+22;
child3Lyr = document.all["child3Layer"].style;
child3Lyr.left = parseInt(parentLyr.left)+135;
child3Lyr.top = parseInt(parentLyr.top)+44;
child4Lyr = document.all["child4Layer"].style;
child4Lyr.left = parseInt(parentLyr.left)+135;
child4Lyr.top = parseInt(parentLyr.top)+66;
child5Lyr = document.all["child5Layer"].style;
child5Lyr.left = parseInt(parentLyr.left)+135;
child5Lyr.top = parseInt(parentLyr.top)+88;
child6Lyr = document.all["child6Layer"].style;
child6Lyr.left = parseInt(parentLyr.left)+135;
child6Lyr.top = parseInt(parentLyr.top)+110;
arraySetup();}
//*********************************************************************************************
