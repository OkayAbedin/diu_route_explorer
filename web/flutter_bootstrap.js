{{flutter_js}}
{{flutter_build_config}}

// Performance optimizations for faster loading
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    // Initialize the Flutter engine with performance optimizations
    let appRunner = await engineInitializer.initializeEngine({
      // Use HTML renderer for better performance on web
      renderer: "html",
      // Enable multi-threading if available
      useColorEmoji: true,
    });
    
    // Start the Flutter app
    await appRunner.runApp();
  }
});
