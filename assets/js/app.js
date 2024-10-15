// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function hideAllOther(nodes, thisId) {
    for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].id != thisId) {
            nodes[i].style.display = "none";
        }
    }
}

window.displayOrHide = function displayOrHide(elementId) {
    event.stopPropagation();
    var hideable = document.querySelectorAll(".hideable");
    hideAllOther(hideable, elementId);

    var elem = document.getElementById(elementId);
    if (elem.style.display != "block") {
        elem.style.display = "block";
    } else {
        elem.style.display = "none";
    }
}

window.appendProduct = function appendProduct(imgSrc) {
    var productsList = document.getElementById("products_list");
    var newLi = document.createElement('li');
    var newId = `product_${productsList.children.length}`;
    newLi.id = newId;


    var codeLabel = document.createElement("label");
    codeLabel.innerHTML = "Product code:";
    codeLabel.className = "bold-label label-inline";
    codeLabel.style.marginLeft = "2.0rem";


    var codeSelect = document.createElement('select');
    codeSelect.name = "products[" + productsList.children.length + "][code]";
    codeSelect.style.marginLeft = "2.0rem";
    codeSelect.required = true;
    codeSelect.autocomplete = 'off';

    var options = [
        { value: "GR1", text: "GR1" },
        { value: "SR1", text: "SR1" },
        { value: "CF1", text: "CF1" }
    ];

    options.forEach(function(optionData) {
        let option = document.createElement('option');
        option.value = optionData.value;
        option.text = optionData.text;
        codeSelect.appendChild(option);
    });

    var quantityLabel = document.createElement("label");
    quantityLabel.innerHTML = "Quantity:";
    quantityLabel.className = "bold-label label-inline";
    quantityLabel.style.marginLeft = "2.0rem";
    quantityLabel.style.display = "inline-block";

    var quantityInput = document.createElement("input");
    quantityInput.type = 'number';
    quantityInput.value = '1';
    quantityInput.min = 1;
    quantityInput.addEventListener('input', function() {
      var value = parseInt(this.value, 10);
      if (value <= 0) {
        this.value = 1;
      }
    });
    quantityInput.name = "products[" + productsList.children.length + "][quantity]";
    quantityInput.required = true;
    quantityInput.autocomplete = 'off';
    quantityInput.style.width = "50px";
    quantityInput.style.display = "inline-block";
    quantityInput.style.marginLeft = "10px";

    var removeImg = document.createElement('img');
    removeImg.classList.add('intext-icon');
    removeImg.style.marginLeft = '2.0rem';
    removeImg.src = imgSrc;

    removeImg.onclick = function() {
        removeProduct(newId);
    };

    newLi.appendChild(codeLabel);
    newLi.appendChild(codeSelect);
    newLi.appendChild(quantityLabel);
    newLi.appendChild(quantityInput);
    newLi.appendChild(removeImg);

    var newProductButton = document.getElementById("new_order");
    productsList.insertBefore(newLi, newProductButton);
};

function removeProduct(productId) {
    var productElement = document.getElementById(productId);
    if (productElement) {
        productElement.remove();
    }
}







