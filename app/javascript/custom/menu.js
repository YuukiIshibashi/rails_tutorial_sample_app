// メニュー操作

function addToggleListener(selectorId, targetSelectorId, className) {
  let target = document.querySelector(selectorId);
  target.addEventListener("click", function(event) {
    event.preventDefault();
    let menu = document.querySelector(targetSelectorId);
    menu.classList.toggle(className);
  });
}

// トグルリスナーを追加してクリックをリッスンする
document.addEventListener("turbo:load", function() {
  addToggleListener("#hamburger", "#navbar-menu", "collapse");
  addToggleListener("#account", "#dropdown-menu", "active")
});