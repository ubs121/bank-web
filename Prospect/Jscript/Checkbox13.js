
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
	parentArray[5] = new arrayValues(child5Lyr);
	parentArray[6] = new arrayValues(child6Lyr);
	parentArray[7] = new arrayValues(child7Lyr);
    parentArray[8] = new arrayValues(child8Lyr);
	parentArray[9] = new arrayValues(child9Lyr);
    parentArray[10] = new arrayValues(child10Lyr);
    parentArray[11] = new arrayValues(child11Lyr);
    parentArray[12] = new arrayValues(child12Lyr);
    parentArray[13] = new arrayValues(child13Lyr);
		
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
child5Lyr = document.all["child5Layer"].style;
child5Lyr.left = parseInt(parentLyr.left)+186;
child5Lyr.top = parseInt(parentLyr.top);
child6Lyr = document.all["child6Layer"].style;
child6Lyr.left = parseInt(parentLyr.left)+186;
child6Lyr.top = parseInt(parentLyr.top);
child7Lyr = document.all["child7Layer"].style;
child7Lyr.left = parseInt(parentLyr.left)+186;
child7Lyr.top = parseInt(parentLyr.top);
child8Lyr = document.all["child8Layer"].style;
child8Lyr.left = parseInt(parentLyr.left)+186;
child8Lyr.top = parseInt(parentLyr.top);

child9Lyr = document.all["child9Layer"].style;
child9Lyr.left = parseInt(parentLyr.left)+186;
child9Lyr.top = parseInt(parentLyr.top);

child10Lyr = document.all["child10Layer"].style;
child10Lyr.left = parseInt(parentLyr.left)+186;
child10Lyr.top = parseInt(parentLyr.top);

child11Lyr = document.all["child11Layer"].style;
child11Lyr.left = parseInt(parentLyr.left)+186;
child11Lyr.top = parseInt(parentLyr.top);

child12Lyr = document.all["child12Layer"].style;
child12Lyr.left = parseInt(parentLyr.left)+186;
child12Lyr.top = parseInt(parentLyr.top);

child13Lyr = document.all["child13Layer"].style;
child13Lyr.left = parseInt(parentLyr.left)+186;
child13Lyr.top = parseInt(parentLyr.top);

arraySetup();}
//*********************************************************************************************
function hide_sublayers()
{
 parentLyr.visibility = "hidden";
 child1Lyr.visibility = "hidden";
 child2Lyr.visibility = "hidden";
 child3Lyr.visibility = "hidden";
 child4Lyr.visibility = "hidden";
 child5Lyr.visibility = "hidden";
 child6Lyr.visibility = "hidden";
 child7Lyr.visibility = "hidden";
 child8Lyr.visibility = "hidden";
 child9Lyr.visibility = "hidden";
 child10Lyr.visibility = "hidden";
 child11Lyr.visibility = "hidden";
 child12Lyr.visibility = "hidden";
 child13Lyr.visibility = "hidden";
 }
//*********************************************************************************************
function show_sublayers()
{
 parentLyr.visibility = "visible";
}
//*********************************************************************************************
