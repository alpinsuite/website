/* Theme. Follows the desktop by default; a stored choice pins it.
 *
 * Loaded synchronously in <head>, before the stylesheet does any painting, so
 * a reader whose stored choice differs from their desktop never sees the wrong
 * theme flash first.
 *
 * The whole mechanism is `color-scheme` on <html>. style.css defines every
 * colour with light-dark(), which resolves against it, so nothing here needs
 * to know a single colour value. */
(function () {
  "use strict";

  var root = document.documentElement;
  var KEY = "buache-theme";

  /* Reveal the controls that need scripting. Everything else already works. */
  root.classList.remove("no-js");

  function stored() {
    try {
      var v = localStorage.getItem(KEY);
      return v === "light" || v === "dark" ? v : null;
    } catch (e) {
      /* Private browsing, or storage disabled. The toggle still works for the
         length of the visit; it just will not be remembered. */
      return null;
    }
  }

  function apply(theme) {
    if (theme) {
      root.setAttribute("data-theme", theme);
    } else {
      root.removeAttribute("data-theme");
    }
  }

  apply(stored());

  var darkQuery = window.matchMedia
    ? window.matchMedia("(prefers-color-scheme: dark)")
    : null;

  function effective() {
    var pinned = root.getAttribute("data-theme");
    if (pinned === "light" || pinned === "dark") return pinned;
    return darkQuery && darkQuery.matches ? "dark" : "light";
  }

  function describe(button) {
    var next = effective() === "dark" ? "light" : "dark";
    var text = "Switch to the " + next + " theme";
    button.setAttribute("aria-label", text);
    button.setAttribute("title", text);
  }

  function ready() {
    var buttons = document.querySelectorAll(".theme-toggle");
    var i;

    for (i = 0; i < buttons.length; i++) {
      (function (button) {
        describe(button);
        button.addEventListener("click", function () {
          var next = effective() === "dark" ? "light" : "dark";
          apply(next);
          try {
            localStorage.setItem(KEY, next);
          } catch (e) {
            /* Not fatal. See stored(). */
          }
          for (var j = 0; j < buttons.length; j++) describe(buttons[j]);
        });
      })(buttons[i]);
    }

    /* The desktop can change theme while the page is open. With no stored
       choice we follow it, so the button label has to keep up. */
    if (darkQuery) {
      var onChange = function () {
        for (var j = 0; j < buttons.length; j++) describe(buttons[j]);
      };
      if (darkQuery.addEventListener) {
        darkQuery.addEventListener("change", onChange);
      } else if (darkQuery.addListener) {
        darkQuery.addListener(onChange);
      }
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", ready);
  } else {
    ready();
  }
})();
