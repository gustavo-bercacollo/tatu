"""Serve build/web na rede local para abrir o app no celular.

Uso (dentro de app/):  py tool/serve_web.py
Manda o navegador não guardar cache, para cada build novo aparecer
só recarregando a página.

Com tool/certificado/cert.pem e chave.pem, serve em HTTPS: o navegador
do celular só libera a câmera ao vivo em HTTPS. O certificado é feito
aqui mesmo, então o celular avisa "não seguro" na primeira vez; é só
tocar em "Avançado" e continuar. Para gerar (Git Bash):
  openssl req -x509 -newkey rsa:2048 -nodes -days 825 \
    -keyout tool/certificado/chave.pem -out tool/certificado/cert.pem \
    -subj "/CN=tatu-local"
"""

import functools
import http.server
import socket
import ssl
from pathlib import Path

PORTA = 8080
APP = Path(__file__).resolve().parent.parent
PASTA = APP / "build" / "web"
CERT = APP / "tool" / "certificado" / "cert.pem"
CHAVE = APP / "tool" / "certificado" / "chave.pem"


class SemCache(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".mjs": "text/javascript",
    }

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()


def ip_local():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        return s.getsockname()[0]
    except OSError:
        return "127.0.0.1"
    finally:
        s.close()


if __name__ == "__main__":
    handler = functools.partial(SemCache, directory=str(PASTA))
    with http.server.ThreadingHTTPServer(("0.0.0.0", PORTA), handler) as srv:
        protocolo = "http"
        if CERT.exists() and CHAVE.exists():
            ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ctx.load_cert_chain(CERT, CHAVE)
            srv.socket = ctx.wrap_socket(srv.socket, server_side=True)
            protocolo = "https"
        print(f"Servindo {PASTA}")
        print(f"No celular (mesmo Wi-Fi): {protocolo}://{ip_local()}:{PORTA}")
        srv.serve_forever()
