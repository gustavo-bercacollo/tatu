from arq.connections import RedisSettings

from app.config import settings


async def expandir_raio(ctx, chamado_id: str):
    """Expande o raio de busca de um chamado sem aceite após 60–90 s."""
    pass


class WorkerSettings:
    functions = [expandir_raio]
    redis_settings = RedisSettings.from_dsn(settings.redis_url)
