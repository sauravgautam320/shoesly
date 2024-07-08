# Shoesly E-commerce App

## Project Overview

Shoesly is a feature-rich e-commerce mobile application built using Flutter and Firebase. The app allows users to browse, filter, and purchase shoes from various brands. Users can also view product details, read and write reviews, and manage their shopping cart and orders.

## Project Setup Instructions

### Prerequisites

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Firebase project: [Firebase Console](https://console.firebase.google.com/)
- An IDE (e.g., VS Code, Android Studio)

### Steps to Set Up the Project

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/shoesly.git
   cd shoesly

2. **Install Dependencies:**
`flutter pub get`

3. **Set up Firebase:**
Go to the Firebase Console and create a new project.
Add an Android app to your project and download the `google-services.json` file.
Place the `google-services.json` file in the android/app directory.
Add an iOS app to your project and download the `GoogleService-Info.plist` file.
Place the `GoogleService-Info.plist` file in the ios/Runner directory.


## Assumptions

- Users have basic knowledge of Flutter and Firebase setup.
- Users have a Firebase project set up with Firestore enabled.
- The `products` collection in Firestore contains sample product data.
- All images used in the app are accessible and hosted online.

## Challenges Faced

### 1. Managing State:

**Challenge:** Ensuring consistent and efficient state management across various components.

**Solution:** Utilized Flutter's built-in `StatefulWidget` and `State` classes to manage state locally. For more complex state management, consider using state management solutions like Provider, Bloc, or Riverpod.

### 2. Firestore Queries:

**Challenge:** Complex Firestore queries, including filtering and sorting products based on multiple criteria.

**Solution:** Used Firestore's powerful querying capabilities, combined with Flutter's asynchronous programming model, to fetch and display data efficiently.

### 3. UI and UX Design:

**Challenge:** Designing a user-friendly and visually appealing interface.

**Solution:** Leveraged Flutter's extensive widget library to create a clean and responsive UI. Used third-party packages like `flutter_rating_bar` and `flutter_svg` to enhance the user experience.

### 4. Error Handling:

**Challenge:** Handling errors gracefully, especially network-related issues.

**Solution:** Implemented try-catch blocks for asynchronous operations and used Flutter's `FutureBuilder` and `StreamBuilder` to handle loading states and display error messages when necessary.

## Additional Features and Improvements

### 1. Enhanced Filtering:

Added advanced filtering options, allowing users to filter products by brand, price, color, and gender.

### 2. Review System:

Implemented a review system where users can read reviews for products.

### 3. Order Management:

Users can view their order summary and manage their orders efficiently. Orders are stored in Firestore and can be retrieved later.

### 4. Responsive Design:

Ensured the app is responsive and works well on different screen sizes, including tablets.

### 5. Improved UX:

Added visual feedback for user actions, such as adding items to the cart, to improve the overall user experience.

## Conclusion

This project demonstrates how to build a full-featured e-commerce app using Flutter and Firebase. By following the setup instructions and leveraging the provided code, you can quickly get started with your e-commerce application. The project is designed to be scalable and maintainable, with room for further enhancements and customizations.
