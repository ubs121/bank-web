var navbuttIMG;
var navbarIMG;
var newLyr;
var top_layer=21;
var prev_layer=20;
var nav_left=170;
var nav_top=6;
var nav_width=0;
var nav_depth=25;
var image_width=0;
var image_depth=25;
var template_file;
var plansMouse_x;
var o_image_path="";
var theHTML;
var theHTML_items=0;
var titles_Count=0;

//***************************************************************************
function load_Navbar(b_asp)
{
     if(b_asp)
	 {
		 theHTML_items = document.forms.page_number.total_items.value;
		 thePage = document.forms.page_number.template.value;
		}
	 else 
	 {
	 	theHTML_items=1;
		thePage = document.forms.itemid.tn.value;		
		}

	titles_Array = new Array();
	tableArray = new Array();
			
	switch(thePage) {
 case "Asset_Register": titles_Array[0] = "Maintain_Static_Data";
tableArray[20] = "Maintain_Static_Data";
titles_Array[1] = "Disposal_of_Assets";
tableArray[21] = "Disposal_of_Assets";
titles_Array[2] = "Depreciation_to_the_Asset_&_General_Ledgers";
tableArray[22] = "Depreciation_to_the_Asset_&_General_Ledgers";
titles_Array[3] = "Depreciation_Posting_to_the_Job_Ledger";
tableArray[23] = "Depreciation_Posting_to_the_Job_Ledger";
titles_Array[4] = "Enquiries";
tableArray[24] = "Enquiries";
titles_Array[5] = "Reports";
tableArray[25] = "Reports";
titles_Array[6] = "Audits";
tableArray[26] = "Audits";
titles_Array[7] = "Purges";
tableArray[27] = "Purges";
titles_Array[8] = "Year-end_Procedures";
tableArray[28] = "Year-end_Procedures";
break;		
case "asset" :	titles_Array[0] = "Depreciation History";
						tableArray[20] = "DepreciationLayer";
						titles_Array[1] = "Asset Details";
						tableArray[21] = "assetLayer";
						titles_Array[2] = "Transaction History";
						tableArray[22] = "TransactionLayer";
						image_width = 444;
						nav_width = 148;
						break;

		case "demolitions" :	titles_Array[0] = "Licence Details";
						tableArray[20] = "LicenceLayer";
						titles_Array[1] = "General";
						tableArray[21] = "GeneralLayer";
						titles_Array[2] = "Fees & Conditions";
						tableArray[22] = "FeeLayer";
						image_width = 450;
						nav_width = 150;						
						break;

		case "loan" :	titles_Array[0] = "Repayment Schedule";
						tableArray[20] = "RepaymentLayer";
						titles_Array[1] = "Loan Details";
						tableArray[21] = "LoanLayer";
						titles_Array[2] = "Deposit Schedule";
						tableArray[22] = "DepositLayer";
						image_width = 450;
						nav_width = 150;						
						break;

		case "opac_result" :	titles_Array[0] = "Catalogue";
						tableArray[20] = "CatalogueLayer";
						titles_Array[1] = "Holding Details";
						tableArray[21] = "HoldingLayer";
						image_width = 300;
						nav_width = 150;						
						break;

		case "parking" :	titles_Array[0] = "Vehicle / Offence";
						tableArray[20] = "VehicleLayer";
						titles_Array[1] = "Summary";
						tableArray[21] = "SummaryLayer";
						titles_Array[2] = "Owner / Driver";
						tableArray[22] = "OwnerLayer";
						titles_Array[3] = "Payment Details";
						tableArray[23] = "PaymentLayer";
						image_width = 400;
						nav_width = 150;						
						break;
						
						
		case "plans" :	titles_Array[0] = "Memo";
						tableArray[20] = "memoLayer";
						titles_Array[1] = "General";
						tableArray[21] = "generalLayer";
						titles_Array[2] = "Builder";
						tableArray[22] = "builderLayer";
						titles_Array[3] = "Process";
						tableArray[23] = "processLayer";
						titles_Array[4] = "Construction";
						tableArray[24] = "constructionLayer";
						titles_Array[5] = "Insurance";
						tableArray[25] = "insuranceLayer";
						titles_Array[6] = "Approvals";
						tableArray[26] = "approvalsLayer";
						titles_Array[7] = "Pending";
						tableArray[27] = "pendingLayer";
						image_width = 592;
						nav_width = 74;
						break;


		default : theHTML_items=0;		
	}
		
	titles_Count = titles_Array.length;
	preLoad_Opac(b_asp);
}	

//***************************************************************************
function table_Setup(b_asp)
    {
	  if(b_asp)
	    {
	     tempTableLyr = document.all["tableLayer"].style;
         tempTableLyr.left = 0;
	     tempTableLyr.top = 0;
        }
      else
	     {
	      itemLyr = document.all["itemLayer"].style;
	      itemLyr.left  = 0;
	      itemLyr.top   = 0;
	     }
		  
	navbuttLyr    = document.all["navbuttLayer"].style;
    navbarLyr     = document.all["navbarLayer"].style;
    navtextLyr      = document.all["navtextLayer"].style;
	navEventLyr      = document.all["navEventLayer"].style;

    navbuttLyr.left=nav_left; navbuttLyr.top=nav_top;
	navbarLyr.left=nav_left;  navbarLyr.top=nav_top;
    navtextLyr.left=nav_left; navtextLyr.top=nav_top;
	navEventLyr.left=nav_left;   navEventLyr.top=nav_top;    

    titleLyr = document.all["titleLayer"].style;		
    
    navbarIMG = document.all["navbarLayer"].document;
	navbarIMG["strip1"].src = strip_off.src;
    navbarLyr.visibility="visible";
    navbuttIMG = document.all["navbuttLayer"].document;
    navbuttIMG["strip2"].src = strip_on.src;
    navbuttLyr.clip="rect(0 0 0 0)"; 	
	navbuttLyr.visibility="visible";
	navtextLyr.visibility="visible";
	titleLyr.visibility="visible";

	showTable();
    showNavBarText();
    plansEventSetup();
	}
//***************************************************************************
function plansEventSetup()
   {
   	var eventArea = document.all["navEventLayer"];
	eventArea.onmousemove = plansMouseMove;
   }	
//***************************************************************************
function plansMouseMove(e)
  {
   prev_layer=top_layer;      
   plansMouse_x = eval(event.x)-nav_left;
   
    hideTable();
	   
    if(plansMouse_x>0&&plansMouse_x<nav_width+1){navbuttLyr.clip="rect(0 " + (nav_width-1) + " " + nav_depth + " 0)";top_layer =20;showTable();return;}
    if(plansMouse_x>nav_width&&plansMouse_x<2*nav_width+1)   {navbuttLyr.clip="rect(0 " + (2*nav_width-1) + " " + nav_depth + " " +   nav_width +")"; top_layer =21;showTable();return;}

	for (j=22; j < tableArray.length; j++)
	{
		if(plansMouse_x>(j-20)*nav_width&&plansMouse_x<(j-19)*nav_width+1) {navbuttLyr.clip="rect(0 " + ((j-19)*nav_width-1) + " " + nav_depth + " " + (j-20)*nav_width +")"; top_layer =j;showTable();return;}
		//	if(plansMouse_x>2*nav_width&&plansMouse_x<3*nav_width+1) {navbuttLyr.clip="rect(0 " + (3*nav_width-1) + " " + nav_depth + " " + 2*nav_width +")"; top_layer =22;showTable();return;}
	}
}
//***********************************************************
function showTable()
{
  newLyr = document.all[tableArray[top_layer]].style;
  newLyr.visibility="visible";
  newLyr.zIndex=top_layer;
}
//*********************************************************
function hideTable()
{
    newLyr = document.all[tableArray[prev_layer]].style;
    newLyr.visibility="hidden";
    newLyr.zIndex=prev_layer;
}
//**********************************************************
function showNavBarText()
 {

   	theHTML = document.all["navtextLayer"];
    var fill_text = '<TABLE "WIDTH="' + image_width + '" HEIGHT="' + image_depth +'"><TR>'
	
	for (j = 0; j < titles_Count; j++)
	{
		fill_text = fill_text + '<TD class="tdempty" width="' + nav_width + '" align="center">' + titles_Array[j];
	}
	
	fill_text = fill_text + '</TABLE>';

    theHTML.innerHTML = fill_text;
}
