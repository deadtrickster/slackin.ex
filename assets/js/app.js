// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import channel from "./socket";

channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);

    var form = document.getElementById("invite");
    var email = document.getElementById("email");
    var button = document.getElementById("submit");

    form.addEventListener("submit", function(e) {
      e.preventDefault();

      button.disabled = true;
      button.className = 'button loading';
      button.innerHTML = 'Please Wait';

      channel.push("slack_invite", {email: email.value})
        .receive("ok", (msg) => {
          button.className = 'button success';
          button.value = "SUCCESS!";
        })
        .receive("error", (error) => {
          button.removeAttribute('disabled');
          button.className = 'button error';
          button.value = error.error;
        })
        .receive("timeout", () => {
          button.removeAttribute('disabled');
          button.className = 'button error';
          button.value = "Timed out";
        });
    });
  })
  .receive("error", resp => { console.log("Unable to join", resp); });
