from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env")

    mongodb_uri: str = "mongodb://localhost:27017"
    mongodb_db: str = "tatu"
    redis_url: str = "redis://localhost:6379"


settings = Settings()
