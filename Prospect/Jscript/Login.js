//****************************************************
function check_status()
 {
  status=document.forms.login.status.value;
  if(status=="fail")
    {
	 alert("This D3 User is not currently allowed access to Prospect");   
	}

 }
//****************************************************** 
function position_login()
{
    collierLyr = document.all["collierLayer"].style;
	collierLyr.left = (available_width)/2-177;
    collierLyr.top = 10;
	    
	loginLyr = document.all["loginLayer"].style;
	loginLyr.left = available_width/2-160;
    loginLyr.top = 100;

    collierLyr.visibility = "visible";
    loginLyr.visibility="visible";

}
//*****************************************************
