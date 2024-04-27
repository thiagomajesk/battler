// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/battler_web.ex",
    "../lib/battler_web/**/*.*ex",
    "node_modules/preline/dist/*.js",
  ],
  theme: {
    extend: {
      colors: {
        brand: "#AA00FF",
        accent: "#E1C564",
      },
    },
  },
  plugins: [
    require("preline/plugin"),
    require("@tailwindcss/forms"),
    require("tailwindcss-animated"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
