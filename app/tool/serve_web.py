"""Serve build/web na rede local para abrir o app no celular.

Uso (dentro de app/):  py tool/serve_web.py
Manda o navegador não guardar cache, para cada build novo aparecer
só recarregando a página.
"""

import functools
import http.server
from pathlib import Path

PORTA = 8080
PASTA = Path(__file__).resolve().parent.parent / "build" / "web"


class SemCache(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".mjs": "text/javascript",
    }

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()


if __name__ == "__main__":
    handler = functools.partial(SemCache, directory=str(PASTA))
    with http.server.ThreadingHTTPServer(("0.0.0.0", PORTA), handler) as srv:
        print(f"Servindo {PASTA} em http://0.0.0.0:{PORTA}")
        srv.serve_forever()
