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
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

import * as Plot from "@observablehq/plot";
import Alpine from 'alpinejs'

window.Alpine = Alpine
 
Alpine.start()

import { format } from 'sql-formatter';

window.format = format

let Hooks = {}
Hooks.SQLFormatting = {
    mounted() {
        this.handleEvent("sql", ({ sql }) => {
            const d = document.getElementById("sql")
            this.pushEvent("format_sql", { sql: format(sql).replace(":: ", "::") })
        })
    }
}

Hooks.chartData = {
    mounted() {
        this.handleEvent("clear", () => {
            const d = document.getElementById("chart")
            d.innerHTML = ''
        })
        this.handleEvent("results", ({ fields, columns, rows }) => {
            console.log({ fields, columns, rows })
            window.Plot = Plot
            window.rows = rows
            const d = document.getElementById("chart")
            d.innerHTML = ''
            if (columns.length != 2) return
            const plot = Plot.plot({
                marks: [
                    Plot.barX(rows, { y: d => d[0] || "null", x: d => d[1], fill: "steelblue" }),
                    Plot.ruleY([0])
                ],
                tickRotate: "90",
                marginLeft: 130
            })
            d.appendChild(plot)
        })
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken }, hooks: Hooks, dom: {
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) { window.Alpine.clone(from, to) }
        }
    },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
