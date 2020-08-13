JSON-RPC

1) Функция получения текущего времени.

```
→ {"method": "getTime"}
← {"result": 1597350769}
```

2) Коллбек, который дёргается при появлении пира, в параметрах время и уникальный айдишник

```
→ {"method": "foundPeer", "peerID": "iPhone Masala", "ti": 1597350769}
← {"result": "ok"}
```

3) Коллбек, который дёргается при исчезновении пира, в параметрах  время и айдишник

```
→ {"method": "lostPeer", "peerID": "iPhone Masala", "ti": 1597350769}
← {"result": "ok"}
```

4) Функция отправки байтов пиру, в параметрах айдишник и данные

```
→ {"method": "sendToPeer", "peerID": "iPhone Masala", "data": "text message (?)"}
← {"result": "ok"}
```

5) Коллбек, который дёргается при поступлении сообщения от пира, в параметрах время, айдишник и данные

```
→ {"method": "didReceiveFromPeer", "peerID": "iPhone Masala", "data": "text message (?)"}
← {"result": "ok"}
```

<hr/>

Нужны ли технические параметры типа версии jsonrpc, sequence id, версия аппки?

```
--> {"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 3}
<-- {"jsonrpc": "2.0", "result": 19, "id": 3}
```
