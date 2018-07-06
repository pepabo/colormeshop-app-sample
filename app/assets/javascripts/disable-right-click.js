document.addEventListener("contextmenu", function (e) {
  e.preventDefault();
});

var style = document.createElement("style");
style.type      = "text/css";
style.innerHTML = "body {" +
  "-webkit-touch-callout: none !important;" +
  "-webkit-user-select: none !important;" +
  "-moz-user-select: none !important;" +
  "-ms-user-select: none !important;" +
  "user-select: none !important;" +
  "}";
document.head.appendChild(style);