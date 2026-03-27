# flutter_ai_ml

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

Flutter ML App Summary

Hello!
I have completed the Flutter Machine Learning (ML) course, where the course content was based on setState for state management. However, I took it a step further and implemented the full application using BLoC for scalable, production-ready architecture.
Each feature was developed to simulate real-world use cases, and I added extra functionality like live camera usage, gallery selection, and camera capture.

Here are the ML features I developed:

_________________________

1. Image Labeling

In this module, users can select or capture an image in three ways:

Using the live camera feed
Selecting an image from the gallery
Taking a new photo with the camera

Once an image is set, the app uses ML to analyze and identify the objects or scenes within the image. The recognized labels (e.g., "Mountain", "Animal", "Building") along with their confidence scores are displayed. This is useful for understanding image content and performing automatic categorization.

![Image Labeling](https://github.com/ravindra6596/flutter_ml/blob/f86ade1333f703a959939ecc215b3fbd95756dc3/assets/screenshots/image_picker.png)

____________________________

2. Barcode Scanner

This feature allows the user to scan barcodes using:

Live camera
Gallery
Camera capture

Once the barcode is detected, the app displays the data embedded within it (like product codes, URLs, or contact information). This module supports different barcode formats including QR codes and is practical for applications like inventory systems, scanners, or data extraction tools.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/barcode_scanner.png)

____________________________

3. Face Detection

In this section, users can detect human faces using:

Live camera input
Gallery image
Camera capture

Once the face is detected, the app analyzes and displays details such as:

Whether the person is smiling
Probability of different facial expressions

This can be used in emotion detection, photo analysis, or security verification systems.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/face_detection1.png)
![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/face_detection2.png)


____________________________

4. Object Detection

This feature detects multiple objects within a single image or frame using:

Live camera
Gallery
Camera capture

After loading the image, the app identifies all visible objects, highlights them with bounding boxes, and displays their labels (e.g., "Laptop", "Chair", "Bottle"). This is helpful in building applications related to augmented reality, automation, or visual search engines.
![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/object_detection.png)

____________________________

5. Text Recognition

Users can extract text from images through:

Live camera
Gallery selection
New photo capture

The app performs Optical Character Recognition (OCR) and displays all the detected text blocks from the image. It supports printed as well as handwritten text in different fonts. This is useful in scanning documents, IDs, or printed receipts.


![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/text_recognition.png)
____________________________

6. Pose Estimation

This module estimates human body poses using:

Live camera
Gallery
Photo capture

The app detects body keypoints (such as eyes, shoulders, elbows, knees) and maps the skeletal structure. It can be used in fitness tracking, posture correction, or interactive applications that rely on body movement.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/pose_estimation1.png)

____________________________

7. Smart Reply

This section simulates a chat conversation between two text fields: one for the sender and one for the receiver.

When a conversation is entered, the app uses ML to generate context-aware reply suggestions based on the message thread. This mimics the smart reply functionality in modern messaging apps and demonstrates how conversational AI can assist users with quicker replies.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/smart_reply.png)

____________________________

8. Smart Reply Chatting

Smart Reply simulates a real chat experience by providing automatic reply suggestions based on the conversation. As users type and exchange messages, the app analyzes the context and suggests quick, relevant responses — just like in modern messaging apps like Gmail or WhatsApp. This helps make conversations faster and more efficient.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/chatting.png)

____________________________

9. Entity Extraction

In this module, users can input any paragraph or sentence, such as a personal bio or form input (e.g., "My name is John, I was born on Jan 1st, 1990, my email is john@example.com, and I live at 123 Main Street...").

The app uses ML to automatically extract and classify key pieces of information like:

Name
Contact number
Date of birth
Address
Email address
Payment or credit card details
Profile URLs

This is extremely useful in form processing, resume parsing, chatbots, or any system that needs to understand structured information from unstructured text.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/entity_extraction.png)


____________________________

10. Digital Ink Recognition

This feature allows the user to draw any text or character on a digital canvas (drawing pad).

After clicking the recognize button, the app processes the handwritten strokes and suggests possible matching text. It supports different handwriting styles and is useful for handwriting recognition, note-taking apps, or drawing input fields.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/digital_ink_recognition1.png)
![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/digital_ink_recognition2.png)



11. Text Translation

This feature allows the user to translate text from any language into a selected target language using:

A text input field
A microphone button for voice input

The app first auto-detects the source language, then translates the entered or spoken sentence into the selected language from a dropdown. This module supports real-time translation and can be integrated into global communication apps or travel tools.

![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/text_translation1.png)
![Barcode Scanner](https://github.com/ravindra6596/flutter_ml/blob/main/assets/screenshots/text_translation2.png)

____________________________



All of the above features are integrated using Flutter + BLoC for robust and maintainable code. The app supports both image-based input (from gallery/camera) and real-time camera feeds, making it flexible for different user scenarios.

This project was developed as a hands-on learning experience to go beyond basic tutorials and simulate real-life ML applications in a mobile app environment.

# flutter_ml
