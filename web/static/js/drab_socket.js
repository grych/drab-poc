import {Socket} from "phoenix"
import uuid from "node-uuid"

class DrabSocket {
  constructor() {
    this.self = this
    this.myid = uuid.v1()
    let socket = new Socket("/drab/socket", {params: {token: window.userToken}})
    socket.connect()
    this.channel = socket.channel(`drab:${this.myid}`, [])
    // console.log(this)
    this.channel.join()
      .receive("error", resp => { console.log("Unable to join", resp) })
      .receive("ok", resp => this.connected(resp, this))
  }
  connected(resp, him) {
    console.log("Joined successfully", resp)
    him.channel.on("onload", (message) => {
      // console.log("onload message:", message)
    })
    // handler for "query" message from the server
    him.channel.on("query", (message) => {
      // console.log("he is:", him)
      console.log("message: ", $(message))
      let r = $(message.query)
      // console.log("reply: ", r)
      let query_output = [
        message.query,
        message.sender,
        $(message.query).map(() => {
          return eval(`$(this).${message.get_function}`)
        }).toArray()
      ]
      him.channel.push("query", {ok: query_output})
    })
    // register events
    $("[drab-click]").on("click", function(event) {
      let payload = {
        // by default, we pass some sender attributes
        id: $(this).attr("id"),
        text: $(this).text(),
        html: $(this).html(),
        val: $(this).val(),
        event_function: $(this).attr("drab-click")
      }
      him.channel.push("click", payload)
    })
    // initialize onload on server side
    him.channel.push("onload")
  }
}

export default DrabSocket
