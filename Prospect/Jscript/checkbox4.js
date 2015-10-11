
 var  parentLyr,gobackLyr,buttLyr,ulistLyr,loadingLyr,groupLyr;
 var toggle = true;
 var prev_name = null;
 var prev_index = null;
 var shut=0;
 var m_image_path="";
//*********************************************************************************************8
function users()
{
   groupLyr.visibility = "hidden";
   ulistLyr.visibility = "visible";
   buttLyr.visibility = "visible";
   show_sublayers(); 
}
//*********************************************************************************************8
function groups()
{
  ulistLyr.visibility = "hidden";
  buttLyr.visibility = "hidden";
  hide_sublayers(); 
  groupLyr.left=50;
  groupLyr.top=50;
  groupLyr.visibility = "visible";
    
   user=document.user_list.usr.value  
   document.group_list.AddGroup.value="Add Group To " + user  
   document.group_list.DeleteGroup.value="Delete Group From " + user  
}

//*********************************************************************************************8
function ShowAll()
{
    parentLyr = document.all["parentLayer"].style;
    gobackLyr = document.all["gobackLayer"].style;
    buttLyr = document.all["buttLayer"].style;
    ulistLyr = document.all["ulistLayer"].style;
    loadingLyr = document.all["loadingLayer"].style;
    groupLyr = document.all["groupLayer"].style;
   
    loadingLyr.visibility = "hidden";
	gobackLyr.visibility = "visible";
    buttLyr.visibility = "visible";
    ulistLyr.visibility = "visible";
    
}  

//*********************************************************************************************8
function Load_CheckBoxes()
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
    layerSetup();
}
//*********************************************************************************************8
function arrayValues(child)
   {
	this.child = child;
	}
//*********************************************************************************************8
function visibilitySetup()
{
parentLyr.visibility = "visible";

ShowAll();
}
//*********************************************************************************************8
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
//******************************************************************************
//S.Royle Auto-generation: 12-Jul-99 12:27:48 PM
function arraySetup(){

    parentArray = new Array();
	parentArray[1] = new arrayValues(child1Lyr);
	parentArray[2] = new arrayValues(child2Lyr);
      parentArray[3] = new arrayValues(child3Lyr);
      parentArray[4] = new arrayValues(child4Lyr);
	//parentArray[3] = new arrayValues(NULL);
	
visibilitySetup();}
//*********************************************************************************************
//S.Royle Auto-generation: 12-Jul-99 12:27:48 PM
function layerSetup(){
parentLyr = document.all["parentLayer"].style;
parentLyr.left=312;
parentLyr.top=36;
child1Lyr = document.all["child1Layer"].style;
child1Lyr.left = parseInt(parentLyr.left)+186;
child1Lyr.top = parseInt(parentLyr.top);
child2Lyr = document.all["child2Layer"].style;
child2Lyr.left = parseInt(parentLyr.left)+186;
child2Lyr.top = parseInt(parentLyr.top);
child3Lyr = document.all["child3Layer"].style;
child3Lyr.left = parseInt(parentLyr.left)+186;
child3Lyr.top = parseInt(parentLyr.top);
child4Lyr = document.all["child4Layer"].style;
child4Lyr.left = parseInt(parentLyr.left)+186;
child4Lyr.top = parseInt(parentLyr.top);
arraySetup();}
//*********************************************************************************************
function hide_sublayers()
{
 parentLyr.visibility = "hidden";
 child1Lyr.visibility = "hidden";
 child2Lyr.visibility = "hidden";
 }
//*********************************************************************************************
function show_sublayers()
{
 parentLyr.visibility = "visible";
}
//*********************************************************************************************
