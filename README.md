# **Number Plate Detection System using MATLAB**

This MATLAB-based system is designed to detect and classify vehicle number plates from images. The system identifies potential number plate regions by analyzing color spaces and applies shape criteria to pinpoint the exact location of the plate. It then classifies the vehicle as either commercial (yellow plate) or private (white plate) based on the detected plate.

## **Features**
- Detects yellow and white number plates.
- Identifies the location of the number plate within the image.
- Classifies vehicles as either commercial or private based on plate color.
- Provides a visual display of the identified number plate.

## **Requirements**
- MATLAB software with Image Processing Toolbox.
- A set of images with visible number plates.

## **Installation**
1. Clone the repository or download the code files.
2. Ensure you have MATLAB installed with the required toolbox.
3. Place your test images in a folder named `images` within the working directory.

## **How It Works**
1. **Image Selection**: The system prompts the user to select an image from the `images` folder.
2. **Color Space Conversion**: The selected image is converted from RGB to CIE color space to facilitate color-based filtering.
3. **Yellow Plate Detection**: 
   - The system applies conditions specific to yellow plates.
   - A binary image is created highlighting regions that meet the yellow plate criteria.
   - The system then identifies the most probable region that contains the number plate.
4. **White Plate Detection**:
   - Similar to yellow plate detection, but with conditions specific to white plates.
5. **Classification**:
   - The system compares the detected regions for yellow and white plates.
   - It classifies the image as either a commercial vehicle (yellow plate) or a private vehicle (white plate) based on the region's characteristics.
6. **Output**:
   - The identified number plate is displayed along with a message indicating the type of vehicle.
   - If no valid plate is detected, an error message is shown.

## **Usage**
1. Run the MATLAB script (`NumberPlateDetection.m` or similar).
2. Select an image from the prompted file dialog.
3. View the output image with the detected number plate and the classification message.

## **Example**
After running the script, you will be prompted to choose an image. The system will process the image, display the detected number plate, and classify it as either a commercial or private vehicle.

## **Future Enhancements**
- Integrate OCR (Optical Character Recognition) to read the text on the number plates.
- Improve detection accuracy by enhancing the color and shape filtering techniques.
- Extend the system to work with video feeds for real-time detection.

## **Contributing**
Contributions are welcome! Feel free to fork the repository, report issues, or submit pull requests to improve the system.

