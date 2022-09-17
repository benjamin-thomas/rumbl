import Player from './player';

const Video = {
    init(socket, element) {
        if (!element) return;

        const playerId = element.getAttribute("data-player-id");
        const videoId = element.getAttribute("data-id");

        socket.connect();

        Player.init(element.id, playerId, () => {
            this.onReady(videoId, socket);
        });
    },

    onReady(videoId, socket) {
        const msgContainer = document.getElementById("msg-container");
        const msgInput = document.getElementById("msg-input");
        const postBtn = document.getElementById("msg-submit");
        const vidChannel = socket.channel("videos:" + videoId);

        postBtn.addEventListener("click", e => {
            const payload = { body: msgInput.value, at: Player.getCurrentTime() };

            vidChannel
                .push("new_annotation", payload) // send to the server
                .receive("error", e => console.log(e));

            msgInput.value = "";
        });

        vidChannel.on("new_annotation", (resp) => { // receive form server
            this.renderAnnotation(msgContainer, resp);
        });

        vidChannel.join()
            .receive("ok", resp => console.log("joined the video channel", resp))
            .receive("error", reason => console.log("join failed", reason));

        // vidChannel.on("ping", ({ count }) => console.log("PING", count));

    },

    esc(str) {
        const div = document.createElement("div");
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    },

    renderAnnotation(msgContainer, { user, body, at }) {
        // TODO: append annotation to msgContainer
        const template = document.createElement("div");

        template.innerHTML = `
        <a href="#" data-seek="${this.esc(at)}">
            <b>${this.esc(user.username)}</b>: ${this.esc(body)}
        </a>
        `;

        msgContainer.appendChild(template);
        msgContainer.scrollTop = msgContainer.scrollHeight;
    }
};

export default Video;