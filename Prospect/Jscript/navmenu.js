function nav_off(x)
  {
    navbarIMG = document.all["bimage" + x].document;
	navbarIMG["image" + x].src = navbarOff.src;
  }
//***************************************************************************
function nav_on(x)
  {
   cnt=document.menu.subheadings.value;

    navbarIMG = document.all["bimage" + x].document;
	navbarIMG["image" + x].src = navbarOn.src;
	tempLyr = document.all["layer" + x].style;
    
   	for (i = 1; i <= cnt; i++)
	    {
	     if(x==i)tempLyr.visibility="visible";
	     else{offLyr = document.all["layer" + i].style;offLyr.visibility="hidden";}
 		}		
  }
//***************************************************************************
