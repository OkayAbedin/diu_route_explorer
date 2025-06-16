# DIU Route Explorer v2.0.1

[![Flutter Version](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/Version-2.0.1-brightgreen.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Firebase Hosting](https://img.shields.io/badge/Firebase-Hosting-orange.svg)](https://diurouteexplorer.web.app)
[![Live Website](https://img.shields.io/badge/Live-Website-success.svg)](https://diurouteexplorer.web.app)

<p align="center">
  <img src="assets/icons/Icon.png" alt="DIU Route Explorer Logo" width="200"/>
</p>

DIU Route Explorer is a comprehensive mobile application designed to streamline bus transportation for Daffodil International University students, faculty, and staff. Version 2.0.1 brings significant improvements in performance, user interface, and adds new features to help users efficiently navigate university transportation with real-time information.

🌐 **Live Web App**: [https://diurouteexplorer.web.app](https://diurouteexplorer.web.app)

## 🚀 What's New in v2.0.1

- **Performance Improvements**: Significantly faster loading times and smoother transitions
- **Enhanced UI/UX**: Refreshed interface with improved accessibility features
- **Optimization**: Lower battery consumption and reduced app size
- **Bug Fixes**: Addressed various issues reported by users
- **Updated Dependencies**: Latest security patches and library updates

## 🚀 Deployment

This project is automatically deployed to Firebase Hosting using GitHub Actions. Every push to the `main` branch triggers:
- Flutter code analysis
- Unit tests
- Web build compilation
- Automatic deployment to production

## Features

- **Real-time Bus Schedules**: Access up-to-date bus schedules and departure times
- **Route Information**: View detailed information about bus routes and stops
- **User Authentication**: Secure login for students and faculty with enhanced security
- **Push Notifications**: Receive important updates about schedule changes or delays
- **Dark/Light Theme Support**: Choose your preferred app appearance with automatic system theme detection
- **Personalized Onboarding**: Customized experience for first-time users
- **Offline Support**: Access critical information even without internet connection
- **Live Bus Tracking**: See where your bus is in real-time (coming soon)

## Screenshots

![image](https://github.com/user-attachments/assets/baf97ef5-5859-4ac1-98f3-b1ff8b509580)

## Installation

1. **Prerequisites**:
   - Flutter SDK (version 3.7 or higher)
   - Dart SDK
   - Android Studio / VS Code with Flutter extensions

2. **Clone the repository**:
   ```bash
   git clone https://github.com/marslab/diu-route-explorer.git
   cd diu-route-explorer
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

5. **Build release APK**:
   ```bash
   flutter build apk --release
   ```
   
   The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Architecture

The application follows a clean architecture approach with provider-based state management and is organized into the following directory structure:

- `lib/screens/`: All app screens including login and bus schedules
- `lib/providers/`: State management using Provider pattern
- `lib/services/`: Backend services and API integration
- `lib/widgets/`: Reusable UI components
- `lib/utils/`: Utility functions and helper methods
- `lib/config/`: Configuration constants and environment settings

## Technical Specifications

- **Package Name**: `com.marslab.diu_route_explorer`
- **Version**: 2.0.1 (Build 201)
- **Min SDK**: 23 (Android 6.0+)
- **Target SDK**: Latest stable
- **Flutter Version**: 3.7+
- **Dart SDK**: Latest compatible version

## 🛠️ Development & Deployment

### Local Development
1. Follow the installation steps above
2. Make your changes
3. Test locally with `flutter run -d chrome` for web testing
4. Test on physical devices when possible for best evaluation

### Deployment Process
This project uses automated CI/CD with GitHub Actions:

1. **Push to main branch** → Triggers automatic deployment
2. **Pull Request** → Creates preview deployment for testing
3. **Automatic steps**:
   - Code analysis (`flutter analyze`)
   - Unit tests (`flutter test`)
   - Web build (`flutter build web --release`)
   - Deploy to Firebase Hosting

### Manual Deployment
If you need to deploy manually:
```bash
flutter build web --release
firebase deploy --only hosting
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Flutter Team for the amazing cross-platform framework
- Daffodil International University for supporting this project

---

*Made with ❤️ by MarsLab | Version 2.0.1 | Last updated: June 2025*
