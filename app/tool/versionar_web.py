"""Coloca a versão no endereço dos arquivos do build web.

O GitHub Pages manda o navegador guardar os arquivos por 10 minutos; com a
versão no endereço (?v=...), um recarregar comum já baixa o app novo.
Rodar depois de `flutter build web` (dentro de app/):

    py tool/versionar_web.py
"""

import hashlib
import pathlib
import re

web = pathlib.Path(__file__).resolve().parent.parent / 'build' / 'web'
main = (web / 'main.dart.js').read_bytes()
versao = hashlib.sha1(main).hexdigest()[:10]

boot = web / 'flutter_bootstrap.js'
s = boot.read_text(encoding='utf-8')
s = re.sub(r'"mainJsPath":"main\.dart\.js(\?v=[0-9a-f]+)?"',
           f'"mainJsPath":"main.dart.js?v={versao}"', s)
boot.write_text(s, encoding='utf-8')

index = web / 'index.html'
h = index.read_text(encoding='utf-8')
h = re.sub(r'flutter_bootstrap\.js(\?v=[0-9a-f]+)?"',
           f'flutter_bootstrap.js?v={versao}"', h)
index.write_text(h, encoding='utf-8')
print('versão', versao)
