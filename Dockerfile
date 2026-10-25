# подготовка: сборка приложения, подтягивание библиотек, FROM  - ГОТОВЫЙ ОБРАЗ
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

RUN pip install poetry poetry-plugin-export setuptools wheel

COPY pyproject.toml poetry.lock README.md ./
COPY src/ ./src/
# установочные пакеты 
RUN poetry export --without-hashes -f requirements.txt -o requirements.txt \
    && pip wheel -r requirements.txt -w /wheels \
    && poetry build -f wheel -o /wheels

# запуск
FROM python:3.11-slim-bookworm
# пакеты из подготовки
COPY --from=builder /wheels /wheels

RUN pip install --no-index --find-links=/wheels audit-svc \
    && rm -rf /wheels \
    && useradd -m appuser

USER appuser

EXPOSE 8080

CMD ["server"]