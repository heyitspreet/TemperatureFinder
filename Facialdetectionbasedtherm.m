clc;
close all;
clear;

the_Image= imread('index.jpeg');
[width, height] = size(the_Image);

if width>320
    the_Image = imresize(the_Image,[320 NaN]);
end

%cascade detector object.
faceDetector = vision.CascadeObjectDetector();

%finding the x,y height, width value of the box highlighting faces and
%drawing them
face_Location = step(faceDetector, the_Image);
the_Image = insertShape(the_Image, 'Rectangle', face_Location);
figure; 
imshow(the_Image,[]); 
title('Detected face');

% workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 15;

baseFileName = 'tface2.png';
folder = pwd;
fullFileName = fullfile(folder, baseFileName);
if ~isfile(fullFileName)
	errorMessage = sprintf('Error: file not found:\n%s', fullFileName)
	uiwait(errordlg(errorMessage));
	return;
end
fprintf('Transforming image "%s" to a thermal image.\n', fullFileName);

% Reading the image
originalRGBImage = imread(fullFileName);

% Display the image with face detection
subplot(2, 3, 1);
imshow(the_Image,[]); 
title('Detected face');

%imshow(originalRGBImage, []);
axis on;
caption = sprintf('Face detected image');
% caption = sprintf('Original Pseudocolor Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

grayImage = min(originalRGBImage, [], 3); % Useful for finding image and color map regions of image.

imageRow1 = 1; %y1
imageRow2 = 477; %y2
imageCol1 = 1; %x1
imageCol2 = 581; %x2
% Crop out the original image
rgbImage = originalRGBImage(imageRow1 : imageRow2, imageCol1 : imageCol2, :);
% imcrop(originalRGBImage, [20, 40, 441, 259]);

colorBarRow1 = 45;
colorBarRow2 = 436;
colorBarCol1 = 617;
colorBarCol2 = 632;
% Cropping the colorbar.
colorBarImage = originalRGBImage(colorBarRow1 : colorBarRow2, colorBarCol1 : colorBarCol2, :);
b = colorBarImage(:,:,3);

% Display the pseudocolored RGB image.
subplot(2, 3, 2);
imshow(rgbImage, []);
axis on;
caption = sprintf('Cropped Pseudocolor Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
hp = impixelinfo();

% Display the colorbar image.
subplot(2, 3, 3);
imshow(colorBarImage, []);
axis on;
caption = sprintf('Cropped Colorbar Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'IR thermometer', 'NumberTitle', 'Off')

% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, not the low temperatures.
storedColorMap = flipud(storedColorMap);

% Convert the subject/sample from a pseudocolored RGB image to a grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);
% Display the indexed image.
subplot(2, 3, 4);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Thermal Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Defining the temperature range:
highTemp = 34.2;
lowTemp = 23.5;

% Scale the indexed gray scale image so that it's actual temperatures in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

%resizing the thermal image to correlate with the normal RGB image
[width, height] = size(thermalImage);

if width>320
    thermalImage = imresize(thermalImage,[320 NaN]);
end

% Display the thermal image.
subplot(2, 3, 5);
imshow(thermalImage, []);
axis on;
colorbar;
title('Floating Point Thermal (Temperature) Image', 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');

% Let user mouse around and see temperatures on the GUI under the temperature image.
hp = impixelinfo();
hp.Units = 'normalized';
hp.Position = [0.45, 0.03, 0.25, 0.05];
sz = size(face_Location);

%printing the temperature of the faces detected in the console
if isvector(face_Location) %for 1 face detected
    %roughly estimating the forehead
    py = face_Location(2)+2/7*(face_Location(4));
    px = face_Location(1)+1/2*(face_Location(3));

    impixel(thermalImage,px,py) 
else  %incase multiple faces are detected
     for i=1:sz
        %roughly estimating the forehead
        px = face_Location(i,1)+(face_Location(i,3))/2;
        py = face_Location(i,2)+2/7*(face_Location(i,4));
        impixel(thermalImage,px,py)
    end
end

% histogram of the thermal image.
subplot(2, 3, 6);
histogram(thermalImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Temperature [Degrees]', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency [Pixel Count]', 'FontSize', fontSize, 'Interpreter', 'None');

% Get the maximum temperature.
maxTemperature = max(thermalImage(:));
meanTemperature = mean(thermalImage(:));
minTemperature = min(thermalImage(:));
fprintf('The maximum temperature in the image is %.2f\n', maxTemperature);
fprintf('The average temperature in the image is %.2f\n', meanTemperature);
fprintf('The minimum temperature in the image is %.2f\n', minTemperature);