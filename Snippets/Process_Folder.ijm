/* Process_Folder.ijm
 * IJ BAR snippet https://github.com/tferr/Scripts/tree/master/Snippets
 *
 * This macro[1] snippet implements a generic, reusable macro to be used as a
 * more modular and flexible alternative to the Process>Batch>Macro built-in
 * command.
 *
 * It is composed of four self-contained functions:
 *   1. expectedImage(): Determines wich image types should be processed
 *   2. getOutputDirectory(): Sets a destination folder to save processed images
 *   3. myRoutines(): Container to hold the image processing routines
 *   4. processImage(): Applies myRoutines() to each individual image
 *
 * Because all the tasks required to iterate through the files[2,3] are handled
 * by separated functions, only the myRoutines() function needs to be filled,
 * e.g., with code generated by the Macro Recorder. It can also call macros and
 * scripts saved elsewhere (see Help>Macro Functions... for details). Example:
 *      function myRoutines() {
 *          runMacro("/Path/to/Coolest/Macro.ijm");
 *          eval("python", "/Path/to/Coolest/Script.py");
 *      }
 *
 * [1] https://github.com/tferr/Scripts/tree/master/Snippets#imagej-macro-language
 * [2] http://fiji.sc/How_to_apply_a_common_operation_to_a_complete_directory
 * [3] http://rsb.info.nih.gov/ij/macros/BatchProcessFolders.txt
 */


// Define which images should be processed. Only file extensions listed in this
// array will be accepted as valid by expectedImage(). Note that certain files
// may not be handled by IJ directly but by other plugins, such as Bio-Formats
var extensions = newArray(".tif", ".stk", ".oib");

// Define input directory
inputDir = getDirectory("Select a source directory");

// Define output directory
outputDir = getOutputDirectory(inputDir);

// Iterate through inputDir, ignore files with non-specified extensions and save
// a copy of processed images in outputDir
processImage(inputDir, outputDir);

showMessage("All done!");



/* This function defines all the image manipulation routines. */
function myRoutines() {

	// <Your code here>

}


/*
 * This function retrieves the full path to a "Processed" folder placed at the
 * same location of <input_dir>. For safety, the macro is aborted if <input_dir>
 * is not accessible or if the directory cannot be created, e.g., due to lack of
 * appropriate credentials. It does nothing if such a directory already exists.
 */
function getOutputDirectory(input_dir) {
	if (!File.isDirectory(input_dir)) {
		exit("Macro aborted: The directory\n'"+ input_dir +"'\nwas not found.");
	}
	if (endsWith(input_dir, File.separator)) {
		separatorPosition = lengthOf(input_dir);
		input_dir = substring(input_dir, 0, separatorPosition-1);
	}
	new_dir = input_dir + "_Processed" + File.separator;
	if (!File.isDirectory(new_dir)) {
		File.makeDirectory(new_dir);
		if (!File.isDirectory(new_dir))
			exit("Macro aborted:\n" + new_dir + "\ncould not be created.");
	}
	return new_dir;
}


/*
 * This function applies <myRoutines()> to individual files filtered by
 * <expectedImage()>. It takes 2 arguments: <open_dir>, the full path of input
 * directory and <save_dir>, the directory where a copy of the processed images
 * will be saved. It does nothing if <open_dir> does not exist.
 */
function processImage(open_dir, save_dir) {

	// Do not display images during macro execution
	setBatchMode(true);

	// Get the array containing the names of input files and loop through it.
	// We will not perform safety checks to verify if open_dir and save_dir
	// exist since that task was already performed by getOutputDirectory()
	files = getFileList(open_dir);
	for (i=0; i<files.length; i++) {
		file_path = files[i];
		if (expectedImage(file_path)) {
			print(i+1, "Analyzing "+ file_path +"...");
			open(file_path);

			// Apply processing steps
			myRoutines();

			output_path = save_dir + "Treated_" + getTitle();
			saveAs("tiff", output_path);
			close();
		} else {
			print(i+1, "Skipping "+ file_path +"... not the right file type");
		}
	}

}


/*
 * This function returns true if the file extension of the argument <filename>
 * is present in the global variable <extensions> array. Returns false otherwise.
 */
function expectedImage(filename) {
	expected = false;
	for (i=0; i<extensions.length; i++) {
		if (endsWith(toLowerCase(filename), extensions[i])) {
			expected = true;
			break;
		}
	}
	return expected;
}
