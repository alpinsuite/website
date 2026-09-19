/* Copy buttons on the command blocks.
 *
 * The buttons are created here rather than written into the markup, so a
 * reader without JavaScript is not shown a control that does nothing.
 *
 * What gets copied is the <pre>'s text, exactly. No prompt characters are
 * stripped, because none are ever written into the markup — a command block on
 * this site contains the command and nothing else, so that selecting it by
 * hand copies the same thing this button does. */
(function () {
  "use strict";

  function commandText(pre) {
    /* Trailing whitespace only: leading whitespace could be a continuation
       line's indent, which matters. */
    return pre.textContent.replace(/\s+$/, "");
  }

  /* execCommand is the fallback for a page opened from the filesystem, where
     navigator.clipboard is unavailable because the context is not secure. */
  function legacyCopy(text) {
    var area = document.createElement("textarea");
    area.value = text;
    area.setAttribute("readonly", "");
    area.style.position = "fixed";
    area.style.top = "-1000px";
    document.body.appendChild(area);
    area.select();
    var ok = false;
    try {
      ok = document.execCommand("copy");
    } catch (e) {
      ok = false;
    }
    document.body.removeChild(area);
    return ok ? Promise.resolve() : Promise.reject(new Error("copy failed"));
  }

  function copy(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return legacyCopy(text);
  }

  function ready() {
    var blocks = document.querySelectorAll(".command");
    if (!blocks.length) return;

    /* One live region for the page. Screen readers announce the result; the
       button's own label stays stable so it is never read as a different
       control after use. */
    var status = document.createElement("span");
    status.setAttribute("role", "status");
    status.className = "visually-hidden";
    document.body.appendChild(status);

    for (var i = 0; i < blocks.length; i++) {
      (function (block) {
        var pre = block.querySelector("pre");
        if (!pre) return;

        var button = document.createElement("button");
        button.type = "button";
        button.className = "copy-button";
        button.textContent = "Copy";

        var label = block.getAttribute("data-copy-label");
        if (label) {
          button.setAttribute("aria-label", "Copy the " + label);
        } else {
          button.setAttribute("aria-label", "Copy this command");
        }

        var reset;
        button.addEventListener("click", function () {
          copy(commandText(pre)).then(
            function () {
              button.textContent = "Copied";
              button.setAttribute("data-copied", "true");
              status.textContent = "Command copied to the clipboard.";
            },
            function () {
              button.textContent = "Press Ctrl+C";
              status.textContent =
                "Could not reach the clipboard. The command is selected; " +
                "press Control C to copy it.";
              selectContents(pre);
            }
          );

          window.clearTimeout(reset);
          reset = window.setTimeout(function () {
            button.textContent = "Copy";
            button.removeAttribute("data-copied");
            status.textContent = "";
          }, 2500);
        });

        block.appendChild(button);
      })(blocks[i]);
    }
  }

  function selectContents(node) {
    var range = document.createRange();
    range.selectNodeContents(node);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", ready);
  } else {
    ready();
  }
})();
