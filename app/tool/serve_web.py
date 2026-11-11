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
import threading
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


PORTA_HTTPS = 8443


if __name__ == "__main__":
    handler = functools.partial(SemCache, directory=str(PASTA))
    ip = ip_local()
    if CERT.exists() and CHAVE.exists():
        # http de sempre (abre direto, sem aviso) + https (câmera ao vivo).
        https = http.server.ThreadingHTTPServer(("0.0.0.0", PORTA_HTTPS), handler)
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ctx.load_cert_chain(CERT, CHAVE)
        https.socket = ctx.wrap_socket(https.socket, server_side=True)
        http_simples = http.server.ThreadingHTTPServer(("0.0.0.0", PORTA), handler)
        threading.Thread(target=http_simples.serve_forever, daemon=True).start()
        print(f"Servindo {PASTA}")
        print(f"No celular (mesmo Wi-Fi): http://{ip}:{PORTA}")
        print(f"Com camera ao vivo: https://{ip}:{PORTA_HTTPS} (1a vez: Avancado > Continuar)")
        https.serve_forever()
    else:
        with http.server.ThreadingHTTPServer(("0.0.0.0", PORTA), handler) as srv:
            print(f"Servindo {PASTA}")
            print(f"No celular (mesmo Wi-Fi): http://{ip}:{PORTA}")
            srv.serve_forever()
