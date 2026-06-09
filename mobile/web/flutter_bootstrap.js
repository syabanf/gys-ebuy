// Custom Flutter bootstrap for the GYS Buyer prototype.
// Renders the app into the #flutter_host element (inside the phone frame)
// instead of <body>, and skips the (deprecated) service worker so rebuilds
// are picked up immediately during demos.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const host = document.querySelector("#flutter_host");
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: host,
    });
    await appRunner.runApp();
    const boot = document.getElementById("boot");
    if (boot) boot.remove();
  },
});
