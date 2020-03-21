let WebSocket = require("ws")
let uuid = require("uuid")

console.log("Listening on port 8080")

let clients = []

const wss = new WebSocket.Server({ port: 8080 })
wss.on("connection", ws => {
    ws.id = uuid.v4()
    clients.push([ws, 400, 200])
    ws.send("myid," + ws.id)

    clients.forEach(client => {
        ws.send(client[0].id + "," + client[1] + "," + client[2])
    })

    ws.on("message", message => {
        let messageString = message.toString()
        let messageArray = messageString.split(",")
        clients.forEach(client => {
            if (client[0].id == ws.id) {
                client[1] = Number(messageArray[0])
                client[2] = Number(messageArray[1])
            } else {
                client[0].send(ws.id + "," + messageArray[0] + "," + messageArray[1])
            }
        })
    })
    ws.on("close", req => {
        console.log("Removing client...")
        let clientIndex = 0
        clients.forEach((client, index) => {
            if (client[0].id == ws.id) {
                clientIndex = index
            } else {
                client[0].send("destroy," + ws.id)
            }
        })
        clients.splice(clientIndex)
        ws.close()
    })
})