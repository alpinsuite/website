/* The Apps submenu.
 *
 * CSS already opens it: `.has-submenu:hover` for a pointer, `:focus-within`
 * for a keyboard. Both work with this file absent, which is why the markup
 * ships with no ARIA state on the trigger — an `aria-expanded="false"` that
 * nothing ever updates is a worse lie than no attribute at all. This adds the
 * attributes and then keeps them honest.
 *
 * What it adds on top of CSS: the state a screen reader reads, Escape, and
 * closing on a click somewhere else. */
(function () {
  "use strict";

  var items = document.querySelectorAll(".has-submenu");

  Array.prototype.forEach.call(items, function (item) {
    var trigger = item.querySelector(".nav-trigger");
    var menu = item.querySelector(".submenu");
    if (!trigger || !menu) return;

    if (!menu.id) menu.id = "submenu-" + Math.random().toString(36).slice(2, 8);
    trigger.setAttribute("aria-haspopup", "true");
    trigger.setAttribute("aria-controls", menu.id);
    trigger.setAttribute("aria-expanded", "false");

    /* The class only ever forces the menu open. Hover and focus-within are
       left to CSS, so a pointer leaving the item closes it with no help. */
    function open(state) {
      item.classList.toggle("is-open", state);
      trigger.setAttribute("aria-expanded", state ? "true" : "false");
    }

    trigger.addEventListener("click", function () {
      open(trigger.getAttribute("aria-expanded") !== "true");
    });

    /* Focus moving out of the item is the reliable close signal for a
       keyboard: relatedTarget is where focus went, and null when it left the
       document entirely. */
    item.addEventListener("focusout", function (event) {
      if (!item.contains(event.relatedTarget)) open(false);
    });

    item.addEventListener("keydown", function (event) {
      if (event.key !== "Escape" && event.key !== "Esc") return;
      open(false);
      trigger.focus();
    });

    /* A tap anywhere else. Listening on the document rather than on a backdrop
       element, because a backdrop would have to sit over the page. */
    document.addEventListener("click", function (event) {
      if (!item.contains(event.target)) open(false);
    });
  });
})();
