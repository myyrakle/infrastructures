import { useEffect, useState } from "react";

import { Cookies } from "react-cookie";

const cookies = new Cookies();

export function setCookie(key: string, value: string) {
  return cookies.set(key, value);
}

export function getCookie(key: string): string {
  return cookies.get(key);
}

export function hasCookie(key: string): boolean {
  const value = getCookie(key);

  return value !== null && value !== undefined && value !== "";
}

class ChatType {
  name: string;
  message: string;

  constructor(name: string, message: string) {
    this.name = name;
    this.message = message;
  }
}

const socket = new WebSocket(
  "wss://q4w54cu53i.execute-api.ap-northeast-2.amazonaws.com/production"
);

function App() {
  const [isConnected, setIsConnected] = useState(false);
  const [chatList, setChatList] = useState([] as ChatType[]);
  const [yourName, setYourName] = useState("");
  const [sendMessage, setSendMessage] = useState("");

  useEffect(() => {
    socket.addEventListener("open", (event) => {
      setIsConnected(true);
    });

    socket.addEventListener("close", (event) => {
      setIsConnected(false);
    });

    socket.addEventListener("error", (error) => {
      console.error(error);
    });

    socket.addEventListener("message", (message) => {
      const data = JSON.parse(message.data);

      switch (data.action) {
        case "receive": {
          setChatList(
            chatList.concat([{ name: data.name, message: data.message }])
          );
        }
      }
    });
  });

  return (
    <div className="App">
      {hasCookie("yourName") ? (
        <div>
          {chatList.map((chat) => (
            <div>
              {chat.name}: {chat.message}
            </div>
          ))}
          <hr />
          <input
            type="text"
            onChange={(e) => setSendMessage(e.target.value)}
          />{" "}
          <button
            onClick={() => {
              if (!isConnected) {
                alert("채팅서버에 접속되어있지 않습니다.");
              } else {
                const message = sendMessage;
                const name = getCookie("yourName");
                socket.send(JSON.stringify({ action: "send", name, message }));
              }
            }}
          >
            전송
          </button>
        </div>
      ) : (
        <div>
          <h3>닉네임을 입력해주세요</h3>
          <input
            type="text"
            onChange={(e) => setYourName(e.target.value)}
          />{" "}
          <button
            onClick={() => {
              setCookie("yourName", yourName);
              window.location.reload();
            }}
          >
            입력
          </button>
        </div>
      )}
    </div>
  );
}

export default App;
