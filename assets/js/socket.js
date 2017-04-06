// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {})

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("team:all", {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("stat", msg => {
  var online = msg.online;
  var total = msg.total;

  var statusText;
  
  if (online == 0) {
    statusText = "<b class=\"total\">" + total + "</b> user" + (total>1?"s":"") + " registered.";
  } else {
    statusText = "<b class=\"active\">" + online + "</b> user" + (online>1?"s":"") + " online now" +
      " of <b class=\"total\">" + total + "</b> registered.";
  }

  var status = document.getElementsByClassName('status')[0];
  status.innerHTML = statusText;
});

export default socket

















