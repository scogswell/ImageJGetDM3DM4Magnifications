// This macro scours a directory and all subdirectories from a chosen root, and 
// extracts the indicated microscope magnification for all DM3/DM4 (gatan format) files 
// contained within.  It then presents a summary table of magnifications which can be 
// saved as a CSV file or text. \
//
// Steven Cogswell, P.Eng.
// UNB Microscopy and Microanalysis Facility
// April 2012. 
// October 2018 - Updated to read .DM4 and .DM3 files, using the bio-formats plugin extensions to get metadata
// 
run("Bio-Formats Macro Extensions");  // Gives you access to the "Ext." functions below
setBatchMode(true); 
showMessage("Determine DM Magnifications", "This Macro makes a report of all the magnifications of DM3/DM4 files in a directory");

// Some of this is adapted from http://rsbweb.nih.gov/ij/macros/ListFilesRecursively.txt  
dir = getDirectory("Choose a Directory");
count = 1;
listFiles(dir); 
updateResults(); 
// End of macro. 

function listFiles(dir) {
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        showProgress(i/list.length);  
        if (endsWith(list[i], "/"))
           listFiles(""+dir+list[i]);    // Recusive through all subdirectories
        else
           //print((count++) + ": " + dir + list[i]);
           
		if(endsWith(list[i],".dm3") || endsWith(list[i],".dm4")) {    // Only open DM3 and DM4 files 
			Ext.openImagePlus(dir+list[i]);
			printMag();   // Determine microscope indicated mag from DM3 file 
			close();
		}
     }
  }
		

// Function to determine the indicated magnification from a DM3 file, and put result into a table
//
function printMag() {

	thename = getInfo("image.filename");    // Name of image	

	theInfo = getMetadata("Info");  // Get the metadata for the image, this is a string
	theInfoCollapsed = replace(theInfo," ","");  // Bio-formats puts spaces in the name and that messes up the List() functions so we just collapse the spaces
	List.setList(theInfoCollapsed) // Make a key/value list with the metadata from the string

    if (List.indexOf("IndicatedMagnification") != -1)   // DM3/DM4 files look like this
    {
    	theMag=List.get("IndicatedMagnification");
    } else {
    	theMag="?";   // Unknown format, try  not to crash
    }
	row=nResults;  // Current row in the results table 
	setResult("Microscope Magnfication",row,theMag);    
	setResult("Label",row,thename); 
}
